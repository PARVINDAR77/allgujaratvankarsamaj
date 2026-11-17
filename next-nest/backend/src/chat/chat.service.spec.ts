import { Test, TestingModule } from "@nestjs/testing";
import { ForbiddenException, NotFoundException } from "@nestjs/common";
import { ChatService } from "./chat.service";
import { PrismaService } from "../prisma/prisma.service";

describe("ChatService", () => {
  let service: ChatService;
  let prisma: any;

  const mockMyProfile = {
    id: "profile-1",
    userId: "user-1",
    firstName: "Test",
    lastName: "User",
  };

  const mockOtherProfile = {
    id: "profile-2",
    userId: "user-2",
    firstName: "Other",
    lastName: "User",
  };

  const mockConversation = {
    id: "conv-1",
    participant1Id: "profile-1",
    participant2Id: "profile-2",
    lastMessage: "Hello",
    lastMessageAt: new Date(),
    updatedAt: new Date(),
    createdAt: new Date(),
  };

  beforeEach(async () => {
    prisma = {
      matrimonialProfile: {
        findUnique: jest.fn().mockImplementation(({ where }) => {
          if (where.userId === "user-1") return Promise.resolve(mockMyProfile);
          if (where.id === "profile-2") return Promise.resolve(mockOtherProfile);
          return Promise.resolve(null);
        }),
      },
      chatConversation: {
        findUnique: jest.fn().mockResolvedValue(mockConversation),
        delete: jest.fn().mockResolvedValue(mockConversation),
        update: jest.fn().mockResolvedValue(mockConversation),
      },
      chatMessage: {
        deleteMany: jest.fn().mockResolvedValue({ count: 2 }),
        delete: jest.fn().mockResolvedValue({ id: "msg-1" }),
        findUnique: jest.fn().mockResolvedValue({
          id: "msg-1",
          conversationId: "conv-1",
          senderId: "profile-1",
          receiverId: "profile-2",
          content: "Hello",
          conversation: mockConversation,
        }),
        findFirst: jest.fn().mockResolvedValue(null),
      },
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ChatService,
        {
          provide: PrismaService,
          useValue: prisma,
        },
      ],
    }).compile();

    service = module.get<ChatService>(ChatService);
  });

  describe("deleteConversation", () => {
    it("should successfully delete a conversation and its messages when user is participant", async () => {
      const result = await service.deleteConversation("user-1", "conv-1");
      expect(result.success).toBe(true);
      expect(prisma.chatMessage.deleteMany).toHaveBeenCalledWith({
        where: { conversationId: "conv-1" },
      });
      expect(prisma.chatConversation.delete).toHaveBeenCalledWith({
        where: { id: "conv-1" },
      });
    });

    it("should throw ForbiddenException if user is not a participant", async () => {
      prisma.chatConversation.findUnique.mockResolvedValueOnce({
        id: "conv-1",
        participant1Id: "profile-x",
        participant2Id: "profile-y",
      });

      await expect(service.deleteConversation("user-1", "conv-1")).rejects.toThrow(
        ForbiddenException,
      );
    });

    it("should throw NotFoundException if conversation does not exist", async () => {
      prisma.chatConversation.findUnique.mockResolvedValueOnce(null);

      await expect(service.deleteConversation("user-1", "non-existent")).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe("clearMessages", () => {
    it("should clear all messages and reset conversation lastMessage", async () => {
      const result = await service.clearMessages("user-1", "conv-1");
      expect(result.success).toBe(true);
      expect(prisma.chatMessage.deleteMany).toHaveBeenCalledWith({
        where: { conversationId: "conv-1" },
      });
      expect(prisma.chatConversation.update).toHaveBeenCalledWith({
        where: { id: "conv-1" },
        data: {
          lastMessage: null,
          lastMessageAt: null,
        },
      });
    });
  });

  describe("deleteMessage", () => {
    it("should delete a message and update lastMessage on conversation", async () => {
      const result = await service.deleteMessage("user-1", "msg-1");
      expect(result.success).toBe(true);
      expect(prisma.chatMessage.delete).toHaveBeenCalledWith({
        where: { id: "msg-1" },
      });
      expect(prisma.chatConversation.update).toHaveBeenCalled();
    });

    it("should throw ForbiddenException if user is neither sender nor participant", async () => {
      prisma.chatMessage.findUnique.mockResolvedValueOnce({
        id: "msg-1",
        conversationId: "conv-1",
        senderId: "stranger",
        receiverId: "other",
        conversation: {
          participant1Id: "stranger",
          participant2Id: "other",
        },
      });

      await expect(service.deleteMessage("user-1", "msg-1")).rejects.toThrow(
        ForbiddenException,
      );
    });
  });
});
