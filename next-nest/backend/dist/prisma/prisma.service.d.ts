import { OnModuleDestroy, OnModuleInit } from "@nestjs/common";
import { PrismaClient } from "@prisma/client";
export declare class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
    private readonly logger;
    onModuleInit(): Promise<void>;
    isSchemaComplete(): Promise<boolean>;
    syncSchemaWithLock(): Promise<boolean>;
    syncSchema(maxRetries?: number, retryDelayMs?: number): Promise<void>;
    syncGovernmentEmployeesFromProfiles(): Promise<void>;
    onModuleDestroy(): Promise<void>;
}
