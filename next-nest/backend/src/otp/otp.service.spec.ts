import { Test, TestingModule } from "@nestjs/testing";
import { OtpService } from "./otp.service";
import { SmsService } from "./sms.service";
import { MailService } from "./mail.service";
import { PrismaService } from "../prisma/prisma.service";
import { OtpChannel, OtpPurpose, OtpStatus } from "@prisma/client";
import { HttpException, HttpStatus, BadRequestException, ConflictException } from "@nestjs/common";

describe("OtpService - Security, Throttling & Verification Tests", () => {
  let service: OtpService;
  let prisma: any;
  let smsService: any;
  let mailService: any;

  beforeEach(async () => {
    prisma = {
      user: {
        findFirst: jest.fn(),
      },
      otpSession: {
        findFirst: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
        deleteMany: jest.fn(),
        delete: jest.fn(),
        count: jest.fn(),
      },
      otpLog: {
        create: jest.fn(),
        findMany: jest.fn(),
        count: jest.fn(),
      },
    };

    smsService = {
      cleanPhoneNumber: jest.fn((p) => p.replace(/\D/g, "").slice(-10)),
      sendOtpSms: jest.fn().mockResolvedValue({ success: true, messageId: "msg_123" }),
    };

    mailService = {
      isConfigured: jest.fn().mockReturnValue(true),
      sendOtpEmail: jest.fn().mockResolvedValue({ success: true, messageId: "email_123" }),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        OtpService,
        { provide: PrismaService, useValue: prisma },
        { provide: SmsService, useValue: smsService },
        { provide: MailService, useValue: mailService },
      ],
    }).compile();

    service = module.get<OtpService>(OtpService);
  });

  describe("Registration Flow (Dual Verification)", () => {
    it("MUST reject registration OTP request if phone is already registered", async () => {
      prisma.user.findFirst.mockResolvedValueOnce({
        id: "user-1",
        phone: "9876543210",
        isPhoneVerified: true,
      });

      await expect(
        service.sendRegistrationOtp({
          name: "Ramesh",
          phone: "9876543210",
          email: "ramesh@example.com",
        }),
      ).rejects.toThrow(ConflictException);
    });

    it("MUST dispatch both SMS and Email OTPs when inputs are valid and available", async () => {
      prisma.user.findFirst.mockResolvedValue(null);
      prisma.otpSession.findFirst.mockResolvedValue(null);

      const res = await service.sendRegistrationOtp({
        name: "Ramesh",
        phone: "9876543210",
        email: "ramesh@example.com",
      });

      expect(res.success).toBe(true);
      expect(smsService.sendOtpSms).toHaveBeenCalled();
      expect(mailService.sendOtpEmail).toHaveBeenCalled();
      expect(prisma.otpSession.create).toHaveBeenCalledTimes(2);
    });

    it("MUST lockout user for 10 minutes when failing 4 attempts on verification", async () => {
      const phoneSession = {
        id: "sess_phone",
        target: "9876543210",
        code: "123456",
        attempts: 3, // next attempt will be 4th
        expiresAt: new Date(Date.now() + 600000),
        lockedUntil: null,
      };
      const emailSession = {
        id: "sess_email",
        target: "ramesh@example.com",
        code: "654321",
        attempts: 0,
        expiresAt: new Date(Date.now() + 600000),
        lockedUntil: null,
      };

      prisma.otpSession.findFirst.mockImplementation(({ where }: any) => {
        if (where?.target === "9876543210") return Promise.resolve(phoneSession);
        if (where?.target === "ramesh@example.com") return Promise.resolve(emailSession);
        return Promise.resolve(null);
      });

      await expect(
        service.verifyRegistrationOtp({
          phone: "9876543210",
          email: "ramesh@example.com",
          phoneOtp: "999999", // wrong OTP
          emailOtp: "654321",
        }),
      ).rejects.toThrow(HttpException);

      expect(prisma.otpSession.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: "sess_phone" },
          data: expect.objectContaining({
            attempts: 4,
            lockedUntil: expect.any(Date),
          }),
        }),
      );
    });

    it("MUST issue signed registrationToken when both mobile and email OTPs are correct", async () => {
      const phoneSession = {
        id: "sess_phone",
        target: "9876543210",
        code: "123456",
        attempts: 0,
        expiresAt: new Date(Date.now() + 600000),
        lockedUntil: null,
      };
      const emailSession = {
        id: "sess_email",
        target: "ramesh@example.com",
        code: "654321",
        attempts: 0,
        expiresAt: new Date(Date.now() + 600000),
        lockedUntil: null,
      };

      prisma.otpSession.findFirst.mockImplementation(({ where }: any) => {
        if (where?.target === "9876543210") return Promise.resolve(phoneSession);
        if (where?.target === "ramesh@example.com") return Promise.resolve(emailSession);
        return Promise.resolve(null);
      });

      const res = await service.verifyRegistrationOtp({
        phone: "9876543210",
        email: "ramesh@example.com",
        phoneOtp: "123456",
        emailOtp: "654321",
      });

      expect(res.success).toBe(true);
      expect(res.verified).toBe(true);
      expect(res.registrationToken).toMatch(/^reg_/);
    });
  });

  describe("Super Admin Analytics", () => {
    it("MUST return daily summary breakdown of SMS vs Email OTPs", async () => {
      prisma.otpLog.findMany
        .mockResolvedValueOnce([
          { channel: OtpChannel.SMS, purpose: OtpPurpose.REGISTRATION, status: OtpStatus.DELIVERED },
          { channel: OtpChannel.EMAIL, purpose: OtpPurpose.REGISTRATION, status: OtpStatus.DELIVERED },
          { channel: OtpChannel.SMS, purpose: OtpPurpose.FORGOT_PASSWORD, status: OtpStatus.DELIVERED },
        ])
        .mockResolvedValueOnce([
          { channel: OtpChannel.SMS, status: OtpStatus.DELIVERED },
        ]);
      prisma.otpSession.count.mockResolvedValue(0);
      prisma.otpLog.count.mockResolvedValue(150);

      const summary = await service.getDailySummary();
      expect(summary.success).toBe(true);
      expect(summary.today.total).toBe(3);
      expect(summary.today.smsCount).toBe(2);
      expect(summary.today.emailCount).toBe(1);
      expect(summary.yesterday.total).toBe(1);
      expect(summary.totalAllTime).toBe(150);
    });
  });
});
