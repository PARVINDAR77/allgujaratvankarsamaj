import { EducationService } from "./education.service";
import { UpdateEducationDto } from "./dto/update-education.dto";
export declare class EducationController {
    private readonly educationService;
    constructor(educationService: EducationService);
    getEducation(): Promise<{
        statusCode: number;
        data: any;
    }>;
    getAdminEducation(): Promise<{
        statusCode: number;
        data: any;
    }>;
    updateEducation(dto: UpdateEducationDto): Promise<{
        statusCode: number;
        message: string;
        data: UpdateEducationDto;
    }>;
}
