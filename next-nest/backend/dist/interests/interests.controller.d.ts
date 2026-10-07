import { InterestsService } from "./interests.service";
import { CreateInterestDto } from "./dto/create-interest.dto";
export declare class InterestsController {
    private readonly interestsService;
    constructor(interestsService: InterestsService);
    sendInterest(req: any, dto: CreateInterestDto): Promise<{
        status: import(".prisma/client").$Enums.InterestStatus;
        id: string;
        createdAt: Date;
        senderProfileId: string;
        receiverProfileId: string;
    }>;
    acceptInterest(req: any, interestId: string): Promise<{
        status: import(".prisma/client").$Enums.InterestStatus;
        id: string;
        createdAt: Date;
        senderProfileId: string;
        receiverProfileId: string;
    }>;
    declineInterest(req: any, interestId: string): Promise<{
        status: import(".prisma/client").$Enums.InterestStatus;
        id: string;
        createdAt: Date;
        senderProfileId: string;
        receiverProfileId: string;
    }>;
    getSentInterests(req: any): Promise<{
        status: import(".prisma/client").$Enums.InterestStatus;
        id: string;
        createdAt: Date;
        senderProfileId: string;
        receiverProfileId: string;
    }[]>;
    getReceivedInterests(req: any): Promise<{
        status: import(".prisma/client").$Enums.InterestStatus;
        id: string;
        createdAt: Date;
        senderProfileId: string;
        receiverProfileId: string;
    }[]>;
}
