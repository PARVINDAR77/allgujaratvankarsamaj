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
exports.StatisticsController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const statistics_service_1 = require("./statistics.service");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
const capabilities_guard_1 = require("../auth/guards/capabilities.guard");
const capabilities_decorator_1 = require("../auth/decorators/capabilities.decorator");
const capabilities_1 = require("../auth/constants/capabilities");
const public_decorator_1 = require("../auth/decorators/public.decorator");
let StatisticsController = class StatisticsController {
    constructor(statisticsService) {
        this.statisticsService = statisticsService;
    }
    async getDashboardStatistics() {
        return this.statisticsService.getDashboardStatistics();
    }
    async getPublicDashboard() {
        return this.statisticsService.getPublicLiveStatistics();
    }
    async getTodaysBirthdays() {
        return this.statisticsService.getTodaysBirthdays();
    }
    async getSectionViews() {
        return this.statisticsService.getSectionViews();
    }
    async incrementSectionView(sectionName) {
        return this.statisticsService.incrementSectionView(sectionName);
    }
};
exports.StatisticsController = StatisticsController;
__decorate([
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, capabilities_guard_1.CapabilitiesGuard),
    (0, capabilities_decorator_1.Capabilities)(capabilities_1.Capability.STATISTICS_READ),
    (0, common_1.Get)("admin/statistics/dashboard"),
    (0, swagger_1.ApiOperation)({ summary: "Get Admin Dashboard Statistics" }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], StatisticsController.prototype, "getDashboardStatistics", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)("statistics/dashboard"),
    (0, swagger_1.ApiOperation)({ summary: "Get Public Live Statistics" }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], StatisticsController.prototype, "getPublicDashboard", null);
__decorate([
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.Get)("statistics/birthdays"),
    (0, swagger_1.ApiOperation)({ summary: "Get Todays Birthdays" }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], StatisticsController.prototype, "getTodaysBirthdays", null);
__decorate([
    (0, common_1.Get)("statistics/views"),
    (0, swagger_1.ApiOperation)({ summary: "Get all section views" }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], StatisticsController.prototype, "getSectionViews", null);
__decorate([
    (0, common_1.Post)("statistics/views/:sectionName/increment"),
    (0, swagger_1.ApiOperation)({ summary: "Increment a section view" }),
    __param(0, (0, common_1.Param)("sectionName")),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], StatisticsController.prototype, "incrementSectionView", null);
exports.StatisticsController = StatisticsController = __decorate([
    (0, swagger_1.ApiTags)("Statistics"),
    (0, common_1.Controller)(),
    __metadata("design:paramtypes", [statistics_service_1.StatisticsService])
], StatisticsController);
//# sourceMappingURL=statistics.controller.js.map