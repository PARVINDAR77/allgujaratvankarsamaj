import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { StatisticsService } from './statistics.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { PermissionsGuard } from '../auth/guards/permissions.guard';
import { Permissions } from '../auth/decorators/permissions.decorator';
import { Permission } from '../auth/constants/permissions';

@ApiTags('Statistics')
@Controller()
export class StatisticsController {
  constructor(private readonly statisticsService: StatisticsService) {}

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, PermissionsGuard)
  @Permissions(Permission.STATISTICS_VIEW)
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
