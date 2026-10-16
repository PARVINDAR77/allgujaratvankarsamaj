import {
  Controller,
  Post,
  UseInterceptors,
  UploadedFile,
  Body,
  BadRequestException,
} from "@nestjs/common";
import { FileInterceptor } from "@nestjs/platform-express";
import { ApiTags, ApiOperation, ApiConsumes } from "@nestjs/swagger";
import { StorageService } from "./storage.service";

@ApiTags("Storage")
@Controller("storage")
export class StorageController {
  constructor(private readonly storageService: StorageService) {}

  @Post("upload")
  @ApiOperation({ summary: "Upload a public media file or private verification document" })
  @ApiConsumes("multipart/form-data", "application/json")
  @UseInterceptors(FileInterceptor("file"))
  async uploadFile(
    @UploadedFile() file?: Express.Multer.File,
    @Body() body?: any,
  ) {
    const isPrivate =
      body?.isPrivate === true ||
      body?.isPrivate === "true" ||
      body?.category === "verification" ||
      body?.documentType != null;

    const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5 MB limit

    // Case 1: Standard multipart file upload
    if (file && file.buffer) {
      if (file.buffer.length > MAX_FILE_SIZE) {
        throw new BadRequestException(
          "File size exceeds maximum limit of 5 MB (મહત્તમ ફાઈલ સાઈઝ 5 MB છે).",
        );
      }
      const url = await this.storageService.uploadFile(
        file.buffer,
        file.mimetype,
        file.originalname || "image.jpg",
        isPrivate,
      );
      return { url };
    }

    // Case 2: Base64 string payload (JSON)
    const base64Data = body?.base64 || body?.file;
    if (typeof base64Data === "string" && base64Data.trim().length > 0) {
      let rawBase64 = base64Data.trim();
      let mimetype = body?.mimetype || "image/jpeg";
      let originalName = body?.filename || "upload.jpg";

      // Parse data URI prefix if present (e.g., data:image/png;base64,...)
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
        throw new BadRequestException("Invalid or empty base64 data");
      }
      if (fileBuffer.length > MAX_FILE_SIZE) {
        throw new BadRequestException(
          "File size exceeds maximum limit of 5 MB (મહત્તમ ફાઈલ સાઈઝ 5 MB છે).",
        );
      }

      const url = await this.storageService.uploadFile(
        fileBuffer,
        mimetype,
        originalName,
        isPrivate,
      );
      return { url };
    }

    throw new BadRequestException("No file or base64 image data provided");
  }

  @Post("upload-verification")
  @ApiOperation({ summary: "Upload private verification document (ID cards, credentials)" })
  @ApiConsumes("multipart/form-data")
  @UseInterceptors(FileInterceptor("file"))
  async uploadVerificationDocument(
    @UploadedFile() file?: Express.Multer.File,
  ) {
    if (!file || !file.buffer) {
      throw new BadRequestException("No verification document file provided");
    }
    const MAX_FILE_SIZE = 5 * 1024 * 1024;
    if (file.buffer.length > MAX_FILE_SIZE) {
      throw new BadRequestException("File size exceeds maximum limit of 5 MB.");
    }

    const url = await this.storageService.uploadVerificationDocument(
      file.buffer,
      file.mimetype,
      file.originalname || "document.pdf",
    );
    return { url };
  }
}

