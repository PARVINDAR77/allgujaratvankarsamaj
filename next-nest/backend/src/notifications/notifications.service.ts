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

  // --- User Notifications (Personal connection requests, accepts, chat alerts) ---

  async getUserNotifications(userId: string) {
    try {
      const userNotifs = await this.prisma.userNotification.findMany({
        where: { userId },
        orderBy: { createdAt: "desc" },
        take: 50,
      });
      return userNotifs;
    } catch (err: any) {
      this.logger.warn("Could not query user_notifications:", err?.message);
      return [];
    }
  }

  async markAsRead(userId: string, notificationId: string) {
    try {
      return await this.prisma.userNotification.updateMany({
        where: { id: notificationId, userId },
        data: { isRead: true },
      });
    } catch (err: any) {
      this.logger.warn("Could not mark notification as read:", err?.message);
      return { success: false };
    }
  }

  async markAllAsRead(userId: string) {
    try {
      return await this.prisma.userNotification.updateMany({
        where: { userId, isRead: false },
        data: { isRead: true },
      });
    } catch (err: any) {
      this.logger.warn("Could not mark all notifications as read:", err?.message);
      return { success: false };
    }
  }

  async getUnreadCount(userId: string) {
    try {
      const count = await this.prisma.userNotification.count({
        where: { userId, isRead: false },
      });
      return { unreadCount: count };
    } catch (err: any) {
      return { unreadCount: 0 };
    }
  }
}
