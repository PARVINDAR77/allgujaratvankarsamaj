import { InterestsService } from "./interests.service";
import { CreateInterestDto } from "./dto/create-interest.dto";
export declare class InterestsController {
    private readonly interestsService;
    constructor(interestsService: InterestsService);
    sendInterestRoot(req: any, dto: CreateInterestDto): Promise<{
        message: string;
        status: string;
        interest: {
            status: import(".prisma/client").$Enums.InterestStatus;
            id: string;
            createdAt: Date;
            receiverProfileId: string;
            senderProfileId: string;
        };
        conversationId: string;
    } | {
        message: string;
        status: string;
        interest: {
            status: import(".prisma/client").$Enums.InterestStatus;
            id: string;
            createdAt: Date;
            receiverProfileId: string;
            senderProfileId: string;
        };
    }>;
    sendInterest(req: any, dto: CreateInterestDto): Promise<{
        message: string;
        status: string;
        interest: {
            status: import(".prisma/client").$Enums.InterestStatus;
            id: string;
            createdAt: Date;
            receiverProfileId: string;
            senderProfileId: string;
        };
        conversationId: string;
    } | {
        message: string;
        status: string;
        interest: {
            status: import(".prisma/client").$Enums.InterestStatus;
            id: string;
            createdAt: Date;
            receiverProfileId: string;
            senderProfileId: string;
        };
    }>;
    getInterestStatus(req: any, targetProfileId: string): Promise<{
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
    acceptInterest(req: any, interestId: string): Promise<{
        message: string;
        status: string;
        interest: {
            status: import(".prisma/client").$Enums.InterestStatus;
            id: string;
            createdAt: Date;
            receiverProfileId: string;
            senderProfileId: string;
        };
        conversationId: string;
    }>;
    declineInterest(req: any, interestId: string): Promise<{
        status: import(".prisma/client").$Enums.InterestStatus;
        id: string;
        createdAt: Date;
        receiverProfileId: string;
        senderProfileId: string;
    }>;
    getSentInterests(req: any): Promise<{
        receiverProfile: any;
        status: import(".prisma/client").$Enums.InterestStatus;
        id: string;
        createdAt: Date;
        receiverProfileId: string;
        senderProfileId: string;
    }[]>;
    getReceivedInterests(req: any): Promise<{
        senderProfile: any;
        status: import(".prisma/client").$Enums.InterestStatus;
        id: string;
        createdAt: Date;
        receiverProfileId: string;
        senderProfileId: string;
    }[]>;
    getMutualInterests(req: any): Promise<{
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
                code: string | null;
                gujaratiName: string | null;
            };
            taluka: {
                name: string;
                id: string;
                createdAt: Date;
                updatedAt: Date;
                districtId: string;
                isActive: boolean;
                code: string | null;
                gujaratiName: string | null;
            };
            pargana: {
                description: string | null;
                name: string;
                id: string;
                createdAt: Date;
                updatedAt: Date;
                isActive: boolean;
                code: string | null;
                contactPhone: string | null;
                gujaratiName: string | null;
                villageCount: string | null;
                districtRegion: string | null;
                leaderName: string | null;
                manualCount: number | null;
                totalCount: number;
            };
            village: {
                name: string;
                id: string;
                createdAt: Date;
                updatedAt: Date;
                pincode: string | null;
                talukaId: string | null;
                parganaId: string | null;
                isActive: boolean;
                code: string | null;
                gujaratiName: string | null;
            };
            governmentEmployment: {
                designation: {
                    name: string;
                    id: string;
                    createdAt: Date;
                    updatedAt: Date;
                    isActive: boolean;
                    departmentId: string;
                    code: string | null;
                    gujaratiName: string | null;
                };
                department: {
                    name: string;
                    id: string;
                    createdAt: Date;
                    updatedAt: Date;
                    isActive: boolean;
                    code: string | null;
                    gujaratiName: string | null;
                };
            } & {
                id: string;
                createdAt: Date;
                updatedAt: Date;
                isFeatured: boolean;
                profileId: string;
                rejectionReason: string | null;
                employmentType: import(".prisma/client").$Enums.GovtEmploymentType;
                officeLocation: string | null;
                joiningYear: number | null;
                verificationStatus: import(".prisma/client").$Enums.GovtVerificationStatus;
                verificationSubmittedAt: Date | null;
                verifiedAt: Date | null;
                verifiedBy: string | null;
                isActive: boolean;
                departmentId: string | null;
                designationId: string | null;
            };
            stateRef: {
                name: string;
                id: string;
                createdAt: Date;
                updatedAt: Date;
                isActive: boolean;
                code: string;
                gujaratiName: string | null;
            };
        } & {
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
            photos: string | null;
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
            privacySettings: string | null;
            stateId: string | null;
            districtId: string | null;
            talukaId: string | null;
            parganaId: string | null;
            villageId: string | null;
            isVerified: boolean;
            isFeatured: boolean;
            showInMatrimony: boolean;
        };
        conversationId: string;
        status: import(".prisma/client").$Enums.InterestStatus;
        id: string;
        createdAt: Date;
        receiverProfileId: string;
        senderProfileId: string;
    }[]>;
}
