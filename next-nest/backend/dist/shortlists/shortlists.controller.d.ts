import { ShortlistsService } from "./shortlists.service";
import { CreateShortlistDto } from "./dto/create-shortlist.dto";
export declare class ShortlistsController {
    private readonly shortlistsService;
    constructor(shortlistsService: ShortlistsService);
    createShortlist(req: any, dto: CreateShortlistDto): Promise<{
        id: string;
        createdAt: Date;
        userId: string;
        targetProfileId: string;
    }>;
    removeShortlist(req: any, targetProfileId: string): Promise<{
        id: string;
        createdAt: Date;
        userId: string;
        targetProfileId: string;
    }>;
    getShortlistedProfiles(req: any): Promise<{
        id: string;
        createdAt: Date;
        userId: string;
        targetProfileId: string;
    }[]>;
}
