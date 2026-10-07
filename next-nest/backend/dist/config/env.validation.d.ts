declare class EnvironmentVariables {
    PORT: number;
    DATABASE_URL: string;
    JWT_SECRET: string;
    JWT_EXPIRES_IN: string;
    JWT_REFRESH_SECRET?: string;
    NODE_ENV: string;
    ALLOWED_ORIGINS?: string;
}
export declare function validate(config: Record<string, unknown>): EnvironmentVariables;
export {};
