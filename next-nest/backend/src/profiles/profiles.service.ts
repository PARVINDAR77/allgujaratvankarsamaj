import {
  ConflictException,
  Injectable,
  Logger,
  NotFoundException,
  OnModuleInit,
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
export class ProfilesService implements OnModuleInit {
  private readonly logger = new Logger(ProfilesService.name);
  private readonly memoryProfiles: Map<string, MatrimonialProfile> = new Map();

  async onModuleInit() {
    try {
      await this.prisma.$executeRawUnsafe(`
        ALTER TABLE matrimonial_profiles MODIFY COLUMN marital_status ENUM('NEVER_MARRIED', 'MARRIED', 'DIVORCED', 'WIDOWED', 'SEPARATED') NOT NULL DEFAULT 'NEVER_MARRIED';
      `);
      this.logger.log('Matrimonial profile marital_status ENUM updated in database.');
    } catch (e: any) {
      this.logger.warn(`Candidate marital status enum sync: ${e.message}`);
    }

    try {
      await this.prisma.$executeRawUnsafe(`
        UPDATE matrimonial_profiles 
        SET gender = 'FEMALE' 
        WHERE LOWER(first_name) LIKE '%ben%' 
           OR LOWER(first_name) LIKE '%bahen%' 
           OR first_name LIKE '%બેન%' 
           OR first_name LIKE '%બહેન%'
           OR LOWER(first_name) IN ('dipika', 'sakshi', 'pooja', 'priya', 'neha', 'dula', 'dulaben', 'heena', 'kinjal', 'payal', 'kiran', 'sheetal', 'rekha');
      `);
      await this.prisma.$executeRawUnsafe(`
        UPDATE users 
        SET gender = 'FEMALE' 
        WHERE id IN (SELECT user_id FROM matrimonial_profiles WHERE gender = 'FEMALE');
      `);
      this.logger.log('Candidate gender synchronization completed in database.');
    } catch (e: any) {
      this.logger.warn(`Candidate gender sync: ${e.message}`);
    }
  }

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

      const profilePayload = {
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
        bloodGroup: dto.bloodGroup ? dto.bloodGroup.trim() : null,
        isVankar: dto.isVankar ?? true,
        annualIncome: dto.annualIncome ? dto.annualIncome.trim() : null,
        fatherName: dto.fatherName ? dto.fatherName.trim() : null,
        fatherOccupation: dto.fatherOccupation ? dto.fatherOccupation.trim() : null,
        fatherContact: dto.fatherContact ? dto.fatherContact.trim() : null,
        motherName: dto.motherName ? dto.motherName.trim() : null,
        motherOccupation: dto.motherOccupation ? dto.motherOccupation.trim() : null,
        guardianContact: dto.guardianContact ? dto.guardianContact.trim() : null,
        siblings: dto.siblings ? dto.siblings.trim() : null,
        mamasVillage: dto.mamasVillage ? dto.mamasVillage.trim() : null,
        addressLine: dto.addressLine ? dto.addressLine.trim() : null,
        pincode: dto.pincode ? dto.pincode.trim() : null,
        altPhone: dto.altPhone ? dto.altPhone.trim() : null,
        contactEmail: dto.contactEmail ? dto.contactEmail.trim() : null,
        motherTongue: dto.motherTongue ? dto.motherTongue.trim() : "Gujarati (ગુજરાતી)",
      };

      if (existingProfile) {
        profile = await this.prisma.matrimonialProfile.update({
          where: { id: existingProfile.id },
          data: {
            ...profilePayload,
            firstName: dto.firstName ? dto.firstName.trim() : existingProfile.firstName,
            lastName: dto.lastName ? dto.lastName.trim() : existingProfile.lastName,
            religion: dto.religion !== undefined ? (dto.religion ? dto.religion.trim() : null) : existingProfile.religion,
            caste: dto.caste !== undefined ? (dto.caste ? dto.caste.trim() : null) : existingProfile.caste,
            city: dto.city !== undefined ? (dto.city ? dto.city.trim() : null) : existingProfile.city,
            state: dto.state !== undefined ? (dto.state ? dto.state.trim() : null) : existingProfile.state,
            country: dto.country !== undefined ? (dto.country ? dto.country.trim() : null) : existingProfile.country,
            education: dto.education !== undefined ? (dto.education ? dto.education.trim() : null) : existingProfile.education,
            occupation: dto.occupation !== undefined ? (dto.occupation ? dto.occupation.trim() : null) : existingProfile.occupation,
            organizationName: dto.organizationName !== undefined ? (dto.organizationName ? dto.organizationName.trim() : null) : existingProfile.organizationName,
            designation: dto.designation !== undefined ? (dto.designation ? dto.designation.trim() : null) : existingProfile.designation,
            nativePlace: dto.nativePlace !== undefined ? (dto.nativePlace ? dto.nativePlace.trim() : null) : existingProfile.nativePlace,
            about: dto.about !== undefined ? (dto.about ? dto.about.trim() : null) : existingProfile.about,
            photoUrl: dto.photoUrl !== undefined ? dto.photoUrl : existingProfile.photoUrl,
            status: ProfileStatus.PENDING,
            isVerified: false,
          },
        });
      } else {
        const customId = dto.id && dto.id.trim().length > 0 ? dto.id.trim() : undefined;
        profile = await this.prisma.matrimonialProfile.create({
          data: {
            ...(customId ? { id: customId } : {}),
            userId,
            ...profilePayload,
            status: ProfileStatus.PENDING,
            isVerified: false,
          },
        });
      }

      // Also sync user phone/email if user provided contact details
      if (dto.altPhone || dto.contactEmail) {
        try {
          const userUpdates: any = {};
          if (dto.altPhone) userUpdates.phone = dto.altPhone.trim();
          if (dto.contactEmail) userUpdates.email = dto.contactEmail.trim();
          await this.prisma.user.update({
            where: { id: userId },
            data: userUpdates,
          });
        } catch (_) {}
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
        bloodGroup: dto.bloodGroup ? dto.bloodGroup.trim() : null,
        isVankar: dto.isVankar ?? true,
        annualIncome: dto.annualIncome ? dto.annualIncome.trim() : null,
        fatherName: dto.fatherName ? dto.fatherName.trim() : null,
        fatherOccupation: dto.fatherOccupation ? dto.fatherOccupation.trim() : null,
        fatherContact: dto.fatherContact ? dto.fatherContact.trim() : null,
        motherName: dto.motherName ? dto.motherName.trim() : null,
        motherOccupation: dto.motherOccupation ? dto.motherOccupation.trim() : null,
        guardianContact: dto.guardianContact ? dto.guardianContact.trim() : null,
        siblings: dto.siblings ? dto.siblings.trim() : null,
        mamasVillage: dto.mamasVillage ? dto.mamasVillage.trim() : null,
        addressLine: dto.addressLine ? dto.addressLine.trim() : null,
        pincode: dto.pincode ? dto.pincode.trim() : null,
        altPhone: dto.altPhone ? dto.altPhone.trim() : null,
        contactEmail: dto.contactEmail ? dto.contactEmail.trim() : null,
        motherTongue: dto.motherTongue ? dto.motherTongue.trim() : "Gujarati (ગુજરાતી)",
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
      let profile = await this.prisma.matrimonialProfile.findUnique({
        where: { id },
        include: {
          user: {
            select: { phone: true, email: true },
          },
          governmentEmployment: {
            include: {
              department: true,
              designation: true,
            },
          },
        },
      });

      if (!profile) {
        profile = await this.prisma.matrimonialProfile.findFirst({
          where: {
            OR: [
              { id },
              { userId: id },
            ],
          },
          include: {
            user: {
              select: { phone: true, email: true },
            },
            governmentEmployment: {
              include: {
                department: true,
                designation: true,
              },
            },
          },
        });
      }

      if (!profile) {
        throw new NotFoundException("Profile not found");
      }

      return profile;
    } catch (err: any) {
      if (err instanceof NotFoundException) throw err;
      const profile = Array.from(this.memoryProfiles.values()).find(
        (p) => p.id === id || p.userId === id,
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

      if (dto.bloodGroup !== undefined)
        updateData.bloodGroup = dto.bloodGroup ? dto.bloodGroup.trim() : null;
      if (dto.isVankar !== undefined)
        updateData.isVankar = dto.isVankar;
      if (dto.annualIncome !== undefined)
        updateData.annualIncome = dto.annualIncome ? dto.annualIncome.trim() : null;
      if (dto.fatherName !== undefined)
        updateData.fatherName = dto.fatherName ? dto.fatherName.trim() : null;
      if (dto.fatherOccupation !== undefined)
        updateData.fatherOccupation = dto.fatherOccupation ? dto.fatherOccupation.trim() : null;
      if (dto.fatherContact !== undefined)
        updateData.fatherContact = dto.fatherContact ? dto.fatherContact.trim() : null;
      if (dto.motherName !== undefined)
        updateData.motherName = dto.motherName ? dto.motherName.trim() : null;
      if (dto.motherOccupation !== undefined)
        updateData.motherOccupation = dto.motherOccupation ? dto.motherOccupation.trim() : null;
      if (dto.guardianContact !== undefined)
        updateData.guardianContact = dto.guardianContact ? dto.guardianContact.trim() : null;
      if (dto.siblings !== undefined)
        updateData.siblings = dto.siblings ? dto.siblings.trim() : null;
      if (dto.mamasVillage !== undefined)
        updateData.mamasVillage = dto.mamasVillage ? dto.mamasVillage.trim() : null;
      if (dto.addressLine !== undefined)
        updateData.addressLine = dto.addressLine ? dto.addressLine.trim() : null;
      if (dto.pincode !== undefined)
        updateData.pincode = dto.pincode ? dto.pincode.trim() : null;
      if (dto.altPhone !== undefined)
        updateData.altPhone = dto.altPhone ? dto.altPhone.trim() : null;
      if (dto.contactEmail !== undefined)
        updateData.contactEmail = dto.contactEmail ? dto.contactEmail.trim() : null;
      if (dto.motherTongue !== undefined)
        updateData.motherTongue = dto.motherTongue ? dto.motherTongue.trim() : "Gujarati (ગુજરાતી)";

      const updatedProfile = await this.prisma.matrimonialProfile.update({
        where: { userId },
        data: updateData,
        include: {
          user: {
            select: { phone: true, email: true },
          },
          governmentEmployment: {
            include: {
              department: true,
              designation: true,
            },
          },
        },
      });

      if (dto.altPhone || dto.contactEmail) {
        try {
          const userUpdates: any = {};
          if (dto.altPhone) userUpdates.phone = dto.altPhone.trim();
          if (dto.contactEmail) userUpdates.email = dto.contactEmail.trim();
          await this.prisma.user.update({
            where: { id: userId },
            data: userUpdates,
          });
        } catch (_) {}
      }

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
        bloodGroup:
          dto.bloodGroup !== undefined
            ? dto.bloodGroup
              ? dto.bloodGroup.trim()
              : null
            : existing.bloodGroup,
        isVankar:
          dto.isVankar !== undefined ? dto.isVankar : existing.isVankar,
        annualIncome:
          dto.annualIncome !== undefined
            ? dto.annualIncome
              ? dto.annualIncome.trim()
              : null
            : existing.annualIncome,
        fatherName:
          dto.fatherName !== undefined
            ? dto.fatherName
              ? dto.fatherName.trim()
              : null
            : existing.fatherName,
        fatherOccupation:
          dto.fatherOccupation !== undefined
            ? dto.fatherOccupation
              ? dto.fatherOccupation.trim()
              : null
            : existing.fatherOccupation,
        fatherContact:
          dto.fatherContact !== undefined
            ? dto.fatherContact
              ? dto.fatherContact.trim()
              : null
            : existing.fatherContact,
        motherName:
          dto.motherName !== undefined
            ? dto.motherName
              ? dto.motherName.trim()
              : null
            : existing.motherName,
        motherOccupation:
          dto.motherOccupation !== undefined
            ? dto.motherOccupation
              ? dto.motherOccupation.trim()
              : null
            : existing.motherOccupation,
        guardianContact:
          dto.guardianContact !== undefined
            ? dto.guardianContact
              ? dto.guardianContact.trim()
              : null
            : existing.guardianContact,
        siblings:
          dto.siblings !== undefined
            ? dto.siblings
              ? dto.siblings.trim()
              : null
            : existing.siblings,
        mamasVillage:
          dto.mamasVillage !== undefined
            ? dto.mamasVillage
              ? dto.mamasVillage.trim()
              : null
            : existing.mamasVillage,
        addressLine:
          dto.addressLine !== undefined
            ? dto.addressLine
              ? dto.addressLine.trim()
              : null
            : existing.addressLine,
        pincode:
          dto.pincode !== undefined
            ? dto.pincode
              ? dto.pincode.trim()
              : null
            : existing.pincode,
        altPhone:
          dto.altPhone !== undefined
            ? dto.altPhone
              ? dto.altPhone.trim()
              : null
            : existing.altPhone,
        contactEmail:
          dto.contactEmail !== undefined
            ? dto.contactEmail
              ? dto.contactEmail.trim()
              : null
            : existing.contactEmail,
        motherTongue:
          dto.motherTongue !== undefined
            ? dto.motherTongue
              ? dto.motherTongue.trim()
              : "Gujarati (ગુજરાતી)"
            : existing.motherTongue,
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
      if (resolvedGender === Gender.FEMALE) {
        where.OR = [
          { gender: Gender.FEMALE },
          { firstName: { endsWith: "ben" } },
          { firstName: { endsWith: "bahen" } },
          { firstName: { contains: "બેન" } },
          { firstName: { contains: "બહેન" } },
          { firstName: { in: ["Dipika", "Sakshi", "DULABEN", "dipika", "sakshi", "dulaben", "Dulaben", "Dula"] } },
        ];
      } else if (resolvedGender === Gender.MALE) {
        where.gender = Gender.MALE;
        where.NOT = [
          { firstName: { endsWith: "ben" } },
          { firstName: { endsWith: "bahen" } },
          { firstName: { contains: "બેન" } },
          { firstName: { contains: "બહેન" } },
          { firstName: { in: ["Dipika", "Sakshi", "DULABEN", "dipika", "sakshi", "dulaben", "Dulaben", "Dula"] } },
        ];
      } else {
        where.gender = resolvedGender;
      }
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
          { id: { contains: term } },
          { firstName: { contains: term } },
          { lastName: { contains: term } },
          { city: { contains: term } },
          { state: { contains: term } },
          { occupation: { contains: term } },
          { organizationName: { contains: term } },
          { designation: { contains: term } },
          { nativePlace: { contains: term } },
          { education: { contains: term } },
          { fatherName: { contains: term } },
          { motherName: { contains: term } },
          { mamasVillage: { contains: term } },
          { annualIncome: { contains: term } },
          { bloodGroup: { contains: term } },
          { religion: { contains: term } },
          { caste: { contains: term } },
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
          user: {
            select: {
              phone: true,
              email: true,
            },
          },
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

    const formattedProfiles = result.items.map((p: any) => {
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
      let effectiveGender = p.gender;
      const fn = (p.firstName || "").toLowerCase().trim();
      if (
        fn.endsWith("ben") ||
        fn.endsWith("bahen") ||
        fn.includes("બેન") ||
        fn.includes("બહેન") ||
        ["dipika", "sakshi", "dulaben", "dula", "pooja", "priya", "heena"].includes(fn)
      ) {
        effectiveGender = Gender.FEMALE;
      }

      return {
        id: p.id,
        fullName: `${p.firstName} ${p.lastName}`.trim(),
        firstName: p.firstName,
        lastName: p.lastName,
        gender: effectiveGender,
        age,
        dateOfBirth: p.dateOfBirth,
        height: "5'6\"",
        pargana: p.nativePlace || "Gujarat",
        nativePlace: p.nativePlace,
        city: p.city || "Ahmedabad",
        state: p.state || "Gujarat",
        district: p.state,
        country: p.country || "India",
        education: p.education || "Graduate",
        occupation: p.occupation || p.designation || "Service",
        employmentType: p.occupation,
        organizationName: p.organizationName,
        department: p.organizationName,
        designation: p.designation,
        maritalStatus: p.maritalStatus || "NEVER_MARRIED",
        maritialStatus: p.maritalStatus || "Unmarried",
        isVerified: p.isVerified || false,
        photoUrl: p.photoUrl,
        about: p.about,
        religion: p.religion,
        caste: p.caste,
        subcaste: p.subcaste,
        bloodGroup: p.bloodGroup,
        isVankar: p.isVankar,
        annualIncome: p.annualIncome,
        fatherName: p.fatherName,
        fatherOccupation: p.fatherOccupation,
        fatherContact: p.fatherContact,
        motherName: p.motherName,
        motherOccupation: p.motherOccupation,
        guardianContact: p.guardianContact,
        siblings: p.siblings,
        mamasVillage: p.mamasVillage,
        addressLine: p.addressLine,
        pincode: p.pincode,
        altPhone: p.altPhone,
        contactEmail: p.contactEmail,
        motherTongue: p.motherTongue,
        isPhysicallyDisabled: p.isPhysicallyDisabled,
        pwbdCategory: p.pwbdCategory,
        isAbroad: p.isAbroad,
        abroadCountry: p.abroadCountry,
        businessIndustry: p.businessIndustry,
        businessService: p.businessService,
        user: p.user,
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
    profile: any,
  ) {
    try {
      if (!profile || !userId) return;

      const occ = (profile.occupation || "").toLowerCase();
      const isBusinessOrService =
        occ.includes("business") ||
        occ.includes("સ્વરોજગાર") ||
        occ.includes("વેપાર") ||
        occ.includes("દુકાન") ||
        occ.includes("self") ||
        Boolean(profile.businessIndustry && profile.businessIndustry !== "Select Industry") ||
        Boolean(profile.businessService && profile.businessService !== "Select Service");

      if (isBusinessOrService && (profile.businessService || profile.businessIndustry || profile.designation)) {
        // 1. Resolve matching SamajService with flexible matching
        let service: any = null;

        if (profile.businessService && profile.businessService !== "Select Service") {
          // Exact title match
          service = await this.prisma.samajService.findFirst({
            where: {
              title: profile.businessService.trim(),
              isActive: true,
            },
          });

          // Flexible match by title or description
          if (!service) {
            const cleanTitle = profile.businessService
              .replace(/\(.*?\)/g, "")
              .replace(/[-—/]/g, " ")
              .trim();
            if (cleanTitle.length > 2) {
              service = await this.prisma.samajService.findFirst({
                where: {
                  OR: [
                    { title: { contains: cleanTitle } },
                    { description: { contains: cleanTitle } },
                  ],
                  isActive: true,
                },
              });
            }
          }
        }

        // Fallback: match by category if service still not resolved
        if (!service && profile.businessIndustry && profile.businessIndustry !== "Select Industry") {
          const cleanCat = profile.businessIndustry.replace(/\(.*?\)/g, "").trim();
          service = await this.prisma.samajService.findFirst({
            where: {
              category: { contains: cleanCat },
              isActive: true,
            },
          });
        }

        if (service) {
          // 2. Resolve Contact Phone with robust fallback chain
          let phone = (profile.altPhone || "").trim();
          if (!phone) {
            const user = await this.prisma.user.findUnique({
              where: { id: userId },
              select: { phone: true },
            });
            phone = (user?.phone || "").trim();
          }
          if (!phone) {
            phone = (profile.fatherContact || profile.guardianContact || "").trim();
          }

          if (phone && phone.length >= 8) {
            const fullName = `${profile.firstName || ""} ${profile.lastName || ""}`.trim() || "Samaj Professional";
            const businessName = (profile.organizationName || "").trim();
            const designation = (profile.designation || "").trim();
            const desc = businessName
              ? `${businessName}${designation ? ` (${designation})` : ""} - ${profile.about || service.title}`
              : (profile.about || designation || service.title);

            // 3. Resolve location IDs (districtId, talukaId)
            let districtId = profile.districtId || null;
            if (!districtId && profile.state && profile.state.trim().length > 1) {
              const d = await this.prisma.district.findFirst({
                where: {
                  OR: [
                    { name: { contains: profile.state.trim() } },
                    { gujaratiName: { contains: profile.state.trim() } },
                  ],
                },
              });
              if (d) districtId = d.id;
            }

            let talukaId = profile.talukaId || null;
            if (!talukaId && profile.city && profile.city.trim().length > 1) {
              const t = await this.prisma.taluka.findFirst({
                where: {
                  OR: [
                    { name: { contains: profile.city.trim() } },
                    { gujaratiName: { contains: profile.city.trim() } },
                  ],
                  ...(districtId ? { districtId } : {}),
                },
              });
              if (t) talukaId = t.id;
            }

            const existingPerson = await this.prisma.samajServicePerson.findFirst({
              where: { userId },
            });

            const personData: any = {
              serviceId: service.id,
              userId,
              name: fullName,
              gujaratiName: fullName,
              phone: phone,
              photoUrl: profile.photoUrl || null,
              city: profile.city || profile.state || null,
              address: profile.addressLine || profile.nativePlace || profile.city || null,
              description: desc,
              experience: "અનુભવી વ્યવસાયી (Experienced)",
              districtId,
              talukaId,
              villageId: profile.villageId || null,
              isActive: true,
            };

            if (existingPerson) {
              await this.prisma.samajServicePerson.update({
                where: { id: existingPerson.id },
                data: personData,
              });
              this.logger.log(`Synced SamajServicePerson for user ${userId} under service: ${service.title}`);
            } else {
              await this.prisma.samajServicePerson.create({
                data: personData,
              });
              this.logger.log(`Created new SamajServicePerson for user ${userId} under service: ${service.title}`);
            }
            return;
          }
        }
      }

      // If user changed away from business, remove their entry from directory
      await this.prisma.samajServicePerson.deleteMany({
        where: { userId },
      });
    } catch (err: any) {
      this.logger.warn(`Error syncing SamajServicePerson for user ${userId}: ${err?.message || err}`);
    }
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

  async getFamilyDirectory(search?: string) {
    const where: Prisma.MatrimonialProfileWhereInput = {
      status: "APPROVED",
    };

    if (search && search.trim() !== "") {
      const term = search.trim();
      where.OR = [
        { lastName: { contains: term } },
        { firstName: { contains: term } },
        { fatherName: { contains: term } },
        { motherName: { contains: term } },
        { mamasVillage: { contains: term } },
        { nativePlace: { contains: term } },
        { city: { contains: term } },
        { state: { contains: term } },
      ];
    }

    try {
      const profiles = await this.prisma.matrimonialProfile.findMany({
        where,
        orderBy: { updatedAt: "desc" },
        take: 100,
        include: {
          user: {
            select: { phone: true, email: true },
          },
          district: true,
          taluka: true,
          pargana: true,
        },
      });

      return profiles.map((p) => {
        const surnameEng = p.lastName || "Vankar";
        const surnameGuj = this.translateSurnameGuj(surnameEng);
        const cityEng = p.city || p.district?.name || p.state || "Gujarat";
        const cityGuj = p.district?.gujaratiName || this.translateCityGuj(cityEng);
        const mosal = p.mamasVillage || p.nativePlace || "Gujarat";
        const details = `મોસાળ: ${mosal} | Masal: ${mosal}`;

        return {
          id: p.id,
          nameGuj: `${surnameGuj} પરિવાર`,
          nameEng: `${surnameEng} Family`,
          surname: surnameEng,
          cityGuj,
          cityEng,
          details,
          mosal,
          nativePlace: p.nativePlace || cityEng,
          pargana: p.pargana?.name || p.pargana?.gujaratiName || "",
          district: p.district?.name || p.state || "",
          taluka: p.taluka?.name || "",
          fatherName: p.fatherName || "",
          fatherOccupation: p.fatherOccupation || "",
          fatherContact: p.fatherContact || p.user?.phone || "",
          motherName: p.motherName || "",
          motherOccupation: p.motherOccupation || "",
          guardianContact: p.guardianContact || "",
          siblings: p.siblings || "",
          address: p.addressLine || "",
          pincode: p.pincode || "",
          candidateName: `${p.firstName} ${p.lastName}`.trim(),
          candidateGender: p.gender,
          candidateAge: p.dateOfBirth
            ? Math.floor((Date.now() - new Date(p.dateOfBirth).getTime()) / (365.25 * 24 * 3600 * 1000))
            : 25,
          candidateEducation: p.education || "",
          candidateOccupation: p.occupation || p.designation || "",
          photoUrl: p.photoUrl || "",
          isVerified: p.isVerified || false,
        };
      });
    } catch (err: any) {
      this.logger.warn(`Failed to fetch family directory: ${err?.message || err}`);
      return [];
    }
  }

  private translateSurnameGuj(name: string): string {
    const map: Record<string, string> = {
      Kapadiya: "કપડીયા",
      Vankar: "વાંકર",
      Solanki: "સોલંકી",
      Chauhan: "ચૌહાણ",
      Patel: "પટેલ",
      Parmar: "પરમાર",
      Makwana: "મકવાણા",
      Rathod: "રાઠોડ",
      Jadav: "જાદવ",
      Vaghela: "વાઘેલા",
      Gohel: "ગોહેલ",
      Chavda: "ચાવડા",
      Maru: "મારુ",
      Dabhi: "ડાભી",
      Rohit: "રોહિત",
      Shrimali: "શ્રીમાળી",
      Baraiya: "બારૈયા",
      Tank: "ટાંક",
      Bhati: "ભાટી",
      Vegda: "વેગડા",
      Purani: "પુરાણી",
      Maheria: "મહેરિયા",
      Rentiya: "રેંટિયા",
      Patil: "પાટીલ",
    };
    for (const key of Object.keys(map)) {
      if (name.toLowerCase().includes(key.toLowerCase())) {
        return map[key];
      }
    }
    return name;
  }

  private translateCityGuj(city: string): string {
    const map: Record<string, string> = {
      Ahmedabad: "અમદાવાદ",
      Surat: "સુરત",
      Vadodara: "વડોદરા",
      Rajkot: "રાજકોટ",
      Bhavnagar: "ભાવનગર",
      Jamnagar: "જામનગર",
      Junagadh: "જૂનાગઢ",
      Gandhinagar: "ગાંધીનગર",
      Himatnagar: "હિંમતનગર",
      Patan: "પાટણ",
      Mehsana: "મહેસાણા",
      Idar: "ઈડર",
      Unjha: "ઊંઝા",
      Navsari: "નવસારી",
      Anand: "આણંદ",
      Nadiad: "નડિયાદ",
      Bharuch: "ભરૂચ",
      Valsad: "વલસાડ",
      Kutch: "કચ્છ",
      Bhuj: "ભુજ",
      Surendranagar: "સુરેન્દ્રનગર",
      Morbi: "મોરબી",
      Amreli: "અમરેલી",
      Porbandar: "પોરબંદર",
      Palanpur: "પાલનપુર",
      Godhra: "ગોધરા",
    };
    for (const key of Object.keys(map)) {
      if (city.toLowerCase().includes(key.toLowerCase())) {
        return map[key];
      }
    }
    return city;
  }
}
