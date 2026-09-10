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

  @Get("health")
  @ApiOperation({ summary: "Get system health status" })
  async getHealth() {
    return this.adminService.getHealthStatus();
  }
}
