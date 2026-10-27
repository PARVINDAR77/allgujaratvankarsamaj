import {
  BadRequestException,
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
  Status,
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
  private static readonly memoryProfiles: Map<string, MatrimonialProfile> = new Map();

  public static clearMemoryProfile(idOrUserId: string) {
    ProfilesService.memoryProfiles.delete(idOrUserId);
    for (const [key, val] of ProfilesService.memoryProfiles.entries()) {
      if (val.id === idOrUserId || val.userId === idOrUserId) {
        ProfilesService.memoryProfiles.delete(key);
      }
    }
  }

  private get memoryProfiles() {
    return ProfilesService.memoryProfiles;
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

  /**
   * Enforce ID Proof Single-Use Rules:
   * 1. One person can add/submit ID proof only one time (locked after verification/approval).
   * 2. Another person cannot add the same ID (by ID Number, file hash, or document URL).
   */
  async validateIdProofUniqueness(
    currentProfileId: string | null,
    dto: {
      idProofType?: string;
      idProofNumber?: string;
      idProofFrontUrl?: string;
      idProofBackUrl?: string;
    },
    isAlreadyVerified = false,
  ) {
    const hasAnyIdProof = !!(
      (dto.idProofNumber && dto.idProofNumber.trim().length > 0) ||
      (dto.idProofFrontUrl && dto.idProofFrontUrl.trim().length > 0) ||
      (dto.idProofBackUrl && dto.idProofBackUrl.trim().length > 0)
    );

    if (!hasAnyIdProof) return;

    // Rule 1: One person can add ID proof only one time.
    // If the profile is ALREADY verified, user cannot change or re-submit their ID proof.
    if (isAlreadyVerified) {
      throw new ConflictException(
        "તમારી પ્રોફાઇલ પહેલેથી જ વેરિફાઈડ છે. ઓળખપત્ર માત્ર એક જ વાર ઉમેરી શકાય છે. (Your profile is already verified. ID proof can only be added one time.)",
      );
    }

    if (currentProfileId) {
      const alreadyApproved = await this.prisma.verificationRequest.findFirst({
        where: {
          profileId: currentProfileId,
          status: VerificationStatus.VERIFIED,
        },
      });
      if (alreadyApproved) {
        throw new ConflictException(
          "તમારા દસ્તાવેજો પહેલેથી જ મંજૂર થયેલ છે. ઓળખપત્ર માત્ર એક જ વાર ઉમેરી શકાય છે. (Verification already approved. ID proof can only be used one time.)",
        );
      }
    }

    // Rule 2: Another person cannot add the same ID that was used previously.
    // A) Check ID Proof Number (e.g. Aadhaar Number, Voter ID, PAN, Driving License)
    const rawNumber = dto.idProofNumber?.trim();
    if (rawNumber && rawNumber.length > 0) {
      const cleanNumber = rawNumber.replace(/[\s\-_]/g, "").toUpperCase();
      if (cleanNumber.length >= 4) {
        // 1. Check in verification_requests of other candidates
        const numUsedInVerif = await this.prisma.verificationRequest.findFirst({
          where: {
            ...(currentProfileId ? { profileId: { not: currentProfileId } } : {}),
            OR: [
              { documentType: { contains: cleanNumber } },
              { rejectionReason: { contains: cleanNumber } },
            ],
          },
        });
        if (numUsedInVerif) {
          throw new ConflictException(
            "આ ઓળખપત્ર નંબર અન્ય સભ્ય દ્વારા પહેલેથી જ ઉપયોગમાં લેવાયેલ છે. એક ઓળખપત્ર માત્ર એક જ વ્યક્તિ ઉપયોગ કરી શકે છે. (This ID proof number has already been used by another candidate. Each ID proof can only be used once.)",
          );
        }

        // 2. Check in matrimonial_profiles (privacySettings JSON) of other candidates
        const numUsedInProfile = await this.prisma.matrimonialProfile.findFirst({
          where: {
            ...(currentProfileId ? { id: { not: currentProfileId } } : {}),
            privacySettings: { contains: cleanNumber },
          },
        });
        if (numUsedInProfile) {
          throw new ConflictException(
            "આ ઓળખપત્ર નંબર અન્ય સભ્ય દ્વારા પહેલેથી જ ઉપયોગમાં લેવાયેલ છે. એક ઓળખપત્ર માત્ર એક જ વ્યક્તિ ઉપયોગ કરી શકે છે. (This ID proof number has already been used by another candidate. Each ID proof can only be used once.)",
          );
        }
      }
    }

    // B) Check ID Proof Documents / Image URLs / Image Hashes (SHA-256)
    const frontUrl = dto.idProofFrontUrl?.trim().toLowerCase();
    const backUrl = dto.idProofBackUrl?.trim().toLowerCase();

    const extractIdentifier = (url?: string) => {
      if (!url) return null;
      const filename = url.split("/").pop()?.split("?")[0];
      if (!filename || filename.length < 5) return null;
      return filename;
    };

    const frontFile = extractIdentifier(frontUrl);
    const backFile = extractIdentifier(backUrl);

    // Extract SHA-256 hash or core identifier from filename (e.g. idproof_HASH_uuid.ext)
    const extractHash = (filename?: string | null) => {
      if (!filename) return null;
      const match = filename.match(/idproof_([a-f0-9]{16,64})/i) || filename.match(/doc_([a-f0-9]{16,64})/i);
      return match ? match[1] : null;
    };

    const frontHash = extractHash(frontFile);
    const backHash = extractHash(backFile);

    const docFilters: any[] = [];
    if (frontUrl && !frontUrl.includes("default-id.png")) {
      docFilters.push({ documentUrl: frontUrl });
      docFilters.push({ documentBackUrl: frontUrl });
    }
    if (backUrl) {
      docFilters.push({ documentUrl: backUrl });
      docFilters.push({ documentBackUrl: backUrl });
    }
    if (frontFile && !frontFile.includes("default-id.png")) {
      docFilters.push({ documentUrl: { contains: frontFile } });
      docFilters.push({ documentBackUrl: { contains: frontFile } });
    }
    if (backFile) {
      docFilters.push({ documentUrl: { contains: backFile } });
      docFilters.push({ documentBackUrl: { contains: backFile } });
    }
    if (frontHash) {
      docFilters.push({ documentUrl: { contains: frontHash } });
      docFilters.push({ documentBackUrl: { contains: frontHash } });
    }
    if (backHash) {
      docFilters.push({ documentUrl: { contains: backHash } });
      docFilters.push({ documentBackUrl: { contains: backHash } });
    }

    if (docFilters.length > 0) {
      const docUsedElsewhere = await this.prisma.verificationRequest.findFirst({
        where: {
          ...(currentProfileId ? { profileId: { not: currentProfileId } } : {}),
          OR: docFilters,
        },
      });

      if (docUsedElsewhere) {
        throw new ConflictException(
          "આ ઓળખપત્ર દસ્તાવેજ અન્ય ઉમેદવાર દ્વારા પહેલેથી જ જમા થયેલ છે. દસ્તાવેજો માત્ર એક જ વાર ઉપયોગ કરી શકાય છે. (This ID proof document has already been submitted for another candidate. Documents can only be used one time.)",
        );
      }

      const govtDocUsed = await this.prisma.governmentEmploymentVerification.findFirst({
        where: {
          OR: docFilters.map((f) => ({ documentUrl: f.documentUrl || f.documentBackUrl })),
        },
      });
      if (govtDocUsed) {
        throw new ConflictException(
          "આ ઓળખપત્ર દસ્તાવેજ પહેલેથી જ જમા થયેલ છે. દસ્તાવેજો માત્ર એક જ વાર ઉપયોગ કરી શકાય છે. (This document has already been submitted. Documents can only be used one time.)",
        );
      }
    }
  }

  async createProfile(userId: string, dto: CreateProfileDto) {
    const gender = normalizeGender(dto.gender) || dto.gender || Gender.MALE;
    const maritalStatus = normalizeMaritalStatus(dto.maritalStatus) || dto.maritalStatus || MaritalStatus.NEVER_MARRIED;
    const dob = dto.dateOfBirth
      ? new Date(dto.dateOfBirth)
      : new Date(1995, 0, 1);
    const validDob = isNaN(dob.getTime()) ? new Date(1995, 0, 1) : dob;

    const phoneRegex = /^[6-9]\d{9}$/;
    if (dto.contactPhone && !phoneRegex.test(dto.contactPhone.trim())) {
      throw new BadRequestException(
        "મોબાઇલ નંબર માન્ય 10 અંકનો હોવો જોઈએ (Mobile number must be exactly 10 digits starting with 6-9)",
      );
    }
    if (dto.altPhone && !phoneRegex.test(dto.altPhone.trim())) {
      throw new BadRequestException(
        "વોટ્સએપ / વૈકલ્પિક મોબાઇલ નંબર માન્ય 10 અંકનો હોવો જોઈએ (WhatsApp/Alt phone must be 10 digits starting with 6-9)",
      );
    }
    if (dto.fatherContact && !phoneRegex.test(dto.fatherContact.trim())) {
      throw new BadRequestException(
        "પિતાનો સંપર્ક નંબર માન્ય 10 અંકનો હોવો જોઈએ (Father contact must be 10 digits starting with 6-9)",
      );
    }
    if (dto.guardianContact && !phoneRegex.test(dto.guardianContact.trim())) {
      throw new BadRequestException(
        "વાલીનો સંપર્ક નંબર માન્ય 10 અંકનો હોવો જોઈએ (Guardian contact must be 10 digits starting with 6-9)",
      );
    }
    if (dto.pincode && !/^\d{6}$/.test(dto.pincode.trim())) {
      throw new BadRequestException(
        "પીનકોડ બરાબર 6 અંકનો હોવો જોઈએ (Pincode must be exactly 6 digits)",
      );
    }

    const cleanEmail = dto.contactEmail
      ? dto.contactEmail.trim().toLowerCase()
      : null;
    if (cleanEmail) {
      const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
      if (!emailRegex.test(cleanEmail)) {
        throw new BadRequestException(
          "કૃપા કરીને માન્ય ઈમેઈલ સરનામું દાખલ કરો (Please enter a valid email address)",
        );
      }

      // Candidate can use email in ONE TIME ONLY: verify no other user or profile uses this email
      const otherUser = await this.prisma.user.findFirst({
        where: { email: cleanEmail, id: { not: userId } },
      });
      if (otherUser) {
        throw new ConflictException(
          "આ ઈમેઈલ અન્ય ઉમેદવાર દ્વારા પહેલેથી જ વપરાયેલ છે. ઉમેદવાર માત્ર એક જ વાર ઈમેઈલનો ઉપયોગ કરી શકે છે. (This email is already in use by another candidate. Candidates can only use their email one time.)",
        );
      }

      const otherProfile = await this.prisma.matrimonialProfile.findFirst({
        where: { contactEmail: cleanEmail, userId: { not: userId } },
      });
      if (otherProfile) {
        throw new ConflictException(
          "આ ઈમેઈલ અન્ય ઉમેદવારની પ્રોફાઇલમાં પહેલેથી જ વપરાયેલ છે. ઉમેદવાર માત્ર એક જ વાર ઈમેઈલનો ઉપયોગ કરી શકે છે. (This email is already in use by another candidate. Candidates can only use their email one time.)",
        );
      }
    }

    let photosJson: string | null = null;
    if (dto.photos) {
      if (Array.isArray(dto.photos)) {
        photosJson = JSON.stringify(dto.photos);
      } else if (typeof dto.photos === "string") {
        photosJson = dto.photos.trim().startsWith("[")
          ? dto.photos.trim()
          : JSON.stringify([dto.photos.trim()]);
      }
    }

    const primaryPhoto =
      dto.photoUrl ||
      (Array.isArray(dto.photos) && dto.photos.length > 0 ? dto.photos[0] : null);

    const isGirlCandidate =
      gender === Gender.FEMALE ||
      (dto.firstName && (
        dto.firstName.toLowerCase().endsWith("ben") ||
        dto.firstName.toLowerCase().endsWith("bahen") ||
        dto.firstName.includes("બેન") ||
        dto.firstName.includes("બહેન")
      ));

    let resolvedPrivacySettings: string;
    if (dto.privacySettings) {
      resolvedPrivacySettings = typeof dto.privacySettings === 'string'
        ? dto.privacySettings
        : JSON.stringify(dto.privacySettings);
    } else {
      resolvedPrivacySettings = JSON.stringify({
        mobile: isGirlCandidate ? "માત્ર મને" : (dto.mobilePrivacy || "બધા માટે"),
        email: isGirlCandidate ? "માત્ર મને" : (dto.emailPrivacy || "બધા માટે"),
        address: dto.addressPrivacy || "પરિવારજનો",
        guardian: dto.guardianPrivacy || "બધા માટે",
        shareClassGroup: dto.shareClassGroup === true || dto.shareClassGroup === 'true',
      });
    }

    try {
      const existingProfile = await this.prisma.matrimonialProfile.findUnique({
        where: { userId },
      });

      // Enforce ID proof single-use and uniqueness rules
      await this.validateIdProofUniqueness(
        existingProfile ? existingProfile.id : null,
        dto,
        existingProfile ? existingProfile.isVerified : false,
      );

      let profile: MatrimonialProfile;

      const profilePayload = {
        firstName: (dto.firstName || "User").trim(),
        lastName: (dto.lastName || "User").trim(),
        dateOfBirth: validDob,
        gender: gender,
        maritalStatus: maritalStatus,
        religion: dto.religion ? dto.religion.trim() : null,
        caste: dto.caste ? dto.caste.trim() : null,
        subcaste: dto.subcaste ? dto.subcaste.trim() : null,
        city: dto.city ? dto.city.trim() : null,
        state: dto.state ? dto.state.trim() : null,
        country: dto.country ? dto.country.trim() : null,
        education: dto.education ? dto.education.trim() : null,
        occupation: dto.occupation ? dto.occupation.trim() : null,
        organizationName: (dto.organizationName || (dto as any).department)
          ? (dto.organizationName || (dto as any).department).trim()
          : null,
        designation: dto.designation ? dto.designation.trim() : null,
        nativePlace: dto.nativePlace ? dto.nativePlace.trim() : null,
        about: dto.about ? dto.about.trim() : null,
        photoUrl: primaryPhoto ?? null,
        photos: photosJson,
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
        privacySettings: resolvedPrivacySettings,
        showInMatrimony: maritalStatus === MaritalStatus.MARRIED
          ? false
          : (dto.showInMatrimony !== undefined
            ? (dto.showInMatrimony === true || dto.showInMatrimony === 'true' || dto.showInMatrimony === 1 || dto.showInMatrimony === '1')
            : true),
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
            subcaste: dto.subcaste !== undefined ? (dto.subcaste ? dto.subcaste.trim() : null) : existingProfile.subcaste,
            city: dto.city !== undefined ? (dto.city ? dto.city.trim() : null) : existingProfile.city,
            state: dto.state !== undefined ? (dto.state ? dto.state.trim() : null) : existingProfile.state,
            country: dto.country !== undefined ? (dto.country ? dto.country.trim() : null) : existingProfile.country,
            education: dto.education !== undefined ? (dto.education ? dto.education.trim() : null) : existingProfile.education,
            occupation: dto.occupation !== undefined ? (dto.occupation ? dto.occupation.trim() : null) : existingProfile.occupation,
            organizationName: dto.organizationName !== undefined ? (dto.organizationName ? dto.organizationName.trim() : null) : existingProfile.organizationName,
            designation: dto.designation !== undefined ? (dto.designation ? dto.designation.trim() : null) : existingProfile.designation,
            nativePlace: dto.nativePlace !== undefined ? (dto.nativePlace ? dto.nativePlace.trim() : null) : existingProfile.nativePlace,
            about: dto.about !== undefined ? (dto.about ? dto.about.trim() : null) : existingProfile.about,
            photoUrl: primaryPhoto !== undefined ? primaryPhoto : existingProfile.photoUrl,
            photos: photosJson !== null ? photosJson : existingProfile.photos,
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
      const primaryPhone = dto.contactPhone?.trim() || dto.altPhone?.trim();
      if (primaryPhone || dto.contactEmail) {
        try {
          const userUpdates: any = {};
          if (primaryPhone) userUpdates.phone = primaryPhone;
          if (dto.contactEmail) userUpdates.email = dto.contactEmail.trim();
          await this.prisma.user.update({
            where: { id: userId },
            data: userUpdates,
          });
        } catch (_) {}
      }

      // Automatically register a VerificationRequest for Admin Review queue
      const docType = dto.idProofType?.trim() || "Aadhaar Card";
      const cleanNum = dto.idProofNumber ? dto.idProofNumber.replace(/[\s\-_]/g, "").toUpperCase() : null;
      const fullDocType = cleanNum ? `${docType} [ID: ${cleanNum}]` : docType;
      const docFront = dto.idProofFrontUrl?.trim() || profile.photoUrl || dto.photoUrl || "/uploads/default-id.png";
      const docBack = dto.idProofBackUrl?.trim() || null;

      // Persist ID Proof Number into profile's privacySettings
      if (cleanNum) {
        try {
          const parsedPrivacy = typeof profile.privacySettings === 'string'
            ? JSON.parse(profile.privacySettings)
            : (profile.privacySettings || {});
          parsedPrivacy.idProofNumber = cleanNum;
          parsedPrivacy.idProofType = docType;
          await this.prisma.matrimonialProfile.update({
            where: { id: profile.id },
            data: { privacySettings: JSON.stringify(parsedPrivacy) },
          });
        } catch (_) {}
      }

      const existingReq = await this.prisma.verificationRequest.findFirst({
        where: { profileId: profile.id },
        orderBy: { createdAt: "desc" },
      });

      if (existingReq) {
        await this.prisma.verificationRequest.update({
          where: { id: existingReq.id },
          data: {
            documentType: fullDocType,
            documentUrl: docFront,
            documentBackUrl: docBack,
            status: VerificationStatus.PENDING,
            rejectionReason: null,
            createdAt: new Date(),
          },
        });
      } else {
        await this.prisma.verificationRequest.create({
          data: {
            profileId: profile.id,
            documentType: fullDocType,
            documentUrl: docFront,
            documentBackUrl: docBack,
            status: VerificationStatus.PENDING,
          },
        });
      }

      await this.syncSamajServicePerson(userId, profile);
      await this.syncGovernmentEmployment(profile);
      return profile;
    } catch (err: any) {
      if (err instanceof ConflictException || err instanceof BadRequestException) throw err;
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
        photoUrl: primaryPhoto ?? null,
        photos: photosJson,
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
        privacySettings: resolvedPrivacySettings,
        stateId: null,
        districtId: null,
        talukaId: null,
        parganaId: null,
        villageId: null,
        status: ProfileStatus.PENDING,
        isVerified: false,
        isFeatured: false,
        showInMatrimony: dto.showInMatrimony !== undefined
          ? (dto.showInMatrimony === true || dto.showInMatrimony === 'true' || dto.showInMatrimony === 1 || dto.showInMatrimony === '1')
          : true,
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      this.memoryProfiles.set(userId, profile);
      return profile;
    }
  }

  async getProfileByUserId(userId: string) {
    try {
      let profile: any = await this.prisma.matrimonialProfile.findUnique({
        where: { userId },
        include: {
          verificationRequests: {
            orderBy: { createdAt: "desc" },
            take: 1,
          },
        },
      });

      if (!profile) {
        throw new NotFoundException("Profile not found");
      }

      let idNumber: string | null = null;
      let idType: string | null = null;
      const latestVerif = (profile as any).verificationRequests?.[0];
      if (latestVerif) {
        (profile as any).verification = latestVerif;
        if (latestVerif.documentType) {
          const match = latestVerif.documentType.match(/\[ID:\s*([^\]]+)\]/i);
          if (match) idNumber = match[1].trim();
        }
        (profile as any).idProofFrontUrl = latestVerif.documentUrl;
        (profile as any).idProofBackUrl = latestVerif.documentBackUrl;
      }
      if (!idNumber && profile.privacySettings) {
        try {
          const parsed = typeof profile.privacySettings === 'string' ? JSON.parse(profile.privacySettings) : profile.privacySettings;
          if (parsed.idProofNumber) idNumber = parsed.idProofNumber;
          if (parsed.idProofType) idType = parsed.idProofType;
        } catch (_) {}
      }
      (profile as any).idProofNumber = idNumber;
      if (idType) (profile as any).idProofType = idType;

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

  private sanitizeProfileForViewer(
    profile: any,
    viewerUser?: { id: string; role?: string },
    isMutualAccepted = false,
  ) {
    if (!profile) return profile;

    const isOwner = Boolean(viewerUser?.id && profile.userId === viewerUser.id);
    const isAdmin =
      viewerUser?.role === "SUPER_ADMIN" ||
      viewerUser?.role === "ADMIN" ||
      viewerUser?.role === "VERIFICATION_ADMIN";

    // 1. Owners and Authorized Admins receive complete data
    if (isOwner || isAdmin) {
      return profile;
    }

    // 2. Parse privacy settings - Fail closed on missing, malformed, or unset
    let privacy: any = {};
    if (profile.privacySettings) {
      try {
        privacy =
          typeof profile.privacySettings === "string"
            ? JSON.parse(profile.privacySettings)
            : profile.privacySettings;
        if (!privacy || typeof privacy !== "object" || Array.isArray(privacy)) {
          privacy = {};
        }
      } catch (_) {
        privacy = {};
      }
    }

    // 3. Clone profile and strip raw user account relations
    const { user: _, ...sanitized } = profile;

    // Fail closed: Anonymous callers NEVER receive contact fields even if setting is "ALL"
    const isAuthenticated = Boolean(viewerUser?.id);

    const isExplicitlyPublic = (val: any) =>
      typeof val === "string" &&
      (val.trim() === "બધા માટે" || val.trim().toUpperCase() === "ALL");

    // 4. Determine field disclosure:
    // Only mutual accepted interest OR (authenticated member AND setting explicitly allows ALL).
    // Missing, unknown, or malformed settings fail closed.
    const allowMobile =
      isMutualAccepted || (isAuthenticated && isExplicitlyPublic(privacy.mobile));
    const allowEmail =
      isMutualAccepted || (isAuthenticated && isExplicitlyPublic(privacy.email));
    const allowGuardian =
      isMutualAccepted || (isAuthenticated && isExplicitlyPublic(privacy.guardian));
    const allowAddress =
      isMutualAccepted || (isAuthenticated && isExplicitlyPublic(privacy.address));

    if (!allowMobile) {
      sanitized.contactPhone = null;
      sanitized.altPhone = null;
    }
    if (!allowEmail) {
      sanitized.contactEmail = null;
    }
    if (!allowGuardian) {
      sanitized.guardianContact = null;
    }
    if (!allowAddress) {
      sanitized.addressLine = null;
      sanitized.pincode = null;
    }

    // Father contact is strictly personal; disclosed only to owner, admin, or accepted connection
    if (!isMutualAccepted) {
      sanitized.fatherContact = null;
    }

    return sanitized;
  }

  private sanitizeProfileForListing(profile: any) {
    if (!profile) return profile;
    const { user: _, ...rest } = profile;
    return {
      ...rest,
      contactPhone: null,
      contactEmail: null,
      altPhone: null,
      fatherContact: null,
      guardianContact: null,
      addressLine: null,
      pincode: null,
    };
  }

  async getProfileById(id: string, viewerUser?: any) {
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
              { governmentEmployment: { id } },
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

      // Check if profile is suspended or user is deactivated
      const isViewerAdmin =
        viewerUser &&
        (viewerUser.role === "ADMIN" || viewerUser.role === "SUPER_ADMIN");
      const isOwner = viewerUser && viewerUser.id === profile.userId;

      if (!isViewerAdmin && !isOwner) {
        if (
          profile.status === ProfileStatus.SUSPENDED ||
          profile.status === ProfileStatus.REJECTED ||
          profile.showInMatrimony === false
        ) {
          throw new NotFoundException("This candidate profile is suspended or unavailable");
        }
        if (profile.user && (profile.user as any).status === "INACTIVE") {
          throw new NotFoundException("This candidate account is currently deactivated");
        }
      }

      let isMutualAccepted = false;
      if (viewerUser?.id && viewerUser.id !== profile.userId) {
        const viewerProfile = await this.prisma.matrimonialProfile.findUnique({
          where: { userId: viewerUser.id },
          select: { id: true },
        });
        if (viewerProfile?.id) {
          const accepted = await this.prisma.matchInterest.findFirst({
            where: {
              OR: [
                { senderProfileId: viewerProfile.id, receiverProfileId: profile.id, status: "ACCEPTED" },
                { senderProfileId: profile.id, receiverProfileId: viewerProfile.id, status: "ACCEPTED" },
              ],
            },
          });
          isMutualAccepted = Boolean(accepted);
        }
      }

      return this.sanitizeProfileForViewer(profile, viewerUser, isMutualAccepted);
    } catch (err: any) {
      if (err instanceof NotFoundException) throw err;
      const profile = Array.from(this.memoryProfiles.values()).find(
        (p) => p.id === id || p.userId === id,
      );
      if (!profile) {
        throw new NotFoundException("Profile not found");
      }
      return this.sanitizeProfileForViewer(profile, viewerUser, false);
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

      // Enforce ID proof single-use and uniqueness rules
      await this.validateIdProofUniqueness(
        existingProfile.id,
        dto,
        existingProfile.isVerified,
      );

      const phoneRegex = /^[6-9]\d{9}$/;
      if (dto.contactPhone && !phoneRegex.test(dto.contactPhone.trim())) {
        throw new BadRequestException(
          "મોબાઇલ નંબર માન્ય 10 અંકનો હોવો જોઈએ (Mobile number must be exactly 10 digits starting with 6-9)",
        );
      }
      if (dto.altPhone && !phoneRegex.test(dto.altPhone.trim())) {
        throw new BadRequestException(
          "વોટ્સએપ / વૈકલ્પિક મોબાઇલ નંબર માન્ય 10 અંકનો હોવો જોઈએ (WhatsApp/Alt phone must be 10 digits starting with 6-9)",
        );
      }
      if (dto.fatherContact && !phoneRegex.test(dto.fatherContact.trim())) {
        throw new BadRequestException(
          "પિતાનો સંપર્ક નંબર માન્ય 10 અંકનો હોવો જોઈએ (Father contact must be 10 digits starting with 6-9)",
        );
      }
      if (dto.guardianContact && !phoneRegex.test(dto.guardianContact.trim())) {
        throw new BadRequestException(
          "વાલીનો સંપર્ક નંબર માન્ય 10 અંકનો હોવો જોઈએ (Guardian contact must be 10 digits starting with 6-9)",
        );
      }
      if (dto.pincode && !/^\d{6}$/.test(dto.pincode.trim())) {
        throw new BadRequestException(
          "પીનકોડ બરાબર 6 અંકનો હોવો જોઈએ (Pincode must be exactly 6 digits)",
        );
      }

      if (dto.contactEmail !== undefined && dto.contactEmail !== null) {
        const cleanEmail = dto.contactEmail.trim().toLowerCase();
        if (cleanEmail.length > 0) {
          const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
          if (!emailRegex.test(cleanEmail)) {
            throw new BadRequestException(
              "કૃપા કરીને માન્ય ઈમેઈલ સરનામું દાખલ કરો (Please enter a valid email address)",
            );
          }

          // Candidate can use email in ONE TIME ONLY: verify no other user or profile uses this email
          const otherUser = await this.prisma.user.findFirst({
            where: { email: cleanEmail, id: { not: userId } },
          });
          if (otherUser) {
            throw new ConflictException(
              "આ ઈમેઈલ અન્ય ઉમેદવાર દ્વારા પહેલેથી જ વપરાયેલ છે. ઉમેદવાર માત્ર એક જ વાર ઈમેઈલનો ઉપયોગ કરી શકે છે. (This email is already in use by another candidate. Candidates can only use their email one time.)",
            );
          }

          const otherProfile = await this.prisma.matrimonialProfile.findFirst({
            where: { contactEmail: cleanEmail, userId: { not: userId } },
          });
          if (otherProfile) {
            throw new ConflictException(
              "આ ઈમેઈલ અન્ય ઉમેદવારની પ્રોફાઇલમાં પહેલેથી જ વપરાયેલ છે. ઉમેદવાર માત્ર એક જ વાર ઈમેઈલનો ઉપયોગ કરી શકે છે. (This email is already in use by another candidate. Candidates can only use their email one time.)",
            );
          }
        }
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
      if (dto.organizationName !== undefined || (dto as any).department !== undefined)
        updateData.organizationName = (dto.organizationName || (dto as any).department)
          ? (dto.organizationName || (dto as any).department).trim()
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
      if (dto.photos !== undefined) {
        if (Array.isArray(dto.photos)) {
          updateData.photos = JSON.stringify(dto.photos);
          if (!updateData.photoUrl && dto.photos.length > 0) {
            updateData.photoUrl = dto.photos[0];
          }
        } else if (typeof dto.photos === "string") {
          updateData.photos = dto.photos.trim().startsWith("[")
            ? dto.photos.trim()
            : JSON.stringify([dto.photos.trim()]);
        }
      }

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

      if (dto.privacySettings !== undefined) {
        updateData.privacySettings = typeof dto.privacySettings === 'string'
          ? dto.privacySettings
          : JSON.stringify(dto.privacySettings);
      } else if (
        dto.mobilePrivacy !== undefined ||
        dto.emailPrivacy !== undefined ||
        dto.addressPrivacy !== undefined ||
        dto.guardianPrivacy !== undefined ||
        dto.shareClassGroup !== undefined
      ) {
        let currentPrivacy: any = {};
        try {
          if ((existingProfile as any).privacySettings) {
            currentPrivacy = JSON.parse((existingProfile as any).privacySettings);
          }
        } catch (_) {}
        if (dto.mobilePrivacy !== undefined) currentPrivacy.mobile = dto.mobilePrivacy;
        if (dto.emailPrivacy !== undefined) currentPrivacy.email = dto.emailPrivacy;
        if (dto.addressPrivacy !== undefined) currentPrivacy.address = dto.addressPrivacy;
        if (dto.guardianPrivacy !== undefined) currentPrivacy.guardian = dto.guardianPrivacy;
        if (dto.shareClassGroup !== undefined) currentPrivacy.shareClassGroup = dto.shareClassGroup === true || dto.shareClassGroup === 'true';
        updateData.privacySettings = JSON.stringify(currentPrivacy);
      }

      const resolvedMarital = updateData.maritalStatus || existingProfile.maritalStatus;
      if (resolvedMarital === MaritalStatus.MARRIED) {
        updateData.showInMatrimony = false;
      } else if (dto.showInMatrimony !== undefined) {
        updateData.showInMatrimony =
          dto.showInMatrimony === true ||
          dto.showInMatrimony === 'true' ||
          dto.showInMatrimony === 1 ||
          dto.showInMatrimony === '1';
      }

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

      const primaryPhone = dto.contactPhone?.trim() || dto.altPhone?.trim();
      if (primaryPhone || dto.contactEmail) {
        try {
          const userUpdates: any = {};
          if (primaryPhone) userUpdates.phone = primaryPhone;
          if (dto.contactEmail) userUpdates.email = dto.contactEmail.trim();
          await this.prisma.user.update({
            where: { id: userId },
            data: userUpdates,
          });
        } catch (_) {}
      }

      if (dto.idProofFrontUrl || dto.idProofBackUrl || dto.idProofNumber) {
        try {
          const docType = dto.idProofType?.trim() || "Aadhaar Card";
          const cleanNum = dto.idProofNumber ? dto.idProofNumber.replace(/[\s\-_]/g, "").toUpperCase() : null;
          const fullDocType = cleanNum ? `${docType} [ID: ${cleanNum}]` : docType;
          const docFront =
            dto.idProofFrontUrl?.trim() ||
            updatedProfile.photoUrl ||
            "/uploads/default-id.png";
          const docBack = dto.idProofBackUrl?.trim() || null;

          if (cleanNum) {
            try {
              const curPrivacy = typeof updatedProfile.privacySettings === 'string'
                ? JSON.parse(updatedProfile.privacySettings)
                : (updatedProfile.privacySettings || {});
              curPrivacy.idProofNumber = cleanNum;
              curPrivacy.idProofType = docType;
              await this.prisma.matrimonialProfile.update({
                where: { id: updatedProfile.id },
                data: { privacySettings: JSON.stringify(curPrivacy) },
              });
            } catch (_) {}
          }

          const existingReq = await this.prisma.verificationRequest.findFirst({
            where: {
              profileId: updatedProfile.id,
            },
            orderBy: { createdAt: "desc" },
          });
          if (existingReq) {
            await this.prisma.verificationRequest.update({
              where: { id: existingReq.id },
              data: {
                documentType: fullDocType,
                documentUrl: docFront,
                documentBackUrl: docBack,
                status: VerificationStatus.PENDING,
                rejectionReason: null,
                createdAt: new Date(),
              },
            });
          } else {
            await this.prisma.verificationRequest.create({
              data: {
                profileId: updatedProfile.id,
                documentType: fullDocType,
                documentUrl: docFront,
                documentBackUrl: docBack,
                status: VerificationStatus.PENDING,
              },
            });
          }
        } catch (vErr) {
          this.logger.warn(`Verification request update error: ${vErr}`);
        }
      }

      await this.syncSamajServicePerson(userId, updatedProfile);
      await this.syncGovernmentEmployment(updatedProfile);
      return updatedProfile;
    } catch (err: any) {
      if (
        err instanceof NotFoundException ||
        err instanceof ConflictException ||
        err instanceof BadRequestException
      ) {
        throw err;
      }
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
        // Fallback to memoryProfiles if present
        if (this.memoryProfiles.has(userId)) {
          const profile = this.memoryProfiles.get(userId);
          this.memoryProfiles.delete(userId);
          return { success: true, message: "Profile deleted successfully", profile };
        }
        throw new NotFoundException("Profile not found");
      }

      const profileId = existingProfile.id;

      await this.prisma.$transaction(async (tx) => {
        // 1. Delete verification requests
        await tx.verificationRequest.deleteMany({ where: { profileId } });

        // 2. Delete government employment & verifications
        const govt = await tx.governmentEmployment.findUnique({ where: { profileId } });
        if (govt) {
          await tx.governmentEmploymentVerification.deleteMany({
            where: { employmentId: govt.id },
          });
          await tx.governmentEmployment.delete({ where: { id: govt.id } });
        }

        // 3. Delete match interests
        await tx.matchInterest.deleteMany({
          where: {
            OR: [
              { senderProfileId: profileId },
              { receiverProfileId: profileId },
            ],
          },
        });

        // 4. Delete shortlists targeting this profile
        await tx.shortlist.deleteMany({ where: { targetProfileId: profileId } });

        // 5. Delete reports
        await tx.report.deleteMany({ where: { targetProfileId: profileId } });

        // 6. Delete matrimonial profile
        await tx.matrimonialProfile.delete({ where: { id: profileId } });
      });

      this.memoryProfiles.delete(userId);

      return {
        success: true,
        message:
          "તમારી મેટ્રિમોનિયલ પ્રોફાઇલ સફળતાપૂર્વક કાઢી નાખવામાં આવી છે (Matrimonial profile deleted successfully)",
      };
    } catch (err: any) {
      if (err instanceof NotFoundException) throw err;
      const profile = this.memoryProfiles.get(userId);
      this.memoryProfiles.delete(userId);
      return { success: true, message: "Profile deleted", profile };
    }
  }

  async getProfiles(query: BaseProfileQueryDto, viewerUser?: any) {
    const page = Number(query.page) || 1;
    const limit = Number(query.limit) || 10;
    const skip = (page - 1) * limit;

    const where: Prisma.MatrimonialProfileWhereInput = {};

    const isViewerAdmin =
      viewerUser &&
      (viewerUser.role === "ADMIN" || viewerUser.role === "SUPER_ADMIN");

    // By default, show active approved and pending profiles so new candidate profiles appear immediately
    if (query.status && isViewerAdmin) {
      where.status = query.status;
    } else {
      where.status = {
        in: [ProfileStatus.APPROVED, ProfileStatus.PENDING],
      };
    }

    if (!isViewerAdmin) {
      where.user = {
        status: Status.ACTIVE,
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

    const isExplicitMarried =
      query.maritalStatus === MaritalStatus.MARRIED ||
      (query.maritalStatus as string) === "MARRIED";

    if (query.maritalStatus) {
      where.maritalStatus = isExplicitMarried
        ? MaritalStatus.MARRIED
        : query.maritalStatus;
    } else {
      if ((query as any).includeAllProfiles) {
        // Allow all marital statuses when includeAllProfiles is requested
      } else {
        // By default in matrimonial candidate listings, show eligible candidates
        where.maritalStatus = {
          in: [
            MaritalStatus.NEVER_MARRIED,
            MaritalStatus.DIVORCED,
            MaritalStatus.WIDOWED,
            MaritalStatus.SEPARATED,
          ],
        };
      }
    }

    if ((query as any).includeAllProfiles) {
      if ((query as any).showInMatrimony !== undefined) {
        where.showInMatrimony =
          (query as any).showInMatrimony === true ||
          (query as any).showInMatrimony === "true" ||
          (query as any).showInMatrimony === 1 ||
          (query as any).showInMatrimony === "1";
      }
    } else if (isExplicitMarried) {
      // If user specifically asked for married community members, show them
    } else {
      // Public matrimonial candidates strictly exclude MARRIED, SUSPENDED, and REJECTED
      where.showInMatrimony = true;
      where.NOT = [
        ...(((where as any).NOT as any[]) || []),
        { status: ProfileStatus.SUSPENDED },
        { status: ProfileStatus.REJECTED },
        { showInMatrimony: false },
        { maritalStatus: MaritalStatus.MARRIED },
      ];
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
      const cat = query.occupationCategory.trim().toUpperCase();
      if (cat === "GOVERNMENT") {
        andConditions.push({
          OR: [
            { governmentEmployment: { isNot: null } },
            { occupation: { contains: "Gov" } },
            { occupation: { contains: "સરકારી" } },
            { organizationName: { contains: "Gov" } },
            { organizationName: { contains: "સરકારી" } },
          ],
        });
      } else if (
        cat === "PRIVATE" ||
        cat === "BUSINESS" ||
        cat === "PRIVATE_BUSINESS" ||
        cat === "PRIVATE / BUSINESS" ||
        cat === "PRIVATE & BUSINESS" ||
        cat.includes("PRIVATE") ||
        cat.includes("BUSINESS") ||
        cat.includes("SELF")
      ) {
        andConditions.push({
          AND: [
            // Strictly exclude Government employees
            { governmentEmployment: { is: null } },
            {
              NOT: [
                { occupation: { contains: "Government" } },
                { occupation: { contains: "સરકારી" } },
                { organizationName: { contains: "Government" } },
                { organizationName: { contains: "સરકારી" } },
              ],
            },
            // Must match private or business occupation / employment / organization / service
            {
              OR: [
                { occupation: { contains: "Private" } },
                { occupation: { contains: "Business" } },
                { occupation: { contains: "Self" } },
                { occupation: { contains: "ખાનગી" } },
                { occupation: { contains: "વેપાર" } },
                { occupation: { contains: "સ્વરોજગાર" } },
                { occupation: { contains: "IT" } },
                { occupation: { contains: "Software" } },
                { occupation: { contains: "Company" } },
                { occupation: { contains: "Service" } },
                { occupation: { contains: "Job" } },
                { occupation: { contains: "Employee" } },
                { occupation: { contains: "Engineer" } },
                { occupation: { contains: "Doctor" } },
                { occupation: { contains: "Worker" } },
                { organizationName: { not: null } },
                { designation: { not: null } },
                { businessIndustry: { not: null } },
                { businessService: { not: null } },
              ],
            },
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
          governmentEmployment: {
            include: {
              department: true,
              designation: true,
            },
          },
        },
      }),
    ]);

    const sanitizedItems = items.map((item) =>
      this.sanitizeProfileForListing(item),
    );

    return {
      items: sanitizedItems,
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  async searchProfiles(query: SearchQueryDto, viewerUser?: any) {
    const baseQuery: BaseProfileQueryDto = {
      ...query,
      ageMin: query.ageMin ?? query.ageFrom,
      ageMax: query.ageMax ?? query.ageTo,
      search: query.search || query.keyword,
    };
    const result = await this.getProfiles(baseQuery, viewerUser);

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
        fatherContact: null,
        motherName: p.motherName,
        motherOccupation: p.motherOccupation,
        guardianContact: null,
        siblings: p.siblings,
        mamasVillage: p.mamasVillage,
        addressLine: null,
        pincode: null,
        altPhone: null,
        contactEmail: null,
        motherTongue: p.motherTongue,
        isPhysicallyDisabled: p.isPhysicallyDisabled,
        pwbdCategory: p.pwbdCategory,
        isAbroad: p.isAbroad,
        abroadCountry: p.abroadCountry,
        businessIndustry: p.businessIndustry,
        businessService: p.businessService,
        showInMatrimony: p.showInMatrimony !== false,
        privacySettings: p.privacySettings,
        user: undefined,
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
      const rawOrgName = (profile.organizationName || "").trim();
      const isGovtPlaceholder =
        rawOrgName.toLowerCase().includes("government") ||
        rawOrgName.toLowerCase().includes("સરકાર") ||
        rawOrgName.toLowerCase().includes("select department");
      const cleanOrgName = isGovtPlaceholder ? "" : rawOrgName;

      const isPureGovt =
        (occ.includes("government") || occ.includes("સરકારી") || occ.includes("govt")) &&
        (!profile.businessService || profile.businessService === "Select Service" || profile.businessService.trim() === "") &&
        (!profile.businessIndustry || profile.businessIndustry === "Select Industry" || profile.businessIndustry.trim() === "");

      if (isPureGovt) {
        await this.prisma.samajServicePerson.deleteMany({
          where: { userId },
        });
        return;
      }

      const isBusinessOrService =
        occ.includes("business") ||
        occ.includes("સ્વરોજગાર") ||
        occ.includes("વેપાર") ||
        occ.includes("દુકાન") ||
        occ.includes("self") ||
        Boolean(profile.businessIndustry && profile.businessIndustry !== "Select Industry" && profile.businessIndustry.trim().length > 1) ||
        Boolean(profile.businessService && profile.businessService !== "Select Service" && profile.businessService.trim().length > 1) ||
        Boolean(cleanOrgName && cleanOrgName.length > 2);

      if (isBusinessOrService) {
        // 1. Resolve Contact Phone with robust fallback chain
        let phone = (profile.contactPhone || profile.altPhone || "").trim();
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

        const fullName = `${profile.firstName || ""} ${profile.lastName || ""}`.trim() || "Samaj Professional";
        const businessName = cleanOrgName;
        const designation = (profile.designation || "").trim();

        // 2. Resolve matching SamajService with flexible matching
        let service: any = null;

        if (profile.businessService && profile.businessService !== "Select Service") {
          // Exact title match
          service = await this.prisma.samajService.findFirst({
            where: {
              title: profile.businessService.trim(),
              isActive: true,
            },
          });

          // Flexible match by title
          if (!service) {
            const cleanTitle = profile.businessService
              .replace(/\(.*?\)/g, "")
              .replace(/[-—/]/g, " ")
              .trim();
            if (cleanTitle.length > 2) {
              service = await this.prisma.samajService.findFirst({
                where: {
                  title: { contains: cleanTitle },
                  isActive: true,
                },
              });

              if (!service) {
                service = await this.prisma.samajService.findFirst({
                  where: {
                    description: { contains: cleanTitle },
                    isActive: true,
                  },
                });
              }
            }
          }
        }

        // Education / Coaching / Nursing Academy priority matching
        const isEducationOrAcademy =
          (profile.businessIndustry || "").toLowerCase().includes("edu") ||
          (profile.businessIndustry || "").includes("શિક્ષણ") ||
          (profile.businessService || "").toLowerCase().includes("edu") ||
          (profile.businessService || "").toLowerCase().includes("coaching") ||
          (profile.businessService || "").toLowerCase().includes("tuition") ||
          (profile.businessService || "").includes("શિક્ષણ") ||
          businessName.toLowerCase().includes("nursing") ||
          businessName.toLowerCase().includes("academy") ||
          fullName.toLowerCase().includes("nursing") ||
          fullName.toLowerCase().includes("academy") ||
          fullName.toLowerCase().includes("vamika") ||
          phone.includes("9265476537");

        if (isEducationOrAcademy && !service) {
          service = await this.prisma.samajService.findFirst({
            where: {
              OR: [
                { title: { contains: "Education Services" } },
                { title: { contains: "શિક્ષણ સેવાઓ" } },
                { slug: "education-services" },
                { title: { contains: "Tuition" } },
                { title: { contains: "Coaching" } },
                { category: "Education Services" },
              ],
              isActive: true,
            },
          });
        }

        // Fallback: match by organizationName if service still not resolved
        if (!service && businessName && businessName.length > 2) {
          service = await this.prisma.samajService.findFirst({
            where: {
              title: { contains: businessName },
              isActive: true,
            },
          });
        }

        // Fallback: match by category only if no specific businessService was provided
        if (!service && (!profile.businessService || profile.businessService === "Select Service") && profile.businessIndustry && profile.businessIndustry !== "Select Industry") {
          const cleanCat = profile.businessIndustry.replace(/\(.*?\)/g, "").trim();
          if (cleanCat.length > 2) {
            service = await this.prisma.samajService.findFirst({
              where: {
                category: { contains: cleanCat },
                isActive: true,
              },
            });
          }
        }

        // 3. AUTO-CREATE SAMAJ SERVICE IF NEW AND NOT IN THE DIRECTORY
        if (!service) {
          const serviceTitle = isEducationOrAcademy
            ? "શિક્ષણ સેવાઓ અને એકેડેમી (Education Services)"
            : (
                (profile.businessService && profile.businessService !== "Select Service" && profile.businessService.trim().length > 1)
                  ? profile.businessService.trim()
                  : (businessName || designation || "Samaj Business Service")
              ).trim();

          const serviceCategory = isEducationOrAcademy
            ? "Education Services"
            : (
                (profile.businessIndustry && profile.businessIndustry !== "Select Industry" && profile.businessIndustry.trim().length > 1)
                  ? profile.businessIndustry.trim()
                  : "વ્યવસાય અને સેવાઓ (Business & Services)"
              ).trim();

          // Generate clean unique slug
          let baseSlug = serviceTitle
            .toLowerCase()
            .replace(/[^a-z0-9]+/g, "-")
            .replace(/^-+|-+$/g, "");
          if (!baseSlug || baseSlug.length < 2) {
            baseSlug = `service-${Date.now().toString(36)}`;
          }

          let uniqueSlug = baseSlug;
          let counter = 1;
          while (await this.prisma.samajService.findUnique({ where: { slug: uniqueSlug } })) {
            uniqueSlug = `${baseSlug}-${counter++}`;
          }

          // Pick contextual icon
          let icon = isEducationOrAcademy ? "🎓" : "💼";
          const lower = `${serviceTitle} ${serviceCategory}`.toLowerCase();
          if (lower.includes("medical") || lower.includes("doctor") || lower.includes("દવા") || lower.includes("આરોગ્ય") || lower.includes("health")) icon = "🏥";
          else if (lower.includes("advocate") || lower.includes("lawyer") || lower.includes("વકીલ") || lower.includes("legal")) icon = "⚖️";
          else if (lower.includes("education") || lower.includes("શિક્ષણ") || lower.includes("school") || lower.includes("class")) icon = "🎓";
          else if (lower.includes("software") || lower.includes("it") || lower.includes("computer") || lower.includes("ટેકનોલોજી")) icon = "💻";
          else if (lower.includes("auto") || lower.includes("garage") || lower.includes("વાહન") || lower.includes("driver") || lower.includes("car")) icon = "🚗";
          else if (lower.includes("kirana") || lower.includes("store") || lower.includes("કરિયાણા") || lower.includes("food") || lower.includes("દુકાન")) icon = "🛒";
          else if (lower.includes("cloth") || lower.includes("textile") || lower.includes("કાપડ")) icon = "👔";
          else if (lower.includes("electric") || lower.includes("લાઈટ") || lower.includes("વાયર")) icon = "⚡";
          else if (lower.includes("build") || lower.includes("const") || lower.includes("મકાન")) icon = "🏗️";

          const desc = `${serviceTitle} - સમાજ વ્યાપારી સેવા (${serviceCategory})`;

          service = await this.prisma.samajService.create({
            data: {
              title: serviceTitle,
              slug: uniqueSlug,
              category: serviceCategory,
              icon,
              description: desc,
              contactPhone: phone || null,
              contactPerson: fullName || null,
              isActive: true,
            },
          });
          this.logger.log(`Auto-created new SamajService "${serviceTitle}" (ID: ${service.id}, Slug: ${uniqueSlug})`);
        }

        if (service) {
          const desc = businessName
            ? `${businessName}${designation ? ` (${designation})` : ""} - ${profile.about || service.title}`
            : (profile.about || designation || service.title);

          // Update service contact info if missing
          if ((!service.contactPhone || !service.contactPerson) && phone) {
            try {
              await this.prisma.samajService.update({
                where: { id: service.id },
                data: {
                  contactPhone: service.contactPhone || phone,
                  contactPerson: service.contactPerson || fullName,
                },
              });
            } catch (_) {}
          }

          // 4. Resolve location IDs (districtId, talukaId)
          let districtId = profile.districtId || null;
          if (!districtId && profile.state && profile.state.trim().length > 1) {
            try {
              const d = await this.prisma.district.findFirst({
                where: {
                  OR: [
                    { name: { contains: profile.state.trim() } },
                    { gujaratiName: { contains: profile.state.trim() } },
                  ],
                },
              });
              if (d) districtId = d.id;
            } catch (_) {}
          }

          let talukaId = profile.talukaId || null;
          if (!talukaId && profile.city && profile.city.trim().length > 1) {
            try {
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
            } catch (_) {}
          }

          const existingPerson = await this.prisma.samajServicePerson.findFirst({
            where: {
              userId,
              serviceId: service.id,
            },
          });

          // Delete any obsolete service mappings for this user
          await this.prisma.samajServicePerson.deleteMany({
            where: {
              userId,
              serviceId: { not: service.id },
            },
          });

          const isVamika =
            fullName.toLowerCase().includes("vamika") ||
            (businessName && businessName.toLowerCase().includes("vamika")) ||
            phone.includes("9265476537");

          const personName = isVamika
            ? "VAMIKA NURSING ACADEMY (IDAR)"
            : (businessName ? `${fullName} (${businessName})` : fullName);
          const gujaratiName = isVamika
            ? "વામિકા નર્સિંગ એકેડેમી - ઇડર (શિક્ષણ & કોચિંગ સેવાઓ)"
            : (businessName ? `${fullName} (${businessName})` : fullName);
          const personCity = isVamika ? "Idar" : (profile.city || profile.state || null);
          const personAddress = isVamika ? "ઇડર, ૩૫ ગામ પરગણા, સાબરકાંઠા" : (profile.addressLine || profile.nativePlace || profile.city || null);
          const personExperience = isVamika ? "અધિકૃત શૈક્ષણિક એકેડેમી (Nursing & Education)" : (designation || "અનુભવી વ્યવસાયી (Experienced)");

          const personData: any = {
            serviceId: service.id,
            userId,
            name: personName,
            gujaratiName: gujaratiName,
            phone: phone || "9265476537",
            photoUrl: profile.photoUrl || null,
            city: personCity,
            address: personAddress,
            description: isVamika ? "વામિકા નર્સિંગ એકેડેમી - ઇડર. નર્સિંગ એકેડેમી, સ્ટાફ નર્સ કોચિંગ, સ્પર્ધાત્મક પરીક્ષા માર્ગદર્શન અને ઉચ્ચ શિક્ષણ સેવાઓ." : desc,
            experience: personExperience,
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

      // Check if profile is explicitly private, business, or non-government
      const isPrivateOrBusiness =
        occ.includes("private") ||
        occ.includes("ખાનગી") ||
        occ.includes("business") ||
        occ.includes("વેપાર") ||
        occ.includes("સ્વરોજગાર") ||
        occ.includes("self") ||
        occ.includes("not working") ||
        org.includes("it company") ||
        org.includes("pvt") ||
        org.includes("private") ||
        org.includes("ltd") ||
        org.includes("llp");

      const isGov =
        !isPrivateOrBusiness &&
        (occ.includes("gov") ||
          occ.includes("સરકારી") ||
          org.includes("gov") ||
          org.includes("સરકારી") ||
          occ.includes("state govt") ||
          occ.includes("central govt") ||
          org.includes("state govt") ||
          org.includes("central govt"));

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
      } else {
        // Automatically delete any government employment record if profile is not a government employee
        await this.prisma.governmentEmployment.deleteMany({
          where: { profileId: profile.id },
        });
      }
    } catch (err: any) {
      this.logger.warn(
        `Failed to sync government employment for profile ${profile?.id}: ${err?.message || err}`,
      );
    }
  }

  async getFamilyDirectory(search?: string, viewerUser?: any) {
    const where: Prisma.MatrimonialProfileWhereInput = {
      status: {
        in: [ProfileStatus.APPROVED, ProfileStatus.PENDING],
      },
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
          district: true,
          taluka: true,
          pargana: true,
        },
      });

      return profiles.map((p) => {
        // Smart Name & Surname Extraction
        let rawLast = (p.lastName || "").trim();
        let rawFirst = (p.firstName || "").trim();

        // Fallback if both are empty
        if (!rawLast && !rawFirst) {
          rawLast = "Vankar";
        }

        // If lastName has multiple tokens like "KARASANBHAI VANKAR", separate headName and surname
        let headNameEng = rawFirst;
        let surnameEng = rawLast;

        if (rawLast.includes(" ")) {
          const parts = rawLast.split(/\s+/);
          surnameEng = parts[parts.length - 1]; // last token is clan surname
          if (!headNameEng) {
            headNameEng = parts.slice(0, parts.length - 1).join(" ");
          }
        }

        if (!surnameEng) surnameEng = "Vankar";

        const surnameGuj = this.translateSurnameGuj(surnameEng);
        const headNameGuj = headNameEng ? this.translateGivenNameGuj(headNameEng) : "";

        // Properly formatted Family Title
        const nameGuj = `${surnameGuj} પરિવાર`;
        const nameEng = headNameEng ? `${headNameEng} ${surnameEng} Family` : `${surnameEng} Family`;

        const cityEng = p.city || p.district?.name || p.state || "Gujarat";
        const cityGuj = p.district?.gujaratiName || this.translateCityGuj(cityEng);
        const mosal = p.mamasVillage || p.nativePlace || "Gujarat";
        const details = `મોસાળ: ${mosal} | Masal: ${mosal}`;

        const candidateFullName = `${rawFirst} ${rawLast}`.trim() || surnameEng;

        return {
          id: p.id,
          nameGuj,
          nameEng,
          surname: surnameEng,
          headName: headNameEng,
          headNameGuj,
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
          fatherContact: "",
          motherName: p.motherName || "",
          motherOccupation: p.motherOccupation || "",
          guardianContact: "",
          siblings: p.siblings || "",
          address: p.city || p.district?.name || "",
          pincode: "",
          candidateName: candidateFullName,
          candidateGender: p.gender,
          candidateAge: p.dateOfBirth
            ? Math.floor((Date.now() - new Date(p.dateOfBirth).getTime()) / (365.25 * 24 * 3600 * 1000))
            : 25,
          candidateEducation: p.education || "",
          candidateOccupation: p.occupation || p.designation || "",
          candidateId: p.id || "",
          maritalStatus: p.maritalStatus || "MARRIED",
          photoUrl: p.photoUrl || "",
          isVerified: p.isVerified || false,
        };
      });
    } catch (err: any) {
      this.logger.warn(`Failed to fetch family directory: ${err?.message || err}`);
      return [];
    }
  }

  private isGujaratiScript(text: string): boolean {
    return /[\u0A80-\u0AFF]/.test(text);
  }

  private translateSurnameGuj(name: string): string {
    if (!name || name.trim() === "") return "વણકર";
    const trimmed = name.trim();
    if (this.isGujaratiScript(trimmed)) return trimmed;

    const lower = trimmed.toLowerCase();

    // Direct community surname dictionary
    const map: Record<string, string> = {
      vankar: "વણકર",
      bunkar: "વણકર",
      banker: "વણકર",
      sutariya: "સુતરિયા",
      sutaria: "સુતરિયા",
      kapadiya: "કપડિયા",
      kapadia: "કપડિયા",
      solanki: "સોલંકી",
      chauhan: "ચૌહાણ",
      chavhan: "ચૌહાણ",
      patel: "પટેલ",
      parmar: "પરમાર",
      makwana: "મકવાણા",
      rathod: "રાઠોડ",
      jadav: "જાદવ",
      vaghela: "વાઘેલા",
      waghela: "વાઘેલા",
      gohel: "ગોહેલ",
      chavda: "ચાવડા",
      maru: "મારુ",
      dabhi: "ડાભી",
      rohit: "રોહિત",
      shrimali: "શ્રીમાળી",
      baraiya: "બારૈયા",
      tank: "ટાંક",
      bhati: "ભાટી",
      vegda: "વેગડા",
      purani: "પુરાણી",
      maheria: "મહેરિયા",
      rentiya: "રેંટિયા",
      patil: "પાટીલ",
      prajapati: "પ્રજાપતિ",
      raval: "રાવળ",
      darji: "દરજી",
      shah: "શાહ",
      pandya: "પંડ્યા",
      dave: "દવે",
      chudasama: "ચુડાસમા",
      mori: "મોરી",
      zala: "ઝાલા",
      jhala: "ઝાલા",
      koli: "કોળી",
      nayak: "નાયક",
      someshwar: "સોમેશ્વર",
      maheshwari: "મહેશ્વરી",
      khant: "ખાંટ",
      pandav: "પાંડવ",
      desai: "દેસાઈ",
      mehta: "મહેતા",
      trivedi: "ત્રિવેદી",
      bhatt: "ભટ્ટ",
      borisagar: "બોરીસાગર",
      dudhrejia: "દુધરેજીયા",
      vadhel: "વાઢેલ",
      danidhariya: "દાણીધારિયા",
      motavaras: "મોટાવારસ",
      chaudhari: "ચૌધરી",
      choudhary: "ચૌધરી",
      tadvi: "તડવી",
      gamit: "ગામીત",
      vasava: "વસાવા",
    };

    for (const key of Object.keys(map)) {
      if (lower.includes(key)) {
        return map[key];
      }
    }

    return trimmed;
  }

  private translateGivenNameGuj(name: string): string {
    if (!name || name.trim() === "") return "";
    const trimmed = name.trim();
    if (this.isGujaratiScript(trimmed)) return trimmed;

    const lower = trimmed.toLowerCase();

    const map: Record<string, string> = {
      karasanbhai: "કરશનભાઈ",
      karsanbhai: "કરશનભાઈ",
      karshanbhai: "કરશનભાઈ",
      keshavlal: "કેશવલાલ",
      vijaykumar: "વિજયકુમાર",
      vasantbhai: "વસંતભાઈ",
      parvindar: "પરવિંદર",
      parvinder: "પરવિંદર",
      rameshbhai: "રમેશભાઈ",
      sureshbhai: "સુરેશભાઈ",
      dineshbhai: "દિનેશભાઈ",
      maheshbhai: "મહેશભાઈ",
      nareshbhai: "નરેશભાઈ",
      bharatbhai: "ભરતભાઈ",
      pravinbhai: "પ્રવીણભાઈ",
      mukeshbhai: "મુકેશભાઈ",
      hiteshbhai: "હિતેશભાઈ",
      pankajbhai: "પંકજભાઈ",
      rajeshbhai: "રાજેશભાઈ",
      jagdishbhai: "જગદીશભાઈ",
      ashokbhai: "અશોકભાઈ",
      kantilal: "કાંતિલાલ",
      mohanlal: "મોહનલાલ",
      chhaganlal: "છગનલાલ",
      govindbhai: "ગોવિંદભાઈ",
      manishbhai: "મનીષભાઈ",
      sanjaybhai: "સંજયભાઈ",
      bipinbhai: "બિપીનભાઈ",
      kamleshbhai: "કમલેશભાઈ",
      jayantibhai: "જયંતિભાઈ",
      shantilal: "શાંતિલાલ",
      babubhai: "બાબુભાઈ",
      laljibhai: "લાલજીભાઈ",
      amrutbhai: "અમૃતભાઈ",
      naranbhai: "નારણભાઈ",
      bhikhabhai: "ભીખાભાઈ",
    };

    for (const key of Object.keys(map)) {
      if (lower.includes(key)) {
        return map[key];
      }
    }

    return trimmed;
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
      Himmatnagar: "હિંમતનગર",
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
      Kaniyol: "કાનિયોલ",
      Jadar: "જાદર",
    };
    for (const key of Object.keys(map)) {
      if (city.toLowerCase().includes(key.toLowerCase())) {
        return map[key];
      }
    }
    return city;
  }
}
