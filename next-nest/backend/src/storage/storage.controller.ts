import {
  Controller,
  Post,
  UseInterceptors,
  UploadedFile,
  Body,
  BadRequestException,
} from "@nestjs/common";
import { FileInterceptor } from "@nestjs/platform-express";
import { ApiTags, ApiOperation, ApiConsumes, ApiBody } from "@nestjs/swagger";
import { StorageService } from "./storage.service";

@ApiTags("Storage")
@Controller("storage")
export class StorageController {
  constructor(private readonly storageService: StorageService) {}

  @Post("upload")
  @ApiOperation({ summary: "Upload a file (Image or PDF via Multipart or Base64 JSON)" })
  @ApiConsumes("multipart/form-data", "application/json")
  @UseInterceptors(FileInterceptor("file"))
  async uploadFile(
    @UploadedFile() file?: Express.Multer.File,
    @Body() body?: any,
  ) {
    const allowedMimeTypes = [
      "image/jpeg",
      "image/png",
      "image/gif",
      "image/webp",
      "application/pdf",
    ];

    const MAX_FILE_SIZE = 5 * 1024 * 1024; // 5 MB limit

    // Case 1: Standard multipart file upload
    if (file && file.buffer) {
      if (file.buffer.length > MAX_FILE_SIZE) {
        throw new BadRequestException(
          "Image size exceeds maximum limit of 5 MB (મહત્તમ ફાઈલ સાઈઝ 5 MB છે).",
        );
      }
      if (!allowedMimeTypes.includes(file.mimetype)) {
        throw new BadRequestException(
          "Invalid file type. Only images and PDFs are allowed.",
        );
      }
      const url = await this.storageService.uploadFile(
        file.buffer,
        file.mimetype,
        file.originalname || "image.jpg",
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

      if (!allowedMimeTypes.includes(mimetype)) {
        throw new BadRequestException(
          "Invalid file type. Only images and PDFs are allowed.",
        );
      }

      const fileBuffer = Buffer.from(rawBase64, "base64");
      if (!fileBuffer || fileBuffer.length === 0) {
        throw new BadRequestException("Invalid or empty base64 data");
      }
      if (fileBuffer.length > MAX_FILE_SIZE) {
        throw new BadRequestException(
          "Image size exceeds maximum limit of 5 MB (મહત્તમ ફાઈલ સાઈઝ 5 MB છે).",
        );
      }

      const url = await this.storageService.uploadFile(
        fileBuffer,
        mimetype,
        originalName,
      );
      return { url };
    }

    throw new BadRequestException("No file or base64 image data provided");
  }
}
