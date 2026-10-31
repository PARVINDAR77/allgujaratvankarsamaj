import { Response } from "express";
import { VerificationsService } from "./verifications.service";
import { AiVerificationService } from "./ai-verification.service";
import { StorageService } from "../storage/storage.service";
import { UpdateVerificationStatusDto } from "./dto/update-verification.dto";
export declare class VerificationsController {
    private readonly verificationsService;
    private readonly aiVerificationService;
    private readonly storageService;
    constructor(verificationsService: VerificationsService, aiVerificationService: AiVerificationService, storageService: StorageService);
    aiVerify(file?: Express.Multer.File, body?: any): Promise<{
        success: boolean;
        verified: boolean;
        url: string;
        result: import("./ai-verification.service").AiVerificationResult;
        reason: string;
        message: string;
    }>;
    submitVerification(req: any, body: {
        documentType: string;
        documentUrl: string;
    }): Promise<{
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
    getMyVerificationStatus(req: any): Promise<{
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
    getMyVerificationDocument(req: any, filename: string, res: Response): Promise<void>;
}
export declare class AdminVerificationsController {
    private readonly verificationsService;
    constructor(verificationsService: VerificationsService);
    getPendingVerificationsAdmin(): Promise<{
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
    }[]>;
    getVerificationDocumentAdmin(filename: string, res: Response): Promise<void>;
    updateStatusAdmin(req: any, id: string, dto: UpdateVerificationStatusDto): Promise<{
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
}
