import { Body, Controller, Delete, Get, Param, Patch, Post, Request, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { AdvertisementsService } from './advertisements.service';
import { CreateAdvertisementDto } from './dto/create-advertisement.dto';
import { UpdateAdvertisementDto } from './dto/update-advertisement.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CapabilitiesGuard } from '../auth/guards/capabilities.guard';
import { Capabilities } from '../auth/decorators/capabilities.decorator';
import { Capability } from '../auth/constants/capabilities';
import { Public } from '../auth/decorators/public.decorator';

@ApiTags('Advertisements')
@Controller()
export class AdvertisementsController {
  constructor(private readonly advertisementsService: AdvertisementsService) {}

  @Public()
  @Get('advertisements')
  @ApiOperation({ summary: 'Get all active advertisements for the public app' })
  async findAllPublic() {
    return this.advertisementsService.findAllPublic();
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, CapabilitiesGuard)
  @Capabilities(Capability.ADVERTISEMENTS_MANAGE)
  @Get('admin/advertisements')
  @ApiOperation({ summary: 'Get all advertisements (Admin)' })
  async findAllAdmin() {
    return this.advertisementsService.findAllAdmin();
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, CapabilitiesGuard)
  @Capabilities(Capability.ADVERTISEMENTS_MANAGE)
  @Get('admin/advertisements/:id')
  @ApiOperation({ summary: 'Get a specific advertisement by ID (Admin)' })
  async findOne(@Param('id') id: string) {
    return this.advertisementsService.findOne(id);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, CapabilitiesGuard)
  @Capabilities(Capability.ADVERTISEMENTS_MANAGE)
  @Post('admin/advertisements')
  @ApiOperation({ summary: 'Create a new advertisement (Admin)' })
  async create(@Request() req: any, @Body() createAdvertisementDto: CreateAdvertisementDto) {
    return this.advertisementsService.create(createAdvertisementDto, req.user.id);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, CapabilitiesGuard)
  @Capabilities(Capability.ADVERTISEMENTS_MANAGE)
  @Patch('admin/advertisements/:id')
  @ApiOperation({ summary: 'Update an advertisement (Admin)' })
  async update(@Request() req: any, @Param('id') id: string, @Body() updateAdvertisementDto: UpdateAdvertisementDto) {
    return this.advertisementsService.update(id, updateAdvertisementDto, req.user.id);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, CapabilitiesGuard)
  @Capabilities(Capability.ADVERTISEMENTS_MANAGE)
  @Delete('admin/advertisements/:id')
  @ApiOperation({ summary: 'Delete an advertisement (Admin)' })
  async remove(@Request() req: any, @Param('id') id: string) {
    return this.advertisementsService.remove(id, req.user.id);
  }
}
