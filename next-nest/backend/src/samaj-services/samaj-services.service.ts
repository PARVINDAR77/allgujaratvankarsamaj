import { Injectable, Logger, NotFoundException } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";
import { CreateServicePersonDto } from "./dto/create-service-person.dto";
import { UpdateServicePersonDto } from "./dto/update-service-person.dto";

@Injectable()
export class SamajServicesService {
  private readonly logger = new Logger(SamajServicesService.name);

  constructor(private readonly prisma: PrismaService) {}

  // ==========================================
  // PUBLIC ENDPOINTS (isActive: true filtering)
  // ==========================================

  private readonly defaultServices = [
    {
      id: "srv-001",
      title: "ઘર બાંધકામ અને સિવિલ વર્ક (Construction & Mason)",
      category: "Home & Daily Life Services",
      icon: "🏠",
      contactPhone: "+91 98790 12345",
      contactPerson: "રાજ મિસ્ત્રી રમેશભાઈ વણકર",
      description:
        "ઘર બાંધકામ, રાજ મિસ્ત્રી (Mason Work), આરસીસી અને પ્લાસ્ટર કામકાજ સિંગલ ક્લિકથી.",
      isActive: true,
      _count: { persons: 15 },
    },
    {
      id: "srv-002",
      title: "પ્લમ્બિંગ અને ઇલેક્ટ્રિશિયન સર્વિસ (Plumber & Electrician)",
      category: "Home & Daily Life Services",
      icon: "🔧",
      contactPhone: "+91 98250 67890",
      contactPerson: "મહેશકુમાર પરમાર",
      description:
        "ઇમરજન્સી વાયરિંગ, પ્લમ્બિંગ ફિટિંગ, ગીઝર અને મોટર સુધારણા સેવાઓ.",
      isActive: true,
      _count: { persons: 22 },
    },
    {
      id: "srv-003",
      title: "કલરકામ, પેઇન્ટિંગ અને એસી/ફ્રિજ રીપેર",
      category: "Home & Daily Life Services",
      icon: "🎨",
      contactPhone: "+91 97123 45678",
      contactPerson: "હસમુખભાઈ ચૌહાણ (Painter)",
      description:
        "ઘર/ઓફિસ કલરકામ, વુડન પોલિશ, એસી સર્વિસિંગ, ફ્રિજ અને વોશિંગ મશીન રીપેર.",
      isActive: true,
      _count: { persons: 18 },
    },
    {
      id: "srv-004",
      title: "સુથારીકામ, એલ્યુમિનિયમ અને ગ્લાસ વર્ક (Carpenter)",
      category: "Home & Daily Life Services",
      icon: "🪚",
      contactPhone: "+91 99099 88776",
      contactPerson: "જીગ્નેશભાઈ સોલંકી",
      description:
        "ફર્નિચર બનાવટ, દરવાજા ફિટિંગ, એલ્યુમિનિયમ સેક્શન અને ગ્લાસ વિન્ડો વુડવર્ક.",
      isActive: true,
      _count: { persons: 14 },
    },
    {
      id: "srv-005",
      title: "ગાડી બુકિંગ અને ટેક્સી સર્વિસ (Car Rental & Cab)",
      category: "Vehicle & Transport",
      icon: "🚗",
      contactPhone: "+91 98980 11223",
      contactPerson: "અશ્વિનભાઈ વાઘેલા (Taxi)",
      description:
        "લગ્ન પ્રસંગ, પ્રવાસ કે ઇમરજન્સી માટે કાર રેન્ટલ, ટેક્સી અને ડ્રાઇવર બુકિંગ.",
      isActive: true,
      _count: { persons: 28 },
    },
    {
      id: "srv-006",
      title: "ઓટો/ગેરેજ, પંચર અને બેટરી સર્વિસ (Garage & Puncture)",
      category: "Vehicle & Transport",
      icon: "🛞",
      contactPhone: "+91 98765 43210",
      contactPerson: "કિરણભાઈ રોહિત (Garage)",
      description:
        "ટુ-વીલર/ફોર-વીલર ગેરેજ, ટાયર પંચર, ઓન-રોડ આસિસ્ટન્સ અને કાર બેટરી.",
      isActive: true,
      _count: { persons: 19 },
    },
    {
      id: "srv-007",
      title: "કોમ્પ્યુટર/મોબાઇલ રીપેર અને પ્રિન્ટર સર્વિસ",
      category: "Computer & Digital Services",
      icon: "💻",
      contactPhone: "+91 94270 99887",
      contactPerson: "દિનેશભાઈ ચૌહાણ (Hardware)",
      description:
        "લેપટોપ, કોમ્પ્યુટર સુધારણા, સ્માર્ટફોન ડિસ્પ્લે અને પ્રિન્ટર કાર્ટ્રેજ રીફિલિંગ.",
      isActive: true,
      _count: { persons: 25 },
    },
    {
      id: "srv-008",
      title: "વેબસાઇટ, મોબાઇલ એપ અને ગ્રાફિક ડિઝાઇનિંગ",
      category: "Computer & Digital Services",
      icon: "🌐",
      contactPhone: "+91 99789 44556",
      contactPerson: "અલ્પેશ પરમાર (IT Dev)",
      description:
        "સમાજ ઉદ્યોગો માટે વેબસાઇટ ડેવલપમેન્ટ, બિઝનેસ એપ અને સોશિયલ મીડિયા ડિઝાઇન.",
      isActive: true,
      _count: { persons: 16 },
    },
    {
      id: "srv-009",
      title: "શિક્ષણ સેવાઓ અને નર્સિંગ એકેડેમી (Education Services & Coaching)",
      category: "Education Services",
      icon: "🎓",
      contactPhone: "+91 92654 76537",
      contactPerson: "વામિકા નર્સિંગ એકેડેમી (Vamika Nursing Academy - Idar)",
      description:
        "નર્સિંગ એકેડેમી, સ્ટાફ નર્સ કોચિંગ, સ્પર્ધાત્મક પરીક્ષા માર્ગદર્શન, ધો. ૧ થી ૧૨ ટ્યુશન અને ઉચ્ચ શિક્ષણ સહાય.",
      isActive: true,
      _count: { persons: 25 },
    },
    {
      id: "srv-010",
      title: "સમાજ જોબ પ્લેસમેન્ટ અને રિઝ્યુમ બિલ્ડર",
      category: "Job & Business Services",
      icon: "💼",
      contactPhone: "+91 97111 22334",
      contactPerson: "મનીષભાઈ ચૌહાણ (HR)",
      description:
        "પ્રાઇવેટ અને સ્કિલ્ડ જોબ માહિતી, સીવી બનાવવા અને ઇન્ટરવ્યુ તૈયારી.",
      isActive: true,
      _count: { persons: 38 },
    },
    {
      id: "srv-011",
      title: "વકીલ સલાહ, દસ્તાવેજ અને પ્રોપર્ટી ગાઇડન્સ (Advocate)",
      category: "Legal & Financial Services",
      icon: "⚖️",
      contactPhone: "+91 98251 44556",
      contactPerson: "એડવોકેટ હસમુખ ચૌહાણ",
      description:
        "કાનૂની સલાહ, જમીન-મિલકત દસ્તાવેજ લેખન, સોગંદનામા અને રેવન્યુ કેસ.",
      isActive: true,
      _count: { persons: 17 },
    },
    {
      id: "srv-012",
      title: "હોસ્પિટલ, ડૉક્ટર અને ડેન્ટલ કેર (Health & Doctor)",
      category: "Health & Emergency",
      icon: "🏥",
      contactPhone: "+91 98791 66778",
      contactPerson: "ડૉ. મહેશ પરમાર (MD)",
      description:
        "સમાજ ડૉક્ટર્સ પેનલ, આંખના ડૉક્ટર, દાંતના ડૉક્ટર અને મફત આરોગ્ય કેમ્પ.",
      isActive: true,
      _count: { persons: 32 },
    },
    {
      id: "srv-013",
      title: "એમ્બ્યુલન્સ અને બ્લડ ડોનેશન ડિરેક્ટરી (Ambulance & Blood)",
      category: "Health & Emergency",
      icon: "🩸",
      contactPhone: "+91 98252 77889",
      contactPerson: "રક્તદાતા ગ્રુપ કંટ્રોલ",
      description:
        "૨૪x૭ ઇમરજન્સી એમ્બ્યુલન્સ, બ્લડ ડોનર નેટવર્ક અને લેબોરેટરી રિપોર્ટ સહાય.",
      isActive: true,
      _count: { persons: 45 },
    },
    {
      id: "srv-014",
      title: "કરિયાણું, કપડાં, ફર્નિચર અને જ્વેલર્સ શોપ",
      category: "Business & Local Shops",
      icon: "🏪",
      contactPhone: "+91 99781 88990",
      contactPerson: "વણકર ટ્રેડર્સ ગ્રુપ",
      description:
        "સમાજના વેપારીઓનું હોલસેલ ગ્રોસરી, રેડીમેડ ગારમેન્ટ્સ, શૂઝ અને જ્વેલરી શોપિંગ.",
      isActive: true,
      _count: { persons: 60 },
    },
    {
      id: "srv-015",
      title: "વેલ્ડિંગ, મશીનરી અને ટેકનિશિયન વર્ક (Technicians)",
      category: "Skilled Professionals",
      icon: "🧑🔧",
      contactPhone: "+91 98792 99001",
      contactPerson: "પ્રકાશભાઈ વાઘેલા",
      description:
        "ગ્રીલ/ગેટ વેલ્ડિંગ વર્ક, ટીવી ટેકનિશિયન, સીસીટીવી કેમેરા ફિટિંગ અને મશીનરી વર્ક.",
      isActive: true,
      _count: { persons: 29 },
    },
  ];

