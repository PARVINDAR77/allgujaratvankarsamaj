import { Test, TestingModule } from "@nestjs/testing";
import { ConflictException } from "@nestjs/common";
import { Role, Status, User } from "@prisma/client";
import { UsersService, normalizePhoneNumber } from "./users.service";
import { PrismaService } from "../prisma/prisma.service";

describe("UsersService - Phone Normalization & Ambiguity Detection", () => {
  let service: UsersService;
  let prisma: any;

  beforeEach(async () => {
    prisma = {
      user: {
        findMany: jest.fn(),
        findUnique: jest.fn(),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        { provide: PrismaService, useValue: prisma },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
  });

  describe("normalizePhoneNumber helper", () => {
    it("MUST normalize a standard 10-digit phone number", () => {
      const res = normalizePhoneNumber("9876543210");
      expect(res.isValid).toBe(true);
      expect(res.canonical10).toBe("9876543210");
      expect(res.variants).toEqual(["9876543210", "+919876543210", "919876543210"]);
    });

    it("MUST normalize a 12-digit number with +91 prefix", () => {
      const res = normalizePhoneNumber("+919876543210");
      expect(res.isValid).toBe(true);
      expect(res.canonical10).toBe("9876543210");
      expect(res.variants).toEqual(["9876543210", "+919876543210", "919876543210"]);
    });

    it("MUST normalize a 12-digit number with 91 prefix without plus", () => {
      const res = normalizePhoneNumber("919876543210");
      expect(res.isValid).toBe(true);
      expect(res.canonical10).toBe("9876543210");
      expect(res.variants).toEqual(["9876543210", "+919876543210", "919876543210"]);
    });

    it("MUST clean whitespace, dashes, and parentheses", () => {
      const res = normalizePhoneNumber(" +91 (98765) 43-210 ");
      expect(res.isValid).toBe(true);
      expect(res.canonical10).toBe("9876543210");
      expect(res.variants).toEqual(["9876543210", "+919876543210", "919876543210"]);
    });

    it("MUST reject numbers with invalid lengths", () => {
      expect(normalizePhoneNumber("12345").isValid).toBe(false);
      expect(normalizePhoneNumber("9876543210999").isValid).toBe(false);
      expect(normalizePhoneNumber("9198765").isValid).toBe(false);
    });

    it("MUST reject empty, null, or undefined values", () => {
      expect(normalizePhoneNumber("").isValid).toBe(false);
      expect(normalizePhoneNumber("   ").isValid).toBe(false);
      expect(normalizePhoneNumber(null).isValid).toBe(false);
      expect(normalizePhoneNumber(undefined).isValid).toBe(false);
    });
  });

  describe("UsersService.findByPhone with safe matching", () => {
    const mockUser1: User = {
      id: "user-phone-1",
      email: "user1@vankarsamaj.org",
      phone: "9876543210",
      passwordHash: "hash1",
      role: Role.USER,
      status: Status.ACTIVE,
      name: "User One",
      gender: null,
      isEmailVerified: true,
      isPhoneVerified: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    const mockUser2: User = {
      id: "user-phone-2",
      email: "user2@vankarsamaj.org",
      phone: "+919876543210",
      passwordHash: "hash2",
      role: Role.USER,
      status: Status.ACTIVE,
      name: "User Two",
      gender: null,
      isEmailVerified: true,
      isPhoneVerified: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    it("MUST return matching user when exactly one record is found", async () => {
      prisma.user.findMany.mockResolvedValue([mockUser1]);

      const result = await service.findByPhone("9876543210");
      expect(result).toBeDefined();
      expect(result?.id).toBe("user-phone-1");
      expect(prisma.user.findMany).toHaveBeenCalledWith({
        where: {
          phone: { in: ["9876543210", "+919876543210", "919876543210"] },
        },
        take: 2,
      });
    });

    it("MUST return null if no user matches", async () => {
      prisma.user.findMany.mockResolvedValue([]);

      const result = await service.findByPhone("9876543210");
      expect(result).toBeNull();
    });

    it("MUST fail safely and return null when duplicate/ambiguous legacy records match", async () => {
      prisma.user.findMany.mockResolvedValue([mockUser1, mockUser2]);

      const loggerSpy = jest.spyOn((service as any).logger, "error").mockImplementation();

      const result = await service.findByPhone("9876543210");

      // Verify safe fail-closed behavior: NEVER return an arbitrary user!
      expect(result).toBeNull();
      expect(loggerSpy).toHaveBeenCalledWith(
        expect.stringContaining("Ambiguous phone lookup detected"),
      );
    });

    it("MUST return null immediately for invalid or missing phone", async () => {
      expect(await service.findByPhone("")).toBeNull();
      expect(await service.findByPhone("1234")).toBeNull();
      expect(await service.findByPhone(undefined)).toBeNull();
      expect(prisma.user.findMany).not.toHaveBeenCalled();
    });
  });

  describe("UsersService.createUser race condition & uniqueness", () => {
    it("MUST throw ConflictException when concurrent insertion causes Prisma P2002 error", async () => {
      const p2002Error: any = new Error("Unique constraint failed");
      p2002Error.code = "P2002";
      prisma.user.create = jest.fn().mockRejectedValue(p2002Error);

      await expect(
        service.createUser({
          email: "race.condition@vankarsamaj.org",
          passwordHash: "hash123",
        }),
      ).rejects.toThrow(ConflictException);
    });
  });
});
