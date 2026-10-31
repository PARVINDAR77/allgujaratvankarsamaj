"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var GovernmentEmployeesService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.GovernmentEmployeesService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const client_1 = require("@prisma/client");
let GovernmentEmployeesService = GovernmentEmployeesService_1 = class GovernmentEmployeesService {
    constructor(prisma) {
        this.prisma = prisma;
        this.logger = new common_1.Logger(GovernmentEmployeesService_1.name);
        this.initialDepartments = [
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
        this.isSyncRunning = false;
        this.lastSyncResult = {
            status: "idle",
            lastRunAt: null,
            durationMs: 0,
            syncedCount: 0,
            hasMore: false,
            error: undefined,
        };
    }
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
        }
        catch (err) {
            this.logger.warn("Prisma Master Departments query fallback:", err?.message);
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
    async createDepartment(dto, adminId) {
        const dept = await this.prisma.govtDepartment.create({ data: dto });
        await this.logAdminAudit(adminId, "CREATE_DEPARTMENT", "GovtDepartment", dept.id, null, JSON.stringify(dept));
        return dept;
    }
    async updateDepartment(id, dto, adminId) {
        const oldVal = await this.prisma.govtDepartment.findUnique({
            where: { id },
        });
        const updated = await this.prisma.govtDepartment.update({
            where: { id },
            data: dto,
        });
        await this.logAdminAudit(adminId, "UPDATE_DEPARTMENT", "GovtDepartment", id, JSON.stringify(oldVal), JSON.stringify(updated));
        return updated;
    }
    async softDeleteDepartment(id, adminId) {
        const oldVal = await this.prisma.govtDepartment.findUnique({
            where: { id },
        });
        const updated = await this.prisma.govtDepartment.update({
            where: { id },
            data: { isActive: false },
        });
        await this.logAdminAudit(adminId, "DEACTIVATE_DEPARTMENT", "GovtDepartment", id, JSON.stringify(oldVal), JSON.stringify(updated));
        return updated;
    }
    async createDesignation(dto, adminId) {
        const desig = await this.prisma.govtDesignation.create({ data: dto });
        await this.logAdminAudit(adminId, "CREATE_DESIGNATION", "GovtDesignation", desig.id, null, JSON.stringify(desig));
        return desig;
    }
    async updateDesignation(id, dto, adminId) {
        const oldVal = await this.prisma.govtDesignation.findUnique({
            where: { id },
        });
        const updated = await this.prisma.govtDesignation.update({
            where: { id },
            data: dto,
        });
        await this.logAdminAudit(adminId, "UPDATE_DESIGNATION", "GovtDesignation", id, JSON.stringify(oldVal), JSON.stringify(updated));
        return updated;
    }
    async softDeleteDesignation(id, adminId) {
        const oldVal = await this.prisma.govtDesignation.findUnique({
            where: { id },
        });
        const updated = await this.prisma.govtDesignation.update({
            where: { id },
            data: { isActive: false },
        });
        await this.logAdminAudit(adminId, "DEACTIVATE_DESIGNATION", "GovtDesignation", id, JSON.stringify(oldVal), JSON.stringify(updated));
        return updated;
    }
    async getMyEmployment(userId) {
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
            throw new common_1.NotFoundException("Matrimonial profile not found for user");
        }
        return profile.governmentEmployment || null;
    }
    async createMyEmployment(userId, dto) {
        const profile = await this.prisma.matrimonialProfile.findUnique({
            where: { userId },
            include: { governmentEmployment: true },
        });
        if (!profile) {
            throw new common_1.NotFoundException("Matrimonial profile not found. Please create matrimonial profile first.");
        }
        if (profile.governmentEmployment) {
            throw new common_1.ConflictException("Government employment profile already exists. Use PATCH /me to update.");
        }
        const occ = (profile.occupation || "").toLowerCase();
        const org = (profile.organizationName || "").toLowerCase();
        const isPrivate = occ.includes("private") ||
            occ.includes("ખાનગી") ||
            occ.includes("business") ||
            occ.includes("વેપાર") ||
            occ.includes("સ્વરોજગાર") ||
            occ.includes("self") ||
            occ.includes("not working") ||
            occ.includes("કોઈ નોકરી નથી") ||
            org.includes("it company") ||
            org.includes("pvt") ||
            org.includes("private") ||
            org.includes("ખાનગી") ||
            org.includes("ltd") ||
            org.includes("llp");
        if (isPrivate) {
            throw new common_1.BadRequestException("Private or business employees cannot be registered under Government Employees. Please register under Private Employees or Samaj Services.");
        }
        return this.prisma.governmentEmployment.create({
            data: {
                profileId: profile.id,
                employmentType: dto.employmentType,
                departmentId: dto.departmentId,
                designationId: dto.designationId,
                officeLocation: dto.officeLocation,
                joiningYear: dto.joiningYear,
                verificationStatus: client_1.GovtVerificationStatus.PENDING,
            },
            include: {
                department: true,
                designation: true,
            },
        });
    }
    async updateMyEmployment(userId, dto) {
        const emp = await this.getMyEmployment(userId);
        if (!emp) {
            throw new common_1.NotFoundException("Government employment record not found. Use POST /me to create.");
        }
        const profile = await this.prisma.matrimonialProfile.findUnique({
            where: { userId },
        });
        if (profile) {
            const occ = (profile.occupation || "").toLowerCase();
            const org = (profile.organizationName || "").toLowerCase();
            const isPrivate = occ.includes("private") ||
                occ.includes("ખાનગી") ||
                occ.includes("business") ||
                occ.includes("વેપાર") ||
                occ.includes("સ્વરોજગાર") ||
                occ.includes("self") ||
                occ.includes("not working") ||
                occ.includes("કોઈ નોકરી નથી") ||
                org.includes("it company") ||
                org.includes("pvt") ||
                org.includes("private") ||
                org.includes("ખાનગી") ||
                org.includes("ltd") ||
                org.includes("llp");
            if (isPrivate) {
                throw new common_1.BadRequestException("Private or business employees cannot be registered under Government Employees.");
            }
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
    async submitMyVerification(userId, dto) {
        const emp = await this.getMyEmployment(userId);
        if (!emp) {
            throw new common_1.NotFoundException("Government employment record not found. Create employment profile first.");
        }
        if (emp.verificationStatus === client_1.GovtVerificationStatus.VERIFIED) {
            throw new common_1.ConflictException("સરકારી નોકરી વેરિફિકેશન પહેલેથી જ મંજૂર થયેલ છે. દસ્તાવેજો માત્ર એક જ વાર ઉપયોગ કરી શકાય છે. (Government employment verification is already approved. Documents can only be used one time.)");
        }
        const cleanDoc = dto.documentUrl.trim().toLowerCase();
        const docFilename = cleanDoc.split("/").pop()?.split("?")[0];
        const docUsedElsewhere = await this.prisma.governmentEmploymentVerification.findFirst({
            where: {
                employmentId: { not: emp.id },
                OR: [
                    { documentUrl: cleanDoc },
                    ...(docFilename && docFilename.length > 5
                        ? [{ documentUrl: { contains: docFilename } }]
                        : []),
                ],
            },
        });
        if (docUsedElsewhere) {
            throw new common_1.ConflictException("આ દસ્તાવેજ અન્ય ઉમેદવાર દ્વારા પહેલેથી જ જમા થયેલ છે. દસ્તાવેજો માત્ર એક જ વાર ઉપયોગ કરી શકાય છે. (This document has already been submitted for another candidate. Documents can only be used one time.)");
        }
        const docUsedInMatrimonial = await this.prisma.verificationRequest.findFirst({
            where: {
                OR: [
                    { documentUrl: cleanDoc },
                    ...(docFilename && docFilename.length > 5
                        ? [{ documentUrl: { contains: docFilename } }]
                        : []),
                ],
            },
        });
        if (docUsedInMatrimonial) {
            throw new common_1.ConflictException("આ દસ્તાવેજ પહેલેથી જ જમા થયેલ છે. દસ્તાવેજો માત્ર એક જ વાર ઉપયોગ કરી શકાય છે. (This document has already been submitted. Documents can only be used one time.)");
        }
        return this.prisma.$transaction(async (tx) => {
            const verification = await tx.governmentEmploymentVerification.create({
                data: {
                    employmentId: emp.id,
                    documentType: dto.documentType,
                    documentUrl: dto.documentUrl,
                    status: client_1.GovtVerificationStatus.PENDING,
                },
            });
            const updatedEmp = await tx.governmentEmployment.update({
                where: { id: emp.id },
                data: {
                    verificationStatus: client_1.GovtVerificationStatus.PENDING,
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
    getSyncStatus() {
        return {
            ...this.lastSyncResult,
            isRunning: this.isSyncRunning,
        };
    }
    async triggerAdminSync() {
        if (this.isSyncRunning) {
            this.logger.warn("Government employee sync already in progress (in-process). Concurrent invocation suppressed.");
            throw new common_1.ConflictException("Government profile synchronization is already in progress.");
        }
        this.isSyncRunning = true;
        this.lastSyncResult.status = "running";
        const startTime = Date.now();
        this.logger.log("Administrative government profile synchronization started...");
        try {
            const result = await this.prisma.$transaction(async (tx) => {
                let lockAcquired = false;
                try {
                    const lockRows = await tx.$queryRawUnsafe(`SELECT GET_LOCK('govt_employee_sync_lock', 0) AS acquired`);
                    const val = lockRows?.[0]?.acquired;
                    lockAcquired = val === 1 || val === 1n || val === "1";
                }
                catch (lockErr) {
                    this.logger.debug(`Advisory lock check skipped/unsupported: ${lockErr?.message || lockErr}`);
                    lockAcquired = true;
                }
                if (!lockAcquired) {
                    throw new common_1.ConflictException("Government profile synchronization is already running in another process.");
                }
                try {
                    return await this.executeSyncSafelyOnTx(tx);
                }
                finally {
                    try {
                        if (lockAcquired) {
                            await tx.$queryRawUnsafe(`SELECT RELEASE_LOCK('govt_employee_sync_lock')`);
                        }
                    }
                    catch (_) { }
                }
            }, { timeout: 60000 });
            const durationMs = Date.now() - startTime;
            const isComplete = !result.hasMore;
            this.lastSyncResult = {
                status: "success",
                lastRunAt: new Date().toISOString(),
                durationMs,
                syncedCount: result.syncedCount,
                hasMore: result.hasMore,
                error: undefined,
            };
            this.logger.log(`Government profile synchronization ${isComplete ? "completed" : "reached batch limit"} in ${durationMs}ms. Created: ${result.syncedCount}, Updated: ${result.updatedCount}, Soft-Deactivated: ${result.deactivatedCount}, HasMore: ${result.hasMore}.`);
            return {
                success: true,
                message: isComplete
                    ? `Synchronization fully completed in ${durationMs}ms.`
                    : `Synchronization processed batch limit (${result.syncedCount} created). Additional eligible profiles remain to be processed.`,
                durationMs,
                syncedCount: result.syncedCount,
                updatedCount: result.updatedCount,
                deactivatedCount: result.deactivatedCount,
                hasMore: result.hasMore,
            };
        }
        catch (err) {
            const durationMs = Date.now() - startTime;
            if (!(err instanceof common_1.ConflictException)) {
                this.lastSyncResult = {
                    status: "failed",
                    lastRunAt: new Date().toISOString(),
                    durationMs,
                    syncedCount: 0,
                    hasMore: false,
                    error: err?.message || String(err),
                };
                this.logger.error(`Government profile synchronization failed after ${durationMs}ms: ${err?.message || err}`, err?.stack);
            }
            throw err;
        }
        finally {
            this.isSyncRunning = false;
        }
    }
    async syncMissingGovtEmployees() {
        return this.triggerAdminSync();
    }
    async executeSyncSafelyOnTx(tx) {
        let syncedCount = 0;
        let updatedCount = 0;
        let deactivatedCount = 0;
        const unreviewedActiveGovt = await tx.governmentEmployment.findMany({
            where: {
                isActive: true,
                departmentId: null,
                designationId: null,
                verifiedBy: null,
                verifications: { none: {} },
                profile: {
                    OR: [
                        { status: client_1.ProfileStatus.REJECTED },
                        { status: client_1.ProfileStatus.SUSPENDED },
                        { occupation: { contains: "Private" } },
                        { occupation: { contains: "ખાનગી" } },
                        { occupation: { contains: "Business" } },
                        { occupation: { contains: "વેપાર" } },
                        { occupation: { contains: "સ્વરોજગાર" } },
                        { occupation: { contains: "Not Working" } },
                        { occupation: { contains: "કોઈ નોકરી નથી" } },
                        { organizationName: { contains: "it company" } },
                        { organizationName: { contains: "pvt ltd" } },
                        { organizationName: { contains: "private limited" } },
                        { designation: { contains: "it company" } },
                    ],
                },
            },
            select: { id: true },
            take: 50,
        });
        for (const record of unreviewedActiveGovt) {
            await tx.governmentEmployment.update({
                where: { id: record.id },
                data: { isActive: false },
            });
            deactivatedCount++;
        }
        const isDisqualified = (occ, org, desig, fn) => {
            return (occ.includes("private") ||
                occ.includes("ખાનગી") ||
                occ.includes("business") ||
                occ.includes("વેપાર") ||
                occ.includes("સ્વરોજગાર") ||
                occ.includes("not working") ||
                occ.includes("કોઈ નોકરી નથી") ||
                org.includes("it company") ||
                org.includes("pvt ltd") ||
                org.includes("private limited") ||
                org.includes("ખાનગી") ||
                desig.includes("it company") ||
                fn.includes("parvindar"));
        };
        const qualifyingKeywords = [
            { occupation: { contains: "Gov" } },
            { occupation: { contains: "સરકારી" } },
            { organizationName: { contains: "Gov" } },
            { organizationName: { contains: "સરકારી" } },
            { occupation: { contains: "State Govt" } },
            { occupation: { contains: "Central Govt" } },
            { organizationName: { contains: "State Govt" } },
            { organizationName: { contains: "Central Govt" } },
            { designation: { contains: "Teacher" } },
            { designation: { contains: "શિક્ષક" } },
            { designation: { contains: "Police" } },
            { designation: { contains: "પોલીસ" } },
            { designation: { contains: "Talati" } },
            { designation: { contains: "તલાટી" } },
        ];
        const reactivatableGovt = await tx.governmentEmployment.findMany({
            where: {
                isActive: false,
                departmentId: null,
                designationId: null,
                verifiedBy: null,
                verificationStatus: { not: client_1.GovtVerificationStatus.REJECTED },
                rejectionReason: null,
                verifications: { none: {} },
                profile: {
                    status: { notIn: [client_1.ProfileStatus.REJECTED, client_1.ProfileStatus.SUSPENDED] },
                    OR: qualifyingKeywords,
                },
            },
            include: {
                profile: true,
            },
            take: 50,
        });
        for (const record of reactivatableGovt) {
            const p = record.profile;
            if (!p)
                continue;
            const occ = (p.occupation || "").toLowerCase();
            const org = (p.organizationName || "").toLowerCase();
            const desig = (p.designation || "").toLowerCase();
            const fn = (p.firstName || "").toLowerCase();
            if (!isDisqualified(occ, org, desig, fn)) {
                await tx.governmentEmployment.update({
                    where: { id: record.id },
                    data: { isActive: true },
                });
                updatedCount++;
            }
        }
        const BATCH_SIZE = 50;
        const MAX_BATCHES = 5;
        let batchIteration = 0;
        let hasMoreUnlinked = true;
        while (hasMoreUnlinked && batchIteration < MAX_BATCHES) {
            batchIteration++;
            const unlinkedBatch = await tx.matrimonialProfile.findMany({
                take: BATCH_SIZE,
                orderBy: { id: "asc" },
                where: {
                    governmentEmployment: null,
                    status: { notIn: [client_1.ProfileStatus.REJECTED, client_1.ProfileStatus.SUSPENDED] },
                    OR: qualifyingKeywords,
                },
            });
            if (!unlinkedBatch || unlinkedBatch.length === 0) {
                hasMoreUnlinked = false;
                break;
            }
            for (const p of unlinkedBatch) {
                const occ = (p.occupation || "").toLowerCase();
                const org = (p.organizationName || "").toLowerCase();
                const desig = (p.designation || "").toLowerCase();
                const fn = (p.firstName || "").toLowerCase();
                if (isDisqualified(occ, org, desig, fn)) {
                    continue;
                }
                let empType = client_1.GovtEmploymentType.STATE_GOVT;
                if (org.includes("central") ||
                    org.includes("કેન્દ્ર") ||
                    occ.includes("central") ||
                    occ.includes("કેન્દ્ર")) {
                    empType = client_1.GovtEmploymentType.CENTRAL_GOVT;
                }
                else if (org.includes("psu") ||
                    org.includes("public") ||
                    org.includes("જાહેર") ||
                    occ.includes("psu")) {
                    empType = client_1.GovtEmploymentType.PSU;
                }
                const officeLoc = p.city || p.state || p.nativePlace || p.organizationName || "Gujarat";
                const existing = await tx.governmentEmployment.findUnique({
                    where: { profileId: p.id },
                });
                if (!existing) {
                    await tx.governmentEmployment.create({
                        data: {
                            profileId: p.id,
                            employmentType: empType,
                            officeLocation: officeLoc,
                            verificationStatus: client_1.GovtVerificationStatus.VERIFIED,
                            isActive: true,
                            isFeatured: Boolean(p.isFeatured),
                        },
                    });
                    syncedCount++;
                    this.logger.log(`Auto-synced government profile: ${p.firstName} ${p.lastName} (${p.id})`);
                }
            }
            if (unlinkedBatch.length < BATCH_SIZE) {
                hasMoreUnlinked = false;
            }
        }
        return {
            syncedCount,
            updatedCount,
            deactivatedCount,
            hasMore: hasMoreUnlinked,
        };
    }
    async searchPublicGovtEmployees(query) {
        const page = Math.max(1, Number(query.page) || 1);
        const limit = Math.min(50, Math.max(1, Number(query.limit) || 20));
        const skip = (page - 1) * limit;
        try {
            const whereCondition = {
                isActive: true,
                verificationStatus: {
                    in: [client_1.GovtVerificationStatus.VERIFIED, client_1.GovtVerificationStatus.PENDING],
                },
                profile: {
                    status: {
                        not: client_1.ProfileStatus.REJECTED,
                    },
                },
            };
            if (query.employmentType && query.employmentType !== "ALL") {
                whereCondition.employmentType =
                    query.employmentType;
            }
            if (query.departmentId && query.departmentId !== "ALL" && query.departmentId.trim() !== "") {
                const dept = await this.prisma.govtDepartment.findUnique({
                    where: { id: query.departmentId },
                    select: { name: true, gujaratiName: true },
                }).catch(() => null);
                const deptName = dept?.name || "";
                const isEducation = deptName.toLowerCase().includes("education");
                const isPolice = deptName.toLowerCase().includes("police");
                whereCondition.AND = whereCondition.AND || [];
                whereCondition.AND.push({
                    OR: [
                        { departmentId: query.departmentId },
                        ...(deptName ? [
                            { department: { name: { contains: deptName } } },
                            { profile: { organizationName: { contains: deptName } } },
                            { profile: { occupation: { contains: deptName } } },
                        ] : []),
                        ...(isEducation ? [
                            { designation: { name: { contains: "Teacher" } } },
                            { designation: { gujaratiName: { contains: "શિક્ષક" } } },
                            { profile: { designation: { contains: "Teacher" } } },
                            { profile: { designation: { contains: "શિક્ષક" } } },
                        ] : []),
                        ...(isPolice ? [
                            { designation: { name: { contains: "Police" } } },
                            { designation: { gujaratiName: { contains: "પોલીસ" } } },
                            { profile: { designation: { contains: "Police" } } },
                            { profile: { designation: { contains: "પોલીસ" } } },
                        ] : []),
                    ],
                });
            }
            if (query.designationId && query.designationId !== "ALL" && query.designationId.trim() !== "") {
                const desig = await this.prisma.govtDesignation.findUnique({
                    where: { id: query.designationId },
                    select: { name: true, gujaratiName: true },
                }).catch(() => null);
                const desigName = desig?.name || "";
                whereCondition.AND = whereCondition.AND || [];
                whereCondition.AND.push({
                    OR: [
                        { designationId: query.designationId },
                        ...(desigName ? [
                            { designation: { name: { contains: desigName } } },
                            { profile: { designation: { contains: desigName } } },
                        ] : []),
                    ],
                });
            }
            if (query.search && query.search.trim() !== "") {
                const tokens = query.search.trim().split(/\s+/).filter(Boolean);
                for (const token of tokens) {
                    whereCondition.AND = whereCondition.AND || [];
                    whereCondition.AND.push({
                        OR: [
                            { profile: { id: { contains: token } } },
                            { profile: { firstName: { contains: token } } },
                            { profile: { lastName: { contains: token } } },
                            { profile: { organizationName: { contains: token } } },
                            { profile: { designation: { contains: token } } },
                            { profile: { state: { contains: token } } },
                            { profile: { city: { contains: token } } },
                            { profile: { nativePlace: { contains: token } } },
                            { officeLocation: { contains: token } },
                            { department: { name: { contains: token } } },
                            { department: { gujaratiName: { contains: token } } },
                            { designation: { name: { contains: token } } },
                            { designation: { gujaratiName: { contains: token } } },
                        ],
                    });
                }
            }
            const rawGender = query.gender || "";
            if (rawGender && rawGender.toUpperCase() !== "ALL" && rawGender.trim() !== "") {
                whereCondition.AND = whereCondition.AND || [];
                whereCondition.AND.push({
                    profile: { gender: rawGender.toUpperCase() },
                });
            }
            if (query.districtId && query.districtId !== "ALL" && query.districtId.trim() !== "") {
                const distTerm = query.districtId.trim();
                whereCondition.AND = whereCondition.AND || [];
                whereCondition.AND.push({
                    OR: [
                        { officeLocation: { contains: distTerm } },
                        { profile: { state: { contains: distTerm } } },
                        { profile: { city: { contains: distTerm } } },
                        { profile: { nativePlace: { contains: distTerm } } },
                        { profile: { districtId: distTerm } },
                        { profile: { district: { name: { contains: distTerm } } } },
                        { profile: { district: { gujaratiName: { contains: distTerm } } } },
                    ],
                });
            }
            if (query.talukaId && query.talukaId !== "ALL" && query.talukaId.trim() !== "") {
                const talTerm = query.talukaId.trim();
                whereCondition.AND = whereCondition.AND || [];
                whereCondition.AND.push({
                    OR: [
                        { officeLocation: { contains: talTerm } },
                        { profile: { city: { contains: talTerm } } },
                        { profile: { talukaId: talTerm } },
                        { profile: { taluka: { name: { contains: talTerm } } } },
                        { profile: { taluka: { gujaratiName: { contains: talTerm } } } },
                    ],
                });
            }
            if (query.stateId && query.stateId !== "ALL" && query.stateId.trim() !== "") {
                whereCondition.AND = whereCondition.AND || [];
                whereCondition.AND.push({
                    profile: { stateId: query.stateId },
                });
            }
            const rawMarital = query.maritalStatus || "";
            if (rawMarital && rawMarital.toUpperCase() !== "ALL" && rawMarital.trim() !== "") {
                whereCondition.AND = whereCondition.AND || [];
                whereCondition.AND.push({
                    profile: { maritalStatus: query.maritalStatus },
                });
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
            const validItems = items.filter((item) => !this.isNonGovtProfile(item));
            const formattedItems = validItems.map((item) => this.transformToPublicDto(item));
            return {
                data: formattedItems,
                meta: {
                    page,
                    limit,
                    total: validItems.length < items.length ? validItems.length : total,
                    totalPages: Math.ceil(total / limit) || 1,
                    hasNextPage: page < Math.ceil(total / limit),
                    hasPreviousPage: page > 1,
                },
            };
        }
        catch (err) {
            this.logger.warn("Prisma Public Govt Employee search fallback:", err?.message);
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
        try {
            const items = await this.prisma.governmentEmployment.findMany({
                where: {
                    isFeatured: true,
                    isActive: true,
                    verificationStatus: {
                        in: [client_1.GovtVerificationStatus.VERIFIED, client_1.GovtVerificationStatus.PENDING],
                    },
                    profile: {
                        status: { not: client_1.ProfileStatus.REJECTED },
                        NOT: [
                            { occupation: { contains: "Private" } },
                            { occupation: { contains: "ખાનગી" } },
                            { occupation: { contains: "Business" } },
                            { occupation: { contains: "વેપાર" } },
                            { occupation: { contains: "સ્વરોજગાર" } },
                            { occupation: { contains: "Not Working" } },
                            { occupation: { contains: "કોઈ નોકરી નથી" } },
                            { organizationName: { contains: "it company" } },
                            { organizationName: { contains: "pvt" } },
                            { organizationName: { contains: "private" } },
                            { organizationName: { contains: "ખાનગી" } },
                            { organizationName: { contains: "ltd" } },
                            { organizationName: { contains: "llp" } },
                            { designation: { contains: "it company" } },
                        ],
                    },
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
            const validItems = items.filter((item) => !this.isNonGovtProfile(item));
            return validItems.map((item) => this.transformToPublicDto(item));
        }
        catch (err) {
            this.logger.warn("Prisma Featured Govt Employees fallback:", err?.message);
            return [];
        }
    }
    async getPublicGovtProfileById(id) {
        const item = await this.prisma.governmentEmployment.findFirst({
            where: {
                id,
                verificationStatus: client_1.GovtVerificationStatus.VERIFIED,
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
            throw new common_1.NotFoundException("Verified Government Employee profile not found");
        }
        return this.transformToPublicDto(item);
    }
    async getAdminGovtEmployees(page = 1, limit = 20, status, forceSync = false) {
        if (forceSync) {
            await this.triggerAdminSync();
        }
        const whereCondition = {
            profile: {
                status: { not: client_1.ProfileStatus.REJECTED },
            },
        };
        if (status && status !== "ALL") {
            whereCondition.verificationStatus = status;
        }
        const skip = (page - 1) * limit;
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
        const validItems = items.filter((item) => !this.isNonGovtProfile(item));
        return {
            data: validItems,
            items: validItems,
            meta: {
                page,
                limit,
                total: validItems.length < items.length ? validItems.length : total,
                totalPages: Math.ceil(total / limit) || 1,
                hasNextPage: page < Math.ceil(total / limit),
                hasPreviousPage: page > 1,
            },
        };
    }
    async getAdminStats() {
        try {
            const [total, pending, verified, rejected, featured, active] = await Promise.all([
                this.prisma.governmentEmployment.count(),
                this.prisma.governmentEmployment.count({
                    where: { verificationStatus: client_1.GovtVerificationStatus.PENDING },
                }),
                this.prisma.governmentEmployment.count({
                    where: { verificationStatus: client_1.GovtVerificationStatus.VERIFIED },
                }),
                this.prisma.governmentEmployment.count({
                    where: { verificationStatus: client_1.GovtVerificationStatus.REJECTED },
                }),
                this.prisma.governmentEmployment.count({
                    where: { isFeatured: true },
                }),
                this.prisma.governmentEmployment.count({ where: { isActive: true } }),
            ]);
            return { total, pending, verified, rejected, featured, active };
        }
        catch (err) {
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
    async verifyGovtEmployee(id, dto, adminId) {
        const emp = await this.prisma.governmentEmployment.findUnique({
            where: { id },
            include: { verifications: { orderBy: { createdAt: "desc" }, take: 1 } },
        });
        if (!emp) {
            throw new common_1.NotFoundException("Government employment record not found");
        }
        const targetStatus = dto.action === "APPROVE"
            ? client_1.GovtVerificationStatus.VERIFIED
            : client_1.GovtVerificationStatus.REJECTED;
        return this.prisma.$transaction(async (tx) => {
            const updatedEmp = await tx.governmentEmployment.update({
                where: { id },
                data: {
                    verificationStatus: targetStatus,
                    verifiedAt: targetStatus === client_1.GovtVerificationStatus.VERIFIED
                        ? new Date()
                        : null,
                    verifiedBy: targetStatus === client_1.GovtVerificationStatus.VERIFIED ? adminId : null,
                    rejectionReason: targetStatus === client_1.GovtVerificationStatus.REJECTED
                        ? dto.rejectionReason
                        : null,
                },
                include: { department: true, designation: true },
            });
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
            await this.logAdminAudit(adminId, dto.action === "APPROVE"
                ? "APPROVE_GOVT_EMPLOYMENT"
                : "REJECT_GOVT_EMPLOYMENT", "GovernmentEmployment", id, JSON.stringify({ verificationStatus: emp.verificationStatus }), JSON.stringify({
                verificationStatus: targetStatus,
                rejectionReason: dto.rejectionReason,
            }));
            return updatedEmp;
        });
    }
    async setGovtEmployeeFeatured(id, dto, adminId) {
        const emp = await this.prisma.governmentEmployment.findUnique({
            where: { id },
            include: { profile: true },
        });
        if (!emp) {
            throw new common_1.NotFoundException("Government employment record not found");
        }
        if (dto.isFeatured) {
            if (emp.verificationStatus !== client_1.GovtVerificationStatus.VERIFIED) {
                throw new common_1.BadRequestException("Cannot feature profile: Verification status is not VERIFIED");
            }
            if (!emp.isActive) {
                throw new common_1.BadRequestException("Cannot feature profile: Record is not active");
            }
            if (emp.profile.status !== "APPROVED") {
                throw new common_1.BadRequestException("Cannot feature profile: Matrimonial profile is not approved");
            }
        }
        const updated = await this.prisma.governmentEmployment.update({
            where: { id },
            data: { isFeatured: dto.isFeatured },
        });
        await this.logAdminAudit(adminId, dto.isFeatured ? "FEATURE_GOVT_EMPLOYMENT" : "UNFEATURE_GOVT_EMPLOYMENT", "GovernmentEmployment", id, JSON.stringify({ isFeatured: emp.isFeatured }), JSON.stringify({ isFeatured: dto.isFeatured }));
        return updated;
    }
    async setGovtEmployeeStatus(id, dto, adminId) {
        const emp = await this.prisma.governmentEmployment.findUnique({
            where: { id },
        });
        if (!emp) {
            throw new common_1.NotFoundException("Government employment record not found");
        }
        const updated = await this.prisma.governmentEmployment.update({
            where: { id },
            data: { isActive: dto.isActive },
        });
        await this.logAdminAudit(adminId, dto.isActive ? "ACTIVATE_GOVT_EMPLOYMENT" : "DEACTIVATE_GOVT_EMPLOYMENT", "GovernmentEmployment", id, JSON.stringify({ isActive: emp.isActive }), JSON.stringify({ isActive: dto.isActive }));
        return updated;
    }
    async logAdminAudit(adminId, action, entityType, entityId, oldValue, newValue) {
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
        }
        catch (err) {
            this.logger.warn("Failed to record admin audit log:", err?.message);
        }
    }
    isNonGovtProfile(item) {
        const p = item?.profile || {};
        const occ = (p.occupation || "").toLowerCase();
        const org = (p.organizationName || "").toLowerCase();
        const desig = (p.designation || "").toLowerCase();
        const name = `${p.firstName || ""} ${p.lastName || ""}`.toLowerCase();
        const dept = (item?.department?.name || "").toLowerCase();
        const deptGu = (item?.department?.gujaratiName || "").toLowerCase();
        const desigName = (item?.designation?.name || "").toLowerCase();
        const loc = (item?.officeLocation || "").toLowerCase();
        const nonGovtTerms = [
            "it company",
            "private",
            "ખાનગી",
            "pvt ltd",
            "pvt. ltd",
            "private limited",
            "business",
            "વેપાર",
            "સ્વરોજગાર",
            "not working",
            "કોઈ નોકરી નથી",
        ];
        for (const term of nonGovtTerms) {
            if (name.includes(term) ||
                occ.includes(term) ||
                org.includes(term) ||
                desig.includes(term) ||
                dept.includes(term) ||
                deptGu.includes(term) ||
                desigName.includes(term) ||
                loc.includes(term)) {
                return true;
            }
        }
        return false;
    }
    transformToPublicDto(emp) {
        const p = emp.profile || {};
        const birthYear = p.dateOfBirth
            ? new Date(p.dateOfBirth).getFullYear()
            : null;
        const currentYear = new Date().getFullYear();
        const calculatedAge = birthYear ? currentYear - birthYear : null;
        const rawOrg = p.organizationName || "";
        const isPrivateOrg = rawOrg.toLowerCase().includes("it company") ||
            rawOrg.toLowerCase().includes("private") ||
            rawOrg.toLowerCase().includes("pvt") ||
            rawOrg.toLowerCase().includes("ખાનગી");
        const deptName = emp.department?.name ||
            (!isPrivateOrg && rawOrg ? rawOrg : null) ||
            (emp.employmentType === "CENTRAL_GOVT"
                ? "Central Government"
                : "State Government");
        const deptGujarati = emp.department?.gujaratiName ||
            (!isPrivateOrg && rawOrg ? rawOrg : null) ||
            (emp.employmentType === "CENTRAL_GOVT"
                ? "કેન્દ્ર સરકાર"
                : "રાજ્ય સરકાર");
        const desigName = emp.designation?.name || p.designation || "Officer / Employee";
        const desigGujarati = emp.designation?.gujaratiName || p.designation || "સરકારી કર્મચારી";
        return {
            id: emp.id,
            profileId: p.id || emp.profileId || emp.id || "",
            fullName: `${p.firstName || ""} ${p.lastName || ""}`.trim() || "Vankar Member",
            gender: p.gender || "MALE",
            age: calculatedAge,
            education: p.education || "Graduate",
            maritalStatus: p.maritalStatus || "NEVER_MARRIED",
            photoUrl: p.photoUrl || null,
            districtName: p.district?.name || p.district?.gujaratiName || p.state || null,
            talukaName: p.taluka?.name || p.taluka?.gujaratiName || p.city || null,
            employmentType: emp.employmentType,
            departmentName: deptName,
            departmentGujaratiName: deptGujarati,
            designationName: desigName,
            designationGujaratiName: desigGujarati,
            officeLocation: emp.officeLocation || p.city || p.nativePlace || p.state || null,
            joiningYear: emp.joiningYear || null,
            isVerified: emp.verificationStatus === client_1.GovtVerificationStatus.VERIFIED ||
                p.isVerified === true,
            isFeatured: emp.isFeatured || p.isFeatured || false,
        };
    }
};
exports.GovernmentEmployeesService = GovernmentEmployeesService;
exports.GovernmentEmployeesService = GovernmentEmployeesService = GovernmentEmployeesService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], GovernmentEmployeesService);
//# sourceMappingURL=government-employees.service.js.map