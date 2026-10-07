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
var NotificationsService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.NotificationsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let NotificationsService = NotificationsService_1 = class NotificationsService {
    constructor(prisma) {
        this.prisma = prisma;
        this.logger = new common_1.Logger(NotificationsService_1.name);
    }
    async findAllPublic() {
        try {
            return await this.prisma.systemNotification.findMany({
                orderBy: { createdAt: "desc" },
                take: 50,
            });
        }
        catch (err) {
            this.logger.warn("Could not query system_notifications:", err?.message);
            return [];
        }
    }
    async findAllAdmin() {
        try {
            return await this.prisma.systemNotification.findMany({
                orderBy: { createdAt: "desc" },
            });
        }
        catch (err) {
            this.logger.warn("Could not query system_notifications:", err?.message);
            return [];
        }
    }
    async create(dto) {
        return this.prisma.systemNotification.create({
            data: {
                title: dto.title,
                message: dto.message,
                target: dto.target || "ALL",
                route: dto.route || null,
            },
        });
    }
    async remove(id) {
        const exists = await this.prisma.systemNotification.findUnique({
            where: { id },
        });
        if (!exists) {
            throw new common_1.NotFoundException("Notification not found");
        }
        return this.prisma.systemNotification.delete({
            where: { id },
        });
    }
};
exports.NotificationsService = NotificationsService;
exports.NotificationsService = NotificationsService = NotificationsService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], NotificationsService);
//# sourceMappingURL=notifications.service.js.map