import { PrismaService } from "../prisma/prisma.service";
import { UpdateVerificationStatusDto } from "./dto/update-verification.dto";
export declare class VerificationsService {
    private readonly prisma;
    private readonly logger;
    private pendingVerificationsCache;
    private readonly CACHE_TTL;
    constructor(prisma: PrismaService);
    submitVerification(userId: string, documentType: string, documentUrl: string): Promise<{
        status: import(".prisma/client").$Enums.VerificationStatus;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        profileId: string;
        documentType: string;
        documentUrl: string;
        documentBackUrl: string | null;
        rejectionReason: string | null;
    }>;
    updateVerificationStatus(requestId: string, adminId: string, dto: UpdateVerificationStatusDto, ipAddress?: string): Promise<{
        status: import(".prisma/client").$Enums.VerificationStatus;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        profileId: string;
        documentType: string;
        documentUrl: string;
        documentBackUrl: string | null;
        rejectionReason: string | null;
    }>;
    getPendingVerifications(page?: number, limit?: number, status?: string): Promise<{
        data: {
            id: any;
            profileId: any;
            documentType: any;
            documentUrl: any;
            documentBackUrl: any;
            status: any;
            rejectionReason: any;
            createdAt: any;
            profile: {
                id: any;
                name: any;
                firstName: any;
                lastName: any;
                photoUrl: any;
                photos: any;
                nativePlace: any;
                city: any;
                pargana: any;
                user: any;
            };
        }[];
        meta: {
            page: number;
            limit: number;
            total: number;
            totalPages: number;
            hasNextPage: boolean;
            hasPreviousPage: boolean;
        };
    }>;
    getMyVerificationStatus(userId: string): Promise<{
        hasProfile: boolean;
        isVerified: boolean;
        profileStatus: string;
        latestRequest: any;
    } | {
        hasProfile: boolean;
        isVerified: boolean;
        profileStatus: import(".prisma/client").$Enums.ProfileStatus;
        latestRequest: {
            id: string;
            documentType: string;
            documentUrl: string;
            status: import(".prisma/client").$Enums.VerificationStatus;
            rejectionReason: string;
            createdAt: Date;
        };
    }>;
    servePrivateDocument(filename: string, res: any): Promise<void>;
    serveCandidatePrivateDocument(userId: string, filename: string, res: any): Promise<void>;
}
