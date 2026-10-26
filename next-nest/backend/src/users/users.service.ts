import {
  Injectable,
  Logger,
  NotFoundException,
  BadRequestException,
  ConflictException,
} from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";
import { User, Role, Status, Gender, ProfileStatus, VerificationStatus, MaritalStatus } from "@prisma/client";
import { v4 as uuidv4 } from "uuid";
import * as bcrypt from "bcrypt";
import { normalizeGender } from "../profiles/dto/normalize-profile.helper";

export function normalizePhoneNumber(phone?: string | null): {
  isValid: boolean;
  canonical10?: string;
  variants: string[];
} {
  if (!phone || typeof phone !== "string") {
    return { isValid: false, variants: [] };
  }
  const trimmed = phone.trim();
  if (!trimmed) {
    return { isValid: false, variants: [] };
  }
  // Remove all non-digit characters
  const digitsOnly = trimmed.replace(/\D/g, "");

  if (digitsOnly.length === 10) {
    return {
      isValid: true,
      canonical10: digitsOnly,
      variants: [digitsOnly, `+91${digitsOnly}`, `91${digitsOnly}`],
    };
  }

  if (digitsOnly.length === 12 && digitsOnly.startsWith("91")) {
    const tenDigit = digitsOnly.slice(2);
    return {
      isValid: true,
      canonical10: tenDigit,
      variants: [tenDigit, `+91${tenDigit}`, `91${tenDigit}`],
    };
  }

  return { isValid: false, variants: [] };
}

