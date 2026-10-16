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
    toggleShortlist(userId: string, targetProfileId: string): Promise<{
        isLiked: boolean;
        count: number;
    }>;
    getShortlistedProfiles(userId: string): Promise<any[]>;
    getShortlistedIds(userId: string): Promise<string[]>;
    getShortlistCount(userId: string): Promise<{
        count: number;
    }>;
}
