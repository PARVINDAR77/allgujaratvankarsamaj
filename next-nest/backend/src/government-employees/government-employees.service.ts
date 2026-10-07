import {
  Injectable,
  Logger,
  NotFoundException,
  ConflictException,
  BadRequestException,
  ForbiddenException,
} from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";
import {
  CreateGovtEmploymentDto,
  UpdateGovtEmploymentDto,
  SubmitVerificationDto,
  GovtEmployeeSearchQueryDto,
  AdminVerifyGovtEmpDto,
  AdminFeatureGovtEmpDto,
  AdminStatusGovtEmpDto,
  CreateDepartmentDto,
  CreateDesignationDto,
} from "./dto/government-employees.dto";
import {
  GovtVerificationStatus,
  GovtEmploymentType,
  ProfileStatus,
} from "@prisma/client";

@Injectable()
export class GovernmentEmployeesService {
  private readonly logger = new Logger(GovernmentEmployeesService.name);

  constructor(private readonly prisma: PrismaService) {}

  // ==========================================
  // MASTER DATA: DEPARTMENTS & DESIGNATIONS
  // ==========================================

  private readonly initialDepartments = [
    {
      name: "Education Department",
      gujaratiName: "શિક્ષણ વિભાગ",
      code: "DEPT_EDU",
      designations: [
        {
          name: "Primary Teacher",
          gujaratiName: "પ્રાથમિક શિક્ષક",
          code: "DESIG_PRI_TEACHER",
        },
        {
          name: "High School Teacher",
          gujaratiName: "ઉચ્ચતર માધ્યમિક શિક્ષક",
          code: "DESIG_HS_TEACHER",
        },
        {
          name: "College Lecturer / Professor",
          gujaratiName: "અધ્યાપક / પ્રાધ્યાપક",
          code: "DESIG_PROFESSOR",
        },
        {
          name: "Principal / Headmaster",
          gujaratiName: "આચાર્ય",
          code: "DESIG_PRINCIPAL",
        },
      ],
    },
    {
      name: "Revenue Department",
      gujaratiName: "મહેસૂલ વિભાગ",
      code: "DEPT_REV",
      designations: [
        {
          name: "Talati Mantri",
          gujaratiName: "તલાટી મંત્રી",
          code: "DESIG_TALATI",
        },
        {
          name: "Revenue Inspector / Circle Officer",
          gujaratiName: "મહેસૂલ નાયબ નિરીક્ષક",
          code: "DESIG_REV_INSP",
        },
        {
          name: "Deputy Mamlatdar / Mamlatdar",
          gujaratiName: "મામલતદાર",
          code: "DESIG_MAMLATDAR",
        },
      ],
    },
    {
      name: "Police & Home Department",
      gujaratiName: "પોલીસ અને ગૃહ વિભાગ",
      code: "DEPT_POL",
      designations: [
        {
          name: "Police Constable",
          gujaratiName: "પોલીસ કોન્સ્ટેબલ",
          code: "DESIG_CONSTABLE",
        },
        {
          name: "Police Sub Inspector (PSI)",
          gujaratiName: "પી.એસ.આઈ.",
          code: "DESIG_PSI",
        },
        {
          name: "Police Inspector (PI)",
          gujaratiName: "પી.આઈ.",
          code: "DESIG_PI",
        },
        {
          name: "DySP / ACP",
          gujaratiName: "ડી.વાય.એસ.પી.",
          code: "DESIG_DYSP",
        },
      ],
    },
    {
      name: "Health & Family Welfare Department",
      gujaratiName: "આરોગ્ય અને પબ્લિક હેલ્થ વિભાગ",
      code: "DEPT_HEALTH",
      designations: [
        {
          name: "Staff Nurse / Nursing Superintendent",
          gujaratiName: "સ્ટાફ નર્સ",
          code: "DESIG_NURSE",
        },
        {
          name: "Medical Officer / Doctor",
          gujaratiName: "મેડિકલ ઓફિસર",
          code: "DESIG_MO",
        },
        {
          name: "Pharmacist",
          gujaratiName: "ફાર્માસિસ્ટ",
          code: "DESIG_PHARMA",
        },
      ],
    },
    {
      name: "Panchayat & Rural Development",
      gujaratiName: "પંચાયત અને ગ્રામ વિકાસ વિભાગ",
      code: "DEPT_PANCHAYAT",
      designations: [
        {
          name: "Gram Sevak",
          gujaratiName: "ગ્રામ સેવક",
          code: "DESIG_GRAM_SEVAK",
        },
        {
          name: "Extension Officer",
          gujaratiName: "વિસ્તરણ અધિકારી",
          code: "DESIG_EXT_OFFICER",
        },
        {
          name: "Taluka Development Officer (TDO)",
          gujaratiName: "તાલુકા વિકાસ અધિકારી",
          code: "DESIG_TDO",
        },
      ],
    },
  ];

