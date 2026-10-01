import { Injectable } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";

@Injectable()
export class MasterDataService {
  constructor(private readonly prisma: PrismaService) {}

  async getAllMasterData() {
    const states = await this.prisma.state.findMany({
      where: { isActive: true },
      include: {
        districts: {
          where: { isActive: true },
          include: {
            talukas: {
              where: { isActive: true },
              select: { id: true, name: true, gujaratiName: true },
            },
          },
        },
      },
    });

    // Formatting for frontend AppData compatibility
    const gujaratDistricts: Record<string, string[]> = {
      "Select District": ["Select Taluka"],
    };

    const gujaratState = states.find((s) => s.name.toLowerCase() === "gujarat");
    if (gujaratState) {
      for (const district of gujaratState.districts) {
        gujaratDistricts[district.name] = district.talukas.map((t) => t.name);
      }
    }

    // Static data that is not yet in DB
    const educationDegrees = [
      "Select Degree",
      "No Formal Education",
      "Primary School",
      "5th Fail",
      "5th Pass",
      "8th Fail",
      "8th Pass",
      "10th Fail",
      "10th Pass / SSC",
      "12th Fail",
      "12th Pass / HSC",
      "12th Arts",
      "12th Commerce",
      "12th Science",
      "12th Vocational",
      "ITI",
      "Certificate Course",
      "Diploma",
      "B.A.",
      "B.Com.",
      "B.Sc.",
      "B.B.A.",
      "B.C.A.",
      "B.E.",
      "B.Tech.",
      "M.A.",
      "M.Com.",
      "M.Sc.",
      "M.B.A.",
      "M.C.A.",
      "M.E.",
      "M.Tech.",
      "Ph.D.",
      "Other Qualification (અન્ય)",
    ];

    const abroadCountries = [
      "Select Country (દેશ પસંદ કરો)",
      "Australia — ઓસ્ટ્રેલિયા",
      "Canada — કેનેડા",
      "Germany — જર્મની",
      "India — ભારત",
      "New Zealand — ન્યૂઝીલેન્ડ",
      "United Arab Emirates — સંયુક્ત આરબ અમીરાત",
      "United Kingdom — યુનાઇટેડ કિંગડમ",
      "United States — યુનાઇટેડ સ્ટેટ્સ",
    ];

    const privateSectors = [
      "Select Category",
      "IT / Software Development",
      "Banking / Financial Services (BFSI)",
      "Healthcare / Medical / Hospital",
      "Engineering / Manufacturing",
      "Education / Teaching",
    ];

    const businessSectors = [
      "Select Category",
      "Retail / Shop (કરિયાણા/અન્ય દુકાન)",
      "Wholesale / Trading (જથ્થાબંધ વેપાર)",
      "Manufacturing / Factory (ઉત્પાદન)",
      "Agriculture / Farming (ખેતી)",
      "Real Estate / Construction",
    ];

    const incomeRanges = [
      "Select Income",
      "₹0–1 લાખ",
      "₹1–2 લાખ",
      "₹2–3 લાખ",
      "₹3–5 લાખ",
      "₹5–10 લાખ",
      "₹10–15 લાખ",
      "₹15–20 લાખ",
      "₹20 લાખથી વધુ",
    ];

    const religionOptions = [
      "Select Religion",
      "હિન્દુ ધર્મ (Hinduism)",
      "બૌદ્ધ ધર્મ (Buddhism)",
    ];

    return {
      gujaratDistricts,
      educationDegrees,
      abroadCountries,
      privateSectors,
      businessSectors,
      incomeRanges,
      religionOptions,
    };
  }
}
