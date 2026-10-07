import { ReportsService } from "./reports.service";
import { CreateReportDto } from "./dto/create-report.dto";
export declare class ReportsController {
    private readonly reportsService;
    constructor(reportsService: ReportsService);
    createReport(req: any, dto: CreateReportDto): Promise<{
        status: import(".prisma/client").$Enums.ReportStatus;
        id: string;
        createdAt: Date;
        details: string | null;
        reporterUserId: string;
        targetProfileId: string;
        reason: string;
    }>;
    getMyReports(req: any): Promise<{
        status: import(".prisma/client").$Enums.ReportStatus;
        id: string;
        createdAt: Date;
        details: string | null;
        reporterUserId: string;
        targetProfileId: string;
        reason: string;
    }[]>;
}
