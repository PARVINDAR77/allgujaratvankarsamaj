import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateAdvertisementDto } from './dto/create-advertisement.dto';
import { UpdateAdvertisementDto } from './dto/update-advertisement.dto';

@Injectable()
export class AdvertisementsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(createAdvertisementDto: CreateAdvertisementDto, adminId: string) {
    const ad = await this.prisma.advertisement.create({
      data: {
        ...createAdvertisementDto,
        createdBy: adminId,
      },
    });
    
    await this.prisma.adminAuditLog.create({
      data: {
        adminId,
        action: 'CREATE_AD',
        entityType: 'Advertisement',
        entityId: ad.id,
        newValue: JSON.stringify(ad),
      }
    });
    return ad;
  }

  async findAllPublic() {
    const now = new Date();
    return this.prisma.advertisement.findMany({
      where: {
        isActive: true,
        OR: [
          { startAt: null },
          { startAt: { lte: now } }
        ],
        AND: [
          {
            OR: [
              { endAt: null },
              { endAt: { gte: now } }
            ]
          }
        ]
      },
      orderBy: { sortOrder: 'asc' },
    });
  }

  async findAllAdmin() {
    return this.prisma.advertisement.findMany({
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: string) {
    const ad = await this.prisma.advertisement.findUnique({
      where: { id },
    });
    if (!ad) {
      throw new NotFoundException('Advertisement not found');
    }
    return ad;
  }

  async update(id: string, updateAdvertisementDto: UpdateAdvertisementDto, adminId: string) {
    const oldAd = await this.findOne(id);
    const updated = await this.prisma.advertisement.update({
      where: { id },
      data: updateAdvertisementDto,
    });
    
    await this.prisma.adminAuditLog.create({
      data: {
        adminId,
        action: 'UPDATE_AD',
        entityType: 'Advertisement',
        entityId: id,
        oldValue: JSON.stringify(oldAd),
        newValue: JSON.stringify(updated),
      }
    });

    return updated;
  }

  async remove(id: string, adminId: string) {
    const oldAd = await this.findOne(id);
    const deleted = await this.prisma.advertisement.delete({
      where: { id },
    });
    
    await this.prisma.adminAuditLog.create({
      data: {
        adminId,
        action: 'DELETE_AD',
        entityType: 'Advertisement',
        entityId: id,
        oldValue: JSON.stringify(oldAd),
      }
    });
    
    return deleted;
  }
}
