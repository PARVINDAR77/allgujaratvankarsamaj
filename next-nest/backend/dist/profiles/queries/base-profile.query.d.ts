import { Prisma } from "@prisma/client";
import { BaseProfileQueryDto } from "../dto/base-profile-query.dto";
export declare class BaseProfileQueryBuilder {
    static buildWhereClause(query: BaseProfileQueryDto): Prisma.MatrimonialProfileWhereInput;
    static buildOrderByClause(query: BaseProfileQueryDto): Prisma.MatrimonialProfileOrderByWithRelationInput;
}
