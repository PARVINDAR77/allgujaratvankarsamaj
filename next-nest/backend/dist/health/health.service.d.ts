import { PrismaService } from "../prisma/prisma.service";
export interface HealthStatusResponse {
    status: string;
    service: string;
    timestamp: string;
    database: string;
}
export declare class HealthService {
    private readonly prisma;
    private readonly logger;
    constructor(prisma: PrismaService);
    checkHealth(): Promise<HealthStatusResponse>;
    syncDatabaseSchema(): Promise<{
        success: boolean;
        message: string;
        timestamp: string;
    }>;
}
