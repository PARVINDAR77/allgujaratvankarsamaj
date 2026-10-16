import { Test, TestingModule } from "@nestjs/testing";
import { BadRequestException, NotFoundException } from "@nestjs/common";
import { InterestsService } from "./interests.service";
import { PrismaService } from "../prisma/prisma.service";

describe("InterestsService - Authorization & Self-Accept Prevention", () => {
  let service: InterestsService;
  let prisma: any;

  beforeEach(async () => {
    prisma = {
      matrimonialProfile: {
        findUnique: jest.fn(),
        findFirst: jest.fn(),
      },
      matchInterest: {
        findUnique: jest.fn(),
        findFirst: jest.fn(),
        findMany: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
      },
      chatConversation: {
        findUnique: jest.fn(),
        create: jest.fn(),
      },
      userNotification: {
        create: jest.fn(),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        InterestsService,
        { provide: PrismaService, useValue: prisma },
      ],
    }).compile();

    service = module.get<InterestsService>(InterestsService);
  });

  describe("acceptInterest security boundary", () => {
    it("MUST reject sender attempt to self-accept own pending interest (CRITICAL FIX)", async () => {
      // Caller is Sender User (id: "user-sender") whose profile is "profile-sender"
      prisma.matrimonialProfile.findUnique.mockResolvedValue({
        id: "profile-sender",
        userId: "user-sender",
      });

      // The interest has senderProfileId = "profile-sender" and receiverProfileId = "profile-receiver"
      prisma.matchInterest.findUnique.mockResolvedValue({
        id: "interest-123",
        senderProfileId: "profile-sender",
        receiverProfileId: "profile-receiver",
        status: "PENDING",
      });

      await expect(
        service.acceptInterest("user-sender", "interest-123"),
      ).rejects.toThrow(BadRequestException);

      await expect(
        service.acceptInterest("user-sender", "interest-123"),
      ).rejects.toThrow(
        /તમને મળેલી સંબંધ વિનંતીઓ જ તમે સ્વીકારી શકો છો|You can only accept connection requests sent directly to you/,
      );

      // Verify update was never called
      expect(prisma.matchInterest.update).not.toHaveBeenCalled();
    });

    it("MUST allow legitimate receiver to accept a pending interest", async () => {
      // Caller is Receiver User (id: "user-receiver") whose profile is "profile-receiver"
      prisma.matrimonialProfile.findUnique.mockResolvedValue({
        id: "profile-receiver",
        userId: "user-receiver",
      });

      prisma.matchInterest.findUnique.mockResolvedValue({
        id: "interest-123",
        senderProfileId: "profile-sender",
        receiverProfileId: "profile-receiver",
        status: "PENDING",
      });

      prisma.matchInterest.update.mockResolvedValue({
        id: "interest-123",
        senderProfileId: "profile-sender",
        receiverProfileId: "profile-receiver",
        status: "ACCEPTED",
      });

      prisma.chatConversation.findUnique.mockResolvedValue(null);
      prisma.chatConversation.create.mockResolvedValue({
        id: "conv-123",
        participant1Id: "profile-receiver",
        participant2Id: "profile-sender",
      });

      const result = await service.acceptInterest("user-receiver", "interest-123");

      expect(prisma.matchInterest.update).toHaveBeenCalledWith({
        where: { id: "interest-123" },
        data: { status: "ACCEPTED" },
      });
      expect(result.status).toBe("ACCEPTED");
    });

    it("MUST reject acceptance if interest is not in PENDING state", async () => {
      prisma.matrimonialProfile.findUnique.mockResolvedValue({
        id: "profile-receiver",
        userId: "user-receiver",
      });

      prisma.matchInterest.findUnique.mockResolvedValue({
        id: "interest-123",
        senderProfileId: "profile-sender",
        receiverProfileId: "profile-receiver",
        status: "ACCEPTED",
      });

      await expect(
        service.acceptInterest("user-receiver", "interest-123"),
      ).rejects.toThrow(BadRequestException);

      await expect(
        service.acceptInterest("user-receiver", "interest-123"),
      ).rejects.toThrow(/Cannot accept interest with status "ACCEPTED"/);
    });

    it("MUST throw NotFoundException if interest record does not exist", async () => {
      prisma.matrimonialProfile.findUnique.mockResolvedValue({
        id: "profile-receiver",
        userId: "user-receiver",
      });

      prisma.matchInterest.findUnique.mockResolvedValue(null);

      await expect(
        service.acceptInterest("user-receiver", "non-existent-id"),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe("declineInterest security boundary", () => {
    it("MUST reject non-recipient attempting to decline an interest", async () => {
      prisma.matrimonialProfile.findUnique.mockResolvedValue({
        id: "profile-sender",
        userId: "user-sender",
      });

      prisma.matchInterest.findUnique.mockResolvedValue({
        id: "interest-123",
        senderProfileId: "profile-sender",
        receiverProfileId: "profile-receiver",
        status: "PENDING",
      });

      await expect(
        service.declineInterest("user-sender", "interest-123"),
      ).rejects.toThrow(BadRequestException);
    });
  });
});
