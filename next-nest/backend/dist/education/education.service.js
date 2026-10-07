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
var EducationService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.EducationService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../prisma/prisma.service");
const DEFAULT_EDUCATION_DATA = {
    id: "default",
    headerTitle: "Education for Better Tomorrow",
    headerSubtitle: "શિક્ષણ અને ઉજ્જવળ ભવિષ્ય માર્ગદર્શન",
    box1Title: "શિક્ષણ માર્ગદર્શિકા અને પરિપત્રો (PDF)",
    box1Subtitle: "Download Official Educational PDF Guidelines & Circulars",
    box1PdfUrl: "",
    box1FileName: "career_guidance_2026.pdf",
    box2Title: "શિક્ષણ પ્રેરણા સંદેશ & કારકિર્દી સલાહ",
    box2Content: "શિક્ષણ એ જીવનનો સૌથી મહત્વનો પાયો છે. આપણા વણકર સમાજના દરેક દીકરા અને દીકરી ઉચ્ચ શિક્ષણ મેળવી સમાજ અને દેશનું નામ રોશન કરે તે અમારો મુખ્ય સંકલ્પ છે. ધોરણ ૧૦ અને ૧૨ પછીના વિવિધ અભ્યાસક્રમો, સ્કોલરશીપ સહાય, અને સરકારી ભરતીઓની તૈયારી માટે સમાજ સદાય તમારી સાથે છે. જ્ઞાન એ જ શક્તિ છે, અને શિક્ષણ દ્વારા જ પ્રગતિ શક્ય છે.",
    box2Author: "શિક્ષણ સમિતિ, ઓલ ગુજરાત વણકર સમાજ",
    box3Title: "શૈક્ષણિક સેમિનાર & કારકિર્દી માર્ગદર્શન",
    box3YoutubeUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    box3Description: "ઉચ્ચ અભ્યાસ અને કારકિર્દી પસંદગી અંગે વિશેષ માર્ગદર્શન વ્યાખ્યાન.",
    box4Title: "યુવા પ્રેરણા સંવાદ & સફળતાની વાર્તાઓ",
    box4YoutubeUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    box4Description: "સમાજના તેજસ્વી તારલાઓ અને અધિકારીઓના પ્રેરણાદાયી અનુભવો.",
    isActive: true,
};
let EducationService = EducationService_1 = class EducationService {
    constructor(prisma) {
        this.prisma = prisma;
        this.logger = new common_1.Logger(EducationService_1.name);
    }
    async getEducationContent() {
        try {
            if (this.prisma.educationContent) {
                let content = await this.prisma.educationContent.findUnique({
                    where: { id: "default" },
                });
                if (!content) {
                    content = await this.prisma.educationContent.create({
                        data: DEFAULT_EDUCATION_DATA,
                    });
                }
                return {
                    statusCode: 200,
                    data: content,
                };
            }
        }
        catch (e) {
            this.logger.warn(`Prisma educationContent lookup failed (${e.message}), attempting raw SQL or default fallback`);
            try {
                const rows = await this.prisma.$queryRawUnsafe("SELECT * FROM `education_content` WHERE id = 'default' LIMIT 1");
                if (rows && rows.length > 0) {
                    return {
                        statusCode: 200,
                        data: rows[0],
                    };
                }
            }
            catch (sqlErr) {
                this.logger.warn(`Raw SQL failed as well: ${sqlErr.message}`);
            }
        }
        return {
            statusCode: 200,
            data: DEFAULT_EDUCATION_DATA,
        };
    }
    async updateEducationContent(dto) {
        try {
            if (this.prisma.educationContent) {
                const updated = await this.prisma.educationContent.upsert({
                    where: { id: "default" },
                    update: {
                        ...dto,
                        updatedAt: new Date(),
                    },
                    create: {
                        id: "default",
                        ...DEFAULT_EDUCATION_DATA,
                        ...dto,
                    },
                });
                return {
                    statusCode: 200,
                    message: "Education content updated successfully",
                    data: updated,
                };
            }
        }
        catch (e) {
            this.logger.error(`Failed to update education content via Prisma: ${e.message}`);
        }
        try {
            const existing = await this.prisma.$queryRawUnsafe("SELECT id FROM `education_content` WHERE id = 'default' LIMIT 1");
            if (existing && existing.length > 0) {
                await this.prisma.$executeRawUnsafe(`UPDATE \`education_content\` SET 
            header_title = COALESCE(?, header_title),
            header_subtitle = COALESCE(?, header_subtitle),
            box1_title = COALESCE(?, box1_title),
            box1_subtitle = COALESCE(?, box1_subtitle),
            box1_pdf_url = COALESCE(?, box1_pdf_url),
            box1_file_name = COALESCE(?, box1_file_name),
            box2_title = COALESCE(?, box2_title),
            box2_content = COALESCE(?, box2_content),
            box2_author = COALESCE(?, box2_author),
            box3_title = COALESCE(?, box3_title),
            box3_youtube_url = COALESCE(?, box3_youtube_url),
            box3_description = COALESCE(?, box3_description),
            box4_title = COALESCE(?, box4_title),
            box4_youtube_url = COALESCE(?, box4_youtube_url),
            box4_description = COALESCE(?, box4_description),
            is_active = COALESCE(?, is_active),
            updated_at = NOW()
          WHERE id = 'default'`, dto.headerTitle ?? null, dto.headerSubtitle ?? null, dto.box1Title ?? null, dto.box1Subtitle ?? null, dto.box1PdfUrl ?? null, dto.box1FileName ?? null, dto.box2Title ?? null, dto.box2Content ?? null, dto.box2Author ?? null, dto.box3Title ?? null, dto.box3YoutubeUrl ?? null, dto.box3Description ?? null, dto.box4Title ?? null, dto.box4YoutubeUrl ?? null, dto.box4Description ?? null, dto.isActive !== undefined ? (dto.isActive ? 1 : 0) : null);
            }
            else {
                await this.prisma.$executeRawUnsafe(`INSERT INTO \`education_content\` 
            (id, header_title, header_subtitle, box1_title, box1_subtitle, box1_pdf_url, box1_file_name, box2_title, box2_content, box2_author, box3_title, box3_youtube_url, box3_description, box4_title, box4_youtube_url, box4_description, is_active)
          VALUES 
            ('default', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)`, dto.headerTitle || DEFAULT_EDUCATION_DATA.headerTitle, dto.headerSubtitle || DEFAULT_EDUCATION_DATA.headerSubtitle, dto.box1Title || DEFAULT_EDUCATION_DATA.box1Title, dto.box1Subtitle || DEFAULT_EDUCATION_DATA.box1Subtitle, dto.box1PdfUrl || DEFAULT_EDUCATION_DATA.box1PdfUrl, dto.box1FileName || DEFAULT_EDUCATION_DATA.box1FileName, dto.box2Title || DEFAULT_EDUCATION_DATA.box2Title, dto.box2Content || DEFAULT_EDUCATION_DATA.box2Content, dto.box2Author || DEFAULT_EDUCATION_DATA.box2Author, dto.box3Title || DEFAULT_EDUCATION_DATA.box3Title, dto.box3YoutubeUrl || DEFAULT_EDUCATION_DATA.box3YoutubeUrl, dto.box3Description || DEFAULT_EDUCATION_DATA.box3Description, dto.box4Title || DEFAULT_EDUCATION_DATA.box4Title, dto.box4YoutubeUrl || DEFAULT_EDUCATION_DATA.box4YoutubeUrl, dto.box4Description || DEFAULT_EDUCATION_DATA.box4Description);
            }
            return {
                statusCode: 200,
                message: "Education content updated successfully (SQL)",
                data: dto,
            };
        }
        catch (sqlErr) {
            this.logger.error(`Raw SQL update failed: ${sqlErr.message}`);
            throw sqlErr;
        }
    }
};
exports.EducationService = EducationService;
exports.EducationService = EducationService = EducationService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], EducationService);
//# sourceMappingURL=education.service.js.map