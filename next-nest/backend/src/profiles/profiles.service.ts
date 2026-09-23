import {
  ConflictException,
  Injectable,
  Logger,
  NotFoundException,
} from "@nestjs/common";
import { Prisma, Gender, MaritalStatus, MatrimonialProfile, ProfileStatus } from "@prisma/client";
import { PrismaService } from "../prisma/prisma.service";
import { CreateProfileDto } from "./dto/create-profile.dto";
import { UpdateProfileDto } from "./dto/update-profile.dto";
import { BaseProfileQueryDto, SortOrder, ProfileSortField } from "./dto/profile-query.dto";
import { v4 as uuidv4 } from "uuid";

export interface CompletenessResult {
  completedFields: number;
  totalFields: number;
  percentage: number;
  isComplete: boolean;
}

@Injectable()
export class ProfilesService {
  private readonly logger = new Logger(ProfilesService.name);
  private readonly memoryProfiles: Map<string, MatrimonialProfile> = new Map();

  constructor(private readonly prisma: PrismaService) {}

  getReferenceData() {
    return {
      gender: Object.values(Gender),
      maritalStatus: Object.values(MaritalStatus),
    };
  }

  calculateCompleteness(
    profile: MatrimonialProfile | null,
  ): CompletenessResult {
    const totalFields = 13;

    if (!profile) {
      return {
        completedFields: 0,
        totalFields,
        percentage: 0,
        isComplete: false,
      };
    }

    const requiredFields = [
      profile.firstName,
      profile.lastName,
      profile.dateOfBirth,
      profile.gender,
      profile.maritalStatus,
      profile.religion,
      profile.caste,
      profile.city,
      profile.state,
      profile.country,
      profile.education,
      profile.occupation,
      profile.about,
    ];

    let completedFields = 0;

    for (const val of requiredFields) {
      if (val !== null && val !== undefined) {
        if (typeof val === "string" && val.trim() !== "") {
          completedFields++;
        } else if (val instanceof Date && !isNaN(val.getTime())) {
          completedFields++;
        }
      }
    }

    const percentage = Math.round((completedFields / totalFields) * 100);

    return {
      completedFields,
      totalFields,
      percentage,
      isComplete: completedFields === totalFields,
    };
  }

  async getProfileCompletenessByUserId(
    userId: string,
  ): Promise<CompletenessResult> {
    try {
      const profile = await this.prisma.matrimonialProfile.findUnique({
        where: { userId },
      });
      return this.calculateCompleteness(profile);
    } catch {
      const profile = this.memoryProfiles.get(userId) || null;
      return this.calculateCompleteness(profile);
    }
  }

