import { ChatService } from "./chat.service";
import { SendMessageDto } from "./dto/send-message.dto";
export declare class ChatController {
    private readonly chatService;
    constructor(chatService: ChatService);
    getUserConversations(req: any): Promise<any>;
    getOrCreateConversationWithPartner(req: any, partnerProfileId: string): Promise<{
        conversationId: any;
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
        messages: any;
    }>;
    getConversationMessages(req: any, conversationId: string): Promise<{
        conversationId: any;
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
        messages: any;
    }>;
    sendMessage(req: any, dto: SendMessageDto): Promise<any>;
    markAsRead(req: any, conversationId: string): Promise<any>;
}
