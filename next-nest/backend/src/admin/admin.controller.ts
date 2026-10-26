import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Delete,
  UseGuards,
  Query,
} from "@nestjs/common";
import { ApiBearerAuth, ApiOperation, ApiTags } from "@nestjs/swagger";
import { AdminService } from "./admin.service";
import { OtpService } from "../otp/otp.service";
import { AdminOtpQueryDto } from "../otp/dto/otp.dto";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { Status } from "@prisma/client";

@ApiTags("Admin")
@Controller("admin")
export class AdminController {
  constructor(
    private readonly adminService: AdminService,
    private readonly otpService: OtpService,
  ) {}

  @Get("stats")
  @ApiOperation({ summary: "Get high-level admin dashboard statistics" })
  async getStats() {
    return this.adminService.getDashboardStats();
  }

  @Get("otp-analytics/summary")
  @ApiOperation({ summary: "Get daily OTP usage metrics and summary for Super Admin" })
  async getOtpSummary() {
    return this.otpService.getDailySummary();
  }

  @Get("otp-analytics/daily-trends")
  @ApiOperation({ summary: "Get daily trends for OTP activity over last N days" })
  async getOtpTrends(@Query("days") days?: string) {
    const parsedDays = days ? parseInt(days, 10) : 7;
    return this.otpService.getDailyTrends(parsedDays);
  }

  @Get("otp-analytics/logs")
  @ApiOperation({ summary: "Get filterable paginated audit logs of all OTP dispatches" })
  async getOtpLogs(@Query() query: AdminOtpQueryDto) {
    return this.otpService.getLogs(query);
  }

  @Get("reports")
  @ApiOperation({ summary: "Get user reports for moderation" })
  async getReports() {
    return this.adminService.getReports();
  }

  @Patch("reports/:id")
  @ApiOperation({ summary: "Update report status" })
  async updateReportStatus(
    @Param("id") id: string,
    @Body("status") status: any,
  ) {
    return this.adminService.updateReportStatus(id, status);
  }

  @Get("matches")
  @ApiOperation({ summary: "Get match interaction list" })
  async getMatches(
    @Query("status") status?: string,
    @Query("search") search?: string,
  ) {
    return this.adminService.getMatches(status, search);
  }

  @Delete("matches/:id")
  @ApiOperation({ summary: "Delete or unlink a match interest" })
  async deleteMatch(@Param("id") id: string) {
    return this.adminService.deleteMatch(id);
  }

  @Get("health")
  @ApiOperation({ summary: "Get system health status" })
  async getHealth() {
    return this.adminService.getHealthStatus();
  }

  @Get("photos/pending")
  @ApiOperation({ summary: "Get all pending unverified profile photos" })
  async getPendingPhotos() {
    return this.adminService.getPendingPhotos();
  }

  @Get("shortlists")
  @ApiOperation({ summary: "Get global shortlists for moderation" })
  async getShortlists() {
    return this.adminService.getShortlists();
  }
}