  // ==========================================
  // RETROACTIVE BUSINESS PROFILE AUTO-SYNC
  // ==========================================
  async syncMissingBusinessProfiles() {
    try {
      // 1. Ensure core Education Services exist in DB
      let eduService = await this.prisma.samajService.findFirst({
        where: {
          OR: [
            { title: { contains: "Education Services" } },
            { title: { contains: "શિક્ષણ સેવાઓ" } },
            { slug: "education-services" },
          ],
        },
      });

      if (!eduService) {
        eduService = await this.prisma.samajService.create({
          data: {
            title: "શિક્ષણ સેવાઓ અને એકેડેમી (Education Services)",
            slug: "education-services",
            category: "Education Services",
            icon: "🎓",
            contactPhone: "9265476537",
            contactPerson: "વામિકા નર્સિંગ એકેડેમી (Vamika Nursing Academy)",
            description:
              "નર્સિંગ પ્રવેશ, કોચિંગ ક્લાસીસ, સ્પર્ધાત્મક પરીક્ષા માર્ગદર્શન અને શિક્ષણ સહાય સેવાઓ.",
            isActive: true,
            sortOrder: 1,
          },
        });
        this.logger.log(`Created main Education Services: ${eduService.id}`);
      }

      // Also ensure Tuition / Coaching exists
      let tuitionService = await this.prisma.samajService.findFirst({
        where: {
          OR: [
            { title: { contains: "Tuition" } },
            { title: { contains: "ટ્યુશન" } },
            { title: { contains: "Coaching" } },
          ],
        },
      });

      if (!tuitionService) {
        tuitionService = await this.prisma.samajService.create({
          data: {
            title: "ટ્યુશન અને કોચિંગ ક્લાસીસ (Tuition / Coaching)",
            slug: "tuition-coaching-classes",
            category: "Education Services",
            icon: "📚",
            contactPhone: "9265476537",
            contactPerson: "વામિકા નર્સિંગ એકેડેમી",
            description:
              "નર્સિંગ, ધોરણ ૧ થી ૧૨ ટ્યુશન, GPSC/TET/TAT અને સ્પર્ધાત્મક પરીક્ષા કોચિંગ.",
            isActive: true,
            sortOrder: 2,
          },
        });
      }

      // 2. Fetch all profiles from MatrimonialProfile that are businesses or professionals
      const profiles = await this.prisma.matrimonialProfile.findMany({
        where: {
          status: { not: "REJECTED" as any },
          OR: [
            { occupation: { contains: "Business" } },
            { occupation: { contains: "Self" } },
            { occupation: { contains: "વેપાર" } },
            { occupation: { contains: "સ્વરોજગાર" } },
            { businessIndustry: { not: null } },
            { businessService: { not: null } },
            { firstName: { contains: "VAMIKA" } },
            { firstName: { contains: "NURSING" } },
            { firstName: { contains: "ACADEMY" } },
            { organizationName: { not: null } },
          ],
        },
        include: {
          user: {
            select: { phone: true, email: true },
          },
        },
      });

      for (const p of profiles) {
        const occ = (p.occupation || "").toLowerCase();
        const bizInd = (p.businessIndustry || "").toLowerCase();
        const bizSvc = (p.businessService || "").toLowerCase();
        const orgName = (p.organizationName || "").trim();
        const fName = (p.firstName || "").trim();
        const lName = (p.lastName || "").trim();
        const combined = `${fName} ${lName} ${orgName} ${p.about || ""} ${bizInd} ${bizSvc}`.toLowerCase();

        const isVamika =
          combined.includes("vamika") ||
          combined.includes("nursing") ||
          combined.includes("academy") ||
          (p.user?.phone && p.user.phone.includes("9265476537")) ||
          (p.altPhone && p.altPhone.includes("9265476537")) ||
          (p.fatherContact && p.fatherContact.includes("9265476537"));

        const isEducation =
          isVamika ||
          bizInd.includes("edu") ||
          bizInd.includes("શિક્ષણ") ||
          bizSvc.includes("edu") ||
          bizSvc.includes("coaching") ||
          bizSvc.includes("tuition") ||
          bizSvc.includes("શિક્ષણ");

        const phone = (
          p.user?.phone ||
          p.altPhone ||
          p.fatherContact ||
          p.guardianContact ||
          (isVamika ? "9265476537" : "") ||
          "સંપર્ક ઉપલબ્ધ"
        ).trim();

        const city = p.city || (isVamika ? "Idar" : (p.nativePlace || "Gujarat"));
        const address =
          p.addressLine ||
          p.nativePlace ||
          (isVamika ? "Idar, 35 Gam Pargana" : (city ? `${city}, Gujarat` : "Gujarat"));

        let displayName = orgName || `${fName} ${lName}`.trim();
        let gujaratiName = orgName || `${fName} ${lName}`.trim();
        let description = p.about || `${displayName} - સમાજ અધિકૃત વ્યાપારી સેવા`;

        if (isVamika) {
          displayName = "VAMIKA NURSING ACADEMY (IDAR)";
          gujaratiName = "વામિકા નર્સિંગ એકેડેમી - ઇડર (શિક્ષણ & કોચિંગ સેવાઓ)";
          description =
            "વામિકા નર્સિંગ એકેડેમી - ઇડર. નર્સિંગ એકેડેમી, સ્ટાફ નર્સ કોચિંગ, સ્પર્ધાત્મક પરીક્ષા માર્ગદર્શન અને ઉચ્ચ શિક્ષણ સેવાઓ.";
        }

        const targetServiceIds: string[] = [];
        if (isEducation) {
          if (eduService?.id) targetServiceIds.push(eduService.id);
          if (tuitionService?.id) targetServiceIds.push(tuitionService.id);
        } else {
          const matched = await this.prisma.samajService.findFirst({
            where: {
              OR: [
                { title: { contains: p.businessService || orgName || "General" } },
                { category: { contains: p.businessIndustry || "Business" } },
              ],
              isActive: true,
            },
          });
          if (matched) targetServiceIds.push(matched.id);
        }

        for (const sId of targetServiceIds) {
          const existing = await this.prisma.samajServicePerson.findFirst({
            where: {
              serviceId: sId,
              OR: [
                { userId: p.userId },
                { phone: phone },
                ...(isVamika ? [{ name: { contains: "VAMIKA" } }] : []),
              ],
            },
          });

          let parsedPhoto = p.photoUrl;
          if (!parsedPhoto && p.photos) {
            try {
              const photoArr = JSON.parse(p.photos);
              if (Array.isArray(photoArr) && photoArr.length > 0) {
                parsedPhoto = photoArr[0];
              }
            } catch (_) {}
          }

          const personPayload = {
            serviceId: sId,
            userId: p.userId,
            name: displayName,
            gujaratiName: gujaratiName,
            phone: phone,
            city: city,
            address: address,
            description: description,
            experience: isVamika
              ? "અધિકૃત શૈક્ષણિક એકેડેમી (Nursing & Education)"
              : (p.designation || "અનુભવી વ્યાવસાયિક"),
            photoUrl: parsedPhoto || null,
            districtId: p.districtId || null,
            talukaId: p.talukaId || null,
            villageId: p.villageId || null,
            isActive: true,
          };

          if (existing) {
            await this.prisma.samajServicePerson.update({
              where: { id: existing.id },
              data: personPayload,
            });
          } else {
            await this.prisma.samajServicePerson.create({
              data: personPayload,
            });
          }
        }
      }

      // Guarantee Vamika Nursing Academy person exists in eduService and tuitionService
      const targetIds = [eduService?.id, tuitionService?.id].filter(Boolean) as string[];
      for (const sId of targetIds) {
        const found = await this.prisma.samajServicePerson.findFirst({
          where: {
            serviceId: sId,
            OR: [
              { phone: { contains: "9265476537" } },
              { name: { contains: "VAMIKA" } },
            ],
          },
        });
        if (!found) {
          await this.prisma.samajServicePerson.create({
            data: {
              serviceId: sId,
              name: "VAMIKA NURSING ACADEMY (IDAR)",
              gujaratiName: "વામિકા નર્સિંગ એકેડેમી - ઇડર (શિક્ષણ & કોચિંગ સેવાઓ)",
              phone: "9265476537",
              city: "ઇડર (Idar)",
              address: "ઇડર, ૩૫ ગામ પરગણા, સાબરકાંઠા",
              description:
                "વામિકા નર્સિંગ એકેડેમી - ઇડર. નર્સિંગ એકેડેમી, સ્ટાફ નર્સ કોચિંગ, સ્પર્ધાત્મક પરીક્ષા માર્ગદર્શન અને ઉચ્ચ શિક્ષણ સેવાઓ.",
              experience: "અધિકૃત શૈક્ષણિક એકેડેમી (Education Services)",
              isActive: true,
            },
          });
        }
      }
    } catch (err: any) {
      this.logger.warn(`syncMissingBusinessProfiles warning: ${err?.message || err}`);
    }
  }

