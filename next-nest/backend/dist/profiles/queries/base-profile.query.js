"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.BaseProfileQueryBuilder = void 0;
class BaseProfileQueryBuilder {
    static buildWhereClause(query) {
        const where = {};
        if (query.search) {
            where.OR = [
                { firstName: { contains: query.search } },
                { lastName: { contains: query.search } },
                { occupation: { contains: query.search } },
                { city: { contains: query.search } },
                { education: { contains: query.search } },
            ];
        }
        if (query.gender)
            where.gender = query.gender;
        if (query.maritalStatus)
            where.maritalStatus = query.maritalStatus;
        if (query.stateId)
            where.stateId = query.stateId;
        if (query.districtId)
            where.districtId = query.districtId;
        if (query.talukaId)
            where.talukaId = query.talukaId;
        if (query.parganaId)
            where.parganaId = query.parganaId;
        if (query.villageId)
            where.villageId = query.villageId;
        if (query.occupation)
            where.occupation = { contains: query.occupation };
        if (query.verificationStatus === "VERIFIED") {
            where.isVerified = true;
        }
        else if (query.verificationStatus === "PENDING") {
            where.isVerified = false;
        }
        if (query.ageMin || query.ageMax) {
            const now = new Date();
            where.dateOfBirth = {};
            if (query.ageMin) {
                const maxDate = new Date(now.getFullYear() - query.ageMin, now.getMonth(), now.getDate());
                where.dateOfBirth.lte = maxDate;
            }
            if (query.ageMax) {
                const minDate = new Date(now.getFullYear() - (query.ageMax + 1), now.getMonth(), now.getDate() + 1);
                where.dateOfBirth.gte = minDate;
            }
        }
        return where;
    }
    static buildOrderByClause(query) {
        const orderBy = {};
        const field = query.sortBy || "createdAt";
        const direction = query.sortOrder || "desc";
        orderBy[field] = direction;
        return orderBy;
    }
}
exports.BaseProfileQueryBuilder = BaseProfileQueryBuilder;
//# sourceMappingURL=base-profile.query.js.map