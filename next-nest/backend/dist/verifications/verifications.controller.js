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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AdminVerificationsController = exports.VerificationsController = void 0;
const common_1 = require("@nestjs/common");
const platform_express_1 = require("@nestjs/platform-express");
const swagger_1 = require("@nestjs/swagger");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
const permissions_guard_1 = require("../auth/guards/permissions.guard");
const permissions_decorator_1 = require("../auth/decorators/permissions.decorator");
const permissions_1 = require("../auth/constants/permissions");
const verifications_service_1 = require("./verifications.service");
const ai_verification_service_1 = require("./ai-verification.service");
const storage_service_1 = require("../storage/storage.service");
const update_verification_dto_1 = require("./dto/update-verification.dto");
let VerificationsController = class VerificationsController {
    constructor(verificationsService, aiVerificationService, storageService) {
        this.verificationsService = verificationsService;
        this.aiVerificationService = aiVerificationService;
        this.storageService = storageService;
    }
    async aiVerify(file, body) {
        let fileBuffer = null;
        let mimetype = "image/jpeg";
        let originalName = "id_doc.jpg";
        if (file && file.buffer) {
            fileBuffer = file.buffer;
            mimetype = file.mimetype || "image/jpeg";
            originalName = file.originalname || "id_doc.jpg";
        }
        else if (body?.base64 || body?.file) {
            let rawBase64 = String(body.base64 || body.file).trim();
            const dataUriMatch = rawBase64.match(/^data:([a-zA-Z0-9\/\-+.]+);base64,(.+)$/s);
            if (dataUriMatch) {
                mimetype = dataUriMatch[1].toLowerCase();
                rawBase64 = dataUriMatch[2].trim();
            }
            fileBuffer = Buffer.from(rawBase64, "base64");
            originalName = body?.filename || `id_doc.${mimetype.split("/")[1] || "jpg"}`;
        }
        if (!fileBuffer || fileBuffer.length === 0) {
            throw new common_1.BadRequestException("કૃપા કરીને ઓળખપત્રનો ફોટો અપલોડ કરો (Please provide an ID document photo)");
        }
        const MAX_SIZE = 5 * 1024 * 1024;
        if (fileBuffer.length > MAX_SIZE) {
            throw new common_1.BadRequestException("ઓળખપત્રના ફોટાની સાઈઝ 5 MB કરતાં ઓછી હોવી જોઈએ (File exceeds 5 MB limit)");
        }
        const result = await this.aiVerificationService.verifyDocument({
            fileBuffer,
            mimetype,
            expectedFirstName: String(body?.firstName || "").trim(),
            expectedLastName: String(body?.lastName || "").trim(),
            expectedDob: String(body?.dob || body?.dateOfBirth || "").trim(),
            documentType: String(body?.documentType || "Aadhaar Card").trim(),
            documentNumber: String(body?.documentNumber || body?.idProofNumber || "").trim(),
            side: String(body?.side || "").toUpperCase() === "BACK" ? "BACK" : "FRONT",
        });
        let uploadedUrl = null;
        if (result.isApproved) {
            try {
                uploadedUrl = await this.storageService.uploadFile(fileBuffer, mimetype, originalName, false);
            }
            catch (err) {
            }
        }
        return {
            success: result.isApproved,
            verified: result.isApproved,
            url: uploadedUrl,
            result,
            reason: result.rejectionReason,
            message: result.gujaratiMessage || result.englishMessage,
        };
    }
    async submitVerification(req, body) {
        return this.verificationsService.submitVerification(req.user.id, body.documentType, body.documentUrl);
    }
    async getMyVerificationStatus(req) {
        return this.verificationsService.getMyVerificationStatus(req.user.id);
    }
    async getMyVerificationDocument(req, filename, res) {
        return this.verificationsService.serveCandidatePrivateDocument(req.user.id, filename, res);
    }
};
exports.VerificationsController = VerificationsController;
__decorate([
    (0, common_1.Post)("ai-verify"),
    (0, swagger_1.ApiOperation)({ summary: "AI Document Verification (verifies Name and DOB on ID card)" }),
    (0, swagger_1.ApiConsumes)("multipart/form-data", "application/json"),
    (0, common_1.UseInterceptors)((0, platform_express_1.FileInterceptor)("file")),
    __param(0, (0, common_1.UploadedFile)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise)
], VerificationsController.prototype, "aiVerify", null);
__decorate([
    (0, common_1.Post)("submit"),
    (0, swagger_1.ApiOperation)({ summary: "Submit a verification request" }),
    (0, swagger_1.ApiResponse)({ status: 201, description: "Verification request submitted" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise)
], VerificationsController.prototype, "submitVerification", null);
__decorate([
    (0, common_1.Get)("my-status"),
    (0, swagger_1.ApiOperation)({ summary: "Get verification status for authenticated user" }),
    (0, swagger_1.ApiResponse)({ status: 200, description: "Current verification status" }),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], VerificationsController.prototype, "getMyVerificationStatus", null);
__decorate([
    (0, common_1.Get)("my-document/:filename"),
    (0, swagger_1.ApiOperation)({ summary: "Get candidate's own uploaded verification document" }),
    (0, swagger_1.ApiResponse)({ status: 200, description: "Document stream" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)("filename")),
    __param(2, (0, common_1.Res)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, Object]),
    __metadata("design:returntype", Promise)
], VerificationsController.prototype, "getMyVerificationDocument", null);
exports.VerificationsController = VerificationsController = __decorate([
    (0, swagger_1.ApiTags)("Verifications"),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, permissions_guard_1.PermissionsGuard),
    (0, common_1.Controller)("verifications"),
    __metadata("design:paramtypes", [verifications_service_1.VerificationsService,
        ai_verification_service_1.AiVerificationService,
        storage_service_1.StorageService])
], VerificationsController);
let AdminVerificationsController = class AdminVerificationsController {
    constructor(verificationsService) {
        this.verificationsService = verificationsService;
    }
    async getPendingVerificationsAdmin() {
        const requests = await this.verificationsService.getPendingVerifications();
        return requests.map((req) => ({
            id: req.id,
            profileId: req.profileId,
            documentType: req.documentType,
            documentUrl: req.documentUrl,
            documentBackUrl: req.documentBackUrl || null,
            status: req.status,
            rejectionReason: req.rejectionReason,
            createdAt: req.createdAt,
            profile: req.profile
                ? {
                    id: req.profile.id,
                    name: `${req.profile.firstName || ""} ${req.profile.lastName || ""}`.trim() || req.profile.user?.name || "Candidate",
                    firstName: req.profile.firstName,
                    lastName: req.profile.lastName,
                    photoUrl: req.profile.photoUrl,
                    photos: req.profile.photos,
                    nativePlace: req.profile.nativePlace,
                    city: req.profile.city,
                    pargana: req.profile.pargana,
                    user: req.profile.user,
                }
                : null,
        }));
    }
    async getVerificationDocumentAdmin(filename, res) {
        return this.verificationsService.servePrivateDocument(filename, res);
    }
    async updateStatusAdmin(req, id, dto) {
        const ipAddress = req.ip || req.connection?.remoteAddress || null;
        return this.verificationsService.updateVerificationStatus(id, req.user.id, dto, ipAddress);
    }
};
exports.AdminVerificationsController = AdminVerificationsController;
__decorate([
    (0, permissions_decorator_1.Permissions)(permissions_1.Permission.VERIFICATION_READ),
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({ summary: "Get all pending verification requests (Admin)" }),
    (0, swagger_1.ApiResponse)({ status: 200, description: "List of pending requests" }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", Promise)
], AdminVerificationsController.prototype, "getPendingVerificationsAdmin", null);
__decorate([
    (0, permissions_decorator_1.Permissions)(permissions_1.Permission.VERIFICATION_READ),
    (0, common_1.Get)("documents/:filename"),
    (0, swagger_1.ApiOperation)({ summary: "Get private verification document (Admin RBAC required)" }),
    (0, swagger_1.ApiResponse)({ status: 200, description: "Document stream" }),
    __param(0, (0, common_1.Param)("filename")),
    __param(1, (0, common_1.Res)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], AdminVerificationsController.prototype, "getVerificationDocumentAdmin", null);
__decorate([
    (0, permissions_decorator_1.Permissions)(permissions_1.Permission.VERIFICATION_REVIEW),
    (0, common_1.Patch)(":id/verify"),
    (0, swagger_1.ApiOperation)({ summary: "Update verification status (Admin)" }),
    (0, swagger_1.ApiResponse)({ status: 200, description: "Status updated" }),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Param)("id")),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, update_verification_dto_1.UpdateVerificationStatusDto]),
    __metadata("design:returntype", Promise)
], AdminVerificationsController.prototype, "updateStatusAdmin", null);
exports.AdminVerificationsController = AdminVerificationsController = __decorate([
    (0, swagger_1.ApiTags)("Admin Verifications"),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard, permissions_guard_1.PermissionsGuard),
    (0, common_1.Controller)("admin/verifications"),
    __metadata("design:paramtypes", [verifications_service_1.VerificationsService])
], AdminVerificationsController);
//# sourceMappingURL=verifications.controller.js.map