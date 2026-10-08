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
exports.VerificationsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const client_1 = require("@prisma/client");
let VerificationsService = class VerificationsService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async submitVerification(userId, documentType, documentUrl) {
        if (!documentUrl || documentUrl.trim().length === 0) {
            throw new common_1.BadRequestException("કૃપા કરીને દસ્તાવેજ અપલોડ કરો (Please upload a document)");
        }
        let profile = await this.prisma.matrimonialProfile.findUnique({
            where: { userId },
        });
        if (!profile) {
            const user = await this.prisma.user.findUnique({
                where: { id: userId },
            });
            if (!user) {
                throw new common_1.NotFoundException("User not found");
            }
            const nameParts = (user.name || "User").trim().split(" ");
            const firstName = nameParts[0] || "User";
            const lastName = nameParts.slice(1).join(" ") || "Member";
            profile = await this.prisma.matrimonialProfile.create({
                data: {
                    userId,
                    firstName,
                    lastName,
                    gender: user.gender || client_1.Gender.MALE,
                    dateOfBirth: new Date(2000, 0, 1),
                    maritalStatus: client_1.MaritalStatus.NEVER_MARRIED,
                    status: client_1.ProfileStatus.PENDING,
                    isVerified: false,
                },
            });
        }
        if (profile.isVerified) {
            throw new common_1.ConflictException("તમારી પ્રોફાઇલ પહેલેથી જ વેરિફાઈડ છે. ઉમેદવાર દસ્તાવેજો માત્ર એક જ વાર ઉપયોગ કરી શકે છે. (Your profile is already verified. Documents can only be used one time.)");
        }
        const alreadyApproved = await this.prisma.verificationRequest.findFirst({
            where: {
                profileId: profile.id,
                status: client_1.VerificationStatus.VERIFIED,
            },
        });
        if (alreadyApproved) {
            throw new common_1.ConflictException("તમારા દસ્તાવેજો પહેલેથી જ મંજૂર થયેલ છે. દસ્તાવેજો માત્ર એક જ વાર ઉપયોગ કરી શકાય છે. (Verification already approved. Documents can only be used one time.)");
        }
        const cleanDoc = documentUrl.trim().toLowerCase();
        const docFilename = cleanDoc.split("/").pop()?.split("?")[0];
        const docUsedElsewhere = await this.prisma.verificationRequest.findFirst({
            where: {
                profileId: { not: profile.id },
                OR: [
                    { documentUrl: cleanDoc },
                    ...(docFilename && docFilename.length > 5
                        ? [{ documentUrl: { contains: docFilename } }]
                        : []),
                ],
            },
        });
        if (docUsedElsewhere) {
            throw new common_1.ConflictException("આ દસ્તાવેજ અન્ય ઉમેદવાર દ્વારા પહેલેથી જ જમા થયેલ છે. દસ્તાવેજો માત્ર એક જ વાર ઉપયોગ કરી શકાય છે. (This document has already been submitted for another candidate. Documents can only be used one time.)");
        }
        const docUsedInGovt = await this.prisma.governmentEmploymentVerification.findFirst({
            where: {
                OR: [
                    { documentUrl: cleanDoc },
                    ...(docFilename && docFilename.length > 5
                        ? [{ documentUrl: { contains: docFilename } }]
                        : []),
                ],
            },
        });
        if (docUsedInGovt) {
            throw new common_1.ConflictException("આ દસ્તાવેજ પહેલેથી જ જમા થયેલ છે. દસ્તાવેજો માત્ર એક જ વાર ઉપયોગ કરી શકાય છે. (This document has already been submitted. Documents can only be used one time.)");
        }
        const existingPending = await this.prisma.verificationRequest.findFirst({
            where: {
                profileId: profile.id,
                status: client_1.VerificationStatus.PENDING,
            },
        });
        if (existingPending) {
            return this.prisma.verificationRequest.update({
                where: { id: existingPending.id },
                data: {
                    documentType,
                    documentUrl,
                    createdAt: new Date(),
                },
            });
        }
        return this.prisma.verificationRequest.create({
            data: {
                profileId: profile.id,
                documentType,
                documentUrl,
                status: client_1.VerificationStatus.PENDING,
            },
        });
    }
    async updateVerificationStatus(requestId, adminId, dto, ipAddress) {
        const request = await this.prisma.verificationRequest.findUnique({
            where: { id: requestId },
            include: {
                profile: true,
            },
        });
        if (!request) {
            throw new common_1.NotFoundException("Verification request not found");
        }
        const oldStatus = request.status;
        const newStatus = dto.status;
        return this.prisma.$transaction(async (tx) => {
            const updatedRequest = await tx.verificationRequest.update({
                where: { id: requestId },
                data: {
                    status: newStatus,
                    rejectionReason: dto.rejectionReason || null,
                },
            });
            if (newStatus === client_1.VerificationStatus.VERIFIED) {
                await tx.matrimonialProfile.update({
                    where: { id: request.profileId },
                    data: {
                        isVerified: true,
                        status: client_1.ProfileStatus.APPROVED,
                    },
                });
                if (request.profile && request.profile.userId) {
                    await tx.user.update({
                        where: { id: request.profile.userId },
                        data: { status: "ACTIVE" },
                    });
                }
            }
            else if (newStatus === client_1.VerificationStatus.REJECTED) {
                await tx.matrimonialProfile.update({
                    where: { id: request.profileId },
                    data: {
                        isVerified: false,
                        status: client_1.ProfileStatus.REJECTED,
                    },
                });
            }
            await tx.adminAuditLog.create({
                data: {
                    adminId,
                    action: "UPDATE_VERIFICATION_STATUS",
                    entityType: "VerificationRequest",
                    entityId: requestId,
                    oldValue: oldStatus,
                    newValue: newStatus,
                    ipAddress: ipAddress || null,
                },
            });
            return updatedRequest;
        });
    }
    async getPendingVerifications() {
        return this.prisma.verificationRequest.findMany({
            orderBy: { createdAt: "desc" },
            include: {
                profile: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                        pargana: {
                            select: {
                                name: true,
                            },
                        },
                    },
                },
            },
        });
    }
    async getMyVerificationStatus(userId) {
        const profile = await this.prisma.matrimonialProfile.findUnique({
            where: { userId },
        });
        if (!profile) {
            return {
                hasProfile: false,
                isVerified: false,
                profileStatus: client_1.ProfileStatus.PENDING,
                latestRequest: null,
            };
        }
        const isStub = profile.firstName === "User" &&
            profile.lastName === "Member" &&
            !profile.religion &&
            !profile.education &&
            !profile.caste;
        const hasProfile = !isStub;
        const latestRequest = await this.prisma.verificationRequest.findFirst({
            where: { profileId: profile.id },
            orderBy: { createdAt: "desc" },
        });
        return {
            hasProfile,
            isVerified: profile.isVerified === true && profile.status === client_1.ProfileStatus.APPROVED,
            profileStatus: profile.status,
            latestRequest: latestRequest
                ? {
                    id: latestRequest.id,
                    documentType: latestRequest.documentType,
                    documentUrl: latestRequest.documentUrl,
                    status: latestRequest.status,
                    rejectionReason: latestRequest.rejectionReason,
                    createdAt: latestRequest.createdAt,
                }
                : null,
        };
    }
};
exports.VerificationsService = VerificationsService;
exports.VerificationsService = VerificationsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], VerificationsService);
//# sourceMappingURL=verifications.service.js.map