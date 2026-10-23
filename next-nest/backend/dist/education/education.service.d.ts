import { OnModuleInit } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";
import { UpdateEducationDto } from "./dto/update-education.dto";
export declare class EducationService implements OnModuleInit {
    private readonly prisma;
    private readonly logger;
    constructor(prisma: PrismaService);
    onModuleInit(): Promise<void>;
    ensureColumnsExist(): Promise<void>;
    getEducationContent(): Promise<{
        statusCode: number;
        data: any;
    }>;
    updateEducationContent(dto: UpdateEducationDto): Promise<{
        statusCode: number;
        message: string;
        data: any;
    }>;
}
