import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";
import { UpdateVerificationStatusDto } from "./dto/update-verification.dto";
import {
  VerificationStatus,
  Gender,
  MaritalStatus,
  ProfileStatus,
} from "@prisma/client";

@Injectable()
export class VerificationsService {
  constructor(private readonly prisma: PrismaService) {}

  async submitVerification(
    userId: string,
    documentType: string,
    documentUrl: string,
  ) {
    if (!documentUrl || documentUrl.trim().length === 0) {
      throw new BadRequestException("કૃપા કરીને દસ્તાવેજ અપલોડ કરો (Please upload a document)");
    }

    let profile = await this.prisma.matrimonialProfile.findUnique({
      where: { userId },
    });

    if (!profile) {
      const user = await this.prisma.user.findUnique({
        where: { id: userId },
      });
      if (!user) {
        throw new NotFoundException("User not found");
      }

      const nameParts = (user.name || "User").trim().split(" ");
      const firstName = nameParts[0] || "User";
      const lastName = nameParts.slice(1).join(" ") || "Member";

      profile = await this.prisma.matrimonialProfile.create({
        data: {
          userId,
          firstName,
          lastName,
          gender: user.gender || Gender.MALE,
          dateOfBirth: new Date(2000, 0, 1),
          maritalStatus: MaritalStatus.NEVER_MARRIED,
          status: ProfileStatus.PENDING,
          isVerified: false,
        },
      });
    }

    // Single-use document rule: If candidate is ALREADY verified, documents cannot be re-submitted
    if (profile.isVerified) {
      throw new ConflictException(
        "તમારી પ્રોફાઇલ પહેલેથી જ વેરિફાઈડ છે. ઉમેદવાર દસ્તાવેજો માત્ર એક જ વાર ઉપયોગ કરી શકે છે. (Your profile is already verified. Documents can only be used one time.)",
      );
    }

    // Check if an approved verification request already exists
    const alreadyApproved = await this.prisma.verificationRequest.findFirst({
      where: {
        profileId: profile.id,
        status: VerificationStatus.VERIFIED,
      },
    });
    if (alreadyApproved) {
      throw new ConflictException(
        "તમારા દસ્તાવેજો પહેલેથી જ મંજૂર થયેલ છે. દસ્તાવેજો માત્ર એક જ વાર ઉપયોગ કરી શકાય છે. (Verification already approved. Documents can only be used one time.)",
      );
    }

    // Single-use document rule: Check if this document was already submitted for another candidate
    const cleanDoc = documentUrl.trim().toLowerCase();
    const docFilename = cleanDoc.split("/").pop()?.split("?")[0];

    const docUsedElsewhere = await this.prisma.verificationRequest.findFirst({
      where: {
        profileId: { not: profile.id },
        OR: [
          { documentUrl: cleanDoc },
          ...(docFilename && docFilename.length > 5
            ? [{ documentUrl: { contains: docFilename } }]
            : []),
        ],
      },
    });
    if (docUsedElsewhere) {
      throw new ConflictException(
        "આ દસ્તાવેજ અન્ય ઉમેદવાર દ્વારા પહેલેથી જ જમા થયેલ છે. દસ્તાવેજો માત્ર એક જ વાર ઉપયોગ કરી શકાય છે. (This document has already been submitted for another candidate. Documents can only be used one time.)",
      );
    }

    const docUsedInGovt = await this.prisma.governmentEmploymentVerification.findFirst({
      where: {
        OR: [
          { documentUrl: cleanDoc },
          ...(docFilename && docFilename.length > 5
            ? [{ documentUrl: { contains: docFilename } }]
            : []),
        ],
      },
    });
    if (docUsedInGovt) {
      throw new ConflictException(
        "આ દસ્તાવેજ પહેલેથી જ જમા થયેલ છે. દસ્તાવેજો માત્ર એક જ વાર ઉપયોગ કરી શકાય છે. (This document has already been submitted. Documents can only be used one time.)",
      );
    }

    // Check if an existing PENDING request already exists for this profile
    const existingPending = await this.prisma.verificationRequest.findFirst({
      where: {
        profileId: profile.id,
        status: VerificationStatus.PENDING,
      },
    });

    if (existingPending) {
      return this.prisma.verificationRequest.update({
        where: { id: existingPending.id },
        data: {
          documentType,
          documentUrl,
          createdAt: new Date(),
        },
      });
    }

    return this.prisma.verificationRequest.create({
      data: {
        profileId: profile.id,
        documentType,
        documentUrl,
        status: VerificationStatus.PENDING,
      },
    });
  }

