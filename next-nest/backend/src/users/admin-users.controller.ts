import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  UseGuards,
  Request,
  ForbiddenException,
} from "@nestjs/common";
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from "@nestjs/swagger";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { PermissionsGuard } from "../auth/guards/permissions.guard";
import { Permissions } from "../auth/decorators/permissions.decorator";
import { Permission } from "../auth/constants/permissions";
import { UsersService } from "./users.service";
import { Role, Status } from "@prisma/client";

@ApiTags("Admin Users")
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, PermissionsGuard)
@Controller("admin")
export class AdminUsersController {
  constructor(private readonly usersService: UsersService) {}

  @Permissions(Permission.MEMBERS_READ)
  @Get("users")
  @ApiOperation({ summary: "Get list of all registered users (Admin)" })
  @ApiResponse({ status: 200, description: "List of users" })
  async getUsersAdmin() {
    return this.usersService.getAllUsersForAdmin();
  }

  @Permissions(Permission.MEMBERS_UPDATE)
  @Patch("users/:id/status")
  @ApiOperation({ summary: "Update a user status (Admin)" })
  @ApiResponse({ status: 200, description: "User status updated" })
  async updateUserStatusAdmin(
    @Request() req: any,
    @Param("id") id: string,
    @Body("status") status: Status,
  ) {
    const ipAddress = req.ip || req.connection?.remoteAddress || null;
    return this.usersService.updateUserStatusAdmin(
      id,
      req.user.id,
      status,
      ipAddress,
    );
  }

  @Permissions(Permission.MEMBERS_UPDATE)
  @Patch("users/:id/role")
  @ApiOperation({ summary: "Update a user role (Admin)" })
  @ApiResponse({ status: 200, description: "User role updated" })
  async updateUserRoleAdmin(
    @Request() req: any,
    @Param("id") id: string,
    @Body("role") role: Role,
  ) {
    if (req.user.role !== Role.SUPER_ADMIN) {
      throw new ForbiddenException("Only SUPER_ADMIN can change roles");
    }
    const ipAddress = req.ip || req.connection?.remoteAddress || null;
    return this.usersService.updateUserRoleAdmin(
      id,
      req.user.id,
      role,
      ipAddress,
    );
  }

  @Permissions(Permission.MEMBERS_READ)
  @Get("profiles")
  @ApiOperation({ summary: "Get list of all matrimonial profiles (Admin)" })
  @ApiResponse({ status: 200, description: "List of profiles" })
  async getProfilesAdmin() {
    return this.usersService.getAllProfilesForAdmin();
  }

  @Permissions(Permission.MEMBERS_UPDATE)
  @Patch("profiles/:id/status")
  @ApiOperation({ summary: "Update profile status (Admin)" })
  async updateProfileStatusAdmin(
    @Request() req: any,
    @Param("id") id: string,
    @Body("status") status: string,
  ) {
    const ipAddress = req.ip || req.connection?.remoteAddress || null;
    return this.usersService.updateProfileStatusAdmin(
      id,
      req.user.id,
      status,
      ipAddress,
    );
  }

  @Permissions(Permission.MEMBERS_UPDATE)
  @Patch("profiles/:id/feature")
  @ApiOperation({ summary: "Toggle featured profile status (Admin)" })
  async toggleProfileFeaturedAdmin(
    @Request() req: any,
    @Param("id") id: string,
    @Body("isFeatured") isFeatured: boolean,
  ) {
    const ipAddress = req.ip || req.connection?.remoteAddress || null;
    return this.usersService.toggleProfileFeaturedAdmin(
      id,
      req.user.id,
      isFeatured,
      ipAddress,
    );
  }

  @Permissions(Permission.MEMBERS_DELETE)
  @Delete("users/:id")
  @ApiOperation({
    summary: "Permanently delete user and all associated data (Admin / Super Admin)",
  })
  @ApiResponse({ status: 200, description: "User account deleted successfully" })
  async deleteUserAdmin(
    @Request() req: any,
    @Param("id") id: string,
  ) {
    if (req.user.role !== Role.SUPER_ADMIN && req.user.role !== Role.ADMIN) {
      throw new ForbiddenException(
        "માત્ર સુપર એડમિન અથવા એડમિન વપરાશકર્તા એકાઉન્ટ ડિલીટ કરી શકે છે (Only SUPER_ADMIN or ADMIN can delete accounts)",
      );
    }
    const ipAddress = req.ip || req.connection?.remoteAddress || null;
    return this.usersService.deleteUserAccount(id, req.user.id, ipAddress);
  }

  @Permissions(Permission.MEMBERS_DELETE)
  @Delete("profiles/:id")
  @ApiOperation({
    summary: "Permanently delete matrimonial profile (Admin / Super Admin)",
  })
  @ApiResponse({ status: 200, description: "Matrimonial profile deleted successfully" })
  async deleteProfileAdmin(
    @Request() req: any,
    @Param("id") id: string,
  ) {
    if (req.user.role !== Role.SUPER_ADMIN && req.user.role !== Role.ADMIN) {
      throw new ForbiddenException(
        "માત્ર સુપર એડમિન અથવા એડમિન પ્રોફાઇલ ડિલીટ કરી શકે છે (Only SUPER_ADMIN or ADMIN can delete profiles)",
      );
    }
    const ipAddress = req.ip || req.connection?.remoteAddress || null;
    return this.usersService.deleteProfileAdmin(id, req.user.id, ipAddress);
  }
}

