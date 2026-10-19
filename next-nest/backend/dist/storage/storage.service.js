"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var StorageService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.StorageService = void 0;
const common_1 = require("@nestjs/common");
const uuid_1 = require("uuid");
const fs = require("fs/promises");
const path = require("path");
const crypto = require("crypto");
let StorageService = StorageService_1 = class StorageService {
    constructor() {
        this.logger = new common_1.Logger(StorageService_1.name);
        this.uploadDir = path.join(process.cwd(), "uploads");
        this.privateUploadDir = path.join(process.cwd(), "private_uploads");
    }
    async uploadPublicMedia(fileBuffer, mimetype, originalName) {
        const allowedPublicTypes = [
            "image/jpeg",
            "image/png",
            "image/webp",
            "image/gif",
        ];
        if (!allowedPublicTypes.includes(mimetype.toLowerCase())) {
            throw new common_1.BadRequestException("Invalid public media type. Only public images (.jpg, .png, .webp, .gif) are allowed in public storage.");
        }
        await fs.mkdir(this.uploadDir, { recursive: true });
        const rawExt = (originalName.split(".").pop() || "jpg").toLowerCase().replace(/[^a-z0-9]/g, "");
        const ext = ["jpg", "jpeg", "png", "webp", "gif"].includes(rawExt) ? rawExt : "jpg";
        const isIdProof = originalName.toLowerCase().includes("id_proof") ||
            originalName.toLowerCase().includes("idproof") ||
            originalName.toLowerCase().includes("doc");
        let uniqueFilename;
        if (isIdProof) {
            const fileHash = crypto.createHash("sha256").update(fileBuffer).digest("hex").substring(0, 32);
            uniqueFilename = `idproof_${fileHash}_${(0, uuid_1.v4)().substring(0, 8)}.${ext}`;
        }
        else {
            uniqueFilename = `${(0, uuid_1.v4)()}.${ext}`;
        }
        const filePath = path.join(this.uploadDir, uniqueFilename);
        await fs.writeFile(filePath, fileBuffer);
        this.logger.log(`Uploaded public media: ${uniqueFilename}`);
        return `/uploads/${uniqueFilename}`;
    }
    async uploadVerificationDocument(fileBuffer, mimetype, originalName) {
        const allowedDocTypes = [
            "image/jpeg",
            "image/png",
            "image/webp",
            "application/pdf",
        ];
        if (!allowedDocTypes.includes(mimetype.toLowerCase())) {
            throw new common_1.BadRequestException("Invalid document type. Only images (.jpg, .png, .webp) and PDF documents are allowed for verification.");
        }
        await fs.mkdir(this.privateUploadDir, { recursive: true, mode: 0o700 });
        const rawExt = (originalName.split(".").pop() || "pdf").toLowerCase().replace(/[^a-z0-9]/g, "");
        const ext = ["jpg", "jpeg", "png", "webp", "pdf"].includes(rawExt) ? rawExt : "pdf";
        const fileHash = crypto.createHash("sha256").update(fileBuffer).digest("hex").substring(0, 32);
        const uniqueFilename = `doc_${fileHash}_${(0, uuid_1.v4)().substring(0, 8)}.${ext}`;
        const filePath = path.join(this.privateUploadDir, uniqueFilename);
        await fs.writeFile(filePath, fileBuffer, { mode: 0o600 });
        this.logger.log(`Uploaded private verification document: ${uniqueFilename}`);
        return `/api/v1/admin/verifications/documents/${uniqueFilename}`;
    }
    async uploadFile(fileBuffer, mimetype, originalName, isPrivate = false) {
        if (isPrivate) {
            return this.uploadVerificationDocument(fileBuffer, mimetype, originalName);
        }
        return this.uploadPublicMedia(fileBuffer, mimetype, originalName);
    }
    async deleteFile(fileUrl) {
        this.logger.log(`Deleting file at ${fileUrl}`);
        await new Promise((resolve) => setTimeout(resolve, 300));
    }
};
exports.StorageService = StorageService;
exports.StorageService = StorageService = StorageService_1 = __decorate([
    (0, common_1.Injectable)()
], StorageService);
//# sourceMappingURL=storage.service.js.map