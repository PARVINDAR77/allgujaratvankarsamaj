import { Body, Controller, Get, Put, UseGuards } from "@nestjs/common";
import { ApiBearerAuth, ApiOperation, ApiTags } from "@nestjs/swagger";
import { SettingsService } from "./settings.service";
import { Public } from "../auth/decorators/public.decorator";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";

@ApiTags("Settings")
@Controller()
export class SettingsController {
  constructor(private readonly settingsService: SettingsService) {}

  @Public()
  @Get("settings/public")
  @ApiOperation({
    summary: "Get public site configuration and settings for Flutter & Web",
  })
  async getPublicSettings() {
    return this.settingsService.getPublicSettings();
  }

  // @UseGuards(JwtAuthGuard)
  // @ApiBearerAuth()
  @Get("admin/settings")
  @ApiOperation({ summary: "Get all site settings for Admin Panel" })
  async getAdminSettings() {
    return this.settingsService.getAllSettings();
  }

  // @UseGuards(JwtAuthGuard)
  // @ApiBearerAuth()
  @Put("admin/settings")
  @ApiOperation({ summary: "Update site settings from Admin Panel" })
  async updateSettings(@Body() body: Record<string, any>) {
    return this.settingsService.updateSettings(body);
  }

  // --- Home Button Configs ---

  @Public()
  @Get("home-buttons")
  @ApiOperation({
    summary: "Get dynamic home button configurations for Flutter app",
  })
  async getHomeButtons() {
    return this.settingsService.getHomeButtonConfigs();
  }

  // @UseGuards(JwtAuthGuard)
  // @ApiBearerAuth()
  @Put("admin/home-buttons")
  @ApiOperation({
    summary: "Update home button configurations from Admin Panel",
  })
  async updateHomeButtons(@Body() configs: any[]) {
    return this.settingsService.updateHomeButtonConfigs(configs);
  }
}
