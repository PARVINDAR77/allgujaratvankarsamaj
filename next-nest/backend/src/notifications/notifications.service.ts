import { Injectable, Logger, NotFoundException } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";
import { CreateNotificationDto } from "./dto/create-notification.dto";

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(private readonly prisma: PrismaService) {}

  async findAllPublic() {
    try {
      return await this.prisma.systemNotification.findMany({
        orderBy: { createdAt: "desc" },
        take: 50,
      });
    } catch (err: any) {
      this.logger.warn("Could not query system_notifications:", err?.message);
      return [];
    }
  }

  async findAllAdmin() {
    try {
      return await this.prisma.systemNotification.findMany({
        orderBy: { createdAt: "desc" },
      });
    } catch (err: any) {
      this.logger.warn("Could not query system_notifications:", err?.message);
      return [];
    }
  }

  async create(dto: CreateNotificationDto) {
    return this.prisma.systemNotification.create({
      data: {
        title: dto.title,
        message: dto.message,
        target: dto.target || "ALL",
        route: dto.route || null,
      },
    });
  }

  async remove(id: string) {
    const exists = await this.prisma.systemNotification.findUnique({
      where: { id },
    });
    if (!exists) {
      throw new NotFoundException("Notification not found");
    }
    return this.prisma.systemNotification.delete({
      where: { id },
    });
  }
}
