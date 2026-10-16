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
exports.StorageController = void 0;
const common_1 = require("@nestjs/common");
const platform_express_1 = require("@nestjs/platform-express");
const swagger_1 = require("@nestjs/swagger");
const storage_service_1 = require("./storage.service");
let StorageController = class StorageController {
    constructor(storageService) {
        this.storageService = storageService;
    }
    async uploadFile(file, body) {
        const isPrivate = body?.isPrivate === true ||
            body?.isPrivate === "true" ||
            body?.category === "verification" ||
            body?.documentType != null;
        const MAX_FILE_SIZE = 5 * 1024 * 1024;
        if (file && file.buffer) {
            if (file.buffer.length > MAX_FILE_SIZE) {
                throw new common_1.BadRequestException("File size exceeds maximum limit of 5 MB (મહત્તમ ફાઈલ સાઈઝ 5 MB છે).");
            }
            const url = await this.storageService.uploadFile(file.buffer, file.mimetype, file.originalname || "image.jpg", isPrivate);
            return { url };
        }
        const base64Data = body?.base64 || body?.file;
        if (typeof base64Data === "string" && base64Data.trim().length > 0) {
            let rawBase64 = base64Data.trim();
            let mimetype = body?.mimetype || "image/jpeg";
            let originalName = body?.filename || "upload.jpg";
            const dataUriMatch = rawBase64.match(/^data:([a-zA-Z0-9\/\-+.]+);base64,(.+)$/s);
            if (dataUriMatch) {
                mimetype = dataUriMatch[1].toLowerCase();
                rawBase64 = dataUriMatch[2].trim();
                if (!body?.filename) {
                    const ext = mimetype.split("/")[1] || "jpg";
                    originalName = `upload.${ext}`;
                }
            }
            const fileBuffer = Buffer.from(rawBase64, "base64");
            if (!fileBuffer || fileBuffer.length === 0) {
                throw new common_1.BadRequestException("Invalid or empty base64 data");
            }
            if (fileBuffer.length > MAX_FILE_SIZE) {
                throw new common_1.BadRequestException("File size exceeds maximum limit of 5 MB (મહત્તમ ફાઈલ સાઈઝ 5 MB છે).");
            }
            const url = await this.storageService.uploadFile(fileBuffer, mimetype, originalName, isPrivate);
            return { url };
        }
        throw new common_1.BadRequestException("No file or base64 image data provided");
    }
    async uploadVerificationDocument(file) {
        if (!file || !file.buffer) {
            throw new common_1.BadRequestException("No verification document file provided");
        }
        const MAX_FILE_SIZE = 5 * 1024 * 1024;
        if (file.buffer.length > MAX_FILE_SIZE) {
            throw new common_1.BadRequestException("File size exceeds maximum limit of 5 MB.");
        }
        const url = await this.storageService.uploadVerificationDocument(file.buffer, file.mimetype, file.originalname || "document.pdf");
        return { url };
    }
};
exports.StorageController = StorageController;
__decorate([
    (0, common_1.Post)("upload"),
    (0, swagger_1.ApiOperation)({ summary: "Upload a public media file or private verification document" }),
    (0, swagger_1.ApiConsumes)("multipart/form-data", "application/json"),
    (0, common_1.UseInterceptors)((0, platform_express_1.FileInterceptor)("file")),
    __param(0, (0, common_1.UploadedFile)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, Object]),
    __metadata("design:returntype", Promise)
], StorageController.prototype, "uploadFile", null);
__decorate([
    (0, common_1.Post)("upload-verification"),
    (0, swagger_1.ApiOperation)({ summary: "Upload private verification document (ID cards, credentials)" }),
    (0, swagger_1.ApiConsumes)("multipart/form-data"),
    (0, common_1.UseInterceptors)((0, platform_express_1.FileInterceptor)("file")),
    __param(0, (0, common_1.UploadedFile)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], StorageController.prototype, "uploadVerificationDocument", null);
exports.StorageController = StorageController = __decorate([
    (0, swagger_1.ApiTags)("Storage"),
    (0, common_1.Controller)("storage"),
    __metadata("design:paramtypes", [storage_service_1.StorageService])
], StorageController);
//# sourceMappingURL=storage.controller.js.map