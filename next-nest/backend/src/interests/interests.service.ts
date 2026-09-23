import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateInterestDto } from './dto/create-interest.dto';

@Injectable()
export class InterestsService {
  constructor(private readonly prisma: PrismaService) {}

  private async getProfileIdForUser(userId: string) {
    const profile = await this.prisma.matrimonialProfile.findUnique({
      where: { userId },
    });
    if (!profile) {
      throw new BadRequestException('You must create a profile before sending interests');
    }
    return profile.id;
  }

  async sendInterest(userId: string, dto: CreateInterestDto) {
    const senderProfileId = await this.getProfileIdForUser(userId);

    if (senderProfileId === dto.targetProfileId) {
      throw new BadRequestException('You cannot send an interest to yourself');
    }

    const existingInterest = await this.prisma.matchInterest.findFirst({
      where: {
        senderProfileId,
        receiverProfileId: dto.targetProfileId,
      },
    });

    if (existingInterest) {
      throw new BadRequestException('Interest already sent');
    }

    return this.prisma.matchInterest.create({
      data: {
        senderProfileId,
        receiverProfileId: dto.targetProfileId,
      },
    });
  }

  async acceptInterest(userId: string, interestId: string) {
    const receiverProfileId = await this.getProfileIdForUser(userId);

    const interest = await this.prisma.matchInterest.findUnique({
      where: { id: interestId },
    });

    if (!interest) {
      throw new NotFoundException('Interest not found');
    }

    if (interest.receiverProfileId !== receiverProfileId) {
      throw new BadRequestException('You can only accept interests sent to you');
    }

    return this.prisma.matchInterest.update({
      where: { id: interestId },
      data: { status: 'ACCEPTED' },
    });
  }

  async declineInterest(userId: string, interestId: string) {
    const receiverProfileId = await this.getProfileIdForUser(userId);

    const interest = await this.prisma.matchInterest.findUnique({
      where: { id: interestId },
    });

    if (!interest) {
      throw new NotFoundException('Interest not found');
    }

    if (interest.receiverProfileId !== receiverProfileId) {
      throw new BadRequestException('You can only decline interests sent to you');
    }

    return this.prisma.matchInterest.update({
      where: { id: interestId },
      data: { status: 'DECLINED' },
    });
  }

  async getSentInterests(userId: string) {
    const senderProfileId = await this.getProfileIdForUser(userId);
    return this.prisma.matchInterest.findMany({
      where: { senderProfileId },
    });
  }

  async getReceivedInterests(userId: string) {
    const receiverProfileId = await this.getProfileIdForUser(userId);
    return this.prisma.matchInterest.findMany({
      where: { receiverProfileId },
    });
  }
}
