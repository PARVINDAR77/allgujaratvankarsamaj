import { Injectable, Logger, BadRequestException } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";

@Injectable()
export class SettingsService {
  private readonly logger = new Logger(SettingsService.name);

  constructor(private readonly prisma: PrismaService) {}

  private readonly defaultSettings = {
    siteTitle: "All Gujarat Vankar Samaj Matrimony",
    bannerText:
      "Welcome to All Gujarat Vankar Samaj Matrimony — Find Your Ideal Life Partner Within Our Community",
    contactEmail: "support@vankarsamaj.org",
    contactPhone: "+91 98765 43210",
    registrationEnabled: "true",
    maintenanceMode: "false",
  };

  async getPublicSettings() {
    try {
      const records = await this.prisma.siteSetting.findMany();
      const settingsMap: Record<string, string> = { ...this.defaultSettings };

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
    } catch (err: any) {
      this.logger.warn(
        "Failed to fetch site settings from DB, returning defaults",
        err?.message,
      );
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

  async updateSettings(settings: Record<string, any>) {
    try {
      const updates = Object.entries(settings).map(([key, value]) =>
        this.prisma.siteSetting.upsert({
          where: { key },
          update: { value: String(value) },
          create: { key, value: String(value) },
        }),
      );

      await this.prisma.$transaction(updates);
      return this.getPublicSettings();
    } catch (err: any) {
      this.logger.error("Error updating site settings", err);
      return { ...settings };
    }
  }

  // --- Home Button Configs ---

  private readonly defaultHomeButtons = [
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
      route: "/advertisement?placement=BUTTON_2&section=HOME_UNITY",
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
      route: "/advertisement?placement=BUTTON_5&section=HOME_STRONG_ROOTS",
      isActive: true,
    },
  ];

  async getHomeButtonConfigs() {
    try {
      const records = await this.prisma.homeButtonConfig.findMany({
        orderBy: { buttonId: "asc" },
      });

      if (records.length === 0) {
        // Seed initial if empty
        await this.prisma.homeButtonConfig.createMany({
          data: this.defaultHomeButtons,
        });
        return { data: this.defaultHomeButtons };
      }

      return { data: records };
    } catch (err: any) {
      this.logger.warn("Failed to fetch home button configs", err?.message);
      return { data: this.defaultHomeButtons };
    }
  }

  async updateHomeButtonConfigs(configs: any[]) {
    for (const config of configs) {
      if (config.buttonId < 1 || config.buttonId > 5) {
        throw new BadRequestException(
          `Invalid button position: ${config.buttonId}`,
        );
      }
    }

    const fixedRoutes: Record<number, string> = {
      1: "/education",
      2: "/advertisement?placement=BUTTON_2&section=HOME_UNITY",
      3: "/statistics",
      4: "/birthdays",
      5: "/advertisement?placement=BUTTON_5&section=HOME_STRONG_ROOTS",
    };

    try {
      const updates = configs.map((config) => {
        let targetRoute = config.route && config.route.trim().startsWith("/") 
          ? config.route.trim() 
          : fixedRoutes[config.buttonId];
        // Ensure buttons 2 and 5 retain their required query params if saved as bare /advertisement
        if (config.buttonId === 2 && (targetRoute === "/advertisement" || targetRoute === "/advertisement/")) {
          targetRoute = "/advertisement?placement=BUTTON_2&section=HOME_UNITY";
        } else if (config.buttonId === 5 && (targetRoute === "/advertisement" || targetRoute === "/advertisement/")) {
          targetRoute = "/advertisement?placement=BUTTON_5&section=HOME_STRONG_ROOTS";
        }
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
    } catch (err: any) {
      this.logger.error("Error updating home button configs", err);
      throw err;
    }
  }
}
