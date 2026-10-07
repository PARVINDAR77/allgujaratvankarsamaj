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
let StorageService = StorageService_1 = class StorageService {
    constructor() {
        this.logger = new common_1.Logger(StorageService_1.name);
        this.uploadDir = path.join(process.cwd(), "uploads");
    }
    async uploadFile(fileBuffer, mimetype, originalName) {
        this.logger.log(`Uploading file ${originalName} of type ${mimetype}`);
        await fs.mkdir(this.uploadDir, { recursive: true });
        const ext = originalName.split(".").pop() || "";
        const uniqueFilename = `${(0, uuid_1.v4)()}.${ext}`;
        const filePath = path.join(this.uploadDir, uniqueFilename);
        await fs.writeFile(filePath, fileBuffer);
        return `/uploads/${uniqueFilename}`;
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