import { PrismaService } from "../prisma/prisma.service";
export declare class SettingsService {
    private readonly prisma;
    private readonly logger;
    constructor(prisma: PrismaService);
    private readonly defaultSettings;
    getPublicSettings(): Promise<{
        siteTitle: string;
        bannerText: string;
        contactEmail: string;
        contactPhone: string;
        registrationEnabled: boolean;
        maintenanceMode: boolean;
    }>;
    getAllSettings(): Promise<{
        siteTitle: string;
        bannerText: string;
        contactEmail: string;
        contactPhone: string;
        registrationEnabled: boolean;
        maintenanceMode: boolean;
    }>;
    updateSettings(settings: Record<string, any>): Promise<{
        siteTitle: string;
        bannerText: string;
        contactEmail: string;
        contactPhone: string;
        registrationEnabled: boolean;
        maintenanceMode: boolean;
    } | {
        [x: string]: any;
    }>;
    private readonly defaultHomeButtons;
    getHomeButtonConfigs(): Promise<{
        data: {
            buttonId: number;
            title: string;
            subtitle: string;
            icon: string;
            route: string;
            isActive: boolean;
        }[];
    }>;
    updateHomeButtonConfigs(configs: any[]): Promise<{
        data: {
            buttonId: number;
            title: string;
            subtitle: string;
            icon: string;
            route: string;
            isActive: boolean;
        }[];
    }>;
}