  async getPublicServices(search?: string, category?: string) {
    try {
      await this.syncMissingBusinessProfiles();

      const whereClause: any = { isActive: true };
      if (category && category.trim()) {
        whereClause.category = { contains: category.trim() };
      }
      if (search && search.trim()) {
        const q = search.trim();
        whereClause.OR = [
          { title: { contains: q } },
          { description: { contains: q } },
          { category: { contains: q } },
          { slug: { contains: q } },
          { contactPhone: { contains: q } },
          { contactPerson: { contains: q } },
        ];
      }

      const res = await this.prisma.samajService.findMany({
        where: whereClause,
        orderBy: { createdAt: "desc" },
        include: {
          _count: {
            select: { persons: { where: { isActive: true } } },
          },
        },
      });
      return res;
    } catch (error) {
      this.logger.warn("DB unavailable, returning hardcoded fallback services");
      let fallback = this.defaultServices;
      if (category && category.trim()) {
        fallback = fallback.filter((s) =>
          s.category.toLowerCase().includes(category.trim().toLowerCase()),
        );
      }
      if (search && search.trim()) {
        const q = search.trim().toLowerCase();
        fallback = fallback.filter(
          (s) =>
            s.title.toLowerCase().includes(q) ||
            (s.description && s.description.toLowerCase().includes(q)) ||
            s.category.toLowerCase().includes(q) ||
            (s.contactPhone && s.contactPhone.includes(q)) ||
            (s.contactPerson && s.contactPerson.toLowerCase().includes(q)),
        );
      }
      return fallback;
    }
  }

