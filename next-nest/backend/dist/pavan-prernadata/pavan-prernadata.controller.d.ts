import { PavanPrernadataService } from "./pavan-prernadata.service";
export declare class PavanPrernadataController {
    private readonly pavanService;
    constructor(pavanService: PavanPrernadataService);
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
    create(createDto: any): Promise<{
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
    update(id: string, updateDto: any): Promise<{
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
