import { StatisticsService } from "./statistics.service";
export declare class StatisticsController {
    private readonly statisticsService;
    constructor(statisticsService: StatisticsService);
    getDashboardStatistics(): Promise<any>;
    getPublicDashboard(): Promise<any>;
    getTodaysBirthdays(): Promise<any>;
    getSectionViews(): Promise<any>;
    incrementSectionView(sectionName: string): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        sectionName: string;
        viewCount: number;
    }>;
}
