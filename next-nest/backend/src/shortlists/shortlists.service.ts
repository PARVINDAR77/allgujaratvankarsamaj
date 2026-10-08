import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";
import { CreateShortlistDto } from "./dto/create-shortlist.dto";

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
      throw new BadRequestException("Profile is already shortlisted");
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
      throw new NotFoundException("Shortlist entry not found");
    }
  }

  async toggleShortlist(userId: string, targetProfileId: string) {
    const existing = await this.prisma.shortlist.findUnique({
      where: {
        userId_targetProfileId: {
          userId,
          targetProfileId,
        },
      },
    });

    if (existing) {
      await this.prisma.shortlist.delete({
        where: { id: existing.id },
      });
      const count = await this.prisma.shortlist.count({ where: { userId } });
      return { isLiked: false, count };
    } else {
      await this.prisma.shortlist.create({
        data: {
          userId,
          targetProfileId,
        },
      });
      const count = await this.prisma.shortlist.count({ where: { userId } });
      return { isLiked: true, count };
    }
  }

  async getShortlistedProfiles(userId: string) {
    const list = await this.prisma.shortlist.findMany({
      where: { userId },
      orderBy: { createdAt: "desc" },
    });

    if (list.length === 0) return [];

    const targetIds = list.map((s) => s.targetProfileId);
    const profiles = await this.prisma.matrimonialProfile.findMany({
      where: { id: { in: targetIds } },
      include: {
        district: true,
        taluka: true,
        pargana: true,
        village: true,
      },
    });

    const profileMap = new Map(profiles.map((p) => [p.id, p]));
    return targetIds
      .map((id) => profileMap.get(id))
      .filter((p) => p !== undefined);
  }

  async getShortlistedIds(userId: string): Promise<string[]> {
    const list = await this.prisma.shortlist.findMany({
      where: { userId },
      select: { targetProfileId: true },
    });
    return list.map((s) => s.targetProfileId);
  }

  async getShortlistCount(userId: string): Promise<{ count: number }> {
    const count = await this.prisma.shortlist.count({ where: { userId } });
    return { count };
  }
}
