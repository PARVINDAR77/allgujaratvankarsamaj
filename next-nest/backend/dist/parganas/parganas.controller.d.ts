import { ParganasService } from "./parganas.service";
export declare class ParganasController {
    private readonly parganasService;
    constructor(parganasService: ParganasService);
    getPublicParganas(): Promise<{
        name: string;
        gujaratiName: string;
        code: string;
        description: string;
        villageCount: string;
        districtRegion: string;
        leaderName: string;
        contactPhone: string;
        totalCount: number;
        isActive: boolean;
        id: string;
    }[]>;
    getAdminParganas(): Promise<{
        name: string;
        gujaratiName: string;
        code: string;
        description: string;
        villageCount: string;
        districtRegion: string;
        leaderName: string;
        contactPhone: string;
        totalCount: number;
        isActive: boolean;
        id: string;
    }[]>;
    createPargana(body: any): Promise<{
        description: string | null;
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        isActive: boolean;
        contactPhone: string | null;
        gujaratiName: string | null;
        code: string | null;
        villageCount: string | null;
        districtRegion: string | null;
        leaderName: string | null;
        manualCount: number | null;
        totalCount: number;
    }>;
    updatePargana(id: string, body: any): Promise<{
        description: string | null;
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        isActive: boolean;
        contactPhone: string | null;
        gujaratiName: string | null;
        code: string | null;
        villageCount: string | null;
        districtRegion: string | null;
        leaderName: string | null;
        manualCount: number | null;
        totalCount: number;
    }>;
    deletePargana(id: string): Promise<{
        description: string | null;
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        isActive: boolean;
        contactPhone: string | null;
        gujaratiName: string | null;
        code: string | null;
        villageCount: string | null;
        districtRegion: string | null;
        leaderName: string | null;
        manualCount: number | null;
        totalCount: number;
    }>;
}
