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
exports.ShortlistsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let ShortlistsService = class ShortlistsService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async createShortlist(userId, dto) {
        const existing = await this.prisma.shortlist.findUnique({
            where: {
                userId_targetProfileId: {
                    userId,
                    targetProfileId: dto.targetProfileId,
                },
            },
        });
        if (existing) {
            throw new common_1.BadRequestException("Profile is already shortlisted");
        }
        return this.prisma.shortlist.create({
            data: {
                userId,
                targetProfileId: dto.targetProfileId,
            },
        });
    }
    async removeShortlist(userId, targetProfileId) {
        try {
            return await this.prisma.shortlist.delete({
                where: {
                    userId_targetProfileId: {
                        userId,
                        targetProfileId,
                    },
                },
            });
        }
        catch (e) {
            throw new common_1.NotFoundException("Shortlist entry not found");
        }
    }
    async getShortlistedProfiles(userId) {
        return this.prisma.shortlist.findMany({
            where: { userId },
        });
    }
};
exports.ShortlistsService = ShortlistsService;
exports.ShortlistsService = ShortlistsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], ShortlistsService);
//# sourceMappingURL=shortlists.service.js.map