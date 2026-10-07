import { VerificationsService } from "./verifications.service";
import { UpdateVerificationStatusDto } from "./dto/update-verification.dto";
export declare class VerificationsController {
    private readonly verificationsService;
    constructor(verificationsService: VerificationsService);
    submitVerification(req: any, body: {
        documentType: string;
        documentUrl: string;
    }): Promise<{
        status: import(".prisma/client").$Enums.VerificationStatus;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        documentType: string;
        documentUrl: string;
        rejectionReason: string | null;
        profileId: string;
    }>;
    getMyVerificationStatus(req: any): Promise<{
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
export declare class AdminVerificationsController {
    private readonly verificationsService;
    constructor(verificationsService: VerificationsService);
    getPendingVerificationsAdmin(): Promise<{
        id: any;
        profileId: any;
        documentType: any;
        documentUrl: any;
        status: any;
        rejectionReason: any;
        createdAt: any;
        profile: {
            id: any;
            name: string;
            pargana: any;
        };
    }[]>;
    updateStatusAdmin(req: any, id: string, dto: UpdateVerificationStatusDto): Promise<{
        status: import(".prisma/client").$Enums.VerificationStatus;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        documentType: string;
        documentUrl: string;
        rejectionReason: string | null;
        profileId: string;
    }>;
}