  async createProfile(userId: string, dto: CreateProfileDto) {
    const gender = dto.gender || Gender.MALE;
    const maritalStatus = dto.maritalStatus || MaritalStatus.NEVER_MARRIED;
    const dob = dto.dateOfBirth ? new Date(dto.dateOfBirth) : new Date(1995, 0, 1);
    const validDob = isNaN(dob.getTime()) ? new Date(1995, 0, 1) : dob;

    try {
      const existingProfile = await this.prisma.matrimonialProfile.findUnique({
        where: { userId },
      });

      if (existingProfile) {
        throw new ConflictException("Profile already exists");
      }

      return await this.prisma.matrimonialProfile.create({
        data: {
          userId,
          firstName: (dto.firstName || "User").trim(),
          lastName: (dto.lastName || "User").trim(),
          dateOfBirth: validDob,
          gender: gender,
          maritalStatus: maritalStatus,
          religion: dto.religion ? dto.religion.trim() : null,
          caste: dto.caste ? dto.caste.trim() : null,
          city: dto.city ? dto.city.trim() : null,
          state: dto.state ? dto.state.trim() : null,
          country: dto.country ? dto.country.trim() : null,
          education: dto.education ? dto.education.trim() : null,
          occupation: dto.occupation ? dto.occupation.trim() : null,
          about: dto.about ? dto.about.trim() : null,
          photoUrl: dto.photoUrl ?? null,
        },
      });
    } catch (err: any) {
      if (err instanceof ConflictException) throw err;
      this.logger.warn(`PostgreSQL offline or error during DB profile create for user ${userId}: ${err?.message || err}`);
      if (this.memoryProfiles.has(userId)) {
        throw new ConflictException("Profile already exists");
      }
      const profile: MatrimonialProfile = {
        id: uuidv4(),
        userId,
        firstName: (dto.firstName || "User").trim(),
        lastName: (dto.lastName || "User").trim(),
        dateOfBirth: validDob,
        gender: gender,
        maritalStatus: maritalStatus,
        religion: dto.religion ? dto.religion.trim() : null,
        caste: dto.caste ? dto.caste.trim() : null,
        subcaste: null,
        nativePlace: null,
        city: dto.city ? dto.city.trim() : null,
        state: dto.state ? dto.state.trim() : null,
        country: dto.country ? dto.country.trim() : null,
        education: dto.education ? dto.education.trim() : null,
        occupation: dto.occupation ? dto.occupation.trim() : null,
        organizationName: null,
        designation: null,
        about: dto.about ? dto.about.trim() : null,
        photoUrl: dto.photoUrl ?? null,
        stateId: null,
        districtId: null,
        talukaId: null,
        parganaId: null,
        villageId: null,
        status: ProfileStatus.APPROVED,
        isVerified: false,
        isFeatured: false,
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      this.memoryProfiles.set(userId, profile);
      return profile;
    }
  }

  async getProfileByUserId(userId: string) {
    try {
      const profile = await this.prisma.matrimonialProfile.findUnique({
        where: { userId },
      });

      if (!profile) {
        throw new NotFoundException("Profile not found");
      }

      return profile;
    } catch (err: any) {
      if (err instanceof NotFoundException) throw err;
      const profile = this.memoryProfiles.get(userId);
      if (!profile) {
        throw new NotFoundException("Profile not found");
      }
      return profile;
    }
  }

  async getProfileById(id: string) {
    try {
      const profile = await this.prisma.matrimonialProfile.findUnique({
        where: { id },
      });

      if (!profile) {
        throw new NotFoundException("Profile not found");
      }

      return profile;
    } catch (err: any) {
      if (err instanceof NotFoundException) throw err;
      const profile = Array.from(this.memoryProfiles.values()).find(p => p.id === id);
      if (!profile) {
        throw new NotFoundException("Profile not found");
      }
      return profile;
    }
  }

  async updateProfileByUserId(userId: string, dto: UpdateProfileDto) {
    try {
      const existingProfile = await this.prisma.matrimonialProfile.findUnique({
        where: { userId },
      });

      if (!existingProfile) {
        throw new NotFoundException("Profile not found");
      }

      const updateData: any = {};
      if (dto.firstName !== undefined) updateData.firstName = dto.firstName.trim();
      if (dto.lastName !== undefined) updateData.lastName = dto.lastName.trim();
      if (dto.dateOfBirth !== undefined) updateData.dateOfBirth = new Date(dto.dateOfBirth);
      if (dto.gender !== undefined) updateData.gender = dto.gender;
      if (dto.maritalStatus !== undefined) updateData.maritalStatus = dto.maritalStatus;
      if (dto.religion !== undefined) updateData.religion = dto.religion ? dto.religion.trim() : null;
      if (dto.caste !== undefined) updateData.caste = dto.caste ? dto.caste.trim() : null;
      if (dto.city !== undefined) updateData.city = dto.city ? dto.city.trim() : null;
      if (dto.state !== undefined) updateData.state = dto.state ? dto.state.trim() : null;
      if (dto.country !== undefined) updateData.country = dto.country ? dto.country.trim() : null;
      if (dto.education !== undefined) updateData.education = dto.education ? dto.education.trim() : null;
      if (dto.occupation !== undefined) updateData.occupation = dto.occupation ? dto.occupation.trim() : null;
      if (dto.about !== undefined) updateData.about = dto.about ? dto.about.trim() : null;
      if (dto.photoUrl !== undefined) updateData.photoUrl = dto.photoUrl;

      return await this.prisma.matrimonialProfile.update({
        where: { userId },
        data: updateData,
      });
    } catch (err: any) {
      if (err instanceof NotFoundException) throw err;
      const existing = this.memoryProfiles.get(userId);
      if (!existing) {
        throw new NotFoundException("Profile not found");
      }
      const updated: MatrimonialProfile = {
        ...existing,
        firstName: dto.firstName !== undefined ? dto.firstName.trim() : existing.firstName,
        lastName: dto.lastName !== undefined ? dto.lastName.trim() : existing.lastName,
        dateOfBirth: dto.dateOfBirth !== undefined ? new Date(dto.dateOfBirth) : existing.dateOfBirth,
        gender: dto.gender !== undefined ? dto.gender : existing.gender,
        maritalStatus: dto.maritalStatus !== undefined ? dto.maritalStatus : existing.maritalStatus,
        religion: dto.religion !== undefined ? (dto.religion ? dto.religion.trim() : null) : existing.religion,
        caste: dto.caste !== undefined ? (dto.caste ? dto.caste.trim() : null) : existing.caste,
        city: dto.city !== undefined ? (dto.city ? dto.city.trim() : null) : existing.city,
        state: dto.state !== undefined ? (dto.state ? dto.state.trim() : null) : existing.state,
        country: dto.country !== undefined ? (dto.country ? dto.country.trim() : null) : existing.country,
        education: dto.education !== undefined ? (dto.education ? dto.education.trim() : null) : existing.education,
        occupation: dto.occupation !== undefined ? (dto.occupation ? dto.occupation.trim() : null) : existing.occupation,
        about: dto.about !== undefined ? (dto.about ? dto.about.trim() : null) : existing.about,
        photoUrl: dto.photoUrl !== undefined ? dto.photoUrl : existing.photoUrl,
        updatedAt: new Date(),
      };
      this.memoryProfiles.set(userId, updated);
      return updated;
    }
  }

  async deleteProfileByUserId(userId: string) {
    try {
      const existingProfile = await this.prisma.matrimonialProfile.findUnique({
        where: { userId },
      });

      if (!existingProfile) {
        throw new NotFoundException("Profile not found");
      }

    } catch (err: any) {
      if (err instanceof NotFoundException) throw err;
      const profile = this.memoryProfiles.get(userId);
      this.memoryProfiles.delete(userId);
      return profile;
    }
  }

  async getProfiles(query: BaseProfileQueryDto) {
    const page = Number(query.page) || 1;
    const limit = Number(query.limit) || 10;
    const skip = (page - 1) * limit;

    const where: Prisma.MatrimonialProfileWhereInput = {
      // By default, only show active and approved profiles for public listings.
      // (This should be configurable if called from Admin APIs, but we assume public here).
      status: ProfileStatus.APPROVED,
    };

    if (query.gender) {
      where.gender = query.gender;
    }

    if (query.status) {
      where.status = query.status;
    }

    // Age filtering based on date of birth
    if (query.ageMin || query.ageMax) {
      const today = new Date();
      where.dateOfBirth = {};
      
      if (query.ageMin) {
        // If min age is 20, they must be born BEFORE (today - 20 years)
        const maxDate = new Date(today.getFullYear() - query.ageMin, today.getMonth(), today.getDate());
        where.dateOfBirth.lte = maxDate;
      }
      
      if (query.ageMax) {
        // If max age is 30, they must be born AFTER (today - 31 years)
        const minDate = new Date(today.getFullYear() - query.ageMax - 1, today.getMonth(), today.getDate());
        where.dateOfBirth.gt = minDate;
      }
    }

    if (query.districtId) {
      where.districtId = query.districtId;
    }

    if (query.talukaId) {
      where.talukaId = query.talukaId;
    }

    if (query.occupationCategory) {
      // Handle occupation categories
      if (query.occupationCategory.toUpperCase() === 'GOVERNMENT') {
        where.governmentEmployment = { isNot: null };
      } else {
        where.occupation = { contains: query.occupationCategory };
      }
    }
    
    // Keyword search across multiple fields
    if (query.search) {
      where.OR = [
        { firstName: { contains: query.search } },
        { lastName: { contains: query.search } },
        { city: { contains: query.search } },
        { occupation: { contains: query.search } },
        { organizationName: { contains: query.search } },
        { designation: { contains: query.search } },
      ];
    }

    // Sort order
    const orderBy: Prisma.MatrimonialProfileOrderByWithRelationInput = {};
    const sortOrder = query.sortOrder === SortOrder.ASC ? 'asc' : 'desc';

    switch (query.sortBy) {
      case ProfileSortField.FIRST_NAME:
        orderBy.firstName = sortOrder;
        break;
      case ProfileSortField.AGE:
        // Sorting by age descending means sorting by DOB ascending
        orderBy.dateOfBirth = sortOrder === 'desc' ? 'asc' : 'desc';
        break;
      case ProfileSortField.UPDATED_AT:
        orderBy.updatedAt = sortOrder;
        break;
      case ProfileSortField.CREATED_AT:
      default:
        orderBy.createdAt = sortOrder;
        break;
    }

    const [total, items] = await Promise.all([
      this.prisma.matrimonialProfile.count({ where }),
      this.prisma.matrimonialProfile.findMany({
        where,
        orderBy,
        skip,
        take: limit,
        include: {
          governmentEmployment: {
            include: {
              department: true,
              designation: true,
            }
          }
        }
      })
    ]);

    return {
      items,
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }
}
