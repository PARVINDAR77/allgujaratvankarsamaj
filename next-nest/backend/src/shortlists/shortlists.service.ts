import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateShortlistDto } from './dto/create-shortlist.dto';

@Injectable()
export class ShortlistsService {
  constructor(private readonly prisma: PrismaService) {}

  async createShortlist(userId: string, dto: CreateShortlistDto) {
    const existing = await this.prisma.shortlist.findUnique({
      where: {
        userId_targetProfileId: {
          userId,
          targetProfileId: dto.targetProfileId,
        },
      },
    });

    if (existing) {
      throw new BadRequestException('Profile is already shortlisted');
    }

    return this.prisma.shortlist.create({
      data: {
        userId,
        targetProfileId: dto.targetProfileId,
      },
    });
  }

  async removeShortlist(userId: string, targetProfileId: string) {
    try {
      return await this.prisma.shortlist.delete({
        where: {
          userId_targetProfileId: {
            userId,
            targetProfileId,
          },
        },
      });
    } catch (e) {
      throw new NotFoundException('Shortlist entry not found');
    }
  }

  async getShortlistedProfiles(userId: string) {
    return this.prisma.shortlist.findMany({
      where: { userId },
    });
  }
}
