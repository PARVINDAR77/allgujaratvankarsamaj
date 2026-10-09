import { PrismaService } from "../prisma/prisma.service";
import { CreateNotificationDto } from "./dto/create-notification.dto";
export declare class NotificationsService {
    private readonly prisma;
    private readonly logger;
    constructor(prisma: PrismaService);
    findAllPublic(): Promise<{
        id: string;
        createdAt: Date;
        title: string;
        route: string | null;
        message: string;
        target: string;
    }[]>;
    findAllAdmin(): Promise<{
        id: string;
        createdAt: Date;
        title: string;
        route: string | null;
        message: string;
        target: string;
    }[]>;
    create(dto: CreateNotificationDto): Promise<{
        id: string;
        createdAt: Date;
        title: string;
        route: string | null;
        message: string;
        target: string;
    }>;
    remove(id: string): Promise<{
        id: string;
        createdAt: Date;
        title: string;
        route: string | null;
        message: string;
        target: string;
    }>;
    getUserNotifications(userId: string): Promise<{
        type: string;
        id: string;
        createdAt: Date;
        userId: string;
        title: string;
        message: string;
        metadata: string | null;
        isRead: boolean;
    }[]>;
    markAsRead(userId: string, notificationId: string): Promise<import(".prisma/client").Prisma.BatchPayload | {
        success: boolean;
    }>;
    markAllAsRead(userId: string): Promise<import(".prisma/client").Prisma.BatchPayload | {
        success: boolean;
    }>;
    getUnreadCount(userId: string): Promise<{
        unreadCount: number;
    }>;
}
