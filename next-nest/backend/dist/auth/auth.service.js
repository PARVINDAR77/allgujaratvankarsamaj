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
let AuthService = AuthService_1 = class AuthService {
    constructor(usersService, jwtService, configService, prisma) {
        this.usersService = usersService;
        this.jwtService = jwtService;
        this.configService = configService;
        this.prisma = prisma;
        this.logger = new common_1.Logger(AuthService_1.name);
        this.resetCodes = new Map();
    }
    async register(dto) {
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
    async forgotPassword(dto) {
        const rawIdentifier = dto.identifier.trim();
        if (!rawIdentifier) {
            throw new common_1.BadRequestException("ઈમેઈલ અથવા મોબાઇલ નંબર દાખલ કરો (Please enter email or mobile number)");
        }
        let user = await this.usersService.findByPhone(rawIdentifier);
        if (!user) {
            user = await this.usersService.findByEmail(rawIdentifier);
        }
        if (!user) {
            throw new common_1.NotFoundException("આ ઈમેઈલ અથવા મોબાઇલ નંબર સાથે કોઈ એકાઉન્ટ મળ્યું નથી (No account found with this email or mobile number)");
        }
        const code = Math.floor(100000 + Math.random() * 900000).toString();
        const expiresAt = Date.now() + 15 * 60 * 1000;
        const normKey = user.email?.toLowerCase().trim() ||
            user.phone?.trim() ||
            rawIdentifier.toLowerCase();
        this.resetCodes.set(normKey, {
            code,
            userId: user.id,
            expiresAt,
            attempts: 0,
        });
        this.resetCodes.set(rawIdentifier.toLowerCase(), {
            code,
            userId: user.id,
            expiresAt,
            attempts: 0,
        });
        if (user.phone) {
            this.resetCodes.set(user.phone.trim(), {
                code,
                userId: user.id,
                expiresAt,
                attempts: 0,
            });
        }
        this.logger.log(`Password reset code for user ${user.id} (${user.email || user.phone}): ${code}`);
        let masked = "";
        if (user.phone && user.phone.length >= 10) {
            masked = `${user.phone.slice(0, 2)}******${user.phone.slice(-2)}`;
        }
        else if (user.email && user.email.includes("@")) {
            const [local, dom] = user.email.split("@");
            masked = `${local.slice(0, 2)}***@${dom}`;
        }
        else {
            masked = "તમારો નોંધાયેલ સંપર્ક";
        }
        return {
            success: true,
            message: `પાસવર્ડ રીસેટ કોડ મોકલવામાં આવ્યો છે (${masked})`,
            identifier: rawIdentifier,
            maskedContact: masked,
            code,
        };
    }
    async verifyResetCode(dto) {
        const rawIdentifier = dto.identifier.trim().toLowerCase();
        const entry = this.resetCodes.get(rawIdentifier);
        if (!entry) {
            throw new common_1.BadRequestException("કોઈ સક્રિય રીસેટ વિનંતી મળી નથી. કૃપા કરીને ફરીથી પ્રયાસ કરો (No active reset request found. Please request again.)");
        }
        if (Date.now() > entry.expiresAt) {
            this.resetCodes.delete(rawIdentifier);
            throw new common_1.BadRequestException("ચકાસણી કોડની સમયસીમા સમાપ્ત થઈ ગઈ છે (Verification code has expired. Please request a new one.)");
        }
        if (entry.code !== dto.code.trim()) {
            entry.attempts += 1;
            if (entry.attempts >= 5) {
                this.resetCodes.delete(rawIdentifier);
                throw new common_1.BadRequestException("ખૂબ ખોટા પ્રયાસો. કૃપા કરીને નવો કોડ મેળવો (Too many invalid attempts. Please request a new code.)");
            }
            throw new common_1.BadRequestException("અમાન્ય ચકાસણી કોડ (Invalid verification code)");
        }
        return {
            success: true,
            message: "ચકાસણી સફળ (Verification successful)",
        };
    }
    async resetPassword(dto) {
        const rawIdentifier = dto.identifier.trim().toLowerCase();
        const entry = this.resetCodes.get(rawIdentifier);
        if (!entry) {
            throw new common_1.BadRequestException("કોઈ સક્રિય રીસેટ વિનંતી મળી નથી. કૃપા કરીને ફરીથી પ્રયાસ કરો (No active reset request found. Please request again.)");
        }
        if (Date.now() > entry.expiresAt) {
            this.resetCodes.delete(rawIdentifier);
            throw new common_1.BadRequestException("ચકાસણી કોડની સમયસીમા સમાપ્ત થઈ ગઈ છે (Verification code has expired)");
        }
        if (entry.code !== dto.code.trim()) {
            throw new common_1.BadRequestException("અમાન્ય ચકાસણી કોડ (Invalid verification code)");
        }
        if (!dto.newPassword || dto.newPassword.length < 6) {
            throw new common_1.BadRequestException("પાસવર્ડ ઓછામાં ઓછા 6 અક્ષરોનો હોવો જોઈએ (Password must be at least 6 characters)");
        }
        const saltRounds = 10;
        const passwordHash = await bcrypt.hash(dto.newPassword, saltRounds);
        await this.prisma.user.update({
            where: { id: entry.userId },
            data: { passwordHash },
        });
        this.resetCodes.delete(rawIdentifier);
        return {
            success: true,
            message: "તમારો પાસવર્ડ સફળતાપૂર્વક બદલાઈ ગયો છે. હવે તમે નવા પાસવર્ડથી લોગિન કરી શકો છો (Password has been reset successfully. You can now login.)",
        };
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = AuthService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [users_service_1.UsersService,
        jwt_1.JwtService,
        config_1.ConfigService,
        prisma_service_1.PrismaService])
], AuthService);
//# sourceMappingURL=auth.service.js.map