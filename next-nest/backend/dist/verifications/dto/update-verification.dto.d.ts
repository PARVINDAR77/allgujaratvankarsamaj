import { VerificationStatus } from "@prisma/client";
export declare class UpdateVerificationStatusDto {
    status: VerificationStatus;
    rejectionReason?: string;
}