  async getPublicServiceById(id: string) {
    await this.syncMissingBusinessProfiles();

    const service = await this.prisma.samajService.findFirst({
      where: { id, isActive: true },
      include: {
        persons: {
          where: { isActive: true },
          orderBy: { createdAt: "desc" },
        },
      },
    });

    if (!service) {
      const fallback = this.defaultServices.find((s) => s.id === id);
      if (fallback) {
        const fallbackPersons = this.defaultPersons.filter(
          (p) => p.serviceId === id,
        );
        return {
          ...fallback,
          persons: fallbackPersons,
        };
      }
      throw new NotFoundException(
        `Samaj Service with ID ${id} not found or inactive`,
      );
    }

    if (!service.persons || service.persons.length === 0) {
      const fallbackPersons = this.defaultPersons.filter(
        (p) =>
          p.serviceId === id ||
          (service.category?.toLowerCase().includes("edu") &&
            p.service?.category === "Education Services"),
      );
      if (fallbackPersons.length > 0) {
        return {
          ...service,
          persons: fallbackPersons,
        };
      }
    }

    return service;
  }

  private readonly defaultPersons = [
    {
      id: "sp-vamika-01",
      serviceId: "srv-009",
      name: "VAMIKA NURSING ACADEMY (IDAR)",
      gujaratiName: "વામિકા નર્સિંગ એકેડેમી - ઇડર (શિક્ષણ સેવાઓ)",
      photoUrl: "https://picsum.photos/seed/nursing1/200/200",
      phone: "+91 92654 76537",
      address: "ઇડર, ૩૫ ગામ પરગણા, સાબરકાંઠા",
      city: "ઇડર (Idar)",
      description:
        "વામિકા નર્સિંગ એકેડેમી - ઇડર. નર્સિંગ એકેડેમી, સ્ટાફ નર્સ કોચિંગ, સ્પર્ધાત્મક પરીક્ષા માર્ગદર્શન અને ઉચ્ચ શિક્ષણ સેવાઓ.",
      experience: "અધિકૃત શૈક્ષણિક એકેડેમી (Education Services)",
      isActive: true,
      service: {
        id: "srv-009",
        title: "શિક્ષણ સેવાઓ અને નર્સિંગ એકેડેમી (Education Services & Coaching)",
        category: "Education Services",
        icon: "🎓",
      },
    },
    {
      id: "sp-001",
      serviceId: "srv-001",
      name: "Rameshbhai Vankar",
      gujaratiName: "રાજ મિસ્ત્રી રમેશભાઈ વણકર",
      photoUrl: "https://picsum.photos/seed/mason1/200/200",
      phone: "+91 98790 12345",
      address: "નવા નરોડા, અમદાવાદ",
      city: "અમદાવાદ",
      description:
        "RCC સ્લેબ, ઘર બાંધકામ, રાજ મિસ્ત્રી (Mason Work), પ્લાસ્ટર અને ટાઇલ્સ ફિટિંગ વર્ક.",
      experience: "15+ વર્ષ અનુભવ (Mason / Raj Mistri)",
      isActive: true,
      service: {
        id: "srv-001",
        title: "ઘર બાંધકામ અને સિવિલ વર્ક (Mason Work)",
        category: "Home & Daily Life Services",
        icon: "🏠",
      },
    },
    {
      id: "sp-002",
      serviceId: "srv-001",
      name: "Pravinbhai Parmar",
      gujaratiName: "પ્રવીણભાઈ પરમાર (Painter)",
      photoUrl: "https://picsum.photos/seed/painter1/200/200",
      phone: "+91 98251 11223",
      address: "અલકાપુરી, વડોદરા",
      city: "વડોદરા",
      description:
        "ઘર પેઇન્ટિંગ, રોયલ પ્લે કલર વર્ક, વુડન પોલિશ અને વોટરપ્રૂફિંગ કામકાજ.",
      experience: "10+ વર્ષ અનુભવ (Painter / Color Work)",
      isActive: true,
      service: {
        id: "srv-001",
        title: "પેઇન્ટર અને કલરકામ સર્વિસ (Painter)",
        category: "Home & Daily Life Services",
        icon: "🎨",
      },
    },
    {
      id: "sp-003",
      serviceId: "srv-002",
      name: "Maheshkumar Parmar",
      gujaratiName: "મહેશકુમાર પરમાર (Plumber)",
      photoUrl: "https://picsum.photos/seed/plumber1/200/200",
      phone: "+91 98250 67890",
      address: "કાપોદ્રા, સુરત",
      city: "સુરત",
      description:
        "બાથરૂમ પ્લમ્બિંગ, ગીઝર ફિટિંગ, મોટર રીપેર અને ઇમરજન્સી લીકેજ સોલ્યુશન.",
      experience: "8+ વર્ષ અનુભવ (Plumber)",
      isActive: true,
      service: {
        id: "srv-002",
        title: "ઇમરજન્સી પ્લમ્બિંગ વર્ક (Plumber)",
        category: "Home & Daily Life Services",
        icon: "🔧",
      },
    },
    {
      id: "sp-004",
      serviceId: "srv-002",
      name: "Hardik Vaghela",
      gujaratiName: "હાર્દિક વાઘેલા (Electrician)",
      photoUrl: "https://picsum.photos/seed/elec1/200/200",
      phone: "+91 97123 99887",
      address: "કાલાવડ રોડ, રાજકોટ",
      city: "રાજકોટ",
      description:
        "હાઉસ વાયરિંગ, ઇન્વર્ટર ફિટિંગ, શોર્ટ સર્કિટ અને ઇલેક્ટ્રિશિયન કામ.",
      experience: "12+ વર્ષ અનુભવ (Electrician)",
      isActive: true,
      service: {
        id: "srv-002",
        title: "હાઉસ વાયરિંગ અને ઇલેક્ટ્રિશિયન (Electrician)",
        category: "Home & Daily Life Services",
        icon: "⚡",
      },
    },
    {
      id: "sp-005",
      serviceId: "srv-015",
      name: "Prakash Vaghela",
      gujaratiName: "પ્રકાશ વાઘેલા (TV & AC Tech)",
      photoUrl: "https://picsum.photos/seed/tech1/200/200",
      phone: "+91 98792 99001",
      address: "સેક્ટર-૬, ગાંધીનગર",
      city: "ગાંધીનગર",
      description:
        "સ્માર્ટ એલઇડી ટીવી સેટઅપ, સ્પ્લિટ એસી ગેસ ચાર્જિંગ અને સીસીટીવી કેમેરા ફિટિંગ.",
      experience: "9+ વર્ષ અનુભવ (Technician)",
      isActive: true,
      service: {
        id: "srv-015",
        title: "ટીવી અને એસી ટેકનિશિયન (TV/AC Technician)",
        category: "Skilled Professionals",
        icon: "🧑🔧",
      },
    },
  ];

