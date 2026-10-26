import { PrismaService } from "../prisma/prisma.service";
import { OtpPurpose } from "@prisma/client";
export interface SendSmsResult {
    success: boolean;
    messageId?: string;
    gatewayResponse?: any;
    error?: string;
}
export declare class SmsService {
    private readonly prisma;
    private readonly logger;
    private readonly gatewayUrl;
    private readonly username;
    private readonly apiKey;
    private readonly senderId;
    private readonly templateId;
    private readonly entityId;
    private readonly route;
    constructor(prisma: PrismaService);
    private formatDltMessage;
    cleanPhoneNumber(phone: string): string;
    sendOtpSms(params: {
        phone: string;
        otp: string;
        recipientName?: string;
        purpose: OtpPurpose;
        ipAddress?: string;
    }): Promise<SendSmsResult>;
}
