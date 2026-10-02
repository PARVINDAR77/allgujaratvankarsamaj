import { Injectable, NotFoundException, Logger } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";

@Injectable()
export class SamajSuperStarsService {
  private readonly logger = new Logger(SamajSuperStarsService.name);
  constructor(private prisma: PrismaService) {}

  async findAllAdmin() {
    try {
      return await this.prisma.samajSuperStar.findMany({
        orderBy: { displayOrder: "asc" },
      });
    } catch (e) {
      this.logger.warn("Could not query samaj_super_stars table:", e);
      return [];
    }
  }

  async findAllPublic() {
    try {
      return await this.prisma.samajSuperStar.findMany({
        where: { isActive: true },
        orderBy: { displayOrder: "asc" },
      });
    } catch (e) {
      this.logger.warn("Could not query samaj_super_stars table:", e);
      return [];
    }
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
