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
exports.AdminUsersController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
const permissions_guard_1 = require("../auth/guards/permissions.guard");
const permissions_decorator_1 = require("../auth/decorators/permissions.decorator");
const permissions_1 = require("../auth/constants/permissions");
const users_service_1 = require("./users.service");
const client_1 = require("@prisma/client");
let AdminUsersController = class AdminUsersController {
    constructor(usersService) {
        this.usersService = usersService;
    }
    async getUsersAdmin() {
        return this.usersService.getAllUsersForAdmin();
    }
    async updateUserStatusAdmin(req, id, status) {
        const ipAddress = req.ip || req.connection?.remoteAddress || null;
        return this.usersService.updateUserStatusAdmin(id, req.user.id, status, ipAddress);
    }
    async updateUserRoleAdmin(req, id, role) {
        if (req.user.role !== client_1.Role.SUPER_ADMIN) {
            throw new common_1.ForbiddenException("Only SUPER_ADMIN can change roles");
        }
        const ipAddress = req.ip || req.connection?.remoteAddress || null;
        return this.usersService.updateUserRoleAdmin(id, req.user.id, role, ipAddress);
    }
    async getProfilesAdmin() {
        return this.usersService.getAllProfilesForAdmin();
    }
    async updateProfileStatusAdmin(req, id, status) {
        const ipAddress = req.ip || req.connection?.remoteAddress || null;
        return this.usersService.updateProfileStatusAdmin(id, req.user.id, status, ipAddress);
    }
    async toggleProfileFeaturedAdmin(req, id, isFeatured) {
        const ipAddress = req.ip || req.connection?.remoteAddress || null;
        return this.usersService.toggleProfileFeaturedAdmin(id, req.user.id, isFeatured, ipAddress);
    }
};
exports.AdminUsersController = AdminUsersController;
__decorate([
    (0, permissions_decorator_1.Permissions)(permissions_1.Permission.MEMBERS_READ),
    (0, common_1.Get)("users"),
    (0, swagger_1.ApiOperation)({ summary: "Get list of all registered users (Admin)" }),
    (0, swagger_1.ApiResponse)({ status: 200, description: "List of users" }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], AdminUsersController.prototype, "getUsersAdmin", null);
__decorate([
    (0, permissions_decorator_1.Permissions)(permissions_1.Permission.MEMBERS_UPDATE),
    (0, common_1.Patch)("users/:id/status"),
    (0, swagger_1.ApiOperation)({ summary: "Update a user status (Admin)" }),
    (0, swagger_1.ApiResponse)({ status: 200, description: "User status updated" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)("id")),
    __param(2, (0, common_1.Body)("status")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, String]),
    __metadata("design:returntype", Promise)
], AdminUsersController.prototype, "updateUserStatusAdmin", null);
__decorate([
    (0, permissions_decorator_1.Permissions)(permissions_1.Permission.MEMBERS_UPDATE),
    (0, common_1.Patch)("users/:id/role"),
    (0, swagger_1.ApiOperation)({ summary: "Update a user role (Admin)" }),
    (0, swagger_1.ApiResponse)({ status: 200, description: "User role updated" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)("id")),
    __param(2, (0, common_1.Body)("role")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, String]),
    __metadata("design:returntype", Promise)
], AdminUsersController.prototype, "updateUserRoleAdmin", null);
__decorate([
    (0, permissions_decorator_1.Permissions)(permissions_1.Permission.MEMBERS_READ),
    (0, common_1.Get)("profiles"),
    (0, swagger_1.ApiOperation)({ summary: "Get list of all matrimonial profiles (Admin)" }),
    (0, swagger_1.ApiResponse)({ status: 200, description: "List of profiles" }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], AdminUsersController.prototype, "getProfilesAdmin", null);
__decorate([
    (0, permissions_decorator_1.Permissions)(permissions_1.Permission.MEMBERS_UPDATE),
    (0, common_1.Patch)("profiles/:id/status"),
    (0, swagger_1.ApiOperation)({ summary: "Update profile status (Admin)" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)("id")),
    __param(2, (0, common_1.Body)("status")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, String]),
    __metadata("design:returntype", Promise)
], AdminUsersController.prototype, "updateProfileStatusAdmin", null);
__decorate([
    (0, permissions_decorator_1.Permissions)(permissions_1.Permission.MEMBERS_UPDATE),
    (0, common_1.Patch)("profiles/:id/feature"),
    (0, swagger_1.ApiOperation)({ summary: "Toggle featured profile status (Admin)" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)("id")),
    __param(2, (0, common_1.Body)("isFeatured")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, Boolean]),
    __metadata("design:returntype", Promise)
], AdminUsersController.prototype, "toggleProfileFeaturedAdmin", null);
exports.AdminUsersController = AdminUsersController = __decorate([
    (0, swagger_1.ApiTags)("Admin Users"),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, permissions_guard_1.PermissionsGuard),
    (0, common_1.Controller)("admin"),
    __metadata("design:paramtypes", [users_service_1.UsersService])
], AdminUsersController);
//# sourceMappingURL=admin-users.controller.js.map