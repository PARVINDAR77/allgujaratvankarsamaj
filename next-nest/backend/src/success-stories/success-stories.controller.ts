import { Body, Controller, Delete, Get, Param, Patch, Post, Request, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { SuccessStoriesService } from './success-stories.service';
import { CreateSuccessStoryDto } from './dto/create-success-story.dto';
import { UpdateSuccessStoryDto } from './dto/update-success-story.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { PermissionsGuard } from '../auth/guards/permissions.guard';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Permission } from '../auth/constants/permissions';
import { Public } from '../auth/decorators/public.decorator';

@ApiTags('Success Stories')
@Controller()
export class SuccessStoriesController {
  constructor(private readonly successStoriesService: SuccessStoriesService) {}

  @Public()
  @Get('success-stories')
  @ApiOperation({ summary: 'Get all published success stories for public app' })
  async findAllPublic() {
    return this.successStoriesService.findAllPublic();
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, PermissionsGuard)
  @Permissions(Permission.CONTENT_MANAGE)
  @Get('admin/success-stories')
  @ApiOperation({ summary: 'Get all success stories (Admin)' })
  async findAllAdmin() {
    return this.successStoriesService.findAllAdmin();
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, PermissionsGuard)
  @Permissions(Permission.CONTENT_MANAGE)
  @Get('admin/success-stories/:id')
  @ApiOperation({ summary: 'Get a specific success story by ID (Admin)' })
  async findOne(@Param('id') id: string) {
    return this.successStoriesService.findOne(id);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, PermissionsGuard)
  @Permissions(Permission.CONTENT_MANAGE)
  @Post('admin/success-stories')
  @ApiOperation({ summary: 'Create a new success story (Admin)' })
  async create(@Request() req: any, @Body() createSuccessStoryDto: CreateSuccessStoryDto) {
    return this.successStoriesService.create(createSuccessStoryDto, req.user.id);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, PermissionsGuard)
  @Permissions(Permission.CONTENT_MANAGE)
  @Patch('admin/success-stories/:id')
  @ApiOperation({ summary: 'Update a success story (Admin)' })
  async update(@Request() req: any, @Param('id') id: string, @Body() updateSuccessStoryDto: UpdateSuccessStoryDto) {
    return this.successStoriesService.update(id, updateSuccessStoryDto, req.user.id);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, PermissionsGuard)
  @Permissions(Permission.CONTENT_MANAGE)
  @Delete('admin/success-stories/:id')
  @ApiOperation({ summary: 'Delete a success story (Admin)' })
  async remove(@Request() req: any, @Param('id') id: string) {
    return this.successStoriesService.remove(id, req.user.id);
  }
}
