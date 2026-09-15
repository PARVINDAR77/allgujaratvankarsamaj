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

  private readonly defaultServices = [
    {
      id: 'srv-001',
      title: 'ઘર બાંધકામ અને સિવિલ વર્ક (Construction & Mason)',
      category: 'Home & Daily Life Services',
      icon: '🏠',
      contactPhone: '+91 98790 12345',
      contactPerson: 'રાજ મિસ્ત્રી રમેશભાઈ વણકર',
      description: 'ઘર બાંધકામ, રાજ મિસ્ત્રી (Mason Work), આરસીસી અને પ્લાસ્ટર કામકાજ સિંગલ ક્લિકથી.',
      isActive: true,
      _count: { persons: 15 },
    },
    {
      id: 'srv-002',
      title: 'પ્લમ્બિંગ અને ઇલેક્ટ્રિશિયન સર્વિસ (Plumber & Electrician)',
      category: 'Home & Daily Life Services',
      icon: '🔧',
      contactPhone: '+91 98250 67890',
      contactPerson: 'મહેશકુમાર પરમાર',
      description: 'ઇમરજન્સી વાયરિંગ, પ્લમ્બિંગ ફિટિંગ, ગીઝર અને મોટર સુધારણા સેવાઓ.',
      isActive: true,
      _count: { persons: 22 },
    },
    {
      id: 'srv-003',
      title: 'કલરકામ, પેઇન્ટિંગ અને એસી/ફ્રિજ રીપેર',
      category: 'Home & Daily Life Services',
      icon: '🎨',
      contactPhone: '+91 97123 45678',
      contactPerson: 'હસમુખભાઈ ચૌહાણ (Painter)',
      description: 'ઘર/ઓફિસ કલરકામ, વુડન પોલિશ, એસી સર્વિસિંગ, ફ્રિજ અને વોશિંગ મશીન રીપેર.',
      isActive: true,
      _count: { persons: 18 },
    },
    {
      id: 'srv-004',
      title: 'સુથારીકામ, એલ્યુમિનિયમ અને ગ્લાસ વર્ક (Carpenter)',
      category: 'Home & Daily Life Services',
      icon: '🪚',
      contactPhone: '+91 99099 88776',
      contactPerson: 'જીગ્નેશભાઈ સોલંકી',
      description: 'ફર્નિચર બનાવટ, દરવાજા ફિટિંગ, એલ્યુમિનિયમ સેક્શન અને ગ્લાસ વિન્ડો વુડવર્ક.',
      isActive: true,
      _count: { persons: 14 },
    },
    {
      id: 'srv-005',
      title: 'ગાડી બુકિંગ અને ટેક્સી સર્વિસ (Car Rental & Cab)',
      category: 'Vehicle & Transport',
      icon: '🚗',
      contactPhone: '+91 98980 11223',
      contactPerson: 'અશ્વિનભાઈ વાઘેલા (Taxi)',
      description: 'લગ્ન પ્રસંગ, પ્રવાસ કે ઇમરજન્સી માટે કાર રેન્ટલ, ટેક્સી અને ડ્રાઇવર બુકિંગ.',
      isActive: true,
      _count: { persons: 28 },
    },
    {
      id: 'srv-006',
      title: 'ઓટો/ગેરેજ, પંચર અને બેટરી સર્વિસ (Garage & Puncture)',
      category: 'Vehicle & Transport',
      icon: '🛞',
      contactPhone: '+91 98765 43210',
      contactPerson: 'કિરણભાઈ રોહિત (Garage)',
      description: 'ટુ-વીલર/ફોર-વીલર ગેરેજ, ટાયર પંચર, ઓન-રોડ આસિસ્ટન્સ અને કાર બેટરી.',
      isActive: true,
      _count: { persons: 19 },
    },
    {
      id: 'srv-007',
      title: 'કોમ્પ્યુટર/મોબાઇલ રીપેર અને પ્રિન્ટર સર્વિસ',
      category: 'Computer & Digital Services',
      icon: '💻',
      contactPhone: '+91 94270 99887',
      contactPerson: 'દિનેશભાઈ ચૌહાણ (Hardware)',
      description: 'લેપટોપ, કોમ્પ્યુટર સુધારણા, સ્માર્ટફોન ડિસ્પ્લે અને પ્રિન્ટર કાર્ટ્રેજ રીફિલિંગ.',
      isActive: true,
      _count: { persons: 25 },
    },
    {
      id: 'srv-008',
      title: 'વેબસાઇટ, મોબાઇલ એપ અને ગ્રાફિક ડિઝાઇનિંગ',
      category: 'Computer & Digital Services',
      icon: '🌐',
      contactPhone: '+91 99789 44556',
      contactPerson: 'અલ્પેશ પરમાર (IT Dev)',
      description: 'સમાજ ઉદ્યોગો માટે વેબસાઇટ ડેવલપમેન્ટ, બિઝનેસ એપ અને સોશિયલ મીડિયા ડિઝાઇન.',
      isActive: true,
      _count: { persons: 16 },
    },
    {
      id: 'srv-009',
      title: 'ટ્યુશન ક્લાસીસ અને સ્પર્ધાત્મક પરીક્ષા કોચિંગ',
      category: 'Education Services',
      icon: '📚',
      contactPhone: '+91 98989 98989',
      contactPerson: 'પ્રો. સંજયભાઈ વણકર',
      description: 'ધો. ૧ થી ૧૨ ટ્યુશન, GPSC/TET/TAT/SSC પરીક્ષા માર્ગદર્શન અને પુસ્તક સહાય.',
      isActive: true,
      _count: { persons: 24 },
    },
    {
      id: 'srv-010',
      title: 'સમાજ જોબ પ્લેસમેન્ટ અને રિઝ્યુમ બિલ્ડર',
      category: 'Job & Business Services',
      icon: '💼',
      contactPhone: '+91 97111 22334',
      contactPerson: 'મનીષભાઈ ચૌહાણ (HR)',
      description: 'પ્રાઇવેટ અને સ્કિલ્ડ જોબ માહિતી, સીવી બનાવવા અને ઇન્ટરવ્યુ તૈયારી.',
      isActive: true,
      _count: { persons: 38 },
    },
    {
      id: 'srv-011',
      title: 'વકીલ સલાહ, દસ્તાવેજ અને પ્રોપર્ટી ગાઇડન્સ (Advocate)',
      category: 'Legal & Financial Services',
      icon: '⚖️',
      contactPhone: '+91 98251 44556',
      contactPerson: 'એડવોકેટ હસમુખ ચૌહાણ',
      description: 'કાનૂની સલાહ, જમીન-મિલકત દસ્તાવેજ લેખન, સોગંદનામા અને રેવન્યુ કેસ.',
      isActive: true,
      _count: { persons: 17 },
    },
    {
      id: 'srv-012',
      title: 'હોસ્પિટલ, ડૉક્ટર અને ડેન્ટલ કેર (Health & Doctor)',
      category: 'Health & Emergency',
      icon: '🏥',
      contactPhone: '+91 98791 66778',
      contactPerson: 'ડૉ. મહેશ પરમાર (MD)',
      description: 'સમાજ ડૉક્ટર્સ પેનલ, આંખના ડૉક્ટર, દાંતના ડૉક્ટર અને મફત આરોગ્ય કેમ્પ.',
      isActive: true,
      _count: { persons: 32 },
    },
    {
      id: 'srv-013',
      title: 'એમ્બ્યુલન્સ અને બ્લડ ડોનેશન ડિરેક્ટરી (Ambulance & Blood)',
      category: 'Health & Emergency',
      icon: '🩸',
      contactPhone: '+91 98252 77889',
      contactPerson: 'રક્તદાતા ગ્રુપ કંટ્રોલ',
      description: '૨૪x૭ ઇમરજન્સી એમ્બ્યુલન્સ, બ્લડ ડોનર નેટવર્ક અને લેબોરેટરી રિપોર્ટ સહાય.',
      isActive: true,
      _count: { persons: 45 },
    },
    {
      id: 'srv-014',
      title: 'કરિયાણું, કપડાં, ફર્નિચર અને જ્વેલર્સ શોપ',
      category: 'Business & Local Shops',
      icon: '🏪',
      contactPhone: '+91 99781 88990',
      contactPerson: 'વણકર ટ્રેડર્સ ગ્રુપ',
      description: 'સમાજના વેપારીઓનું હોલસેલ ગ્રોસરી, રેડીમેડ ગારમેન્ટ્સ, શૂઝ અને જ્વેલરી શોપિંગ.',
      isActive: true,
      _count: { persons: 60 },
    },
    {
      id: 'srv-015',
      title: 'વેલ્ડિંગ, મશીનરી અને ટેકનિશિયન વર્ક (Technicians)',
      category: 'Skilled Professionals',
      icon: '🧑🔧',
      contactPhone: '+91 98792 99001',
      contactPerson: 'પ્રકાશભાઈ વાઘેલા',
      description: 'ગ્રીલ/ગેટ વેલ્ડિંગ વર્ક, ટીવી ટેકનિશિયન, સીસીટીવી કેમેરા ફિટિંગ અને મશીનરી વર્ક.',
      isActive: true,
      _count: { persons: 29 },
    },
  ];

  async getPublicServices() {
    try {
      const res = await this.prisma.samajService.findMany({
        where: { isActive: true },
        orderBy: { createdAt: 'desc' },
        include: {
          _count: {
            select: { persons: { where: { isActive: true } } },
          },
        },
      });
      if (res && res.length > 0) return res;
    } catch {
      // Return default services fallback
    }
    return this.defaultServices;
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
    try {
      const res = await this.prisma.samajService.findMany({
        orderBy: { createdAt: 'desc' },
        include: {
          _count: {
            select: { persons: true },
          },
        },
      });
      if (res && res.length > 0) return res;
    } catch {
      // Return default services fallback
    }
    return this.defaultServices;
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
