import { Injectable, NotFoundException, Logger } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";

@Injectable()
export class SamajRatnaService {
  private readonly logger = new Logger(SamajRatnaService.name);
  constructor(private prisma: PrismaService) {}

  async findAllAdmin() {
    try {
      return await this.prisma.samajRatna.findMany({
        orderBy: { displayOrder: "asc" },
      });
    } catch (e) {
      this.logger.warn("Could not query samaj_ratnas table:", e);
      return [];
    }
  }

  async findAllPublic() {
    try {
      return await this.prisma.samajRatna.findMany({
        where: { isActive: true },
        orderBy: { displayOrder: "asc" },
      });
    } catch (e) {
      this.logger.warn("Could not query samaj_ratnas table:", e);
      return [];
    }
  }

  async create(data: any) {
    return this.prisma.samajRatna.create({
      data,
    });
  }

  async update(id: string, data: any) {
    const exists = await this.prisma.samajRatna.findUnique({ where: { id } });
    if (!exists) throw new NotFoundException("Samaj Ratna not found");

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
