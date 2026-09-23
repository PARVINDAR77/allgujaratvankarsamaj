import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { StatisticsService } from './statistics.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CapabilitiesGuard } from '../auth/guards/capabilities.guard';
import { Capabilities } from '../auth/decorators/capabilities.decorator';
import { Capability } from '../auth/constants/capabilities';

@ApiTags('Statistics')
@Controller()
export class StatisticsController {
  constructor(private readonly statisticsService: StatisticsService) {}

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, CapabilitiesGuard)
  @Capabilities(Capability.STATISTICS_READ)
  @Get('admin/statistics/dashboard')
  @ApiOperation({ summary: 'Get Admin Dashboard Statistics' })
  async getDashboardStatistics() {
    return this.statisticsService.getDashboardStatistics();
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Get('statistics/birthdays')
  @ApiOperation({ summary: 'Get Todays Birthdays' })
  async getTodaysBirthdays() {
    return this.statisticsService.getTodaysBirthdays();
  }
}
