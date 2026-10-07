import { PaginatedResponse } from "./pagination.types";
export declare function createPaginatedResponse<T>(data: T[], total: number, page: number, limit: number): PaginatedResponse<T>;
export declare function getPaginationPrismaArgs(page: number, limit: number): {
    skip: number;
    take: number;
};
