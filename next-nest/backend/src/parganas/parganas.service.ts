import { Injectable, Logger, NotFoundException } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";

@Injectable()
export class ParganasService {
  private readonly logger = new Logger(ParganasService.name);

  constructor(private readonly prisma: PrismaService) {}

  private readonly initialParganas = [
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
    } catch (err: any) {
      this.logger.warn("DB connection fallback for public parganas", err?.message);
      return this.initialParganas.map((p, idx) => ({ id: `pg-${idx + 1}`, ...p }));
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
    } catch (err: any) {
      this.logger.warn("DB connection fallback for admin parganas", err?.message);
      return this.initialParganas.map((p, idx) => ({ id: `pg-${idx + 1}`, ...p }));
    }
  }

  async createPargana(data: {
    name: string;
    gujaratiName?: string;
    code?: string;
    description?: string;
    villageCount?: string;
    districtRegion?: string;
    leaderName?: string;
    contactPhone?: string;
    totalCount?: number;
    isActive?: boolean;
  }) {
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

  async updatePargana(
    id: string,
    data: Partial<{
      name: string;
      gujaratiName: string;
      code: string;
      description: string;
      villageCount: string;
      districtRegion: string;
      leaderName: string;
      contactPhone: string;
      totalCount: number;
      isActive: boolean;
    }>
  ) {
    const existing = await this.prisma.pargana.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException(`Pargana with ID ${id} not found`);
    }

    return this.prisma.pargana.update({
      where: { id },
      data,
    });
  }

  async deletePargana(id: string) {
    const existing = await this.prisma.pargana.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException(`Pargana with ID ${id} not found`);
    }

    return this.prisma.pargana.delete({ where: { id } });
  }
}