  async getMasterDepartments() {
    try {
      const departments = await this.prisma.govtDepartment.findMany({
        where: { isActive: true },
        include: {
          designations: {
            where: { isActive: true },
            orderBy: { name: "asc" },
          },
        },
        orderBy: { name: "asc" },
      });

      if (departments.length === 0) {
        // Seed initial department records if empty
        for (const deptData of this.initialDepartments) {
          const dept = await this.prisma.govtDepartment.create({
            data: {
              name: deptData.name,
              gujaratiName: deptData.gujaratiName,
              code: deptData.code,
              isActive: true,
            },
          });
          for (const desigData of deptData.designations) {
            await this.prisma.govtDesignation.create({
              data: {
                departmentId: dept.id,
                name: desigData.name,
                gujaratiName: desigData.gujaratiName,
                code: desigData.code,
                isActive: true,
              },
            });
          }
        }
        return this.prisma.govtDepartment.findMany({
          where: { isActive: true },
          include: {
            designations: {
              where: { isActive: true },
              orderBy: { name: "asc" },
            },
          },
          orderBy: { name: "asc" },
        });
      }

      return departments;
    } catch (err: any) {
      this.logger.warn(
        "Prisma Master Departments query fallback:",
        err?.message,
      );
      return this.initialDepartments.map((d, idx) => ({
        id: `dept-${idx + 1}`,
        name: d.name,
        gujaratiName: d.gujaratiName,
        code: d.code,
        isActive: true,
        designations: d.designations.map((ds, desigIdx) => ({
          id: `desig-${idx + 1}-${desigIdx + 1}`,
          departmentId: `dept-${idx + 1}`,
          name: ds.name,
          gujaratiName: ds.gujaratiName,
          code: ds.code,
          isActive: true,
        })),
      }));
    }
  }

  // Admin Master Data CRUD
  async createDepartment(dto: CreateDepartmentDto, adminId: string) {
    const dept = await this.prisma.govtDepartment.create({ data: dto });
    await this.logAdminAudit(
      adminId,
      "CREATE_DEPARTMENT",
      "GovtDepartment",
      dept.id,
      null,
      JSON.stringify(dept),
    );
    return dept;
  }

  async updateDepartment(
    id: string,
    dto: Partial<CreateDepartmentDto>,
    adminId: string,
  ) {
    const oldVal = await this.prisma.govtDepartment.findUnique({
      where: { id },
    });
    const updated = await this.prisma.govtDepartment.update({
      where: { id },
      data: dto,
    });
    await this.logAdminAudit(
      adminId,
      "UPDATE_DEPARTMENT",
      "GovtDepartment",
      id,
      JSON.stringify(oldVal),
      JSON.stringify(updated),
    );
    return updated;
  }

