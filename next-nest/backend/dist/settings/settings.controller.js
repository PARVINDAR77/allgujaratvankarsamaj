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
exports.SettingsController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const settings_service_1 = require("./settings.service");
const public_decorator_1 = require("../auth/decorators/public.decorator");
let SettingsController = class SettingsController {
    constructor(settingsService) {
        this.settingsService = settingsService;
    }
    async getPublicSettings() {
        return this.settingsService.getPublicSettings();
    }
    async getAdminSettings() {
        return this.settingsService.getAllSettings();
    }
    async updateSettings(body) {
        return this.settingsService.updateSettings(body);
    }
    async getHomeButtons() {
        return this.settingsService.getHomeButtonConfigs();
    }
    async updateHomeButtons(configs) {
        return this.settingsService.updateHomeButtonConfigs(configs);
    }
};
exports.SettingsController = SettingsController;
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)("settings/public"),
    (0, swagger_1.ApiOperation)({
        summary: "Get public site configuration and settings for Flutter & Web",
    }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], SettingsController.prototype, "getPublicSettings", null);
__decorate([
    (0, common_1.Get)("admin/settings"),
    (0, swagger_1.ApiOperation)({ summary: "Get all site settings for Admin Panel" }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], SettingsController.prototype, "getAdminSettings", null);
__decorate([
    (0, common_1.Put)("admin/settings"),
    (0, swagger_1.ApiOperation)({ summary: "Update site settings from Admin Panel" }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], SettingsController.prototype, "updateSettings", null);
__decorate([
    (0, public_decorator_1.Public)(),
    (0, common_1.Get)("home-buttons"),
    (0, swagger_1.ApiOperation)({
        summary: "Get dynamic home button configurations for Flutter app",
    }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], SettingsController.prototype, "getHomeButtons", null);
__decorate([
    (0, common_1.Put)("admin/home-buttons"),
    (0, swagger_1.ApiOperation)({
        summary: "Update home button configurations from Admin Panel",
    }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Array]),
    __metadata("design:returntype", Promise)
], SettingsController.prototype, "updateHomeButtons", null);
exports.SettingsController = SettingsController = __decorate([
    (0, swagger_1.ApiTags)("Settings"),
    (0, common_1.Controller)(),
    __metadata("design:paramtypes", [settings_service_1.SettingsService])
], SettingsController);
//# sourceMappingURL=settings.controller.js.map