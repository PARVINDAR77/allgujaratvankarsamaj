import { AuthService } from "./auth.service";
import { UsersService } from "../users/users.service";
import { OtpService } from "../otp/otp.service";
import { SendRegistrationOtpDto, VerifyRegistrationOtpDto } from "../otp/dto/otp.dto";
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
    register(dto: RegisterDto): Promise<{
        isVerified: boolean;
        hasProfile: boolean;
        profileStatus: string;
        status: import(".prisma/client").$Enums.Status;
        name: string | null;
        gender: import(".prisma/client").$Enums.Gender | null;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        email: string | null;
        phone: string | null;
        role: import(".prisma/client").$Enums.Role;
        isEmailVerified: boolean;
        isPhoneVerified: boolean;
    }>;
    login(dto: LoginDto, res: Response): Promise<{
        message: string;
        user: {
            isVerified: boolean;
            hasProfile: boolean;
            profileStatus: import(".prisma/client").$Enums.ProfileStatus;
            status: import(".prisma/client").$Enums.Status;
            name: string | null;
            gender: import(".prisma/client").$Enums.Gender | null;
            id: string;
            createdAt: Date;
            updatedAt: Date;
            email: string | null;
            phone: string | null;
            role: import(".prisma/client").$Enums.Role;
            isEmailVerified: boolean;
            isPhoneVerified: boolean;
        };
        accessToken: string;
        tokenType: string;
        expiresIn: string;
    }>;
    logout(res: Response): Promise<{
        message: string;
    }>;
    getProfile(req: any): Promise<any>;
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
