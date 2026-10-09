import { NotificationsService } from "./notifications.service";
import { CreateNotificationDto } from "./dto/create-notification.dto";
export declare class NotificationsController {
    private readonly notificationsService;
    constructor(notificationsService: NotificationsService);
    findAllPublic(): Promise<{
        id: string;
        createdAt: Date;
        title: string;
        route: string | null;
        message: string;
        target: string;
    }[]>;
    findUserNotifications(req: any): Promise<{
        type: string;
        id: string;
        createdAt: Date;
        userId: string;
        title: string;
        message: string;
        metadata: string | null;
        isRead: boolean;
    }[]>;
    getUnreadCount(req: any): Promise<{
        unreadCount: number;
    }>;
    markAsRead(req: any, id: string): Promise<import(".prisma/client").Prisma.BatchPayload | {
        success: boolean;
    }>;
    markAllAsRead(req: any): Promise<import(".prisma/client").Prisma.BatchPayload | {
        success: boolean;
    }>;
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
}
