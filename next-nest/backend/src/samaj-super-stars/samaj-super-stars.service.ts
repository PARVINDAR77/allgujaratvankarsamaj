import { Injectable, NotFoundException } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";

@Injectable()
export class SamajSuperStarsService {
  constructor(private prisma: PrismaService) {}

  async findAllAdmin() {
    return this.prisma.samajSuperStar.findMany({
      orderBy: { displayOrder: "asc" },
    });
  }

  async findAllPublic() {
    return this.prisma.samajSuperStar.findMany({
      where: { isActive: true },
      orderBy: { displayOrder: "asc" },
    });
  }

  async create(data: any) {
    return this.prisma.samajSuperStar.create({
      data,
    });
  }

  async update(id: string, data: any) {
    const exists = await this.prisma.samajSuperStar.findUnique({ where: { id } });
    if (!exists) throw new NotFoundException("Samaj Super Star not found");

    return this.prisma.samajSuperStar.update({
      where: { id },
      data,
    });
  }

  async remove(id: string) {
    return this.prisma.samajSuperStar.delete({
      where: { id },
    });
  }
}
