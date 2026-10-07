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
exports.AdvertisementsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let AdvertisementsService = class AdvertisementsService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async create(createAdvertisementDto, adminId) {
        const ad = await this.prisma.advertisement.create({
            data: {
                ...createAdvertisementDto,
                createdBy: adminId,
            },
        });
        await this.prisma.adminAuditLog.create({
            data: {
                adminId,
                action: "CREATE_AD",
                entityType: "Advertisement",
                entityId: ad.id,
                newValue: JSON.stringify(ad),
            },
        });
        return ad;
    }
    async findAllPublic() {
        const now = new Date();
        return this.prisma.advertisement.findMany({
            where: {
                isActive: true,
                OR: [{ startAt: null }, { startAt: { lte: now } }],
                AND: [
                    {
                        OR: [{ endAt: null }, { endAt: { gte: now } }],
                    },
                ],
            },
            orderBy: { sortOrder: "asc" },
        });
    }
    async findAllAdmin() {
        return this.prisma.advertisement.findMany({
            orderBy: { createdAt: "desc" },
        });
    }
    async findOne(id) {
        const ad = await this.prisma.advertisement.findUnique({
            where: { id },
        });
        if (!ad) {
            throw new common_1.NotFoundException("Advertisement not found");
        }
        return ad;
    }
    async update(id, updateAdvertisementDto, adminId) {
        const oldAd = await this.findOne(id);
        const updated = await this.prisma.advertisement.update({
            where: { id },
            data: updateAdvertisementDto,
        });
        await this.prisma.adminAuditLog.create({
            data: {
                adminId,
                action: "UPDATE_AD",
                entityType: "Advertisement",
                entityId: id,
                oldValue: JSON.stringify(oldAd),
                newValue: JSON.stringify(updated),
            },
        });
        return updated;
    }
    async remove(id, adminId) {
        const oldAd = await this.findOne(id);
        const deleted = await this.prisma.advertisement.delete({
            where: { id },
        });
        await this.prisma.adminAuditLog.create({
            data: {
                adminId,
                action: "DELETE_AD",
                entityType: "Advertisement",
                entityId: id,
                oldValue: JSON.stringify(oldAd),
            },
        });
        return deleted;
    }
};
exports.AdvertisementsService = AdvertisementsService;
exports.AdvertisementsService = AdvertisementsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], AdvertisementsService);
//# sourceMappingURL=advertisements.service.js.map