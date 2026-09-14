import { Injectable, Logger, NotFoundException, BadRequestException } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";

@Injectable()
export class LocationsService {
  private readonly logger = new Logger(LocationsService.name);

  constructor(private readonly prisma: PrismaService) {}

  // ==================== SEED INITIAL VERIFIED GEOGRAPHY ====================
  async seedInitialLocations() {
    try {
      // 1. Seed State: Gujarat
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

      // 2. Seed Districts
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

      // 3. Seed Idar Taluka under Sabarkantha
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

        // Link Pargana 35 Gam Pargana to Idar Taluka
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
    } catch (err: any) {
      this.logger.warn("Location seeding warning:", err?.message);
    }
  }

  // ==================== STATES API ====================
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

  async createState(data: { name: string; gujaratiName?: string; code: string; isActive?: boolean }) {
    const existing = await this.prisma.state.findUnique({ where: { code: data.code } });
    if (existing) throw new BadRequestException(`State with code ${data.code} already exists`);

    return this.prisma.state.create({ data });
  }

  async updateState(id: string, data: Partial<{ name: string; gujaratiName: string; code: string; isActive: boolean }>) {
    return this.prisma.state.update({ where: { id }, data });
  }

  async deleteState(id: string) {
    // Soft delete to protect profile relationships
    return this.prisma.state.update({ where: { id }, data: { isActive: false } });
  }

  // ==================== DISTRICTS API ====================
  async getPublicDistricts(stateId?: string) {
    return this.prisma.district.findMany({
      where: {
        isActive: true,
        ...(stateId ? { stateId } : {}),
      },
      orderBy: { name: "asc" },
    });
  }

  async getAdminDistricts(stateId?: string) {
    return this.prisma.district.findMany({
      where: stateId ? { stateId } : {},
      orderBy: { name: "asc" },
      include: {
        state: { select: { id: true, name: true, gujaratiName: true } },
        _count: { select: { talukas: true } },
      },
    });
  }

  async createDistrict(data: { stateId: string; name: string; gujaratiName?: string; code?: string; isActive?: boolean }) {
    return this.prisma.district.create({ data });
  }

  async updateDistrict(id: string, data: Partial<{ stateId: string; name: string; gujaratiName: string; code: string; isActive: boolean }>) {
    return this.prisma.district.update({ where: { id }, data });
  }

  async deleteDistrict(id: string) {
    return this.prisma.district.update({ where: { id }, data: { isActive: false } });
  }

  // ==================== TALUKAS API ====================
  async getPublicTalukas(districtId?: string) {
    return this.prisma.taluka.findMany({
      where: {
        isActive: true,
        ...(districtId ? { districtId } : {}),
      },
      orderBy: { name: "asc" },
    });
  }

  async getAdminTalukas(districtId?: string) {
    return this.prisma.taluka.findMany({
      where: districtId ? { districtId } : {},
      orderBy: { name: "asc" },
      include: {
        district: { select: { id: true, name: true, gujaratiName: true } },
        _count: { select: { villages: true } },
      },
    });
  }

  async createTaluka(data: { districtId: string; name: string; gujaratiName?: string; code?: string; isActive?: boolean }) {
    return this.prisma.taluka.create({ data });
  }

  async updateTaluka(id: string, data: Partial<{ districtId: string; name: string; gujaratiName: string; code: string; isActive: boolean }>) {
    return this.prisma.taluka.update({ where: { id }, data });
  }

  async deleteTaluka(id: string) {
    return this.prisma.taluka.update({ where: { id }, data: { isActive: false } });
  }

  // ==================== PARGANAS API (DYNAMIC VILLAGE COUNT) ====================
  async getPublicParganas(talukaId?: string) {
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
      computedVillageCount: p._count.villages > 0 ? `${p._count.villages} Gam` : p.villageCount || "N/A",
    }));
  }

  async getAdminParganas() {
    const parganas = await this.prisma.pargana.findMany({
      orderBy: { name: "asc" },
      include: {
        talukas: { include: { taluka: { select: { id: true, name: true, gujaratiName: true } } } },
        _count: { select: { villages: true } },
      },
    });

    return parganas.map((p) => ({
      ...p,
      computedVillageCount: p._count.villages > 0 ? `${p._count.villages} Gam` : p.villageCount || "N/A",
    }));
  }

  // ==================== VILLAGES API (SEARCHABLE & PAGINATED) ====================
  async getPublicVillages(query: { parganaId?: string; talukaId?: string; search?: string }) {
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

  async getAdminVillages(query: { parganaId?: string; talukaId?: string; search?: string }) {
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

  async createVillage(data: {
    parganaId?: string;
    talukaId?: string;
    name: string;
    gujaratiName?: string;
    code?: string;
    pincode?: string;
    isActive?: boolean;
  }) {
    return this.prisma.village.create({ data });
  }

  async updateVillage(
    id: string,
    data: Partial<{
      parganaId: string;
      talukaId: string;
      name: string;
      gujaratiName: string;
      code: string;
      pincode: string;
      isActive: boolean;
    }>
  ) {
    return this.prisma.village.update({ where: { id }, data });
  }

  async deleteVillage(id: string) {
    return this.prisma.village.update({ where: { id }, data: { isActive: false } });
  }
}
