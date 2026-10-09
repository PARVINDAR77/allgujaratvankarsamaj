"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var ChatService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.ChatService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let ChatService = ChatService_1 = class ChatService {
    constructor(prisma) {
        this.prisma = prisma;
        this.logger = new common_1.Logger(ChatService_1.name);
    }
    async getMyProfile(userId) {
        const profile = await this.prisma.matrimonialProfile.findUnique({
            where: { userId },
        });
        if (!profile) {
            throw new common_1.BadRequestException("You must have an active candidate profile to use chat");
        }
        return profile;
    }
    async getUserConversations(userId) {
        const myProfile = await this.getMyProfile(userId);
        const myProfileId = myProfile.id;
        const conversations = await this.prisma.chatConversation.findMany({
            where: {
                OR: [
                    { participant1Id: myProfileId },
                    { participant2Id: myProfileId },
                ],
            },
            orderBy: { updatedAt: "desc" },
        });
        const results = await Promise.all(conversations.map(async (conv) => {
            const partnerProfileId = conv.participant1Id === myProfileId
                ? conv.participant2Id
                : conv.participant1Id;
            const partnerProfile = await this.prisma.matrimonialProfile.findUnique({
                where: { id: partnerProfileId },
                select: {
                    id: true,
                    firstName: true,
                    lastName: true,
                    photoUrl: true,
                    photos: true,
                    gender: true,
                    city: true,
                    district: { select: { name: true, gujaratiName: true } },
                    state: true,
                    occupation: true,
                    designation: true,
                },
            });
            const unreadCount = await this.prisma.chatMessage.count({
                where: {
                    conversationId: conv.id,
                    receiverId: myProfileId,
                    isRead: false,
                },
            });
            return {
                id: conv.id,
                partnerProfileId,
                partnerProfile,
                lastMessage: conv.lastMessage,
                lastMessageAt: conv.lastMessageAt || conv.updatedAt,
                unreadCount,
                createdAt: conv.createdAt,
            };
        }));
        return results;
    }
    async getConversationMessages(userId, conversationId) {
        const myProfile = await this.getMyProfile(userId);
        const myProfileId = myProfile.id;
        const conv = await this.prisma.chatConversation.findUnique({
            where: { id: conversationId },
        });
        if (!conv) {
            throw new common_1.NotFoundException("Conversation not found");
        }
        if (conv.participant1Id !== myProfileId &&
            conv.participant2Id !== myProfileId) {
            throw new common_1.ForbiddenException("You do not have access to this conversation");
        }
        await this.prisma.chatMessage.updateMany({
            where: {
                conversationId,
                receiverId: myProfileId,
                isRead: false,
            },
            data: { isRead: true },
        });
        const messages = await this.prisma.chatMessage.findMany({
            where: { conversationId },
            orderBy: { createdAt: "asc" },
            take: 200,
        });
        const partnerProfileId = conv.participant1Id === myProfileId
            ? conv.participant2Id
            : conv.participant1Id;
        const partnerProfile = await this.prisma.matrimonialProfile.findUnique({
            where: { id: partnerProfileId },
            select: {
                id: true,
                firstName: true,
                lastName: true,
                photoUrl: true,
                gender: true,
                city: true,
                district: { select: { name: true, gujaratiName: true } },
                designation: true,
                occupation: true,
            },
        });
        return {
            conversationId: conv.id,
            myProfileId,
            partnerProfile,
            messages,
        };
    }
    async getOrCreateConversationWithPartner(userId, partnerProfileId) {
        const myProfile = await this.getMyProfile(userId);
        const myProfileId = myProfile.id;
        if (myProfileId === partnerProfileId) {
            throw new common_1.BadRequestException("You cannot start a chat with yourself");
        }
        const connection = await this.prisma.matchInterest.findFirst({
            where: {
                OR: [
                    { senderProfileId: myProfileId, receiverProfileId: partnerProfileId },
                    { senderProfileId: partnerProfileId, receiverProfileId: myProfileId },
                ],
                status: "ACCEPTED",
            },
        });
        if (!connection) {
            throw new common_1.ForbiddenException("You can only chat after a connection request is accepted");
        }
        const p1 = myProfileId < partnerProfileId ? myProfileId : partnerProfileId;
        const p2 = myProfileId < partnerProfileId ? partnerProfileId : myProfileId;
        let conv = await this.prisma.chatConversation.findUnique({
            where: {
                participant1Id_participant2Id: {
                    participant1Id: p1,
                    participant2Id: p2,
                },
            },
        });
        if (!conv) {
            conv = await this.prisma.chatConversation.create({
                data: {
                    participant1Id: p1,
                    participant2Id: p2,
                },
            });
        }
        return this.getConversationMessages(userId, conv.id);
    }
    async sendMessage(userId, dto) {
        const myProfile = await this.getMyProfile(userId);
        const myProfileId = myProfile.id;
        let conversationId = dto.conversationId;
        let targetReceiverId = dto.receiverProfileId;
        if (conversationId) {
            const conv = await this.prisma.chatConversation.findUnique({
                where: { id: conversationId },
            });
            if (!conv) {
                throw new common_1.NotFoundException("Conversation not found");
            }
            if (conv.participant1Id !== myProfileId && conv.participant2Id !== myProfileId) {
                throw new common_1.ForbiddenException("Not authorized in this conversation");
            }
            targetReceiverId =
                conv.participant1Id === myProfileId
                    ? conv.participant2Id
                    : conv.participant1Id;
        }
        else if (targetReceiverId) {
            const p1 = myProfileId < targetReceiverId ? myProfileId : targetReceiverId;
            const p2 = myProfileId < targetReceiverId ? targetReceiverId : myProfileId;
            let conv = await this.prisma.chatConversation.findUnique({
                where: {
                    participant1Id_participant2Id: {
                        participant1Id: p1,
                        participant2Id: p2,
                    },
                },
            });
            if (!conv) {
                const connection = await this.prisma.matchInterest.findFirst({
                    where: {
                        OR: [
                            { senderProfileId: myProfileId, receiverProfileId: targetReceiverId },
                            { senderProfileId: targetReceiverId, receiverProfileId: myProfileId },
                        ],
                        status: "ACCEPTED",
                    },
                });
                if (!connection) {
                    throw new common_1.ForbiddenException("You can only chat after connection request is accepted");
                }
                conv = await this.prisma.chatConversation.create({
                    data: {
                        participant1Id: p1,
                        participant2Id: p2,
                    },
                });
            }
            conversationId = conv.id;
        }
        else {
            throw new common_1.BadRequestException("Either conversationId or receiverProfileId must be provided");
        }
        const message = await this.prisma.chatMessage.create({
            data: {
                conversationId,
                senderId: myProfileId,
                receiverId: targetReceiverId,
                content: dto.content.trim(),
            },
        });
        await this.prisma.chatConversation.update({
            where: { id: conversationId },
            data: {
                lastMessage: dto.content.trim(),
                lastMessageAt: new Date(),
            },
        });
        try {
            const receiverProfile = await this.prisma.matrimonialProfile.findUnique({
                where: { id: targetReceiverId },
            });
            if (receiverProfile?.userId) {
                const senderName = `${myProfile.firstName} ${myProfile.lastName}`.trim();
                await this.prisma.userNotification.create({
                    data: {
                        userId: receiverProfile.userId,
                        title: `💬 નવો સંદેશો: ${senderName}`,
                        message: dto.content.length > 50
                            ? `${dto.content.substring(0, 47)}...`
                            : dto.content,
                        type: "NEW_MESSAGE",
                        metadata: JSON.stringify({
                            conversationId,
                            senderProfileId: myProfileId,
                            senderName,
                        }),
                    },
                });
            }
        }
        catch (_) { }
        return message;
    }
    async markAsRead(userId, conversationId) {
        const myProfile = await this.getMyProfile(userId);
        return this.prisma.chatMessage.updateMany({
            where: {
                conversationId,
                receiverId: myProfile.id,
                isRead: false,
            },
            data: { isRead: true },
        });
    }
};
exports.ChatService = ChatService;
exports.ChatService = ChatService = ChatService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], ChatService);
//# sourceMappingURL=chat.service.js.map