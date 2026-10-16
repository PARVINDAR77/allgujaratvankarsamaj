import { Test, TestingModule } from "@nestjs/testing";
import { ForbiddenException, NotFoundException, BadRequestException } from "@nestjs/common";
import { VerificationsController, AdminVerificationsController } from "./verifications.controller";
import { VerificationsService } from "./verifications.service";
import { PrismaService } from "../prisma/prisma.service";
import { Response } from "express";

describe("VerificationsController & Private Document RBAC Tests", () => {
  let verificationsController: VerificationsController;
  let adminVerificationsController: AdminVerificationsController;
  let verificationsService: VerificationsService;

  const mockPrismaService = {
    matrimonialProfile: {
      findUnique: jest.fn(),
    },
    verificationRequest: {
      findFirst: jest.fn(),
      findUnique: jest.fn(),
      findMany: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
    governmentEmploymentVerification: {
      findFirst: jest.fn(),
    },
    auditLog: {
      create: jest.fn(),
    },
  };

  const createMockResponse = (): Partial<Response> => {
    const res: any = {
      set: jest.fn().mockReturnThis(),
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
      end: jest.fn().mockReturnThis(),
    };
    return res;
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [VerificationsController, AdminVerificationsController],
      providers: [
        VerificationsService,
        {
          provide: PrismaService,
          useValue: mockPrismaService,
        },
      ],
    }).compile();

    verificationsController = module.get<VerificationsController>(VerificationsController);
    adminVerificationsController = module.get<AdminVerificationsController>(AdminVerificationsController);
    verificationsService = module.get<VerificationsService>(VerificationsService);

    jest.clearAllMocks();
  });

  describe("AdminVerificationsController.getVerificationDocumentAdmin", () => {
    it("should delegate to verificationsService.servePrivateDocument", async () => {
      const serveSpy = jest
        .spyOn(verificationsService, "servePrivateDocument")
        .mockImplementation(async () => undefined);

      const res = createMockResponse() as Response;
      await adminVerificationsController.getVerificationDocumentAdmin("proof_123.pdf", res);

      expect(serveSpy).toHaveBeenCalledWith("proof_123.pdf", res);
    });
  });

  describe("VerificationsController.getMyVerificationDocument", () => {
    it("should delegate to verificationsService.serveCandidatePrivateDocument with authenticated userId", async () => {
      const serveCandidateSpy = jest
        .spyOn(verificationsService, "serveCandidatePrivateDocument")
        .mockImplementation(async () => undefined);

      const req = { user: { id: "user-abc-123" } };
      const res = createMockResponse() as Response;

      await verificationsController.getMyVerificationDocument(req, "my_aadhaar.pdf", res);

      expect(serveCandidateSpy).toHaveBeenCalledWith("user-abc-123", "my_aadhaar.pdf", res);
    });
  });

  describe("VerificationsService - Candidate Document Ownership Enclosure", () => {
    it("should throw NotFoundException if candidate has no matrimonial profile", async () => {
      mockPrismaService.matrimonialProfile.findUnique.mockResolvedValue(null);
      const res = createMockResponse() as Response;

      await expect(
        verificationsService.serveCandidatePrivateDocument("unregistered-user", "doc.pdf", res),
      ).rejects.toThrow(NotFoundException);
    });

    it("should throw ForbiddenException if candidate does not own the requested verification document", async () => {
      mockPrismaService.matrimonialProfile.findUnique.mockResolvedValue({
        id: "profile-owner-1",
        userId: "user-1",
      });
      // Verification request belonging to someone else
      mockPrismaService.verificationRequest.findFirst.mockResolvedValue(null);
      const res = createMockResponse() as Response;

      await expect(
        verificationsService.serveCandidatePrivateDocument("user-1", "other_user_doc.pdf", res),
      ).rejects.toThrow(ForbiddenException);
    });

    it("should serve document if candidate owns the verification record", async () => {
      mockPrismaService.matrimonialProfile.findUnique.mockResolvedValue({
        id: "profile-owner-1",
        userId: "user-1",
      });
      mockPrismaService.verificationRequest.findFirst.mockResolvedValue({
        id: "ver-1",
        profileId: "profile-owner-1",
        documentUrl: "private_uploads/user-1-doc.pdf",
      });

      const servePrivateSpy = jest
        .spyOn(verificationsService, "servePrivateDocument")
        .mockImplementation(async () => undefined);

      const res = createMockResponse() as Response;
      await verificationsService.serveCandidatePrivateDocument("user-1", "user-1-doc.pdf", res);

      expect(servePrivateSpy).toHaveBeenCalledWith("user-1-doc.pdf", res);
    });
  });

  describe("VerificationsService.servePrivateDocument Filename Validation", () => {
    it("should reject path traversal attempts (..)", async () => {
      const res = createMockResponse() as Response;
      await expect(
        verificationsService.servePrivateDocument("../../../etc/passwd", res),
      ).rejects.toThrow(BadRequestException);
    });

    it("should reject disallowed extensions (.exe, .sh, .php)", async () => {
      const res = createMockResponse() as Response;
      await expect(
        verificationsService.servePrivateDocument("malicious.php", res),
      ).rejects.toThrow(BadRequestException);

      await expect(
        verificationsService.servePrivateDocument("exploit.sh", res),
      ).rejects.toThrow(BadRequestException);
    });

    it("should throw NotFoundException for non-existent document file", async () => {
      const res = createMockResponse() as Response;
      await expect(
        verificationsService.servePrivateDocument("non_existent_doc_123.pdf", res),
      ).rejects.toThrow(NotFoundException);
    });
  });
});
