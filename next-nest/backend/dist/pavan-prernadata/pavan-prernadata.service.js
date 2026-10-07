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
var PavanPrernadataService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.PavanPrernadataService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let PavanPrernadataService = PavanPrernadataService_1 = class PavanPrernadataService {
    constructor(prisma) {
        this.prisma = prisma;
        this.logger = new common_1.Logger(PavanPrernadataService_1.name);
    }
    async findAllAdmin() {
        try {
            return await this.prisma.pavanPrernadata.findMany({
                orderBy: { displayOrder: "asc" },
            });
        }
        catch (e) {
            this.logger.warn("Could not query pavan_prernadata table:", e);
            return [];
        }
    }
    async findAllPublic() {
        try {
            return await this.prisma.pavanPrernadata.findMany({
                where: { isActive: true },
                orderBy: { displayOrder: "asc" },
            });
        }
        catch (e) {
            this.logger.warn("Could not query pavan_prernadata table:", e);
            return [];
        }
    }
    async create(data) {
        return this.prisma.pavanPrernadata.create({
            data,
        });
    }
    async update(id, data) {
        const exists = await this.prisma.pavanPrernadata.findUnique({ where: { id } });
        if (!exists)
            throw new common_1.NotFoundException("Pavan Prernadata not found");
        return this.prisma.pavanPrernadata.update({
            where: { id },
            data,
        });
    }
    async remove(id) {
        return this.prisma.pavanPrernadata.delete({
            where: { id },
        });
    }
};
exports.PavanPrernadataService = PavanPrernadataService;
exports.PavanPrernadataService = PavanPrernadataService = PavanPrernadataService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], PavanPrernadataService);
//# sourceMappingURL=pavan-prernadata.service.js.map