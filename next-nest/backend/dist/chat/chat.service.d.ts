import { PrismaService } from "../prisma/prisma.service";
import { SendMessageDto } from "./dto/send-message.dto";
export declare class ChatService {
    private readonly prisma;
    private readonly logger;
    constructor(prisma: PrismaService);
    private getMyProfile;
    getUserConversations(userId: string): Promise<{
        id: string;
        partnerProfileId: string;
        partnerProfile: {
            state: string;
            district: {
                name: string;
                gujaratiName: string;
            };
            firstName: string;
            lastName: string;
            gender: import(".prisma/client").$Enums.Gender;
            city: string;
            occupation: string;
            designation: string;
            photoUrl: string;
            photos: string;
            id: string;
        };
        lastMessage: string;
        lastMessageAt: Date;
        unreadCount: number;
        createdAt: Date;
    }[]>;
    getConversationMessages(userId: string, conversationId: string): Promise<{
        conversationId: string;
        myProfileId: string;
        partnerProfile: {
            district: {
                name: string;
                gujaratiName: string;
            };
            firstName: string;
            lastName: string;
            gender: import(".prisma/client").$Enums.Gender;
            city: string;
            occupation: string;
            designation: string;
            photoUrl: string;
            id: string;
        };
        messages: {
            content: string;
            id: string;
            createdAt: Date;
            receiverId: string;
            senderId: string;
            conversationId: string;
            isRead: boolean;
        }[];
    }>;
    getOrCreateConversationWithPartner(userId: string, partnerProfileId: string): Promise<{
        conversationId: string;
        myProfileId: string;
        partnerProfile: {
            district: {
                name: string;
                gujaratiName: string;
            };
            firstName: string;
            lastName: string;
            gender: import(".prisma/client").$Enums.Gender;
            city: string;
            occupation: string;
            designation: string;
            photoUrl: string;
            id: string;
        };
        messages: {
            content: string;
            id: string;
            createdAt: Date;
            receiverId: string;
            senderId: string;
            conversationId: string;
            isRead: boolean;
        }[];
    }>;
    sendMessage(userId: string, dto: SendMessageDto): Promise<{
        content: string;
        id: string;
        createdAt: Date;
        receiverId: string;
        senderId: string;
        conversationId: string;
        isRead: boolean;
    }>;
    markAsRead(userId: string, conversationId: string): Promise<import(".prisma/client").Prisma.BatchPayload>;
}
