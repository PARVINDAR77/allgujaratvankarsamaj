import { Test, TestingModule } from "@nestjs/testing";
import { ConflictException, UnauthorizedException } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { JwtService } from "@nestjs/jwt";
import * as bcrypt from "bcrypt";
import { Role, Status, ProfileStatus } from "@prisma/client";
import { AuthService } from "./auth.service";
import { UsersService } from "../users/users.service";
import { PrismaService } from "../prisma/prisma.service";

describe("AuthService Security & Regression Tests", () => {
  let authService: AuthService;
  let usersService: Partial<Record<keyof UsersService, jest.Mock>>;
  let jwtService: Partial<Record<keyof JwtService, jest.Mock>>;
  let configService: Partial<Record<keyof ConfigService, jest.Mock>>;
  let prismaService: any;

  const validPlainPassword = "StrongSecretPassword123!";
  let storedHash: string;

  beforeAll(async () => {
    storedHash = await bcrypt.hash(validPlainPassword, 10);
  });

  beforeEach(async () => {
    usersService = {
      findByEmail: jest.fn(),
      findByPhone: jest.fn(),
      createUser: jest.fn(),
    };

    jwtService = {
      sign: jest.fn().mockReturnValue("mocked.jwt.token"),
    };

    configService = {
      get: jest.fn().mockImplementation((key: string, def?: any) => def ?? "1d"),
    };

    prismaService = {
      matrimonialProfile: {
        findUnique: jest.fn(),
        findFirst: jest.fn(),
      },
      user: {
        update: jest.fn(),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: UsersService, useValue: usersService },
        { provide: JwtService, useValue: jwtService },
        { provide: ConfigService, useValue: configService },
        { provide: PrismaService, useValue: prismaService },
      ],
    }).compile();

    authService = module.get<AuthService>(AuthService);
  });

  describe("VULN-AUTH-01 Remediation Verification", () => {
    it("MUST reject incorrect password with UnauthorizedException and NEVER issue token", async () => {
      const activeUser = {
        id: "user-123",
        email: "member@vankarsamaj.org",
        phone: "9876543210",
        passwordHash: storedHash,
        role: Role.USER,
        status: Status.ACTIVE,
      };

      (usersService.findByEmail as jest.Mock).mockResolvedValue(activeUser);

      await expect(
        authService.login({
          email: "member@vankarsamaj.org",
          password: "WrongPasswordAttempt!",
        }),
      ).rejects.toThrow(UnauthorizedException);

      // Verify token was NEVER signed
      expect(jwtService.sign).not.toHaveBeenCalled();

      // Verify password hash in database was NEVER mutated
      expect(prismaService.user.update).not.toHaveBeenCalled();
      expect(activeUser.passwordHash).toBe(storedHash);
    });

    it("MUST reject unknown accounts with UnauthorizedException and NEVER auto-provision a user", async () => {
      (usersService.findByEmail as jest.Mock).mockResolvedValue(null);
      (usersService.findByPhone as jest.Mock).mockResolvedValue(null);

      await expect(
        authService.login({
          email: "unknown.account@example.test",
          password: "SomePassword123!",
        }),
      ).rejects.toThrow(UnauthorizedException);

      // Verify createUser was NEVER called
      expect(usersService.createUser).not.toHaveBeenCalled();
      expect(jwtService.sign).not.toHaveBeenCalled();
    });

    it("MUST reject inactive / suspended accounts", async () => {
      const inactiveUser = {
        id: "user-suspended",
        email: "suspended@vankarsamaj.org",
        phone: "9876543211",
        passwordHash: storedHash,
        role: Role.USER,
        status: Status.INACTIVE,
      };

      (usersService.findByEmail as jest.Mock).mockResolvedValue(inactiveUser);

      await expect(
        authService.login({
          email: "suspended@vankarsamaj.org",
          password: validPlainPassword,
        }),
      ).rejects.toThrow(UnauthorizedException);

      expect(jwtService.sign).not.toHaveBeenCalled();
    });

    it("MUST successfully authenticate valid credentials and issue JWT with correct claims", async () => {
      const activeUser = {
        id: "admin-001",
        email: "superadmin@vankarsamaj.org",
        phone: "9876543212",
        passwordHash: storedHash,
        role: Role.SUPER_ADMIN,
        status: Status.ACTIVE,
      };

      (usersService.findByEmail as jest.Mock).mockResolvedValue(activeUser);
      (prismaService.matrimonialProfile.findUnique as jest.Mock).mockResolvedValue({
        id: "profile-admin",
        firstName: "Super",
        lastName: "Admin",
        status: ProfileStatus.APPROVED,
        isVerified: true,
      });

      const result = await authService.login({
        email: "superadmin@vankarsamaj.org",
        password: validPlainPassword,
      });

      expect(result).toBeDefined();
      expect(result.accessToken).toBe("mocked.jwt.token");
      expect(result.user.email).toBe("superadmin@vankarsamaj.org");
      expect(result.user.role).toBe(Role.SUPER_ADMIN);

      // Verify JWT claims passed to sign()
      expect(jwtService.sign).toHaveBeenCalledWith({
        sub: "admin-001",
        email: "superadmin@vankarsamaj.org",
        role: Role.SUPER_ADMIN,
        isVerified: true,
        hasProfile: true,
      });
    });

    it("MUST authenticate valid credentials using 10-digit mobile phone number", async () => {
      const activeUser = {
        id: "user-mobile-001",
        email: "mobile@vankarsamaj.org",
        phone: "9876543213",
        passwordHash: storedHash,
        role: Role.USER,
        status: Status.ACTIVE,
      };

      (usersService.findByPhone as jest.Mock).mockResolvedValue(activeUser);
      (prismaService.matrimonialProfile.findUnique as jest.Mock).mockResolvedValue(null);

      const result = await authService.login({
        phone: "9876543213",
        password: validPlainPassword,
      });

      expect(result).toBeDefined();
      expect(result.accessToken).toBe("mocked.jwt.token");
      expect(result.user.id).toBe("user-mobile-001");
      expect(jwtService.sign).toHaveBeenCalledWith(
        expect.objectContaining({ sub: "user-mobile-001" }),
      );
    });
  });

  describe("Registration Flow Security", () => {
    it("MUST reject registration with ConflictException if email is already registered", async () => {
      (usersService.findByEmail as jest.Mock).mockResolvedValue({ id: "existing-user" });

      await expect(
        authService.register({
          email: "existing@vankarsamaj.org",
          password: "NewPassword123!",
        }),
      ).rejects.toThrow(ConflictException);

      expect(usersService.createUser).not.toHaveBeenCalled();
    });

    it("MUST reject registration with ConflictException if email is already in a MatrimonialProfile", async () => {
      (usersService.findByEmail as jest.Mock).mockResolvedValue(null);
      (prismaService.matrimonialProfile.findFirst as jest.Mock).mockResolvedValue({ id: "profile-with-email" });

      await expect(
        authService.register({
          email: "profile.email@vankarsamaj.org",
          password: "NewPassword123!",
        }),
      ).rejects.toThrow(ConflictException);

      expect(usersService.createUser).not.toHaveBeenCalled();
    });

    it("MUST reject registration with ConflictException if phone number is already registered", async () => {
      (usersService.findByEmail as jest.Mock).mockResolvedValue(null);
      (prismaService.matrimonialProfile.findFirst as jest.Mock).mockResolvedValue(null);
      (usersService.findByPhone as jest.Mock).mockResolvedValue({ id: "existing-phone-user" });

      await expect(
        authService.register({
          email: "new.user@vankarsamaj.org",
          phone: "9876543210",
          password: "NewPassword123!",
        }),
      ).rejects.toThrow(ConflictException);

      expect(usersService.createUser).not.toHaveBeenCalled();
    });

    it("MUST hash password with bcrypt and return sanitized user without passwordHash", async () => {
      (usersService.findByEmail as jest.Mock).mockResolvedValue(null);
      (prismaService.matrimonialProfile.findFirst as jest.Mock).mockResolvedValue(null);
      (usersService.findByPhone as jest.Mock).mockResolvedValue(null);

      (usersService.createUser as jest.Mock).mockImplementation(async (userData) => ({
        id: "created-user-01",
        email: userData.email,
        phone: userData.phone,
        passwordHash: userData.passwordHash,
        role: Role.USER,
        status: Status.ACTIVE,
      }));

      const result = await authService.register({
        email: "brand.new@vankarsamaj.org",
        phone: "9876543219",
        password: "SuperSecretPassword123!",
      });

      expect(result).toBeDefined();
      expect(result.id).toBe("created-user-01");
      expect(result.email).toBe("brand.new@vankarsamaj.org");
      // Password hash MUST NOT be exposed in registration response
      expect((result as any).passwordHash).toBeUndefined();
      expect(usersService.createUser).toHaveBeenCalledWith(
        expect.objectContaining({
          email: "brand.new@vankarsamaj.org",
          phone: "9876543219",
          passwordHash: expect.stringMatching(/^\$2[aby]?\$\d+\$/),
        }),
      );
    });
  });
});
