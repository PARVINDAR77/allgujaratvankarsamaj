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
Object.defineProperty(exports, "__esModule", { value: true });
exports.InterestsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let InterestsService = class InterestsService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async getProfileIdForUser(userId) {
        const profile = await this.prisma.matrimonialProfile.findUnique({
            where: { userId },
        });
        if (!profile) {
            throw new common_1.BadRequestException("You must create a profile before sending connection requests");
        }
        return profile.id;
    }
    async getInterestStatus(userId, targetProfileId) {
        const myProfile = await this.prisma.matrimonialProfile.findUnique({
            where: { userId },
        });
        if (!myProfile) {
            return { status: "NONE" };
        }
        const myProfileId = myProfile.id;
        if (myProfileId === targetProfileId) {
            return { status: "SELF" };
        }
        const sent = await this.prisma.matchInterest.findFirst({
            where: {
                senderProfileId: myProfileId,
                receiverProfileId: targetProfileId,
            },
        });
        const received = await this.prisma.matchInterest.findFirst({
            where: {
                senderProfileId: targetProfileId,
                receiverProfileId: myProfileId,
            },
        });
        if (sent?.status === "ACCEPTED" || received?.status === "ACCEPTED") {
            const p1 = myProfileId < targetProfileId ? myProfileId : targetProfileId;
            const p2 = myProfileId < targetProfileId ? targetProfileId : myProfileId;
            const conversation = await this.prisma.chatConversation.findUnique({
                where: { participant1Id_participant2Id: { participant1Id: p1, participant2Id: p2 } },
            });
            return {
                status: "ACCEPTED",
                interestId: sent?.id || received?.id,
                conversationId: conversation?.id,
            };
        }
        if (sent) {
            return {
                status: sent.status === "PENDING" ? "PENDING_SENT" : sent.status,
                interestId: sent.id,
            };
        }
        if (received) {
            return {
                status: received.status === "PENDING" ? "PENDING_RECEIVED" : received.status,
                interestId: received.id,
            };
        }
        return { status: "NONE" };
    }
    async sendInterest(userId, dto) {
        const senderProfile = await this.prisma.matrimonialProfile.findUnique({
            where: { userId },
        });
        if (!senderProfile) {
            throw new common_1.BadRequestException("You must create a profile before sending connection requests");
        }
        const senderProfileId = senderProfile.id;
        if (senderProfileId === dto.targetProfileId) {
            throw new common_1.BadRequestException("You cannot send a connection request to yourself");
        }
        const existingInterest = await this.prisma.matchInterest.findFirst({
            where: {
                OR: [
                    { senderProfileId, receiverProfileId: dto.targetProfileId },
                    { senderProfileId: dto.targetProfileId, receiverProfileId: senderProfileId },
                ],
            },
        });
        if (existingInterest) {
            if (existingInterest.status === "ACCEPTED") {
                return { message: "Already connected", status: "ACCEPTED", interest: existingInterest };
            }
            if (existingInterest.senderProfileId === senderProfileId) {
                return { message: "Request already sent", status: "PENDING_SENT", interest: existingInterest };
            }
            else {
                return this.acceptInterest(userId, existingInterest.id);
            }
        }
        const created = await this.prisma.matchInterest.create({
            data: {
                senderProfileId,
                receiverProfileId: dto.targetProfileId,
                status: "PENDING",
            },
        });
        try {
            const receiverProfile = await this.prisma.matrimonialProfile.findUnique({
                where: { id: dto.targetProfileId },
            });
            if (receiverProfile?.userId) {
                const senderName = `${senderProfile.firstName} ${senderProfile.lastName}`.trim();
                await this.prisma.userNotification.create({
                    data: {
                        userId: receiverProfile.userId,
                        title: "નવી કનેક્શન વિનંતી (New Connection Request)",
                        message: `${senderName} એ તમને કનેક્શન વિનંતી મોકલી છે. પ્રોફાઇલ જુઓ અને સ્વીકારો.`,
                        type: "CONNECTION_REQUEST",
                        metadata: JSON.stringify({
                            senderProfileId,
                            senderName,
                            interestId: created.id,
                        }),
                    },
                });
            }
        }
        catch (_) { }
        return { message: "Connection request sent successfully", status: "PENDING_SENT", interest: created };
    }
    async acceptInterest(userId, interestId) {
        const receiverProfile = await this.prisma.matrimonialProfile.findUnique({
            where: { userId },
        });
        if (!receiverProfile) {
            throw new common_1.BadRequestException("Profile not found");
        }
        const receiverProfileId = receiverProfile.id;
        const interest = await this.prisma.matchInterest.findUnique({
            where: { id: interestId },
        });
        if (!interest) {
            throw new common_1.NotFoundException("Interest not found");
        }
        if (interest.receiverProfileId !== receiverProfileId &&
            interest.senderProfileId !== receiverProfileId) {
            throw new common_1.BadRequestException("You can only accept connection requests involving your profile");
        }
        const updated = await this.prisma.matchInterest.update({
            where: { id: interestId },
            data: { status: "ACCEPTED" },
        });
        const p1 = interest.senderProfileId < interest.receiverProfileId ? interest.senderProfileId : interest.receiverProfileId;
        const p2 = interest.senderProfileId < interest.receiverProfileId ? interest.receiverProfileId : interest.senderProfileId;
        let conversation = await this.prisma.chatConversation.findUnique({
            where: {
                participant1Id_participant2Id: {
                    participant1Id: p1,
                    participant2Id: p2,
                },
            },
        });
        if (!conversation) {
            conversation = await this.prisma.chatConversation.create({
                data: {
                    participant1Id: p1,
                    participant2Id: p2,
                },
            });
        }
        try {
            const otherProfileId = interest.senderProfileId === receiverProfileId
                ? interest.receiverProfileId
                : interest.senderProfileId;
            const otherProfile = await this.prisma.matrimonialProfile.findUnique({
                where: { id: otherProfileId },
            });
            if (otherProfile?.userId) {
                const myName = `${receiverProfile.firstName} ${receiverProfile.lastName}`.trim();
                await this.prisma.userNotification.create({
                    data: {
                        userId: otherProfile.userId,
                        title: "વિનંતી સ્વીકારાઈ! (Connection Accepted)",
                        message: `${myName} એ તમારી કનેક્શન વિનંતી સ્વીકારી લીધી છે! હવે તમે એકબીજા સાથે ચેટ કરી શકો છો.`,
                        type: "REQUEST_ACCEPTED",
                        metadata: JSON.stringify({
                            partnerProfileId: receiverProfileId,
                            partnerName: myName,
                            conversationId: conversation.id,
                        }),
                    },
                });
            }
        }
        catch (_) { }
        return {
            message: "Connection request accepted successfully",
            status: "ACCEPTED",
            interest: updated,
            conversationId: conversation.id,
        };
    }
    async declineInterest(userId, interestId) {
        const receiverProfileId = await this.getProfileIdForUser(userId);
        const interest = await this.prisma.matchInterest.findUnique({
            where: { id: interestId },
        });
        if (!interest) {
            throw new common_1.NotFoundException("Interest not found");
        }
        if (interest.receiverProfileId !== receiverProfileId) {
            throw new common_1.BadRequestException("You can only decline interests sent to you");
        }
        return this.prisma.matchInterest.update({
            where: { id: interestId },
            data: { status: "DECLINED" },
        });
    }
    async getSentInterests(userId) {
        const myProfile = await this.prisma.matrimonialProfile.findUnique({ where: { userId } });
        if (!myProfile)
            return [];
        const interests = await this.prisma.matchInterest.findMany({
            where: { senderProfileId: myProfile.id },
            orderBy: { createdAt: "desc" },
        });
        const receiverIds = interests.map((i) => i.receiverProfileId);
        const profiles = await this.prisma.matrimonialProfile.findMany({
            where: { id: { in: receiverIds } },
        });
        const profileMap = new Map(profiles.map((p) => [p.id, p]));
        return interests.map((i) => ({
            ...i,
            receiverProfile: profileMap.get(i.receiverProfileId) || null,
        }));
    }
    async getReceivedInterests(userId) {
        const myProfile = await this.prisma.matrimonialProfile.findUnique({ where: { userId } });
        if (!myProfile)
            return [];
        const interests = await this.prisma.matchInterest.findMany({
            where: { receiverProfileId: myProfile.id },
            orderBy: { createdAt: "desc" },
        });
        const senderIds = interests.map((i) => i.senderProfileId);
        const profiles = await this.prisma.matrimonialProfile.findMany({
            where: { id: { in: senderIds } },
        });
        const profileMap = new Map(profiles.map((p) => [p.id, p]));
        return interests.map((i) => ({
            ...i,
            senderProfile: profileMap.get(i.senderProfileId) || null,
        }));
    }
    async getMutualInterests(userId) {
        const myProfile = await this.prisma.matrimonialProfile.findUnique({ where: { userId } });
        if (!myProfile)
            return [];
        const interests = await this.prisma.matchInterest.findMany({
            where: {
                status: "ACCEPTED",
                OR: [
                    { senderProfileId: myProfile.id },
                    { receiverProfileId: myProfile.id },
                ],
            },
            orderBy: { createdAt: "desc" },
        });
        const otherProfileIds = interests.map((i) => i.senderProfileId === myProfile.id ? i.receiverProfileId : i.senderProfileId);
        const profiles = await this.prisma.matrimonialProfile.findMany({
            where: { id: { in: otherProfileIds } },
        });
        const profileMap = new Map(profiles.map((p) => [p.id, p]));
        const conversations = await this.prisma.chatConversation.findMany({
            where: {
                OR: [
                    { participant1Id: userId },
                    { participant2Id: userId },
                ],
            },
        });
        return interests.map((i) => {
            const otherProfileId = i.senderProfileId === myProfile.id ? i.receiverProfileId : i.senderProfileId;
            const otherProfile = profileMap.get(otherProfileId) || null;
            const matchedConv = conversations.find((c) => otherProfile &&
                (c.participant1Id === otherProfile.userId || c.participant2Id === otherProfile.userId));
            return {
                ...i,
                otherProfile,
                conversationId: matchedConv?.id || null,
            };
        });
    }
};
exports.InterestsService = InterestsService;
exports.InterestsService = InterestsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], InterestsService);
//# sourceMappingURL=interests.service.js.map