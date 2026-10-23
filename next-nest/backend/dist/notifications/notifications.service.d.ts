import { PrismaService } from "../prisma/prisma.service";
import { CreateNotificationDto } from "./dto/create-notification.dto";
export declare class NotificationsService {
    private readonly prisma;
    private readonly logger;
    constructor(prisma: PrismaService);
    findAllPublic(): Promise<any>;
    findAllAdmin(): Promise<any>;
    create(dto: CreateNotificationDto): Promise<any>;
    remove(id: string): Promise<any>;
    getUserNotifications(userId: string): Promise<any>;
    markAsRead(userId: string, notificationId: string): Promise<any>;
    markAllAsRead(userId: string): Promise<any>;
    getUnreadCount(userId: string): Promise<{
        unreadCount: any;
    }>;
}
