import {
  ConflictException,
  Injectable,
  Logger,
  NotFoundException,
} from "@nestjs/common";
import {
  Prisma,
  Gender,
  MaritalStatus,
  MatrimonialProfile,
  ProfileStatus,
  VerificationStatus,
  GovtEmploymentType,
  GovtVerificationStatus,
} from "@prisma/client";
import { PrismaService } from "../prisma/prisma.service";
import { CreateProfileDto } from "./dto/create-profile.dto";
import { UpdateProfileDto } from "./dto/update-profile.dto";
import {
  BaseProfileQueryDto,
  SortOrder,
  ProfileSortField,
} from "./dto/profile-query.dto";
import { SearchQueryDto } from "./dto/search-query.dto";
import { normalizeGender, normalizeMaritalStatus } from "./dto/normalize-profile.helper";
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
    const gender = normalizeGender(dto.gender) || dto.gender || Gender.MALE;
    const maritalStatus = normalizeMaritalStatus(dto.maritalStatus) || dto.maritalStatus || MaritalStatus.NEVER_MARRIED;
    const dob = dto.dateOfBirth
      ? new Date(dto.dateOfBirth)
      : new Date(1995, 0, 1);
    const validDob = isNaN(dob.getTime()) ? new Date(1995, 0, 1) : dob;

    try {
      const existingProfile = await this.prisma.matrimonialProfile.findUnique({
        where: { userId },
      });

      let profile: MatrimonialProfile;

      if (existingProfile) {
        profile = await this.prisma.matrimonialProfile.update({
          where: { id: existingProfile.id },
          data: {
            firstName: (dto.firstName || existingProfile.firstName).trim(),
            lastName: (dto.lastName || existingProfile.lastName).trim(),
            dateOfBirth: validDob,
            gender: gender,
            maritalStatus: maritalStatus,
            religion: dto.religion ? dto.religion.trim() : existingProfile.religion,
            caste: dto.caste ? dto.caste.trim() : existingProfile.caste,
            city: dto.city ? dto.city.trim() : existingProfile.city,
            state: dto.state ? dto.state.trim() : existingProfile.state,
            country: dto.country ? dto.country.trim() : existingProfile.country,
            education: dto.education ? dto.education.trim() : existingProfile.education,
            occupation: dto.occupation ? dto.occupation.trim() : existingProfile.occupation,
            organizationName: dto.organizationName
              ? dto.organizationName.trim()
              : existingProfile.organizationName,
            designation: dto.designation
              ? dto.designation.trim()
              : existingProfile.designation,
            nativePlace: dto.nativePlace
              ? dto.nativePlace.trim()
              : existingProfile.nativePlace,
            about: dto.about ? dto.about.trim() : existingProfile.about,
            photoUrl: dto.photoUrl ?? existingProfile.photoUrl,
            isPhysicallyDisabled: dto.isPhysicallyDisabled ?? existingProfile.isPhysicallyDisabled,
            pwbdCategory: dto.pwbdCategory
              ? dto.pwbdCategory.trim()
              : existingProfile.pwbdCategory,
            isAbroad: dto.isAbroad ?? existingProfile.isAbroad,
            abroadCountry: dto.abroadCountry
              ? dto.abroadCountry.trim()
              : existingProfile.abroadCountry,
            businessIndustry: dto.businessIndustry
              ? dto.businessIndustry.trim()
              : existingProfile.businessIndustry,
            businessService: dto.businessService
              ? dto.businessService.trim()
              : existingProfile.businessService,
            status: ProfileStatus.PENDING,
            isVerified: false,
          },
        });
      } else {
        profile = await this.prisma.matrimonialProfile.create({
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
            organizationName: dto.organizationName
              ? dto.organizationName.trim()
              : null,
            designation: dto.designation ? dto.designation.trim() : null,
            nativePlace: dto.nativePlace ? dto.nativePlace.trim() : null,
            about: dto.about ? dto.about.trim() : null,
            photoUrl: dto.photoUrl ?? null,
            isPhysicallyDisabled: dto.isPhysicallyDisabled ?? false,
            pwbdCategory: dto.pwbdCategory ? dto.pwbdCategory.trim() : null,
            isAbroad: dto.isAbroad ?? false,
            abroadCountry: dto.abroadCountry ? dto.abroadCountry.trim() : null,
            businessIndustry: dto.businessIndustry
              ? dto.businessIndustry.trim()
              : null,
            businessService: dto.businessService
              ? dto.businessService.trim()
              : null,
            status: ProfileStatus.PENDING,
            isVerified: false,
          },
        });
      }

      // Automatically register a VerificationRequest for Admin Review queue
      const docUrl = profile.photoUrl || dto.photoUrl || "/uploads/default-id.png";
      const existingReq = await this.prisma.verificationRequest.findFirst({
        where: { profileId: profile.id, status: VerificationStatus.PENDING },
      });

      if (existingReq) {
        await this.prisma.verificationRequest.update({
          where: { id: existingReq.id },
          data: {
            documentType: "Profile Photo & KYC",
            documentUrl: docUrl,
            status: VerificationStatus.PENDING,
            createdAt: new Date(),
          },
        });
      } else {
        await this.prisma.verificationRequest.create({
          data: {
            profileId: profile.id,
            documentType: "Profile Photo & KYC",
            documentUrl: docUrl,
            status: VerificationStatus.PENDING,
          },
        });
      }

      await this.syncSamajServicePerson(userId, profile);
      await this.syncGovernmentEmployment(profile);
      return profile;
    } catch (err: any) {
      if (err instanceof ConflictException) throw err;
      this.logger.warn(
        `PostgreSQL offline or error during DB profile create for user ${userId}: ${err?.message || err}`,
      );
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
        city: dto.city ? dto.city.trim() : null,
        state: dto.state ? dto.state.trim() : null,
        country: dto.country ? dto.country.trim() : null,
        education: dto.education ? dto.education.trim() : null,
        occupation: dto.occupation ? dto.occupation.trim() : null,
        organizationName: dto.organizationName
          ? dto.organizationName.trim()
          : null,
        designation: dto.designation ? dto.designation.trim() : null,
        nativePlace: dto.nativePlace ? dto.nativePlace.trim() : null,
        about: dto.about ? dto.about.trim() : null,
        photoUrl: dto.photoUrl ?? null,
        isPhysicallyDisabled: dto.isPhysicallyDisabled ?? false,
        pwbdCategory: dto.pwbdCategory ? dto.pwbdCategory.trim() : null,
        isAbroad: dto.isAbroad ?? false,
        abroadCountry: dto.abroadCountry ? dto.abroadCountry.trim() : null,
        businessIndustry: dto.businessIndustry
          ? dto.businessIndustry.trim()
          : null,
        businessService: dto.businessService
          ? dto.businessService.trim()
          : null,
        stateId: null,
        districtId: null,
        talukaId: null,
        parganaId: null,
        villageId: null,
        status: ProfileStatus.PENDING,
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
      let profile = await this.prisma.matrimonialProfile.findUnique({
        where: { userId },
      });

      if (!profile) {
        const user = await this.prisma.user.findUnique({
          where: { id: userId },
        });
        if (user) {
          const nameParts = (user.name || "User").trim().split(" ");
          profile = await this.prisma.matrimonialProfile.create({
            data: {
              userId,
              firstName: nameParts[0] || "User",
              lastName: nameParts.slice(1).join(" ") || "Member",
              gender: user.gender || Gender.MALE,
              dateOfBirth: new Date(2000, 0, 1),
              maritalStatus: MaritalStatus.NEVER_MARRIED,
              status: ProfileStatus.PENDING,
              isVerified: false,
            },
          });
        }
      }

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
      const profile = Array.from(this.memoryProfiles.values()).find(
        (p) => p.id === id,
      );
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
      if (dto.firstName !== undefined)
        updateData.firstName = dto.firstName.trim();
      if (dto.lastName !== undefined) updateData.lastName = dto.lastName.trim();
      if (dto.dateOfBirth !== undefined)
        updateData.dateOfBirth = new Date(dto.dateOfBirth);
      if (dto.gender !== undefined) updateData.gender = normalizeGender(dto.gender) || dto.gender;
      if (dto.maritalStatus !== undefined)
        updateData.maritalStatus = normalizeMaritalStatus(dto.maritalStatus) || dto.maritalStatus;
      if (dto.religion !== undefined)
        updateData.religion = dto.religion ? dto.religion.trim() : null;
      if (dto.caste !== undefined)
        updateData.caste = dto.caste ? dto.caste.trim() : null;
      if (dto.city !== undefined)
        updateData.city = dto.city ? dto.city.trim() : null;
      if (dto.state !== undefined)
        updateData.state = dto.state ? dto.state.trim() : null;
      if (dto.country !== undefined)
        updateData.country = dto.country ? dto.country.trim() : null;
      if (dto.education !== undefined)
        updateData.education = dto.education ? dto.education.trim() : null;
      if (dto.occupation !== undefined)
        updateData.occupation = dto.occupation ? dto.occupation.trim() : null;
      if (dto.organizationName !== undefined)
        updateData.organizationName = dto.organizationName
          ? dto.organizationName.trim()
          : null;
      if (dto.designation !== undefined)
        updateData.designation = dto.designation
          ? dto.designation.trim()
          : null;
      if (dto.nativePlace !== undefined)
        updateData.nativePlace = dto.nativePlace
          ? dto.nativePlace.trim()
          : null;
      if (dto.about !== undefined)
        updateData.about = dto.about ? dto.about.trim() : null;
      if (dto.photoUrl !== undefined) updateData.photoUrl = dto.photoUrl;

      if (dto.isPhysicallyDisabled !== undefined)
        updateData.isPhysicallyDisabled = dto.isPhysicallyDisabled;
      if (dto.pwbdCategory !== undefined)
        updateData.pwbdCategory = dto.pwbdCategory
          ? dto.pwbdCategory.trim()
          : null;
      if (dto.isAbroad !== undefined) updateData.isAbroad = dto.isAbroad;
      if (dto.abroadCountry !== undefined)
        updateData.abroadCountry = dto.abroadCountry
          ? dto.abroadCountry.trim()
          : null;
      if (dto.businessIndustry !== undefined)
        updateData.businessIndustry = dto.businessIndustry
          ? dto.businessIndustry.trim()
          : null;
      if (dto.businessService !== undefined)
        updateData.businessService = dto.businessService
          ? dto.businessService.trim()
          : null;

      const updatedProfile = await this.prisma.matrimonialProfile.update({
        where: { userId },
        data: updateData,
      });
      await this.syncSamajServicePerson(userId, updatedProfile);
      await this.syncGovernmentEmployment(updatedProfile);
      return updatedProfile;
    } catch (err: any) {
      if (err instanceof NotFoundException) throw err;
      const existing = this.memoryProfiles.get(userId);
      if (!existing) {
        throw new NotFoundException("Profile not found");
      }
      const updated: MatrimonialProfile = {
        ...existing,
        firstName:
          dto.firstName !== undefined
            ? dto.firstName.trim()
            : existing.firstName,
        lastName:
          dto.lastName !== undefined ? dto.lastName.trim() : existing.lastName,
        dateOfBirth:
          dto.dateOfBirth !== undefined
            ? new Date(dto.dateOfBirth)
            : existing.dateOfBirth,
        gender: dto.gender !== undefined ? dto.gender : existing.gender,
        maritalStatus:
          dto.maritalStatus !== undefined
            ? dto.maritalStatus
            : existing.maritalStatus,
        religion:
          dto.religion !== undefined
            ? dto.religion
              ? dto.religion.trim()
              : null
            : existing.religion,
        caste:
          dto.caste !== undefined
            ? dto.caste
              ? dto.caste.trim()
              : null
            : existing.caste,
        city:
          dto.city !== undefined
            ? dto.city
              ? dto.city.trim()
              : null
            : existing.city,
        state:
          dto.state !== undefined
            ? dto.state
              ? dto.state.trim()
              : null
            : existing.state,
        country:
          dto.country !== undefined
            ? dto.country
              ? dto.country.trim()
              : null
            : existing.country,
        education:
          dto.education !== undefined
            ? dto.education
              ? dto.education.trim()
              : null
            : existing.education,
        occupation:
          dto.occupation !== undefined
            ? dto.occupation
              ? dto.occupation.trim()
              : null
            : existing.occupation,
        organizationName:
          dto.organizationName !== undefined
            ? dto.organizationName
              ? dto.organizationName.trim()
              : null
            : existing.organizationName,
        designation:
          dto.designation !== undefined
            ? dto.designation
              ? dto.designation.trim()
              : null
            : existing.designation,
        nativePlace:
          dto.nativePlace !== undefined
            ? dto.nativePlace
              ? dto.nativePlace.trim()
              : null
            : existing.nativePlace,
        about:
          dto.about !== undefined
            ? dto.about
              ? dto.about.trim()
              : null
            : existing.about,
        photoUrl: dto.photoUrl !== undefined ? dto.photoUrl : existing.photoUrl,
        isPhysicallyDisabled:
          dto.isPhysicallyDisabled !== undefined
            ? dto.isPhysicallyDisabled
            : existing.isPhysicallyDisabled,
        pwbdCategory:
          dto.pwbdCategory !== undefined
            ? dto.pwbdCategory
              ? dto.pwbdCategory.trim()
              : null
            : existing.pwbdCategory,
        isAbroad: dto.isAbroad !== undefined ? dto.isAbroad : existing.isAbroad,
        abroadCountry:
          dto.abroadCountry !== undefined
            ? dto.abroadCountry
              ? dto.abroadCountry.trim()
              : null
            : existing.abroadCountry,
        businessIndustry:
          dto.businessIndustry !== undefined
            ? dto.businessIndustry
              ? dto.businessIndustry.trim()
              : null
            : existing.businessIndustry,
        businessService:
          dto.businessService !== undefined
            ? dto.businessService
              ? dto.businessService.trim()
              : null
            : existing.businessService,
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

    const where: Prisma.MatrimonialProfileWhereInput = {};

    // By default, show active approved and pending profiles so new candidate profiles appear immediately
    if (query.status) {
      where.status = query.status;
    } else {
      where.status = {
        in: [ProfileStatus.APPROVED, ProfileStatus.PENDING],
      };
    }

    // Resolve gender strictly: explicit gender or lookingFor
    const resolvedGender =
      query.gender || (query.lookingFor ? normalizeGender(query.lookingFor) : undefined);
    if (resolvedGender) {
      where.gender = resolvedGender;
    }

    if (query.maritalStatus) {
      where.maritalStatus = query.maritalStatus;
    }

    // Age filtering based on date of birth
    const minAge = query.ageMin ?? (query as any).ageFrom;
    const maxAge = query.ageMax ?? (query as any).ageTo;
    if (minAge || maxAge) {
      const today = new Date();
      where.dateOfBirth = {};

      if (minAge) {
        // If min age is 20, they must be born BEFORE (today - 20 years)
        const maxDate = new Date(
          today.getFullYear() - minAge,
          today.getMonth(),
          today.getDate(),
        );
        where.dateOfBirth.lte = maxDate;
      }

      if (maxAge) {
        // If max age is 30, they must be born AFTER (today - 31 years)
        const minDate = new Date(
          today.getFullYear() - maxAge - 1,
          today.getMonth(),
          today.getDate(),
        );
        where.dateOfBirth.gt = minDate;
      }
    }

    if (query.districtId) {
      where.districtId = query.districtId;
    }

    if (query.talukaId) {
      where.talukaId = query.talukaId;
    }

    if ((query as any).parganaId) {
      where.parganaId = (query as any).parganaId;
    }

    const andConditions: Prisma.MatrimonialProfileWhereInput[] = [];

    if (query.occupationCategory) {
      // Handle occupation categories
      if (query.occupationCategory.toUpperCase() === "GOVERNMENT") {
        andConditions.push({
          OR: [
            { governmentEmployment: { isNot: null } },
            { occupation: { contains: "Gov" } },
            { occupation: { contains: "સરકારી" } },
            { organizationName: { contains: "Gov" } },
            { organizationName: { contains: "સરકારી" } },
          ],
        });
      } else {
        andConditions.push({
          occupation: { contains: query.occupationCategory },
        });
      }
    }

    // Keyword search across multiple fields
    const searchTerm = query.search || (query as any).keyword;
    if (searchTerm && searchTerm.trim() !== "") {
      const term = searchTerm.trim();
      andConditions.push({
        OR: [
          { firstName: { contains: term } },
          { lastName: { contains: term } },
          { city: { contains: term } },
          { occupation: { contains: term } },
          { organizationName: { contains: term } },
          { designation: { contains: term } },
          { nativePlace: { contains: term } },
          { education: { contains: term } },
        ],
      });
    }

    const pargana = (query as any).pargana;
    if (pargana && pargana.trim() !== "") {
      andConditions.push({
        nativePlace: { contains: pargana.trim() },
      });
    }

    const city = (query as any).city;
    if (city && city.trim() !== "") {
      andConditions.push({
        city: { contains: city.trim() },
      });
    }

    const education = (query as any).education;
    if (education && education.trim() !== "") {
      andConditions.push({
        education: { contains: education.trim() },
      });
    }

    if (andConditions.length > 0) {
      where.AND = andConditions;
    }

    // Sort order
    const orderBy: Prisma.MatrimonialProfileOrderByWithRelationInput = {};
    const sortOrder = query.sortOrder === SortOrder.ASC ? "asc" : "desc";

    switch (query.sortBy) {
      case ProfileSortField.FIRST_NAME:
        orderBy.firstName = sortOrder;
        break;
      case ProfileSortField.AGE:
        // Sorting by age descending means sorting by DOB ascending
        orderBy.dateOfBirth = sortOrder === "desc" ? "asc" : "desc";
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
            },
          },
        },
      }),
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

  async searchProfiles(query: SearchQueryDto) {
    const baseQuery: BaseProfileQueryDto = {
      ...query,
      ageMin: query.ageMin ?? query.ageFrom,
      ageMax: query.ageMax ?? query.ageTo,
      search: query.search || query.keyword,
    };
    const result = await this.getProfiles(baseQuery);

    const formattedProfiles = result.items.map((p) => {
      let age = 25;
      if (p.dateOfBirth) {
        const diff = Date.now() - new Date(p.dateOfBirth).getTime();
        const calculatedAge = Math.floor(
          diff / (365.25 * 24 * 3600 * 1000),
        );
        if (calculatedAge >= 18 && calculatedAge <= 100) {
          age = calculatedAge;
        }
      }
      return {
        id: p.id,
        fullName: `${p.firstName} ${p.lastName}`.trim(),
        firstName: p.firstName,
        lastName: p.lastName,
        gender: p.gender,
        age,
        height: "5'6\"",
        pargana: p.nativePlace || "Gujarat",
        city: p.city || "Ahmedabad",
        education: p.education || "Graduate",
        occupation: p.occupation || p.designation || "Service",
        maritialStatus: p.maritalStatus || "Unmarried",
        isVerified: p.isVerified || false,
        photoUrl: p.photoUrl,
      };
    });

    return {
      profiles: formattedProfiles,
      items: result.items,
      meta: result.meta,
    };
  }

  private async syncSamajServicePerson(
    userId: string,
    profile: MatrimonialProfile,
  ) {
    if (
      profile.occupation?.includes("Business") &&
      profile.businessIndustry &&
      profile.businessService
    ) {
      const service = await this.prisma.samajService.findFirst({
        where: {
          category: profile.businessIndustry,
          title: profile.businessService,
        },
      });
      if (service) {
        const user = await this.prisma.user.findUnique({
          where: { id: userId },
        });
        if (user && user.phone) {
          const existingPerson = await this.prisma.samajServicePerson.findFirst(
            {
              where: { userId },
            },
          );
          const data = {
            serviceId: service.id,
            name: `${profile.firstName} ${profile.lastName}`.trim(),
            phone: user.phone,
            photoUrl: profile.photoUrl,
            city: profile.city,
            address: profile.nativePlace,
            description: profile.about,
          };
          if (existingPerson) {
            await this.prisma.samajServicePerson.update({
              where: { id: existingPerson.id },
              data,
            });
          } else {
            await this.prisma.samajServicePerson.create({
              data: { ...data, userId },
            });
          }
          return;
        }
      }
    }

    // If not business, remove existing
    await this.prisma.samajServicePerson.deleteMany({
      where: { userId },
    });
  }

  private async syncGovernmentEmployment(profile: any) {
    try {
      if (!profile || !profile.id) return;
      const occ = (profile.occupation || "").toLowerCase();
      const org = (profile.organizationName || "").toLowerCase();

      const isGov =
        occ.includes("gov") ||
        occ.includes("સરકારી") ||
        org.includes("gov") ||
        org.includes("સરકારી") ||
        occ.includes("state") ||
        occ.includes("central") ||
        org.includes("state") ||
        org.includes("central");

      if (isGov) {
        let empType: GovtEmploymentType = GovtEmploymentType.STATE_GOVT;
        if (
          org.includes("central") ||
          org.includes("કેન્દ્ર") ||
          occ.includes("central") ||
          occ.includes("કેન્દ્ર")
        ) {
          empType = GovtEmploymentType.CENTRAL_GOVT;
        } else if (
          org.includes("psu") ||
          org.includes("public") ||
          org.includes("જાહેર") ||
          occ.includes("psu")
        ) {
          empType = GovtEmploymentType.PSU;
        }

        const officeLoc =
          profile.city ||
          profile.state ||
          profile.nativePlace ||
          profile.organizationName ||
          "Gujarat";

        const existingGov = await this.prisma.governmentEmployment.findUnique({
          where: { profileId: profile.id },
        });

        if (existingGov) {
          await this.prisma.governmentEmployment.update({
            where: { id: existingGov.id },
            data: {
              employmentType: empType,
              officeLocation: officeLoc,
              verificationStatus: GovtVerificationStatus.VERIFIED,
              isActive: true,
              isFeatured: profile.isFeatured || false,
            },
          });
        } else {
          await this.prisma.governmentEmployment.create({
            data: {
              profileId: profile.id,
              employmentType: empType,
              officeLocation: officeLoc,
              verificationStatus: GovtVerificationStatus.VERIFIED,
              isActive: true,
              isFeatured: profile.isFeatured || false,
            },
          });
        }
      }
    } catch (err: any) {
      this.logger.warn(
        `Failed to sync government employment for profile ${profile?.id}: ${err?.message || err}`,
      );
    }
  }
}
