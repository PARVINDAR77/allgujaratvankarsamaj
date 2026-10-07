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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.SuccessStoriesController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const success_stories_service_1 = require("./success-stories.service");
const create_success_story_dto_1 = require("./dto/create-success-story.dto");
const update_success_story_dto_1 = require("./dto/update-success-story.dto");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
const capabilities_guard_1 = require("../auth/guards/capabilities.guard");
const capabilities_decorator_1 = require("../auth/decorators/capabilities.decorator");
const capabilities_1 = require("../auth/constants/capabilities");
const public_decorator_1 = require("../auth/decorators/public.decorator");
let SuccessStoriesController = class SuccessStoriesController {
    constructor(successStoriesService) {
        this.successStoriesService = successStoriesService;
    }
    async findAllPublic() {
        return this.successStoriesService.findAllPublic();
    }
    async findAllAdmin() {
        return this.successStoriesService.findAllAdmin();
    }
    async findOne(id) {
        return this.successStoriesService.findOne(id);
    }
    async create(req, createSuccessStoryDto) {
        return this.successStoriesService.create(createSuccessStoryDto, req.user.id);
    }
    async update(req, id, updateSuccessStoryDto) {
        return this.successStoriesService.update(id, updateSuccessStoryDto, req.user.id);
    }
    async remove(req, id) {
        return this.successStoriesService.remove(id, req.user.id);
    }
};
exports.SuccessStoriesController = SuccessStoriesController;
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)("success-stories"),
    (0, swagger_1.ApiOperation)({ summary: "Get all published success stories for public app" }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], SuccessStoriesController.prototype, "findAllPublic", null);
__decorate([
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, capabilities_guard_1.CapabilitiesGuard),
    (0, capabilities_decorator_1.Capabilities)(capabilities_1.Capability.SUCCESS_STORIES_MANAGE),
    (0, common_1.Get)("admin/success-stories"),
    (0, swagger_1.ApiOperation)({ summary: "Get all success stories (Admin)" }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], SuccessStoriesController.prototype, "findAllAdmin", null);
__decorate([
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, capabilities_guard_1.CapabilitiesGuard),
    (0, capabilities_decorator_1.Capabilities)(capabilities_1.Capability.SUCCESS_STORIES_MANAGE),
    (0, common_1.Get)("admin/success-stories/:id"),
    (0, swagger_1.ApiOperation)({ summary: "Get a specific success story by ID (Admin)" }),
    __param(0, (0, common_1.Param)("id")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], SuccessStoriesController.prototype, "findOne", null);
__decorate([
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, capabilities_guard_1.CapabilitiesGuard),
    (0, capabilities_decorator_1.Capabilities)(capabilities_1.Capability.SUCCESS_STORIES_MANAGE),
    (0, common_1.Post)("admin/success-stories"),
    (0, swagger_1.ApiOperation)({ summary: "Create a new success story (Admin)" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, create_success_story_dto_1.CreateSuccessStoryDto]),
    __metadata("design:returntype", Promise)
], SuccessStoriesController.prototype, "create", null);
__decorate([
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, capabilities_guard_1.CapabilitiesGuard),
    (0, capabilities_decorator_1.Capabilities)(capabilities_1.Capability.SUCCESS_STORIES_MANAGE),
    (0, common_1.Patch)("admin/success-stories/:id"),
    (0, swagger_1.ApiOperation)({ summary: "Update a success story (Admin)" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)("id")),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, update_success_story_dto_1.UpdateSuccessStoryDto]),
    __metadata("design:returntype", Promise)
], SuccessStoriesController.prototype, "update", null);
__decorate([
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, capabilities_guard_1.CapabilitiesGuard),
    (0, capabilities_decorator_1.Capabilities)(capabilities_1.Capability.SUCCESS_STORIES_MANAGE),
    (0, common_1.Delete)("admin/success-stories/:id"),
    (0, swagger_1.ApiOperation)({ summary: "Delete a success story (Admin)" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)("id")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], SuccessStoriesController.prototype, "remove", null);
exports.SuccessStoriesController = SuccessStoriesController = __decorate([
    (0, swagger_1.ApiTags)("Success Stories"),
    (0, common_1.Controller)(),
    __metadata("design:paramtypes", [success_stories_service_1.SuccessStoriesService])
], SuccessStoriesController);
//# sourceMappingURL=success-stories.controller.js.map