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
exports.normalizePhoneNumber = normalizePhoneNumber;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const client_1 = require("@prisma/client");
const uuid_1 = require("uuid");
const normalize_profile_helper_1 = require("../profiles/dto/normalize-profile.helper");
function normalizePhoneNumber(phone) {
    if (!phone || typeof phone !== "string") {
        return { isValid: false, variants: [] };
    }
    const trimmed = phone.trim();
    if (!trimmed) {
        return { isValid: false, variants: [] };
    }
    const digitsOnly = trimmed.replace(/\D/g, "");
    if (digitsOnly.length === 10) {
        return {
            isValid: true,
            canonical10: digitsOnly,
            variants: [digitsOnly, `+91${digitsOnly}`, `91${digitsOnly}`],
        };
    }
    if (digitsOnly.length === 12 && digitsOnly.startsWith("91")) {
        const tenDigit = digitsOnly.slice(2);
        return {
            isValid: true,
            canonical10: tenDigit,
            variants: [tenDigit, `+91${tenDigit}`, `91${tenDigit}`],
        };
    }
    return { isValid: false, variants: [] };
}
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
        const norm = normalizePhoneNumber(phone);
        if (!norm.isValid || norm.variants.length === 0) {
            return null;
        }
        const matches = await this.prisma.user.findMany({
            where: {
                phone: { in: norm.variants },
            },
            take: 2,
        });
        if (matches.length === 0) {
            return null;
        }
        if (matches.length > 1) {
            this.logger.error(`Ambiguous phone lookup detected for input: "${phone}". Multiple user records match variants: [${norm.variants.join(", ")}]. Failing safely.`);
            return null;
        }
        return matches[0];
    }
    async findById(id) {
        return await this.prisma.user.findUnique({
            where: { id },
        });
    }
    async createUser(data) {
        const normalizedEmail = data.email?.toLowerCase().trim() || `${(0, uuid_1.v4)()}@vankar.org`;
        const resolvedGender = (0, normalize_profile_helper_1.normalizeGender)(data.gender);
        try {
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
        catch (err) {
            if (err.code === "P2002") {
                throw new common_1.ConflictException("આ ઈમેઈલ અથવા મોબાઇલ નંબર પહેલેથી જ નોંધાયેલ છે (Email or mobile number is already registered)");
            }
            throw err;
        }
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
            const user = await tx.user.findUnique({
                where: { id: userId },
                include: { profile: true },
            });
            if (!user)
                throw new common_1.NotFoundException("User not found");
            const updatedUser = await tx.user.update({
                where: { id: userId },
                data: { status },
            });
            if (status === client_1.Status.INACTIVE) {
                await tx.matrimonialProfile.updateMany({
                    where: { userId },
                    data: {
                        status: client_1.ProfileStatus.SUSPENDED,
                        showInMatrimony: false,
                        isVerified: false,
                    },
                });
                const profileId = user.profile?.id;
                if (profileId) {
                    await tx.governmentEmployment.updateMany({
                        where: { profileId },
                        data: { isActive: false, isFeatured: false },
                    });
                }
            }
            else if (status === client_1.Status.ACTIVE) {
                await tx.matrimonialProfile.updateMany({
                    where: { userId },
                    data: {
                        status: client_1.ProfileStatus.APPROVED,
                        showInMatrimony: true,
                        isVerified: true,
                    },
                });
                const profileId = user.profile?.id;
                if (profileId) {
                    await tx.governmentEmployment.updateMany({
                        where: { profileId },
                        data: { isActive: true },
                    });
                }
            }
            await tx.adminAuditLog.create({
                data: {
                    adminId,
                    action: status === client_1.Status.INACTIVE ? "SUSPEND_USER_ACCOUNT" : "ACTIVATE_USER_ACCOUNT",
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
                    photoUrl: true,
                    photos: true,
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
                    verificationRequests: {
                        orderBy: { createdAt: "desc" },
                        take: 1,
                        select: {
                            id: true,
                            documentType: true,
                            documentUrl: true,
                            documentBackUrl: true,
                            status: true,
                            createdAt: true,
                        },
                    },
                },
            });
            return profiles.map((p) => {
                let parsedPhotos = [];
                if (p.photos) {
                    try {
                        parsedPhotos = JSON.parse(p.photos);
                    }
                    catch (_) {
                        parsedPhotos = [p.photos];
                    }
                }
                else if (p.photoUrl) {
                    parsedPhotos = [p.photoUrl];
                }
                return {
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
                    photoUrl: p.photoUrl,
                    photos: parsedPhotos,
                    verification: p.verificationRequests && p.verificationRequests[0]
                        ? p.verificationRequests[0]
                        : null,
                    user: p.user,
                    status: p.status || "PENDING",
                    isVerified: p.isVerified,
                    isFeatured: p.isFeatured,
                    createdAt: p.createdAt,
                };
            });
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
            let profileStatus;
            let isVerified = false;
            let showInMatrimony = false;
            let userStatus = client_1.Status.ACTIVE;
            if (status === "APPROVED" || status === "ACTIVE") {
                profileStatus = client_1.ProfileStatus.APPROVED;
                isVerified = true;
                showInMatrimony = true;
                userStatus = client_1.Status.ACTIVE;
            }
            else if (status === "SUSPENDED" || status === "INACTIVE") {
                profileStatus = client_1.ProfileStatus.SUSPENDED;
                isVerified = false;
                showInMatrimony = false;
                userStatus = client_1.Status.INACTIVE;
            }
            else {
                profileStatus = client_1.ProfileStatus.REJECTED;
                isVerified = false;
                showInMatrimony = false;
                userStatus = client_1.Status.ACTIVE;
            }
            const updatedProfile = await tx.matrimonialProfile.update({
                where: { id: profileId },
                data: {
                    status: profileStatus,
                    isVerified,
                    showInMatrimony,
                },
            });
            if (profile.userId) {
                await tx.user.update({
                    where: { id: profile.userId },
                    data: { status: userStatus },
                });
            }
            await tx.verificationRequest.updateMany({
                where: { profileId, status: client_1.VerificationStatus.PENDING },
                data: {
                    status: isVerified ? client_1.VerificationStatus.VERIFIED : client_1.VerificationStatus.REJECTED,
                },
            });
            await tx.governmentEmployment.updateMany({
                where: { profileId },
                data: {
                    verificationStatus: isVerified ? "VERIFIED" : "REJECTED",
                    isActive: isVerified,
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
    async deleteUserAccount(userId, deletedByAdminId, ipAddress) {
        return this.prisma.$transaction(async (tx) => {
            const user = await tx.user.findUnique({
                where: { id: userId },
                include: { profile: true },
            });
            if (!user) {
                throw new common_1.NotFoundException("વપરાશકર્તા મળ્યો નથી (User not found)");
            }
            if (deletedByAdminId && deletedByAdminId === userId) {
                throw new common_1.BadRequestException("એડમિન પોતાનું એકાઉન્ટ ડિલીટ કરી શકતા નથી (Super Admin cannot delete their own account)");
            }
            if (user.email === "admin@vankarsamaj.org" ||
                user.email === "admin@vankarsamaj.com") {
                throw new common_1.BadRequestException("રૂટ સિસ્ટમ એડમિન એકાઉન્ટ ડિલીટ કરી શકાતું નથી (Root System Administrator cannot be deleted)");
            }
            const profile = user.profile || (await tx.matrimonialProfile.findUnique({ where: { userId } }));
            const profileId = profile?.id;
            if (profileId) {
                await tx.verificationRequest.deleteMany({
                    where: { profileId },
                });
                const govtList = await tx.governmentEmployment.findMany({
                    where: { profileId },
                    select: { id: true },
                });
                const govtIds = govtList.map((g) => g.id);
                if (govtIds.length > 0) {
                    await tx.governmentEmploymentVerification.deleteMany({
                        where: { employmentId: { in: govtIds } },
                    });
                    await tx.governmentEmployment.deleteMany({
                        where: { id: { in: govtIds } },
                    });
                }
                await tx.matchInterest.deleteMany({
                    where: {
                        OR: [
                            { senderProfileId: profileId },
                            { receiverProfileId: profileId },
                        ],
                    },
                });
                await tx.shortlist.deleteMany({
                    where: { targetProfileId: profileId },
                });
                await tx.report.deleteMany({
                    where: { targetProfileId: profileId },
                });
                await tx.matrimonialProfile.deleteMany({
                    where: { id: profileId },
                });
            }
            await tx.shortlist.deleteMany({
                where: { userId },
            });
            await tx.userNotification.deleteMany({
                where: { userId },
            });
            const conversations = await tx.chatConversation.findMany({
                where: {
                    OR: [{ participant1Id: userId }, { participant2Id: userId }],
                },
                select: { id: true },
            });
            const convIds = conversations.map((c) => c.id);
            if (convIds.length > 0) {
                await tx.chatMessage.deleteMany({
                    where: { conversationId: { in: convIds } },
                });
                await tx.chatConversation.deleteMany({
                    where: { id: { in: convIds } },
                });
            }
            await tx.chatMessage.deleteMany({
                where: {
                    OR: [{ senderId: userId }, { receiverId: userId }],
                },
            });
            await tx.report.deleteMany({
                where: { reporterUserId: userId },
            });
            await tx.samajServicePerson.deleteMany({
                where: { userId },
            });
            await tx.advertisement.updateMany({
                where: { createdBy: userId },
                data: { createdBy: null },
            });
            if (deletedByAdminId) {
                await tx.adminAuditLog.create({
                    data: {
                        adminId: deletedByAdminId,
                        action: "DELETE_USER_ACCOUNT",
                        entityId: userId,
                        entityType: "User",
                        oldValue: JSON.stringify({
                            id: user.id,
                            email: user.email,
                            phone: user.phone,
                            name: user.name,
                            role: user.role,
                        }),
                        newValue: null,
                        ipAddress: ipAddress || null,
                    },
                });
            }
            await tx.user.delete({
                where: { id: userId },
            });
            return {
                success: true,
                message: "વપરાશકર્તા એકાઉન્ટ અને તમામ ડેટા કાયમ માટે કાઢી નાખવામાં આવ્યા છે (User account and all data deleted permanently)",
            };
        });
    }
    async deleteProfileAdmin(profileIdOrUserId, adminId, ipAddress) {
        return this.prisma.$transaction(async (tx) => {
            let profile = await tx.matrimonialProfile.findUnique({
                where: { id: profileIdOrUserId },
            });
            if (!profile) {
                profile = await tx.matrimonialProfile.findUnique({
                    where: { userId: profileIdOrUserId },
                });
            }
            if (!profile) {
                throw new common_1.NotFoundException("પ્રોફાઇલ મળી નથી (Profile not found)");
            }
            const profileId = profile.id;
            await tx.verificationRequest.deleteMany({ where: { profileId } });
            const govtList = await tx.governmentEmployment.findMany({
                where: { profileId },
                select: { id: true },
            });
            const govtIds = govtList.map((g) => g.id);
            if (govtIds.length > 0) {
                await tx.governmentEmploymentVerification.deleteMany({
                    where: { employmentId: { in: govtIds } },
                });
                await tx.governmentEmployment.deleteMany({
                    where: { id: { in: govtIds } },
                });
            }
            await tx.matchInterest.deleteMany({
                where: {
                    OR: [
                        { senderProfileId: profileId },
                        { receiverProfileId: profileId },
                    ],
                },
            });
            await tx.shortlist.deleteMany({ where: { targetProfileId: profileId } });
            await tx.report.deleteMany({ where: { targetProfileId: profileId } });
            await tx.matrimonialProfile.deleteMany({ where: { id: profileId } });
            await tx.adminAuditLog.create({
                data: {
                    adminId,
                    action: "DELETE_PROFILE",
                    entityId: profileId,
                    entityType: "MatrimonialProfile",
                    oldValue: JSON.stringify({
                        id: profile.id,
                        userId: profile.userId,
                        name: `${profile.firstName} ${profile.lastName}`,
                    }),
                    newValue: null,
                    ipAddress: ipAddress || null,
                },
            });
            return {
                success: true,
                message: "મેટ્રિમોનિયલ પ્રોફાઇલ સફળતાપૂર્વક કાઢી નાખવામાં આવી છે (Matrimonial profile deleted successfully)",
            };
        });
    }
};
exports.UsersService = UsersService;
exports.UsersService = UsersService = UsersService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], UsersService);
//# sourceMappingURL=users.service.js.map