import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateServicePersonDto } from './dto/create-service-person.dto';
import { UpdateServicePersonDto } from './dto/update-service-person.dto';

@Injectable()
export class SamajServicesService {
  private readonly logger = new Logger(SamajServicesService.name);

  constructor(private readonly prisma: PrismaService) {}

  // ==========================================
  // PUBLIC ENDPOINTS (isActive: true filtering)
  // ==========================================

  async getPublicServices() {
    return this.prisma.samajService.findMany({
      where: { isActive: true },
      orderBy: { createdAt: 'desc' },
      include: {
        _count: {
          select: { persons: { where: { isActive: true } } },
        },
      },
    });
  }

  async getPublicServiceById(id: string) {
    const service = await this.prisma.samajService.findFirst({
      where: { id, isActive: true },
      include: {
        persons: {
          where: { isActive: true },
          orderBy: { createdAt: 'desc' },
        },
      },
    });

    if (!service) {
      throw new NotFoundException(`Samaj Service with ID ${id} not found or inactive`);
    }

    return service;
  }

  async getPublicPersonsByServiceId(serviceId: string) {
    return this.prisma.samajServicePerson.findMany({
      where: {
        serviceId,
        isActive: true,
      },
      include: {
        service: {
          select: {
            id: true,
            title: true,
            category: true,
            icon: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  // ==========================================
  // ADMIN SERVICE ENDPOINTS
  // ==========================================

  async getAllAdminServices() {
    return this.prisma.samajService.findMany({
      orderBy: { createdAt: 'desc' },
      include: {
        _count: {
          select: { persons: true },
        },
      },
    });
  }

  async createService(data: {
    title: string;
    category?: string;
    icon?: string;
    contactPhone?: string;
    contactPerson?: string;
    description?: string;
    isActive?: boolean;
  }) {
    return this.prisma.samajService.create({
      data: {
        title: data.title,
        category: data.category || 'General',
        icon: data.icon || '🤝',
        contactPhone: data.contactPhone || null,
        contactPerson: data.contactPerson || null,
        description: data.description || null,
        isActive: data.isActive !== undefined ? data.isActive : true,
      },
    });
  }

  async updateService(
    id: string,
    data: Partial<{
      title: string;
      category: string;
      icon: string;
      contactPhone: string;
      contactPerson: string;
      description: string;
      isActive: boolean;
    }>
  ) {
    const existing = await this.prisma.samajService.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException(`Samaj Service with ID ${id} not found`);
    }

    return this.prisma.samajService.update({
      where: { id },
      data,
    });
  }

  async deleteService(id: string) {
    const existing = await this.prisma.samajService.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException(`Samaj Service with ID ${id} not found`);
    }

    return this.prisma.samajService.delete({
      where: { id },
    });
  }

  // ==========================================
  // ADMIN SERVICE PERSON ENDPOINTS
  // ==========================================

  async getAllAdminServicePersons(serviceId?: string) {
    return this.prisma.samajServicePerson.findMany({
      where: serviceId ? { serviceId } : undefined,
      include: {
        service: {
          select: {
            id: true,
            title: true,
            category: true,
            icon: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async createServicePerson(dto: CreateServicePersonDto) {
    const service = await this.prisma.samajService.findUnique({
      where: { id: dto.serviceId },
    });

    if (!service) {
      throw new NotFoundException(`Associated Samaj Service with ID ${dto.serviceId} not found`);
    }

    return this.prisma.samajServicePerson.create({
      data: {
        serviceId: dto.serviceId,
        name: dto.name,
        gujaratiName: dto.gujaratiName || null,
        photoUrl: dto.photoUrl || null,
        phone: dto.phone,
        address: dto.address || null,
        city: dto.city || null,
        description: dto.description || null,
        experience: dto.experience || null,
        isActive: dto.isActive !== undefined ? dto.isActive : true,
      },
      include: {
        service: {
          select: {
            id: true,
            title: true,
            category: true,
          },
        },
      },
    });
  }

  async updateServicePerson(id: string, dto: UpdateServicePersonDto) {
    const existing = await this.prisma.samajServicePerson.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException(`Samaj Service Person with ID ${id} not found`);
    }

    if (dto.serviceId) {
      const service = await this.prisma.samajService.findUnique({
        where: { id: dto.serviceId },
      });
      if (!service) {
        throw new NotFoundException(`Associated Samaj Service with ID ${dto.serviceId} not found`);
      }
    }

    return this.prisma.samajServicePerson.update({
      where: { id },
      data: dto,
      include: {
        service: {
          select: {
            id: true,
            title: true,
            category: true,
          },
        },
      },
    });
  }

  async deleteServicePerson(id: string) {
    const existing = await this.prisma.samajServicePerson.findUnique({ where: { id } });
    if (!existing) {
      throw new NotFoundException(`Samaj Service Person with ID ${id} not found`);
    }

    return this.prisma.samajServicePerson.delete({
      where: { id },
    });
  }
}
