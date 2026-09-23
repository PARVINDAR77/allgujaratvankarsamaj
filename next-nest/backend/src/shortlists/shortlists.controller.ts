import { Body, Controller, Delete, Get, Param, Post, Request, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ShortlistsService } from './shortlists.service';
import { CreateShortlistDto } from './dto/create-shortlist.dto';

@ApiTags('Shortlists')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('shortlists')
export class ShortlistsController {
  constructor(private readonly shortlistsService: ShortlistsService) {}

  @Post()
  @ApiOperation({ summary: 'Shortlist a profile' })
  @ApiResponse({ status: 201, description: 'Profile shortlisted successfully' })
  async createShortlist(@Request() req: any, @Body() dto: CreateShortlistDto) {
    return this.shortlistsService.createShortlist(req.user.id, dto);
  }

  @Delete(':targetProfileId')
  @ApiOperation({ summary: 'Remove a profile from shortlists' })
  @ApiResponse({ status: 200, description: 'Profile removed from shortlists' })
  async removeShortlist(@Request() req: any, @Param('targetProfileId') targetProfileId: string) {
    return this.shortlistsService.removeShortlist(req.user.id, targetProfileId);
  }

  @Get()
  @ApiOperation({ summary: 'Get all shortlisted profiles' })
  @ApiResponse({ status: 200, description: 'List of shortlisted profiles' })
  async getShortlistedProfiles(@Request() req: any) {
    return this.shortlistsService.getShortlistedProfiles(req.user.id);
  }
}
