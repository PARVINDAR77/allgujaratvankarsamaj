import { Injectable, Logger } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";
import { UpdateEducationDto } from "./dto/update-education.dto";

const DEFAULT_EDUCATION_DATA = {
  id: "default",
  headerTitle: "Education for Better Tomorrow",
  headerSubtitle: "શિક્ષણ અને ઉજ્જવળ ભવિષ્ય માર્ગદર્શન",

  // Box 1: PDF Document
  box1Title: "શિક્ષણ માર્ગદર્શિકા અને પરિપત્રો (PDF)",
  box1Subtitle: "Download Official Educational PDF Guidelines & Circulars",
  box1PdfUrl: "",
  box1FileName: "career_guidance_2026.pdf",

  // Box 2: Written Paragraph / Guidance Message
  box2Title: "શિક્ષણ પ્રેરણા સંદેશ & કારકિર્દી સલાહ",
  box2Content:
    "શિક્ષણ એ જીવનનો સૌથી મહત્વનો પાયો છે. આપણા વણકર સમાજના દરેક દીકરા અને દીકરી ઉચ્ચ શિક્ષણ મેળવી સમાજ અને દેશનું નામ રોશન કરે તે અમારો મુખ્ય સંકલ્પ છે. ધોરણ ૧૦ અને ૧૨ પછીના વિવિધ અભ્યાસક્રમો, સ્કોલરશીપ સહાય, અને સરકારી ભરતીઓની તૈયારી માટે સમાજ સદાય તમારી સાથે છે. જ્ઞાન એ જ શક્તિ છે, અને શિક્ષણ દ્વારા જ પ્રગતિ શક્ય છે.",
  box2Author: "શિક્ષણ સમિતિ, ઓલ ગુજરાત વણકર સમાજ",

  // Box 3: YouTube Video 1
  box3Title: "શૈક્ષણિક સેમિનાર & કારકિર્દી માર્ગદર્શન",
  box3YoutubeUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
  box3Description: "ઉચ્ચ અભ્યાસ અને કારકિર્દી પસંદગી અંગે વિશેષ માર્ગદર્શન વ્યાખ્યાન.",

  // Box 4: YouTube Video 2
  box4Title: "યુવા પ્રેરણા સંવાદ & સફળતાની વાર્તાઓ",
  box4YoutubeUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
  box4Description: "સમાજના તેજસ્વી તારલાઓ અને અધિકારીઓના પ્રેરણાદાયી અનુભવો.",

  isActive: true,
};

@Injectable()
export class EducationService {
  private readonly logger = new Logger(EducationService.name);

  constructor(private readonly prisma: PrismaService) {}

  async getEducationContent() {
    try {
      // @ts-ignore - dynamic model check
      if (this.prisma.educationContent) {
        // @ts-ignore
        let content = await this.prisma.educationContent.findUnique({
          where: { id: "default" },
        });

        if (!content) {
          // @ts-ignore
          content = await this.prisma.educationContent.create({
            data: DEFAULT_EDUCATION_DATA,
          });
        }
        return {
          statusCode: 200,
          data: content,
        };
      }
    } catch (e: any) {
      this.logger.warn(
        `Prisma educationContent lookup failed (${e.message}), attempting raw SQL or default fallback`,
      );
      try {
        const rows: any[] = await this.prisma.$queryRawUnsafe(
          "SELECT * FROM `education_content` WHERE id = 'default' LIMIT 1",
        );
        if (rows && rows.length > 0) {
          const r = rows[0];
          return {
            statusCode: 200,
            data: {
              id: r.id,
              headerTitle: r.header_title,
              headerSubtitle: r.header_subtitle,
              box1Title: r.box1_title,
              box1Subtitle: r.box1_subtitle,
              box1PdfUrl: r.box1_pdf_url || "",
              box1FileName: r.box1_file_name || "",
              box2Title: r.box2_title,
              box2Content: r.box2_content || "",
              box2Author: r.box2_author || "",
              box3Title: r.box3_title,
              box3YoutubeUrl: r.box3_youtube_url || "",
              box3Description: r.box3_description || "",
              box4Title: r.box4_title,
              box4YoutubeUrl: r.box4_youtube_url || "",
              box4Description: r.box4_description || "",
              isActive: r.is_active === 1 || r.is_active === true,
              createdAt: r.created_at,
              updatedAt: r.updated_at,
            },
          };
        }
      } catch (sqlErr: any) {
        this.logger.warn(`Raw SQL failed as well: ${sqlErr.message}`);
      }
    }

    return {
      statusCode: 200,
      data: DEFAULT_EDUCATION_DATA,
    };
  }

