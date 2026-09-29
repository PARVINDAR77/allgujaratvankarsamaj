import { Injectable, Logger, NotFoundException, BadRequestException } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";
import { User, Role, Status, Gender } from "@prisma/client";
import { v4 as uuidv4 } from "uuid";
import * as bcrypt from "bcrypt";

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
    if (!phone) return null;
    return null;
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
  }): Promise<User> {
    const normalizedEmail = data.email?.toLowerCase().trim() || `${uuidv4()}@vankar.org`;
    const user = await this.prisma.user.create({
      data: {
        email: normalizedEmail,
        passwordHash: data.passwordHash,
        role: data.role || Role.USER,
        status: data.status || Status.ACTIVE,
      },
    });
    return user;
  }

  // --- Admin Endpoints ---

  async getAllUsersForAdmin() {
    const users = await this.prisma.user.findMany({
      orderBy: { createdAt: "desc" },
      include: { profile: true },
    });
    return users.map((u) => ({
      id: u.id,
      name: (u as any).name || (u.profile?.firstName ? `${u.profile.firstName} ${u.profile.lastName}`.trim() : u.email || "Member"),
      email: u.email,
      phone: (u as any).phone || "9876543210",
      pargana: u.profile?.city || "35 Pargana",
      status: u.status,
      role: u.role,
      createdAt: u.createdAt,
    }));
  }

  async updateUserStatusAdmin(userId: string, adminId: string, status: Status, ipAddress?: string) {
    if (!Object.values(Status).includes(status)) {
      throw new BadRequestException("Invalid status");
    }

    return this.prisma.$transaction(async (tx) => {
      const user = await tx.user.findUnique({ where: { id: userId } });
      if (!user) throw new NotFoundException("User not found");

      const updatedUser = await tx.user.update({
        where: { id: userId },
        data: { status },
      });

      await tx.adminAuditLog.create({
        data: {
          adminId,
          action: "UPDATE_USER_STATUS",
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

  async updateUserRoleAdmin(userId: string, adminId: string, role: Role, ipAddress?: string) {
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
    const profiles = await this.prisma.matrimonialProfile.findMany({
      orderBy: { createdAt: "desc" },
      include: { user: true },
    });
    return profiles.map((p) => ({
      id: p.id,
      userId: p.userId,
      name: `${p.firstName} ${p.lastName}`.trim(),
      age: p.dateOfBirth ? new Date().getFullYear() - new Date(p.dateOfBirth).getFullYear() : 26,
      gender: p.gender,
      pargana: p.city || "35 Pargana",
      city: p.city || "Ahmedabad",
      education: p.education || "Graduate",
      occupation: p.occupation || "Service",
      status: p.status || "APPROVED",
      isVerified: p.isVerified,
      isFeatured: p.isFeatured,
      createdAt: p.createdAt,
    }));
  }

  async updateProfileStatusAdmin(profileId: string, adminId: string, status: string, ipAddress?: string) {
    return this.prisma.$transaction(async (tx) => {
      const profile = await tx.matrimonialProfile.findUnique({ where: { id: profileId } });
      if (!profile) throw new NotFoundException("Profile not found");

      const updatedProfile = await tx.matrimonialProfile.update({
        where: { id: profileId },
        data: { status: status as any },
      });

      await tx.adminAuditLog.create({
        data: {
          adminId,
          action: "UPDATE_PROFILE_STATUS",
          entityId: profileId,
          entityType: "MatrimonialProfile",
          oldValue: JSON.stringify({ status: profile.status }),
          newValue: JSON.stringify({ status: updatedProfile.status }),
          ipAddress: ipAddress || null,
        },
      });

      return { id: profileId, status: updatedProfile.status };
    });
  }

  async toggleProfileFeaturedAdmin(profileId: string, adminId: string, isFeatured: boolean, ipAddress?: string) {
    return this.prisma.$transaction(async (tx) => {
      const profile = await tx.matrimonialProfile.findUnique({ where: { id: profileId } });
      if (!profile) throw new NotFoundException("Profile not found");

      const updatedProfile = await tx.matrimonialProfile.update({
        where: { id: profileId },
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
}
