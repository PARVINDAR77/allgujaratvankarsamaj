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
            throw new common_1.BadRequestException("You must create a profile before sending interests");
        }
        return profile.id;
    }
    async sendInterest(userId, dto) {
        const senderProfileId = await this.getProfileIdForUser(userId);
        if (senderProfileId === dto.targetProfileId) {
            throw new common_1.BadRequestException("You cannot send an interest to yourself");
        }
        const existingInterest = await this.prisma.matchInterest.findFirst({
            where: {
                senderProfileId,
                receiverProfileId: dto.targetProfileId,
            },
        });
        if (existingInterest) {
            throw new common_1.BadRequestException("Interest already sent");
        }
        return this.prisma.matchInterest.create({
            data: {
                senderProfileId,
                receiverProfileId: dto.targetProfileId,
            },
        });
    }
    async acceptInterest(userId, interestId) {
        const receiverProfileId = await this.getProfileIdForUser(userId);
        const interest = await this.prisma.matchInterest.findUnique({
            where: { id: interestId },
        });
        if (!interest) {
            throw new common_1.NotFoundException("Interest not found");
        }
        if (interest.receiverProfileId !== receiverProfileId) {
            throw new common_1.BadRequestException("You can only accept interests sent to you");
        }
        return this.prisma.matchInterest.update({
            where: { id: interestId },
            data: { status: "ACCEPTED" },
        });
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
        const senderProfileId = await this.getProfileIdForUser(userId);
        return this.prisma.matchInterest.findMany({
            where: { senderProfileId },
        });
    }
    async getReceivedInterests(userId) {
        const receiverProfileId = await this.getProfileIdForUser(userId);
        return this.prisma.matchInterest.findMany({
            where: { receiverProfileId },
        });
    }
};
exports.InterestsService = InterestsService;
exports.InterestsService = InterestsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], InterestsService);
//# sourceMappingURL=interests.service.js.map