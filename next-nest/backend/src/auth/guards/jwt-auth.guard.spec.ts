import { ExecutionContext, UnauthorizedException } from "@nestjs/common";
import { Reflector } from "@nestjs/core";
import { JwtAuthGuard } from "./jwt-auth.guard";
import { Role } from "@prisma/client";

describe("JwtAuthGuard & Optional Authentication Tests", () => {
  let guard: JwtAuthGuard;
  let reflector: Reflector;

  const mockUser = {
    id: "user-123",
    email: "member@vankarsamaj.org",
    role: Role.USER,
  };

  const mockAdmin = {
    id: "admin-456",
    email: "admin@vankarsamaj.org",
    role: Role.ADMIN,
  };

  beforeEach(() => {
    reflector = new Reflector();
    guard = new JwtAuthGuard(reflector);
  });

  function createMockContext(options: {
    isPublic: boolean;
    headers?: Record<string, string>;
    cookies?: Record<string, string>;
    user?: any;
  }): ExecutionContext {
    const req: any = {
      headers: options.headers || {},
      cookies: options.cookies || {},
      user: options.user || null,
    };

    jest.spyOn(reflector, "getAllAndOverride").mockReturnValue(options.isPublic);

    return {
      getHandler: jest.fn(),
      getClass: jest.fn(),
      switchToHttp: jest.fn().mockReturnValue({
        getRequest: () => req,
        getResponse: () => ({}),
      }),
    } as unknown as ExecutionContext;
  }

  describe("Public Routes (@Public())", () => {
    it("MUST permit anonymous requests with no token and set req.user to null", async () => {
      const context = createMockContext({ isPublic: true });
      const req = context.switchToHttp().getRequest();

      const canActivate = await guard.canActivate(context);

      expect(canActivate).toBe(true);
      expect(req.user).toBeNull();
    });

    it("MUST populate req.user with verified user when valid Bearer token is provided", async () => {
      const context = createMockContext({
        isPublic: true,
        headers: { authorization: "Bearer valid.member.jwt" },
      });
      const req = context.switchToHttp().getRequest();

      // Mock Passport's super.canActivate to simulate successful JWT strategy validation
      jest.spyOn(Object.getPrototypeOf(Object.getPrototypeOf(guard)), "canActivate").mockImplementation(
        async () => {
          req.user = mockUser;
          return true;
        },
      );

      const canActivate = await guard.canActivate(context);

      expect(canActivate).toBe(true);
      expect(req.user).toEqual(mockUser);
      expect(req.user.role).toBe(Role.USER);
    });

    it("MUST fail safely and set req.user to null when token is invalid or malformed", async () => {
      const context = createMockContext({
        isPublic: true,
        headers: { authorization: "Bearer malformed.or.tampered.token" },
      });
      const req = context.switchToHttp().getRequest();

      jest.spyOn(Object.getPrototypeOf(Object.getPrototypeOf(guard)), "canActivate").mockImplementation(
        async () => {
          throw new UnauthorizedException("jwt malformed");
        },
      );

      const canActivate = await guard.canActivate(context);

      // Public access remains permitted, but with NO privileged user attached
      expect(canActivate).toBe(true);
      expect(req.user).toBeNull();
    });

    it("MUST fail safely and set req.user to null when token is expired", async () => {
      const context = createMockContext({
        isPublic: true,
        headers: { authorization: "Bearer expired.jwt.token" },
      });
      const req = context.switchToHttp().getRequest();

      jest.spyOn(Object.getPrototypeOf(Object.getPrototypeOf(guard)), "canActivate").mockImplementation(
        async () => {
          throw new UnauthorizedException("jwt expired");
        },
      );

      const canActivate = await guard.canActivate(context);

      expect(canActivate).toBe(true);
      expect(req.user).toBeNull();
    });

    it("MUST populate req.user when valid admin_token cookie is provided", async () => {
      const context = createMockContext({
        isPublic: true,
        cookies: { admin_token: "valid.admin.jwt.cookie" },
      });
      const req = context.switchToHttp().getRequest();

      jest.spyOn(Object.getPrototypeOf(Object.getPrototypeOf(guard)), "canActivate").mockImplementation(
        async () => {
          req.user = mockAdmin;
          return true;
        },
      );

      const canActivate = await guard.canActivate(context);

      expect(canActivate).toBe(true);
      expect(req.user).toEqual(mockAdmin);
      expect(req.user.role).toBe(Role.ADMIN);
    });

    it("MUST fail safely and set req.user to null when admin_token cookie is invalid or forged", async () => {
      const context = createMockContext({
        isPublic: true,
        cookies: { admin_token: "forged.admin.cookie" },
      });
      const req = context.switchToHttp().getRequest();

      jest.spyOn(Object.getPrototypeOf(Object.getPrototypeOf(guard)), "canActivate").mockImplementation(
        async () => {
          throw new UnauthorizedException("invalid signature");
        },
      );

      const canActivate = await guard.canActivate(context);

      expect(canActivate).toBe(true);
      expect(req.user).toBeNull();
    });
  });

  describe("Protected Routes (No @Public())", () => {
    it("MUST reject missing authentication with UnauthorizedException", async () => {
      const context = createMockContext({ isPublic: false });

      jest.spyOn(Object.getPrototypeOf(Object.getPrototypeOf(guard)), "canActivate").mockImplementation(
        async () => {
          throw new UnauthorizedException("Unauthorized access");
        },
      );

      await expect(guard.canActivate(context)).rejects.toThrow(UnauthorizedException);
    });

    it("MUST reject invalid or expired tokens with UnauthorizedException", async () => {
      const context = createMockContext({
        isPublic: false,
        headers: { authorization: "Bearer expired.jwt" },
      });

      jest.spyOn(Object.getPrototypeOf(Object.getPrototypeOf(guard)), "canActivate").mockImplementation(
        async () => {
          throw new UnauthorizedException("jwt expired");
        },
      );

      await expect(guard.canActivate(context)).rejects.toThrow(UnauthorizedException);
    });

    it("MUST allow access and populate req.user when valid token is provided on protected routes", async () => {
      const context = createMockContext({
        isPublic: false,
        headers: { authorization: "Bearer valid.token" },
      });
      const req = context.switchToHttp().getRequest();

      jest.spyOn(Object.getPrototypeOf(Object.getPrototypeOf(guard)), "canActivate").mockImplementation(
        async () => {
          req.user = mockUser;
          return true;
        },
      );

      const canActivate = await guard.canActivate(context);
      expect(canActivate).toBe(true);
      expect(req.user).toEqual(mockUser);
    });
  });

  describe("handleRequest method", () => {
    it("returns null on public routes when error or no user", () => {
      const context = createMockContext({ isPublic: true });
      expect(guard.handleRequest(new Error("jwt expired"), null, null, context)).toBeNull();
      expect(guard.handleRequest(null, null, null, context)).toBeNull();
    });

    it("returns user on public routes when valid user present", () => {
      const context = createMockContext({ isPublic: true });
      expect(guard.handleRequest(null, mockUser, null, context)).toEqual(mockUser);
    });

    it("throws UnauthorizedException on protected routes when error or no user", () => {
      const context = createMockContext({ isPublic: false });
      expect(() => guard.handleRequest(null, null, null, context)).toThrow(UnauthorizedException);
      expect(() => guard.handleRequest(new Error("err"), null, null, context)).toThrow(Error);
    });
  });
});
