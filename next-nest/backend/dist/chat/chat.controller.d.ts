import { ChatService } from "./chat.service";
import { SendMessageDto } from "./dto/send-message.dto";
export declare class ChatController {
    private readonly chatService;
    constructor(chatService: ChatService);
    getUserConversations(req: any): Promise<{
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
    getOrCreateConversationWithPartner(req: any, partnerProfileId: string): Promise<{
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
    getConversationMessages(req: any, conversationId: string): Promise<{
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
    sendMessage(req: any, dto: SendMessageDto): Promise<{
        content: string;
        id: string;
        createdAt: Date;
        conversationId: string;
        isRead: boolean;
        senderId: string;
        receiverId: string;
    }>;
    markAsRead(req: any, conversationId: string): Promise<import(".prisma/client").Prisma.BatchPayload>;
}
