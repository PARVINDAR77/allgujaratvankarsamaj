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
    async getUsersAdmin(page, limit, search, role, status) {
        return this.usersService.getAllUsersForAdmin(Number(page) || 1, Number(limit) || 15, search, role, status);
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
    async getProfilesAdmin(page, limit, search, status, category) {
        return this.usersService.getAllProfilesForAdmin(Number(page) || 1, Number(limit) || 15, search, status, category);
    }
    async updateProfileStatusAdmin(req, id, status) {
        const ipAddress = req.ip || req.connection?.remoteAddress || null;
        return this.usersService.updateProfileStatusAdmin(id, req.user.id, status, ipAddress);
    }
    async toggleProfileFeaturedAdmin(req, id, isFeatured) {
        const ipAddress = req.ip || req.connection?.remoteAddress || null;
        return this.usersService.toggleProfileFeaturedAdmin(id, req.user.id, isFeatured, ipAddress);
    }
    async deleteUserAdmin(req, id) {
        if (req.user.role !== client_1.Role.SUPER_ADMIN && req.user.role !== client_1.Role.ADMIN) {
            throw new common_1.ForbiddenException("માત્ર સુપર એડમિન અથવા એડમિન વપરાશકર્તા એકાઉન્ટ ડિલીટ કરી શકે છે (Only SUPER_ADMIN or ADMIN can delete accounts)");
        }
        const ipAddress = req.ip || req.connection?.remoteAddress || null;
        return this.usersService.deleteUserAccount(id, req.user.id, ipAddress);
    }
    async deleteProfileAdmin(req, id) {
        if (req.user.role !== client_1.Role.SUPER_ADMIN && req.user.role !== client_1.Role.ADMIN) {
            throw new common_1.ForbiddenException("માત્ર સુપર એડમિન અથવા એડમિન પ્રોફાઇલ ડિલીટ કરી શકે છે (Only SUPER_ADMIN or ADMIN can delete profiles)");
        }
        const ipAddress = req.ip || req.connection?.remoteAddress || null;
        return this.usersService.deleteProfileAdmin(id, req.user.id, ipAddress);
    }
    async getSubAdmins(req) {
        if (req.user.role !== client_1.Role.SUPER_ADMIN) {
            throw new common_1.ForbiddenException("માત્ર સુપર એડમિન સબ-એડમિન એકાઉન્ટ્સ જોઈ શકે છે (Only SUPER_ADMIN can view sub-admins)");
        }
        return this.usersService.getSubAdmins();
    }
    async createSubAdmin(req, body) {
        if (req.user.role !== client_1.Role.SUPER_ADMIN) {
            throw new common_1.ForbiddenException("માત્ર સુપર એડમિન નવા સબ-એડમિન બનાવી શકે છે (Only SUPER_ADMIN can create sub-admins)");
        }
        const ipAddress = req.ip || req.connection?.remoteAddress || null;
        return this.usersService.createSubAdmin(req.user.id, body, ipAddress);
    }
    async updateSubAdmin(req, id, body) {
        if (req.user.role !== client_1.Role.SUPER_ADMIN) {
            throw new common_1.ForbiddenException("માત્ર સુપર એડમિન સબ-એડમિનમાં ફેરફાર કરી શકે છે (Only SUPER_ADMIN can update sub-admins)");
        }
        const ipAddress = req.ip || req.connection?.remoteAddress || null;
        return this.usersService.updateSubAdmin(req.user.id, id, body, ipAddress);
    }
    async deleteSubAdmin(req, id) {
        if (req.user.role !== client_1.Role.SUPER_ADMIN) {
            throw new common_1.ForbiddenException("માત્ર સુપર એડમિન સબ-એડમિન ડિલીટ કરી શકે છે (Only SUPER_ADMIN can delete sub-admins)");
        }
        const ipAddress = req.ip || req.connection?.remoteAddress || null;
        return this.usersService.deleteSubAdmin(req.user.id, id, ipAddress);
    }
};
exports.AdminUsersController = AdminUsersController;
__decorate([
    (0, permissions_decorator_1.Permissions)(permissions_1.Permission.MEMBERS_READ),
    (0, common_1.Get)("users"),
    (0, swagger_1.ApiOperation)({ summary: "Get list of all registered users (Admin)" }),
    (0, swagger_1.ApiResponse)({ status: 200, description: "List of users" }),
    __param(0, (0, common_1.Query)("page")),
    __param(1, (0, common_1.Query)("limit")),
    __param(2, (0, common_1.Query)("search")),
    __param(3, (0, common_1.Query)("role")),
    __param(4, (0, common_1.Query)("status")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Number, String, String, String]),
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
    __param(0, (0, common_1.Query)("page")),
    __param(1, (0, common_1.Query)("limit")),
    __param(2, (0, common_1.Query)("search")),
    __param(3, (0, common_1.Query)("status")),
    __param(4, (0, common_1.Query)("category")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Number, String, String, String]),
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
__decorate([
    (0, permissions_decorator_1.Permissions)(permissions_1.Permission.MEMBERS_DELETE),
    (0, common_1.Delete)("users/:id"),
    (0, swagger_1.ApiOperation)({
        summary: "Permanently delete user and all associated data (Admin / Super Admin)",
    }),
    (0, swagger_1.ApiResponse)({ status: 200, description: "User account deleted successfully" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)("id")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], AdminUsersController.prototype, "deleteUserAdmin", null);
__decorate([
    (0, permissions_decorator_1.Permissions)(permissions_1.Permission.MEMBERS_DELETE),
    (0, common_1.Delete)("profiles/:id"),
    (0, swagger_1.ApiOperation)({
        summary: "Permanently delete matrimonial profile (Admin / Super Admin)",
    }),
    (0, swagger_1.ApiResponse)({ status: 200, description: "Matrimonial profile deleted successfully" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)("id")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], AdminUsersController.prototype, "deleteProfileAdmin", null);
__decorate([
    (0, common_1.Get)("sub-admins"),
    (0, swagger_1.ApiOperation)({ summary: "Get all sub-admin staff accounts (Super Admin only)" }),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], AdminUsersController.prototype, "getSubAdmins", null);
__decorate([
    (0, common_1.Post)("sub-admins"),
    (0, swagger_1.ApiOperation)({ summary: "Create a new sub-admin staff account with granular permissions (Super Admin only)" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise)
], AdminUsersController.prototype, "createSubAdmin", null);
__decorate([
    (0, common_1.Patch)("sub-admins/:id"),
    (0, swagger_1.ApiOperation)({ summary: "Update a sub-admin staff account details & section permissions (Super Admin only)" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)("id")),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, Object]),
    __metadata("design:returntype", Promise)
], AdminUsersController.prototype, "updateSubAdmin", null);
__decorate([
    (0, common_1.Delete)("sub-admins/:id"),
    (0, swagger_1.ApiOperation)({ summary: "Delete a sub-admin staff account (Super Admin only)" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)("id")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], AdminUsersController.prototype, "deleteSubAdmin", null);
exports.AdminUsersController = AdminUsersController = __decorate([
    (0, swagger_1.ApiTags)("Admin Users"),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, permissions_guard_1.PermissionsGuard),
    (0, common_1.Controller)("admin"),
    __metadata("design:paramtypes", [users_service_1.UsersService])
], AdminUsersController);
//# sourceMappingURL=admin-users.controller.js.map