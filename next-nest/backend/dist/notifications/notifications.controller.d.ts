import { NotificationsService } from "./notifications.service";
import { CreateNotificationDto } from "./dto/create-notification.dto";
export declare class NotificationsController {
    private readonly notificationsService;
    constructor(notificationsService: NotificationsService);
    findAllPublic(): Promise<any>;
    findUserNotifications(req: any): Promise<any>;
    getUnreadCount(req: any): Promise<{
        unreadCount: any;
    }>;
    markAsRead(req: any, id: string): Promise<any>;
    markAllAsRead(req: any): Promise<any>;
    findAllAdmin(): Promise<any>;
    create(dto: CreateNotificationDto): Promise<any>;
    remove(id: string): Promise<any>;
}
