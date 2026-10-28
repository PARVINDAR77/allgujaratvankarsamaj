import { OtpChannel, OtpPurpose } from "@prisma/client";
export declare class SendRegistrationOtpDto {
    name: string;
    phone: string;
    email: string;
}
export declare class VerifyRegistrationOtpDto {
    phone: string;
    email: string;
    phoneOtp: string;
    emailOtp: string;
}
export declare class SendForgotPasswordOtpDto {
    identifier: string;
    channel?: OtpChannel;
}
export declare class VerifyResetOtpDto {
    identifier: string;
    code: string;
}
export declare class AdminOtpQueryDto {
    page?: number;
    limit?: number;
    channel?: OtpChannel;
    purpose?: OtpPurpose;
    date?: string;
    search?: string;
}
export declare class SendProfileContactOtpDto {
    name?: string;
    phone?: string;
    email?: string;
    channel?: "SMS" | "EMAIL" | "BOTH";
}
export declare class VerifyProfileContactOtpDto {
    phone?: string;
    email?: string;
    phoneOtp?: string;
    emailOtp?: string;
}
