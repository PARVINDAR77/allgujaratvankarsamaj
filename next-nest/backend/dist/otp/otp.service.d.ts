import { PrismaService } from "../prisma/prisma.service";
import { SmsService } from "./sms.service";
import { MailService } from "./mail.service";
import { AdminOtpQueryDto, SendForgotPasswordOtpDto, SendProfileContactOtpDto, SendRegistrationOtpDto, VerifyProfileContactOtpDto, VerifyRegistrationOtpDto, VerifyResetOtpDto } from "./dto/otp.dto";
export declare class OtpService {
    private readonly prisma;
    private readonly smsService;
    private readonly mailService;
    private readonly logger;
    private readonly MAX_ATTEMPTS;
    private readonly LOCKOUT_MINUTES;
    private readonly RESEND_COOLDOWN_SECONDS;
    private readonly OTP_EXPIRY_MINUTES;
    constructor(prisma: PrismaService, smsService: SmsService, mailService: MailService);
    private generate6DigitOtp;
    private maskPhone;
    private maskEmail;
    private checkLockout;
    private checkCooldown;
    sendRegistrationOtp(dto: SendRegistrationOtpDto, ipAddress?: string): Promise<{
        success: boolean;
        message: string;
        maskedPhone: string;
        maskedEmail: string;
        smsDelivered: boolean;
        emailConfigured: boolean;
        expiresInSeconds: number;
        resendCooldownSeconds: number;
        maxAttempts: number;
    }>;
    verifyRegistrationOtp(dto: VerifyRegistrationOtpDto): Promise<{
        success: boolean;
        verified: boolean;
        message: string;
        registrationToken: string;
    }>;
    sendProfileContactOtp(userId?: string, dto?: SendProfileContactOtpDto, ipAddress?: string): Promise<{
        success: boolean;
        message: string;
        maskedPhone: string;
        maskedEmail: string;
        channel: string;
        smsDelivered: any;
        emailConfigured: boolean;
        expiresInSeconds: number;
        resendCooldownSeconds: number;
        maxAttempts: number;
    }>;
    verifyProfileContactOtp(userId?: string, dto?: VerifyProfileContactOtpDto): Promise<{
        success: boolean;
        verified: boolean;
        isPhoneVerified: boolean;
        isEmailVerified: boolean;
        message: string;
    }>;
    consumeRegistrationToken(token: string, phone: string, email: string): Promise<boolean>;
    sendForgotPasswordOtp(dto: SendForgotPasswordOtpDto, ipAddress?: string): Promise<{
        success: boolean;
        message: string;
        target: string;
        maskedContact: string;
        channel: import(".prisma/client").$Enums.OtpChannel;
        expiresInSeconds: number;
        resendCooldownSeconds: number;
        maxAttempts: number;
    }>;
    verifyResetOtp(dto: VerifyResetOtpDto): Promise<{
        success: boolean;
        verified: boolean;
        message: string;
        resetToken: string;
    }>;
    consumeResetToken(identifier: string, token: string): Promise<boolean>;
    getDailySummary(): Promise<{
        success: boolean;
        today: {
            total: number;
            smsCount: number;
            emailCount: number;
            registrationCount: number;
            forgotPasswordCount: number;
            deliveredCount: number;
            failedCount: number;
        };
        yesterday: {
            total: number;
            smsCount: number;
            emailCount: number;
        };
        activeLockouts: number;
        totalAllTime: number;
    }>;
    getDailyTrends(days?: number): Promise<{
        success: boolean;
        days: number;
        trends: {
            date: string;
            sms: number;
            email: number;
            total: number;
            failed: number;
        }[];
    }>;
    getLogs(query: AdminOtpQueryDto): Promise<{
        success: boolean;
        data: {
            status: import(".prisma/client").$Enums.OtpStatus;
            id: string;
            createdAt: Date;
            ipAddress: string | null;
            channel: import(".prisma/client").$Enums.OtpChannel;
            purpose: import(".prisma/client").$Enums.OtpPurpose;
            recipient: string;
            gatewayId: string | null;
            gatewayResp: string | null;
        }[];
        meta: {
            page: number;
            limit: number;
            total: number;
            totalPages: number;
        };
    }>;
}
