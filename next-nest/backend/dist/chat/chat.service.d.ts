import { PrismaService } from "../prisma/prisma.service";
import { SendMessageDto } from "./dto/send-message.dto";
export declare class ChatService {
    private readonly prisma;
    private readonly logger;
    constructor(prisma: PrismaService);
    private getMyProfile;
    getUserConversations(userId: string): Promise<any>;
    getConversationMessages(userId: string, conversationId: string): Promise<{
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
    getOrCreateConversationWithPartner(userId: string, partnerProfileId: string): Promise<{
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
    sendMessage(userId: string, dto: SendMessageDto): Promise<any>;
    markAsRead(userId: string, conversationId: string): Promise<any>;
}
