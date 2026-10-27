import { NotificationsService } from "./notifications.service";
import { CreateNotificationDto } from "./dto/create-notification.dto";
export declare class NotificationsController {
    private readonly notificationsService;
    constructor(notificationsService: NotificationsService);
    findAllPublic(): Promise<{
        title: string;
        id: string;
        createdAt: Date;
        message: string;
        route: string | null;
        target: string;
    }[]>;
    findUserNotifications(req: any): Promise<{
        type: string;
        title: string;
        id: string;
        createdAt: Date;
        userId: string;
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
}
