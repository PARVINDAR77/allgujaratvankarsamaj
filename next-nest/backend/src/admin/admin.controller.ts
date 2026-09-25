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

