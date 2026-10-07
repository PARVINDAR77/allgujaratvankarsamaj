import { GovtEmploymentType } from "@prisma/client";
export declare class CreateGovtEmploymentDto {
    employmentType: GovtEmploymentType;
    departmentId?: string;
    designationId?: string;
    officeLocation?: string;
    joiningYear?: number;
}
export declare class UpdateGovtEmploymentDto {
    employmentType?: GovtEmploymentType;
    departmentId?: string;
    designationId?: string;
    officeLocation?: string;
    joiningYear?: number;
}
export declare class SubmitVerificationDto {
    documentType: string;
    documentUrl: string;
}
import { BaseProfileQueryDto } from "../../profiles/dto/base-profile-query.dto";
export declare class GovtEmployeeSearchQueryDto extends BaseProfileQueryDto {
    departmentId?: string;
    designationId?: string;
    employmentType?: string;
}
export declare class AdminVerifyGovtEmpDto {
    action: "APPROVE" | "REJECT";
    rejectionReason?: string;
}
export declare class AdminFeatureGovtEmpDto {
    isFeatured: boolean;
}
export declare class AdminStatusGovtEmpDto {
    isActive: boolean;
}
export declare class CreateDepartmentDto {
    name: string;
    gujaratiName?: string;
    code?: string;
}
export declare class CreateDesignationDto {
    departmentId: string;
    name: string;
    gujaratiName?: string;
    code?: string;
}
