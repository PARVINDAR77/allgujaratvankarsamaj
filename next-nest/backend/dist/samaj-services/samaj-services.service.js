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
var SamajServicesService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.SamajServicesService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
let SamajServicesService = SamajServicesService_1 = class SamajServicesService {
    constructor(prisma) {
        this.prisma = prisma;
        this.logger = new common_1.Logger(SamajServicesService_1.name);
        this.defaultServices = [
            {
                id: "srv-001",
                title: "ઘર બાંધકામ અને સિવિલ વર્ક (Construction & Mason)",
                category: "Home & Daily Life Services",
                icon: "🏠",
                contactPhone: "+91 98790 12345",
                contactPerson: "રાજ મિસ્ત્રી રમેશભાઈ વણકર",
                description: "ઘર બાંધકામ, રાજ મિસ્ત્રી (Mason Work), આરસીસી અને પ્લાસ્ટર કામકાજ સિંગલ ક્લિકથી.",
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
                description: "ઇમરજન્સી વાયરિંગ, પ્લમ્બિંગ ફિટિંગ, ગીઝર અને મોટર સુધારણા સેવાઓ.",
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
                description: "ઘર/ઓફિસ કલરકામ, વુડન પોલિશ, એસી સર્વિસિંગ, ફ્રિજ અને વોશિંગ મશીન રીપેર.",
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
                description: "ફર્નિચર બનાવટ, દરવાજા ફિટિંગ, એલ્યુમિનિયમ સેક્શન અને ગ્લાસ વિન્ડો વુડવર્ક.",
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
                description: "લગ્ન પ્રસંગ, પ્રવાસ કે ઇમરજન્સી માટે કાર રેન્ટલ, ટેક્સી અને ડ્રાઇવર બુકિંગ.",
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
                description: "ટુ-વીલર/ફોર-વીલર ગેરેજ, ટાયર પંચર, ઓન-રોડ આસિસ્ટન્સ અને કાર બેટરી.",
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
                description: "લેપટોપ, કોમ્પ્યુટર સુધારણા, સ્માર્ટફોન ડિસ્પ્લે અને પ્રિન્ટર કાર્ટ્રેજ રીફિલિંગ.",
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
                description: "સમાજ ઉદ્યોગો માટે વેબસાઇટ ડેવલપમેન્ટ, બિઝનેસ એપ અને સોશિયલ મીડિયા ડિઝાઇન.",
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
                description: "નર્સિંગ એકેડેમી, સ્ટાફ નર્સ કોચિંગ, સ્પર્ધાત્મક પરીક્ષા માર્ગદર્શન, ધો. ૧ થી ૧૨ ટ્યુશન અને ઉચ્ચ શિક્ષણ સહાય.",
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
                description: "પ્રાઇવેટ અને સ્કિલ્ડ જોબ માહિતી, સીવી બનાવવા અને ઇન્ટરવ્યુ તૈયારી.",
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
                description: "કાનૂની સલાહ, જમીન-મિલકત દસ્તાવેજ લેખન, સોગંદનામા અને રેવન્યુ કેસ.",
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
                description: "સમાજ ડૉક્ટર્સ પેનલ, આંખના ડૉક્ટર, દાંતના ડૉક્ટર અને મફત આરોગ્ય કેમ્પ.",
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
                description: "૨૪x૭ ઇમરજન્સી એમ્બ્યુલન્સ, બ્લડ ડોનર નેટવર્ક અને લેબોરેટરી રિપોર્ટ સહાય.",
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
                description: "સમાજના વેપારીઓનું હોલસેલ ગ્રોસરી, રેડીમેડ ગારમેન્ટ્સ, શૂઝ અને જ્વેલરી શોપિંગ.",
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
                description: "ગ્રીલ/ગેટ વેલ્ડિંગ વર્ક, ટીવી ટેકનિશિયન, સીસીટીવી કેમેરા ફિટિંગ અને મશીનરી વર્ક.",
                isActive: true,
                _count: { persons: 29 },
            },
        ];
        this.defaultPersons = [
            {
                id: "sp-vamika-01",
                serviceId: "srv-009",
                name: "VAMIKA NURSING ACADEMY (IDAR)",
                gujaratiName: "વામિકા નર્સિંગ એકેડેમી - ઇડર (શિક્ષણ સેવાઓ)",
                photoUrl: "https://picsum.photos/seed/nursing1/200/200",
                phone: "+91 92654 76537",
                address: "ઇડર, ૩૫ ગામ પરગણા, સાબરકાંઠા",
                city: "ઇડર (Idar)",
                description: "વામિકા નર્સિંગ એકેડેમી - ઇડર. નર્સિંગ એકેડેમી, સ્ટાફ નર્સ કોચિંગ, સ્પર્ધાત્મક પરીક્ષા માર્ગદર્શન અને ઉચ્ચ શિક્ષણ સેવાઓ.",
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
                description: "RCC સ્લેબ, ઘર બાંધકામ, રાજ મિસ્ત્રી (Mason Work), પ્લાસ્ટર અને ટાઇલ્સ ફિટિંગ વર્ક.",
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
                description: "ઘર પેઇન્ટિંગ, રોયલ પ્લે કલર વર્ક, વુડન પોલિશ અને વોટરપ્રૂફિંગ કામકાજ.",
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
                description: "બાથરૂમ પ્લમ્બિંગ, ગીઝર ફિટિંગ, મોટર રીપેર અને ઇમરજન્સી લીકેજ સોલ્યુશન.",
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
                description: "હાઉસ વાયરિંગ, ઇન્વર્ટર ફિટિંગ, શોર્ટ સર્કિટ અને ઇલેક્ટ્રિશિયન કામ.",
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
                description: "સ્માર્ટ એલઇડી ટીવી સેટઅપ, સ્પ્લિટ એસી ગેસ ચાર્જિંગ અને સીસીટીવી કેમેરા ફિટિંગ.",
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
    }
    async syncMissingBusinessProfiles() {
        try {
            try {
                await this.prisma.$executeRawUnsafe("ALTER TABLE `samaj_service_persons` ADD COLUMN IF NOT EXISTS `user_id` VARCHAR(191) NULL");
                await this.prisma.$executeRawUnsafe("ALTER TABLE `samaj_service_persons` MODIFY COLUMN `address` TEXT NULL");
                await this.prisma.$executeRawUnsafe("ALTER TABLE `samaj_service_persons` MODIFY COLUMN `description` TEXT NULL");
                await this.prisma.$executeRawUnsafe("ALTER TABLE `samaj_service_persons` MODIFY COLUMN `photo_url` TEXT NULL");
            }
            catch (_) { }
            try {
                await this.prisma.samajServicePerson.deleteMany({
                    where: {
                        OR: [
                            { name: "it company" },
                            { gujaratiName: "it company" },
                            { name: "Education / Teachers" },
                            { gujaratiName: "Education / Teachers" },
                            { name: { contains: "State Government" } },
                            { name: { contains: "Central Government" } },
                            { name: { contains: "રાજ્ય સરકાર" } },
                            { name: { contains: "કેન્દ્ર સરકાર" } },
                            { name: { contains: "Select Department" } },
                            { phone: "સંપર્ક ઉપલબ્ધ" },
                            { phone: "" },
                        ],
                    },
                });
                const garmentService = await this.prisma.samajService.findFirst({
                    where: { title: { contains: "Clothes" } },
                });
                if (garmentService) {
                    const badGarmentPersons = await this.prisma.samajServicePerson.findMany({
                        where: { serviceId: garmentService.id },
                    });
                    for (const gp of badGarmentPersons) {
                        const text = `${gp.name} ${gp.description || ""} ${gp.experience || ""}`.toLowerCase();
                        const isRealGarment = text.includes("cloth") ||
                            text.includes("garment") ||
                            text.includes("textile") ||
                            text.includes("tailor") ||
                            text.includes("કાપડ") ||
                            text.includes("દરજી");
                        if (!isRealGarment) {
                            await this.prisma.samajServicePerson.delete({ where: { id: gp.id } });
                        }
                    }
                }
                const bikeService = await this.prisma.samajService.findFirst({
                    where: { title: { contains: "Bike" } },
                });
                if (bikeService) {
                    const badBikePersons = await this.prisma.samajServicePerson.findMany({
                        where: { serviceId: bikeService.id },
                    });
                    for (const bp of badBikePersons) {
                        const text = `${bp.name} ${bp.description || ""} ${bp.experience || ""}`.toLowerCase();
                        const isRealBike = text.includes("bike") ||
                            text.includes("scooter") ||
                            text.includes("garage") ||
                            text.includes("two wheeler") ||
                            text.includes("ગેરેજ");
                        if (!isRealBike) {
                            await this.prisma.samajServicePerson.delete({ where: { id: bp.id } });
                        }
                    }
                }
                await this.prisma.samajService.updateMany({
                    where: {
                        OR: [
                            { category: "Event & Wedding Planning" },
                            { title: { contains: "safavada" } },
                            { title: { contains: "Safavara" } },
                            { title: { contains: "સાફાવાળા" } },
                        ],
                    },
                    data: { category: "Wedding" },
                });
                await this.prisma.samajService.updateMany({
                    where: { category: { contains: "Business & Services" } },
                    data: { category: "Business & Local Shops" },
                });
                await this.prisma.samajService.updateMany({
                    where: { category: "વ્યવસાય અને સેવાઓ (Business)" },
                    data: { category: "Health & Emergency" },
                });
                await this.prisma.samajService.updateMany({
                    where: { category: { contains: "IT & Computer" } },
                    data: { category: "Computer & Digital Services" },
                });
            }
            catch (_) { }
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
                        description: "નર્સિંગ પ્રવેશ, કોચિંગ ક્લાસીસ, સ્પર્ધાત્મક પરીક્ષા માર્ગદર્શન અને શિક્ષણ સહાય સેવાઓ.",
                        isActive: true,
                        sortOrder: 1,
                    },
                });
                this.logger.log(`Created main Education Services: ${eduService.id}`);
            }
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
                        description: "નર્સિંગ, ધોરણ ૧ થી ૧૨ ટ્યુશન, GPSC/TET/TAT અને સ્પર્ધાત્મક પરીક્ષા કોચિંગ.",
                        isActive: true,
                        sortOrder: 2,
                    },
                });
            }
            let itService = await this.prisma.samajService.findFirst({
                where: {
                    OR: [
                        { title: { contains: "Computer & IT" } },
                        { title: { contains: "કમ્પ્યુટર અને સોફ્ટવેર" } },
                        { title: { contains: "કમ્પ્યુટર અને આઇટી" } },
                        { slug: "computer-it-services" },
                    ],
                },
            });
            if (!itService) {
                itService = await this.prisma.samajService.create({
                    data: {
                        title: "કમ્પ્યુટર અને આઇટી સેવાઓ (Computer & IT Services)",
                        slug: "computer-it-services",
                        category: "કમ્પ્યુટર અને ટેકનોલોજી (IT & Computer)",
                        icon: "💻",
                        contactPhone: "9234567890",
                        contactPerson: "પરવિન્દર પંજાબી (Parvindar Panjabi)",
                        description: "સોફ્ટવેર ડેવલપમેન્ટ, વેબસાઇટ ડિઝાઇન, કમ્પ્યુટર હાર્ડવેર, લેપટોપ રિપેરિંગ અને નેટવર્કિંગ સેવાઓ.",
                        isActive: true,
                        sortOrder: 3,
                    },
                });
                this.logger.log(`Created main IT Services: ${itService.id}`);
            }
            const profiles = await this.prisma.matrimonialProfile.findMany({
                where: {
                    status: { not: "REJECTED" },
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
                const isGovtOnly = (occ.includes("government") || occ.includes("સરકારી") || occ.includes("govt")) &&
                    (!p.businessService || p.businessService === "Select Service" || p.businessService.trim() === "") &&
                    (!p.businessIndustry || p.businessIndustry === "Select Industry" || p.businessIndustry.trim() === "");
                if (isGovtOnly) {
                    if (p.userId) {
                        await this.prisma.samajServicePerson.deleteMany({
                            where: { userId: p.userId },
                        });
                    }
                    continue;
                }
                const isVamika = combined.includes("vamika") ||
                    combined.includes("nursing") ||
                    combined.includes("academy") ||
                    (p.user?.phone && p.user.phone.includes("9265476537")) ||
                    (p.altPhone && p.altPhone.includes("9265476537")) ||
                    (p.fatherContact && p.fatherContact.includes("9265476537"));
                const isEducation = isVamika ||
                    bizInd.includes("edu") ||
                    bizInd.includes("શિક્ષણ") ||
                    bizSvc.includes("edu") ||
                    bizSvc.includes("coaching") ||
                    bizSvc.includes("tuition") ||
                    bizSvc.includes("શિક્ષણ");
                const phone = (p.user?.phone ||
                    p.altPhone ||
                    p.fatherContact ||
                    p.guardianContact ||
                    (isVamika ? "9265476537" : ""))?.trim() || "";
                const city = p.city || (isVamika ? "Idar" : (p.nativePlace || "Gujarat"));
                const address = p.addressLine ||
                    p.nativePlace ||
                    (isVamika ? "Idar, 35 Gam Pargana" : (city ? `${city}, Gujarat` : "Gujarat"));
                const personFullName = `${fName} ${lName}`.trim() || "સમાજ સભ્ય";
                const isGovtPlaceholder = orgName.toLowerCase().includes("government") ||
                    orgName.toLowerCase().includes("સરકાર") ||
                    orgName.toLowerCase().includes("select department");
                let displayName = personFullName;
                let gujaratiName = personFullName;
                if (isVamika) {
                    displayName = "VAMIKA NURSING ACADEMY (IDAR)";
                    gujaratiName = "વામિકા નર્સિંગ એકેડેમી - ઇડર (શિક્ષણ & કોચિંગ સેવાઓ)";
                }
                else if (orgName && !isGovtPlaceholder && orgName.length > 2) {
                    displayName = `${personFullName} (${orgName})`;
                    gujaratiName = `${personFullName} (${orgName})`;
                }
                let description = p.about || `${displayName} - સમાજ અધિકૃત વ્યાપારી સેવા`;
                if (isVamika) {
                    description =
                        "વામિકા નર્સિંગ એકેડેમી - ઇડર. નર્સિંગ એકેડેમી, સ્ટાફ નર્સ કોચિંગ, સ્પર્ધાત્મક પરીક્ષા માર્ગદર્શન અને ઉચ્ચ શિક્ષણ સેવાઓ.";
                }
                const isIT = combined.includes("it company") ||
                    combined.includes("computer") ||
                    combined.includes("software") ||
                    combined.includes("technology") ||
                    combined.includes("developer") ||
                    combined.includes("web designer") ||
                    combined.includes("hardware") ||
                    combined.includes("laptop") ||
                    combined.includes("engineeres") ||
                    combined.includes("engineer") ||
                    combined.includes("આઇટી");
                const targetServiceIds = [];
                if (isEducation) {
                    if (eduService?.id)
                        targetServiceIds.push(eduService.id);
                    if (tuitionService?.id)
                        targetServiceIds.push(tuitionService.id);
                }
                else if (isIT) {
                    if (itService?.id)
                        targetServiceIds.push(itService.id);
                }
                else {
                    let matched = null;
                    if (p.businessService && p.businessService !== "Select Service") {
                        matched = await this.prisma.samajService.findFirst({
                            where: { title: p.businessService.trim(), isActive: true },
                        });
                        if (!matched) {
                            const cleanSvc = p.businessService.replace(/\(.*?\)/g, "").replace(/[-—/]/g, " ").trim();
                            if (cleanSvc.length > 2) {
                                matched = await this.prisma.samajService.findFirst({
                                    where: {
                                        title: { contains: cleanSvc },
                                        isActive: true,
                                    },
                                });
                                if (!matched) {
                                    matched = await this.prisma.samajService.findFirst({
                                        where: {
                                            description: { contains: cleanSvc },
                                            isActive: true,
                                        },
                                    });
                                }
                            }
                        }
                    }
                    if (!matched && orgName && !isGovtPlaceholder && orgName.length > 2) {
                        matched = await this.prisma.samajService.findFirst({
                            where: {
                                title: { contains: orgName },
                                isActive: true,
                            },
                        });
                    }
                    if (!matched && (!p.businessService || p.businessService === "Select Service") && p.businessIndustry && p.businessIndustry !== "Select Industry") {
                        const cleanInd = p.businessIndustry.replace(/\(.*?\)/g, "").trim();
                        if (cleanInd.length > 2) {
                            matched = await this.prisma.samajService.findFirst({
                                where: {
                                    category: { contains: cleanInd },
                                    isActive: true,
                                },
                            });
                        }
                    }
                    if (!matched) {
                        const serviceTitle = ((p.businessService && p.businessService !== "Select Service" && p.businessService.trim().length > 1)
                            ? p.businessService.trim()
                            : ((!isGovtPlaceholder && orgName) || p.designation || "Samaj Business Service")).trim();
                        const serviceCategory = ((p.businessIndustry && p.businessIndustry !== "Select Industry" && p.businessIndustry.trim().length > 1)
                            ? p.businessIndustry.trim()
                            : "વ્યવસાય અને સેવાઓ (Business & Services)").trim();
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
                        let icon = "💼";
                        const lower = `${serviceTitle} ${serviceCategory}`.toLowerCase();
                        if (lower.includes("medical") || lower.includes("doctor") || lower.includes("દવા") || lower.includes("આરોગ્ય"))
                            icon = "🏥";
                        else if (lower.includes("advocate") || lower.includes("lawyer") || lower.includes("વકીલ") || lower.includes("legal"))
                            icon = "⚖️";
                        else if (lower.includes("education") || lower.includes("શિક્ષણ") || lower.includes("school") || lower.includes("class"))
                            icon = "🎓";
                        else if (lower.includes("software") || lower.includes("it") || lower.includes("computer") || lower.includes("ટેકનોલોજી"))
                            icon = "💻";
                        else if (lower.includes("auto") || lower.includes("garage") || lower.includes("વાહન") || lower.includes("driver") || lower.includes("car"))
                            icon = "🚗";
                        else if (lower.includes("kirana") || lower.includes("store") || lower.includes("કરિયાણા") || lower.includes("food") || lower.includes("દુકાન"))
                            icon = "🛒";
                        else if (lower.includes("cloth") || lower.includes("textile") || lower.includes("કાપડ"))
                            icon = "👔";
                        else if (lower.includes("electric") || lower.includes("લાઈટ") || lower.includes("વાયર"))
                            icon = "⚡";
                        else if (lower.includes("build") || lower.includes("const") || lower.includes("મકાન"))
                            icon = "🏗️";
                        try {
                            matched = await this.prisma.samajService.create({
                                data: {
                                    title: serviceTitle,
                                    slug: uniqueSlug,
                                    category: serviceCategory,
                                    icon,
                                    description: `${serviceTitle} - સમાજ અધિકૃત વ્યાપારી સેવા (${serviceCategory})`,
                                    contactPhone: phone || null,
                                    contactPerson: displayName || null,
                                    isActive: true,
                                },
                            });
                            this.logger.log(`Retroactive auto-created SamajService "${serviceTitle}" (${matched.id})`);
                        }
                        catch (createErr) {
                            this.logger.warn(`Could not create SamajService "${serviceTitle}": ${createErr}`);
                        }
                    }
                    if (matched?.id) {
                        targetServiceIds.push(matched.id);
                    }
                }
                if (p.userId && targetServiceIds.length > 0) {
                    try {
                        await this.prisma.samajServicePerson.deleteMany({
                            where: {
                                userId: p.userId,
                                serviceId: { notIn: targetServiceIds },
                            },
                        });
                    }
                    catch (_) { }
                }
                for (const sId of targetServiceIds) {
                    try {
                        let existing = null;
                        if (p.userId) {
                            existing = await this.prisma.samajServicePerson.findFirst({
                                where: {
                                    userId: p.userId,
                                    serviceId: sId,
                                },
                            });
                        }
                        if (!existing && phone && phone.length >= 10) {
                            existing = await this.prisma.samajServicePerson.findFirst({
                                where: {
                                    phone: phone,
                                    serviceId: sId,
                                },
                            });
                        }
                        let parsedPhoto = p.photoUrl;
                        if (!parsedPhoto && p.photos) {
                            try {
                                const photoArr = JSON.parse(p.photos);
                                if (Array.isArray(photoArr) && photoArr.length > 0) {
                                    parsedPhoto = photoArr[0];
                                }
                            }
                            catch (_) { }
                        }
                        const personPayload = {
                            serviceId: sId,
                            userId: p.userId || null,
                            name: displayName,
                            gujaratiName: gujaratiName,
                            phone: phone || "9265476537",
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
                        }
                        else {
                            await this.prisma.samajServicePerson.create({
                                data: personPayload,
                            });
                        }
                        await this.prisma.samajService.updateMany({
                            where: {
                                id: sId,
                                OR: [{ contactPhone: null }, { contactPerson: null }],
                            },
                            data: {
                                contactPhone: phone || "9265476537",
                                contactPerson: displayName,
                            },
                        });
                    }
                    catch (personErr) {
                        this.logger.warn(`Could not sync person for service ${sId}: ${personErr?.message || personErr}`);
                    }
                }
            }
            const targetIds = [eduService?.id, tuitionService?.id].filter(Boolean);
            for (const sId of targetIds) {
                try {
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
                                description: "વામિકા નર્સિંગ એકેડેમી - ઇડર. નર્સિંગ એકેડેમી, સ્ટાફ નર્સ કોચિંગ, સ્પર્ધાત્મક પરીક્ષા માર્ગદર્શન અને ઉચ્ચ શિક્ષણ સેવાઓ.",
                                experience: "અધિકૃત શૈક્ષણિક એકેડેમી (Education Services)",
                                isActive: true,
                            },
                        });
                    }
                }
                catch (_) { }
            }
        }
        catch (err) {
            this.logger.warn(`syncMissingBusinessProfiles warning: ${err?.message || err}`);
        }
    }
    async fixDatabaseRecords() {
        this.logger.log("Running comprehensive database repair for Samaj Services...");
        await this.syncMissingBusinessProfiles();
        const activePersons = await this.prisma.samajServicePerson.findMany({
            where: { isActive: true },
            include: { service: true },
            orderBy: { createdAt: "desc" },
        });
        const activeServices = await this.prisma.samajService.findMany({
            where: { isActive: true },
            include: {
                _count: {
                    select: { persons: true },
                },
            },
        });
        return {
            success: true,
            message: "Database successfully purged of corrupted placeholder records and business candidates properly mapped.",
            totalPersons: activePersons.length,
            persons: activePersons.map((p) => ({
                id: p.id,
                name: p.name,
                gujaratiName: p.gujaratiName,
                phone: p.phone,
                city: p.city,
                service: p.service?.title,
                category: p.service?.category,
            })),
            servicesWithCounts: activeServices
                .filter((s) => s._count.persons > 0)
                .map((s) => ({
                title: s.title,
                category: s.category,
                count: s._count.persons,
            })),
        };
    }
    async getPublicServices(search, category) {
        try {
            const whereClause = { isActive: true };
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
            const normalized = res.map((s) => {
                let cat = s.category;
                const lowerCat = (cat || "").toLowerCase();
                const lowerTitle = (s.title || "").toLowerCase();
                if (lowerCat.includes("wedding") ||
                    lowerCat.includes("event") ||
                    lowerTitle.includes("safav") ||
                    lowerTitle.includes("સાફા")) {
                    cat = "Wedding";
                }
                return {
                    ...s,
                    category: cat,
                };
            });
            return normalized;
        }
        catch (error) {
            this.logger.warn("DB unavailable, returning hardcoded fallback services");
            let fallback = this.defaultServices;
            if (category && category.trim()) {
                fallback = fallback.filter((s) => s.category.toLowerCase().includes(category.trim().toLowerCase()));
            }
            if (search && search.trim()) {
                const q = search.trim().toLowerCase();
                fallback = fallback.filter((s) => s.title.toLowerCase().includes(q) ||
                    (s.description && s.description.toLowerCase().includes(q)) ||
                    s.category.toLowerCase().includes(q) ||
                    (s.contactPhone && s.contactPhone.includes(q)) ||
                    (s.contactPerson && s.contactPerson.toLowerCase().includes(q)));
            }
            return fallback;
        }
    }
    async getPublicServiceById(id) {
        try {
            const service = await this.prisma.samajService.findFirst({
                where: { id, isActive: true },
                include: {
                    persons: {
                        where: { isActive: true },
                        orderBy: { createdAt: "desc" },
                    },
                },
            });
            if (service) {
                if (!service.persons || service.persons.length === 0) {
                    const fallbackPersons = this.defaultPersons.filter((p) => p.serviceId === id ||
                        (service.category?.toLowerCase().includes("edu") &&
                            p.service?.category === "Education Services"));
                    if (fallbackPersons.length > 0) {
                        return {
                            ...service,
                            persons: fallbackPersons,
                        };
                    }
                }
                return service;
            }
            const fallback = this.defaultServices.find((s) => s.id === id);
            if (fallback) {
                const fallbackPersons = this.defaultPersons.filter((p) => p.serviceId === id);
                return {
                    ...fallback,
                    persons: fallbackPersons,
                };
            }
            throw new common_1.NotFoundException(`Samaj Service with ID ${id} not found or inactive`);
        }
        catch (error) {
            if (error instanceof common_1.NotFoundException)
                throw error;
            this.logger.warn(`Error in getPublicServiceById for ${id}: ${error?.message || error}`);
            const fallback = this.defaultServices.find((s) => s.id === id) || {
                id,
                title: "Samaj Service",
                category: "General",
                icon: "💼",
                description: "સમાજ વ્યાપારી સેવા",
                isActive: true,
            };
            return {
                ...fallback,
                persons: this.defaultPersons.filter((p) => p.serviceId === id),
            };
        }
    }
    async getPublicPersonsByServiceId(serviceId, filters) {
        try {
            let targetServiceId = serviceId;
            if (serviceId !== "all") {
                const foundSvc = await this.prisma.samajService.findFirst({
                    where: { OR: [{ id: serviceId }, { slug: serviceId }] },
                    select: { id: true },
                });
                if (foundSvc) {
                    targetServiceId = foundSvc.id;
                }
            }
            const AND = [{ isActive: true }];
            if (targetServiceId !== "all") {
                AND.push({ serviceId: targetServiceId });
            }
            if (filters?.search && filters.search.trim()) {
                const q = filters.search.trim();
                AND.push({
                    OR: [
                        { name: { contains: q } },
                        { gujaratiName: { contains: q } },
                        { description: { contains: q } },
                        { city: { contains: q } },
                        { address: { contains: q } },
                        { phone: { contains: q } },
                        { experience: { contains: q } },
                        { service: { title: { contains: q } } },
                        { service: { category: { contains: q } } },
                    ],
                });
            }
            if (filters?.district && filters.district.trim()) {
                const d = filters.district.trim();
                AND.push({
                    OR: [
                        { district: { name: { contains: d } } },
                        { district: { gujaratiName: { contains: d } } },
                        { city: { contains: d } },
                        { address: { contains: d } },
                    ],
                });
            }
            if (filters?.taluka && filters.taluka.trim()) {
                const t = filters.taluka.trim();
                AND.push({
                    OR: [
                        { taluka: { name: { contains: t } } },
                        { taluka: { gujaratiName: { contains: t } } },
                        { city: { contains: t } },
                        { address: { contains: t } },
                    ],
                });
            }
            const res = await this.prisma.samajServicePerson.findMany({
                where: { AND },
                include: {
                    service: {
                        select: {
                            id: true,
                            title: true,
                            category: true,
                            icon: true,
                        },
                    },
                    district: {
                        select: { id: true, name: true, gujaratiName: true },
                    },
                    taluka: {
                        select: { id: true, name: true, gujaratiName: true },
                    },
                },
                orderBy: { createdAt: "desc" },
            });
            if (res && res.length > 0) {
                return res;
            }
            const matchingFallbacks = this.defaultPersons.filter((p) => p.serviceId === targetServiceId || targetServiceId === "all");
            if (matchingFallbacks.length > 0) {
                return matchingFallbacks;
            }
            return res;
        }
        catch (err) {
            this.logger.warn(`Error in getPublicPersonsByServiceId: ${err?.message || err}`);
            return this.defaultPersons.filter((p) => p.serviceId === serviceId || serviceId === "all");
        }
    }
    async getAllAdminServices() {
        try {
            const res = await this.prisma.samajService.findMany({
                orderBy: { createdAt: "desc" },
                include: {
                    _count: {
                        select: { persons: true },
                    },
                },
            });
            return res;
        }
        catch (error) {
            this.logger.warn("DB unavailable, returning hardcoded fallback services");
            return this.defaultServices;
        }
    }
    async createService(data) {
        const baseSlug = data.title
            .toLowerCase()
            .replace(/[^\w\s-]/g, "")
            .replace(/\s+/g, "-")
            .substring(0, 50);
        const uniqueSlug = `${baseSlug}-${Date.now()}`.replace(/^-+|-+$/g, "") ||
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
    async updateService(id, data) {
        const existing = await this.prisma.samajService.findUnique({
            where: { id },
        });
        if (!existing) {
            throw new common_1.NotFoundException(`Samaj Service with ID ${id} not found`);
        }
        return this.prisma.samajService.update({
            where: { id },
            data,
        });
    }
    async deleteService(id) {
        const existing = await this.prisma.samajService.findUnique({
            where: { id },
        });
        if (!existing) {
            throw new common_1.NotFoundException(`Samaj Service with ID ${id} not found`);
        }
        return this.prisma.samajService.delete({
            where: { id },
        });
    }
    async getAllAdminServicePersons(serviceId) {
        try {
            return await this.prisma.samajServicePerson.findMany({
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
        catch (err) {
            this.logger.warn(`getAllAdminServicePersons error: ${err?.message || err}`);
            return this.defaultPersons.filter((p) => !serviceId || p.serviceId === serviceId);
        }
    }
    async createServicePerson(dto) {
        let service = await this.prisma.samajService.findUnique({
            where: { id: dto.serviceId },
        });
        if (!service) {
            service = await this.prisma.samajService.findFirst({
                where: { slug: dto.serviceId },
            });
        }
        if (!service) {
            throw new common_1.NotFoundException(`Associated Samaj Service with ID ${dto.serviceId} not found`);
        }
        return this.prisma.samajServicePerson.create({
            data: {
                serviceId: service.id,
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
    async updateServicePerson(id, dto) {
        const existing = await this.prisma.samajServicePerson.findUnique({
            where: { id },
        });
        if (!existing) {
            throw new common_1.NotFoundException(`Samaj Service Person with ID ${id} not found`);
        }
        if (dto.serviceId) {
            let service = await this.prisma.samajService.findUnique({
                where: { id: dto.serviceId },
            });
            if (!service) {
                service = await this.prisma.samajService.findFirst({
                    where: { slug: dto.serviceId },
                });
            }
            if (!service) {
                throw new common_1.NotFoundException(`Associated Samaj Service with ID ${dto.serviceId} not found`);
            }
            dto.serviceId = service.id;
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
    async deleteServicePerson(id) {
        const existing = await this.prisma.samajServicePerson.findUnique({
            where: { id },
        });
        if (!existing) {
            throw new common_1.NotFoundException(`Samaj Service Person with ID ${id} not found`);
        }
        return this.prisma.samajServicePerson.delete({
            where: { id },
        });
    }
};
exports.SamajServicesService = SamajServicesService;
exports.SamajServicesService = SamajServicesService = SamajServicesService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], SamajServicesService);
//# sourceMappingURL=samaj-services.service.js.map