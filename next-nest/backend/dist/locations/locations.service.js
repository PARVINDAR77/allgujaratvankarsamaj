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
var LocationsService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.LocationsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let LocationsService = LocationsService_1 = class LocationsService {
    constructor(prisma) {
        this.prisma = prisma;
        this.logger = new common_1.Logger(LocationsService_1.name);
    }
    async seedInitialLocations() {
        try {
            let state = await this.prisma.state.findUnique({ where: { code: "GJ" } });
            if (!state) {
                state = await this.prisma.state.create({
                    data: {
                        name: "Gujarat",
                        gujaratiName: "ગુજરાત",
                        code: "GJ",
                        isActive: true,
                    },
                });
            }
            const initialDistricts = [
                { name: "Sabarkantha", gujaratiName: "સાબરકાંઠા", code: "SK" },
                { name: "Mehsana", gujaratiName: "મહેસાણા", code: "MS" },
                { name: "Anand", gujaratiName: "આણંદ", code: "AN" },
                { name: "Surat", gujaratiName: "સુરત", code: "ST" },
                { name: "Rajkot", gujaratiName: "રાજકોટ", code: "RJ" },
                { name: "Ahmedabad", gujaratiName: "અમદાવાદ", code: "AMD" },
            ];
            for (const d of initialDistricts) {
                const existing = await this.prisma.district.findFirst({
                    where: { stateId: state.id, name: d.name },
                });
                if (!existing) {
                    await this.prisma.district.create({
                        data: {
                            stateId: state.id,
                            name: d.name,
                            gujaratiName: d.gujaratiName,
                            code: d.code,
                            isActive: true,
                        },
                    });
                }
            }
            const sabarkantha = await this.prisma.district.findFirst({
                where: { stateId: state.id, name: "Sabarkantha" },
            });
            if (sabarkantha) {
                let idarTaluka = await this.prisma.taluka.findFirst({
                    where: { districtId: sabarkantha.id, name: "Idar" },
                });
                if (!idarTaluka) {
                    idarTaluka = await this.prisma.taluka.create({
                        data: {
                            districtId: sabarkantha.id,
                            name: "Idar",
                            gujaratiName: "ઈડર",
                            code: "IDAR",
                            isActive: true,
                        },
                    });
                }
                const pargana35 = await this.prisma.pargana.findFirst({
                    where: { name: { contains: "35" } },
                });
                if (pargana35 && idarTaluka) {
                    await this.prisma.parganaTaluka.upsert({
                        where: {
                            parganaId_talukaId: {
                                parganaId: pargana35.id,
                                talukaId: idarTaluka.id,
                            },
                        },
                        create: {
                            parganaId: pargana35.id,
                            talukaId: idarTaluka.id,
                        },
                        update: {},
                    });
                }
            }
        }
        catch (err) {
            this.logger.warn("Location seeding warning:", err?.message);
        }
    }
    async getPublicStates() {
        await this.seedInitialLocations();
        return this.prisma.state.findMany({
            where: { isActive: true },
            orderBy: { name: "asc" },
        });
    }
    async getAdminStates() {
        return this.prisma.state.findMany({
            orderBy: { name: "asc" },
            include: {
                _count: { select: { districts: true } },
            },
        });
    }
    async createState(data) {
        const existing = await this.prisma.state.findUnique({
            where: { code: data.code },
        });
        if (existing)
            throw new common_1.BadRequestException(`State with code ${data.code} already exists`);
        return this.prisma.state.create({ data });
    }
    async updateState(id, data) {
        return this.prisma.state.update({ where: { id }, data });
    }
    async deleteState(id) {
        return this.prisma.state.update({
            where: { id },
            data: { isActive: false },
        });
    }
    async getPublicDistricts(stateId) {
        return this.prisma.district.findMany({
            where: {
                isActive: true,
                ...(stateId ? { stateId } : {}),
            },
            orderBy: { name: "asc" },
        });
    }
    async getAdminDistricts(stateId) {
        return this.prisma.district.findMany({
            where: stateId ? { stateId } : {},
            orderBy: { name: "asc" },
            include: {
                state: { select: { id: true, name: true, gujaratiName: true } },
                _count: { select: { talukas: true } },
            },
        });
    }
    async createDistrict(data) {
        return this.prisma.district.create({ data });
    }
    async updateDistrict(id, data) {
        return this.prisma.district.update({ where: { id }, data });
    }
    async deleteDistrict(id) {
        return this.prisma.district.update({
            where: { id },
            data: { isActive: false },
        });
    }
    async getPublicTalukas(districtId) {
        return this.prisma.taluka.findMany({
            where: {
                isActive: true,
                ...(districtId ? { districtId } : {}),
            },
            orderBy: { name: "asc" },
        });
    }
    async getAdminTalukas(districtId) {
        return this.prisma.taluka.findMany({
            where: districtId ? { districtId } : {},
            orderBy: { name: "asc" },
            include: {
                district: { select: { id: true, name: true, gujaratiName: true } },
                _count: { select: { villages: true } },
            },
        });
    }
    async createTaluka(data) {
        return this.prisma.taluka.create({ data });
    }
    async updateTaluka(id, data) {
        return this.prisma.taluka.update({ where: { id }, data });
    }
    async deleteTaluka(id) {
        return this.prisma.taluka.update({
            where: { id },
            data: { isActive: false },
        });
    }
    async getPublicParganas(talukaId) {
        const parganas = await this.prisma.pargana.findMany({
            where: {
                isActive: true,
                ...(talukaId ? { talukas: { some: { talukaId } } } : {}),
            },
            orderBy: { name: "asc" },
            include: {
                _count: { select: { villages: true } },
            },
        });
        return parganas.map((p) => ({
            ...p,
            computedVillageCount: p._count.villages > 0
                ? `${p._count.villages} Gam`
                : p.villageCount || "N/A",
        }));
    }
    async getAdminParganas() {
        const parganas = await this.prisma.pargana.findMany({
            orderBy: { name: "asc" },
            include: {
                talukas: {
                    include: {
                        taluka: { select: { id: true, name: true, gujaratiName: true } },
                    },
                },
                _count: { select: { villages: true } },
            },
        });
        return parganas.map((p) => ({
            ...p,
            computedVillageCount: p._count.villages > 0
                ? `${p._count.villages} Gam`
                : p.villageCount || "N/A",
        }));
    }
    async getPublicVillages(query) {
        const { parganaId, talukaId, search } = query;
        return this.prisma.village.findMany({
            where: {
                isActive: true,
                ...(parganaId ? { parganaId } : {}),
                ...(talukaId ? { talukaId } : {}),
                ...(search
                    ? {
                        OR: [
                            { name: { contains: search } },
                            { gujaratiName: { contains: search } },
                        ],
                    }
                    : {}),
            },
            take: 100,
            orderBy: { name: "asc" },
        });
    }
    async getAdminVillages(query) {
        const { parganaId, talukaId, search } = query;
        return this.prisma.village.findMany({
            where: {
                ...(parganaId ? { parganaId } : {}),
                ...(talukaId ? { talukaId } : {}),
                ...(search
                    ? {
                        OR: [
                            { name: { contains: search } },
                            { gujaratiName: { contains: search } },
                        ],
                    }
                    : {}),
            },
            orderBy: { name: "asc" },
            include: {
                pargana: { select: { id: true, name: true, gujaratiName: true } },
                taluka: { select: { id: true, name: true, gujaratiName: true } },
            },
        });
    }
    async createVillage(data) {
        return this.prisma.village.create({ data });
    }
    async updateVillage(id, data) {
        return this.prisma.village.update({ where: { id }, data });
    }
    async deleteVillage(id) {
        return this.prisma.village.update({
            where: { id },
            data: { isActive: false },
        });
    }
};
exports.LocationsService = LocationsService;
exports.LocationsService = LocationsService = LocationsService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], LocationsService);
//# sourceMappingURL=locations.service.js.map