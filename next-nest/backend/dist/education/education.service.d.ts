import { PrismaService } from "../prisma/prisma.service";
import { UpdateEducationDto } from "./dto/update-education.dto";
export declare class EducationService {
    private readonly prisma;
    private readonly logger;
    constructor(prisma: PrismaService);
    getEducationContent(): Promise<{
        statusCode: number;
        data: any;
    }>;
    updateEducationContent(dto: UpdateEducationDto): Promise<{
        statusCode: number;
        message: string;
        data: UpdateEducationDto;
    }>;
}
