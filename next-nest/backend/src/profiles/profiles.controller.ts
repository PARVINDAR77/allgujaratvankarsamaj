import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Patch,
  Post,
  Query,
  Request,
  UseGuards,
} from "@nestjs/common";
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from "@nestjs/swagger";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { Public } from "../auth/decorators/public.decorator";
import { CreateProfileDto } from "./dto/create-profile.dto";
import { UpdateProfileDto } from "./dto/update-profile.dto";
import { BaseProfileQueryDto } from "./dto/profile-query.dto";
import { ProfilesService } from "./profiles.service";

@ApiTags("Matrimonial Profile")
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller("profiles")
export class ProfilesController {
  constructor(private readonly profilesService: ProfilesService) {}

  @Public()
  @Get()
  @ApiOperation({ summary: "List and search matrimonial candidate profiles" })
  async getProfiles(@Query() query: BaseProfileQueryDto) {
    return this.profilesService.getProfiles(query);
  }

  @Get("reference-data")
  @ApiOperation({
    summary: "Get profile static reference options (gender, maritalStatus)",
  })
  @ApiResponse({
    status: 200,
    description: "Static reference data arrays for profile options",
    schema: {
      example: {
        gender: ["MALE", "FEMALE", "OTHER"],
        maritalStatus: ["NEVER_MARRIED", "DIVORCED", "WIDOWED", "SEPARATED"],
      },
    },
  })
  @ApiResponse({ status: 401, description: "Unauthorized access" })
  getReferenceData() {
    return this.profilesService.getReferenceData();
  }

  @Get("completeness")
  @ApiOperation({
    summary: "Get profile completeness calculation for authenticated user",
  })
  @ApiResponse({
    status: 200,
    description: "Profile completion statistics",
    schema: {
      example: {
        completedFields: 10,
        totalFields: 13,
        percentage: 77,
        isComplete: false,
      },
    },
  })
  @ApiResponse({ status: 401, description: "Unauthorized access" })
  async getProfileCompleteness(@Request() req: any) {
    return this.profilesService.getProfileCompletenessByUserId(req.user.id);
  }

  @Post()
  @ApiOperation({
    summary: "Create matrimonial profile for authenticated user",
  })
  @ApiResponse({
    status: 201,
    description: "Profile created successfully",
  })
  @ApiResponse({ status: 400, description: "Validation failed" })
  @ApiResponse({ status: 401, description: "Unauthorized access" })
  @ApiResponse({ status: 409, description: "Profile already exists" })
  async createProfile(@Request() req: any, @Body() dto: CreateProfileDto) {
    return this.profilesService.createProfile(req.user.id, dto);
  }

  @Get("me")
  @ApiOperation({ summary: "Get matrimonial profile of authenticated user" })
  @ApiResponse({
    status: 200,
    description: "Authenticated user matrimonial profile",
  })
  @ApiResponse({ status: 401, description: "Unauthorized access" })
  @ApiResponse({ status: 404, description: "Profile not found" })
  async getMyProfile(@Request() req: any) {
    return this.profilesService.getProfileByUserId(req.user.id);
  }

  @Patch("me")
  @ApiOperation({ summary: "Update matrimonial profile of authenticated user" })
  @ApiResponse({
    status: 200,
    description: "Profile updated successfully",
  })
  @ApiResponse({ status: 400, description: "Validation failed" })
  @ApiResponse({ status: 401, description: "Unauthorized access" })
  @ApiResponse({ status: 404, description: "Profile not found" })
  async updateMyProfile(@Request() req: any, @Body() dto: UpdateProfileDto) {
    return this.profilesService.updateProfileByUserId(req.user.id, dto);
  }

  @Delete("me")
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Delete matrimonial profile of authenticated user" })
  @ApiResponse({
    status: 200,
    description: "Profile deleted successfully",
  })
  @ApiResponse({ status: 401, description: "Unauthorized access" })
  @ApiResponse({ status: 404, description: "Profile not found" })
  async deleteMyProfile(@Request() req: any) {
    return this.profilesService.deleteProfileByUserId(req.user.id);
  }

  @Public()
  @Get(":id")
  @ApiOperation({ summary: "Get public details of a matrimonial profile by ID" })
  @ApiResponse({
    status: 200,
    description: "Profile details",
  })
  @ApiResponse({ status: 404, description: "Profile not found" })
  async getProfileById(@Request() req: any) {
    return this.profilesService.getProfileById(req.params.id);
  }
}
