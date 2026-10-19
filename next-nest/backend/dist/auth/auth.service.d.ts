import { ConfigService } from "@nestjs/config";
import { JwtService } from "@nestjs/jwt";
import { PrismaService } from "../prisma/prisma.service";
import { UsersService } from "../users/users.service";
import { LoginDto } from "./dto/login.dto";
import { RegisterDto } from "./dto/register.dto";
import { ForgotPasswordDto, VerifyResetCodeDto, ResetPasswordDto, UpdatePasswordDto } from "./dto/password-reset.dto";
export declare class AuthService {
    private readonly usersService;
    private readonly jwtService;
    private readonly configService;
    private readonly prisma;
    private readonly logger;
    private resetCodes;
    constructor(usersService: UsersService, jwtService: JwtService, configService: ConfigService, prisma: PrismaService);
    register(dto: RegisterDto): Promise<{
        isVerified: boolean;
        hasProfile: boolean;
        profileStatus: string;
        status: import(".prisma/client").$Enums.Status;
        name: string | null;
        id: string;
        email: string | null;
        phone: string | null;
        gender: import(".prisma/client").$Enums.Gender | null;
        role: import(".prisma/client").$Enums.Role;
        createdAt: Date;
        updatedAt: Date;
    }>;
    login(dto: LoginDto): Promise<{
        accessToken: string;
        user: {
            isVerified: boolean;
            hasProfile: boolean;
            profileStatus: import(".prisma/client").$Enums.ProfileStatus;
            status: import(".prisma/client").$Enums.Status;
            name: string | null;
            id: string;
            email: string | null;
            phone: string | null;
            gender: import(".prisma/client").$Enums.Gender | null;
            role: import(".prisma/client").$Enums.Role;
            createdAt: Date;
            updatedAt: Date;
        };
        tokenType: string;
        expiresIn: string;
    }>;
    forgotPassword(dto: ForgotPasswordDto): Promise<{
        success: boolean;
        message: string;
        identifier: string;
        maskedContact: string;
        code: string;
    }>;
    verifyResetCode(dto: VerifyResetCodeDto): Promise<{
        success: boolean;
        message: string;
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
