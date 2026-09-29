import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateVerificationStatusDto } from './dto/update-verification.dto';
import { VerificationStatus } from '@prisma/client';

@Injectable()
export class VerificationsService {
  constructor(private readonly prisma: PrismaService) {}

  async submitVerification(userId: string, documentType: string, documentUrl: string) {
    const profile = await this.prisma.matrimonialProfile.findUnique({
      where: { userId },
    });

    if (!profile) {
      throw new NotFoundException('Profile not found');
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
      throw new NotFoundException('Verification request not found');
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

      // 2. Update the Profile isVerified flag if the document was approved
      if (newStatus === VerificationStatus.VERIFIED) {
        await tx.matrimonialProfile.update({
          where: { id: request.profileId },
          data: { isVerified: true },
        });
      } else if (newStatus === VerificationStatus.REJECTED && request.profile.isVerified) {
         // Optionally revoke verification if a required document is rejected
         // Leaving this commented out, depends on specific business logic
      }

      // 3. Create the Admin Audit Log
      await tx.adminAuditLog.create({
        data: {
          adminId,
          action: 'UPDATE_VERIFICATION_STATUS',
          entityType: 'VerificationRequest',
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
      where: { status: VerificationStatus.PENDING },
      include: {
        profile: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
          },
        },
      },
    });
  }
}
