import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
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
import * as fs from "fs";
import * as fsPromises from "fs/promises";
import * as path from "path";


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
    const docHashMatch = docFilename?.match(/(?:idproof|doc)_([a-f0-9]{16,64})/i);
    const docHash = docHashMatch ? docHashMatch[1] : null;

    const docFilters: any[] = [{ documentUrl: cleanDoc }, { documentBackUrl: cleanDoc }];
    if (docFilename && docFilename.length > 5) {
      docFilters.push({ documentUrl: { contains: docFilename } });
      docFilters.push({ documentBackUrl: { contains: docFilename } });
    }
    if (docHash) {
      docFilters.push({ documentUrl: { contains: docHash } });
      docFilters.push({ documentBackUrl: { contains: docHash } });
    }

    const docUsedElsewhere = await this.prisma.verificationRequest.findFirst({
      where: {
        profileId: { not: profile.id },
        OR: docFilters,
      },
    });
    if (docUsedElsewhere) {
      throw new ConflictException(
        "આ દસ્તાવેજ અન્ય ઉમેદવાર દ્વારા પહેલેથી જ જમા થયેલ છે. દસ્તાવેજો માત્ર એક જ વાર ઉપયોગ કરી શકાય છે. (This document has already been submitted for another candidate. Documents can only be used one time.)",
      );
    }

    const docUsedInGovt = await this.prisma.governmentEmploymentVerification.findFirst({
      where: {
        OR: docFilters.map((f) => ({ documentUrl: f.documentUrl || f.documentBackUrl })),
      },
    });
    if (docUsedInGovt) {
      throw new ConflictException(
        "આ દસ્તાવેજ પહેલેથી જ જમા થયેલ છે. દસ્તાવેજો માત્ર એક જ વાર ઉપયોગ કરી શકાય છે. (This document has already been submitted. Documents can only be used one time.)",
      );
    }

    // Check if an existing request already exists for this profile (any status)
    const existingReq = await this.prisma.verificationRequest.findFirst({
      where: {
        profileId: profile.id,
      },
      orderBy: { createdAt: "desc" },
    });

    if (existingReq) {
      return this.prisma.verificationRequest.update({
        where: { id: existingReq.id },
        data: {
          documentType,
          documentUrl,
          status: VerificationStatus.PENDING,
          rejectionReason: null,
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
    const allRequests = await this.prisma.verificationRequest.findMany({
      orderBy: { createdAt: "desc" },
      include: {
        profile: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            photoUrl: true,
            photos: true,
            nativePlace: true,
            city: true,
            pargana: {
              select: {
                id: true,
                name: true,
                gujaratiName: true,
              },
            },
            user: {
              select: {
                id: true,
                phone: true,
                email: true,
                name: true,
                status: true,
              },
            },
          },
        },
      },
    });

    // Deduplicate by profileId: return the single latest verification record for each profile
    const seenProfileIds = new Set<string>();
    const deduplicated = [];
    for (const req of allRequests) {
      const key = req.profileId || (req.profile && req.profile.id);
      if (!key) continue;
      if (!seenProfileIds.has(key)) {
        seenProfileIds.add(key);
        deduplicated.push(req);
      }
    }

    return deduplicated;
  }

  async getMyVerificationStatus(userId: string) {
    const profile = await this.prisma.matrimonialProfile.findUnique({
      where: { userId },
    });

    if (!profile) {
      return {
        hasProfile: false,
        isVerified: false,
        profileStatus: "NOT_CREATED",
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

    if (isStub) {
      return {
        hasProfile: false,
        isVerified: false,
        profileStatus: "NOT_CREATED",
        latestRequest: null,
      };
    }

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

  /**
   * Serve Private Verification Document
   * Restricts access to authorized callers.
   * Checks file existence, symlink absence, and canonical realpath containment.
   */
  async servePrivateDocument(filename: string, res: any) {
    if (
      !filename ||
      !/^[a-zA-Z0-9_\-.]+\.(jpg|jpeg|png|webp|pdf)$/i.test(filename) ||
      filename.includes("..")
    ) {
      throw new BadRequestException("Invalid document filename format");
    }

    const privateDir = path.resolve(process.cwd(), "private_uploads");
    const targetFile = path.resolve(privateDir, filename);

    if (!targetFile.startsWith(privateDir + path.sep)) {
      throw new ForbiddenException("Access outside private document storage is forbidden");
    }

    let fileHandle: fsPromises.FileHandle | null = null;
    try {
      // 1. Verify private directory is a genuine directory and not a symlink
      const privateDirLstat = await fsPromises.lstat(privateDir);
      if (privateDirLstat.isSymbolicLink() || !privateDirLstat.isDirectory()) {
        throw new ForbiddenException("Private document storage directory is invalid or a symlink");
      }
      const canonicalPrivateDir = await fsPromises.realpath(privateDir);

      // 2. Verify target file is a regular file and not a symlink before opening
      const targetLstat = await fsPromises.lstat(targetFile);
      if (targetLstat.isSymbolicLink() || !targetLstat.isFile()) {
        throw new ForbiddenException("Target document is a symlink or non-regular file");
      }

      // 3. Fail closed on POSIX if O_NOFOLLOW is unsupported
      if (process.platform !== "win32") {
        if (typeof fs.constants.O_NOFOLLOW !== "number" || fs.constants.O_NOFOLLOW === 0) {
          throw new Error("Security invariant violated: O_NOFOLLOW is required on POSIX platform");
        }
      }

      const openFlags = fs.constants.O_RDONLY | (fs.constants.O_NOFOLLOW || 0);
      fileHandle = await fsPromises.open(targetFile, openFlags);
      const handleStat = await fileHandle.stat();

      if (!handleStat.isFile()) {
        await fileHandle.close();
        throw new ForbiddenException("Invalid file type or non-regular file detected");
      }

      // 4. Verify canonical realpath containment inside private_uploads
      const canonicalTarget = await fsPromises.realpath(targetFile);
      if (!canonicalTarget.startsWith(canonicalPrivateDir + path.sep)) {
        await fileHandle.close();
        throw new ForbiddenException("Canonical file path escapes private storage");
      }

      // 5. Inode & Device Consistency Check (Defeats TOCTOU races)
      const canonicalStat = await fsPromises.stat(canonicalTarget);
      if (handleStat.dev !== canonicalStat.dev || handleStat.ino !== canonicalStat.ino) {
        await fileHandle.close();
        throw new ForbiddenException("File descriptor device/inode does not match canonical document");
      }

      const ext = path.extname(filename).toLowerCase();
      const mimeTypes: Record<string, string> = {
        ".pdf": "application/pdf",
        ".jpg": "image/jpeg",
        ".jpeg": "image/jpeg",
        ".png": "image/png",
        ".webp": "image/webp",
      };
      const contentType = mimeTypes[ext] || "application/octet-stream";

      res.set({
        "Content-Type": contentType,
        "Content-Length": handleStat.size.toString(),
        "Content-Disposition": `inline; filename="${filename}"`,
        "Cache-Control": "private, no-cache, no-store, must-revalidate",
        "X-Content-Type-Options": "nosniff",
      });

      // 6. Streaming Lifecycle & Safe File Handle Cleanup
      let isCleanedUp = false;
      const cleanupHandle = async () => {
        if (!isCleanedUp && fileHandle) {
          isCleanedUp = true;
          await fileHandle.close().catch(() => {});
        }
      };

      const fileStream = fileHandle.createReadStream();

      res.on("close", () => {
        if (!fileStream.destroyed) {
          fileStream.destroy();
        }
        cleanupHandle();
      });

      fileStream.on("error", () => {
        cleanupHandle();
        if (!res.headersSent) {
          res.status(500).json({ statusCode: 500, error: "Internal Server Error", message: "Failed to stream document safely." });
        }
      });

      fileStream.on("end", () => {
        cleanupHandle();
      });

      fileStream.pipe(res);
    } catch (err: any) {
      if (fileHandle) {
        await fileHandle.close().catch(() => {});
      }
      if (err.code === "ENOENT") {
        throw new NotFoundException("Verification document not found");
      }
      if (err.code === "ELOOP" || err.code === "EACCES" || err.code === "EPERM") {
        throw new ForbiddenException("Symbolic links and unauthorized access are forbidden");
      }
      throw err;
    }
  }

  /**
   * Serve Candidate's Own Private Document
   * Verifies that the authenticated candidate owns the requested verification record.
   */
  async serveCandidatePrivateDocument(userId: string, filename: string, res: any) {
    const profile = await this.prisma.matrimonialProfile.findUnique({
      where: { userId },
    });
    if (!profile) {
      throw new NotFoundException("Profile not found");
    }

    const verification = await this.prisma.verificationRequest.findFirst({
      where: {
        profileId: profile.id,
        documentUrl: { contains: filename },
      },
    });

    if (!verification) {
      throw new ForbiddenException("You are not authorized to view this document");
    }

    return this.servePrivateDocument(filename, res);
  }
}