  async softDeleteDepartment(id: string, adminId: string) {
    const oldVal = await this.prisma.govtDepartment.findUnique({
      where: { id },
    });
    const updated = await this.prisma.govtDepartment.update({
      where: { id },
      data: { isActive: false },
    });
    await this.logAdminAudit(
      adminId,
      "DEACTIVATE_DEPARTMENT",
      "GovtDepartment",
      id,
      JSON.stringify(oldVal),
      JSON.stringify(updated),
    );
    return updated;
  }

  async createDesignation(dto: CreateDesignationDto, adminId: string) {
    const desig = await this.prisma.govtDesignation.create({ data: dto });
    await this.logAdminAudit(
      adminId,
      "CREATE_DESIGNATION",
      "GovtDesignation",
      desig.id,
      null,
      JSON.stringify(desig),
    );
    return desig;
  }

  async updateDesignation(
    id: string,
    dto: Partial<CreateDesignationDto>,
    adminId: string,
  ) {
    const oldVal = await this.prisma.govtDesignation.findUnique({
      where: { id },
    });
    const updated = await this.prisma.govtDesignation.update({
      where: { id },
      data: dto,
    });
    await this.logAdminAudit(
      adminId,
      "UPDATE_DESIGNATION",
      "GovtDesignation",
      id,
      JSON.stringify(oldVal),
      JSON.stringify(updated),
    );
    return updated;
  }

  async softDeleteDesignation(id: string, adminId: string) {
    const oldVal = await this.prisma.govtDesignation.findUnique({
      where: { id },
    });
    const updated = await this.prisma.govtDesignation.update({
      where: { id },
      data: { isActive: false },
    });
    await this.logAdminAudit(
      adminId,
      "DEACTIVATE_DESIGNATION",
      "GovtDesignation",
      id,
      JSON.stringify(oldVal),
      JSON.stringify(updated),
    );
    return updated;
  }

  // ==========================================
  // MEMBER API: MY EMPLOYMENT RECORD (/me)
  // ==========================================

  async getMyEmployment(userId: string) {
    const profile = await this.prisma.matrimonialProfile.findUnique({
      where: { userId },
      include: {
        governmentEmployment: {
          include: {
            department: true,
            designation: true,
            verifications: { orderBy: { createdAt: "desc" }, take: 1 },
          },
        },
      },
    });

    if (!profile) {
      throw new NotFoundException("Matrimonial profile not found for user");
    }

    return profile.governmentEmployment || null;
  }

  async createMyEmployment(userId: string, dto: CreateGovtEmploymentDto) {
    const profile = await this.prisma.matrimonialProfile.findUnique({
      where: { userId },
      include: { governmentEmployment: true },
    });

    if (!profile) {
      throw new NotFoundException(
        "Matrimonial profile not found. Please create matrimonial profile first.",
      );
    }

    if (profile.governmentEmployment) {
      throw new ConflictException(
        "Government employment profile already exists. Use PATCH /me to update.",
      );
    }

    return this.prisma.governmentEmployment.create({
      data: {
        profileId: profile.id,
        employmentType: dto.employmentType,
        departmentId: dto.departmentId,
        designationId: dto.designationId,
        officeLocation: dto.officeLocation,
        joiningYear: dto.joiningYear,
        verificationStatus: GovtVerificationStatus.PENDING,
      },
      include: {
        department: true,
        designation: true,
      },
    });
  }

  async updateMyEmployment(userId: string, dto: UpdateGovtEmploymentDto) {
    const emp = await this.getMyEmployment(userId);
    if (!emp) {
      throw new NotFoundException(
        "Government employment record not found. Use POST /me to create.",
      );
    }

    return this.prisma.governmentEmployment.update({
      where: { id: emp.id },
      data: {
        ...dto,
      },
      include: {
        department: true,
        designation: true,
      },
    });
  }

