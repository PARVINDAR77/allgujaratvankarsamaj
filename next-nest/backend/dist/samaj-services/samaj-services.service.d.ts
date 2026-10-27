import { PrismaService } from "../prisma/prisma.service";
import { CreateServicePersonDto } from "./dto/create-service-person.dto";
import { UpdateServicePersonDto } from "./dto/update-service-person.dto";
export declare class SamajServicesService {
    private readonly prisma;
    private readonly logger;
    constructor(prisma: PrismaService);
    private readonly defaultServices;
    syncMissingBusinessProfiles(): Promise<void>;
    fixDatabaseRecords(): Promise<{
        success: boolean;
        message: string;
        totalPersons: number;
        persons: {
            id: string;
            name: string;
            gujaratiName: string;
            phone: string;
            city: string;
            service: string;
            category: string;
        }[];
        servicesWithCounts: {
            title: string;
            category: string;
            count: number;
        }[];
    }>;
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
    getPublicServiceById(id: string): Promise<({
        persons: {
            description: string | null;
            name: string;
            city: string | null;
            photoUrl: string | null;
            id: string;
            createdAt: Date;
            updatedAt: Date;
            districtId: string | null;
            talukaId: string | null;
            userId: string | null;
            villageId: string | null;
            phone: string;
            isActive: boolean;
            gujaratiName: string | null;
            serviceId: string;
            address: string | null;
            experience: string | null;
        }[];
    } & {
        description: string | null;
        title: string;
        id: string;
        contactPhone: string | null;
        createdAt: Date;
        updatedAt: Date;
        sortOrder: number;
        isActive: boolean;
        slug: string;
        category: string;
        icon: string;
        contactPerson: string | null;
    }) | {
        persons: {
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
        }[];
        description: string | null;
        title: string;
        id: string;
        contactPhone: string | null;
        createdAt: Date;
        updatedAt: Date;
        sortOrder: number;
        isActive: boolean;
        slug: string;
        category: string;
        icon: string;
        contactPerson: string | null;
    } | {
        persons: {
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
        }[];
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
    } | {
        persons: {
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
        }[];
        id: string;
        title: string;
        category: string;
        icon: string;
        description: string;
        isActive: true;
    }>;
    private readonly defaultPersons;
    getPublicPersonsByServiceId(serviceId: string, filters?: {
        district?: string;
        taluka?: string;
        village?: string;
        search?: string;
    }): Promise<{
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
    getAllAdminServices(): Promise<{
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
    createService(data: {
        title: string;
        category?: string;
        icon?: string;
        contactPhone?: string;
        contactPerson?: string;
        description?: string;
        isActive?: boolean;
    }): Promise<{
        description: string | null;
        title: string;
        id: string;
        contactPhone: string | null;
        createdAt: Date;
        updatedAt: Date;
        sortOrder: number;
        isActive: boolean;
        slug: string;
        category: string;
        icon: string;
        contactPerson: string | null;
    }>;
    updateService(id: string, data: Partial<{
        title: string;
        category: string;
        icon: string;
        contactPhone: string;
        contactPerson: string;
        description: string;
        isActive: boolean;
    }>): Promise<{
        description: string | null;
        title: string;
        id: string;
        contactPhone: string | null;
        createdAt: Date;
        updatedAt: Date;
        sortOrder: number;
        isActive: boolean;
        slug: string;
        category: string;
        icon: string;
        contactPerson: string | null;
    }>;
    deleteService(id: string): Promise<{
        description: string | null;
        title: string;
        id: string;
        contactPhone: string | null;
        createdAt: Date;
        updatedAt: Date;
        sortOrder: number;
        isActive: boolean;
        slug: string;
        category: string;
        icon: string;
        contactPerson: string | null;
    }>;
    getAllAdminServicePersons(serviceId?: string): Promise<{
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
    createServicePerson(dto: CreateServicePersonDto): Promise<{
        service: {
            title: string;
            id: string;
            category: string;
        };
    } & {
        description: string | null;
        name: string;
        city: string | null;
        photoUrl: string | null;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        districtId: string | null;
        talukaId: string | null;
        userId: string | null;
        villageId: string | null;
        phone: string;
        isActive: boolean;
        gujaratiName: string | null;
        serviceId: string;
        address: string | null;
        experience: string | null;
    }>;
    updateServicePerson(id: string, dto: UpdateServicePersonDto): Promise<{
        service: {
            title: string;
            id: string;
            category: string;
        };
    } & {
        description: string | null;
        name: string;
        city: string | null;
        photoUrl: string | null;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        districtId: string | null;
        talukaId: string | null;
        userId: string | null;
        villageId: string | null;
        phone: string;
        isActive: boolean;
        gujaratiName: string | null;
        serviceId: string;
        address: string | null;
        experience: string | null;
    }>;
    deleteServicePerson(id: string): Promise<{
        description: string | null;
        name: string;
        city: string | null;
        photoUrl: string | null;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        districtId: string | null;
        talukaId: string | null;
        userId: string | null;
        villageId: string | null;
        phone: string;
        isActive: boolean;
        gujaratiName: string | null;
        serviceId: string;
        address: string | null;
        experience: string | null;
    }>;
}
