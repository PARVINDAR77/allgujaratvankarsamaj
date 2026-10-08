import { SamajServicesService } from "./samaj-services.service";
import { CreateServicePersonDto } from "./dto/create-service-person.dto";
import { UpdateServicePersonDto } from "./dto/update-service-person.dto";
export declare class SamajServicesController {
    private readonly samajServicesService;
    constructor(samajServicesService: SamajServicesService);
    getPublicServices(search?: string, category?: string): Promise<{
        id: string;
        title: string;
        category: string;
        icon: string;
        contactPhone: string;
        contactPerson: string;
        description: string;
        isActive: boolean;
        _count: {
            persons: number;
        };
    }[]>;
    getPublicServiceById(id: string): Promise<{
        persons: {
            description: string | null;
            name: string;
            id: string;
            phone: string;
            createdAt: Date;
            updatedAt: Date;
            userId: string | null;
            city: string | null;
            photoUrl: string | null;
            districtId: string | null;
            talukaId: string | null;
            villageId: string | null;
            isActive: boolean;
            gujaratiName: string | null;
            serviceId: string;
            address: string | null;
            experience: string | null;
        }[];
    } & {
        description: string | null;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        isActive: boolean;
        title: string;
        sortOrder: number;
        slug: string;
        category: string;
        icon: string;
        contactPhone: string | null;
        contactPerson: string | null;
    }>;
    getPublicPersonsByServiceId(serviceId: string, district?: string, taluka?: string, village?: string, search?: string): Promise<{
        id: string;
        serviceId: string;
        name: string;
        gujaratiName: string;
        photoUrl: string;
        phone: string;
        address: string;
        city: string;
        description: string;
        experience: string;
        isActive: boolean;
        service: {
            id: string;
            title: string;
            category: string;
            icon: string;
        };
    }[]>;
    getAdminServices(): Promise<{
        id: string;
        title: string;
        category: string;
        icon: string;
        contactPhone: string;
        contactPerson: string;
        description: string;
        isActive: boolean;
        _count: {
            persons: number;
        };
    }[]>;
    createService(body: any): Promise<{
        description: string | null;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        isActive: boolean;
        title: string;
        sortOrder: number;
        slug: string;
        category: string;
        icon: string;
        contactPhone: string | null;
        contactPerson: string | null;
    }>;
    updateService(id: string, body: any): Promise<{
        description: string | null;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        isActive: boolean;
        title: string;
        sortOrder: number;
        slug: string;
        category: string;
        icon: string;
        contactPhone: string | null;
        contactPerson: string | null;
    }>;
    deleteService(id: string): Promise<{
        description: string | null;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        isActive: boolean;
        title: string;
        sortOrder: number;
        slug: string;
        category: string;
        icon: string;
        contactPhone: string | null;
        contactPerson: string | null;
    }>;
    getAdminServicePersons(serviceId?: string): Promise<({
        service: {
            id: string;
            title: string;
            category: string;
            icon: string;
        };
    } & {
        description: string | null;
        name: string;
        id: string;
        phone: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string | null;
        city: string | null;
        photoUrl: string | null;
        districtId: string | null;
        talukaId: string | null;
        villageId: string | null;
        isActive: boolean;
        gujaratiName: string | null;
        serviceId: string;
        address: string | null;
        experience: string | null;
    })[]>;
    createServicePerson(dto: CreateServicePersonDto): Promise<{
        service: {
            id: string;
            title: string;
            category: string;
        };
    } & {
        description: string | null;
        name: string;
        id: string;
        phone: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string | null;
        city: string | null;
        photoUrl: string | null;
        districtId: string | null;
        talukaId: string | null;
        villageId: string | null;
        isActive: boolean;
        gujaratiName: string | null;
        serviceId: string;
        address: string | null;
        experience: string | null;
    }>;
    updateServicePerson(id: string, dto: UpdateServicePersonDto): Promise<{
        service: {
            id: string;
            title: string;
            category: string;
        };
    } & {
        description: string | null;
        name: string;
        id: string;
        phone: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string | null;
        city: string | null;
        photoUrl: string | null;
        districtId: string | null;
        talukaId: string | null;
        villageId: string | null;
        isActive: boolean;
        gujaratiName: string | null;
        serviceId: string;
        address: string | null;
        experience: string | null;
    }>;
    deleteServicePerson(id: string): Promise<{
        description: string | null;
        name: string;
        id: string;
        phone: string;
        createdAt: Date;
        updatedAt: Date;
        userId: string | null;
        city: string | null;
        photoUrl: string | null;
        districtId: string | null;
        talukaId: string | null;
        villageId: string | null;
        isActive: boolean;
        gujaratiName: string | null;
        serviceId: string;
        address: string | null;
        experience: string | null;
    }>;
}
