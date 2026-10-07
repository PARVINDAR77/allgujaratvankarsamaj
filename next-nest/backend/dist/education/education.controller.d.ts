import { EducationService } from "./education.service";
import { UpdateEducationDto } from "./dto/update-education.dto";
export declare class EducationController {
    private readonly educationService;
    constructor(educationService: EducationService);
    getEducation(): Promise<{
        statusCode: number;
        data: {
            id: any;
            headerTitle: any;
            headerSubtitle: any;
            box1Title: any;
            box1Subtitle: any;
            box1PdfUrl: any;
            box1FileName: any;
            box2Title: any;
            box2Content: any;
            box2Author: any;
            box3Title: any;
            box3YoutubeUrl: any;
            box3Description: any;
            box4Title: any;
            box4YoutubeUrl: any;
            box4Description: any;
            isActive: boolean;
            createdAt: any;
            updatedAt: any;
        };
    } | {
        statusCode: number;
        data: {
            id: string;
            headerTitle: string;
            headerSubtitle: string;
            box1Title: string;
            box1Subtitle: string;
            box1PdfUrl: string;
            box1FileName: string;
            box2Title: string;
            box2Content: string;
            box2Author: string;
            box3Title: string;
            box3YoutubeUrl: string;
            box3Description: string;
            box4Title: string;
            box4YoutubeUrl: string;
            box4Description: string;
            isActive: boolean;
        };
    }>;
    getAdminEducation(): Promise<{
        statusCode: number;
        data: {
            id: any;
            headerTitle: any;
            headerSubtitle: any;
            box1Title: any;
            box1Subtitle: any;
            box1PdfUrl: any;
            box1FileName: any;
            box2Title: any;
            box2Content: any;
            box2Author: any;
            box3Title: any;
            box3YoutubeUrl: any;
            box3Description: any;
            box4Title: any;
            box4YoutubeUrl: any;
            box4Description: any;
            isActive: boolean;
            createdAt: any;
            updatedAt: any;
        };
    } | {
        statusCode: number;
        data: {
            id: string;
            headerTitle: string;
            headerSubtitle: string;
            box1Title: string;
            box1Subtitle: string;
            box1PdfUrl: string;
            box1FileName: string;
            box2Title: string;
            box2Content: string;
            box2Author: string;
            box3Title: string;
            box3YoutubeUrl: string;
            box3Description: string;
            box4Title: string;
            box4YoutubeUrl: string;
            box4Description: string;
            isActive: boolean;
        };
    }>;
    updateEducation(dto: UpdateEducationDto): Promise<{
        statusCode: number;
        message: string;
        data: {
            id: string;
            createdAt: Date;
            updatedAt: Date;
            isActive: boolean;
            headerTitle: string | null;
            headerSubtitle: string | null;
            box1Title: string | null;
            box1Subtitle: string | null;
            box1PdfUrl: string | null;
            box1FileName: string | null;
            box2Title: string | null;
            box2Content: string | null;
            box2Author: string | null;
            box3Title: string | null;
            box3YoutubeUrl: string | null;
            box3Description: string | null;
            box4Title: string | null;
            box4YoutubeUrl: string | null;
            box4Description: string | null;
        };
    } | {
        statusCode: number;
        message: string;
        data: Record<string, any>;
    }>;
}
