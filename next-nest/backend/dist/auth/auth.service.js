"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var AuthService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const jwt_1 = require("@nestjs/jwt");
const bcrypt = require("bcrypt");
const client_1 = require("@prisma/client");
const prisma_service_1 = require("../prisma/prisma.service");
const users_service_1 = require("../users/users.service");
const otp_service_1 = require("../otp/otp.service");
let AuthService = AuthService_1 = class AuthService {
    constructor(usersService, jwtService, configService, prisma, otpService) {
        this.usersService = usersService;
        this.jwtService = jwtService;
        this.configService = configService;
        this.prisma = prisma;
        this.otpService = otpService;
        this.logger = new common_1.Logger(AuthService_1.name);
    }
    async register(dto) {
        let isEmailVerified = false;
        let isPhoneVerified = false;
        if (dto.registrationToken) {
            const isValid = await this.otpService.consumeRegistrationToken(dto.registrationToken, dto.phone || "", dto.email || "");
            if (!isValid) {
                throw new common_1.BadRequestException("અમાન્ય અથવા સમાપ્ત થયેલ ચકાસણી ટોકન. કૃપા કરીને ફરીથી ચકાસણી કરો (Invalid or expired verification token. Please verify again.)");
            }
            isEmailVerified = true;
            isPhoneVerified = true;
        }
        if (dto.email) {
            const cleanEmail = dto.email.trim().toLowerCase();
            const existingByEmail = await this.usersService.findByEmail(cleanEmail);
            if (existingByEmail) {
                throw new common_1.ConflictException("આ ઈમેઈલ સરનામું પહેલેથી જ વપરાયેલ છે. ઉમેદવાર માત્ર એક જ વાર ઈમેઈલનો ઉપયોગ કરી શકે છે. (This email is already registered. Candidates can use their email only once.)");
            }
            const existingProfileEmail = await this.prisma.matrimonialProfile.findFirst({
                where: { contactEmail: cleanEmail },
            });
            if (existingProfileEmail) {
                throw new common_1.ConflictException("આ ઈમેઈલ અન્ય ઉમેદવાર દ્વારા પહેલેથી જ વપરાયેલ છે. ઉમેદવાર માત્ર એક જ વાર ઈમેઈલનો ઉપયોગ કરી શકે છે. (This email is already in use by another candidate. Candidates can use their email only once.)");
            }
        }
        if (dto.phone) {
            const cleanPhone = dto.phone.trim();
            const existingByPhone = await this.usersService.findByPhone(cleanPhone);
            if (existingByPhone) {
                throw new common_1.ConflictException("આ મોબાઇલ નંબર પહેલેથી જ નોંધાયેલ છે. (This mobile number is already registered.)");
            }
        }
        const saltRounds = 10;
        const passwordHash = await bcrypt.hash(dto.password, saltRounds);
        const user = await this.usersService.createUser({
            email: dto.email,
            phone: dto.phone,
            name: dto.name,
            gender: dto.gender,
            passwordHash,
            isEmailVerified,
            isPhoneVerified,
        });
        const { passwordHash: _, ...safeUser } = user;
        return {
            ...safeUser,
            isVerified: false,
            hasProfile: false,
            profileStatus: "NOT_CREATED",
        };
    }
    async login(dto) {
        let user = dto.phone
            ? await this.usersService.findByPhone(dto.phone)
            : null;
        if (!user && dto.email) {
            user = await this.usersService.findByEmail(dto.email);
        }
        if (!user) {
            throw new common_1.UnauthorizedException("અમાન્ય ઓળખપત્ર (Invalid email/phone or password)");
        }
        const isPasswordValid = await bcrypt.compare(dto.password, user.passwordHash);
        if (!isPasswordValid) {
            throw new common_1.UnauthorizedException("અમાન્ય ઓળખપત્ર (Invalid email/phone or password)");
        }
        if (user.status !== "ACTIVE") {
            throw new common_1.UnauthorizedException("આ એકાઉન્ટ નિષ્ક્રિય છે (Account is deactivated)");
        }
        const profile = await this.prisma.matrimonialProfile.findUnique({
            where: { userId: user.id },
        });
        const isStub = profile &&
            profile.firstName === "User" &&
            profile.lastName === "Member" &&
            !profile.religion &&
            !profile.education &&
            !profile.caste;
        const hasProfile = profile !== null && !isStub;
        const isVerified = hasProfile &&
            profile?.isVerified === true &&
            profile?.status === client_1.ProfileStatus.APPROVED;
        const payload = {
            sub: user.id,
            email: user.email,
            role: user.role,
            isVerified,
            hasProfile,
        };
        const expiresIn = this.configService.get("JWT_EXPIRES_IN", "1d");
        const accessToken = this.jwtService.sign(payload);
        const { passwordHash: _, ...safeUser } = user;
        return {
            accessToken,
            user: {
                ...safeUser,
                isVerified,
                hasProfile,
                profileStatus: profile?.status ?? "PENDING",
            },
            tokenType: "Bearer",
            expiresIn,
        };
    }
    async forgotPassword(dto, ipAddress) {
        return this.otpService.sendForgotPasswordOtp({ identifier: dto.identifier }, ipAddress);
    }
    async verifyResetCode(dto) {
        return this.otpService.verifyResetOtp({
            identifier: dto.identifier,
            code: dto.code,
        });
    }
    async resetPassword(dto) {
        if (!dto.newPassword || dto.newPassword.length < 6) {
            throw new common_1.BadRequestException("પાસવર્ડ ઓછામાં ઓછા 6 અક્ષરોનો હોવો જોઈએ (Password must be at least 6 characters)");
        }
        const rawIdentifier = dto.identifier.trim();
        let user = await this.usersService.findByPhone(rawIdentifier);
        if (!user) {
            user = await this.usersService.findByEmail(rawIdentifier.toLowerCase());
        }
        if (!user) {
            throw new common_1.NotFoundException("આ ઈમેઈલ અથવા મોબાઇલ નંબર સાથે કોઈ એકાઉન્ટ મળ્યું નથી (No account found with this email or mobile number)");
        }
        const isTokenConsumed = await this.otpService.consumeResetToken(rawIdentifier, dto.code);
        if (!isTokenConsumed) {
            const verifyRes = await this.otpService.verifyResetOtp({
                identifier: rawIdentifier,
                code: dto.code,
            });
            if (!verifyRes?.success) {
                throw new common_1.BadRequestException("અમાન્ય અથવા સમાપ્ત થયેલ ચકાસણી કોડ (Invalid or expired verification code)");
            }
            await this.otpService.consumeResetToken(rawIdentifier, verifyRes.resetToken);
        }
        const saltRounds = 10;
        const passwordHash = await bcrypt.hash(dto.newPassword, saltRounds);
        await this.prisma.user.update({
            where: { id: user.id },
            data: { passwordHash },
        });
        return {
            success: true,
            message: "તમારો પાસવર્ડ સફળતાપૂર્વક બદલાઈ ગયો છે. હવે તમે નવા પાસવર્ડથી લોગિન કરી શકો છો (Password has been reset successfully. You can now login.)",
        };
    }
    async updatePassword(userId, dto) {
        const user = await this.prisma.user.findUnique({
            where: { id: userId },
        });
        if (!user) {
            throw new common_1.NotFoundException("વપરાશકર્તા મળ્યા નથી (User not found)");
        }
        const isCurrentValid = await bcrypt.compare(dto.currentPassword, user.passwordHash);
        if (!isCurrentValid) {
            throw new common_1.BadRequestException("હાલનો પાસવર્ડ ખોટો છે (Current password is incorrect)");
        }
        if (dto.newPassword.length < 6) {
            throw new common_1.BadRequestException("નવો પાસવર્ડ ઓછામાં ઓછા 6 અક્ષરોનો હોવો જોઈએ (New password must be at least 6 characters)");
        }
        const saltRounds = 10;
        const passwordHash = await bcrypt.hash(dto.newPassword, saltRounds);
        await this.prisma.user.update({
            where: { id: userId },
            data: { passwordHash },
        });
        return {
            success: true,
            message: "પાસવર્ડ સફળતાપૂર્વક અપડેટ થયો છે (Password has been updated successfully)",
        };
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = AuthService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [users_service_1.UsersService,
        jwt_1.JwtService,
        config_1.ConfigService,
        prisma_service_1.PrismaService,
        otp_service_1.OtpService])
], AuthService);
//# sourceMappingURL=auth.service.js.map