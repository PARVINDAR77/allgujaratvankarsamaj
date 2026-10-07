import { Gender, MaritalStatus, ProfileStatus, VerificationStatus } from "@prisma/client";
export declare enum SortOrder {
    ASC = "asc",
    DESC = "desc"
}
export declare enum ProfileSortField {
    CREATED_AT = "createdAt",
    UPDATED_AT = "updatedAt",
    FIRST_NAME = "firstName",
    AGE = "age"
}
export declare class BaseProfileQueryDto {
    page?: number;
    limit?: number;
    gender?: Gender;
    lookingFor?: string;
    maritalStatus?: MaritalStatus;
    ageMin?: number;
    ageMax?: number;
    districtId?: string;
    talukaId?: string;
    occupationCategory?: string;
    verification?: VerificationStatus;
    status?: ProfileStatus;
    search?: string;
    keyword?: string;
    parganaId?: string;
    pargana?: string;
    city?: string;
    education?: string;
    occupation?: string;
    ageFrom?: number;
    ageTo?: number;
    sortBy?: ProfileSortField;
    sortOrder?: SortOrder;
}
