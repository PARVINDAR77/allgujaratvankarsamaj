import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  Req,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GovernmentEmployeesService } from './government-employees.service';
import {
  CreateGovtEmploymentDto,
  UpdateGovtEmploymentDto,
  SubmitVerificationDto,
  GovtEmployeeSearchQueryDto,
  AdminVerifyGovtEmpDto,
  AdminFeatureGovtEmpDto,
  AdminStatusGovtEmpDto,
  CreateDepartmentDto,
  CreateDesignationDto,
} from './dto/government-employees.dto';

@ApiTags('Government Employees')
@Controller()
export class GovernmentEmployeesController {
  constructor(private readonly govtEmployeesService: GovernmentEmployeesService) {}

  // ==========================================
  // PUBLIC / MEMBER MASTER DATA & SEARCH
  // ==========================================

  @Get('government-employees/departments')
  @ApiOperation({ summary: 'Get active government departments & designations' })
  getDepartments() {
    return this.govtEmployeesService.getMasterDepartments();
  }

  @Get('government-employees')
  @ApiOperation({ summary: 'Search & filter verified government employee profiles' })
  searchPublic(@Query() query: GovtEmployeeSearchQueryDto) {
    return this.govtEmployeesService.searchPublicGovtEmployees(query);
  }

  @Get('government-employees/featured')
  @ApiOperation({ summary: 'Get featured government employee profiles' })
  getFeatured() {
    return this.govtEmployeesService.getFeaturedGovtEmployees();
  }

  // ==========================================
  // AUTHENTICATED MEMBER ENDPOINTS (/me)
  // ==========================================

  @Get('government-employees/me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get current user government employment profile' })
  getMyEmployment(@Req() req: any) {
    return this.govtEmployeesService.getMyEmployment(req.user.id);
  }

  @Post('government-employees/me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create current user government employment profile' })
  createMyEmployment(@Req() req: any, @Body() dto: CreateGovtEmploymentDto) {
    return this.govtEmployeesService.createMyEmployment(req.user.id, dto);
  }

  @Patch('government-employees/me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update current user government employment profile' })
  updateMyEmployment(@Req() req: any, @Body() dto: UpdateGovtEmploymentDto) {
    return this.govtEmployeesService.updateMyEmployment(req.user.id, dto);
  }

  @Post('government-employees/me/verification')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Submit verification proof document for government employment' })
  submitVerification(@Req() req: any, @Body() dto: SubmitVerificationDto) {
    return this.govtEmployeesService.submitMyVerification(req.user.id, dto);
  }

  @Get('government-employees/:id')
  @ApiOperation({ summary: 'Get public details of a verified government employee' })
  getPublicById(@Param('id') id: string) {
    return this.govtEmployeesService.getPublicGovtProfileById(id);
  }

  // ==========================================
  // ADMIN PANEL MANAGED ENDPOINTS
  // ==========================================

  @Get('admin/government-employees/stats')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get Admin dashboard government employee statistics' })
  getAdminStats() {
    return this.govtEmployeesService.getAdminStats();
  }

  @Get('admin/government-employees')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get all government employee profiles for Admin review' })
  getAdminProfiles(
    @Query('page') page?: number,
    @Query('limit') limit?: number,
    @Query('status') status?: string,
  ) {
    return this.govtEmployeesService.getAdminGovtEmployees(
      Number(page) || 1,
      Number(limit) || 20,
      status,
    );
  }

  @Patch('admin/government-employees/:id/verify')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Approve or Reject government employment verification' })
  verifyProfile(
    @Req() req: any,
    @Param('id') id: string,
    @Body() dto: AdminVerifyGovtEmpDto,
  ) {
    return this.govtEmployeesService.verifyGovtEmployee(id, dto, req.user.id);
  }

  @Patch('admin/government-employees/:id/feature')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Set government employment featured status' })
  setFeatured(
    @Req() req: any,
    @Param('id') id: string,
    @Body() dto: AdminFeatureGovtEmpDto,
  ) {
    return this.govtEmployeesService.setGovtEmployeeFeatured(id, dto, req.user.id);
  }

  @Patch('admin/government-employees/:id/status')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Set government employment active status' })
  setStatus(
    @Req() req: any,
    @Param('id') id: string,
    @Body() dto: AdminStatusGovtEmpDto,
  ) {
    return this.govtEmployeesService.setGovtEmployeeStatus(id, dto, req.user.id);
  }

  // Admin Master Data CRUD
  @Post('admin/government-departments')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  createDepartment(@Req() req: any, @Body() dto: CreateDepartmentDto) {
    return this.govtEmployeesService.createDepartment(dto, req.user.id);
  }

  @Patch('admin/government-departments/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  updateDepartment(@Req() req: any, @Param('id') id: string, @Body() dto: Partial<CreateDepartmentDto>) {
    return this.govtEmployeesService.updateDepartment(id, dto, req.user.id);
  }

  @Delete('admin/government-departments/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  deleteDepartment(@Req() req: any, @Param('id') id: string) {
    return this.govtEmployeesService.softDeleteDepartment(id, req.user.id);
  }

  @Post('admin/government-designations')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  createDesignation(@Req() req: any, @Body() dto: CreateDesignationDto) {
    return this.govtEmployeesService.createDesignation(dto, req.user.id);
  }

  @Patch('admin/government-designations/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  updateDesignation(@Req() req: any, @Param('id') id: string, @Body() dto: Partial<CreateDesignationDto>) {
    return this.govtEmployeesService.updateDesignation(id, dto, req.user.id);
  }

  @Delete('admin/government-designations/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  deleteDesignation(@Req() req: any, @Param('id') id: string) {
    return this.govtEmployeesService.softDeleteDesignation(id, req.user.id);
  }
}
