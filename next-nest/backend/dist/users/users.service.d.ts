import { PrismaService } from "../prisma/prisma.service";
import { User, Role, Status } from "@prisma/client";
export declare class UsersService {
    private readonly prisma;
    private readonly logger;
    constructor(prisma: PrismaService);
    findByEmail(email?: string): Promise<User | null>;
    findByPhone(phone?: string): Promise<User | null>;
    findById(id: string): Promise<User | null>;
    createUser(data: {
        email?: string;
        phone?: string;
        name?: string;
        gender?: string;
        passwordHash: string;
        role?: Role;
        status?: Status;
    }): Promise<User>;
    getAllUsersForAdmin(): Promise<{
        id: string;
        name: string;
        email: string;
        phone: string;
        pargana: string;
        status: import(".prisma/client").$Enums.Status;
        role: import(".prisma/client").$Enums.Role;
        createdAt: Date;
    }[]>;
    updateUserStatusAdmin(userId: string, adminId: string, status: Status, ipAddress?: string): Promise<{
        id: string;
        status: import(".prisma/client").$Enums.Status;
    }>;
    updateUserRoleAdmin(userId: string, adminId: string, role: Role, ipAddress?: string): Promise<{
        id: string;
        role: import(".prisma/client").$Enums.Role;
    }>;
    getAllProfilesForAdmin(): Promise<{
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
    updateProfileStatusAdmin(profileId: string, adminId: string, status: string, ipAddress?: string): Promise<{
        id: string;
        status: import(".prisma/client").$Enums.ProfileStatus;
        isVerified: boolean;
    }>;
    toggleProfileFeaturedAdmin(profileId: string, adminId: string, isFeatured: boolean, ipAddress?: string): Promise<{
        id: string;
        isFeatured: boolean;
    }>;
}
