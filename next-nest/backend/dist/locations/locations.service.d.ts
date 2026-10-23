import { PrismaService } from "../prisma/prisma.service";
export declare class LocationsService {
    private readonly prisma;
    private readonly logger;
    constructor(prisma: PrismaService);
    seedInitialLocations(): Promise<void>;
    getPublicStates(): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        isActive: boolean;
        code: string;
        gujaratiName: string | null;
    }[]>;
    getAdminStates(): Promise<({
        _count: {
            districts: number;
        };
    } & {
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        isActive: boolean;
        code: string;
        gujaratiName: string | null;
    })[]>;
    createState(data: {
        name: string;
        gujaratiName?: string;
        code: string;
        isActive?: boolean;
    }): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        isActive: boolean;
        code: string;
        gujaratiName: string | null;
    }>;
    updateState(id: string, data: Partial<{
        name: string;
        gujaratiName: string;
        code: string;
        isActive: boolean;
    }>): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        isActive: boolean;
        code: string;
        gujaratiName: string | null;
    }>;
    deleteState(id: string): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        isActive: boolean;
        code: string;
        gujaratiName: string | null;
    }>;
    getPublicDistricts(stateId?: string): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        stateId: string;
        isActive: boolean;
        code: string | null;
        gujaratiName: string | null;
    }[]>;
    getAdminDistricts(stateId?: string): Promise<({
        state: {
            name: string;
            id: string;
            gujaratiName: string;
        };
        _count: {
            talukas: number;
        };
    } & {
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        stateId: string;
        isActive: boolean;
        code: string | null;
        gujaratiName: string | null;
    })[]>;
    createDistrict(data: {
        stateId: string;
        name: string;
        gujaratiName?: string;
        code?: string;
        isActive?: boolean;
    }): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        stateId: string;
        isActive: boolean;
        code: string | null;
        gujaratiName: string | null;
    }>;
    updateDistrict(id: string, data: Partial<{
        stateId: string;
        name: string;
        gujaratiName: string;
        code: string;
        isActive: boolean;
    }>): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        stateId: string;
        isActive: boolean;
        code: string | null;
        gujaratiName: string | null;
    }>;
    deleteDistrict(id: string): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        stateId: string;
        isActive: boolean;
        code: string | null;
        gujaratiName: string | null;
    }>;
    getPublicTalukas(districtId?: string): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        districtId: string;
        isActive: boolean;
        code: string | null;
        gujaratiName: string | null;
    }[]>;
    getAdminTalukas(districtId?: string): Promise<({
        district: {
            name: string;
            id: string;
            gujaratiName: string;
        };
        _count: {
            villages: number;
        };
    } & {
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        districtId: string;
        isActive: boolean;
        code: string | null;
        gujaratiName: string | null;
    })[]>;
    createTaluka(data: {
        districtId: string;
        name: string;
        gujaratiName?: string;
        code?: string;
        isActive?: boolean;
    }): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        districtId: string;
        isActive: boolean;
        code: string | null;
        gujaratiName: string | null;
    }>;
    updateTaluka(id: string, data: Partial<{
        districtId: string;
        name: string;
        gujaratiName: string;
        code: string;
        isActive: boolean;
    }>): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        districtId: string;
        isActive: boolean;
        code: string | null;
        gujaratiName: string | null;
    }>;
    deleteTaluka(id: string): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        districtId: string;
        isActive: boolean;
        code: string | null;
        gujaratiName: string | null;
    }>;
    getPublicParganas(talukaId?: string): Promise<{
        computedVillageCount: string;
        _count: {
            villages: number;
        };
        description: string | null;
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        isActive: boolean;
        code: string | null;
        contactPhone: string | null;
        gujaratiName: string | null;
        villageCount: string | null;
        districtRegion: string | null;
        leaderName: string | null;
        manualCount: number | null;
        totalCount: number;
    }[]>;
    getAdminParganas(): Promise<{
        computedVillageCount: string;
        _count: {
            villages: number;
        };
        talukas: ({
            taluka: {
                name: string;
                id: string;
                gujaratiName: string;
            };
        } & {
            talukaId: string;
            parganaId: string;
        })[];
        description: string | null;
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        isActive: boolean;
        code: string | null;
        contactPhone: string | null;
        gujaratiName: string | null;
        villageCount: string | null;
        districtRegion: string | null;
        leaderName: string | null;
        manualCount: number | null;
        totalCount: number;
    }[]>;
    getPublicVillages(query: {
        parganaId?: string;
        talukaId?: string;
        search?: string;
    }): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        talukaId: string | null;
        parganaId: string | null;
        isActive: boolean;
        code: string | null;
        pincode: string | null;
        gujaratiName: string | null;
    }[]>;
    getAdminVillages(query: {
        parganaId?: string;
        talukaId?: string;
        search?: string;
    }): Promise<({
        taluka: {
            name: string;
            id: string;
            gujaratiName: string;
        };
        pargana: {
            name: string;
            id: string;
            gujaratiName: string;
        };
    } & {
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        talukaId: string | null;
        parganaId: string | null;
        isActive: boolean;
        code: string | null;
        pincode: string | null;
        gujaratiName: string | null;
    })[]>;
    createVillage(data: {
        parganaId?: string;
        talukaId?: string;
        name: string;
        gujaratiName?: string;
        code?: string;
        pincode?: string;
        isActive?: boolean;
    }): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        talukaId: string | null;
        parganaId: string | null;
        isActive: boolean;
        code: string | null;
        pincode: string | null;
        gujaratiName: string | null;
    }>;
    updateVillage(id: string, data: Partial<{
        parganaId: string;
        talukaId: string;
        name: string;
        gujaratiName: string;
        code: string;
        pincode: string;
        isActive: boolean;
    }>): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        talukaId: string | null;
        parganaId: string | null;
        isActive: boolean;
        code: string | null;
        pincode: string | null;
        gujaratiName: string | null;
    }>;
    deleteVillage(id: string): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        talukaId: string | null;
        parganaId: string | null;
        isActive: boolean;
        code: string | null;
        pincode: string | null;
        gujaratiName: string | null;
    }>;
}
