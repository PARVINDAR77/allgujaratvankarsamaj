import { AdminService } from "./admin.service";
export declare class AdminController {
    private readonly adminService;
    constructor(adminService: AdminService);
    getStats(): Promise<{
        totalUsers: number;
        totalProfiles: number;
        totalMatches: number;
        totalMessages: number;
        monthlyGrowth: {
            month: string;
            users: number;
            profiles: number;
        }[];
        parganaBreakdown: {
            name: string;
            count: number;
            percentage: number;
        }[];
        recentActivities: {
            id: string;
            icon: string;
            title: string;
            user: string;
            time: string;
            status: string;
        }[];
        recentUsers: {
            id: string;
            name: any;
            email: string;
            phone: any;
            pargana: string;
            status: import(".prisma/client").$Enums.Status;
            role: import(".prisma/client").$Enums.Role;
            createdAt: Date;
        }[] | {
            id: string;
            name: string;
            email: string;
            phone: string;
            pargana: string;
            status: string;
            role: string;
            createdAt: Date;
        }[];
        recentVerifications: {
            id: string;
            name: string;
            type: string;
            status: string;
            date: string;
        }[];
    }>;
    getReports(): Promise<{
        status: import(".prisma/client").$Enums.ReportStatus;
        id: string;
        createdAt: Date;
        details: string | null;
        reporterUserId: string;
        targetProfileId: string;
        reason: string;
    }[]>;
    updateReportStatus(id: string, status: any): Promise<{
        status: import(".prisma/client").$Enums.ReportStatus;
        id: string;
        createdAt: Date;
        details: string | null;
        reporterUserId: string;
        targetProfileId: string;
        reason: string;
    } | {
        id: string;
        status: any;
    }>;
    getMatches(): Promise<{
        status: import(".prisma/client").$Enums.InterestStatus;
        id: string;
        createdAt: Date;
        senderProfileId: string;
        receiverProfileId: string;
    }[]>;
    getHealth(): Promise<{
        status: string;
        timestamp: string;
        environment: string;
        services: {
            database: string;
            api: string;
            auth: string;
        };
    }>;
    getPendingPhotos(): Promise<{
        id: string;
        createdAt: Date;
        userId: string;
        firstName: string;
        lastName: string;
        photoUrl: string;
    }[]>;
    getShortlists(): Promise<{
        id: string;
        createdAt: Date;
        userId: string;
        targetProfileId: string;
    }[]>;
}
