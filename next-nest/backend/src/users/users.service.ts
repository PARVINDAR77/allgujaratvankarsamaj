import { Injectable, Logger } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";
import { User, Role, Status, Gender } from "@prisma/client";
import { v4 as uuidv4 } from "uuid";
import * as bcrypt from "bcrypt";

@Injectable()
export class UsersService {
  private readonly logger = new Logger(UsersService.name);
  // In-memory fallback repository when PostgreSQL is offline
  private readonly memoryUsers: Map<string, User> = new Map();

  constructor(private readonly prisma: PrismaService) {
    this._initDemoUsers();
  }

  private async _initDemoUsers() {
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
    this.memoryUsers.set(demoUser.email!, demoUser);
    this.memoryUsers.set(demoUser.id, demoUser);

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
    this.memoryUsers.set(parvindarUser.email!, parvindarUser);
    this.memoryUsers.set(parvindarUser.id, parvindarUser);
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
        `PostgreSQL offline, using in-memory user store for findByEmail(${normalized})`,
      );
      return this.memoryUsers.get(normalized) ?? null;
    }
  }

  async findByPhone(phone?: string): Promise<User | null> {
    if (!phone) return null;
    const cleanPhone = phone.replace(/\D/g, "").slice(-10);
    try {
      const user = await this.prisma.user.findFirst({
        where: { OR: [{ phone }, { phone: cleanPhone }] },
      });
      if (user) return user;
    } catch {
      // Fallback in-memory lookup
    }
    for (const u of this.memoryUsers.values()) {
      if (u.phone && (u.phone === phone || u.phone.replace(/\D/g, "").slice(-10) === cleanPhone)) {
        return u;
      }
    }
    return null;
  }

  async findById(id: string): Promise<User | null> {
    try {
      return await this.prisma.user.findUnique({
        where: { id },
      });
    } catch (err: any) {
      this.logger.warn(
        `PostgreSQL offline, using in-memory user store for findById(${id})`,
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
    const normalizedEmail = data.email?.toLowerCase().trim();
    try {
      const user = await this.prisma.user.create({
        data: {
          email: normalizedEmail,
          phone: data.phone,
          name: data.name,
          gender: data.gender as Gender | undefined,
          passwordHash: data.passwordHash,
          role: data.role || Role.USER,
          status: data.status || Status.ACTIVE,
        },
      });
      return user;
    } catch (err: any) {
      this.logger.warn(
        `PostgreSQL offline, storing user in in-memory store for (${normalizedEmail ?? data.phone})`,
      );
      const user: User = {
        id: uuidv4(),
        email: normalizedEmail ?? null,
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
      if (user.phone) this.memoryUsers.set(user.phone, user);
      this.memoryUsers.set(user.id, user);
      return user;
    }
  }
}
