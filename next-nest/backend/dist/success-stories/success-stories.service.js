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
exports.SuccessStoriesService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let SuccessStoriesService = class SuccessStoriesService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async create(createSuccessStoryDto, adminId) {
        const story = await this.prisma.successStory.create({
            data: createSuccessStoryDto,
        });
        await this.prisma.adminAuditLog.create({
            data: {
                adminId,
                action: "CREATE_SUCCESS_STORY",
                entityType: "SuccessStory",
                entityId: story.id,
                newValue: JSON.stringify(story),
            },
        });
        return story;
    }
    async findAllPublic() {
        return this.prisma.successStory.findMany({
            where: {
                isPublished: true,
            },
            orderBy: { createdAt: "desc" },
        });
    }
    async findAllAdmin() {
        return this.prisma.successStory.findMany({
            orderBy: { createdAt: "desc" },
        });
    }
    async findOne(id) {
        const story = await this.prisma.successStory.findUnique({
            where: { id },
        });
        if (!story) {
            throw new common_1.NotFoundException("Success story not found");
        }
        return story;
    }
    async update(id, updateSuccessStoryDto, adminId) {
        const oldStory = await this.findOne(id);
        const updated = await this.prisma.successStory.update({
            where: { id },
            data: updateSuccessStoryDto,
        });
        await this.prisma.adminAuditLog.create({
            data: {
                adminId,
                action: "UPDATE_SUCCESS_STORY",
                entityType: "SuccessStory",
                entityId: id,
                oldValue: JSON.stringify(oldStory),
                newValue: JSON.stringify(updated),
            },
        });
        return updated;
    }
    async remove(id, adminId) {
        const oldStory = await this.findOne(id);
        const deleted = await this.prisma.successStory.delete({
            where: { id },
        });
        await this.prisma.adminAuditLog.create({
            data: {
                adminId,
                action: "DELETE_SUCCESS_STORY",
                entityType: "SuccessStory",
                entityId: id,
                oldValue: JSON.stringify(oldStory),
            },
        });
        return deleted;
    }
};
exports.SuccessStoriesService = SuccessStoriesService;
exports.SuccessStoriesService = SuccessStoriesService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], SuccessStoriesService);
//# sourceMappingURL=success-stories.service.js.map