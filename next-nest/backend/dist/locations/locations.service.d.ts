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
        gujaratiName: string | null;
        code: string;
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
        gujaratiName: string | null;
        code: string;
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
        gujaratiName: string | null;
        code: string;
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
        gujaratiName: string | null;
        code: string;
    }>;
    deleteState(id: string): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        isActive: boolean;
        gujaratiName: string | null;
        code: string;
    }>;
    getPublicDistricts(stateId?: string): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        stateId: string;
        isActive: boolean;
        gujaratiName: string | null;
        code: string | null;
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
        gujaratiName: string | null;
        code: string | null;
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
        gujaratiName: string | null;
        code: string | null;
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
        gujaratiName: string | null;
        code: string | null;
    }>;
    deleteDistrict(id: string): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        stateId: string;
        isActive: boolean;
        gujaratiName: string | null;
        code: string | null;
    }>;
    getPublicTalukas(districtId?: string): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        districtId: string;
        isActive: boolean;
        gujaratiName: string | null;
        code: string | null;
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
        gujaratiName: string | null;
        code: string | null;
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
        gujaratiName: string | null;
        code: string | null;
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
        gujaratiName: string | null;
        code: string | null;
    }>;
    deleteTaluka(id: string): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        districtId: string;
        isActive: boolean;
        gujaratiName: string | null;
        code: string | null;
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
        contactPhone: string | null;
        gujaratiName: string | null;
        code: string | null;
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
        contactPhone: string | null;
        gujaratiName: string | null;
        code: string | null;
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
        pincode: string | null;
        talukaId: string | null;
        parganaId: string | null;
        isActive: boolean;
        gujaratiName: string | null;
        code: string | null;
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
        pincode: string | null;
        talukaId: string | null;
        parganaId: string | null;
        isActive: boolean;
        gujaratiName: string | null;
        code: string | null;
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
        pincode: string | null;
        talukaId: string | null;
        parganaId: string | null;
        isActive: boolean;
        gujaratiName: string | null;
        code: string | null;
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
        pincode: string | null;
        talukaId: string | null;
        parganaId: string | null;
        isActive: boolean;
        gujaratiName: string | null;
        code: string | null;
    }>;
    deleteVillage(id: string): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        pincode: string | null;
        talukaId: string | null;
        parganaId: string | null;
        isActive: boolean;
        gujaratiName: string | null;
        code: string | null;
    }>;
}
