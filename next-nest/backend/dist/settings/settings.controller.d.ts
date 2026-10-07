import { SettingsService } from "./settings.service";
export declare class SettingsController {
    private readonly settingsService;
    constructor(settingsService: SettingsService);
    getPublicSettings(): Promise<{
        siteTitle: string;
        bannerText: string;
        contactEmail: string;
        contactPhone: string;
        registrationEnabled: boolean;
        maintenanceMode: boolean;
    }>;
    getAdminSettings(): Promise<{
        siteTitle: string;
        bannerText: string;
        contactEmail: string;
        contactPhone: string;
        registrationEnabled: boolean;
        maintenanceMode: boolean;
    }>;
    updateSettings(body: Record<string, any>): Promise<{
        siteTitle: string;
        bannerText: string;
        contactEmail: string;
        contactPhone: string;
        registrationEnabled: boolean;
        maintenanceMode: boolean;
    } | {
        [x: string]: any;
    }>;
    getHomeButtons(): Promise<{
        data: {
            buttonId: number;
            title: string;
            subtitle: string;
            icon: string;
            route: string;
            isActive: boolean;
        }[];
    }>;
    updateHomeButtons(configs: any[]): Promise<{
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
