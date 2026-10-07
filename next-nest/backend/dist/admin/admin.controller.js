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
exports.AdminController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const admin_service_1 = require("./admin.service");
let AdminController = class AdminController {
    constructor(adminService) {
        this.adminService = adminService;
    }
    async getStats() {
        return this.adminService.getDashboardStats();
    }
    async getReports() {
        return this.adminService.getReports();
    }
    async updateReportStatus(id, status) {
        return this.adminService.updateReportStatus(id, status);
    }
    async getMatches() {
        return this.adminService.getMatches();
    }
    async getHealth() {
        return this.adminService.getHealthStatus();
    }
    async getPendingPhotos() {
        return this.adminService.getPendingPhotos();
    }
    async getShortlists() {
        return this.adminService.getShortlists();
    }
};
exports.AdminController = AdminController;
__decorate([
    (0, common_1.Get)("stats"),
    (0, swagger_1.ApiOperation)({ summary: "Get high-level admin dashboard statistics" }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], AdminController.prototype, "getStats", null);
__decorate([
    (0, common_1.Get)("reports"),
    (0, swagger_1.ApiOperation)({ summary: "Get user reports for moderation" }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], AdminController.prototype, "getReports", null);
__decorate([
    (0, common_1.Patch)("reports/:id"),
    (0, swagger_1.ApiOperation)({ summary: "Update report status" }),
    __param(0, (0, common_1.Param)("id")),
    __param(1, (0, common_1.Body)("status")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], AdminController.prototype, "updateReportStatus", null);
__decorate([
    (0, common_1.Get)("matches"),
    (0, swagger_1.ApiOperation)({ summary: "Get match interaction list" }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], AdminController.prototype, "getMatches", null);
__decorate([
    (0, common_1.Get)("health"),
    (0, swagger_1.ApiOperation)({ summary: "Get system health status" }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], AdminController.prototype, "getHealth", null);
__decorate([
    (0, common_1.Get)("photos/pending"),
    (0, swagger_1.ApiOperation)({ summary: "Get all pending unverified profile photos" }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], AdminController.prototype, "getPendingPhotos", null);
__decorate([
    (0, common_1.Get)("shortlists"),
    (0, swagger_1.ApiOperation)({ summary: "Get global shortlists for moderation" }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], AdminController.prototype, "getShortlists", null);
exports.AdminController = AdminController = __decorate([
    (0, swagger_1.ApiTags)("Admin"),
    (0, common_1.Controller)("admin"),
    __metadata("design:paramtypes", [admin_service_1.AdminService])
], AdminController);
//# sourceMappingURL=admin.controller.js.map