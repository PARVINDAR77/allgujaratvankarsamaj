import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class StatisticsService {
  constructor(private readonly prisma: PrismaService) {}

  async getDashboardStatistics() {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // 1. Live counter for today (Boys/Girls)
    const todayProfiles = await this.prisma.matrimonialProfile.findMany({
      where: {
        createdAt: {
          gte: today,
        },
      },
      select: { gender: true },
    });

    let boysToday = 0;
    let girlsToday = 0;
    for (const p of todayProfiles) {
      if (p.gender === 'MALE') boysToday++;
      else if (p.gender === 'FEMALE') girlsToday++;
    }

    // 2. Total number of candidates
    const totalCandidates = await this.prisma.matrimonialProfile.count();

    // 3. Department breakdown
    // Government
    const governmentProfiles = await this.prisma.governmentEmployment.findMany({
      select: { employmentType: true },
    });

    const govMap = new Map<string, number>();
    for (const p of governmentProfiles) {
      const dept = p.employmentType || 'Other Govt';
      govMap.set(dept, (govMap.get(dept) || 0) + 1);
    }
    const governmentStats = Array.from(govMap.entries()).map(([name, count]) => ({
      name,
      count,
    }));

    // Private (using occupation field)
    const privateProfiles = await this.prisma.matrimonialProfile.findMany({
      where: {
        governmentEmployment: {
          is: null,
        },
        occupation: {
          not: null,
          notIn: [''],
        },
      },
      select: { occupation: true },
    });

    const privMap = new Map<string, number>();
    for (const p of privateProfiles) {
      const occ = p.occupation || 'Private / Other';
      privMap.set(occ, (privMap.get(occ) || 0) + 1);
    }
    const privateStats = Array.from(privMap.entries())
      .map(([name, count]) => ({ name, count }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 20);

    return {
      today: {
        boys: boysToday,
        girls: girlsToday,
        total: boysToday + girlsToday,
      },
      totalCandidates,
      departments: {
        government: governmentStats,
        private: privateStats,
      },
    };
  }

  async getTodaysBirthdays() {
    const today = new Date();
    const currentMonth = today.getMonth() + 1;
    const currentDay = today.getDate();

    // Fetch all profiles and filter in JS to avoid raw SQL dialect issues
    // Alternatively, use raw SQL. For now, we fetch select fields and filter.
    const allProfiles = await this.prisma.matrimonialProfile.findMany({
      select: {
        id: true,
        firstName: true,
        lastName: true,
        gender: true,
        photoUrl: true,
        dateOfBirth: true,
      },
    });

    const birthdays = allProfiles.filter((p) => {
      const dob = new Date(p.dateOfBirth);
      return dob.getMonth() + 1 === currentMonth && dob.getDate() === currentDay;
    });

    return birthdays.map(p => {
      const dob = new Date(p.dateOfBirth);
      let age = today.getFullYear() - dob.getFullYear();
      if (today.getMonth() < dob.getMonth() || (today.getMonth() === dob.getMonth() && today.getDate() < dob.getDate())) {
        age--;
      }
      return {
        ...p,
        age,
      };
    });
  }
}
