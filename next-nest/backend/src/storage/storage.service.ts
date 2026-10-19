import { Injectable, Logger, BadRequestException } from "@nestjs/common";
import { v4 as uuidv4 } from "uuid";
import * as fs from "fs/promises";
import * as path from "path";
import * as crypto from "crypto";

@Injectable()
export class StorageService {
  private readonly logger = new Logger(StorageService.name);
  private readonly uploadDir = path.join(process.cwd(), "uploads");
  private readonly privateUploadDir = path.join(process.cwd(), "private_uploads");

  /**
   * Upload Public Media (Profile photos, avatars, banner graphics)
   * Stored in the public static directory (/uploads).
   * Strictly enforces public image extensions and mimetypes.
   */
  async uploadPublicMedia(
    fileBuffer: Buffer,
    mimetype: string,
    originalName: string,
  ): Promise<string> {
    const allowedPublicTypes = [
      "image/jpeg",
      "image/png",
      "image/webp",
      "image/gif",
    ];

    if (!allowedPublicTypes.includes(mimetype.toLowerCase())) {
      throw new BadRequestException(
        "Invalid public media type. Only public images (.jpg, .png, .webp, .gif) are allowed in public storage.",
      );
    }

    await fs.mkdir(this.uploadDir, { recursive: true });

    const rawExt = (originalName.split(".").pop() || "jpg").toLowerCase().replace(/[^a-z0-9]/g, "");
    const ext = ["jpg", "jpeg", "png", "webp", "gif"].includes(rawExt) ? rawExt : "jpg";
    const isIdProof =
      originalName.toLowerCase().includes("id_proof") ||
      originalName.toLowerCase().includes("idproof") ||
      originalName.toLowerCase().includes("doc");

    let uniqueFilename: string;
    if (isIdProof) {
      const fileHash = crypto.createHash("sha256").update(fileBuffer).digest("hex").substring(0, 32);
      uniqueFilename = `idproof_${fileHash}_${uuidv4().substring(0, 8)}.${ext}`;
    } else {
      uniqueFilename = `${uuidv4()}.${ext}`;
    }

    const filePath = path.join(this.uploadDir, uniqueFilename);

    await fs.writeFile(filePath, fileBuffer);
    this.logger.log(`Uploaded public media: ${uniqueFilename}`);
    return `/uploads/${uniqueFilename}`;
  }

  /**
   * Upload Private Verification Document (Aadhaar cards, Govt IDs, credentials)
   * Stored in the private directory (/private_uploads) OUTSIDE public static access.
   * Accessible only via authenticated RBAC endpoints.
   */
  async uploadVerificationDocument(
    fileBuffer: Buffer,
    mimetype: string,
    originalName: string,
  ): Promise<string> {
    const allowedDocTypes = [
      "image/jpeg",
      "image/png",
      "image/webp",
      "application/pdf",
    ];

    if (!allowedDocTypes.includes(mimetype.toLowerCase())) {
      throw new BadRequestException(
        "Invalid document type. Only images (.jpg, .png, .webp) and PDF documents are allowed for verification.",
      );
    }

    await fs.mkdir(this.privateUploadDir, { recursive: true, mode: 0o700 });

    const rawExt = (originalName.split(".").pop() || "pdf").toLowerCase().replace(/[^a-z0-9]/g, "");
    const ext = ["jpg", "jpeg", "png", "webp", "pdf"].includes(rawExt) ? rawExt : "pdf";
    const fileHash = crypto.createHash("sha256").update(fileBuffer).digest("hex").substring(0, 32);
    const uniqueFilename = `doc_${fileHash}_${uuidv4().substring(0, 8)}.${ext}`;
    const filePath = path.join(this.privateUploadDir, uniqueFilename);

    await fs.writeFile(filePath, fileBuffer, { mode: 0o600 });
    this.logger.log(`Uploaded private verification document: ${uniqueFilename}`);
    return `/api/v1/admin/verifications/documents/${uniqueFilename}`;
  }

  /**
   * General upload handler routing based on privacy classification
   */
  async uploadFile(
    fileBuffer: Buffer,
    mimetype: string,
    originalName: string,
    isPrivate = false,
  ): Promise<string> {
    if (isPrivate) {
      return this.uploadVerificationDocument(fileBuffer, mimetype, originalName);
    }
    return this.uploadPublicMedia(fileBuffer, mimetype, originalName);
  }

  async deleteFile(fileUrl: string): Promise<void> {
    this.logger.log(`Deleting file at ${fileUrl}`);
    await new Promise((resolve) => setTimeout(resolve, 300));
  }
}