  async updateEducationContent(dto: UpdateEducationDto) {
    const { id, createdAt, updatedAt, ...cleanData } = dto as any;

    // Normalize empty strings to null or string
    const normalized: Record<string, any> = {};
    for (const key of Object.keys(cleanData)) {
      normalized[key] = cleanData[key];
    }

    try {
      // @ts-ignore
      if (this.prisma.educationContent) {
        // @ts-ignore
        const updated = await this.prisma.educationContent.upsert({
          where: { id: "default" },
          update: {
            ...normalized,
            updatedAt: new Date(),
          },
          create: {
            id: "default",
            ...DEFAULT_EDUCATION_DATA,
            ...normalized,
          },
        });
        return {
          statusCode: 200,
          message: "Education content updated successfully",
          data: updated,
        };
      }
    } catch (e: any) {
      this.logger.error(`Failed to update education content via Prisma: ${e.message}`);
    }

    // Raw SQL fallback for safe updates
    try {
      const existing: any[] = await this.prisma.$queryRawUnsafe(
        "SELECT id FROM `education_content` WHERE id = 'default' LIMIT 1",
      );

      const headerTitle = normalized.headerTitle !== undefined ? normalized.headerTitle : DEFAULT_EDUCATION_DATA.headerTitle;
      const headerSubtitle = normalized.headerSubtitle !== undefined ? normalized.headerSubtitle : DEFAULT_EDUCATION_DATA.headerSubtitle;
      const box1Title = normalized.box1Title !== undefined ? normalized.box1Title : DEFAULT_EDUCATION_DATA.box1Title;
      const box1Subtitle = normalized.box1Subtitle !== undefined ? normalized.box1Subtitle : DEFAULT_EDUCATION_DATA.box1Subtitle;
      const box1PdfUrl = normalized.box1PdfUrl !== undefined ? (normalized.box1PdfUrl || null) : null;
      const box1FileName = normalized.box1FileName !== undefined ? (normalized.box1FileName || null) : null;
      const box2Title = normalized.box2Title !== undefined ? normalized.box2Title : DEFAULT_EDUCATION_DATA.box2Title;
      const box2Content = normalized.box2Content !== undefined ? (normalized.box2Content || null) : null;
      const box2Author = normalized.box2Author !== undefined ? (normalized.box2Author || null) : null;
      const box3Title = normalized.box3Title !== undefined ? normalized.box3Title : DEFAULT_EDUCATION_DATA.box3Title;
      const box3YoutubeUrl = normalized.box3YoutubeUrl !== undefined ? (normalized.box3YoutubeUrl || null) : null;
      const box3Description = normalized.box3Description !== undefined ? (normalized.box3Description || null) : null;
      const box4Title = normalized.box4Title !== undefined ? normalized.box4Title : DEFAULT_EDUCATION_DATA.box4Title;
      const box4YoutubeUrl = normalized.box4YoutubeUrl !== undefined ? (normalized.box4YoutubeUrl || null) : null;
      const box4Description = normalized.box4Description !== undefined ? (normalized.box4Description || null) : null;
      const isActive = normalized.isActive !== undefined ? (normalized.isActive ? 1 : 0) : 1;

      if (existing && existing.length > 0) {
        await this.prisma.$executeRawUnsafe(
          `UPDATE \`education_content\` SET 
            header_title = ?,
            header_subtitle = ?,
            box1_title = ?,
            box1_subtitle = ?,
            box1_pdf_url = ?,
            box1_file_name = ?,
            box2_title = ?,
            box2_content = ?,
            box2_author = ?,
            box3_title = ?,
            box3_youtube_url = ?,
            box3_description = ?,
            box4_title = ?,
            box4_youtube_url = ?,
            box4_description = ?,
            is_active = ?,
            updated_at = NOW()
          WHERE id = 'default'`,
          headerTitle,
          headerSubtitle,
          box1Title,
          box1Subtitle,
          box1PdfUrl,
          box1FileName,
          box2Title,
          box2Content,
          box2Author,
          box3Title,
          box3YoutubeUrl,
          box3Description,
          box4Title,
          box4YoutubeUrl,
          box4Description,
          isActive,
        );
      } else {
        await this.prisma.$executeRawUnsafe(
          `INSERT INTO \`education_content\` 
            (id, header_title, header_subtitle, box1_title, box1_subtitle, box1_pdf_url, box1_file_name, box2_title, box2_content, box2_author, box3_title, box3_youtube_url, box3_description, box4_title, box4_youtube_url, box4_description, is_active)
          VALUES 
            ('default', ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
          headerTitle,
          headerSubtitle,
          box1Title,
          box1Subtitle,
          box1PdfUrl,
          box1FileName,
          box2Title,
          box2Content,
          box2Author,
          box3Title,
          box3YoutubeUrl,
          box3Description,
          box4Title,
          box4YoutubeUrl,
          box4Description,
          isActive,
        );
      }

      return {
        statusCode: 200,
        message: "Education content updated successfully (SQL)",
        data: normalized,
      };
    } catch (sqlErr: any) {
      this.logger.error(`Raw SQL update failed: ${sqlErr.message}`);
      throw sqlErr;
    }
  }
}