  async updateVerificationStatus(
    requestId: string,
    adminId: string,
    dto: UpdateVerificationStatusDto,
    ipAddress?: string,
  ) {
    const request = await this.prisma.verificationRequest.findUnique({
      where: { id: requestId },
      include: {
        profile: true,
      },
    });

    if (!request) {
      throw new NotFoundException("Verification request not found");
    }

    const oldStatus = request.status;
    const newStatus = dto.status;

    // Use a transaction to ensure all updates succeed or fail together
    return this.prisma.$transaction(async (tx) => {
      // 1. Update the Verification Request
      const updatedRequest = await tx.verificationRequest.update({
        where: { id: requestId },
        data: {
          status: newStatus,
          rejectionReason: dto.rejectionReason || null,
        },
      });

      // 2. Update the Profile isVerified and status flags
      if (newStatus === VerificationStatus.VERIFIED) {
        await tx.matrimonialProfile.update({
          where: { id: request.profileId },
          data: {
            isVerified: true,
            status: ProfileStatus.APPROVED,
          },
        });
        if (request.profile && request.profile.userId) {
          await tx.user.update({
            where: { id: request.profile.userId },
            data: { status: "ACTIVE" as any },
          });
        }
      } else if (newStatus === VerificationStatus.REJECTED) {
        await tx.matrimonialProfile.update({
          where: { id: request.profileId },
          data: {
            isVerified: false,
            status: ProfileStatus.REJECTED,
          },
        });
      }

      // 3. Create the Admin Audit Log
      await tx.adminAuditLog.create({
        data: {
          adminId,
          action: "UPDATE_VERIFICATION_STATUS",
          entityType: "VerificationRequest",
          entityId: requestId,
          oldValue: oldStatus,
          newValue: newStatus,
          ipAddress: ipAddress || null,
        },
      });

      return updatedRequest;
    });
  }

  async getPendingVerifications() {
    return this.prisma.verificationRequest.findMany({
      orderBy: { createdAt: "desc" },
      include: {
        profile: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            pargana: {
              select: {
                name: true,
              },
            },
          },
        },
      },
    });
  }

  async getMyVerificationStatus(userId: string) {
    const profile = await this.prisma.matrimonialProfile.findUnique({
      where: { userId },
    });

    if (!profile) {
      return {
        hasProfile: false,
        isVerified: false,
        profileStatus: ProfileStatus.PENDING,
        latestRequest: null,
      };
    }

    const isStub =
      profile.firstName === "User" &&
      profile.lastName === "Member" &&
      !profile.religion &&
      !profile.education &&
      !profile.caste;

    const hasProfile = !isStub;

    const latestRequest = await this.prisma.verificationRequest.findFirst({
      where: { profileId: profile.id },
      orderBy: { createdAt: "desc" },
    });

    return {
      hasProfile,
      isVerified: profile.isVerified === true && profile.status === ProfileStatus.APPROVED,
      profileStatus: profile.status,
      latestRequest: latestRequest
        ? {
            id: latestRequest.id,
            documentType: latestRequest.documentType,
            documentUrl: latestRequest.documentUrl,
            status: latestRequest.status,
            rejectionReason: latestRequest.rejectionReason,
            createdAt: latestRequest.createdAt,
          }
        : null,
    };
  }
}
