import { UsersService } from "./users.service";
import { Role, Status } from "@prisma/client";
export declare class AdminUsersController {
    private readonly usersService;
    constructor(usersService: UsersService);
    getUsersAdmin(): Promise<{
        id: string;
        name: string;
        email: string;
        phone: string;
        pargana: string;
        status: import(".prisma/client").$Enums.Status;
        role: import(".prisma/client").$Enums.Role;
        createdAt: Date;
    }[]>;
    updateUserStatusAdmin(req: any, id: string, status: Status): Promise<{
        id: string;
        status: import(".prisma/client").$Enums.Status;
    }>;
    updateUserRoleAdmin(req: any, id: string, role: Role): Promise<{
        id: string;
        role: import(".prisma/client").$Enums.Role;
    }>;
    getProfilesAdmin(): Promise<{
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
    }[]>;
    updateProfileStatusAdmin(req: any, id: string, status: string): Promise<{
        id: string;
        status: import(".prisma/client").$Enums.ProfileStatus;
        isVerified: boolean;
    }>;
    toggleProfileFeaturedAdmin(req: any, id: string, isFeatured: boolean): Promise<{
        id: string;
        isFeatured: boolean;
    }>;
}
