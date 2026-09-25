import { Body, Controller, Get, Param, Patch, Post, Request, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { PermissionsGuard } from '../auth/guards/permissions.guard';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Permission } from '../auth/constants/permissions';
import { VerificationsService } from './verifications.service';
import { UpdateVerificationStatusDto } from './dto/update-verification.dto';

@ApiTags('Verifications')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, PermissionsGuard)
@Controller('verifications')
export class VerificationsController {
  constructor(private readonly verificationsService: VerificationsService) {}

  @Post('submit')
  @ApiOperation({ summary: 'Submit a verification request' })
  @ApiResponse({ status: 201, description: 'Verification request submitted' })
  async submitVerification(@Request() req: any, @Body() body: { documentType: string; documentUrl: string }) {
    return this.verificationsService.submitVerification(req.user.id, body.documentType, body.documentUrl);
  }

}

@ApiTags('Admin Verifications')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, PermissionsGuard)
@Controller('admin/verifications')
export class AdminVerificationsController {
  constructor(private readonly verificationsService: VerificationsService) {}

  @Permissions(Permission.VERIFICATION_READ)
  @Get()
  @ApiOperation({ summary: 'Get all pending verification requests (Admin)' })
  @ApiResponse({ status: 200, description: 'List of pending requests' })
  async getPendingVerificationsAdmin() {
    const requests = await this.verificationsService.getPendingVerifications();
    return requests.map(req => ({
      id: req.id,
      profileId: req.profileId,
      documentType: req.documentType,
      documentUrl: req.documentUrl,
      status: req.status,
      createdAt: req.createdAt,
      profile: {
        id: req.profile.id,
        name: `${req.profile.firstName} ${req.profile.lastName}`.trim()
      }
    }));
  }

  @Permissions(Permission.VERIFICATION_REVIEW)
  @Patch(':id/verify')
  @ApiOperation({ summary: 'Update verification status (Admin)' })
  @ApiResponse({ status: 200, description: 'Status updated' })
  async updateStatusAdmin(
    @Request() req: any,
    @Param('id') id: string,
    @Body() dto: UpdateVerificationStatusDto,
  ) {
    const ipAddress = req.ip || req.connection?.remoteAddress || null;
    return this.verificationsService.updateVerificationStatus(id, req.user.id, dto, ipAddress);
  }
}
