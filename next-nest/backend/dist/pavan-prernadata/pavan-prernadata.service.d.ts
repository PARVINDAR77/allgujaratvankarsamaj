import { PrismaService } from "../prisma/prisma.service";
export declare class PavanPrernadataService {
    private prisma;
    private readonly logger;
    constructor(prisma: PrismaService);
    findAllAdmin(): Promise<{
        description: string | null;
        name: string;
        designation: string | null;
        photoUrl: string | null;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        isActive: boolean;
        gujaratiName: string | null;
        year: string | null;
        displayOrder: number;
    }[]>;
    findAllPublic(): Promise<{
        description: string | null;
        name: string;
        designation: string | null;
        photoUrl: string | null;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        isActive: boolean;
        gujaratiName: string | null;
        year: string | null;
        displayOrder: number;
    }[]>;
    create(data: any): Promise<{
        description: string | null;
        name: string;
        designation: string | null;
        photoUrl: string | null;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        isActive: boolean;
        gujaratiName: string | null;
        year: string | null;
        displayOrder: number;
    }>;
    update(id: string, data: any): Promise<{
        description: string | null;
        name: string;
        designation: string | null;
        photoUrl: string | null;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        isActive: boolean;
        gujaratiName: string | null;
        year: string | null;
        displayOrder: number;
    }>;
    remove(id: string): Promise<{
        description: string | null;
        name: string;
        designation: string | null;
        photoUrl: string | null;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        isActive: boolean;
        gujaratiName: string | null;
        year: string | null;
        displayOrder: number;
    }>;
}
