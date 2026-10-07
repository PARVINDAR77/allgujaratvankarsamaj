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
var UsersService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.UsersService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const client_1 = require("@prisma/client");
const uuid_1 = require("uuid");
const normalize_profile_helper_1 = require("../profiles/dto/normalize-profile.helper");
let UsersService = UsersService_1 = class UsersService {
    constructor(prisma) {
        this.prisma = prisma;
        this.logger = new common_1.Logger(UsersService_1.name);
    }
    async findByEmail(email) {
        if (!email)
            return null;
        const normalized = email.toLowerCase().trim();
        return await this.prisma.user.findUnique({
            where: { email: normalized },
        });
    }
    async findByPhone(phone) {
        if (!phone)
            return null;
        return null;
    }
    async findById(id) {
        return await this.prisma.user.findUnique({
            where: { id },
        });
    }
    async createUser(data) {
        const normalizedEmail = data.email?.toLowerCase().trim() || `${(0, uuid_1.v4)()}@vankar.org`;
        const resolvedGender = (0, normalize_profile_helper_1.normalizeGender)(data.gender);
        const user = await this.prisma.user.create({
            data: {
                email: normalizedEmail,
                phone: data.phone,
                name: data.name,
                gender: resolvedGender,
                passwordHash: data.passwordHash,
                role: data.role || client_1.Role.USER,
                status: data.status || client_1.Status.ACTIVE,
            },
        });
        return user;
    }
    async getAllUsersForAdmin() {
        try {
            const users = await this.prisma.user.findMany({
                orderBy: { createdAt: "desc" },
                select: {
                    id: true,
                    name: true,
                    email: true,
                    phone: true,
                    status: true,
                    role: true,
                    createdAt: true,
                    profile: {
                        select: {
                            firstName: true,
                            lastName: true,
                            city: true,
                            nativePlace: true,
                        },
                    },
                },
            });
            return users.map((u) => ({
                id: u.id,
                name: u.name ||
                    (u.profile?.firstName
                        ? `${u.profile.firstName} ${u.profile.lastName || ""}`.trim()
                        : u.email || "Member"),
                email: u.email || "",
                phone: u.phone || "9876543210",
                pargana: u.profile?.city || u.profile?.nativePlace || "35 Pargana",
                status: u.status,
                role: u.role,
                createdAt: u.createdAt,
            }));
        }
        catch (err) {
            this.logger.error("Failed to query admin users with profiles, falling back to basic users", err);
            const basicUsers = await this.prisma.user.findMany({
                orderBy: { createdAt: "desc" },
                select: {
                    id: true,
                    name: true,
                    email: true,
                    phone: true,
                    status: true,
                    role: true,
                    createdAt: true,
                },
            });
            return basicUsers.map((u) => ({
                id: u.id,
                name: u.name || u.email || "Member",
                email: u.email || "",
                phone: u.phone || "9876543210",
                pargana: "35 Pargana",
                status: u.status,
                role: u.role,
                createdAt: u.createdAt,
            }));
        }
    }
    async updateUserStatusAdmin(userId, adminId, status, ipAddress) {
        if (!Object.values(client_1.Status).includes(status)) {
            throw new common_1.BadRequestException("Invalid status");
        }
        return this.prisma.$transaction(async (tx) => {
            const user = await tx.user.findUnique({ where: { id: userId } });
            if (!user)
                throw new common_1.NotFoundException("User not found");
            const updatedUser = await tx.user.update({
                where: { id: userId },
                data: { status },
            });
            await tx.adminAuditLog.create({
                data: {
                    adminId,
                    action: "UPDATE_USER_STATUS",
                    entityId: userId,
                    entityType: "User",
                    oldValue: JSON.stringify({ status: user.status }),
                    newValue: JSON.stringify({ status: updatedUser.status }),
                    ipAddress: ipAddress || null,
                },
            });
            return {
                id: updatedUser.id,
                status: updatedUser.status,
            };
        });
    }
    async updateUserRoleAdmin(userId, adminId, role, ipAddress) {
        if (!Object.values(client_1.Role).includes(role)) {
            throw new common_1.BadRequestException("Invalid role");
        }
        return this.prisma.$transaction(async (tx) => {
            const user = await tx.user.findUnique({ where: { id: userId } });
            if (!user)
                throw new common_1.NotFoundException("User not found");
            const updatedUser = await tx.user.update({
                where: { id: userId },
                data: { role },
            });
            await tx.adminAuditLog.create({
                data: {
                    adminId,
                    action: "UPDATE_USER_ROLE",
                    entityId: userId,
                    entityType: "User",
                    oldValue: JSON.stringify({ role: user.role }),
                    newValue: JSON.stringify({ role: updatedUser.role }),
                    ipAddress: ipAddress || null,
                },
            });
            return {
                id: updatedUser.id,
                role: updatedUser.role,
            };
        });
    }
    async getAllProfilesForAdmin() {
        try {
            const profiles = await this.prisma.matrimonialProfile.findMany({
                orderBy: { createdAt: "desc" },
                select: {
                    id: true,
                    userId: true,
                    firstName: true,
                    lastName: true,
                    dateOfBirth: true,
                    gender: true,
                    nativePlace: true,
                    city: true,
                    education: true,
                    occupation: true,
                    status: true,
                    isVerified: true,
                    isFeatured: true,
                    createdAt: true,
                    user: {
                        select: {
                            email: true,
                            phone: true,
                        },
                    },
                },
            });
            return profiles.map((p) => ({
                id: p.id,
                userId: p.userId,
                name: `${p.firstName} ${p.lastName || ""}`.trim(),
                age: p.dateOfBirth
                    ? new Date().getFullYear() - new Date(p.dateOfBirth).getFullYear()
                    : 26,
                gender: p.gender,
                pargana: p.nativePlace || "35 Pargana",
                city: p.city || "Ahmedabad",
                education: p.education || "Graduate",
                occupation: p.occupation || "Service",
                status: p.status || "PENDING",
                isVerified: p.isVerified,
                isFeatured: p.isFeatured,
                createdAt: p.createdAt,
            }));
        }
        catch (err) {
            this.logger.error("Failed to query admin matrimonial profiles", err);
            return [];
        }
    }
    async updateProfileStatusAdmin(profileId, adminId, status, ipAddress) {
        return this.prisma.$transaction(async (tx) => {
            const profile = await tx.matrimonialProfile.findUnique({
                where: { id: profileId },
            });
            if (!profile)
                throw new common_1.NotFoundException("Profile not found");
            const isApproved = status === "APPROVED" || status === "ACTIVE";
            const profileStatus = isApproved ? client_1.ProfileStatus.APPROVED : client_1.ProfileStatus.REJECTED;
            const updatedProfile = await tx.matrimonialProfile.update({
                where: { id: profileId },
                data: {
                    status: profileStatus,
                    isVerified: isApproved,
                },
            });
            await tx.verificationRequest.updateMany({
                where: { profileId, status: client_1.VerificationStatus.PENDING },
                data: {
                    status: isApproved ? client_1.VerificationStatus.VERIFIED : client_1.VerificationStatus.REJECTED,
                },
            });
            await tx.governmentEmployment.updateMany({
                where: { profileId },
                data: {
                    verificationStatus: isApproved ? "VERIFIED" : "REJECTED",
                    isActive: isApproved,
                },
            });
            await tx.adminAuditLog.create({
                data: {
                    adminId,
                    action: "UPDATE_PROFILE_STATUS",
                    entityId: profileId,
                    entityType: "MatrimonialProfile",
                    oldValue: JSON.stringify({ status: profile.status, isVerified: profile.isVerified }),
                    newValue: JSON.stringify({ status: updatedProfile.status, isVerified: updatedProfile.isVerified }),
                    ipAddress: ipAddress || null,
                },
            });
            return { id: profileId, status: updatedProfile.status, isVerified: updatedProfile.isVerified };
        });
    }
    async toggleProfileFeaturedAdmin(profileId, adminId, isFeatured, ipAddress) {
        return this.prisma.$transaction(async (tx) => {
            const profile = await tx.matrimonialProfile.findUnique({
                where: { id: profileId },
            });
            if (!profile)
                throw new common_1.NotFoundException("Profile not found");
            const updatedProfile = await tx.matrimonialProfile.update({
                where: { id: profileId },
                data: { isFeatured },
            });
            await tx.governmentEmployment.updateMany({
                where: { profileId },
                data: { isFeatured },
            });
            await tx.adminAuditLog.create({
                data: {
                    adminId,
                    action: "TOGGLE_PROFILE_FEATURED",
                    entityId: profileId,
                    entityType: "MatrimonialProfile",
                    oldValue: JSON.stringify({ isFeatured: profile.isFeatured }),
                    newValue: JSON.stringify({ isFeatured: updatedProfile.isFeatured }),
                    ipAddress: ipAddress || null,
                },
            });
            return { id: profileId, isFeatured: updatedProfile.isFeatured };
        });
    }
};
exports.UsersService = UsersService;
exports.UsersService = UsersService = UsersService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], UsersService);
//# sourceMappingURL=users.service.js.map