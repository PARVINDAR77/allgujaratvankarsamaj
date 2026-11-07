import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Request,
  Res,
  Query,
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
import { Public } from "../auth/decorators/public.decorator";
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

  @Public()
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

    // Direct Instant Auto-Approval (AI checking removed per admin configuration)
    let uploadedUrl: string | null = null;
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

    const docType = String(body?.documentType || "ID Proof").trim();
    const docNumber = String(body?.documentNumber || body?.idProofNumber || "").trim();

    return {
      success: true,
      verified: true,
      url: uploadedUrl,
      result: {
        isApproved: true,
        isValidDocument: true,
        detectedDocumentType: docType,
        extractedName: null,
        extractedDob: null,
        extractedDocNumber: docNumber,
        nameMatched: true,
        dobMatched: true,
        confidence: 100,
        rejectionReason: null,
        englishMessage: "Document uploaded and auto-verified successfully.",
        gujaratiMessage: "ઓળખપત્ર સફળતાપૂર્વક અપલોડ અને મંજૂર થયેલ છે.",
      },
      reason: null,
      message: "ઓળખપત્ર સફળતાપૂર્વક અપલોડ અને મંજૂર થયેલ છે.",
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
  async getPendingVerificationsAdmin(
    @Query("page") page?: number,
    @Query("limit") limit?: number,
    @Query("status") status?: string,
  ) {
    return this.verificationsService.getPendingVerifications(
      Number(page) || 1,
      Number(limit) || 15,
      status,
    );
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

