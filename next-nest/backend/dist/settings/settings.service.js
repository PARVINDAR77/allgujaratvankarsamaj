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
var SettingsService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.SettingsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let SettingsService = SettingsService_1 = class SettingsService {
    constructor(prisma) {
        this.prisma = prisma;
        this.logger = new common_1.Logger(SettingsService_1.name);
        this.defaultSettings = {
            siteTitle: "All Gujarat Vankar Samaj Matrimony",
            bannerText: "Welcome to All Gujarat Vankar Samaj Matrimony — Find Your Ideal Life Partner Within Our Community",
            contactEmail: "support@vankarsamaj.org",
            contactPhone: "+91 98765 43210",
            registrationEnabled: "true",
            maintenanceMode: "false",
        };
        this.defaultHomeButtons = [
            {
                buttonId: 1,
                title: "Education",
                subtitle: "For Better Tomorrow",
                icon: "menu_book",
                route: "/education",
                isActive: true,
            },
            {
                buttonId: 2,
                title: "Unity",
                subtitle: "In Diversity",
                icon: "groups",
                route: "/advertisement",
                isActive: true,
            },
            {
                buttonId: 3,
                title: "Progress",
                subtitle: "Through Support",
                icon: "trending_up",
                route: "/statistics",
                isActive: true,
            },
            {
                buttonId: 4,
                title: "Service",
                subtitle: "To Society",
                icon: "volunteer_activism",
                route: "/birthdays",
                isActive: true,
            },
            {
                buttonId: 5,
                title: "Strong Roots",
                subtitle: "Bright Future",
                icon: "nature",
                route: "/advertisement",
                isActive: true,
            },
        ];
    }
    async getPublicSettings() {
        try {
            const records = await this.prisma.siteSetting.findMany();
            const settingsMap = { ...this.defaultSettings };
            records.forEach((rec) => {
                settingsMap[rec.key] = rec.value;
            });
            return {
                siteTitle: settingsMap.siteTitle,
                bannerText: settingsMap.bannerText,
                contactEmail: settingsMap.contactEmail,
                contactPhone: settingsMap.contactPhone,
                registrationEnabled: settingsMap.registrationEnabled === "true",
                maintenanceMode: settingsMap.maintenanceMode === "true",
            };
        }
        catch (err) {
            this.logger.warn("Failed to fetch site settings from DB, returning defaults", err?.message);
            return {
                siteTitle: this.defaultSettings.siteTitle,
                bannerText: this.defaultSettings.bannerText,
                contactEmail: this.defaultSettings.contactEmail,
                contactPhone: this.defaultSettings.contactPhone,
                registrationEnabled: true,
                maintenanceMode: false,
            };
        }
    }
    async getAllSettings() {
        return this.getPublicSettings();
    }
    async updateSettings(settings) {
        try {
            const updates = Object.entries(settings).map(([key, value]) => this.prisma.siteSetting.upsert({
                where: { key },
                update: { value: String(value) },
                create: { key, value: String(value) },
            }));
            await this.prisma.$transaction(updates);
            return this.getPublicSettings();
        }
        catch (err) {
            this.logger.error("Error updating site settings", err);
            return { ...settings };
        }
    }
    async getHomeButtonConfigs() {
        try {
            const records = await this.prisma.homeButtonConfig.findMany({
                orderBy: { buttonId: "asc" },
            });
            if (records.length === 0) {
                await this.prisma.homeButtonConfig.createMany({
                    data: this.defaultHomeButtons,
                });
                return { data: this.defaultHomeButtons };
            }
            return { data: records };
        }
        catch (err) {
            this.logger.warn("Failed to fetch home button configs", err?.message);
            return { data: this.defaultHomeButtons };
        }
    }
    async updateHomeButtonConfigs(configs) {
        for (const config of configs) {
            if (config.buttonId < 1 || config.buttonId > 5) {
                throw new common_1.BadRequestException(`Invalid button position: ${config.buttonId}`);
            }
        }
        const fixedRoutes = {
            1: "/education",
            2: "/advertisement",
            3: "/statistics",
            4: "/birthdays",
            5: "/advertisement",
        };
        try {
            const updates = configs.map((config) => {
                const targetRoute = config.route && config.route.trim().startsWith("/")
                    ? config.route.trim()
                    : fixedRoutes[config.buttonId];
                return this.prisma.homeButtonConfig.upsert({
                    where: { buttonId: config.buttonId },
                    update: {
                        title: config.title,
                        subtitle: config.subtitle,
                        icon: config.icon,
                        route: targetRoute,
                        isActive: config.isActive !== undefined ? config.isActive : true,
                    },
                    create: {
                        buttonId: config.buttonId,
                        title: config.title,
                        subtitle: config.subtitle,
                        icon: config.icon,
                        route: targetRoute,
                        isActive: config.isActive !== undefined ? config.isActive : true,
                    },
                });
            });
            await this.prisma.$transaction(updates);
            return this.getHomeButtonConfigs();
        }
        catch (err) {
            this.logger.error("Error updating home button configs", err);
            throw err;
        }
    }
};
exports.SettingsService = SettingsService;
exports.SettingsService = SettingsService = SettingsService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], SettingsService);
//# sourceMappingURL=settings.service.js.map