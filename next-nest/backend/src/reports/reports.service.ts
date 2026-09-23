import { BadRequestException, Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateReportDto } from './dto/create-report.dto';

@Injectable()
export class ReportsService {
  constructor(private readonly prisma: PrismaService) {}

  async createReport(reporterUserId: string, dto: CreateReportDto) {
    const targetProfile = await this.prisma.matrimonialProfile.findUnique({
      where: { id: dto.targetProfileId }
    });

    if (!targetProfile) {
      throw new BadRequestException('Target profile not found');
    }

    if (targetProfile.userId === reporterUserId) {
      throw new BadRequestException('You cannot report yourself');
    }

    // Optionally check if a report already exists to prevent spam

    return this.prisma.report.create({
      data: {
        reporterUserId,
        targetProfileId: dto.targetProfileId,
        reason: dto.reason,
        details: dto.details,
      },
    });
  }

  async getMyReports(reporterUserId: string) {
    return this.prisma.report.findMany({
      where: { reporterUserId },
    });
  }
}
