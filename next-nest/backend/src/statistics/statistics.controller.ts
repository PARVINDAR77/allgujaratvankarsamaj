import { Controller, Get, Post, Param, UseGuards } from "@nestjs/common";
import { ApiBearerAuth, ApiOperation, ApiTags } from "@nestjs/swagger";
import { StatisticsService } from "./statistics.service";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { CapabilitiesGuard } from "../auth/guards/capabilities.guard";
import { Capabilities } from "../auth/decorators/capabilities.decorator";
import { Capability } from "../auth/constants/capabilities";
import { Public } from "../auth/decorators/public.decorator";

@ApiTags("Statistics")
@Controller()
export class StatisticsController {
  constructor(private readonly statisticsService: StatisticsService) {}

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, CapabilitiesGuard)
  @Capabilities(Capability.STATISTICS_READ)
  @Get("admin/statistics/dashboard")
  @ApiOperation({ summary: "Get Admin Dashboard Statistics" })
  async getDashboardStatistics() {
    return this.statisticsService.getDashboardStatistics();
  }

  @Public()
  @Get("statistics/dashboard")
  @ApiOperation({ summary: "Get Public Live Statistics" })
  async getPublicDashboard() {
    return this.statisticsService.getPublicLiveStatistics();
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Get("statistics/birthdays")
  @ApiOperation({ summary: "Get Todays Birthdays" })
  async getTodaysBirthdays() {
    return this.statisticsService.getTodaysBirthdays();
  }
  @Get("statistics/views")
  @ApiOperation({ summary: "Get all section views" })
  async getSectionViews() {
    return this.statisticsService.getSectionViews();
  }

  @Post("statistics/views/:sectionName/increment")
  @ApiOperation({ summary: "Increment a section view" })
  async incrementSectionView(@Param("sectionName") sectionName: string) {
    return this.statisticsService.incrementSectionView(sectionName);
  }
}
