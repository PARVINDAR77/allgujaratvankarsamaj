import { PrismaService } from "../prisma/prisma.service";
import { CreateNotificationDto } from "./dto/create-notification.dto";
export declare class NotificationsService {
    private readonly prisma;
    private readonly logger;
    constructor(prisma: PrismaService);
    findAllPublic(): Promise<{
        title: string;
        id: string;
        createdAt: Date;
        message: string;
        route: string | null;
        target: string;
    }[]>;
    findAllAdmin(): Promise<{
        title: string;
        id: string;
        createdAt: Date;
        message: string;
        route: string | null;
        target: string;
    }[]>;
    create(dto: CreateNotificationDto): Promise<{
        title: string;
        id: string;
        createdAt: Date;
        message: string;
        route: string | null;
        target: string;
    }>;
    remove(id: string): Promise<{
        title: string;
        id: string;
        createdAt: Date;
        message: string;
        route: string | null;
        target: string;
    }>;
    getUserNotifications(userId: string): Promise<{
        type: string;
        title: string;
        id: string;
        createdAt: Date;
        userId: string;
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