  async submitMyVerification(userId: string, dto: SubmitVerificationDto) {
    const emp = await this.getMyEmployment(userId);
    if (!emp) {
      throw new NotFoundException(
        "Government employment record not found. Create employment profile first.",
      );
    }

    return this.prisma.$transaction(async (tx) => {
      const verification = await tx.governmentEmploymentVerification.create({
        data: {
          employmentId: emp.id,
          documentType: dto.documentType,
          documentUrl: dto.documentUrl,
          status: GovtVerificationStatus.PENDING,
        },
      });

      const updatedEmp = await tx.governmentEmployment.update({
        where: { id: emp.id },
        data: {
          verificationStatus: GovtVerificationStatus.PENDING,
          verificationSubmittedAt: new Date(),
          rejectionReason: null,
        },
        include: {
          department: true,
          designation: true,
          verifications: { orderBy: { createdAt: "desc" }, take: 1 },
        },
      });

      return updatedEmp;
    });
  }

  // ==========================================
  // SYNC MISSING GOVT EMPLOYEES FROM PROFILES
  // ==========================================

  async syncMissingGovtEmployees() {
    try {
      const govtProfiles = await this.prisma.matrimonialProfile.findMany({
        where: {
          governmentEmployment: null,
          OR: [
            { occupation: { contains: "Gov" } },
            { occupation: { contains: "સરકારી" } },
            { organizationName: { contains: "Gov" } },
            { organizationName: { contains: "સરકારી" } },
            { occupation: { contains: "State" } },
            { occupation: { contains: "Central" } },
            { organizationName: { contains: "State" } },
            { organizationName: { contains: "Central" } },
          ],
        },
      });

      for (const p of govtProfiles) {
        const occ = (p.occupation || "").toLowerCase();
        const org = (p.organizationName || "").toLowerCase();
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
          p.city || p.state || p.nativePlace || p.organizationName || "Gujarat";

        await this.prisma.governmentEmployment.create({
          data: {
            profileId: p.id,
            employmentType: empType,
            officeLocation: officeLoc,
            verificationStatus: GovtVerificationStatus.VERIFIED,
            isActive: true,
            isFeatured: p.isFeatured || false,
          },
        });
        this.logger.log(
          `Auto-synced government profile: ${p.firstName} ${p.lastName} (${p.id})`,
        );
      }
    } catch (err: any) {
      this.logger.warn(
        `syncMissingGovtEmployees warning: ${err?.message || err}`,
      );
    }
  }

  // ==========================================
  // PUBLIC MEMBER SEARCH & LISTING
  // ==========================================

