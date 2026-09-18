import { Controller, Get } from '@nestjs/common';
import { StatisticsService } from './statistics.service';

@Controller('statistics')
export class StatisticsController {
  constructor(private readonly statisticsService: StatisticsService) {}

  @Get('dashboard')
  async getDashboardStatistics() {
    return this.statisticsService.getDashboardStatistics();
  }

  @Get('birthdays')
  async getTodaysBirthdays() {
    return this.statisticsService.getTodaysBirthdays();
  }
}
