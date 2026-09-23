import { Body, Controller, Get, Param, Patch, Post, Request, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { InterestsService } from './interests.service';
import { CreateInterestDto } from './dto/create-interest.dto';

@ApiTags('Interests')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('interests')
export class InterestsController {
  constructor(private readonly interestsService: InterestsService) {}

  @Post('send')
  @ApiOperation({ summary: 'Send an interest to another profile' })
  @ApiResponse({ status: 201, description: 'Interest sent successfully' })
  async sendInterest(@Request() req: any, @Body() dto: CreateInterestDto) {
    return this.interestsService.sendInterest(req.user.id, dto);
  }

  @Patch(':id/accept')
  @ApiOperation({ summary: 'Accept a received interest' })
  @ApiResponse({ status: 200, description: 'Interest accepted' })
  async acceptInterest(@Request() req: any, @Param('id') interestId: string) {
    return this.interestsService.acceptInterest(req.user.id, interestId);
  }

  @Patch(':id/decline')
  @ApiOperation({ summary: 'Decline a received interest' })
  @ApiResponse({ status: 200, description: 'Interest declined' })
  async declineInterest(@Request() req: any, @Param('id') interestId: string) {
    return this.interestsService.declineInterest(req.user.id, interestId);
  }

  @Get('sent')
  @ApiOperation({ summary: 'Get all interests sent by the user' })
  @ApiResponse({ status: 200, description: 'List of sent interests' })
  async getSentInterests(@Request() req: any) {
    return this.interestsService.getSentInterests(req.user.id);
  }

  @Get('received')
  @ApiOperation({ summary: 'Get all interests received by the user' })
  @ApiResponse({ status: 200, description: 'List of received interests' })
  async getReceivedInterests(@Request() req: any) {
    return this.interestsService.getReceivedInterests(req.user.id);
  }
}
