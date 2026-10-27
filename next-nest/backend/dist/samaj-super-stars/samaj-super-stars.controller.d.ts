import { SamajSuperStarsService } from "./samaj-super-stars.service";
export declare class SamajSuperStarsController {
    private readonly starsService;
    constructor(starsService: SamajSuperStarsService);
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
