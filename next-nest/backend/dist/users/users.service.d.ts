import { PrismaService } from "../prisma/prisma.service";
import { User, Role, Status } from "@prisma/client";
export declare function normalizePhoneNumber(phone?: string | null): {
    isValid: boolean;
    canonical10?: string;
    variants: string[];
};
export declare class UsersService {
    private readonly prisma;
    private readonly logger;
    constructor(prisma: PrismaService);
    findByEmail(email?: string): Promise<User | null>;
    findByPhone(phone?: string): Promise<User | null>;
    findById(id: string): Promise<User | null>;
    findByIdWithProfile(id: string): Promise<{
        profile: {
            state: string | null;
            status: import(".prisma/client").$Enums.ProfileStatus;
            firstName: string;
            lastName: string;
            dateOfBirth: Date;
            gender: import(".prisma/client").$Enums.Gender;
            maritalStatus: import(".prisma/client").$Enums.MaritalStatus;
            religion: string | null;
            caste: string | null;
            subcaste: string | null;
            city: string | null;
            country: string | null;
            education: string | null;
            occupation: string | null;
            about: string | null;
            nativePlace: string | null;
            organizationName: string | null;
            designation: string | null;
            photoUrl: string | null;
            photos: string | null;
            isPhysicallyDisabled: boolean;
            pwbdCategory: string | null;
            isAbroad: boolean;
            abroadCountry: string | null;
            businessIndustry: string | null;
            businessService: string | null;
            id: string;
            bloodGroup: string | null;
            isVankar: boolean;
            annualIncome: string | null;
            fatherName: string | null;
            fatherOccupation: string | null;
            fatherContact: string | null;
            motherName: string | null;
            motherOccupation: string | null;
            guardianContact: string | null;
            siblings: string | null;
            mamasVillage: string | null;
            addressLine: string | null;
            pincode: string | null;
            altPhone: string | null;
            contactEmail: string | null;
            motherTongue: string | null;
            privacySettings: string | null;
            showInMatrimony: boolean;
            createdAt: Date;
            updatedAt: Date;
            districtId: string | null;
            talukaId: string | null;
            parganaId: string | null;
            userId: string;
            stateId: string | null;
            villageId: string | null;
            isVerified: boolean;
            isFeatured: boolean;
        };
    } & {
        status: import(".prisma/client").$Enums.Status;
        name: string | null;
        gender: import(".prisma/client").$Enums.Gender | null;
        id: string;
        isPhoneVerified: boolean;
        isEmailVerified: boolean;
        createdAt: Date;
        updatedAt: Date;
        email: string | null;
        phone: string | null;
        passwordHash: string;
        role: import(".prisma/client").$Enums.Role;
    }>;
    createUser(data: {
        email?: string;
        phone?: string;
        name?: string;
        gender?: string;
        passwordHash: string;
        role?: Role;
        status?: Status;
        isEmailVerified?: boolean;
        isPhoneVerified?: boolean;
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
    deleteUserAccount(userId: string, deletedByAdminId?: string, ipAddress?: string): Promise<{
        success: boolean;
        message: string;
    }>;
    deleteProfileAdmin(profileIdOrUserId: string, adminId: string, ipAddress?: string): Promise<{
        success: boolean;
        message: string;
    }>;
}
