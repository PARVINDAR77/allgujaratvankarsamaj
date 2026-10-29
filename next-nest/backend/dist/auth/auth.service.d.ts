import { ConfigService } from "@nestjs/config";
import { JwtService } from "@nestjs/jwt";
import { PrismaService } from "../prisma/prisma.service";
import { UsersService } from "../users/users.service";
import { OtpService } from "../otp/otp.service";
import { LoginDto } from "./dto/login.dto";
import { RegisterDto } from "./dto/register.dto";
import { ForgotPasswordDto, VerifyResetCodeDto, ResetPasswordDto, UpdatePasswordDto } from "./dto/password-reset.dto";
export declare class AuthService {
    private readonly usersService;
    private readonly jwtService;
    private readonly configService;
    private readonly prisma;
    private readonly otpService;
    private readonly logger;
    constructor(usersService: UsersService, jwtService: JwtService, configService: ConfigService, prisma: PrismaService, otpService: OtpService);
    register(dto: RegisterDto): Promise<any>;
    login(dto: LoginDto): Promise<{
        accessToken: string;
        user: {
            isVerified: boolean;
            hasProfile: boolean;
            profileStatus: import(".prisma/client").$Enums.ProfileStatus;
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
        tokenType: string;
        expiresIn: string;
    }>;
    forgotPassword(dto: ForgotPasswordDto, ipAddress?: string): Promise<{
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
    updatePassword(userId: string, dto: UpdatePasswordDto): Promise<{
        success: boolean;
        message: string;
    }>;
}
