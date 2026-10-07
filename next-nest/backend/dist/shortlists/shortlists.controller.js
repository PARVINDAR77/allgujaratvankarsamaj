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
exports.ShortlistsController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
const shortlists_service_1 = require("./shortlists.service");
const create_shortlist_dto_1 = require("./dto/create-shortlist.dto");
let ShortlistsController = class ShortlistsController {
    constructor(shortlistsService) {
        this.shortlistsService = shortlistsService;
    }
    async createShortlist(req, dto) {
        return this.shortlistsService.createShortlist(req.user.id, dto);
    }
    async removeShortlist(req, targetProfileId) {
        return this.shortlistsService.removeShortlist(req.user.id, targetProfileId);
    }
    async getShortlistedProfiles(req) {
        return this.shortlistsService.getShortlistedProfiles(req.user.id);
    }
};
exports.ShortlistsController = ShortlistsController;
__decorate([
    (0, common_1.Post)(),
    (0, swagger_1.ApiOperation)({ summary: "Shortlist a profile" }),
    (0, swagger_1.ApiResponse)({ status: 201, description: "Profile shortlisted successfully" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, create_shortlist_dto_1.CreateShortlistDto]),
    __metadata("design:returntype", Promise)
], ShortlistsController.prototype, "createShortlist", null);
__decorate([
    (0, common_1.Delete)(":targetProfileId"),
    (0, swagger_1.ApiOperation)({ summary: "Remove a profile from shortlists" }),
    (0, swagger_1.ApiResponse)({ status: 200, description: "Profile removed from shortlists" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)("targetProfileId")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], ShortlistsController.prototype, "removeShortlist", null);
__decorate([
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({ summary: "Get all shortlisted profiles" }),
    (0, swagger_1.ApiResponse)({ status: 200, description: "List of shortlisted profiles" }),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], ShortlistsController.prototype, "getShortlistedProfiles", null);
exports.ShortlistsController = ShortlistsController = __decorate([
    (0, swagger_1.ApiTags)("Shortlists"),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.Controller)("shortlists"),
    __metadata("design:paramtypes", [shortlists_service_1.ShortlistsService])
], ShortlistsController);
//# sourceMappingURL=shortlists.controller.js.map