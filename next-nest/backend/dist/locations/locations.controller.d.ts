import { LocationsService } from "./locations.service";
export declare class LocationsController {
    private readonly locationsService;
    constructor(locationsService: LocationsService);
    getPublicStates(): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        isActive: boolean;
        code: string;
        gujaratiName: string | null;
    }[]>;
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
    getPublicVillages(parganaId?: string, talukaId?: string, search?: string): Promise<{
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
    createState(body: any): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        isActive: boolean;
        code: string;
        gujaratiName: string | null;
    }>;
    updateState(id: string, body: any): Promise<{
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
    createDistrict(body: any): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        stateId: string;
        isActive: boolean;
        code: string | null;
        gujaratiName: string | null;
    }>;
    updateDistrict(id: string, body: any): Promise<{
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
    createTaluka(body: any): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        districtId: string;
        isActive: boolean;
        code: string | null;
        gujaratiName: string | null;
    }>;
    updateTaluka(id: string, body: any): Promise<{
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
    getAdminVillages(parganaId?: string, talukaId?: string, search?: string): Promise<({
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
    createVillage(body: any): Promise<{
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
    updateVillage(id: string, body: any): Promise<{
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
