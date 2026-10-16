import { HealthService, HealthStatusResponse } from "./health.service";
import { Response } from "express";
export declare class HealthController {
    private readonly healthService;
    constructor(healthService: HealthService);
    getHealth(): Promise<HealthStatusResponse>;
    cookieTest(res: Response): Promise<{
        status: string;
        cookieTest: boolean;
    }>;
}
