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
var ParganasService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.ParganasService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let ParganasService = ParganasService_1 = class ParganasService {
    constructor(prisma) {
        this.prisma = prisma;
        this.logger = new common_1.Logger(ParganasService_1.name);
        this.initialParganas = [
            {
                name: "35 Gam Pargana (Idar)",
                gujaratiName: "૩૫ ગામ પરગણું (ઈડર)",
                code: "PARGANA_35_IDAR",
                description: "ઈડર, સાબરકાંઠા અને અરાવલ્લી પંથકના વણકર સમાજ ગામો",
                villageCount: "35 Gam",
                districtRegion: "Idar, Sabarkantha, Aravalli",
                leaderName: "Rameshbhai Vankar (Idar)",
                contactPhone: "+91 98765 43210",
                totalCount: 485,
                isActive: true,
            },
            {
                name: "27 Gam Pargana (Mehsana & Patan)",
                gujaratiName: "૨૭ ગામ પરગણું (મહેસાણા-પાટણ)",
                code: "PARGANA_27",
                description: "ઉત્તર ગુજરાત મહેસાણા, પાટણ અને સિદ્ધપુર પંથક",
                villageCount: "27 Gam",
                districtRegion: "Mehsana, Patan, Banaskantha",
                leaderName: "Kishorbhai Parmar",
                contactPhone: "+91 98765 43211",
                totalCount: 320,
                isActive: true,
            },
            {
                name: "16 Gam Pargana (Charotar)",
                gujaratiName: "૧૬ ગામ પરગણું (ચરોતર)",
                code: "PARGANA_16",
                description: "આણંદ, ખેડા અને નડિયાદ ચરોતર પંથક",
                villageCount: "16 Gam",
                districtRegion: "Anand, Kheda, Nadiad",
                leaderName: "Pravinbhai Solanki",
                contactPhone: "+91 98765 43212",
                totalCount: 210,
                isActive: true,
            },
            {
                name: "14 Gam Pargana (South Gujarat)",
                gujaratiName: "૧૪ ગામ પરગણું (દક્ષિણ ગુજરાત)",
                code: "PARGANA_14",
                description: "સુરત, નવસારી, વલસાડ અને ભરૂચ પંથક",
                villageCount: "14 Gam",
                districtRegion: "Surat, Navsari, Valsad, Bharuch",
                leaderName: "Dineshbhai Vankar",
                contactPhone: "+91 98765 43213",
                totalCount: 140,
                isActive: true,
            },
            {
                name: "Chorasi Pargana (84 Gam)",
                gujaratiName: "ચોરાસી (૮૪ ગામ) પરગણું",
                code: "PARGANA_CHORASI",
                description: "અમદાવાદ, દસક્રોઈ અને ગાંધીનગર વિસ્તાર",
                villageCount: "84 Gam",
                districtRegion: "Ahmedabad, Gandhinagar",
                leaderName: "Harshadbhai Vankar",
                contactPhone: "+91 98765 43214",
                totalCount: 290,
                isActive: true,
            },
            {
                name: "Betalisi Pargana (42 Gam)",
                gujaratiName: "બેતાલીસી (૪૨ ગામ) પરગણું",
                code: "PARGANA_BETALISI",
                description: "મહેમદાબાદ, કલોલ અને કડી પંથક",
                villageCount: "42 Gam",
                districtRegion: "Mahemdabad, Kalol, Kadi",
                leaderName: "Jigneshabhai Chauhan",
                contactPhone: "+91 98765 43215",
                totalCount: 175,
                isActive: true,
            },
            {
                name: "Chhagaon Pargana (06 Gam)",
                gujaratiName: "છગાંવ (૦૬ ગામ) પરગણું",
                code: "PARGANA_CHHAGAON",
                description: "વડોદરા અને ડભોઈ પંથક",
                villageCount: "06 Gam",
                districtRegion: "Vadodara, Dabhoi",
                leaderName: "Vipulbhai Vankar",
                contactPhone: "+91 98765 43216",
                totalCount: 95,
                isActive: true,
            },
            {
                name: "Sattavisi Pargana (27 Gam Saurashtra)",
                gujaratiName: "સત્તાવીસી પરગણું (સૌરાષ્ટ્ર)",
                code: "PARGANA_SATTAVISI",
                description: "રાજકોટ, જૂનાગઢ અને જામનગર પંથક",
                villageCount: "27 Gam",
                districtRegion: "Rajkot, Junagadh, Jamnagar",
                leaderName: "Rohitbhai Rathod",
                contactPhone: "+91 98765 43217",
                totalCount: 160,
                isActive: true,
            },
        ];
    }
    async getPublicParganas() {
        try {
            const parganas = await this.prisma.pargana.findMany({
                where: { isActive: true },
                orderBy: { name: "asc" },
            });
            if (parganas.length === 0) {
                await this.prisma.pargana.createMany({
                    data: this.initialParganas,
                    skipDuplicates: true,
                });
                return this.prisma.pargana.findMany({
                    where: { isActive: true },
                    orderBy: { name: "asc" },
                });
            }
            return parganas;
        }
        catch (err) {
            this.logger.warn("DB connection fallback for public parganas", err?.message);
            return this.initialParganas.map((p, idx) => ({
                id: `pg-${idx + 1}`,
                ...p,
            }));
        }
    }
    async getAllAdminParganas() {
        try {
            const parganas = await this.prisma.pargana.findMany({
                orderBy: { name: "asc" },
            });
            if (parganas.length === 0) {
                await this.prisma.pargana.createMany({
                    data: this.initialParganas,
                    skipDuplicates: true,
                });
                return this.prisma.pargana.findMany({ orderBy: { name: "asc" } });
            }
            return parganas;
        }
        catch (err) {
            this.logger.warn("DB connection fallback for admin parganas", err?.message);
            return this.initialParganas.map((p, idx) => ({
                id: `pg-${idx + 1}`,
                ...p,
            }));
        }
    }
    async createPargana(data) {
        return this.prisma.pargana.create({
            data: {
                name: data.name,
                gujaratiName: data.gujaratiName || null,
                code: data.code || null,
                description: data.description || null,
                villageCount: data.villageCount || null,
                districtRegion: data.districtRegion || null,
                leaderName: data.leaderName || null,
                contactPhone: data.contactPhone || null,
                totalCount: data.totalCount || 0,
                isActive: data.isActive !== undefined ? data.isActive : true,
            },
        });
    }
    async updatePargana(id, data) {
        const existing = await this.prisma.pargana.findUnique({ where: { id } });
        if (!existing) {
            throw new common_1.NotFoundException(`Pargana with ID ${id} not found`);
        }
        return this.prisma.pargana.update({
            where: { id },
            data,
        });
    }
    async deletePargana(id) {
        const existing = await this.prisma.pargana.findUnique({ where: { id } });
        if (!existing) {
            throw new common_1.NotFoundException(`Pargana with ID ${id} not found`);
        }
        return this.prisma.pargana.delete({ where: { id } });
    }
};
exports.ParganasService = ParganasService;
exports.ParganasService = ParganasService = ParganasService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], ParganasService);
//# sourceMappingURL=parganas.service.js.map