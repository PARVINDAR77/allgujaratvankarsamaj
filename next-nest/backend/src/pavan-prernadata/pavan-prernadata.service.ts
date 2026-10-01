import { Injectable, NotFoundException } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";

@Injectable()
export class PavanPrernadataService {
  constructor(private prisma: PrismaService) {}

  async findAllAdmin() {
    return this.prisma.pavanPrernadata.findMany({
      orderBy: { displayOrder: "asc" },
    });
  }

  async findAllPublic() {
    return this.prisma.pavanPrernadata.findMany({
      where: { isActive: true },
      orderBy: { displayOrder: "asc" },
    });
  }

  async create(data: any) {
    return this.prisma.pavanPrernadata.create({
      data,
    });
  }

  async update(id: string, data: any) {
    const exists = await this.prisma.pavanPrernadata.findUnique({ where: { id } });
    if (!exists) throw new NotFoundException("Pavan Prernadata not found");

    return this.prisma.pavanPrernadata.update({
      where: { id },
      data,
    });
  }

  async remove(id: string) {
    return this.prisma.pavanPrernadata.delete({
      where: { id },
    });
  }
}
