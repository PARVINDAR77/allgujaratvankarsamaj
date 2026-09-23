import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class StatisticsService {
  constructor(private readonly prisma: PrismaService) {}

  async getDashboardStatistics() {
    const [
      totalUsers,
      activeProfiles,
      pendingVerifications,
      openReports,
      totalSuccessStories,
      activeGovtEmployees
    ] = await Promise.all([
      this.prisma.user.count(),
      this.prisma.matrimonialProfile.count({ where: { status: 'APPROVED' } }),
      this.prisma.verificationRequest.count({ where: { status: 'PENDING' } }),
      this.prisma.report.count({ where: { status: 'OPEN' } }),
      this.prisma.successStory.count(),
      this.prisma.governmentEmployment.count({ where: { isActive: true } }),
    ]);

    // Gather some gender breakdown for active profiles
    const genderStats = await this.prisma.matrimonialProfile.groupBy({
      by: ['gender'],
      _count: {
        id: true,
      },
      where: {
        status: 'APPROVED',
      }
    });

    const breakdown = {
      MALE: 0,
      FEMALE: 0,
      OTHER: 0,
    };

    genderStats.forEach((stat) => {
      breakdown[stat.gender] = stat._count.id;
    });

    return {
      totalUsers,
      activeProfiles,
      pendingVerifications,
      openReports,
      totalSuccessStories,
      activeGovtEmployees,
      genderBreakdown: breakdown,
    };
  }

  async getTodaysBirthdays() {
    const today = new Date();
    const currentMonth = today.getMonth() + 1;
    const currentDay = today.getDate();

    const profiles = await this.prisma.matrimonialProfile.findMany({
      where: {
        status: 'APPROVED',
      },
    });

    // Filter profiles where birthday month and day match today
    const birthdayProfiles = profiles.filter((profile) => {
      const dob = new Date(profile.dateOfBirth);
      return dob.getMonth() + 1 === currentMonth && dob.getDate() === currentDay;
    });

    return birthdayProfiles;
  }
}
