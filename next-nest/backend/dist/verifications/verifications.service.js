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
const fs = require("fs");
const fsPromises = require("fs/promises");
const path = require("path");
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
        const docHashMatch = docFilename?.match(/(?:idproof|doc)_([a-f0-9]{16,64})/i);
        const docHash = docHashMatch ? docHashMatch[1] : null;
        const docFilters = [{ documentUrl: cleanDoc }, { documentBackUrl: cleanDoc }];
        if (docFilename && docFilename.length > 5) {
            docFilters.push({ documentUrl: { contains: docFilename } });
            docFilters.push({ documentBackUrl: { contains: docFilename } });
        }
        if (docHash) {
            docFilters.push({ documentUrl: { contains: docHash } });
            docFilters.push({ documentBackUrl: { contains: docHash } });
        }
        const docUsedElsewhere = await this.prisma.verificationRequest.findFirst({
            where: {
                profileId: { not: profile.id },
                OR: docFilters,
            },
        });
        if (docUsedElsewhere) {
            throw new common_1.ConflictException("આ દસ્તાવેજ અન્ય ઉમેદવાર દ્વારા પહેલેથી જ જમા થયેલ છે. દસ્તાવેજો માત્ર એક જ વાર ઉપયોગ કરી શકાય છે. (This document has already been submitted for another candidate. Documents can only be used one time.)");
        }
        const docUsedInGovt = await this.prisma.governmentEmploymentVerification.findFirst({
            where: {
                OR: docFilters.map((f) => ({ documentUrl: f.documentUrl || f.documentBackUrl })),
            },
        });
        if (docUsedInGovt) {
            throw new common_1.ConflictException("આ દસ્તાવેજ પહેલેથી જ જમા થયેલ છે. દસ્તાવેજો માત્ર એક જ વાર ઉપયોગ કરી શકાય છે. (This document has already been submitted. Documents can only be used one time.)");
        }
        const existingReq = await this.prisma.verificationRequest.findFirst({
            where: {
                profileId: profile.id,
            },
            orderBy: { createdAt: "desc" },
        });
        if (existingReq) {
            return this.prisma.verificationRequest.update({
                where: { id: existingReq.id },
                data: {
                    documentType,
                    documentUrl,
                    status: client_1.VerificationStatus.PENDING,
                    rejectionReason: null,
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
        const allRequests = await this.prisma.verificationRequest.findMany({
            orderBy: { createdAt: "desc" },
            include: {
                profile: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true,
                        photoUrl: true,
                        photos: true,
                        nativePlace: true,
                        city: true,
                        pargana: {
                            select: {
                                id: true,
                                name: true,
                                gujaratiName: true,
                            },
                        },
                        user: {
                            select: {
                                id: true,
                                phone: true,
                                email: true,
                                name: true,
                                status: true,
                            },
                        },
                    },
                },
            },
        });
        const seenProfileIds = new Set();
        const deduplicated = [];
        for (const req of allRequests) {
            const key = req.profileId || (req.profile && req.profile.id);
            if (!key)
                continue;
            if (!seenProfileIds.has(key)) {
                seenProfileIds.add(key);
                deduplicated.push(req);
            }
        }
        return deduplicated;
    }
    async getMyVerificationStatus(userId) {
        const profile = await this.prisma.matrimonialProfile.findUnique({
            where: { userId },
        });
        if (!profile) {
            return {
                hasProfile: false,
                isVerified: false,
                profileStatus: "NOT_CREATED",
                latestRequest: null,
            };
        }
        const isStub = profile.firstName === "User" &&
            profile.lastName === "Member" &&
            !profile.religion &&
            !profile.education &&
            !profile.caste;
        const hasProfile = !isStub;
        if (isStub) {
            return {
                hasProfile: false,
                isVerified: false,
                profileStatus: "NOT_CREATED",
                latestRequest: null,
            };
        }
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
    async servePrivateDocument(filename, res) {
        if (!filename ||
            !/^[a-zA-Z0-9_\-.]+\.(jpg|jpeg|png|webp|pdf)$/i.test(filename) ||
            filename.includes("..")) {
            throw new common_1.BadRequestException("Invalid document filename format");
        }
        const privateDir = path.resolve(process.cwd(), "private_uploads");
        const targetFile = path.resolve(privateDir, filename);
        if (!targetFile.startsWith(privateDir + path.sep)) {
            throw new common_1.ForbiddenException("Access outside private document storage is forbidden");
        }
        let fileHandle = null;
        try {
            const privateDirLstat = await fsPromises.lstat(privateDir);
            if (privateDirLstat.isSymbolicLink() || !privateDirLstat.isDirectory()) {
                throw new common_1.ForbiddenException("Private document storage directory is invalid or a symlink");
            }
            const canonicalPrivateDir = await fsPromises.realpath(privateDir);
            const targetLstat = await fsPromises.lstat(targetFile);
            if (targetLstat.isSymbolicLink() || !targetLstat.isFile()) {
                throw new common_1.ForbiddenException("Target document is a symlink or non-regular file");
            }
            if (process.platform !== "win32") {
                if (typeof fs.constants.O_NOFOLLOW !== "number" || fs.constants.O_NOFOLLOW === 0) {
                    throw new Error("Security invariant violated: O_NOFOLLOW is required on POSIX platform");
                }
            }
            const openFlags = fs.constants.O_RDONLY | (fs.constants.O_NOFOLLOW || 0);
            fileHandle = await fsPromises.open(targetFile, openFlags);
            const handleStat = await fileHandle.stat();
            if (!handleStat.isFile()) {
                await fileHandle.close();
                throw new common_1.ForbiddenException("Invalid file type or non-regular file detected");
            }
            const canonicalTarget = await fsPromises.realpath(targetFile);
            if (!canonicalTarget.startsWith(canonicalPrivateDir + path.sep)) {
                await fileHandle.close();
                throw new common_1.ForbiddenException("Canonical file path escapes private storage");
            }
            const canonicalStat = await fsPromises.stat(canonicalTarget);
            if (handleStat.dev !== canonicalStat.dev || handleStat.ino !== canonicalStat.ino) {
                await fileHandle.close();
                throw new common_1.ForbiddenException("File descriptor device/inode does not match canonical document");
            }
            const ext = path.extname(filename).toLowerCase();
            const mimeTypes = {
                ".pdf": "application/pdf",
                ".jpg": "image/jpeg",
                ".jpeg": "image/jpeg",
                ".png": "image/png",
                ".webp": "image/webp",
            };
            const contentType = mimeTypes[ext] || "application/octet-stream";
            res.set({
                "Content-Type": contentType,
                "Content-Length": handleStat.size.toString(),
                "Content-Disposition": `inline; filename="${filename}"`,
                "Cache-Control": "private, no-cache, no-store, must-revalidate",
                "X-Content-Type-Options": "nosniff",
            });
            let isCleanedUp = false;
            const cleanupHandle = async () => {
                if (!isCleanedUp && fileHandle) {
                    isCleanedUp = true;
                    await fileHandle.close().catch(() => { });
                }
            };
            const fileStream = fileHandle.createReadStream();
            res.on("close", () => {
                if (!fileStream.destroyed) {
                    fileStream.destroy();
                }
                cleanupHandle();
            });
            fileStream.on("error", () => {
                cleanupHandle();
                if (!res.headersSent) {
                    res.status(500).json({ statusCode: 500, error: "Internal Server Error", message: "Failed to stream document safely." });
                }
            });
            fileStream.on("end", () => {
                cleanupHandle();
            });
            fileStream.pipe(res);
        }
        catch (err) {
            if (fileHandle) {
                await fileHandle.close().catch(() => { });
            }
            if (err.code === "ENOENT") {
                throw new common_1.NotFoundException("Verification document not found");
            }
            if (err.code === "ELOOP" || err.code === "EACCES" || err.code === "EPERM") {
                throw new common_1.ForbiddenException("Symbolic links and unauthorized access are forbidden");
            }
            throw err;
        }
    }
    async serveCandidatePrivateDocument(userId, filename, res) {
        const profile = await this.prisma.matrimonialProfile.findUnique({
            where: { userId },
        });
        if (!profile) {
            throw new common_1.NotFoundException("Profile not found");
        }
        const verification = await this.prisma.verificationRequest.findFirst({
            where: {
                profileId: profile.id,
                documentUrl: { contains: filename },
            },
        });
        if (!verification) {
            throw new common_1.ForbiddenException("You are not authorized to view this document");
        }
        return this.servePrivateDocument(filename, res);
    }
};
exports.VerificationsService = VerificationsService;
exports.VerificationsService = VerificationsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], VerificationsService);
//# sourceMappingURL=verifications.service.js.map