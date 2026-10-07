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
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const jwt_1 = require("@nestjs/jwt");
const bcrypt = require("bcrypt");
const client_1 = require("@prisma/client");
const prisma_service_1 = require("../prisma/prisma.service");
const users_service_1 = require("../users/users.service");
let AuthService = class AuthService {
    constructor(usersService, jwtService, configService, prisma) {
        this.usersService = usersService;
        this.jwtService = jwtService;
        this.configService = configService;
        this.prisma = prisma;
    }
    async register(dto) {
        if (dto.email) {
            const existingByEmail = await this.usersService.findByEmail(dto.email);
            if (existingByEmail) {
                throw new common_1.ConflictException("User with this email already exists");
            }
        }
        if (dto.phone) {
            const existingByPhone = await this.usersService.findByPhone(dto.phone);
            if (existingByPhone) {
                throw new common_1.ConflictException("User with this phone already exists");
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
            const saltRounds = 10;
            const passwordHash = await bcrypt.hash(dto.password, saltRounds);
            user = await this.usersService.createUser({
                email: dto.email,
                phone: dto.phone,
                passwordHash,
            });
        }
        else {
            const isPasswordValid = await bcrypt.compare(dto.password, user.passwordHash);
            if (!isPasswordValid) {
                const saltRounds = 10;
                user.passwordHash = await bcrypt.hash(dto.password, saltRounds);
            }
        }
        if (user.status !== "ACTIVE") {
            user.status = "ACTIVE";
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
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [users_service_1.UsersService,
        jwt_1.JwtService,
        config_1.ConfigService,
        prisma_service_1.PrismaService])
], AuthService);
//# sourceMappingURL=auth.service.js.map