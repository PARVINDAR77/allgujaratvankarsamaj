import { PrismaService } from "../prisma/prisma.service";
import { CreateReportDto } from "./dto/create-report.dto";
export declare class ReportsService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    createReport(reporterUserId: string, dto: CreateReportDto): Promise<{
        status: import(".prisma/client").$Enums.ReportStatus;
        id: string;
        createdAt: Date;
        details: string | null;
        reporterUserId: string;
        targetProfileId: string;
        reason: string;
    }>;
    getMyReports(reporterUserId: string): Promise<{
        status: import(".prisma/client").$Enums.ReportStatus;
        id: string;
        createdAt: Date;
        details: string | null;
        reporterUserId: string;
        targetProfileId: string;
        reason: string;
    }[]>;
}