  async searchPublicGovtEmployees(query: GovtEmployeeSearchQueryDto) {
    await this.syncMissingGovtEmployees();

    const page = Math.max(1, Number(query.page) || 1);
    const limit = Math.min(50, Math.max(1, Number(query.limit) || 20));
    const skip = (page - 1) * limit;

    try {
      // Base condition for government employee specific rules
      const whereCondition: any = {
        isActive: true,
        verificationStatus: {
          in: [GovtVerificationStatus.VERIFIED, GovtVerificationStatus.PENDING],
        },
        profile: {
          status: {
            not: ProfileStatus.REJECTED,
          },
        },
      };

      if (query.employmentType && query.employmentType !== "ALL") {
        whereCondition.employmentType =
          query.employmentType as GovtEmploymentType;
      }

      if (query.departmentId) {
        whereCondition.departmentId = query.departmentId;
      }

      if (query.designationId) {
        whereCondition.designationId = query.designationId;
      }

      if (query.search) {
        whereCondition.OR = [
          { profile: { firstName: { contains: query.search } } },
          { profile: { lastName: { contains: query.search } } },
          { profile: { organizationName: { contains: query.search } } },
          { profile: { designation: { contains: query.search } } },
          { officeLocation: { contains: query.search } },
          { department: { name: { contains: query.search } } },
          { designation: { name: { contains: query.search } } },
        ];
      }

      // Add base profile filters (gender, age, location)
      if (query.gender) {
        whereCondition.profile.gender = query.gender.toUpperCase();
      }
      if (query.districtId) {
        whereCondition.profile.OR = [
          { districtId: query.districtId },
          { district: { name: { contains: query.districtId } } },
          { city: { contains: query.districtId } },
          { nativePlace: { contains: query.districtId } },
        ];
      }
      if (query.talukaId) {
        whereCondition.profile.talukaId = query.talukaId;
      }
      if (query.stateId) {
        whereCondition.profile.stateId = query.stateId;
      }
      if (query.maritalStatus) {
        whereCondition.profile.maritalStatus = query.maritalStatus;
      }

      const [items, total] = await Promise.all([
        this.prisma.governmentEmployment.findMany({
          where: whereCondition,
          skip,
          take: limit,
          include: {
            department: true,
            designation: true,
            profile: {
              include: {
                district: true,
                taluka: true,
                stateRef: true,
              },
            },
          },
          orderBy: query.sortBy
            ? { [query.sortBy]: query.sortOrder || "desc" }
            : { createdAt: "desc" },
        }),
        this.prisma.governmentEmployment.count({ where: whereCondition }),
      ]);

      const formattedItems = items.map((item) =>
        this.transformToPublicDto(item),
      );

      return {
        data: formattedItems,
        meta: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit) || 1,
          hasNextPage: page < Math.ceil(total / limit),
          hasPreviousPage: page > 1,
        },
      };
    } catch (err: any) {
      this.logger.warn(
        "Prisma Public Govt Employee search fallback:",
        err?.message,
      );
      return {
        data: [],
        meta: {
          page: 1,
          limit: 20,
          total: 0,
          totalPages: 1,
          hasNextPage: false,
          hasPreviousPage: false,
        },
      };
    }
  }

  async getFeaturedGovtEmployees() {
    await this.syncMissingGovtEmployees();
    try {
      const items = await this.prisma.governmentEmployment.findMany({
        where: {
          isFeatured: true,
          isActive: true,
          verificationStatus: {
            in: [GovtVerificationStatus.VERIFIED, GovtVerificationStatus.PENDING],
          },
          profile: { status: { not: ProfileStatus.REJECTED } },
        },
        take: 10,
        include: {
          department: true,
          designation: true,
          profile: {
            include: {
              district: true,
              taluka: true,
            },
          },
        },
        orderBy: { updatedAt: "desc" },
      });

      return items.map((item) => this.transformToPublicDto(item));
    } catch (err: any) {
      this.logger.warn(
        "Prisma Featured Govt Employees fallback:",
        err?.message,
      );
      return [];
    }
  }

  async getPublicGovtProfileById(id: string) {
    const item = await this.prisma.governmentEmployment.findFirst({
      where: {
        id,
        verificationStatus: GovtVerificationStatus.VERIFIED,
        isActive: true,
      },
      include: {
        department: true,
        designation: true,
        profile: {
          include: {
            district: true,
            taluka: true,
            pargana: true,
            village: true,
          },
        },
      },
    });

    if (!item) {
      throw new NotFoundException(
        "Verified Government Employee profile not found",
      );
    }

    return this.transformToPublicDto(item);
  }

  // ==========================================
  // ADMIN PANEL APIs
  // ==========================================

  async getAdminGovtEmployees(page = 1, limit = 20, status?: string) {
    await this.syncMissingGovtEmployees();
    const skip = (page - 1) * limit;
    const whereCondition: any = {};
    if (status && status !== "ALL") {
      whereCondition.verificationStatus = status as GovtVerificationStatus;
    }

    const [items, total] = await Promise.all([
      this.prisma.governmentEmployment.findMany({
        where: whereCondition,
        skip,
        take: limit,
        include: {
          department: true,
          designation: true,
          verifications: { orderBy: { createdAt: "desc" } },
          profile: {
            include: {
              user: true,
              district: true,
              taluka: true,
            },
          },
        },
        orderBy: { createdAt: "desc" },
      }),
      this.prisma.governmentEmployment.count({ where: whereCondition }),
    ]);

    return {
      data: items,
      items: items,
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit) || 1,
        hasNextPage: page < Math.ceil(total / limit),
        hasPreviousPage: page > 1,
      },
    };
  }

  async getAdminStats() {
    try {
      const [total, pending, verified, rejected, featured, active] =
        await Promise.all([
          this.prisma.governmentEmployment.count(),
          this.prisma.governmentEmployment.count({
            where: { verificationStatus: GovtVerificationStatus.PENDING },
          }),
          this.prisma.governmentEmployment.count({
            where: { verificationStatus: GovtVerificationStatus.VERIFIED },
          }),
          this.prisma.governmentEmployment.count({
            where: { verificationStatus: GovtVerificationStatus.REJECTED },
          }),
          this.prisma.governmentEmployment.count({
            where: { isFeatured: true },
          }),
          this.prisma.governmentEmployment.count({ where: { isActive: true } }),
        ]);

      return { total, pending, verified, rejected, featured, active };
    } catch (err: any) {
      return {
        total: 0,
        pending: 0,
        verified: 0,
        rejected: 0,
        featured: 0,
        active: 0,
      };
    }
  }

  async verifyGovtEmployee(
    id: string,
    dto: AdminVerifyGovtEmpDto,
    adminId: string,
  ) {
    const emp = await this.prisma.governmentEmployment.findUnique({
      where: { id },
      include: { verifications: { orderBy: { createdAt: "desc" }, take: 1 } },
    });

    if (!emp) {
      throw new NotFoundException("Government employment record not found");
    }

    const targetStatus =
      dto.action === "APPROVE"
        ? GovtVerificationStatus.VERIFIED
        : GovtVerificationStatus.REJECTED;

    return this.prisma.$transaction(async (tx) => {
      // Update employment record
      const updatedEmp = await tx.governmentEmployment.update({
        where: { id },
        data: {
          verificationStatus: targetStatus,
          verifiedAt:
            targetStatus === GovtVerificationStatus.VERIFIED
              ? new Date()
              : null,
          verifiedBy:
            targetStatus === GovtVerificationStatus.VERIFIED ? adminId : null,
          rejectionReason:
            targetStatus === GovtVerificationStatus.REJECTED
              ? dto.rejectionReason
              : null,
        },
        include: { department: true, designation: true },
      });

      // Update latest verification document if present
      const latestVerification = emp.verifications[0];
      if (latestVerification) {
        await tx.governmentEmploymentVerification.update({
          where: { id: latestVerification.id },
          data: {
            status: targetStatus,
            reviewedBy: adminId,
            reviewedAt: new Date(),
            rejectionReason: dto.rejectionReason || null,
          },
        });
      }

      // Log audit
      await this.logAdminAudit(
        adminId,
        dto.action === "APPROVE"
          ? "APPROVE_GOVT_EMPLOYMENT"
          : "REJECT_GOVT_EMPLOYMENT",
        "GovernmentEmployment",
        id,
        JSON.stringify({ verificationStatus: emp.verificationStatus }),
        JSON.stringify({
          verificationStatus: targetStatus,
          rejectionReason: dto.rejectionReason,
        }),
      );

      return updatedEmp;
    });
  }

  async setGovtEmployeeFeatured(
    id: string,
    dto: AdminFeatureGovtEmpDto,
    adminId: string,
  ) {
    const emp = await this.prisma.governmentEmployment.findUnique({
      where: { id },
      include: { profile: true },
    });

    if (!emp) {
      throw new NotFoundException("Government employment record not found");
    }

    // Backend rule enforcement
    if (dto.isFeatured) {
      if (emp.verificationStatus !== GovtVerificationStatus.VERIFIED) {
        throw new BadRequestException(
          "Cannot feature profile: Verification status is not VERIFIED",
        );
      }
      if (!emp.isActive) {
        throw new BadRequestException(
          "Cannot feature profile: Record is not active",
        );
      }
      if (emp.profile.status !== "APPROVED") {
        throw new BadRequestException(
          "Cannot feature profile: Matrimonial profile is not approved",
        );
      }
    }

    const updated = await this.prisma.governmentEmployment.update({
      where: { id },
      data: { isFeatured: dto.isFeatured },
    });

    await this.logAdminAudit(
      adminId,
      dto.isFeatured ? "FEATURE_GOVT_EMPLOYMENT" : "UNFEATURE_GOVT_EMPLOYMENT",
      "GovernmentEmployment",
      id,
      JSON.stringify({ isFeatured: emp.isFeatured }),
      JSON.stringify({ isFeatured: dto.isFeatured }),
    );

    return updated;
  }

  async setGovtEmployeeStatus(
    id: string,
    dto: AdminStatusGovtEmpDto,
    adminId: string,
  ) {
    const emp = await this.prisma.governmentEmployment.findUnique({
      where: { id },
    });
    if (!emp) {
      throw new NotFoundException("Government employment record not found");
    }

    const updated = await this.prisma.governmentEmployment.update({
      where: { id },
      data: { isActive: dto.isActive },
    });

    await this.logAdminAudit(
      adminId,
      dto.isActive ? "ACTIVATE_GOVT_EMPLOYMENT" : "DEACTIVATE_GOVT_EMPLOYMENT",
      "GovernmentEmployment",
      id,
      JSON.stringify({ isActive: emp.isActive }),
      JSON.stringify({ isActive: dto.isActive }),
    );

    return updated;
  }

  // Helper for admin audit logging
  private async logAdminAudit(
    adminId: string,
    action: string,
    entityType: string,
    entityId: string,
    oldValue: string | null,
    newValue: string | null,
  ) {
    try {
      await this.prisma.adminAuditLog.create({
        data: {
          adminId,
          action,
          entityType,
          entityId,
          oldValue,
          newValue,
        },
      });
    } catch (err: any) {
      this.logger.warn("Failed to record admin audit log:", err?.message);
    }
  }

  // DTO Transformation isolating sensitive documents & admin data
  private transformToPublicDto(emp: any) {
    const p = emp.profile || {};
    const birthYear = p.dateOfBirth
      ? new Date(p.dateOfBirth).getFullYear()
      : null;
    const currentYear = new Date().getFullYear();
    const calculatedAge = birthYear ? currentYear - birthYear : null;

    const deptName =
      emp.department?.name ||
      p.organizationName ||
      (emp.employmentType === "CENTRAL_GOVT"
        ? "Central Government"
        : "State Government");

    const deptGujarati =
      emp.department?.gujaratiName ||
      p.organizationName ||
      (emp.employmentType === "CENTRAL_GOVT"
        ? "કેન્દ્ર સરકાર"
        : "રાજ્ય સરકાર");

    const desigName =
      emp.designation?.name || p.designation || "Officer / Employee";

    const desigGujarati =
      emp.designation?.gujaratiName || p.designation || "સરકારી કર્મચારી";

    return {
      id: emp.id,
      profileId: p.id,
      fullName:
        `${p.firstName || ""} ${p.lastName || ""}`.trim() || "Vankar Member",
      gender: p.gender || "MALE",
      age: calculatedAge,
      education: p.education || "Graduate",
      maritalStatus: p.maritalStatus || "NEVER_MARRIED",
      photoUrl: p.photoUrl || null,
      districtName:
        p.district?.name || p.district?.gujaratiName || p.state || null,
      talukaName:
        p.taluka?.name || p.taluka?.gujaratiName || p.city || null,
      employmentType: emp.employmentType,
      departmentName: deptName,
      departmentGujaratiName: deptGujarati,
      designationName: desigName,
      designationGujaratiName: desigGujarati,
      officeLocation:
        emp.officeLocation || p.city || p.nativePlace || p.state || null,
      joiningYear: emp.joiningYear || null,
      isVerified:
        emp.verificationStatus === GovtVerificationStatus.VERIFIED ||
        p.isVerified === true,
      isFeatured: emp.isFeatured || p.isFeatured || false,
    };
  }
}