  async getPublicPersonsByServiceId(
    serviceId: string,
    filters?: {
      district?: string;
      taluka?: string;
      village?: string;
      search?: string;
    },
  ) {
    try {
      await this.syncMissingBusinessProfiles();

      const whereClause: any = {
        isActive: true,
      };

      if (serviceId !== "all") {
        whereClause.serviceId = serviceId;
      }

      if (filters?.search && filters.search.trim()) {
        const q = filters.search.trim();
        whereClause.OR = [
          { name: { contains: q } },
          { gujaratiName: { contains: q } },
          { description: { contains: q } },
          { city: { contains: q } },
          { address: { contains: q } },
          { phone: { contains: q } },
        ];
      }

      if (filters?.district && filters.district.trim()) {
        whereClause.district = {
          name: { contains: filters.district.trim() },
        };
      }

      if (filters?.taluka && filters.taluka.trim()) {
        whereClause.taluka = {
          name: { contains: filters.taluka.trim() },
        };
      }

      const res = await this.prisma.samajServicePerson.findMany({
        where: whereClause,
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
        orderBy: { createdAt: "desc" },
      });

      if (res && res.length > 0) {
        return res;
      }

      // If DB has no persons for this serviceId yet, return matching fallback
      const matchingFallbacks = this.defaultPersons.filter(
        (p) => p.serviceId === serviceId || serviceId === "all",
      );
      if (matchingFallbacks.length > 0) {
        return matchingFallbacks;
      }

      return res;
    } catch {
      // Fallback only if DB fails
      return this.defaultPersons.filter(
        (p) => p.serviceId === serviceId || serviceId === "all",
      );
    }
  }

