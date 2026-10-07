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
}
