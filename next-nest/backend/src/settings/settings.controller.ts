import { Body, Controller, Get, Put } from "@nestjs/common";
import { ApiOperation, ApiTags } from "@nestjs/swagger";
import { SettingsService } from "./settings.service";
import { Public } from "../auth/decorators/public.decorator";

@ApiTags("Settings")
@Controller()
export class SettingsController {
  constructor(private readonly settingsService: SettingsService) {}

  @Public()
  @Get("settings/public")
  @ApiOperation({ summary: "Get public site configuration and settings for Flutter & Web" })
  async getPublicSettings() {
    return this.settingsService.getPublicSettings();
  }

  @Get("admin/settings")
  @ApiOperation({ summary: "Get all site settings for Admin Panel" })
  async getAdminSettings() {
    return this.settingsService.getAllSettings();
  }

  @Put("admin/settings")
  @ApiOperation({ summary: "Update site settings from Admin Panel" })
  async updateSettings(@Body() body: Record<string, any>) {
    return this.settingsService.updateSettings(body);
  }
}
