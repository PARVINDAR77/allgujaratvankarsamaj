import { Injectable, Logger } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";

@Injectable()
export class SettingsService {
  private readonly logger = new Logger(SettingsService.name);

  constructor(private readonly prisma: PrismaService) {}

  private readonly defaultSettings = {
    siteTitle: "All Gujarat Vankar Samaj Matrimony",
    bannerText: "Welcome to All Gujarat Vankar Samaj Matrimony — Find Your Ideal Life Partner Within Our Community",
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

  async updateSettings(settings: Record<string, any>) {
    try {
      const updates = Object.entries(settings).map(([key, value]) =>
        this.prisma.siteSetting.upsert({
          where: { key },
          update: { value: String(value) },
          create: { key, value: String(value) },
        })
      );

      await this.prisma.$transaction(updates);
      return this.getPublicSettings();
    } catch (err: any) {
      this.logger.error("Error updating site settings", err);
      return { ...settings };
    }
  }
}
