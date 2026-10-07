import { Gender, MaritalStatus, VerificationStatus } from "../../common/enums/profile.enums";
import { PaginationQueryDto } from "../../common/pagination/dto/pagination-query.dto";
declare const ALLOWED_SORT_FIELDS: readonly ["createdAt", "updatedAt", "dateOfBirth", "firstName"];
type SortField = (typeof ALLOWED_SORT_FIELDS)[number];
export declare class BaseProfileQueryDto extends PaginationQueryDto {
    search?: string;
    gender?: Gender;
    lookingFor?: string;
    ageMin?: number;
    ageMax?: number;
    maritalStatus?: MaritalStatus;
    verificationStatus?: VerificationStatus;
    stateId?: string;
    districtId?: string;
    talukaId?: string;
    parganaId?: string;
    villageId?: string;
    occupation?: string;
    category?: string;
    sortBy?: SortField;
    sortOrder?: "asc" | "desc";
}
export {};
