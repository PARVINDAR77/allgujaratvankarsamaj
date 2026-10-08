import { PrismaService } from "../prisma/prisma.service";
export declare class AdminService {
    private readonly prisma;
    private readonly logger;
    constructor(prisma: PrismaService);
    getDashboardStats(): Promise<{
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
    getVerifications(): Promise<({
        profile: {
            user: {
                name: string;
                email: string;
                phone: string;
            };
            id: string;
            firstName: string;
            lastName: string;
            nativePlace: string;
            city: string;
            photoUrl: string;
            photos: string;
        };
    } & {
        status: import(".prisma/client").$Enums.VerificationStatus;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        profileId: string;
        documentType: string;
        documentUrl: string;
        documentBackUrl: string | null;
        rejectionReason: string | null;
    })[] | {
        id: string;
        profileId: string;
        name: string;
        type: string;
        documentUrl: string;
        status: string;
        createdAt: Date;
    }[]>;
    updateVerificationStatus(id: string, status: any, rejectionReason?: string): Promise<{
        status: import(".prisma/client").$Enums.VerificationStatus;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        profileId: string;
        documentType: string;
        documentUrl: string;
        documentBackUrl: string | null;
        rejectionReason: string | null;
    } | {
        id: string;
        status: any;
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
    getHealthStatus(): Promise<{
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
