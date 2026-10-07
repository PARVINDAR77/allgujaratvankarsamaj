import { PrismaService } from "../prisma/prisma.service";
import { CreateInterestDto } from "./dto/create-interest.dto";
export declare class InterestsService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    private getProfileIdForUser;
    sendInterest(userId: string, dto: CreateInterestDto): Promise<{
        status: import(".prisma/client").$Enums.InterestStatus;
        id: string;
        createdAt: Date;
        senderProfileId: string;
        receiverProfileId: string;
    }>;
    acceptInterest(userId: string, interestId: string): Promise<{
        status: import(".prisma/client").$Enums.InterestStatus;
        id: string;
        createdAt: Date;
        senderProfileId: string;
        receiverProfileId: string;
    }>;
    declineInterest(userId: string, interestId: string): Promise<{
        status: import(".prisma/client").$Enums.InterestStatus;
        id: string;
        createdAt: Date;
        senderProfileId: string;
        receiverProfileId: string;
    }>;
    getSentInterests(userId: string): Promise<{
        status: import(".prisma/client").$Enums.InterestStatus;
        id: string;
        createdAt: Date;
        senderProfileId: string;
        receiverProfileId: string;
    }[]>;
    getReceivedInterests(userId: string): Promise<{
        status: import(".prisma/client").$Enums.InterestStatus;
        id: string;
        createdAt: Date;
        senderProfileId: string;
        receiverProfileId: string;
    }[]>;
}