@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name);

  constructor(private readonly prisma: PrismaService) {}

  async findByEmail(email?: string): Promise<User | null> {
    if (!email) return null;
    const normalized = email.toLowerCase().trim();
    return await this.prisma.user.findUnique({
      where: { email: normalized },
    });
  }

  async findByPhone(phone?: string): Promise<User | null> {
    const norm = normalizePhoneNumber(phone);
    if (!norm.isValid || norm.variants.length === 0) {
      return null;
    }

    const matches = await this.prisma.user.findMany({
      where: {
        phone: { in: norm.variants },
      },
      take: 2,
    });

    if (matches.length === 0) {
      return null;
    }

    if (matches.length > 1) {
      this.logger.error(
        `Ambiguous phone lookup detected for input: "${phone}". Multiple user records match variants: [${norm.variants.join(", ")}]. Failing safely.`,
      );
      return null;
    }

    return matches[0];
  }

  async findById(id: string): Promise<User | null> {
    return await this.prisma.user.findUnique({
      where: { id },
    });
  }

  async createUser(data: {
    email?: string;
    phone?: string;
    name?: string;
    gender?: string;
    passwordHash: string;
    role?: Role;
    status?: Status;
    isEmailVerified?: boolean;
    isPhoneVerified?: boolean;
  }): Promise<User> {
    const normalizedEmail =
      data.email?.toLowerCase().trim() || `${uuidv4()}@vankar.org`;
    const resolvedGender = normalizeGender(data.gender);
    try {
      const user = await this.prisma.user.create({
        data: {
          email: normalizedEmail,
          phone: data.phone,
          name: data.name,
          gender: resolvedGender,
          passwordHash: data.passwordHash,
          role: data.role || Role.USER,
          status: data.status || Status.ACTIVE,
          isEmailVerified: data.isEmailVerified ?? false,
          isPhoneVerified: data.isPhoneVerified ?? false,
        },
      });
      return user;
    } catch (err: any) {
      if (err.code === "P2002") {
        throw new ConflictException(
          "આ ઈમેઈલ અથવા મોબાઇલ નંબર પહેલેથી જ નોંધાયેલ છે (Email or mobile number is already registered)",
        );
      }
      throw err;
    }
  }

  // --- Admin Endpoints ---

  async getAllUsersForAdmin() {
    try {
      const users = await this.prisma.user.findMany({
        orderBy: { createdAt: "desc" },
        select: {
          id: true,
          name: true,
          email: true,
          phone: true,
          status: true,
          role: true,
          createdAt: true,
          profile: {
            select: {
              firstName: true,
              lastName: true,
              city: true,
              nativePlace: true,
            },
          },
        },
      });
      return users.map((u) => ({
        id: u.id,
        name:
          u.name ||
          (u.profile?.firstName
            ? `${u.profile.firstName} ${u.profile.lastName || ""}`.trim()
            : u.email || "Member"),
        email: u.email || "",
        phone: u.phone || "9876543210",
        pargana: u.profile?.city || u.profile?.nativePlace || "35 Pargana",
        status: u.status,
        role: u.role,
        createdAt: u.createdAt,
      }));
    } catch (err) {
      this.logger.error("Failed to query admin users with profiles, falling back to basic users", err);
      const basicUsers = await this.prisma.user.findMany({
        orderBy: { createdAt: "desc" },
        select: {
          id: true,
          name: true,
          email: true,
          phone: true,
          status: true,
          role: true,
          createdAt: true,
        },
      });
      return basicUsers.map((u) => ({
        id: u.id,
        name: u.name || u.email || "Member",
        email: u.email || "",
        phone: u.phone || "9876543210",
        pargana: "35 Pargana",
        status: u.status,
        role: u.role,
        createdAt: u.createdAt,
      }));
    }
  }

  async updateUserStatusAdmin(
    userId: string,
    adminId: string,
    status: Status,
    ipAddress?: string,
  ) {
    if (!Object.values(Status).includes(status)) {
      throw new BadRequestException("Invalid status");
    }

    return this.prisma.$transaction(async (tx) => {
      const user = await tx.user.findUnique({
        where: { id: userId },
        include: { profile: true },
      });
      if (!user) throw new NotFoundException("User not found");

      const updatedUser = await tx.user.update({
        where: { id: userId },
        data: { status },
      });

      // Synchronize matrimonial profile and government employment statuses with user status
      if (status === Status.INACTIVE) {
        // Suspend profile and remove from public listings
        await tx.matrimonialProfile.updateMany({
          where: { userId },
          data: {
            status: ProfileStatus.SUSPENDED,
            showInMatrimony: false,
            isVerified: false,
          },
        });

        const profileId = user.profile?.id;
        if (profileId) {
          await tx.governmentEmployment.updateMany({
            where: { profileId },
            data: { isActive: false, isFeatured: false },
          });
        }
      } else if (status === Status.ACTIVE) {
        // Activate profile and restore to matrimonial listings only if candidate is eligible (not MARRIED)
        const userProfile = await tx.matrimonialProfile.findUnique({ where: { userId } });
        const canShowInMatrimony = Boolean(userProfile && userProfile.maritalStatus !== MaritalStatus.MARRIED);
        await tx.matrimonialProfile.updateMany({
          where: { userId },
          data: {
            status: ProfileStatus.APPROVED,
            showInMatrimony: canShowInMatrimony,
            isVerified: true,
          },
        });

        const profileId = user.profile?.id;
        if (profileId) {
          await tx.governmentEmployment.updateMany({
            where: { profileId },
            data: { isActive: true },
          });
        }
      }

      await tx.adminAuditLog.create({
        data: {
          adminId,
          action: status === Status.INACTIVE ? "SUSPEND_USER_ACCOUNT" : "ACTIVATE_USER_ACCOUNT",
          entityId: userId,
          entityType: "User",
          oldValue: JSON.stringify({ status: user.status }),
          newValue: JSON.stringify({ status: updatedUser.status }),
          ipAddress: ipAddress || null,
        },
      });

      return {
        id: updatedUser.id,
        status: updatedUser.status,
      };
    });
  }

  async updateUserRoleAdmin(
    userId: string,
    adminId: string,
    role: Role,
    ipAddress?: string,
  ) {
    if (!Object.values(Role).includes(role)) {
      throw new BadRequestException("Invalid role");
    }

    return this.prisma.$transaction(async (tx) => {
      const user = await tx.user.findUnique({ where: { id: userId } });
      if (!user) throw new NotFoundException("User not found");

      const updatedUser = await tx.user.update({
        where: { id: userId },
        data: { role },
      });

      await tx.adminAuditLog.create({
        data: {
          adminId,
          action: "UPDATE_USER_ROLE",
          entityId: userId,
          entityType: "User",
          oldValue: JSON.stringify({ role: user.role }),
          newValue: JSON.stringify({ role: updatedUser.role }),
          ipAddress: ipAddress || null,
        },
      });

      return {
        id: updatedUser.id,
        role: updatedUser.role,
      };
    });
  }

  async getAllProfilesForAdmin() {
    try {
      const profiles = await this.prisma.matrimonialProfile.findMany({
        orderBy: { createdAt: "desc" },
        select: {
          id: true,
          userId: true,
          firstName: true,
          lastName: true,
          dateOfBirth: true,
          gender: true,
          nativePlace: true,
          city: true,
          education: true,
          occupation: true,
          photoUrl: true,
          photos: true,
          status: true,
          isVerified: true,
          isFeatured: true,
          createdAt: true,
          user: {
            select: {
              email: true,
              phone: true,
            },
          },
          verificationRequests: {
            orderBy: { createdAt: "desc" },
            take: 1,
            select: {
              id: true,
              documentType: true,
              documentUrl: true,
              documentBackUrl: true,
              status: true,
              createdAt: true,
            },
          },
        },
      });
      return profiles.map((p) => {
        let parsedPhotos: string[] = [];
        if (p.photos) {
          try {
            parsedPhotos = JSON.parse(p.photos);
          } catch (_) {
            parsedPhotos = [p.photos];
          }
        } else if (p.photoUrl) {
          parsedPhotos = [p.photoUrl];
        }

        return {
          id: p.id,
          userId: p.userId,
          name: `${p.firstName} ${p.lastName || ""}`.trim(),
          age: p.dateOfBirth
            ? new Date().getFullYear() - new Date(p.dateOfBirth).getFullYear()
            : 26,
          gender: p.gender,
          pargana: p.nativePlace || "35 Pargana",
          city: p.city || "Ahmedabad",
          education: p.education || "Graduate",
          occupation: p.occupation || "Service",
          photoUrl: p.photoUrl,
          photos: parsedPhotos,
          verification:
            p.verificationRequests && p.verificationRequests[0]
              ? p.verificationRequests[0]
              : null,
          user: p.user,
          status: p.status || "PENDING",
          isVerified: p.isVerified,
          isFeatured: p.isFeatured,
          createdAt: p.createdAt,
        };
      });
    } catch (err) {
      this.logger.error("Failed to query admin matrimonial profiles", err);
      return [];
    }
  }

  async updateProfileStatusAdmin(
    profileId: string,
    adminId: string,
    status: string,
    ipAddress?: string,
  ) {
    return this.prisma.$transaction(async (tx) => {
      const profile = await tx.matrimonialProfile.findUnique({
        where: { id: profileId },
      });
      if (!profile) throw new NotFoundException("Profile not found");

      let profileStatus: ProfileStatus;
      let isVerified = false;
      let showInMatrimony = false;
      let userStatus: Status = Status.ACTIVE;

      if (status === "APPROVED" || status === "ACTIVE") {
        profileStatus = ProfileStatus.APPROVED;
        isVerified = true;
        // Strictly exclude married individuals from matrimonial listings
        showInMatrimony = profile.maritalStatus !== MaritalStatus.MARRIED && (profile as any).marital_status !== "MARRIED";
        userStatus = Status.ACTIVE;
      } else if (status === "SUSPENDED" || status === "INACTIVE") {
        profileStatus = ProfileStatus.SUSPENDED;
        isVerified = false;
        showInMatrimony = false;
        userStatus = Status.INACTIVE;
      } else {
        profileStatus = ProfileStatus.REJECTED;
        isVerified = false;
        showInMatrimony = false;
        userStatus = Status.ACTIVE;
      }

      const updatedProfile = await tx.matrimonialProfile.update({
        where: { id: profileId },
        data: {
          status: profileStatus,
          isVerified,
          showInMatrimony,
        },
      });

      // Synchronize with User account status
      if (profile.userId) {
        await tx.user.update({
          where: { id: profile.userId },
          data: { status: userStatus },
        });
      }

      // Also update any pending verification requests for this profile
      await tx.verificationRequest.updateMany({
        where: { profileId, status: VerificationStatus.PENDING },
        data: {
          status: isVerified ? VerificationStatus.VERIFIED : VerificationStatus.REJECTED,
        },
      });

      // Also update any government employment status for this profile
      await tx.governmentEmployment.updateMany({
        where: { profileId },
        data: {
          verificationStatus: isVerified ? "VERIFIED" : "REJECTED",
          isActive: isVerified,
        },
      });

      await tx.adminAuditLog.create({
        data: {
          adminId,
          action: "UPDATE_PROFILE_STATUS",
          entityId: profileId,
          entityType: "MatrimonialProfile",
          oldValue: JSON.stringify({ status: profile.status, isVerified: profile.isVerified }),
          newValue: JSON.stringify({ status: updatedProfile.status, isVerified: updatedProfile.isVerified }),
          ipAddress: ipAddress || null,
        },
      });

      return { id: profileId, status: updatedProfile.status, isVerified: updatedProfile.isVerified };
    });
  }

  async toggleProfileFeaturedAdmin(
    profileId: string,
    adminId: string,
    isFeatured: boolean,
    ipAddress?: string,
  ) {
    return this.prisma.$transaction(async (tx) => {
      const profile = await tx.matrimonialProfile.findUnique({
        where: { id: profileId },
      });
      if (!profile) throw new NotFoundException("Profile not found");

      const updatedProfile = await tx.matrimonialProfile.update({
        where: { id: profileId },
        data: { isFeatured },
      });

      await tx.governmentEmployment.updateMany({
        where: { profileId },
        data: { isFeatured },
      });

      await tx.adminAuditLog.create({
        data: {
          adminId,
          action: "TOGGLE_PROFILE_FEATURED",
          entityId: profileId,
          entityType: "MatrimonialProfile",
          oldValue: JSON.stringify({ isFeatured: profile.isFeatured }),
          newValue: JSON.stringify({ isFeatured: updatedProfile.isFeatured }),
          ipAddress: ipAddress || null,
        },
      });

      return { id: profileId, isFeatured: updatedProfile.isFeatured };
    });
  }

  async deleteUserAccount(
    userId: string,
    deletedByAdminId?: string,
    ipAddress?: string,
  ): Promise<{ success: boolean; message: string }> {
    return this.prisma.$transaction(async (tx) => {
      const user = await tx.user.findUnique({
        where: { id: userId },
        include: { profile: true },
      });

      if (!user) {
        throw new NotFoundException("વપરાશકર્તા મળ્યો નથી (User not found)");
      }

      // Security check: Admin cannot delete their own account
      if (deletedByAdminId && deletedByAdminId === userId) {
        throw new BadRequestException(
          "એડમિન પોતાનું એકાઉન્ટ ડિલીટ કરી શકતા નથી (Super Admin cannot delete their own account)",
        );
      }

      // Security check: Protect root admin
      if (
        user.email === "admin@vankarsamaj.org" ||
        user.email === "admin@vankarsamaj.com"
      ) {
        throw new BadRequestException(
          "રૂટ સિસ્ટમ એડમિન એકાઉન્ટ ડિલીટ કરી શકાતું નથી (Root System Administrator cannot be deleted)",
        );
      }

      // Resolve profileId if exists
      const profile = user.profile || (await tx.matrimonialProfile.findUnique({ where: { userId } }));
      const profileId = profile?.id;

      if (profileId) {
        // 1. Delete verification requests
        await tx.verificationRequest.deleteMany({
          where: { profileId },
        });

        // 2. Delete government employment verifications & employments
        const govtList = await tx.governmentEmployment.findMany({
          where: { profileId },
          select: { id: true },
        });
        const govtIds = govtList.map((g) => g.id);
        if (govtIds.length > 0) {
          await tx.governmentEmploymentVerification.deleteMany({
            where: { employmentId: { in: govtIds } },
          });
          await tx.governmentEmployment.deleteMany({
            where: { id: { in: govtIds } },
          });
        }

        // 3. Delete match interests (both sent and received)
        await tx.matchInterest.deleteMany({
          where: {
            OR: [
              { senderProfileId: profileId },
              { receiverProfileId: profileId },
            ],
          },
        });

        // 4. Delete shortlists targeting this profile
        await tx.shortlist.deleteMany({
          where: { targetProfileId: profileId },
        });

        // 5. Delete reports targeting this profile
        await tx.report.deleteMany({
          where: { targetProfileId: profileId },
        });

        // 6. Delete matrimonial profile
        await tx.matrimonialProfile.deleteMany({
          where: { id: profileId },
        });
      }

      // 7. Delete user's own shortlists
      await tx.shortlist.deleteMany({
        where: { userId },
      });

      // 8. Delete user notifications
      await tx.userNotification.deleteMany({
        where: { userId },
      });

      // 9. Find all chat conversations involving this user
      const conversations = await tx.chatConversation.findMany({
        where: {
          OR: [{ participant1Id: userId }, { participant2Id: userId }],
        },
        select: { id: true },
      });
      const convIds = conversations.map((c) => c.id);

      // 10. Delete all messages inside these conversations first (to prevent foreign key restrict errors)
      if (convIds.length > 0) {
        await tx.chatMessage.deleteMany({
          where: { conversationId: { in: convIds } },
        });
        await tx.chatConversation.deleteMany({
          where: { id: { in: convIds } },
        });
      }

      // 11. Delete any remaining messages sent or received by this user
      await tx.chatMessage.deleteMany({
        where: {
          OR: [{ senderId: userId }, { receiverId: userId }],
        },
      });

      // 12. Delete reports created by user
      await tx.report.deleteMany({
        where: { reporterUserId: userId },
      });

      // 13. Delete samaj service persons registered by or linked to user
      await tx.samajServicePerson.deleteMany({
        where: { userId },
      });

      // 14. Unlink any advertisements created by user
      await tx.advertisement.updateMany({
        where: { createdBy: userId },
        data: { createdBy: null },
      });

      // 15. Audit log if deleted by admin
      if (deletedByAdminId) {
        await tx.adminAuditLog.create({
          data: {
            adminId: deletedByAdminId,
            action: "DELETE_USER_ACCOUNT",
            entityId: userId,
            entityType: "User",
            oldValue: JSON.stringify({
              id: user.id,
              email: user.email,
              phone: user.phone,
              name: user.name,
              role: user.role,
            }),
            newValue: null,
            ipAddress: ipAddress || null,
          },
        });
      }

      // 16. Finally delete User record
      await tx.user.delete({
        where: { id: userId },
      });

      return {
        success: true,
        message:
          "વપરાશકર્તા એકાઉન્ટ અને તમામ ડેટા કાયમ માટે કાઢી નાખવામાં આવ્યા છે (User account and all data deleted permanently)",
      };
    });
  }

  async deleteProfileAdmin(
    profileIdOrUserId: string,
    adminId: string,
    ipAddress?: string,
  ): Promise<{ success: boolean; message: string }> {
    return this.prisma.$transaction(async (tx) => {
      let profile = await tx.matrimonialProfile.findUnique({
        where: { id: profileIdOrUserId },
      });
      if (!profile) {
        profile = await tx.matrimonialProfile.findUnique({
          where: { userId: profileIdOrUserId },
        });
      }

      if (!profile) {
        throw new NotFoundException("પ્રોફાઇલ મળી નથી (Profile not found)");
      }

      const profileId = profile.id;

      // 1. Delete verification requests
      await tx.verificationRequest.deleteMany({ where: { profileId } });

      // 2. Delete government employment & verifications
      const govtList = await tx.governmentEmployment.findMany({
        where: { profileId },
        select: { id: true },
      });
      const govtIds = govtList.map((g) => g.id);
      if (govtIds.length > 0) {
        await tx.governmentEmploymentVerification.deleteMany({
          where: { employmentId: { in: govtIds } },
        });
        await tx.governmentEmployment.deleteMany({
          where: { id: { in: govtIds } },
        });
      }

      // 3. Delete match interests
      await tx.matchInterest.deleteMany({
        where: {
          OR: [
            { senderProfileId: profileId },
            { receiverProfileId: profileId },
          ],
        },
      });

      // 4. Delete shortlists targeting this profile
      await tx.shortlist.deleteMany({ where: { targetProfileId: profileId } });

      // 5. Delete reports
      await tx.report.deleteMany({ where: { targetProfileId: profileId } });

      // 6. Delete profile
      await tx.matrimonialProfile.deleteMany({ where: { id: profileId } });

      // 7. Audit log
      await tx.adminAuditLog.create({
        data: {
          adminId,
          action: "DELETE_PROFILE",
          entityId: profileId,
          entityType: "MatrimonialProfile",
          oldValue: JSON.stringify({
            id: profile.id,
            userId: profile.userId,
            name: `${profile.firstName} ${profile.lastName}`,
          }),
          newValue: null,
          ipAddress: ipAddress || null,
        },
      });

      return {
        success: true,
        message:
          "મેટ્રિમોનિયલ પ્રોફાઇલ સફળતાપૂર્વક કાઢી નાખવામાં આવી છે (Matrimonial profile deleted successfully)",
      };
    });
  }
}
