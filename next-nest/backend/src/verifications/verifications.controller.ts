import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Request,
  Res,
  UseGuards,
  UseInterceptors,
  UploadedFile,
  BadRequestException,
} from "@nestjs/common";
import { FileInterceptor } from "@nestjs/platform-express";
import { Response } from "express";

import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
  ApiConsumes,
} from "@nestjs/swagger";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { PermissionsGuard } from "../auth/guards/permissions.guard";
import { Permissions } from "../auth/decorators/permissions.decorator";
import { Permission } from "../auth/constants/permissions";
import { VerificationsService } from "./verifications.service";
import { AiVerificationService } from "./ai-verification.service";
import { StorageService } from "../storage/storage.service";
import { UpdateVerificationStatusDto } from "./dto/update-verification.dto";

@ApiTags("Verifications")
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, PermissionsGuard)
@Controller("verifications")
export class VerificationsController {
  constructor(
    private readonly verificationsService: VerificationsService,
    private readonly aiVerificationService: AiVerificationService,
    private readonly storageService: StorageService,
  ) {}

  @Post("ai-verify")
  @ApiOperation({ summary: "AI Document Verification (verifies Name and DOB on ID card)" })
  @ApiConsumes("multipart/form-data", "application/json")
  @UseInterceptors(FileInterceptor("file"))
  async aiVerify(
    @UploadedFile() file?: Express.Multer.File,
    @Body() body?: any,
  ) {
    let fileBuffer: Buffer | null = null;
    let mimetype = "image/jpeg";
    let originalName = "id_doc.jpg";

    if (file && file.buffer) {
      fileBuffer = file.buffer;
      mimetype = file.mimetype || "image/jpeg";
      originalName = file.originalname || "id_doc.jpg";
    } else if (body?.base64 || body?.file) {
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
      throw new BadRequestException("કૃપા કરીને ઓળખપત્રનો ફોટો અપલોડ કરો (Please provide an ID document photo)");
    }

    const MAX_SIZE = 5 * 1024 * 1024;
    if (fileBuffer.length > MAX_SIZE) {
      throw new BadRequestException("ઓળખપત્રના ફોટાની સાઈઝ 5 MB કરતાં ઓછી હોવી જોઈએ (File exceeds 5 MB limit)");
    }

    const result = await this.aiVerificationService.verifyDocument({
      fileBuffer,
      mimetype,
      expectedFirstName: String(body?.firstName || "").trim(),
      expectedLastName: String(body?.lastName || "").trim(),
      expectedDob: String(body?.dob || body?.dateOfBirth || "").trim(),
      documentType: String(body?.documentType || "Voter ID Card").trim(),
      documentNumber: String(body?.documentNumber || body?.idProofNumber || "").trim(),
      side: String(body?.side || "").toUpperCase() === "BACK" ? "BACK" : "FRONT",
    });

    let uploadedUrl: string | null = null;
    if (result.isApproved) {
      try {
        uploadedUrl = await this.storageService.uploadFile(
          fileBuffer,
          mimetype,
          originalName,
          false,
        );
      } catch (err: any) {
        // Fallback: uploadedUrl will remain null and be uploaded on final profile submit
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

  @Post("submit")
  @ApiOperation({ summary: "Submit a verification request" })
  @ApiResponse({ status: 201, description: "Verification request submitted" })
  async submitVerification(
    @Request() req: any,
    @Body() body: { documentType: string; documentUrl: string },
  ) {
    return this.verificationsService.submitVerification(
      req.user.id,
      body.documentType,
      body.documentUrl,
    );
  }

  @Get("my-status")
  @ApiOperation({ summary: "Get verification status for authenticated user" })
  @ApiResponse({ status: 200, description: "Current verification status" })
  async getMyVerificationStatus(@Request() req: any) {
    return this.verificationsService.getMyVerificationStatus(req.user.id);
  }

  @Get("my-document/:filename")
  @ApiOperation({ summary: "Get candidate's own uploaded verification document" })
  @ApiResponse({ status: 200, description: "Document stream" })
  async getMyVerificationDocument(
    @Request() req: any,
    @Param("filename") filename: string,
    @Res() res: Response,
  ) {
    return this.verificationsService.serveCandidatePrivateDocument(
      req.user.id,
      filename,
      res,
    );
  }
}

@ApiTags("Admin Verifications")
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, PermissionsGuard)
@Controller("admin/verifications")
export class AdminVerificationsController {
  constructor(private readonly verificationsService: VerificationsService) {}

  @Permissions(Permission.VERIFICATION_READ)
  @Get()
  @ApiOperation({ summary: "Get all pending verification requests (Admin)" })
  @ApiResponse({ status: 200, description: "List of pending requests" })
  async getPendingVerificationsAdmin() {
    const requests = await this.verificationsService.getPendingVerifications();
    return requests.map((req: any) => ({
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

  @Permissions(Permission.VERIFICATION_READ)
  @Get("documents/:filename")
  @ApiOperation({ summary: "Get private verification document (Admin RBAC required)" })
  @ApiResponse({ status: 200, description: "Document stream" })
  async getVerificationDocumentAdmin(
    @Param("filename") filename: string,
    @Res() res: Response,
  ) {
    return this.verificationsService.servePrivateDocument(filename, res);
  }

  @Permissions(Permission.VERIFICATION_REVIEW)
  @Patch(":id/verify")
  @ApiOperation({ summary: "Update verification status (Admin)" })
  @ApiResponse({ status: 200, description: "Status updated" })
  async updateStatusAdmin(
    @Request() req: any,
    @Param("id") id: string,
    @Body() dto: UpdateVerificationStatusDto,
  ) {
    const ipAddress = req.ip || req.connection?.remoteAddress || null;
    return this.verificationsService.updateVerificationStatus(
      id,
      req.user.id,
      dto,
      ipAddress,
    );
  }
}

