import { PrismaService } from "../prisma/prisma.service";
import { UpdateVerificationStatusDto } from "./dto/update-verification.dto";
export declare class VerificationsService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    submitVerification(userId: string, documentType: string, documentUrl: string): Promise<{
        status: import(".prisma/client").$Enums.VerificationStatus;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        documentType: string;
        documentUrl: string;
        rejectionReason: string | null;
        profileId: string;
    }>;
    updateVerificationStatus(requestId: string, adminId: string, dto: UpdateVerificationStatusDto, ipAddress?: string): Promise<{
        status: import(".prisma/client").$Enums.VerificationStatus;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        documentType: string;
        documentUrl: string;
        rejectionReason: string | null;
        profileId: string;
    }>;
    getPendingVerifications(): Promise<({
        profile: {
            pargana: {
                name: string;
            };
            id: string;
            firstName: string;
            lastName: string;
        };
    } & {
        status: import(".prisma/client").$Enums.VerificationStatus;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        documentType: string;
        documentUrl: string;
        rejectionReason: string | null;
        profileId: string;
    })[]>;
    getMyVerificationStatus(userId: string): Promise<{
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
}
