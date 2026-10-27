import { PrismaService } from "../prisma/prisma.service";
import { OtpPurpose } from "@prisma/client";
export interface SendMailResult {
    success: boolean;
    messageId?: string;
    error?: string;
}
export declare class MailService {
    private readonly prisma;
    private readonly logger;
    private transporter;
    constructor(prisma: PrismaService);
    private initTransporter;
    isConfigured(): boolean;
    private buildHtmlTemplate;
    sendOtpEmail(params: {
        email: string;
        otp: string;
        recipientName?: string;
        purpose: OtpPurpose;
        ipAddress?: string;
    }): Promise<SendMailResult>;
}
