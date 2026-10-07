import { PrismaService } from "../prisma/prisma.service";
import { CreateShortlistDto } from "./dto/create-shortlist.dto";
export declare class ShortlistsService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    createShortlist(userId: string, dto: CreateShortlistDto): Promise<{
        id: string;
        createdAt: Date;
        userId: string;
        targetProfileId: string;
    }>;
    removeShortlist(userId: string, targetProfileId: string): Promise<{
        id: string;
        createdAt: Date;
        userId: string;
        targetProfileId: string;
    }>;
    getShortlistedProfiles(userId: string): Promise<{
        id: string;
        createdAt: Date;
        userId: string;
        targetProfileId: string;
    }[]>;
}
