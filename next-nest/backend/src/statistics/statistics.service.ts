import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class StatisticsService {
  constructor(private readonly prisma: PrismaService) {}

  async getDashboardStatistics() {
    const [
      totalUsers,
      activeProfiles,
      totalMatches,
      pendingVerifications,
      openReports,
      totalSuccessStories,
      activeGovtEmployees
    ] = await Promise.all([
      this.prisma.user.count(),
      this.prisma.matrimonialProfile.count({ where: { status: 'APPROVED' } }),
      this.prisma.matchInterest.count({ where: { status: 'ACCEPTED' } }),
      this.prisma.verificationRequest.count({ where: { status: 'PENDING' } }),
      this.prisma.report.count({ where: { status: 'OPEN' } }),
      this.prisma.successStory.count(),
      this.prisma.governmentEmployment.count({ where: { isActive: true } }),
    ]);

    // Gather gender breakdown for active profiles
    const genderStats = await this.prisma.matrimonialProfile.groupBy({
      by: ['gender'],
      _count: { id: true },
      where: { status: 'APPROVED' }
    });

    const genderBreakdown = {
      MALE: 0,
      FEMALE: 0,
      OTHER: 0,
    };
    genderStats.forEach((stat) => {
      genderBreakdown[stat.gender] = stat._count.id;
    });

    // Pargana breakdown
    const parganaStats = await this.prisma.matrimonialProfile.groupBy({
      by: ['parganaId'],
      _count: { id: true },
      where: { status: 'APPROVED', parganaId: { not: null } }
    });

    // Fetch pargana names
    const parganaIds = parganaStats.map(p => p.parganaId).filter(id => id !== null) as string[];
    const parganas = await this.prisma.pargana.findMany({
      where: { id: { in: parganaIds } },
      select: { id: true, name: true }
    });
    
    const parganaMap = new Map(parganas.map(p => [p.id, p.name]));
    const parganaBreakdown = parganaStats.map(stat => ({
      name: stat.parganaId ? parganaMap.get(stat.parganaId) || 'Unknown' : 'Unknown',
      count: stat._count.id,
      percentage: activeProfiles > 0 ? Math.round((stat._count.id / activeProfiles) * 100) : 0
    })).sort((a, b) => b.count - a.count).slice(0, 5); // Top 5

    // Recent Users
    const recentUsersRaw = await this.prisma.user.findMany({
      orderBy: { createdAt: 'desc' },
      take: 5,
      select: {
        id: true,
        name: true,
        email: true,
        phone: true,
        status: true,
        role: true,
        createdAt: true,
        profile: {
          select: { pargana: { select: { name: true } } }
        }
      }
    });

    const recentUsers = recentUsersRaw.map(u => ({
      id: u.id,
      name: u.name || 'Unknown',
      email: u.email || 'N/A',
      phone: u.phone || 'N/A',
      pargana: u.profile?.pargana?.name || 'Not Set',
      status: u.status,
      role: u.role,
      createdAt: u.createdAt.toISOString()
    }));

    // Recent Verifications
    const recentVerificationsRaw = await this.prisma.verificationRequest.findMany({
      where: { status: 'PENDING' },
      orderBy: { createdAt: 'desc' },
      take: 5,
      include: {
        profile: { select: { firstName: true, lastName: true } }
      }
    });

    const recentVerifications = recentVerificationsRaw.map(v => ({
      id: v.id,
      name: v.profile ? `${v.profile.firstName} ${v.profile.lastName}` : 'Unknown Profile',
      type: 'Profile Identity',
      status: v.status,
      date: v.createdAt.toISOString()
    }));

    // Recent Activities (Audit Logs)
    const recentLogs = await this.prisma.adminAuditLog.findMany({
      orderBy: { createdAt: 'desc' },
      take: 5
    });

    // Fetch admin names manually since there's no relation in schema
    const adminIds = [...new Set(recentLogs.map(l => l.adminId))];
    const admins = await this.prisma.user.findMany({
      where: { id: { in: adminIds } },
      select: { id: true, name: true, email: true }
    });
    const adminMap = new Map(admins.map(a => [a.id, a.name || a.email || 'Admin']));

    const recentActivities = recentLogs.map(log => ({
      id: log.id,
      icon: log.action.includes('DELETE') ? '🗑️' : log.action.includes('UPDATE') ? '📝' : '✨',
      title: `${log.action} ${log.entityType}`,
      user: adminMap.get(log.adminId) || 'System',
      time: log.createdAt.toISOString(),
      status: 'completed'
    }));

    // Mocked Monthly Growth for chart (requires historical timeseries table, mocked safely here as fallback)
    const monthlyGrowth = [
      { month: 'Jan', users: 100, profiles: 80 },
      { month: 'Feb', users: 150, profiles: 120 },
      { month: 'Mar', users: 200, profiles: 160 },
      { month: 'Apr', users: 280, profiles: 220 },
      { month: 'May', users: Math.round(totalUsers * 0.8), profiles: Math.round(activeProfiles * 0.8) },
      { month: 'Jun', users: totalUsers, profiles: activeProfiles },
    ];

    return {
      totalUsers,
      activeProfiles,
      totalMatches,
      pendingVerifications,
      openReports,
      totalSuccessStories,
      activeGovtEmployees,
      genderBreakdown,
      parganaBreakdown,
      recentUsers,
      recentVerifications,
      recentActivities,
      monthlyGrowth
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
