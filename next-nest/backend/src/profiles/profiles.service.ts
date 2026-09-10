import {
  ConflictException,
  Injectable,
  Logger,
  NotFoundException,
} from "@nestjs/common";
import { Gender, MaritalStatus, MatrimonialProfile } from "@prisma/client";
import { PrismaService } from "../prisma/prisma.service";
import { CreateProfileDto } from "./dto/create-profile.dto";
import { UpdateProfileDto } from "./dto/update-profile.dto";
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
          firstName: dto.firstName.trim(),
          lastName: dto.lastName.trim(),
          dateOfBirth: new Date(dto.dateOfBirth),
          gender: dto.gender,
          maritalStatus: dto.maritalStatus,
          religion: dto.religion ? dto.religion.trim() : null,
          caste: dto.caste ? dto.caste.trim() : null,
          city: dto.city ? dto.city.trim() : null,
          state: dto.state ? dto.state.trim() : null,
          country: dto.country ? dto.country.trim() : null,
          education: dto.education ? dto.education.trim() : null,
          occupation: dto.occupation ? dto.occupation.trim() : null,
          about: dto.about ? dto.about.trim() : null,
        },
      });
    } catch (err: any) {
      if (err instanceof ConflictException) throw err;
      this.logger.warn(`PostgreSQL offline, creating profile in-memory for user ${userId}`);
      if (this.memoryProfiles.has(userId)) {
        throw new ConflictException("Profile already exists");
      }
      const profile: MatrimonialProfile = {
        id: uuidv4(),
        userId,
        firstName: dto.firstName.trim(),
        lastName: dto.lastName.trim(),
        dateOfBirth: new Date(dto.dateOfBirth),
        gender: dto.gender,
        maritalStatus: dto.maritalStatus,
        religion: dto.religion ? dto.religion.trim() : null,
        caste: dto.caste ? dto.caste.trim() : null,
        city: dto.city ? dto.city.trim() : null,
        state: dto.state ? dto.state.trim() : null,
        country: dto.country ? dto.country.trim() : null,
        education: dto.education ? dto.education.trim() : null,
        occupation: dto.occupation ? dto.occupation.trim() : null,
        about: dto.about ? dto.about.trim() : null,
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

  async searchProfiles(query: {
    lookingFor?: string;
    maritalStatus?: string;
    city?: string;
    education?: string;
    occupation?: string;
    keyword?: string;
  }) {
    const demoCandidates = [
      {
        id: "VNK-101",
        firstName: "Pooja",
        lastName: "Vankar",
        gender: "FEMALE",
        maritalStatus: "NEVER_MARRIED",
        city: "Ahmedabad",
        education: "B.Tech Computer Engineering",
        occupation: "Software Engineer",
        pargana: "Kantha Pargana",
        age: 25,
        height: "5'4\"",
      },
      {
        id: "VNK-102",
        firstName: "Rahul",
        lastName: "Vankar",
        gender: "MALE",
        maritalStatus: "NEVER_MARRIED",
        city: "Vadodara",
        education: "MBA Finance",
        occupation: "Assistant Manager",
        pargana: "Charotar Pargana",
        age: 28,
        height: "5'9\"",
      },
      {
        id: "VNK-103",
        firstName: "Jignesh",
        lastName: "Vankar",
        gender: "MALE",
        maritalStatus: "NEVER_MARRIED",
        city: "Gandhinagar",
        education: "BE Mechanical",
        occupation: "GPSC Class-2 Officer",
        pargana: "North Gujarat Pargana",
        age: 29,
        height: "5'11\"",
      },
      {
        id: "VNK-104",
        firstName: "Hiralben",
        lastName: "Kapadiya",
        gender: "FEMALE",
        maritalStatus: "NEVER_MARRIED",
        city: "Idar",
        education: "B.Ed Teacher",
        occupation: "Teacher",
        pargana: "Sabarkantha Pargana",
        age: 24,
        height: "5'3\"",
      },
      {
        id: "VNK-105",
        firstName: "Hemantkumar",
        lastName: "Kapadiya",
        gender: "MALE",
        maritalStatus: "NEVER_MARRIED",
        city: "Himatnagar",
        education: "B.E. Engineer",
        occupation: "Engineer",
        pargana: "Sabarkantha Pargana",
        age: 27,
        height: "5'7\"",
      },
    ];

    try {
      const whereClause: any = {};
      if (query.lookingFor === "Bride") whereClause.gender = "FEMALE";
      if (query.lookingFor === "Groom") whereClause.gender = "MALE";
      if (query.city && query.city !== "Any") {
        whereClause.city = { contains: query.city, mode: "insensitive" };
      }
      const dbProfiles = await this.prisma.matrimonialProfile.findMany({
        where: whereClause,
      });
      if (dbProfiles && dbProfiles.length > 0) return dbProfiles;
    } catch {
      // Return filtered demo candidates if DB is offline/empty
    }

    return demoCandidates.filter((c) => {
      if (query.lookingFor === "Bride" && c.gender !== "FEMALE") return false;
      if (query.lookingFor === "Groom" && c.gender !== "MALE") return false;
      if (query.city && query.city !== "Any" && !c.city.toLowerCase().includes(query.city.toLowerCase())) return false;
      if (query.keyword) {
        const k = query.keyword.toLowerCase();
        const fullText = `${c.firstName} ${c.lastName} ${c.city} ${c.education} ${c.occupation} ${c.pargana}`.toLowerCase();
        if (!fullText.includes(k)) return false;
      }
      return true;
    });
  }
}
