import { PrismaService } from "../prisma/prisma.service";
export declare class StatisticsService {
    private readonly prisma;
    private readonly logger;
    private dashboardStatsCache;
    private readonly DASHBOARD_CACHE_TTL;
    private publicLiveStatsCache;
    private readonly PUBLIC_CACHE_TTL;
    private sectionViewsCache;
    private readonly SECTION_VIEWS_CACHE_TTL;
    private birthdaysCache;
    private readonly BIRTHDAYS_CACHE_TTL;
    constructor(prisma: PrismaService);
    getDashboardStatistics(): Promise<any>;
    getTodaysBirthdays(): Promise<any>;
    getSectionViews(): Promise<any>;
    incrementSectionView(sectionName: string): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        sectionName: string;
        viewCount: number;
    }>;
    getPublicLiveStatistics(): Promise<any>;
}
