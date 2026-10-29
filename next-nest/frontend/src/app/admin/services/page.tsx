"use client";

import React, { useEffect, useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { adminApi, SamajServiceItem, SamajServicePersonItem } from "@/lib/admin-api";

export interface ServiceCategoryConfig {
  id: string;
  name: string;
  gujarati: string;
  icon: string;
  dbCategory: string;
  color: string;
  iconsPalette: string[];
  presets: { title: string; icon: string }[];
}

export const MAIN_SERVICE_CATEGORIES: ServiceCategoryConfig[] = [
  {
    id: "wedding",
    name: "Wedding & Event Services",
    gujarati: "લગ્ન પ્રસંગ અને ઇવેન્ટ સેવાઓ",
    icon: "🎉",
    dbCategory: "Event & Wedding Planning",
    color: "#EC4899",
    iconsPalette: ["🎪", "📸", "🍲", "🚗", "🎵", "🥁", "💄", "🎨", "🏰", "💌", "🌸", "🎥", "🚌", "💍", "🚘", "👔", "⛺", "🖨️", "✨", "🚁", "🤹", "💁‍♀️", "🕯️", "🎆"],
    presets: [
      { title: "મંડપ ડેકોરેશન (Mandap & Shamiana)", icon: "🎪" },
      { title: "ફોટોગ્રાફી & વિડિયોગ્રાફી (Photography & Video)", icon: "📸" },
      { title: "કેટરિંગ અને રસોઈ (Catering & Halwai)", icon: "🍲" },
      { title: "ડીજે અને સાઉન્ડ સિસ્ટમ (DJ Sound System)", icon: "🎵" },
      { title: "બેન્ડ-વાજા અને ઢોલ (Brass Band & Dhol)", icon: "🥁" },
      { title: "બ્રાઇડલ મેકઅપ & બ્યુટી પાર્લર (Bridal Makeup)", icon: "💄" },
      { title: "મહેંદી ડિઝાઇનર (Mehendi Artist)", icon: "🎨" },
      { title: "વાડી અને પાર્ટી પ્લોટ બુકિંગ (Banquet Hall)", icon: "🏰" },
      { title: "કંકોતરી પ્રિન્ટિંગ (Kankotri Printing)", icon: "💌" },
      { title: "વરરાજા બગી & લક્ઝરી કાર (Groom Buggy & Car)", icon: "🚘" },
      { title: "સ્ટેજ & ફ્લાવર ડેકોરેશન (Flower & Stage Decor)", icon: "🌸" },
      { title: "શેરવાની & જ્વેલરી રેન્ટલ (Jewelry & Sherwani Rental)", icon: "💍" },
    ],
  },
  {
    id: "home",
    name: "Home & Daily Life Services",
    gujarati: "ઘર અને દૈનિક જીવનની સેવાઓ",
    icon: "🏠",
    dbCategory: "Home & Daily Life Services",
    color: "#F59E0B",
    iconsPalette: ["🏠", "🧱", "🎨", "🔧", "⚡", "❄️", "🪚", "🪟", "🚪", "🧹", "🐜", "🚚", "💡", "🛠️", "🚰", "🪑", "🪵", "🔩"],
    presets: [
      { title: "પ્લમ્બર સર્વિસ (Plumber)", icon: "🔧" },
      { title: "ઇલેક્ટ્રિશિયન & વાયરિંગ (Electrician)", icon: "⚡" },
      { title: "કલરકામ & પેઇન્ટિંગ (Painter)", icon: "🎨" },
      { title: "સુથારીકામ & ફર્નિચર (Carpenter)", icon: "🪚" },
      { title: "ઘર બાંધકામ & રાજ મિસ્ત્રી (Mason / Raj Mistri)", icon: "🧱" },
      { title: "એસી & ફ્રિજ રીપેર (AC / Fridge Repair)", icon: "❄️" },
      { title: "એલ્યુમિનિયમ & ગ્લાસ વર્ક (Aluminium & Glass)", icon: "🪟" },
      { title: "હાઉસ ક્લિનિંગ (House Cleaning)", icon: "🧹" },
      { title: "પેસ્ટ કંટ્રોલ (Pest Control)", icon: "🐜" },
      { title: "પેકર્સ એન્ડ મૂવર્સ (Packers & Movers)", icon: "🚚" },
    ],
  },
  {
    id: "vehicle",
    name: "Vehicle & Transport Services",
    gujarati: "વાહન અને પરિવહન સેવાઓ",
    icon: "🚗",
    dbCategory: "Vehicle & Transport",
    color: "#3B82F6",
    iconsPalette: ["🚗", "🛵", "🚘", "🛞", "🔋", "🚕", "🚌", "🚛", "🅿️", "⛽", "🧼", "🚲", "🔧", "🛢️"],
    presets: [
      { title: "કાર રેન્ટલ & બુકિંગ (Car Rental)", icon: "🚗" },
      { title: "ટેક્સી & કેબ સર્વિસ (Taxi / Cab)", icon: "🚕" },
      { title: "ટુ-વ્હીલર ગેરેજ (Bike / Scooter Repair)", icon: "🛵" },
      { title: "કાર રીપેર & ગેરેજ (Car Repair / Garage)", icon: "🚘" },
      { title: "ટાયર પંચર સર્વિસ (Tyre & Puncture)", icon: "🛞" },
      { title: "કાર બેટરી સર્વિસ (Battery Service)", icon: "🔋" },
      { title: "માલસામાન ટ્રાન્સપોર્ટ (Goods Transport)", icon: "🚛" },
      { title: "બસ અને ટેમ્પો બુકિંગ (Bus / Tempo)", icon: "🚌" },
      { title: "ડ્રાઇવર સર્વિસ (Driver Service)", icon: "🚗" },
    ],
  },
  {
    id: "digital",
    name: "Computer & Digital Services",
    gujarati: "કમ્પ્યુટર અને ડિજિટલ સેવાઓ",
    icon: "💻",
    dbCategory: "Computer & Digital Services",
    color: "#06B6D4",
    iconsPalette: ["💻", "🖨️", "📱", "🌐", "🎨", "📸", "🪪", "📄", "💳", "🖥️", "⌨️", "💾", "📡", "🖱️"],
    presets: [
      { title: "લેપટોપ & કમ્પ્યુટર રીપેર (Computer Repair)", icon: "💻" },
      { title: "મોબાઇલ રીપેરિંગ (Mobile Repair)", icon: "📱" },
      { title: "પ્રિન્ટર સર્વિસ & કાર્ટ્રેજ (Printer Repair)", icon: "🖨️" },
      { title: "ઓનલાઇન સરકારી ફોર્મ (Online Form Filling)", icon: "🪪" },
      { title: "ઝેરોક્ષ & પ્રિન્ટિંગ પ્રેસ (Printing / Xerox)", icon: "🖨️" },
      { title: "ફોટો સ્ટુડિયો (Photo Studio)", icon: "📸" },
      { title: "વેબસાઇટ ડેવલપમેન્ટ (Website Development)", icon: "🌐" },
      { title: "ગ્રાફિક ડિઝાઇનિંગ & બેનર (Graphic Design)", icon: "🎨" },
      { title: "દસ્તાવેજ સ્કેનિંગ & PDF (Document Scanning)", icon: "📄" },
    ],
  },
  {
    id: "education",
    name: "Education & Coaching Services",
    gujarati: "શિક્ષણ અને કોચિંગ સેવાઓ",
    icon: "📚",
    dbCategory: "Education Services",
    color: "#8B5CF6",
    iconsPalette: ["📚", "👨‍🏫", "🏫", "🎓", "📝", "💼", "🌍", "📖", "🗣️", "🏆", "✏️", "🎒", "🔬", "📐"],
    presets: [
      { title: "ટ્યુશન & કોચિંગ ક્લાસીસ (Tuition Classes)", icon: "👨‍🏫" },
      { title: "નર્સિંગ એકેડેમી (Nursing Academy)", icon: "🎓" },
      { title: "સ્પર્ધાત્મક પરીક્ષા કોચિંગ (GPSC / TET / TAT)", icon: "📝" },
      { title: "સ્કૂલ & કોલેજ એડમિશન ગાઇડન્સ", icon: "🏫" },
      { title: "વિદેશ અભ્યાસ માર્ગદર્શન (Foreign Study)", icon: "🌍" },
      { title: "પુસ્તકો અને સ્ટેશનરી (Books & Stationery)", icon: "📖" },
      { title: "કમ્પ્યુટર તાલીમ કેન્દ્ર (Computer Training)", icon: "💻" },
      { title: "સ્પોકન ઇંગ્લિશ ક્લાસ (English Speaking)", icon: "🗣️" },
    ],
  },
  {
    id: "jobs",
    name: "Job, Career & Business Services",
    gujarati: "નોકરી અને વ્યવસાય સેવાઓ",
    icon: "💼",
    dbCategory: "Job & Business Services",
    color: "#10B981",
    iconsPalette: ["💼", "👷", "🏢", "🏛️", "📄", "🏪", "🤝", "📈", "🧾", "👔", "📊", "🎯"],
    presets: [
      { title: "જોબ પ્લેસમેન્ટ માહિતી (Job Placement)", icon: "💼" },
      { title: "કુશળ કારીગર જોબ્સ (Skilled Worker Jobs)", icon: "👷" },
      { title: "સરકારી નોકરી માર્ગદર્શન (Govt Job Guidance)", icon: "🏛️" },
      { title: "રિઝ્યુમ / બાયોડેટા બનાવટ (Resume / CV)", icon: "📄" },
      { title: "ઇન્ટરવ્યુ તૈયારી (Interview Preparation)", icon: "💼" },
      { title: "સમાજ બિઝનેસ નેટવર્કિંગ (Business Networking)", icon: "🤝" },
      { title: "જીએસટી & ટેક્સ કન્સલ્ટન્ટ (GST & Tax)", icon: "🧾" },
    ],
  },
  {
    id: "legal",
    name: "Legal & Financial Services",
    gujarati: "કાનૂની અને નાણાકીય સેવાઓ",
    icon: "⚖️",
    dbCategory: "Legal & Financial Services",
    color: "#6366F1",
    iconsPalette: ["⚖️", "📑", "🏦", "💰", "🧾", "🏠", "📜", "💳", "🏢", "🪙", "🖊️", "💼"],
    presets: [
      { title: "એડવોકેટ / વકીલ કાનૂની સલાહ (Advocate)", icon: "⚖️" },
      { title: "દસ્તાવેજ લેખક & સોગંદનામા (Document Writer)", icon: "📑" },
      { title: "બેંક લોન સહાય (Bank Loan Assistance)", icon: "🏦" },
      { title: "જમીન-મિલકત રજીસ્ટ્રી (Property Registry)", icon: "🏠" },
      { title: "ઇન્કમ ટેક્સ & જીએસટી ફાઇલિંગ", icon: "🧾" },
      { title: "લાઇફ / મેડીક્લેમ ઇન્સ્યોરન્સ એજન્ટ", icon: "📜" },
      { title: "નાણાકીય સલાહકાર (Financial Consultant)", icon: "💰" },
    ],
  },
  {
    id: "health",
    name: "Health & Emergency Services",
    gujarati: "આરોગ્ય અને કટોકટી સેવાઓ",
    icon: "🏥",
    dbCategory: "Health & Emergency",
    color: "#EF4444",
    iconsPalette: ["🏥", "👨‍⚕️", "🦷", "👓", "💊", "🚑", "🩸", "🧪", "🧑‍⚕️", "♿", "🩺", "💉", "🩻"],
    presets: [
      { title: "હોસ્પિટલ અને ક્લિનિક (Hospital)", icon: "🏥" },
      { title: "સમાજ ડૉક્ટર્સ પેનલ (Doctor Panel)", icon: "👨‍⚕️" },
      { title: "દાંતના ડૉક્ટર (Dentist)", icon: "🦷" },
      { title: "આંખના ડૉક્ટર & ચશ્માઘર (Eye Care)", icon: "👓" },
      { title: "મેડિકલ સ્ટોર (Medical Store)", icon: "💊" },
      { title: "૨૪x૭ એમ્બ્યુલન્સ સેવા (Ambulance 24x7)", icon: "🚑" },
      { title: "બ્લડ ડોનર ડિરેક્ટરી (Blood Donor Directory)", icon: "🩸" },
      { title: "લેબોરેટરી & પેથોલોજી (Diagnostic Lab)", icon: "🧪" },
      { title: "ઘરબેઠા નર્સિંગ સેવા (Home Nursing)", icon: "🧑‍⚕️" },
    ],
  },
  {
    id: "shops",
    name: "Business, Trade & Local Shops",
    gujarati: "વેપાર અને સ્થાનિક દુકાનો",
    icon: "🏪",
    dbCategory: "Business & Local Shops",
    color: "#F97316",
    iconsPalette: ["🏪", "🛒", "👗", "👟", "📱", "💻", "🪑", "💎", "🍰", "🍽️", "🛍️", "🍕", "🧁", "🧵"],
    presets: [
      { title: "કરિયાણું અને પ્રોવિઝન (Grocery / Kirana)", icon: "🛒" },
      { title: "કાપડ અને રેડીમેડ ગારમેન્ટ્સ (Clothes)", icon: "👗" },
      { title: "શૂઝ અને ચંપલ (Footwear Shop)", icon: "👟" },
      { title: "સોના-ચાંદી જ્વેલર્સ (Jewellery)", icon: "💎" },
      { title: "મોબાઇલ & ઇલેક્ટ્રોનિક્સ શોપ", icon: "📱" },
      { title: "ફર્નિચર શોપ (Furniture Shop)", icon: "🪑" },
      { title: "બેકરી & સ્વીટ્સ (Bakery & Sweets)", icon: "🍰" },
      { title: "રેસ્ટોરન્ટ & ફૂડ ઝોન (Restaurant)", icon: "🍽️" },
    ],
  },
  {
    id: "skilled",
    name: "Skilled Technical Professionals",
    gujarati: "કુશળ કારીગરો અને ટેકનિશિયન",
    icon: "🧑‍🔧",
    dbCategory: "Skilled Professionals",
    color: "#14B8A6",
    iconsPalette: ["🧑‍🔧", "👨‍🔧", "🔧", "🪚", "🔨", "🧱", "🎨", "👨‍💻", "🚗", "📺", "❄️", "🛠️", "🪛", "🧰"],
    presets: [
      { title: "ઇલેક્ટ્રિશિયન ટેકનિશિયન (Electrician)", icon: "👨‍🔧" },
      { title: "પ્લમ્બર ટેકનિશિયન (Plumber)", icon: "🔧" },
      { title: "સુથાર કારીગર (Carpenter)", icon: "🪚" },
      { title: "વેલ્ડર & ફેબ્રિકેશન વર્ક (Welder)", icon: "🔨" },
      { title: "રાજ મિસ્ત્રી (Mason Trade)", icon: "🧱" },
      { title: "પેઇન્ટર કારીગર (Painter)", icon: "🎨" },
      { title: "એસી / રેફ્રિજરેશન ટેકનિશિયન (AC Tech)", icon: "❄️" },
      { title: "ટીવી & હોમ એપ્લાયન્સ ટેકનિશિયન", icon: "📺" },
    ],
  },
  {
    id: "agri",
    name: "Agriculture & Farming Services",
    gujarati: "ખેતીવાડી અને પશુપાલન સેવાઓ",
    icon: "🌾",
    dbCategory: "Agriculture & Farming",
    color: "#84CC16",
    iconsPalette: ["🌾", "🌱", "🧪", "🐛", "🌿", "🚜", "⚙️", "💧", "💦", "🐄", "🌳", "🥬", "🧑‍🌾", "🌻", "🍎"],
    presets: [
      { title: "બીયારણની દુકાન (Seed Shop)", icon: "🌱" },
      { title: "ખાતર અને જંતુનાશક દવા (Fertilizer & Agro Chem)", icon: "🧪" },
      { title: "ટ્રેક્ટર & ખેતીનાં સાધનો (Tractor & Farm Equipment)", icon: "🚜" },
      { title: "ડ્રિપ અને સિંચાઈ સાધનો (Drip Irrigation)", icon: "💧" },
      { title: "પશુ આહાર & ડેરી સાધનો (Cattle Feed & Dairy)", icon: "🐄" },
      { title: "પ્લાન્ટ નર્સરી (Plant Nursery)", icon: "🌳" },
      { title: "અનાજ ખરીદ-વેચાણ (Grain Trading)", icon: "🌾" },
    ],
  },
  {
    id: "trolley",
    name: "Trolley, Caster Wheel & Cane Products",
    gujarati: "ટ્રોલી, વ્હીલ અને વાંસ-કેન ઉદ્યોગ",
    icon: "🛒",
    dbCategory: "Trolley, Caster Wheel & Cane Products",
    color: "#EAB308",
    iconsPalette: ["🛒", "⚙️", "🔘", "🏭", "🧺", "🔧", "🚚", "🛍️", "🪑", "📦", "🧱", "🛠️"],
    presets: [
      { title: "ટ્રોલી ઉત્પાદક (Trolley Manufacturer)", icon: "🛒" },
      { title: "કાસ્ટર વ્હીલ સપ્લાયર (Caster Wheel)", icon: "⚙️" },
      { title: "ઇન્ડસ્ટ્રિયલ ટ્રોલી (Industrial Trolley)", icon: "🏭" },
      { title: "વાંસ & કેન પ્રોડક્ટ્સ (Cane Basket & Furniture)", icon: "🧺" },
      { title: "મટિરિયલ હેન્ડલિંગ સાધનો", icon: "🚚" },
      { title: "શોપિંગ & હોસ્પિટલ ટ્રોલી", icon: "🛍️" },
    ],
  },
  {
    id: "govt",
    name: "Government & Samaj Public Welfare",
    gujarati: "સરકારી અને સમાજ સહાયક સેવાઓ",
    icon: "🏛️",
    dbCategory: "Government & Samaj Public Services",
    color: "#64748B",
    iconsPalette: ["🏛️", "🪪", "📜", "🛡️", "📋", "🤝", "🌐", "🏢", "⚖️", "🇮🇳", "🗳️", "🕊️"],
    presets: [
      { title: "સરકારી યોજના માહિતી & સહાય (Govt Schemes)", icon: "🏛️" },
      { title: "જાતિ / આવક પ્રમાણપત્ર સહાય (Caste Certificate)", icon: "🪪" },
      { title: "રેશન કાર્ડ & આધાર કાર્ડ સહાય", icon: "📜" },
      { title: "સમાજવાડી & ટ્રસ્ટ હોલ બુકિંગ (Samaj Hall)", icon: "🏢" },
      { title: "વરિષ્ઠ નાગરિક સહાય (Senior Citizen Help)", icon: "🛡️" },
    ],
  },
  {
    id: "culture",
    name: "Art, Culture, Media & Entertainment",
    gujarati: "કલા, સંસ્કૃતિ અને મનોરંજન",
    icon: "🎨",
    dbCategory: "Art, Culture & Entertainment",
    color: "#A855F7",
    iconsPalette: ["🎨", "🎭", "🎬", "🎙️", "🎻", "📖", "✍️", "📸", "🎪", "📻", "🪕", "🎺", "🎸"],
    presets: [
      { title: "લોક કલાકારો & ભજન મંડળી (Folk Artists)", icon: "🎙️" },
      { title: "નાટક & સ્ટેજ કલાકારો (Drama & Stage)", icon: "🎭" },
      { title: "સમાજ લેખકો અને કવિઓ (Authors & Poets)", icon: "✍️" },
      { title: "સાંસ્કૃતિક કાર્યક્રમ આયોજક (Cultural Event)", icon: "🎪" },
      { title: "ઓડિયો & મ્યુઝિક રેકોર્ડિંગ સ્ટુડિયો", icon: "🎻" },
    ],
  },
];

export default function AdminServicesPage() {
  const [activeTab, setActiveTab] = useState<"services" | "persons">("services");
  
  // Data state
  const [services, setServices] = useState<SamajServiceItem[]>([]);
  const [persons, setPersons] = useState<SamajServicePersonItem[]>([]);
  const [loadingServices, setLoadingServices] = useState(true);
  const [loadingPersons, setLoadingPersons] = useState(true);

  // Service Modal state
  const [showServiceModal, setShowServiceModal] = useState(false);
  const [editingService, setEditingService] = useState<SamajServiceItem | null>(null);
  const [selectedMainCatId, setSelectedMainCatId] = useState<string>("wedding");
  const [svcTitle, setSvcTitle] = useState("");
  const [svcCategory, setSvcCategory] = useState("Event & Wedding Planning");
  const [svcIcon, setSvcIcon] = useState("🎪");
  const [svcPerson, setSvcPerson] = useState("");
  const [svcPhone, setSvcPhone] = useState("");
  const [svcDesc, setSvcDesc] = useState("");
  const [svcActive, setSvcActive] = useState(true);

  // Person Modal state
  const [showPersonModal, setShowPersonModal] = useState(false);
  const [editingPerson, setEditingPerson] = useState<SamajServicePersonItem | null>(null);
  const [personServiceId, setPersonServiceId] = useState("");
  const [personName, setPersonName] = useState("");
  const [personGujaratiName, setPersonGujaratiName] = useState("");
  const [personPhotoUrl, setPersonPhotoUrl] = useState("");
  const [personPhone, setPersonPhone] = useState("");
  const [personAddress, setPersonAddress] = useState("");
  const [personCity, setPersonCity] = useState("Ahmedabad");
  const [personExperience, setPersonExperience] = useState("5+ Years");
  const [personDesc, setPersonDesc] = useState("");
  const [personActive, setPersonActive] = useState(true);

  // Delete Confirm Modal State
  const [serviceToDelete, setServiceToDelete] = useState<SamajServiceItem | null>(null);
  const [personToDelete, setPersonToDelete] = useState<SamajServicePersonItem | null>(null);

  // Search and Category filters
  const [searchQuery, setSearchQuery] = useState("");
  const [categoryFilter, setCategoryFilter] = useState("ALL");

  const loadServices = async () => {
    try {
      setLoadingServices(true);
      const data = await adminApi.getSamajServices();
      setServices(data);
      if (data.length > 0 && !personServiceId) {
        setPersonServiceId(data[0].id);
      }
    } catch (e) {
      console.error("Failed to load services:", e);
    } finally {
      setLoadingServices(false);
    }
  };

  const loadPersons = async () => {
    try {
      setLoadingPersons(true);
      const data = await adminApi.getSamajServicePersons();
      setPersons(data);
    } catch (e) {
      console.error("Failed to load service persons:", e);
    } finally {
      setLoadingPersons(false);
    }
  };

  useEffect(() => {
    loadServices();
    loadPersons();
  }, []);

  // --- SERVICE ACTIONS ---
  const handleMainCatChange = (catId: string) => {
    setSelectedMainCatId(catId);
    const cat = MAIN_SERVICE_CATEGORIES.find((c) => c.id === catId);
    if (cat) {
      setSvcCategory(cat.dbCategory);
      setSvcIcon(cat.icon);
    }
  };

  const handleSelectPreset = (preset: { title: string; icon: string }) => {
    setSvcTitle(preset.title);
    setSvcIcon(preset.icon);
  };

  const handleSelectIcon = (icon: string) => {
    setSvcIcon(icon);
  };

  const openCreateService = () => {
    setEditingService(null);
    const defaultCat = MAIN_SERVICE_CATEGORIES[0];
    setSelectedMainCatId(defaultCat.id);
    setSvcCategory(defaultCat.dbCategory);
    setSvcTitle("");
    setSvcIcon(defaultCat.presets[0]?.icon || defaultCat.icon);
    setSvcPerson("");
    setSvcPhone("");
    setSvcDesc("");
    setSvcActive(true);
    setShowServiceModal(true);
  };

  const openEditService = (s: SamajServiceItem) => {
    setEditingService(s);
    setSvcTitle(s.title);
    setSvcCategory(s.category || "General");
    setSvcIcon(s.icon || "🤝");
    setSvcPerson(s.contactPerson || "");
    setSvcPhone(s.contactPhone || "");
    setSvcDesc(s.description || "");
    setSvcActive(s.isActive);

    const sCatLower = (s.category || "").toLowerCase();
    const matched = MAIN_SERVICE_CATEGORIES.find(
      (c) =>
        c.dbCategory.toLowerCase() === sCatLower ||
        c.name.toLowerCase() === sCatLower ||
        sCatLower.includes(c.id) ||
        c.dbCategory.toLowerCase().includes(sCatLower)
    );
    if (matched) {
      setSelectedMainCatId(matched.id);
    } else {
      setSelectedMainCatId(MAIN_SERVICE_CATEGORIES[0].id);
    }
    setShowServiceModal(true);
  };

  const handleServiceSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!svcTitle.trim()) return;

    try {
      if (editingService) {
        await adminApi.updateSamajService(editingService.id, {
          title: svcTitle,
          category: svcCategory,
          icon: svcIcon,
          contactPerson: svcPerson,
          contactPhone: svcPhone,
          description: svcDesc,
          isActive: svcActive,
        });
      } else {
        await adminApi.createSamajService({
          title: svcTitle,
          category: svcCategory,
          icon: svcIcon,
          contactPerson: svcPerson,
          contactPhone: svcPhone,
          description: svcDesc,
          isActive: svcActive,
        });
      }
      setShowServiceModal(false);
      loadServices();
    } catch (err: any) {
      console.error(err);
      alert("Failed to save service: " + (err?.message || "Unknown error"));
    }
  };

  const confirmDeleteService = async () => {
    if (!serviceToDelete) return;
    try {
      await adminApi.deleteSamajService(serviceToDelete.id);
      setServiceToDelete(null);
      loadServices();
      loadPersons();
    } catch (err: any) {
      console.error(err);
      alert("Failed to delete service: " + (err?.message || "Unknown error"));
    }
  };

  const toggleServiceStatus = async (item: SamajServiceItem) => {
    try {
      await adminApi.updateSamajService(item.id, { isActive: !item.isActive });
      loadServices();
    } catch (err) {
      console.error(err);
    }
  };

  // --- PERSON ACTIONS ---
  const openCreatePerson = () => {
    setEditingPerson(null);
    if (services.length > 0) {
      setPersonServiceId(services[0].id);
    }
    setPersonName("");
    setPersonGujaratiName("");
    setPersonPhotoUrl("");
    setPersonPhone("");
    setPersonAddress("");
    setPersonCity("Ahmedabad");
    setPersonExperience("5+ Years");
    setPersonDesc("");
    setPersonActive(true);
    setShowPersonModal(true);
  };

  const openEditPerson = (p: SamajServicePersonItem) => {
    setEditingPerson(p);
    setPersonServiceId(p.serviceId);
    setPersonName(p.name);
    setPersonGujaratiName(p.gujaratiName || "");
    setPersonPhotoUrl(p.photoUrl || "");
    setPersonPhone(p.phone);
    setPersonAddress(p.address || "");
    setPersonCity(p.city || "Ahmedabad");
    setPersonExperience(p.experience || "");
    setPersonDesc(p.description || "");
    setPersonActive(p.isActive);
    setShowPersonModal(true);
  };

  const handlePersonSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!personName.trim() || !personPhone.trim() || !personServiceId) {
      alert("Please fill in required fields (Service, Name, and Phone)");
      return;
    }

    try {
      if (editingPerson) {
        await adminApi.updateSamajServicePerson(editingPerson.id, {
          serviceId: personServiceId,
          name: personName,
          gujaratiName: personGujaratiName,
          photoUrl: personPhotoUrl,
          phone: personPhone,
          address: personAddress,
          city: personCity,
          experience: personExperience,
          description: personDesc,
          isActive: personActive,
        });
      } else {
        await adminApi.createSamajServicePerson({
          serviceId: personServiceId,
          name: personName,
          gujaratiName: personGujaratiName,
          photoUrl: personPhotoUrl,
          phone: personPhone,
          address: personAddress,
          city: personCity,
          experience: personExperience,
          description: personDesc,
          isActive: personActive,
        });
      }
      setShowPersonModal(false);
      loadPersons();
    } catch (err: any) {
      console.error(err);
      alert("Failed to save service person: " + (err?.message || "Unknown error"));
    }
  };

  const confirmDeletePerson = async () => {
    if (!personToDelete) return;
    try {
      await adminApi.deleteSamajServicePerson(personToDelete.id);
      setPersonToDelete(null);
      loadPersons();
    } catch (err: any) {
      console.error(err);
      alert("Failed to delete service person: " + (err?.message || "Unknown error"));
    }
  };

  const togglePersonStatus = async (item: SamajServicePersonItem) => {
    try {
      await adminApi.updateSamajServicePerson(item.id, { isActive: !item.isActive });
      loadPersons();
    } catch (err) {
      console.error(err);
    }
  };

  const filteredServices = services.filter((s) => {
    const matchesSearch =
      s.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (s.category && s.category.toLowerCase().includes(searchQuery.toLowerCase()));
    
    if (categoryFilter === "ALL") return matchesSearch;
    const catLower = categoryFilter.toLowerCase();
    const sCatLower = (s.category || "").toLowerCase();
    const matchesCat =
      sCatLower === catLower ||
      sCatLower.includes(catLower) ||
      catLower.includes(sCatLower);
    return matchesSearch && matchesCat;
  });

  const filteredPersons = persons.filter(
    (p) =>
      p.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (p.gujaratiName && p.gujaratiName.toLowerCase().includes(searchQuery.toLowerCase())) ||
      (p.phone && p.phone.includes(searchQuery)) ||
      (p.service?.title && p.service.title.toLowerCase().includes(searchQuery.toLowerCase()))
  );

  const currentMainCat = MAIN_SERVICE_CATEGORIES.find((c) => c.id === selectedMainCatId) || MAIN_SERVICE_CATEGORIES[0];
  const activePalette = Array.from(new Set([
    ...(currentMainCat?.iconsPalette || []),
    "🎪", "📸", "🍲", "🎵", "🥁", "💄", "🎨", "🏰", "💌", "🌸", "🚗", "⚡", "🔧", "🪚", "💻", "📱", "📚", "💼", "⚖️", "🏥", "🛒", "🌾", "🏛️", "🤝"
  ]));

  return (
    <AdminLayout title="Samaj Services" subtitle="Manage Vankar Samaj service categories & contact persons">
      <div  className="flex flex-col gap-6">
        
        {/* Page Header */}
        <div  className="flex justify-between items-center flex-wrap gap-4">
          <div>
            <h1  style={{ margin: 0 }} className="font-extrabold text-admin-gold text-2xl">
              🤝 Samaj Services & Persons Directory (સમાજ સેવાઓ)
            </h1>
            <p  style={{ color: "rgba(255, 255, 255, 0.7)", margin: "4px 0 0 0" }} className="text-sm">
              Manage relational Samaj Services (Categories) and associated Service Persons.
            </p>
          </div>

          <div  style={{ gap: "12px" }} className="flex">
            {activeTab === "services" ? (
              <button
                onClick={openCreateService}
                  style={{ padding: "12px 22px", background: "linear-gradient(90deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)", color: "#000", boxShadow: "0 0 15px rgba(212, 175, 55, 0.3)" }} className="flex items-center font-extrabold cursor-pointer text-sm gap-2 rounded-xl border-none" 
              >
                <span>✨</span>
                <span>Add Service Category</span>
              </button>
            ) : (
              <button
                onClick={openCreatePerson}
                  style={{ padding: "12px 22px", background: "linear-gradient(90deg, #10B981 0%, #A7F3D0 100%)", color: "#000", boxShadow: "0 0 15px rgba(16, 185, 129, 0.3)" }} className="flex items-center font-extrabold cursor-pointer text-sm gap-2 rounded-xl border-none" 
              >
                <span>👤</span>
                <span>Add Service Person</span>
              </button>
            )}
          </div>
        </div>

        {/* Tab Navigation */}
        <div  style={{ gap: "12px", borderBottom: "1.5px solid rgba(212, 175, 55, 0.3)", paddingBottom: "12px" }} className="flex">
          <button
            onClick={() => setActiveTab("services")}
            style={{
              padding: "10px 24px",
              borderRadius: "10px",
              border: activeTab === "services" ? "1.5px solid #D4AF37" : "1px solid rgba(255,255,255,0.1)",
              backgroundColor: activeTab === "services" ? "rgba(212, 175, 55, 0.2)" : "transparent",
              color: activeTab === "services" ? "#F3E5AB" : "rgba(255,255,255,0.6)",
              fontWeight: 800,
              fontSize: "14px",
              cursor: "pointer",
              display: "flex",
              alignItems: "center",
              gap: "8px",
            }}
          >
            <span>🛠️ Section 1: Samaj Services</span>
            <span  style={{ padding: "2px 8px", borderRadius: "10px", backgroundColor: "#D4AF37", color: "#000", fontWeight: 900 }} className="text-[11px]">
              {services.length}
            </span>
          </button>

          <button
            onClick={() => setActiveTab("persons")}
            style={{
              padding: "10px 24px",
              borderRadius: "10px",
              border: activeTab === "persons" ? "1.5px solid #10B981" : "1px solid rgba(255,255,255,0.1)",
              backgroundColor: activeTab === "persons" ? "rgba(16, 185, 129, 0.2)" : "transparent",
              color: activeTab === "persons" ? "#A7F3D0" : "rgba(255,255,255,0.6)",
              fontWeight: 800,
              fontSize: "14px",
              cursor: "pointer",
              display: "flex",
              alignItems: "center",
              gap: "8px",
            }}
          >
            <span>👥 Section 2: Service Persons</span>
            <span  style={{ padding: "2px 8px", borderRadius: "10px", backgroundColor: "#10B981", color: "#000", fontWeight: 900 }} className="text-[11px]">
              {persons.length}
            </span>
          </button>
        </div>

        {/* SECTION 1: SERVICES TAB */}
        {activeTab === "services" && (
          <div  style={{ backgroundColor: "#061224", border: "1.5px solid rgba(212, 175, 55, 0.3)", padding: "20px" }} className="rounded-2xl">
            <div  style={{ marginBottom: "16px" }} className="flex justify-between items-center flex-wrap gap-3">
              <div className="flex items-center gap-3 flex-1 flex-wrap">
                <input
                  type="text"
                  placeholder="Search services by title or category..."
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  style={{
                    width: "100%",
                    maxWidth: "360px",
                    padding: "10px 16px",
                    borderRadius: "10px",
                    backgroundColor: "#041026",
                    border: "1px solid rgba(212, 175, 55, 0.4)",
                    color: "#FFF",
                    fontSize: "14px",
                    outline: "none",
                  }}
                />

                <select
                  value={categoryFilter}
                  onChange={(e) => setCategoryFilter(e.target.value)}
                  style={{
                    padding: "10px 14px",
                    borderRadius: "10px",
                    backgroundColor: "#041026",
                    border: "1px solid rgba(212, 175, 55, 0.4)",
                    color: "#F3E5AB",
                    fontSize: "13px",
                    fontWeight: 600,
                    outline: "none",
                    cursor: "pointer",
                  }}
                >
                  <option value="ALL">🌟 All Categories (બધી કેટેગરીઝ)</option>
                  {MAIN_SERVICE_CATEGORIES.map((c) => (
                    <option key={c.id} value={c.dbCategory}>
                      {c.icon} {c.name} ({c.gujarati})
                    </option>
                  ))}
                </select>
              </div>

              {categoryFilter !== "ALL" && (
                <button
                  type="button"
                  onClick={() => setCategoryFilter("ALL")}
                  style={{
                    padding: "6px 14px",
                    borderRadius: "8px",
                    backgroundColor: "rgba(212, 175, 55, 0.15)",
                    border: "1px solid #D4AF37",
                    color: "#F3E5AB",
                    fontSize: "12px",
                    cursor: "pointer",
                    fontWeight: 700,
                  }}
                >
                  Clear Filter (સાફ કરો)
                </button>
              )}
            </div>

            {loadingServices ? (
              <div  style={{ padding: "40px" }} className="text-center text-admin-gold">Loading Samaj Services...</div>
            ) : filteredServices.length === 0 ? (
              <div  style={{ padding: "40px", color: "rgba(255, 255, 255, 0.6)" }} className="text-center">No services found. Click "Add Service Category" to add one.</div>
            ) : (
              <div style={{ overflowX: "auto" }}>
                <table  style={{ color: "#FFF" }} className="w-full border-collapse text-sm">
                  <thead>
                    <tr  style={{ borderBottom: "1.5px solid rgba(212, 175, 55, 0.3)" }} className="text-left">
                      <th  style={{ padding: "12px" }} className="text-admin-gold">Service Title</th>
                      <th  style={{ padding: "12px" }} className="text-admin-gold">Category</th>
                      <th  style={{ padding: "12px" }} className="text-admin-gold">Associated Persons</th>
                      <th  style={{ padding: "12px" }} className="text-admin-gold">Status</th>
                      <th  style={{ padding: "12px" }} className="text-right text-admin-gold">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {filteredServices.map((svc) => (
                      <tr key={svc.id} style={{ borderBottom: "1px solid rgba(255, 255, 255, 0.08)" }}>
                        <td  style={{ padding: "14px 12px" }} className="font-bold">
                          <span style={{ marginRight: "10px", fontSize: "18px" }}>{svc.icon || "🤝"}</span>
                          <span>{svc.title}</span>
                        </td>
                        <td style={{ padding: "14px 12px" }}>
                          <span  style={{ padding: "4px 10px", backgroundColor: "rgba(212, 175, 55, 0.15)", color: "#F3E5AB" }} className="font-semibold text-xs rounded-xl">
                            {svc.category || "General"}
                          </span>
                        </td>
                        <td style={{ padding: "14px 12px" }}>
                          <span  style={{ padding: "4px 10px", backgroundColor: "rgba(16, 185, 129, 0.15)", color: "#A7F3D0" }} className="font-bold text-xs rounded-xl">
                            👤 {svc._count?.persons || 0} Persons
                          </span>
                        </td>
                        <td style={{ padding: "14px 12px" }}>
                          <button
                            onClick={() => toggleServiceStatus(svc)}
                            style={{
                              padding: "4px 12px",
                              borderRadius: "20px",
                              border: "none",
                              fontSize: "12px",
                              fontWeight: 700,
                              cursor: "pointer",
                              backgroundColor: svc.isActive ? "rgba(16, 185, 129, 0.2)" : "rgba(239, 68, 68, 0.2)",
                              color: svc.isActive ? "#10B981" : "#EF4444",
                            }}
                          >
                            {svc.isActive ? "Active" : "Disabled"}
                          </button>
                        </td>
                        <td  style={{ padding: "14px 12px" }} className="text-right">
                          <button
                            onClick={() => openEditService(svc)}
                            style={{
                              padding: "6px 14px",
                              marginRight: "8px",
                              borderRadius: "8px",
                              backgroundColor: "rgba(212, 175, 55, 0.2)",
                              border: "1px solid #D4AF37",
                              color: "#F3E5AB",
                              cursor: "pointer",
                              fontSize: "12px",
                              fontWeight: 700,
                            }}
                          >
                            Edit
                          </button>
                          <button
                            onClick={() => setServiceToDelete(svc)}
                            style={{
                              padding: "6px 14px",
                              borderRadius: "8px",
                              backgroundColor: "rgba(239, 68, 68, 0.2)",
                              border: "1px solid #EF4444",
                              color: "#FCA5A5",
                              cursor: "pointer",
                              fontSize: "12px",
                              fontWeight: 700,
                            }}
                          >
                            Delete
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        )}

        {/* SECTION 2: SERVICE PERSONS TAB */}
        {activeTab === "persons" && (
          <div  style={{ backgroundColor: "#061224", border: "1.5px solid rgba(16, 185, 129, 0.3)", padding: "20px" }} className="rounded-2xl">
            <div  style={{ marginBottom: "16px" }} className="flex justify-between items-center">
              <input
                type="text"
                placeholder="Search persons by name, Gujarati name, phone, or service..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                style={{
                  width: "100%",
                  maxWidth: "400px",
                  padding: "10px 16px",
                  borderRadius: "10px",
                  backgroundColor: "#041026",
                  border: "1px solid rgba(16, 185, 129, 0.4)",
                  color: "#FFF",
                  fontSize: "14px",
                  outline: "none",
                }}
              />
            </div>

            {loadingPersons ? (
              <div  style={{ padding: "40px", color: "#10B981" }} className="text-center">Loading Service Persons...</div>
            ) : filteredPersons.length === 0 ? (
              <div  style={{ padding: "40px", color: "rgba(255, 255, 255, 0.6)" }} className="text-center">No service persons registered yet. Click "Add Service Person" above to add one.</div>
            ) : (
              <div style={{ overflowX: "auto" }}>
                <table  style={{ color: "#FFF" }} className="w-full border-collapse text-sm">
                  <thead>
                    <tr  style={{ borderBottom: "1.5px solid rgba(16, 185, 129, 0.3)" }} className="text-left">
                      <th style={{ padding: "12px", color: "#A7F3D0" }}>Person Name</th>
                      <th style={{ padding: "12px", color: "#A7F3D0" }}>Gujarati Name</th>
                      <th style={{ padding: "12px", color: "#A7F3D0" }}>Assigned Service</th>
                      <th style={{ padding: "12px", color: "#A7F3D0" }}>Phone</th>
                      <th style={{ padding: "12px", color: "#A7F3D0" }}>City / Locality</th>
                      <th style={{ padding: "12px", color: "#A7F3D0" }}>Status</th>
                      <th  style={{ padding: "12px", color: "#A7F3D0" }} className="text-right">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {filteredPersons.map((person) => (
                      <tr key={person.id} style={{ borderBottom: "1px solid rgba(255, 255, 255, 0.08)" }}>
                        <td  style={{ padding: "14px 12px" }} className="font-bold">
                          <span  style={{ marginRight: "10px" }} className="text-base">👤</span>
                          <span>{person.name}</span>
                        </td>
                        <td style={{ padding: "14px 12px", color: "rgba(255, 255, 255, 0.85)", fontFamily: "sans-serif" }}>
                          {person.gujaratiName || "-"}
                        </td>
                        <td style={{ padding: "14px 12px" }}>
                          <span  style={{ padding: "4px 10px", backgroundColor: "rgba(212, 175, 55, 0.15)", color: "#F3E5AB" }} className="font-bold text-xs rounded-xl">
                            {person.service?.icon || "🤝"} {person.service?.title || "Service"}
                          </span>
                        </td>
                        <td  style={{ padding: "14px 12px", color: "#10B981" }} className="font-bold">{person.phone}</td>
                        <td style={{ padding: "14px 12px", color: "rgba(255, 255, 255, 0.8)" }}>{person.city || "Ahmedabad"}</td>
                        <td style={{ padding: "14px 12px" }}>
                          <button
                            onClick={() => togglePersonStatus(person)}
                            style={{
                              padding: "4px 12px",
                              borderRadius: "20px",
                              border: "none",
                              fontSize: "12px",
                              fontWeight: 700,
                              cursor: "pointer",
                              backgroundColor: person.isActive ? "rgba(16, 185, 129, 0.2)" : "rgba(239, 68, 68, 0.2)",
                              color: person.isActive ? "#10B981" : "#EF4444",
                            }}
                          >
                            {person.isActive ? "Active" : "Disabled"}
                          </button>
                        </td>
                        <td  style={{ padding: "14px 12px" }} className="text-right">
                          <button
                            onClick={() => openEditPerson(person)}
                            style={{
                              padding: "6px 14px",
                              marginRight: "8px",
                              borderRadius: "8px",
                              backgroundColor: "rgba(16, 185, 129, 0.2)",
                              border: "1px solid #10B981",
                              color: "#A7F3D0",
                              cursor: "pointer",
                              fontSize: "12px",
                              fontWeight: 700,
                            }}
                          >
                            Edit
                          </button>
                          <button
                            onClick={() => setPersonToDelete(person)}
                            style={{
                              padding: "6px 14px",
                              borderRadius: "8px",
                              backgroundColor: "rgba(239, 68, 68, 0.2)",
                              border: "1px solid #EF4444",
                              color: "#FCA5A5",
                              cursor: "pointer",
                              fontSize: "12px",
                              fontWeight: 700,
                            }}
                          >
                            Delete
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        )}

        {/* MODAL: ADD / EDIT SAMAJ SERVICE */}
        {showServiceModal && (
          <div
            style={{
              inset: 0,
              backgroundColor: "rgba(0, 0, 0, 0.88)",
              zIndex: 100,
              padding: "16px",
              backdropFilter: "blur(4px)",
            }}
            className="flex justify-center items-center fixed overflow-y-auto"
          >
            <div
              style={{
                backgroundColor: "#061224",
                border: "2px solid #D4AF37",
                maxWidth: "650px",
                color: "#FFF",
                boxShadow: "0 0 35px rgba(212, 175, 55, 0.35)",
                maxHeight: "92vh",
                overflowY: "auto",
              }}
              className="w-full p-6 rounded-2xl flex flex-col gap-4"
            >
              {/* Modal Header */}
              <div
                style={{
                  borderBottom: "1px solid rgba(212, 175, 55, 0.3)",
                  paddingBottom: "12px",
                }}
                className="flex justify-between items-center"
              >
                <div>
                  <h2
                    style={{ fontSize: "19px", margin: 0 }}
                    className="font-extrabold text-admin-gold"
                  >
                    {editingService
                      ? "✏️ Edit Samaj Service Category"
                      : "✨ Add New Samaj Service Category"}
                  </h2>
                  <p
                    style={{
                      color: "rgba(255, 255, 255, 0.7)",
                      fontSize: "12px",
                      margin: "4px 0 0 0",
                    }}
                  >
                    Select main category, enter sub-service title, pick logo & save.
                  </p>
                </div>
                <button
                  type="button"
                  onClick={() => setShowServiceModal(false)}
                  style={{
                    backgroundColor: "transparent",
                    border: "none",
                    color: "rgba(255, 255, 255, 0.6)",
                    fontSize: "22px",
                    cursor: "pointer",
                    padding: "4px 8px",
                  }}
                >
                  ✕
                </button>
              </div>

              <form onSubmit={handleServiceSubmit} className="flex flex-col gap-4">
                {/* BOX 1: MAIN SERVICE CATEGORY (14 CATEGORIES) */}
                <div
                  style={{
                    backgroundColor: "#081938",
                    border: "1.5px solid rgba(212, 175, 55, 0.5)",
                    borderRadius: "12px",
                    padding: "14px",
                  }}
                >
                  <label
                    style={{
                      color: "#F3E5AB",
                      display: "block",
                      marginBottom: "6px",
                    }}
                    className="font-bold text-xs uppercase tracking-wide"
                  >
                    ૧. મુખ્ય સેવા કેટેગરી પસંદ કરો (Box 1: Main Service Category - 14 Categories) *
                  </label>
                  <select
                    value={selectedMainCatId}
                    onChange={(e) => handleMainCatChange(e.target.value)}
                    style={{
                      width: "100%",
                      padding: "12px",
                      borderRadius: "8px",
                      backgroundColor: "#041026",
                      border: "1.5px solid #D4AF37",
                      color: "#FFF",
                      fontSize: "14px",
                      fontWeight: 600,
                      outline: "none",
                      cursor: "pointer",
                    }}
                  >
                    {MAIN_SERVICE_CATEGORIES.map((cat, idx) => (
                      <option key={cat.id} value={cat.id}>
                        {cat.icon} {idx + 1}. {cat.name} ({cat.gujarati})
                      </option>
                    ))}
                  </select>
                  <div
                    style={{
                      color: "rgba(255,255,255,0.6)",
                      fontSize: "11px",
                      marginTop: "6px",
                    }}
                  >
                    📍 Database Mapping Category:{" "}
                    <span style={{ color: "#D4AF37", fontWeight: 700 }}>
                      {svcCategory}
                    </span>
                  </div>
                </div>

                {/* BOX 2: SUB-SERVICE TITLE / NAME */}
                <div
                  style={{
                    backgroundColor: "#081938",
                    border: "1.5px solid rgba(212, 175, 55, 0.5)",
                    borderRadius: "12px",
                    padding: "14px",
                  }}
                >
                  <label
                    style={{
                      color: "#F3E5AB",
                      display: "block",
                      marginBottom: "6px",
                    }}
                    className="font-bold text-xs uppercase tracking-wide"
                  >
                    ૨. નવી સેવાનું નામ (Box 2: Sub-Service Title / Name) *
                  </label>
                  <input
                    type="text"
                    required
                    value={svcTitle}
                    onChange={(e) => setSvcTitle(e.target.value)}
                    placeholder={
                      currentMainCat?.presets[0]?.title
                        ? `દા.ત. ${currentMainCat.presets[0].title}`
                        : "દા.ત. Mandap & Decoration / મંડપ ડેકોરેશન"
                    }
                    style={{
                      width: "100%",
                      padding: "11px 14px",
                      borderRadius: "8px",
                      backgroundColor: "#041026",
                      border: "1px solid rgba(212, 175, 55, 0.4)",
                      color: "#FFF",
                      fontSize: "14px",
                      outline: "none",
                    }}
                  />

                  {/* Preset quick suggestion chips */}
                  {currentMainCat?.presets && currentMainCat.presets.length > 0 && (
                    <div style={{ marginTop: "10px" }}>
                      <div
                        style={{
                          color: "rgba(255, 255, 255, 0.7)",
                          fontSize: "11px",
                          marginBottom: "6px",
                        }}
                      >
                        💡 ઝડપી પસંદગી માટે ક્લિક કરો (Quick Presets):
                      </div>
                      <div style={{ display: "flex", flexWrap: "wrap", gap: "6px" }}>
                        {currentMainCat.presets.map((preset) => {
                          const isSelected = svcTitle === preset.title;
                          return (
                            <button
                              key={preset.title}
                              type="button"
                              onClick={() => handleSelectPreset(preset)}
                              style={{
                                padding: "4px 10px",
                                borderRadius: "14px",
                                backgroundColor: isSelected
                                  ? "rgba(212, 175, 55, 0.3)"
                                  : "rgba(255, 255, 255, 0.08)",
                                border: isSelected
                                  ? "1.5px solid #D4AF37"
                                  : "1px solid rgba(255, 255, 255, 0.15)",
                                color: isSelected
                                  ? "#F3E5AB"
                                  : "rgba(255, 255, 255, 0.85)",
                                fontSize: "11.5px",
                                cursor: "pointer",
                                transition: "all 0.15s ease",
                              }}
                            >
                              <span>{preset.icon}</span> {preset.title}
                            </button>
                          );
                        })}
                      </div>
                    </div>
                  )}
                </div>

                {/* BOX 3: VISUAL LOGO / ICON SELECTION BOX */}
                <div
                  style={{
                    backgroundColor: "#081938",
                    border: "1.5px solid rgba(212, 175, 55, 0.5)",
                    borderRadius: "12px",
                    padding: "14px",
                  }}
                >
                  <div
                    style={{
                      display: "flex",
                      justifyContent: "space-between",
                      alignItems: "center",
                      marginBottom: "8px",
                    }}
                  >
                    <label
                      style={{ color: "#F3E5AB", margin: 0 }}
                      className="font-bold text-xs uppercase tracking-wide"
                    >
                      ૩. સર્વિસ લોગો / આઇકોન પસંદ કરો (Box 3: Service Logo Grid) *
                    </label>
                    <div
                      style={{
                        padding: "3px 10px",
                        borderRadius: "12px",
                        backgroundColor: "rgba(212, 175, 55, 0.2)",
                        border: "1px solid #D4AF37",
                        color: "#F3E5AB",
                        fontSize: "12px",
                        fontWeight: 700,
                        display: "flex",
                        alignItems: "center",
                        gap: "6px",
                      }}
                    >
                      <span>Selected Logo:</span>
                      <span style={{ fontSize: "16px" }}>{svcIcon || "🤝"}</span>
                    </div>
                  </div>

                  <div
                    style={{
                      color: "rgba(255, 255, 255, 0.6)",
                      fontSize: "11px",
                      marginBottom: "8px",
                    }}
                  >
                    નીચેના લોગોમાંથી કોઈપણ પર ક્લિક કરો (Click any logo below to select):
                  </div>

                  {/* Logo Picker Grid */}
                  <div
                    style={{
                      display: "grid",
                      gridTemplateColumns: "repeat(auto-fill, minmax(42px, 1fr))",
                      gap: "8px",
                      backgroundColor: "#041026",
                      padding: "10px",
                      borderRadius: "8px",
                      border: "1px solid rgba(212, 175, 55, 0.3)",
                      maxHeight: "150px",
                      overflowY: "auto",
                    }}
                  >
                    {activePalette.map((icon, idx) => {
                      const isPicked = svcIcon === icon;
                      return (
                        <button
                          key={`${icon}-${idx}`}
                          type="button"
                          onClick={() => handleSelectIcon(icon)}
                          style={{
                            width: "42px",
                            height: "42px",
                            borderRadius: "8px",
                            backgroundColor: isPicked
                              ? "rgba(212, 175, 55, 0.35)"
                              : "rgba(255, 255, 255, 0.05)",
                            border: isPicked
                              ? "2px solid #D4AF37"
                              : "1px solid rgba(255, 255, 255, 0.1)",
                            fontSize: "20px",
                            cursor: "pointer",
                            display: "flex",
                            alignItems: "center",
                            justifyContent: "center",
                            boxShadow: isPicked
                              ? "0 0 10px rgba(212, 175, 55, 0.5)"
                              : "none",
                            transform: isPicked ? "scale(1.08)" : "scale(1)",
                            transition: "all 0.15s ease",
                          }}
                          title={`Select ${icon}`}
                        >
                          {icon}
                        </button>
                      );
                    })}
                  </div>

                  {/* Custom emoji/icon text input */}
                  <div
                    style={{
                      display: "flex",
                      alignItems: "center",
                      gap: "10px",
                      marginTop: "10px",
                    }}
                  >
                    <span
                      style={{
                        color: "rgba(255, 255, 255, 0.7)",
                        fontSize: "11px",
                      }}
                    >
                      અથવા કસ્ટમ ઇમોજી/ટેક્સ્ટ લખો:
                    </span>
                    <input
                      type="text"
                      value={svcIcon}
                      onChange={(e) => setSvcIcon(e.target.value)}
                      placeholder="e.g. 🎪"
                      style={{
                        width: "80px",
                        padding: "6px 10px",
                        borderRadius: "6px",
                        backgroundColor: "#041026",
                        border: "1px solid rgba(212, 175, 55, 0.4)",
                        color: "#FFF",
                        fontSize: "14px",
                        textAlign: "center",
                      }}
                    />
                  </div>
                </div>

                {/* BOX 4: SERVICE DESCRIPTION & APP STATUS */}
                <div
                  style={{
                    backgroundColor: "#081938",
                    border: "1.5px solid rgba(212, 175, 55, 0.5)",
                    borderRadius: "12px",
                    padding: "14px",
                  }}
                >
                  <label
                    style={{
                      color: "#F3E5AB",
                      display: "block",
                      marginBottom: "6px",
                    }}
                    className="font-bold text-xs uppercase tracking-wide"
                  >
                    ૪. સર્વિસ વિગત અને એપ્લિકેશન સક્રિયતા (Box 4: Details & Visibility)
                  </label>
                  <textarea
                    rows={3}
                    value={svcDesc}
                    onChange={(e) => setSvcDesc(e.target.value)}
                    placeholder="આ સર્વિસ વિશે ટૂંકી વિગત લખો (દા.ત. લગ્ન પ્રસંગ માટે મંડપ, લાઇટિંગ અને સ્ટેજ ડેકોરેશન સેવા)..."
                    style={{
                      width: "100%",
                      padding: "10px 14px",
                      borderRadius: "8px",
                      backgroundColor: "#041026",
                      border: "1px solid rgba(212, 175, 55, 0.4)",
                      color: "#FFF",
                      fontSize: "13px",
                      outline: "none",
                      resize: "vertical",
                    }}
                  />

                  <div
                    style={{ marginTop: "10px" }}
                    className="flex items-center gap-2"
                  >
                    <input
                      type="checkbox"
                      id="svcActiveCheck"
                      checked={svcActive}
                      onChange={(e) => setSvcActive(e.target.checked)}
                      style={{
                        width: "16px",
                        height: "16px",
                        cursor: "pointer",
                        accentColor: "#D4AF37",
                      }}
                    />
                    <label
                      htmlFor="svcActiveCheck"
                      style={{ color: "#FFF", cursor: "pointer" }}
                      className="text-[13px] font-semibold"
                    >
                      Make Active in Flutter Mobile App (મોબાઇલ એપ્લિકેશનમાં લાઇવ બતાવો)
                    </label>
                  </div>
                </div>

                {/* SUBMIT BUTTONS */}
                <div
                  style={{ marginTop: "6px" }}
                  className="flex justify-end gap-[10px]"
                >
                  <button
                    type="button"
                    onClick={() => setShowServiceModal(false)}
                    style={{
                      padding: "10px 20px",
                      borderRadius: "8px",
                      backgroundColor: "transparent",
                      border: "1px solid rgba(255,255,255,0.3)",
                      color: "#FFF",
                      cursor: "pointer",
                      fontWeight: 600,
                    }}
                  >
                    Cancel (રદ કરો)
                  </button>
                  <button
                    type="submit"
                    style={{
                      backgroundColor: "#D4AF37",
                      color: "#000",
                      boxShadow: "0 0 15px rgba(212, 175, 55, 0.4)",
                    }}
                    className="font-extrabold cursor-pointer rounded-lg border-none py-2.5 px-[24px] text-sm"
                  >
                    {editingService
                      ? "💾 Save Changes (સાચવો)"
                      : "✨ Create Service (સેવા બનાવો)"}
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}

        {/* MODAL: ADD / EDIT SERVICE PERSON */}
        {showPersonModal && (
          <div  style={{ inset: 0, backgroundColor: "rgba(0, 0, 0, 0.85)", zIndex: 100, padding: "20px" }} className="flex justify-center items-center fixed">
            <div  style={{ backgroundColor: "#061224", border: "2px solid #10B981", maxWidth: "560px", color: "#FFF", boxShadow: "0 0 30px rgba(16, 185, 129, 0.3)" }} className="w-full p-6 rounded-2xl">
              <h2  style={{ fontSize: "18px", color: "#10B981", margin: "0 0 16px 0" }} className="font-extrabold">
                {editingPerson ? "Edit Service Person Details" : "Add Service Person under Category"}
              </h2>

              <form onSubmit={handlePersonSubmit}  className="flex flex-col gap-[14px]">
                <div>
                  <label  style={{ color: "#A7F3D0", display: "block", marginBottom: "4px" }} className="font-bold text-xs">
                    Select Associated Samaj Service Category *
                  </label>
                  <select
                    required
                    value={personServiceId}
                    onChange={(e) => setPersonServiceId(e.target.value)}
                    style={{ width: "100%", padding: "10px", borderRadius: "8px", backgroundColor: "#041026", border: "1px solid rgba(16, 185, 129, 0.4)", color: "#FFF", fontSize: "14px" }}
                  >
                    {services.map((s) => (
                      <option key={s.id} value={s.id}>
                        {s.icon || "🤝"} {s.title} ({s.category || "General"})
                      </option>
                    ))}
                  </select>
                </div>

                <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "12px" }}>
                  <div>
                    <label  style={{ color: "#A7F3D0", display: "block", marginBottom: "4px" }} className="font-bold text-xs">
                      Person Full Name (English) *
                    </label>
                    <input
                      type="text"
                      required
                      value={personName}
                      onChange={(e) => setPersonName(e.target.value)}
                      placeholder="e.g. Rameshbhai Vankar"
                      style={{ width: "100%", padding: "10px", borderRadius: "8px", backgroundColor: "#041026", border: "1px solid rgba(16, 185, 129, 0.4)", color: "#FFF" }}
                    />
                  </div>

                  <div>
                    <label  style={{ color: "#A7F3D0", display: "block", marginBottom: "4px" }} className="font-bold text-xs">
                      Gujarati Name (ગુજરાતી નામ)
                    </label>
                    <input
                      type="text"
                      value={personGujaratiName}
                      onChange={(e) => setPersonGujaratiName(e.target.value)}
                      placeholder="દા.ત. રમેશભાઈ વણકર"
                      style={{ width: "100%", padding: "10px", borderRadius: "8px", backgroundColor: "#041026", border: "1px solid rgba(16, 185, 129, 0.4)", color: "#FFF" }}
                    />
                  </div>
                </div>

                <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "12px" }}>
                  <div>
                    <label  style={{ color: "#A7F3D0", display: "block", marginBottom: "4px" }} className="font-bold text-xs">
                      Phone Number *
                    </label>
                    <input
                      type="text"
                      required
                      value={personPhone}
                      onChange={(e) => setPersonPhone(e.target.value)}
                      placeholder="+91 98765 43210"
                      style={{ width: "100%", padding: "10px", borderRadius: "8px", backgroundColor: "#041026", border: "1px solid rgba(16, 185, 129, 0.4)", color: "#FFF" }}
                    />
                  </div>

                  <div>
                    <label  style={{ color: "#A7F3D0", display: "block", marginBottom: "4px" }} className="font-bold text-xs">
                      City / Area Location
                    </label>
                    <input
                      type="text"
                      value={personCity}
                      onChange={(e) => setPersonCity(e.target.value)}
                      placeholder="e.g. Ahmedabad / Vadodara"
                      style={{ width: "100%", padding: "10px", borderRadius: "8px", backgroundColor: "#041026", border: "1px solid rgba(16, 185, 129, 0.4)", color: "#FFF" }}
                    />
                  </div>
                </div>

                <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "12px" }}>
                  <div>
                    <label  style={{ color: "#A7F3D0", display: "block", marginBottom: "4px" }} className="font-bold text-xs">
                      Experience
                    </label>
                    <input
                      type="text"
                      value={personExperience}
                      onChange={(e) => setPersonExperience(e.target.value)}
                      placeholder="e.g. 5+ Years"
                      style={{ width: "100%", padding: "10px", borderRadius: "8px", backgroundColor: "#041026", border: "1px solid rgba(16, 185, 129, 0.4)", color: "#FFF" }}
                    />
                  </div>

                  <div>
                    <label  style={{ color: "#A7F3D0", display: "block", marginBottom: "4px" }} className="font-bold text-xs">
                      Photo URL (Optional)
                    </label>
                    <input
                      type="text"
                      value={personPhotoUrl}
                      onChange={(e) => setPersonPhotoUrl(e.target.value)}
                      placeholder="https://..."
                      style={{ width: "100%", padding: "10px", borderRadius: "8px", backgroundColor: "#041026", border: "1px solid rgba(16, 185, 129, 0.4)", color: "#FFF" }}
                    />
                  </div>
                </div>

                <div>
                  <label  style={{ color: "#A7F3D0", display: "block", marginBottom: "4px" }} className="font-bold text-xs">
                    Address / Workplace Details
                  </label>
                  <textarea
                    rows={2}
                    value={personAddress}
                    onChange={(e) => setPersonAddress(e.target.value)}
                    placeholder="Full workplace address..."
                    style={{ width: "100%", padding: "10px", borderRadius: "8px", backgroundColor: "#041026", border: "1px solid rgba(16, 185, 129, 0.4)", color: "#FFF" }}
                  />
                </div>

                <div  className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    id="personActiveCheck"
                    checked={personActive}
                    onChange={(e) => setPersonActive(e.target.checked)}
                  />
                  <label htmlFor="personActiveCheck"  style={{ color: "#FFF" }} className="text-[13px]">
                    Publish person profile actively in mobile app
                  </label>
                </div>

                <div  style={{ marginTop: "12px" }} className="flex justify-end gap-[10px]">
                  <button
                    type="button"
                    onClick={() => setShowPersonModal(false)}
                    style={{ padding: "10px 18px", borderRadius: "8px", backgroundColor: "transparent", border: "1px solid rgba(255,255,255,0.3)", color: "#FFF", cursor: "pointer" }}
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                      style={{ backgroundColor: "#10B981", color: "#000" }} className="font-extrabold cursor-pointer rounded-lg border-none py-2.5 px-[22px]" 
                  >
                    {editingPerson ? "Save Changes" : "Create Person"}
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}

        {/* CASCADING DELETE CONFIRMATION MODAL FOR SERVICE */}
        {serviceToDelete && (
          <div  style={{ inset: 0, backgroundColor: "rgba(0, 0, 0, 0.85)", zIndex: 110, padding: "20px" }} className="flex justify-center items-center fixed">
            <div  style={{ backgroundColor: "#061224", border: "2px solid #EF4444", maxWidth: "480px", color: "#FFF", boxShadow: "0 0 30px rgba(239, 68, 68, 0.4)" }} className="w-full p-6 rounded-2xl">
              <div style={{ fontSize: "36px", marginBottom: "8px" }}>⚠️</div>
              <h2  style={{ fontSize: "18px", color: "#EF4444", margin: "0 0 8px 0" }} className="font-extrabold">
                Confirm Service Deletion
              </h2>
              <p  style={{ color: "rgba(255, 255, 255, 0.9)", lineHeight: 1.5, margin: "0 0 16px 0" }} className="text-sm">
                Deleting this service (<strong>{serviceToDelete.title}</strong>) will also automatically remove all service persons associated with this service!
              </p>
              <div   style={{ padding: "12px", backgroundColor: "rgba(239, 68, 68, 0.15)", border: "1px solid rgba(239, 68, 68, 0.3)", marginBottom: "20px" }} className="text-xs rounded-lg text-red-300" >
                💡 <strong>Recommended:</strong> Instead of deleting, you can click "Disable / Deactivate" in the table to hide this service from the Flutter app without deleting historical data.
              </div>
              <div  className="flex justify-end gap-[10px]">
                <button
                  onClick={() => setServiceToDelete(null)}
                  style={{ padding: "10px 18px", borderRadius: "8px", backgroundColor: "transparent", border: "1px solid rgba(255,255,255,0.3)", color: "#FFF", cursor: "pointer" }}
                >
                  Cancel
                </button>
                <button
                  onClick={confirmDeleteService}
                    style={{ backgroundColor: "#EF4444", color: "#FFF" }} className="font-extrabold cursor-pointer rounded-lg border-none py-2.5 px-[22px]" 
                >
                  Yes, Delete Service & Persons
                </button>
              </div>
            </div>
          </div>
        )}

        {/* DELETE CONFIRMATION MODAL FOR PERSON */}
        {personToDelete && (
          <div  style={{ inset: 0, backgroundColor: "rgba(0, 0, 0, 0.85)", zIndex: 110, padding: "20px" }} className="flex justify-center items-center fixed">
            <div  style={{ backgroundColor: "#061224", border: "2px solid #EF4444", maxWidth: "440px", color: "#FFF", boxShadow: "0 0 30px rgba(239, 68, 68, 0.4)" }} className="w-full p-6 rounded-2xl">
              <h2  style={{ fontSize: "18px", color: "#EF4444", margin: "0 0 8px 0" }} className="font-extrabold">
                Delete Service Person
              </h2>
              <p  style={{ color: "rgba(255, 255, 255, 0.9)", margin: "0 0 20px 0" }} className="text-sm">
                Are you sure you want to remove <strong>{personToDelete.name}</strong> from the service directory?
              </p>
              <div  className="flex justify-end gap-[10px]">
                <button
                  onClick={() => setPersonToDelete(null)}
                  style={{ padding: "10px 18px", borderRadius: "8px", backgroundColor: "transparent", border: "1px solid rgba(255,255,255,0.3)", color: "#FFF", cursor: "pointer" }}
                >
                  Cancel
                </button>
                <button
                  onClick={confirmDeletePerson}
                    style={{ backgroundColor: "#EF4444", color: "#FFF" }} className="font-extrabold cursor-pointer rounded-lg border-none py-2.5 px-[22px]" 
                >
                  Delete Person
                </button>
              </div>
            </div>
          </div>
        )}

      </div>
    </AdminLayout>
  );
}
