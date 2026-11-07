import { UsersService } from "./users.service";
import { Role, Status } from "@prisma/client";
export declare class AdminUsersController {
    private readonly usersService;
    constructor(usersService: UsersService);
    getUsersAdmin(page?: number, limit?: number, search?: string, role?: string, status?: string): Promise<{
        data: {
            id: any;
            name: any;
            email: any;
            phone: any;
            pargana: any;
            status: any;
            role: any;
            permissions: any;
            createdAt: any;
        }[];
        meta: {
            page: number;
            limit: number;
            total: number;
            totalPages: number;
            hasNextPage: boolean;
            hasPreviousPage: boolean;
        };
    }>;
    updateUserStatusAdmin(req: any, id: string, status: Status): Promise<{
        id: string;
        status: import(".prisma/client").$Enums.Status;
    }>;
    updateUserRoleAdmin(req: any, id: string, role: Role): Promise<{
        id: string;
        role: import(".prisma/client").$Enums.Role;
    }>;
    getProfilesAdmin(page?: number, limit?: number, search?: string, status?: string, category?: string): Promise<{
        data: {
            id: string;
            userId: string;
            name: string;
            age: number;
            gender: import(".prisma/client").$Enums.Gender;
            pargana: string;
            city: string;
            education: string;
            occupation: string;
            photoUrl: string;
            photos: string[];
            verification: {
                status: import(".prisma/client").$Enums.VerificationStatus;
                id: string;
                createdAt: Date;
                documentType: string;
                documentUrl: string;
                documentBackUrl: string;
            };
            user: {
                email: string;
                phone: string;
            };
            status: import(".prisma/client").$Enums.ProfileStatus;
            isVerified: boolean;
            isFeatured: boolean;
            createdAt: Date;
        }[];
        meta: {
            page: number;
            limit: number;
            total: number;
            totalPages: number;
            hasNextPage: boolean;
            hasPreviousPage: boolean;
        };
    }>;
    updateProfileStatusAdmin(req: any, id: string, status: string): Promise<{
        id: string;
        status: import(".prisma/client").$Enums.ProfileStatus;
        isVerified: boolean;
    }>;
    toggleProfileFeaturedAdmin(req: any, id: string, isFeatured: boolean): Promise<{
        id: string;
        isFeatured: boolean;
    }>;
    deleteUserAdmin(req: any, id: string): Promise<{
        success: boolean;
        message: string;
    }>;
    deleteProfileAdmin(req: any, id: string): Promise<{
        success: boolean;
        message: string;
    }>;
    getSubAdmins(req: any): Promise<any[]>;
    createSubAdmin(req: any, body: {
        name: string;
        email: string;
        phone?: string;
        password: string;
        permissions: string[];
        role?: Role;
    }): Promise<{
        permissions: string[];
        status: import(".prisma/client").$Enums.Status;
        name: string;
        id: string;
        createdAt: Date;
        email: string;
        phone: string;
        role: import(".prisma/client").$Enums.Role;
    }>;
    updateSubAdmin(req: any, id: string, body: {
        name?: string;
        phone?: string;
        password?: string;
        status?: Status;
        permissions?: string[];
        role?: Role;
    }): Promise<{
        permissions: string[];
        status: import(".prisma/client").$Enums.Status;
        name: string;
        id: string;
        updatedAt: Date;
        email: string;
        phone: string;
        role: import(".prisma/client").$Enums.Role;
    }>;
    deleteSubAdmin(req: any, id: string): Promise<{
        success: boolean;
        message: string;
    }>;
}
