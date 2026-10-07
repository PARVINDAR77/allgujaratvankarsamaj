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
exports.ProfilesController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
const public_decorator_1 = require("../auth/decorators/public.decorator");
const create_profile_dto_1 = require("./dto/create-profile.dto");
const update_profile_dto_1 = require("./dto/update-profile.dto");
const profile_query_dto_1 = require("./dto/profile-query.dto");
const search_query_dto_1 = require("./dto/search-query.dto");
const profiles_service_1 = require("./profiles.service");
let ProfilesController = class ProfilesController {
    constructor(profilesService) {
        this.profilesService = profilesService;
    }
    async getProfiles(query) {
        return this.profilesService.getProfiles(query);
    }
    async searchQueryPost(query) {
        return this.profilesService.searchProfiles(query);
    }
    async searchQueryGet(query) {
        return this.profilesService.searchProfiles(query);
    }
    async getFamilyDirectory(search) {
        return this.profilesService.getFamilyDirectory(search);
    }
    getReferenceData() {
        return this.profilesService.getReferenceData();
    }
    async getProfileCompleteness(req) {
        return this.profilesService.getProfileCompletenessByUserId(req.user.id);
    }
    async createProfile(req, dto) {
        return this.profilesService.createProfile(req.user.id, dto);
    }
    async getMyProfile(req) {
        return this.profilesService.getProfileByUserId(req.user.id);
    }
    async updateMyProfile(req, dto) {
        return this.profilesService.updateProfileByUserId(req.user.id, dto);
    }
    async deleteMyProfile(req) {
        return this.profilesService.deleteProfileByUserId(req.user.id);
    }
    async getProfileById(req) {
        return this.profilesService.getProfileById(req.params.id);
    }
};
exports.ProfilesController = ProfilesController;
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({ summary: "List and search matrimonial candidate profiles" }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [profile_query_dto_1.BaseProfileQueryDto]),
    __metadata("design:returntype", Promise)
], ProfilesController.prototype, "getProfiles", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Post)("search-query"),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: "Search candidate profiles with detailed query (POST)" }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [search_query_dto_1.SearchQueryDto]),
    __metadata("design:returntype", Promise)
], ProfilesController.prototype, "searchQueryPost", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)("search-query"),
    (0, swagger_1.ApiOperation)({ summary: "Search candidate profiles with detailed query (GET)" }),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [search_query_dto_1.SearchQueryDto]),
    __metadata("design:returntype", Promise)
], ProfilesController.prototype, "searchQueryGet", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)("family-directory"),
    (0, swagger_1.ApiOperation)({ summary: "Get live family directory aggregated from profiles" }),
    __param(0, (0, common_1.Query)("search")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], ProfilesController.prototype, "getFamilyDirectory", null);
__decorate([
    (0, common_1.Get)("reference-data"),
    (0, swagger_1.ApiOperation)({
        summary: "Get profile static reference options (gender, maritalStatus)",
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: "Static reference data arrays for profile options",
        schema: {
            example: {
                gender: ["MALE", "FEMALE", "OTHER"],
                maritalStatus: ["NEVER_MARRIED", "MARRIED", "DIVORCED", "WIDOWED", "SEPARATED"],
            },
        },
    }),
    (0, swagger_1.ApiResponse)({ status: 401, description: "Unauthorized access" }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], ProfilesController.prototype, "getReferenceData", null);
__decorate([
    (0, common_1.Get)("completeness"),
    (0, swagger_1.ApiOperation)({
        summary: "Get profile completeness calculation for authenticated user",
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: "Profile completion statistics",
        schema: {
            example: {
                completedFields: 10,
                totalFields: 13,
                percentage: 77,
                isComplete: false,
            },
        },
    }),
    (0, swagger_1.ApiResponse)({ status: 401, description: "Unauthorized access" }),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], ProfilesController.prototype, "getProfileCompleteness", null);
__decorate([
    (0, common_1.Post)(),
    (0, swagger_1.ApiOperation)({
        summary: "Create matrimonial profile for authenticated user",
    }),
    (0, swagger_1.ApiResponse)({
        status: 201,
        description: "Profile created successfully",
    }),
    (0, swagger_1.ApiResponse)({ status: 400, description: "Validation failed" }),
    (0, swagger_1.ApiResponse)({ status: 401, description: "Unauthorized access" }),
    (0, swagger_1.ApiResponse)({ status: 409, description: "Profile already exists" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, create_profile_dto_1.CreateProfileDto]),
    __metadata("design:returntype", Promise)
], ProfilesController.prototype, "createProfile", null);
__decorate([
    (0, common_1.Get)("me"),
    (0, swagger_1.ApiOperation)({ summary: "Get matrimonial profile of authenticated user" }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: "Authenticated user matrimonial profile",
    }),
    (0, swagger_1.ApiResponse)({ status: 401, description: "Unauthorized access" }),
    (0, swagger_1.ApiResponse)({ status: 404, description: "Profile not found" }),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], ProfilesController.prototype, "getMyProfile", null);
__decorate([
    (0, common_1.Patch)("me"),
    (0, swagger_1.ApiOperation)({ summary: "Update matrimonial profile of authenticated user" }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: "Profile updated successfully",
    }),
    (0, swagger_1.ApiResponse)({ status: 400, description: "Validation failed" }),
    (0, swagger_1.ApiResponse)({ status: 401, description: "Unauthorized access" }),
    (0, swagger_1.ApiResponse)({ status: 404, description: "Profile not found" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, update_profile_dto_1.UpdateProfileDto]),
    __metadata("design:returntype", Promise)
], ProfilesController.prototype, "updateMyProfile", null);
__decorate([
    (0, common_1.Delete)("me"),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: "Delete matrimonial profile of authenticated user" }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: "Profile deleted successfully",
    }),
    (0, swagger_1.ApiResponse)({ status: 401, description: "Unauthorized access" }),
    (0, swagger_1.ApiResponse)({ status: 404, description: "Profile not found" }),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], ProfilesController.prototype, "deleteMyProfile", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)(":id"),
    (0, swagger_1.ApiOperation)({
        summary: "Get public details of a matrimonial profile by ID",
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: "Profile details",
    }),
    (0, swagger_1.ApiResponse)({ status: 404, description: "Profile not found" }),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], ProfilesController.prototype, "getProfileById", null);
exports.ProfilesController = ProfilesController = __decorate([
    (0, swagger_1.ApiTags)("Matrimonial Profile"),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.Controller)(["profiles", "profile"]),
    __metadata("design:paramtypes", [profiles_service_1.ProfilesService])
], ProfilesController);
//# sourceMappingURL=profiles.controller.js.map