import { Injectable, Logger } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";
import { User, Role, Status, Gender } from "@prisma/client";
import { v4 as uuidv4 } from "uuid";
import * as bcrypt from "bcrypt";
import * as fs from "fs";
import * as path from "path";

@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name);
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

  async findByEmail(email?: string): Promise<User | null> {
    if (!email) return null;
    const normalized = email.toLowerCase().trim();
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
        email: normalizedEmail,
        phone: data.phone ?? null,
        name: data.name ?? null,
        gender: (data.gender as Gender) ?? null,
        passwordHash: data.passwordHash,
        role: data.role || Role.USER,
        status: data.status || Status.ACTIVE,
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      if (user.email) this.memoryUsers.set(user.email, user);
      this.memoryUsers.set(user.id, user);
      this._saveFallbackUsers();
      return user;
    }
  }
}
