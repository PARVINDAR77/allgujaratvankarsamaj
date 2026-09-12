import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  UseGuards,
} from "@nestjs/common";
import { ApiBearerAuth, ApiOperation, ApiTags } from "@nestjs/swagger";
import { AdminService } from "./admin.service";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { Status } from "@prisma/client";

@ApiTags("Admin")
@Controller("admin")
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get("stats")
  @ApiOperation({ summary: "Get high-level admin dashboard statistics" })
  async getStats() {
    return this.adminService.getDashboardStats();
  }

  @Get("users")
  @ApiOperation({ summary: "Get list of all registered users for admin" })
  async getUsers() {
    return this.adminService.getAllUsers();
  }

  @Patch("users/:id/status")
  @ApiOperation({ summary: "Update a user status" })
  async updateUserStatus(
    @Param("id") id: string,
    @Body("status") status: Status
  ) {
    return this.adminService.updateUserStatus(id, status);
  }

  @Get("profiles")
  @ApiOperation({ summary: "Get list of all matrimonial profiles for moderation" })
  async getProfiles() {
    return this.adminService.getAllProfiles();
  }

  @Patch("profiles/:id/status")
  @ApiOperation({ summary: "Update profile status (APPROVED, REJECTED, SUSPENDED)" })
  async updateProfileStatus(
    @Param("id") id: string,
    @Body("status") status: any
  ) {
    return this.adminService.updateProfileStatus(id, status);
  }

  @Patch("profiles/:id/feature")
  @ApiOperation({ summary: "Toggle featured profile status" })
  async toggleProfileFeatured(
    @Param("id") id: string,
    @Body("isFeatured") isFeatured: boolean
  ) {
    return this.adminService.toggleProfileFeatured(id, isFeatured);
  }

  @Get("verifications")
  @ApiOperation({ summary: "Get verification requests for admin" })
  async getVerifications() {
    return this.adminService.getVerifications();
  }

  @Patch("verifications/:id")
  @ApiOperation({ summary: "Update verification request status" })
  async updateVerificationStatus(
    @Param("id") id: string,
    @Body("status") status: any,
    @Body("rejectionReason") rejectionReason?: string
  ) {
    return this.adminService.updateVerificationStatus(id, status, rejectionReason);
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
    @Body("status") status: any
  ) {
    return this.adminService.updateReportStatus(id, status);
  }

  @Get("matches")
  @ApiOperation({ summary: "Get match interaction list" })
  async getMatches() {
    return this.adminService.getMatches();
  }

  @Get("health")
  @ApiOperation({ summary: "Get system health status" })
  async getHealth() {
    return this.adminService.getHealthStatus();
  }
}

