import { AuthService } from "./auth.service";
import { UsersService } from "../users/users.service";
import { LoginDto } from "./dto/login.dto";
import { RegisterDto } from "./dto/register.dto";
import { ForgotPasswordDto, VerifyResetCodeDto, ResetPasswordDto, UpdatePasswordDto } from "./dto/password-reset.dto";
import { Response } from "express";
export declare class AuthController {
    private readonly authService;
    private readonly usersService;
    constructor(authService: AuthService, usersService: UsersService);
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
    login(dto: LoginDto, res: Response): Promise<{
        message: string;
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
        accessToken: string;
        tokenType: string;
        expiresIn: string;
    }>;
    logout(res: Response): Promise<{
        message: string;
    }>;
    getProfile(req: any): Promise<any>;
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
