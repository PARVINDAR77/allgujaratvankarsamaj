import { AuthService } from "./auth.service";
import { UsersService } from "../users/users.service";
import { OtpService } from "../otp/otp.service";
import { SendProfileContactOtpDto, SendRegistrationOtpDto, VerifyProfileContactOtpDto, VerifyRegistrationOtpDto } from "../otp/dto/otp.dto";
import { LoginDto } from "./dto/login.dto";
import { RegisterDto } from "./dto/register.dto";
import { ForgotPasswordDto, VerifyResetCodeDto, ResetPasswordDto, UpdatePasswordDto } from "./dto/password-reset.dto";
import { Response } from "express";
export declare class AuthController {
    private readonly authService;
    private readonly usersService;
    private readonly otpService;
    constructor(authService: AuthService, usersService: UsersService, otpService: OtpService);
    sendRegistrationOtp(req: any, dto: SendRegistrationOtpDto): Promise<{
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
    sendRegistrationCodes(req: any, dto: SendRegistrationOtpDto): Promise<{
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
    verifyRegistrationCodes(dto: VerifyRegistrationOtpDto): Promise<{
        success: boolean;
        verified: boolean;
        message: string;
        registrationToken: string;
    }>;
    sendProfileContactOtp(req: any, dto: SendProfileContactOtpDto): Promise<{
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
    verifyProfileContactOtp(req: any, dto: VerifyProfileContactOtpDto): Promise<{
        success: boolean;
        verified: boolean;
        isPhoneVerified: boolean;
        isEmailVerified: boolean;
        message: string;
    }>;
    register(dto: RegisterDto): Promise<any>;
    login(dto: LoginDto, res: Response): Promise<{
        message: string;
        user: {
            isVerified: boolean;
            hasProfile: boolean;
            profileStatus: string;
            status: import(".prisma/client").$Enums.Status;
            name: string | null;
            gender: import(".prisma/client").$Enums.Gender | null;
            id: string;
            isPhoneVerified: boolean;
            isEmailVerified: boolean;
            createdAt: Date;
            updatedAt: Date;
            email: string | null;
            phone: string | null;
            role: import(".prisma/client").$Enums.Role;
        };
        accessToken: string;
        tokenType: string;
        expiresIn: string;
    }>;
    logout(res: Response): Promise<{
        message: string;
    }>;
    getProfile(req: any): Promise<{
        isVerified: boolean;
        hasProfile: boolean;
        profileStatus: string;
        profileId: string;
        status: import(".prisma/client").$Enums.Status;
        name: string | null;
        gender: import(".prisma/client").$Enums.Gender | null;
        id: string;
        isPhoneVerified: boolean;
        isEmailVerified: boolean;
        createdAt: Date;
        updatedAt: Date;
        email: string | null;
        phone: string | null;
        role: import(".prisma/client").$Enums.Role;
    }>;
    forgotPassword(req: any, dto: ForgotPasswordDto): Promise<{
        success: boolean;
        message: string;
        target: string;
        maskedContact: string;
        channel: import(".prisma/client").$Enums.OtpChannel;
        expiresInSeconds: number;
        resendCooldownSeconds: number;
        maxAttempts: number;
    }>;
    verifyResetCode(dto: VerifyResetCodeDto): Promise<{
        success: boolean;
        verified: boolean;
        message: string;
        resetToken: string;
    }>;
    resetPassword(dto: ResetPasswordDto): Promise<{
        success: boolean;
        message: string;
    }>;
    changePassword(req: any, dto: UpdatePasswordDto): Promise<{
        success: boolean;
        message: string;
    }>;
    updatePassword(req: any, dto: UpdatePasswordDto): Promise<{
        success: boolean;
        message: string;
    }>;
    deleteMyAccount(req: any): Promise<{
        success: boolean;
        message: string;
    }>;
}
