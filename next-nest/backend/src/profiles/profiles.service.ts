import {
  ConflictException,
  Injectable,
  Logger,
  NotFoundException,
} from "@nestjs/common";
import { Gender, MaritalStatus, MatrimonialProfile, ProfileStatus } from "@prisma/client";
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

  async searchProfiles(query: {
    lookingFor?: string;
    maritalStatus?: string;
    city?: string;
    education?: string;
    occupation?: string;
    keyword?: string;
  }) {
    const maleFirstNames = ['Ramesh', 'Suresh', 'Jignesh', 'Mahesh', 'Bhavesh', 'Pankaj', 'Jayesh', 'Kiran', 'Nitin', 'Vijay', 'Pravin', 'Dinesh', 'Ketan', 'Alpesh', 'Rajesh', 'Hitesh', 'Kamlesh', 'Chetan', 'Dipak', 'Vishal', 'Amit', 'Hardik', 'Sanjay', 'Girish', 'Ashok'];
    const femaleFirstNames = ['Pooja', 'Hiral', 'Neeta', 'Kavita', 'Riddhi', 'Bhavana', 'Daxaben', 'Kinjal', 'Nisha', 'Sejal', 'Jalpa', 'Meghaben', 'Komal', 'Purvi', 'Swati', 'Priti', 'Payal', 'Sheetal', 'Sonam', 'Dipali', 'Arti', 'Geetaben', 'Rekhaben', 'Sonal', 'Varsha'];
    const lastNames = ['Vankar', 'Parmar', 'Solanki', 'Chauhan', 'Rathod', 'Makwana', 'Jadav', 'Vaghela', 'Gohel', 'Kapadiya', 'Chavda', 'Dabhi', 'Rohit', 'Mahyavanshi', 'Chitroda'];
    const cities = ['Ahmedabad', 'Vadodara', 'Surat', 'Rajkot', 'Gandhinagar', 'Himatnagar', 'Idar', 'Anand', 'Nadiad', 'Mehsana'];
    const educations = ['B.Tech Computer Engineering', 'BE Mechanical', 'M.Sc IT', 'MBA Finance', 'MBBS Doctor', 'B.Ed Teacher', 'B.Com Accounting', 'M.Com', 'BCA / MCA', 'Diploma Electrical'];
    const occupations = ['Software Engineer', 'GPSC Class-2 Officer', 'High School Teacher', 'Bank Manager', 'Government Servant', 'Assistant Engineer', 'Private Sector Employee', 'Business Owner', 'Pharmacist', 'Police Sub-Inspector'];
    const parganas = ['35 Pargana', '27 Pargana', '16 Pargana', '14 Pargana', 'Kantha Pargana', 'Charotar Pargana', 'Sabarkantha Pargana', 'North Gujarat Pargana'];

    const demoCandidates = Array.from({ length: 100 }, (_, i) => {
      const isMale = i % 2 !== 0;
      const gender = isMale ? "MALE" : "FEMALE";
      const firstName = isMale
        ? maleFirstNames[i % maleFirstNames.length]
        : femaleFirstNames[i % femaleFirstNames.length];
      const lastName = lastNames[i % lastNames.length];
      const city = cities[i % cities.length];
      const education = educations[i % educations.length];
      const occupation = occupations[i % occupations.length];
      const pargana = parganas[i % parganas.length];
      const age = 22 + (i % 16);
      const feet = 5 + Math.floor((i % 10) / 4);
      const inches = (i % 10);
      const height = `${feet}'${inches}"`;

      return {
        id: `VNK-${100 + i + 1}`,
        firstName,
        lastName,
        gender,
        maritalStatus: "NEVER_MARRIED",
        city,
        education,
        occupation,
        pargana,
        age,
        height,
        photoUrl: `https://picsum.photos/seed/${i + 100}/400/400`,
      };
    });

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
