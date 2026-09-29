import { Injectable, Logger, NotFoundException, BadRequestException } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";
import { User, Role, Status, Gender } from "@prisma/client";
import { v4 as uuidv4 } from "uuid";
import * as bcrypt from "bcrypt";
import * as fs from "fs";
import * as path from "path";

@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name);
<<<<<<< HEAD
  // In-memory fallback repository when PostgreSQL is offline
  private readonly memoryUsers: Map<string, User> = new Map();
  private readonly fallbackFilePath = path.join(process.cwd(), "fallback_users.json");

  constructor(private readonly prisma: PrismaService) {
    this._initDemoUsers();
  }

  private _loadFallbackUsers() {
    if (fs.existsSync(this.fallbackFilePath)) {
      try {
        const data = fs.readFileSync(this.fallbackFilePath, "utf8");
        const users = JSON.parse(data);
        for (const user of users) {
          this.memoryUsers.set(user.email, user as User);
          this.memoryUsers.set(user.id, user as User);
        }
      } catch (err) {
        this.logger.error("Failed to load fallback users", err);
      }
    }
  }

  private _saveFallbackUsers() {
    try {
      const uniqueUsers = Array.from(this.memoryUsers.values()).filter(
        (v, i, a) => a.findIndex((u) => u.id === v.id) === i
      );
      fs.writeFileSync(this.fallbackFilePath, JSON.stringify(uniqueUsers, null, 2), "utf8");
    } catch (err) {
      this.logger.error("Failed to save fallback users", err);
    }
  }

  private async _initDemoUsers() {
    this._loadFallbackUsers();

    const passwordHash = await bcrypt.hash("password123", 10);
    const demoUser: User = {
      id: "demo-user-id-001",
      email: "test@example.com",
      phone: null,
      name: "Demo User",
      gender: null,
      passwordHash,
      role: Role.USER,
      status: Status.ACTIVE,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    if (!this.memoryUsers.has(demoUser.email!)) {
      this.memoryUsers.set(demoUser.email!, demoUser);
      this.memoryUsers.set(demoUser.id, demoUser);
    }

    const adminUser: User = {
      id: "demo-user-id-admin",
      email: "admin@vankarsamaj.org",
      phone: null,
      name: "Admin User",
      gender: null,
      passwordHash,
      role: Role.ADMIN,
      status: Status.ACTIVE,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    if (!this.memoryUsers.has(adminUser.email!)) {
      this.memoryUsers.set(adminUser.email!, adminUser);
      this.memoryUsers.set(adminUser.id, adminUser);
    }
    if (!this.memoryUsers.has(demoUser.email!)) {
      this.memoryUsers.set(demoUser.email!, demoUser);
      this.memoryUsers.set(demoUser.id, demoUser);
    }

    const parvindarUser: User = {
      id: "demo-user-id-002",
      email: "panjabiparvindar77@gmail.com",
      phone: null,
      name: "Parvindar",
      gender: null,
      passwordHash,
      role: Role.USER,
      status: Status.ACTIVE,
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    if (!this.memoryUsers.has(parvindarUser.email!)) {
      this.memoryUsers.set(parvindarUser.email!, parvindarUser);
      this.memoryUsers.set(parvindarUser.id, parvindarUser);
    }

    this._saveFallbackUsers();
  }
=======

  constructor(private readonly prisma: PrismaService) {}
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388

  async findByEmail(email?: string): Promise<User | null> {
    if (!email) return null;
    const normalized = email.toLowerCase().trim();
<<<<<<< HEAD
    try {
      return await this.prisma.user.findUnique({
        where: { email: normalized },
      });
    } catch (err: any) {
      this.logger.warn(
        `PostgreSQL offline, using in-memory user store for findByEmail(${normalized})`
      );
      return this.memoryUsers.get(normalized) ?? null;
    }
=======
    return await this.prisma.user.findUnique({
      where: { email: normalized },
    });
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
  }

  async findByPhone(phone?: string): Promise<User | null> {
    if (!phone) return null;
    try {
      return await this.prisma.user.findUnique({
        where: { phone },
      });
    } catch (err: any) {
      this.logger.warn(`PostgreSQL offline, using in-memory user store for findByPhone(${phone})`);
      return Array.from(this.memoryUsers.values()).find(u => u.phone === phone) ?? null;
    }
  }

  async findById(id: string): Promise<User | null> {
<<<<<<< HEAD
    try {
      return await this.prisma.user.findUnique({
        where: { id },
      });
    } catch (err: any) {
      this.logger.warn(
        `PostgreSQL offline, using in-memory user store for findById(${id})`
      );
      return this.memoryUsers.get(id) ?? null;
    }
=======
    return await this.prisma.user.findUnique({
      where: { id },
    });
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
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
<<<<<<< HEAD
    try {
      const user = await this.prisma.user.create({
        data: {
          email: normalizedEmail,
          phone: data.phone,
          name: data.name,
          gender: data.gender ? data.gender as Gender : null,
          passwordHash: data.passwordHash,
          role: data.role || Role.USER,
          status: data.status || Status.ACTIVE,
        },
      });
      return user;
    } catch (err: any) {
      this.logger.warn(
        `PostgreSQL offline, storing user in in-memory store for (${normalizedEmail})`
      );
      const user: User = {
        id: uuidv4(),
=======
    const user = await this.prisma.user.create({
      data: {
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
        email: normalizedEmail,
        passwordHash: data.passwordHash,
        role: data.role || Role.USER,
        status: data.status || Status.ACTIVE,
<<<<<<< HEAD
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      if (user.email) this.memoryUsers.set(user.email, user);
      this.memoryUsers.set(user.id, user);
      this._saveFallbackUsers();
      return user;
=======
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
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
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
