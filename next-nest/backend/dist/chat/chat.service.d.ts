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
            id: string;
            gender: import(".prisma/client").$Enums.Gender;
            firstName: string;
            lastName: string;
            city: string;
            occupation: string;
            designation: string;
            photoUrl: string;
            photos: string;
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
            id: string;
            gender: import(".prisma/client").$Enums.Gender;
            firstName: string;
            lastName: string;
            city: string;
            occupation: string;
            designation: string;
            photoUrl: string;
        };
        messages: {
            content: string;
            id: string;
            createdAt: Date;
            conversationId: string;
            isRead: boolean;
            senderId: string;
            receiverId: string;
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
            id: string;
            gender: import(".prisma/client").$Enums.Gender;
            firstName: string;
            lastName: string;
            city: string;
            occupation: string;
            designation: string;
            photoUrl: string;
        };
        messages: {
            content: string;
            id: string;
            createdAt: Date;
            conversationId: string;
            isRead: boolean;
            senderId: string;
            receiverId: string;
        }[];
    }>;
    sendMessage(userId: string, dto: SendMessageDto): Promise<{
        content: string;
        id: string;
        createdAt: Date;
        conversationId: string;
        isRead: boolean;
        senderId: string;
        receiverId: string;
    }>;
    markAsRead(userId: string, conversationId: string): Promise<import(".prisma/client").Prisma.BatchPayload>;
}
