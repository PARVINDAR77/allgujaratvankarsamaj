import { StatisticsService } from "./statistics.service";
export declare class StatisticsController {
    private readonly statisticsService;
    constructor(statisticsService: StatisticsService);
    getDashboardStatistics(): Promise<{
        totalUsers: number;
        activeProfiles: number;
        totalMatches: number;
        pendingVerifications: number;
        openReports: number;
        totalSuccessStories: number;
        activeGovtEmployees: number;
        genderBreakdown: {
            MALE: number;
            FEMALE: number;
            OTHER: number;
        };
        parganaBreakdown: {
            name: string;
            count: number;
            percentage: number;
        }[];
        recentUsers: {
            id: string;
            name: string;
            email: string;
            phone: string;
            pargana: string;
            status: import(".prisma/client").$Enums.Status;
            role: import(".prisma/client").$Enums.Role;
            createdAt: string;
        }[];
        recentVerifications: {
            id: string;
            name: string;
            type: string;
            status: import(".prisma/client").$Enums.VerificationStatus;
            date: string;
        }[];
        recentActivities: {
            id: string;
            icon: string;
            title: string;
            user: string;
            time: string;
            status: string;
        }[];
        monthlyGrowth: {
            month: string;
            users: number;
            profiles: number;
        }[];
    }>;
    getPublicDashboard(): Promise<{
        totalCandidates: number;
        totalBoys: number;
        totalGirls: number;
        today: {
            total: number;
            boys: number;
            girls: number;
        };
        departments: {
            government: {
                name: string;
                count: number;
            }[];
            private: {
                name: string;
                count: number;
            }[];
        };
    }>;
    getTodaysBirthdays(): Promise<{
        state: string | null;
        status: import(".prisma/client").$Enums.ProfileStatus;
        id: string;
        gender: import(".prisma/client").$Enums.Gender;
        createdAt: Date;
        updatedAt: Date;
        userId: string;
        firstName: string;
        lastName: string;
        dateOfBirth: Date;
        maritalStatus: import(".prisma/client").$Enums.MaritalStatus;
        religion: string | null;
        caste: string | null;
        subcaste: string | null;
        nativePlace: string | null;
        city: string | null;
        country: string | null;
        education: string | null;
        occupation: string | null;
        organizationName: string | null;
        designation: string | null;
        about: string | null;
        photoUrl: string | null;
        isPhysicallyDisabled: boolean;
        pwbdCategory: string | null;
        isAbroad: boolean;
        abroadCountry: string | null;
        businessIndustry: string | null;
        businessService: string | null;
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
        stateId: string | null;
        districtId: string | null;
        talukaId: string | null;
        parganaId: string | null;
        villageId: string | null;
        isVerified: boolean;
        isFeatured: boolean;
    }[]>;
    getSectionViews(): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        sectionName: string;
        viewCount: number;
    }[]>;
    incrementSectionView(sectionName: string): Promise<{
        id: string;
        createdAt: Date;
        updatedAt: Date;
        sectionName: string;
        viewCount: number;
    }>;
}
