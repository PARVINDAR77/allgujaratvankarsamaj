import { Body, Controller, Get, Param, Patch, Post, Request, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CapabilitiesGuard } from '../auth/guards/capabilities.guard';
import { Capabilities } from '../auth/decorators/capabilities.decorator';
import { Capability } from '../auth/constants/capabilities';
import { VerificationsService } from './verifications.service';
import { UpdateVerificationStatusDto } from './dto/update-verification.dto';

@ApiTags('Verifications')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, CapabilitiesGuard)
@Controller('verifications')
export class VerificationsController {
  constructor(private readonly verificationsService: VerificationsService) {}

  @Post('submit')
  @ApiOperation({ summary: 'Submit a verification request' })
  @ApiResponse({ status: 201, description: 'Verification request submitted' })
  async submitVerification(@Request() req: any, @Body() body: { documentType: string; documentUrl: string }) {
    // Note: Assuming `req.user.id` holds the user ID. We should ideally look up profileId first
    // Since VerificationsService requires profileId, let's assume we fetch it or pass it.
    // For now we assume we'll just pass user id and let the service handle it, or we expect profileId in body.
    // Let's expect profileId in body for simplicity, or we can look it up in service.
    // We'll update the service to accept userId instead.
    return this.verificationsService.submitVerification(req.user.id, body.documentType, body.documentUrl);
  }

  @Capabilities(Capability.VERIFICATION_READ)
  @Get('pending')
  @ApiOperation({ summary: 'Get all pending verification requests (Admin)' })
  @ApiResponse({ status: 200, description: 'List of pending requests' })
  async getPendingVerifications() {
    return this.verificationsService.getPendingVerifications();
  }

  @Capabilities(Capability.VERIFICATION_APPROVE, Capability.VERIFICATION_REJECT)
  @Patch(':id/status')
  @ApiOperation({ summary: 'Update verification status (Admin)' })
  @ApiResponse({ status: 200, description: 'Status updated' })
  async updateStatus(
    @Request() req: any,
    @Param('id') id: string,
    @Body() dto: UpdateVerificationStatusDto,
  ) {
    return this.verificationsService.updateVerificationStatus(id, req.user.id, dto);
  }
}
