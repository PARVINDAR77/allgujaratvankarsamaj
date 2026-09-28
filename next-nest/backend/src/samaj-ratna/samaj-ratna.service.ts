import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class SamajRatnaService {
  constructor(private prisma: PrismaService) {}

  async findAllAdmin() {
    return this.prisma.samajRatna.findMany({
      orderBy: { displayOrder: 'asc' },
    });
  }

  async findAllPublic() {
    return this.prisma.samajRatna.findMany({
      where: { isActive: true },
      orderBy: { displayOrder: 'asc' },
    });
  }

  async create(data: any) {
    return this.prisma.samajRatna.create({
      data,
    });
  }

  async update(id: string, data: any) {
    const exists = await this.prisma.samajRatna.findUnique({ where: { id } });
    if (!exists) throw new NotFoundException('Samaj Ratna not found');
    
    return this.prisma.samajRatna.update({
      where: { id },
      data,
    });
  }

  async remove(id: string) {
    return this.prisma.samajRatna.delete({
      where: { id },
    });
  }
}
