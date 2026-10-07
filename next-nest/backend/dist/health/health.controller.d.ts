import { HealthService, HealthStatusResponse } from "./health.service";
export declare class HealthController {
    private readonly healthService;
    constructor(healthService: HealthService);
    getHealth(): Promise<HealthStatusResponse>;
    syncSchema(): Promise<{
        success: boolean;
        message: string;
        timestamp: string;
    }>;
}
