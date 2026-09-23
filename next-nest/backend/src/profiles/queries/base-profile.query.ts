import { Prisma } from '@prisma/client';
import { BaseProfileQueryDto } from '../dto/base-profile-query.dto';

export class BaseProfileQueryBuilder {
  static buildWhereClause(query: BaseProfileQueryDto): Prisma.MatrimonialProfileWhereInput {
    const where: Prisma.MatrimonialProfileWhereInput = {};

    // Base Search (keyword matching on multiple fields)
    if (query.search) {
      where.OR = [
        { firstName: { contains: query.search } },
        { lastName: { contains: query.search } },
        { occupation: { contains: query.search } },
        { city: { contains: query.search } },
        { education: { contains: query.search } },
      ];
    }

    // Exact matches
    if (query.gender) where.gender = query.gender;
    if (query.maritalStatus) where.maritalStatus = query.maritalStatus;
    
    // Locations
    if (query.stateId) where.stateId = query.stateId;
    if (query.districtId) where.districtId = query.districtId;
    if (query.talukaId) where.talukaId = query.talukaId;
    if (query.parganaId) where.parganaId = query.parganaId;
    if (query.villageId) where.villageId = query.villageId;
    
    // Occupation exact
    if (query.occupation) where.occupation = { contains: query.occupation };

    // Verification mapping (isVerified is boolean on profile, but query.verificationStatus might imply checking VerificationRequest or GovernmentVerification, depending on logic)
    // Assuming simple mapping for now based on boolean
    if (query.verificationStatus === 'VERIFIED') {
      where.isVerified = true;
    } else if (query.verificationStatus === 'PENDING') {
      where.isVerified = false;
      // Ideally we'd join on verificationRequests to see if it's pending vs not submitted
    }

    // Age filtering (mapping age to dateOfBirth range)
    if (query.ageMin || query.ageMax) {
      const now = new Date();
      where.dateOfBirth = {};
      
      if (query.ageMin) {
        const maxDate = new Date(now.getFullYear() - query.ageMin, now.getMonth(), now.getDate());
        where.dateOfBirth.lte = maxDate; // born before or exactly on maxDate
      }
      
      if (query.ageMax) {
        const minDate = new Date(now.getFullYear() - (query.ageMax + 1), now.getMonth(), now.getDate() + 1);
        where.dateOfBirth.gte = minDate; // born after minDate
      }
    }

    return where;
  }

  static buildOrderByClause(query: BaseProfileQueryDto): Prisma.MatrimonialProfileOrderByWithRelationInput {
    const orderBy: Prisma.MatrimonialProfileOrderByWithRelationInput = {};
    
    // Default sorting
    const field = query.sortBy || 'createdAt';
    const direction = query.sortOrder || 'desc';

    // Because DTO validates against ALLOWED_SORT_FIELDS, we can safely apply it
    (orderBy as any)[field] = direction;

    return orderBy;
  }
}
