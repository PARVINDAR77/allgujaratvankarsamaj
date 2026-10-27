import { PrismaService } from "../prisma/prisma.service";
export declare class AdminService {
    private readonly prisma;
    private readonly logger;
    constructor(prisma: PrismaService);
    getDashboardStats(): Promise<{
        totalUsers: number;
        totalProfiles: number;
        totalMatches: number;
        totalMessages: number;
        monthlyGrowth: {
            month: string;
            users: number;
            profiles: number;
        }[];
        parganaBreakdown: {
            name: string;
            count: number;
            percentage: number;
        }[];
        recentActivities: {
            id: string;
            icon: string;
            title: string;
            user: string;
            time: string;
            status: string;
        }[];
        recentUsers: {
            id: string;
            name: any;
            email: string;
            phone: any;
            pargana: string;
            status: import(".prisma/client").$Enums.Status;
            role: import(".prisma/client").$Enums.Role;
            createdAt: Date;
        }[] | {
            id: string;
            name: string;
            email: string;
            phone: string;
            pargana: string;
            status: string;
            role: string;
            createdAt: Date;
        }[];
        recentVerifications: {
            id: string;
            name: string;
            type: string;
            status: string;
            date: string;
        }[];
    }>;
    getVerifications(): Promise<any[]>;
    updateVerificationStatus(id: string, status: any, rejectionReason?: string): Promise<{
        status: import(".prisma/client").$Enums.VerificationStatus;
        id: string;
        createdAt: Date;
        updatedAt: Date;
        profileId: string;
        documentType: string;
        documentUrl: string;
        documentBackUrl: string | null;
        rejectionReason: string | null;
    } | {
        id: string;
        status: any;
    }>;
    getReports(): Promise<{
        status: import(".prisma/client").$Enums.ReportStatus;
        id: string;
        createdAt: Date;
        details: string | null;
        reporterUserId: string;
        targetProfileId: string;
        reason: string;
    }[]>;
    updateReportStatus(id: string, status: any): Promise<{
        status: import(".prisma/client").$Enums.ReportStatus;
        id: string;
        createdAt: Date;
        details: string | null;
        reporterUserId: string;
        targetProfileId: string;
        reason: string;
    } | {
        id: string;
        status: any;
    }>;
    getMatches(filterStatus?: string, search?: string): Promise<{
        stats: {
            totalMatches: number;
            mutualInterests: number;
            acceptedProposals: number;
            rejectedPass: number;
            pendingReview: number;
        };
        items: {
            id: string;
            senderProfileId: string;
            receiverProfileId: string;
            candidateA: {
                id: string;
                name: string;
                pargana: string;
                district: string;
                city: string;
                age: number;
                gender: import(".prisma/client").$Enums.Gender;
                photoUrl: string;
                isVerified: boolean;
                education: string;
                occupation: string;
                phone: string;
                email: string;
            };
            candidateB: {
                id: string;
                name: string;
                pargana: string;
                district: string;
                city: string;
                age: number;
                gender: import(".prisma/client").$Enums.Gender;
                photoUrl: string;
                isVerified: boolean;
                education: string;
                occupation: string;
                phone: string;
                email: string;
            };
            userA: {
                profile: {
                    user: {
                        id: string;
                        email: string;
                        phone: string;
                    };
                    district: {
                        name: string;
                        id: string;
                    };
                    pargana: {
                        name: string;
                        id: string;
                        gujaratiName: string;
                    };
                } & {
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
            };
            userB: {
                profile: {
                    user: {
                        id: string;
                        email: string;
                        phone: string;
                    };
                    district: {
                        name: string;
                        id: string;
                    };
                    pargana: {
                        name: string;
                        id: string;
                        gujaratiName: string;
                    };
                } & {
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
            };
            compatibility: string;
            matchScore: string;
            status: import(".prisma/client").$Enums.InterestStatus;
            createdAt: Date;
            matchDate: string;
            date: string;
        }[];
    }>;
    deleteMatch(id: string): Promise<{
        status: import(".prisma/client").$Enums.InterestStatus;
        id: string;
        createdAt: Date;
        senderProfileId: string;
        receiverProfileId: string;
    } | {
        success: boolean;
        message: string;
    }>;
    getHealthStatus(): Promise<{
        status: string;
        timestamp: string;
        environment: string;
        services: {
            database: string;
            api: string;
            auth: string;
        };
    }>;
    getPendingPhotos(): Promise<{
        firstName: string;
        lastName: string;
        photoUrl: string;
        id: string;
        createdAt: Date;
        userId: string;
    }[]>;
    getShortlists(): Promise<{
        id: string;
        createdAt: Date;
        userId: string;
        targetProfileId: string;
    }[]>;
}
