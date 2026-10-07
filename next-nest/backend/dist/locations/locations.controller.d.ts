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
        gujaratiName: string | null;
        code: string;
    }[]>;
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
        gujaratiName: string | null;
        code: string | null;
        contactPhone: string | null;
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
        pincode: string | null;
        talukaId: string | null;
        parganaId: string | null;
        isActive: boolean;
        gujaratiName: string | null;
        code: string | null;
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
    createState(body: any): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        isActive: boolean;
        gujaratiName: string | null;
        code: string;
    }>;
    updateState(id: string, body: any): Promise<{
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
    createDistrict(body: any): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        stateId: string;
        isActive: boolean;
        gujaratiName: string | null;
        code: string | null;
    }>;
    updateDistrict(id: string, body: any): Promise<{
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
    createTaluka(body: any): Promise<{
        name: string;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        districtId: string;
        isActive: boolean;
        gujaratiName: string | null;
        code: string | null;
    }>;
    updateTaluka(id: string, body: any): Promise<{
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
        pincode: string | null;
        talukaId: string | null;
        parganaId: string | null;
        isActive: boolean;
        gujaratiName: string | null;
        code: string | null;
    })[]>;
    createVillage(body: any): Promise<{
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
    updateVillage(id: string, body: any): Promise<{
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