  // ==========================================
  // ADMIN SERVICE ENDPOINTS
  // ==========================================

  async getAllAdminServices() {
    try {
      await this.syncMissingBusinessProfiles();
      const res = await this.prisma.samajService.findMany({
        orderBy: { createdAt: "desc" },
        include: {
          _count: {
            select: { persons: true },
          },
        },
      });
      // Always return DB data — DB is the source of truth
      return res;
    } catch (error) {
      this.logger.warn("DB unavailable, returning hardcoded fallback services");
      return this.defaultServices;
    }
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
    // Generate a URL-safe slug; for Gujarati text, use a random suffix to avoid collisions
    const baseSlug = data.title
      .toLowerCase()
      .replace(/[^\w\s-]/g, "")
      .replace(/\s+/g, "-")
      .substring(0, 50);
    const uniqueSlug =
      `${baseSlug}-${Date.now()}`.replace(/^-+|-+$/g, "") ||
      `service-${Date.now()}`;

    return this.prisma.samajService.create({
      data: {
        title: data.title,
        slug: uniqueSlug,
        category: data.category || "General",
        icon: data.icon || "🤝",
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
    }>,
  ) {
    const existing = await this.prisma.samajService.findUnique({
      where: { id },
    });
    if (!existing) {
      throw new NotFoundException(`Samaj Service with ID ${id} not found`);
    }

    return this.prisma.samajService.update({
      where: { id },
      data,
    });
  }

  async deleteService(id: string) {
    const existing = await this.prisma.samajService.findUnique({
      where: { id },
    });
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
    await this.syncMissingBusinessProfiles();
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
      orderBy: { createdAt: "desc" },
    });
  }

  async createServicePerson(dto: CreateServicePersonDto) {
    const service = await this.prisma.samajService.findUnique({
      where: { id: dto.serviceId },
    });

    if (!service) {
      throw new NotFoundException(
        `Associated Samaj Service with ID ${dto.serviceId} not found`,
      );
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
    const existing = await this.prisma.samajServicePerson.findUnique({
      where: { id },
    });
    if (!existing) {
      throw new NotFoundException(
        `Samaj Service Person with ID ${id} not found`,
      );
    }

    if (dto.serviceId) {
      const service = await this.prisma.samajService.findUnique({
        where: { id: dto.serviceId },
      });
      if (!service) {
        throw new NotFoundException(
          `Associated Samaj Service with ID ${dto.serviceId} not found`,
        );
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
    const existing = await this.prisma.samajServicePerson.findUnique({
      where: { id },
    });
    if (!existing) {
      throw new NotFoundException(
        `Samaj Service Person with ID ${id} not found`,
      );
    }

    return this.prisma.samajServicePerson.delete({
      where: { id },
    });
  }
}
