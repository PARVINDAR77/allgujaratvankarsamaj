"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createPaginatedResponse = createPaginatedResponse;
exports.getPaginationPrismaArgs = getPaginationPrismaArgs;
function createPaginatedResponse(data, total, page, limit) {
    const totalPages = Math.ceil(total / limit);
    const meta = {
        page,
        limit,
        total,
        totalPages,
        hasNextPage: page < totalPages,
        hasPreviousPage: page > 1,
    };
    return {
        data,
        meta,
    };
}
function getPaginationPrismaArgs(page, limit) {
    return {
        skip: (page - 1) * limit,
        take: limit,
    };
}
//# sourceMappingURL=pagination.util.js.map