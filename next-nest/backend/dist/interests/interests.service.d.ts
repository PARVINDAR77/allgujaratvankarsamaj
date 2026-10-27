import { PrismaService } from "../prisma/prisma.service";
import { CreateInterestDto } from "./dto/create-interest.dto";
export declare class InterestsService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    private getProfileIdForUser;
    private get profileInclude();
    getInterestStatus(userId: string, targetProfileId: string): Promise<{
        status: string;
        interestId?: undefined;
        conversationId?: undefined;
    } | {
        status: string;
        interestId: string;
        conversationId: string;
    } | {
        status: string;
        interestId: string;
        conversationId?: undefined;
    }>;
    sendInterest(userId: string, dto: CreateInterestDto): Promise<{
        message: string;
        status: string;
        interest: {
            status: import(".prisma/client").$Enums.InterestStatus;
            id: string;
            createdAt: Date;
            senderProfileId: string;
            receiverProfileId: string;
        };
        conversationId: string;
    } | {
        message: string;
        status: string;
        interest: {
            status: import(".prisma/client").$Enums.InterestStatus;
            id: string;
            createdAt: Date;
            senderProfileId: string;
            receiverProfileId: string;
        };
    }>;
    acceptInterest(userId: string, interestId: string): Promise<{
        message: string;
        status: string;
        interest: {
            status: import(".prisma/client").$Enums.InterestStatus;
            id: string;
            createdAt: Date;
            senderProfileId: string;
            receiverProfileId: string;
        };
        conversationId: string;
    }>;
    declineInterest(userId: string, interestId: string): Promise<{
        status: import(".prisma/client").$Enums.InterestStatus;
        id: string;
        createdAt: Date;
        senderProfileId: string;
        receiverProfileId: string;
    }>;
    getSentInterests(userId: string): Promise<{
        receiverProfile: any;
        status: import(".prisma/client").$Enums.InterestStatus;
        id: string;
        createdAt: Date;
        senderProfileId: string;
        receiverProfileId: string;
    }[]>;
    getReceivedInterests(userId: string): Promise<{
        senderProfile: any;
        status: import(".prisma/client").$Enums.InterestStatus;
        id: string;
        createdAt: Date;
        senderProfileId: string;
        receiverProfileId: string;
    }[]>;
    getMutualInterests(userId: string): Promise<{
        otherProfile: {
            user: {
                email: string;
                phone: string;
            };
            district: {
                name: string;
                id: string;
                createdAt: Date;
                updatedAt: Date;
                stateId: string;
                isActive: boolean;
                gujaratiName: string | null;
                code: string | null;
            };
            taluka: {
                name: string;
                id: string;
                createdAt: Date;
                updatedAt: Date;
                districtId: string;
                isActive: boolean;
                gujaratiName: string | null;
                code: string | null;
            };
            pargana: {
                description: string | null;
                name: string;
                id: string;
                contactPhone: string | null;
                createdAt: Date;
                updatedAt: Date;
                isActive: boolean;
                gujaratiName: string | null;
                code: string | null;
                villageCount: string | null;
                districtRegion: string | null;
                leaderName: string | null;
                manualCount: number | null;
                totalCount: number;
            };
            village: {
                name: string;
                id: string;
                pincode: string | null;
                createdAt: Date;
                updatedAt: Date;
                talukaId: string | null;
                parganaId: string | null;
                isActive: boolean;
                gujaratiName: string | null;
                code: string | null;
            };
            governmentEmployment: {
                designation: {
                    name: string;
                    id: string;
                    createdAt: Date;
                    updatedAt: Date;
                    departmentId: string;
                    isActive: boolean;
                    gujaratiName: string | null;
                    code: string | null;
                };
                department: {
                    name: string;
                    id: string;
                    createdAt: Date;
                    updatedAt: Date;
                    isActive: boolean;
                    gujaratiName: string | null;
                    code: string | null;
                };
            } & {
                id: string;
                createdAt: Date;
                updatedAt: Date;
                isFeatured: boolean;
                profileId: string;
                rejectionReason: string | null;
                employmentType: import(".prisma/client").$Enums.GovtEmploymentType;
                departmentId: string | null;
                designationId: string | null;
                officeLocation: string | null;
                joiningYear: number | null;
                verificationStatus: import(".prisma/client").$Enums.GovtVerificationStatus;
                verificationSubmittedAt: Date | null;
                verifiedAt: Date | null;
                verifiedBy: string | null;
                isActive: boolean;
            };
            stateRef: {
                name: string;
                id: string;
                createdAt: Date;
                updatedAt: Date;
                isActive: boolean;
                gujaratiName: string | null;
                code: string;
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
        conversationId: string;
        status: import(".prisma/client").$Enums.InterestStatus;
        id: string;
        createdAt: Date;
        senderProfileId: string;
        receiverProfileId: string;
    }[]>;
}
