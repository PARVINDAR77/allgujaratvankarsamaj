"use client";

import React, { useState, useEffect } from "react";
import Image from "next/image";
import Link from "next/link";

interface ServiceItem {
  id: string;
  title: string;
  category?: string;
  icon?: string;
  contactPerson?: string;
  contactPhone?: string;
  description?: string;
  _count?: { persons: number };
}

interface ServicePerson {
  id: string;
  name: string;
  gujaratiName?: string;
  photoUrl?: string;
  phone: string;
  address?: string;
  city?: string;
  description?: string;
  experience?: string;
}

export default function ServicesPage() {
  const [services, setServices] = useState<ServiceItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("ALL");

  // Selected Service Detail Modal
  const [activeService, setActiveService] = useState<ServiceItem | null>(null);
  const [servicePersons, setServicePersons] = useState<ServicePerson[]>([]);
  const [loadingPersons, setLoadingPersons] = useState(false);

  const API_BASE =
    process.env.NEXT_PUBLIC_API_URL ||
    (typeof window !== "undefined" && window.location.origin.includes("allgujaratvankarsamaj")
      ? "/api/v1"
      : "https://allgujaratvankarsamaj.com/api/v1");

  // Fallback initial services if backend is unavailable
  const fallbackServices: ServiceItem[] = [
    {
      id: "edu-vamika",
      title: "શિક્ષણ સેવાઓ અને નર્સિંગ એકેડેમી (Education Services & Coaching)",
      category: "Education Services",
      icon: "🎓",
      contactPerson: "વામિકા નર્સિંગ એકેડેમી (Vamika Nursing Academy - Idar)",
      contactPhone: "+91 92654 76537",
      description: "નર્સિંગ પ્રવેશ, સ્ટાફ નર્સ કોચિંગ, સ્પર્ધાત્મક પરીક્ષા માર્ગદર્શન અને ઉચ્ચ શિક્ષણ સેવાઓ.",
      _count: { persons: 1 },
    },
    {
      id: "tuition-coaching",
      title: "ટ્યુશન ક્લાસીસ અને સ્પર્ધાત્મક પરીક્ષા (Tuition / Coaching)",
      category: "Education Services",
      icon: "📚",
      contactPerson: "વામિકા નર્સિંગ એકેડેમી",
      contactPhone: "+91 92654 76537",
      description: "ધોરણ ૧ થી ૧૨ ટ્યુશન, GPSC/TET/TAT/Staff Nurse અને સરકારી ભરતી કોચિંગ.",
      _count: { persons: 1 },
    },
    { id: "textile", title: "કાપડ અને પરિધાન (Textiles & Garments)", category: "Business & Trade", icon: "🧵", contactPhone: "+91 98765 43210", description: "વણકર સમાજના પ્રતિષ્ઠિત કાપડ વેપારીઓ અને શૉરૂમ", _count: { persons: 12 } },
    { id: "mandap", title: "મંડપ ડેકોરેશન (Mandap Service)", category: "Wedding", icon: "🎪", contactPhone: "+91 98765 43210", description: "લગ્ન પ્રસંગ મંડપ અને લાઇટિંગ ડેકોરેશન સેવાઓ", _count: { persons: 8 } },
    { id: "photo", title: "ફોટોગ્રાફી અને વિડિયો (Photography)", category: "Wedding", icon: "📸", contactPhone: "+91 98765 43211", description: "વેડિંગ શૂટ, પ્રી-વેડિંગ અને ડ્રોન કવરેજ", _count: { persons: 15 } },
    { id: "catering", title: "કેટરર્સ અને રસોઈ (Catering Services)", category: "Wedding", icon: "🍽️", contactPhone: "+91 98765 43212", description: "શુદ્ધ શાકાહારી મિષ્ટાન અને કેટરિંગ કોન્ટ્રાક્ટર", _count: { persons: 9 } },
    { id: "car", title: "લગ્ન કાર અને વાહન રેન્ટલ (Car Rental)", category: "Transport", icon: "🚗", contactPhone: "+91 98765 43213", description: "લક્ઝરી કાર અને બસ ભાડે આપનાર", _count: { persons: 6 } },
    { id: "it", title: "આઇટી અને સોફ્ટવેર (IT & Digital Services)", category: "Business & Trade", icon: "💻", contactPhone: "+91 98765 43214", description: "વેબસાઇટ, મોબાઇલ એપ અને ડિજિટલ માર્કેટિંગ", _count: { persons: 11 } },
  ];

  const fetchServices = async () => {
    try {
      setLoading(true);
      const res = await fetch(`${API_BASE}/samaj-services`);
      if (res.ok) {
        const data = await res.json();
        if (Array.isArray(data) && data.length > 0) {
          setServices(data);
          return;
        }
      }
    } catch (_) {
      // Use fallback
    } finally {
      setLoading(false);
    }
    setServices(fallbackServices);
  };

  useEffect(() => {
    fetchServices();
  }, []);

  const handleOpenService = async (svc: ServiceItem) => {
    setActiveService(svc);
    setLoadingPersons(true);
    let resolvedPersons: ServicePerson[] = [];

    try {
      // 1. Try detail endpoint
      const res = await fetch(`${API_BASE}/samaj-services/${svc.id}`);
      if (res.ok) {
        const data = await res.json();
        if (data && Array.isArray(data.persons) && data.persons.length > 0) {
          resolvedPersons = data.persons;
        }
      }

      // 2. Try persons endpoint if detail had 0 persons
      if (resolvedPersons.length === 0) {
        const resPersons = await fetch(`${API_BASE}/samaj-services/${svc.id}/persons`);
        if (resPersons.ok) {
          const personsData = await resPersons.json();
          if (Array.isArray(personsData) && personsData.length > 0) {
            resolvedPersons = personsData;
          }
        }
      }
    } catch (_) {
      // fallback
    } finally {
      setLoadingPersons(false);
    }

    if (resolvedPersons.length > 0) {
      setServicePersons(resolvedPersons);
      return;
    }

    const isEdu =
      (svc.category || "").toLowerCase().includes("edu") ||
      (svc.title || "").toLowerCase().includes("education") ||
      (svc.title || "").toLowerCase().includes("nursing") ||
      (svc.title || "").toLowerCase().includes("vamika") ||
      (svc.title || "").includes("શિક્ષણ") ||
      (svc.title || "").includes("નર્સિંગ") ||
      (svc.title || "").toLowerCase().includes("coaching") ||
      (svc.title || "").toLowerCase().includes("tuition");

    // Default sample provider if none returned from API yet
    setServicePersons([
      {
        id: isEdu ? "sp-vamika-01" : "p1",
        name: isEdu ? "VAMIKA NURSING ACADEMY (IDAR)" : (svc.contactPerson || "સમાજ અધિકૃત વેપારી"),
        gujaratiName: isEdu ? "વામિકા નર્સિંગ એકેડેમી - ઇડર (શિક્ષણ & કોચિંગ સેવાઓ)" : undefined,
        phone: isEdu ? "+91 92654 76537" : (svc.contactPhone || "+91 98765 43210"),
        city: isEdu ? "ઇડર (Idar), 35 Gam Pargana" : "અમદાવાદ / ગુજરાત",
        description: isEdu
          ? "વામિકા નર્સિંગ એકેડેમી - ઇડર. નર્સિંગ એકેડેમી, સ્ટાફ નર્સ કોચિંગ, સ્પર્ધાત્મક પરીક્ષા માર્ગદર્શન અને ઉચ્ચ શિક્ષણ સેવાઓ."
          : (svc.description || "સમાજ સભ્ય દ્વારા સંચાલિત વિશ્વસનીય સેવા."),
        experience: isEdu ? "અધિકૃત શૈક્ષણિક એકેડેમી (Education Services)" : "૧૦+ વર્ષનો અનુભવ",
      },
    ]);
  };

  const categories = [
    { id: "ALL", label: "તમામ સેવાઓ (All)" },
    { id: "Education", label: "📚 શિક્ષણ સેવાઓ (Education Services)" },
    { id: "Wedding", label: "🎉 લગ્ન પ્રસંગ (Wedding)" },
    { id: "Business", label: "💼 વેપાર અને ઉદ્યોગ (Business)" },
    { id: "Transport", label: "🚗 ટ્રાન્સપોર્ટ (Transport)" },
    { id: "Home", label: "🏠 દૈનિક સેવાઓ (Home & Daily Life)" },
    { id: "Health", label: "🏥 આરોગ્ય અને મેડિકલ (Health & Emergency)" },
    { id: "Digital", label: "💻 કમ્પ્યુટર & ટેકનોલોજી (Digital Services)" },
  ];

  const filteredServices = services.filter((s) => {
    const q = search.trim().toLowerCase();
    const matchesSearch =
      !q ||
      s.title.toLowerCase().includes(q) ||
      (s.description && s.description.toLowerCase().includes(q)) ||
      (s.category && s.category.toLowerCase().includes(q)) ||
      (s.contactPhone && s.contactPhone.toLowerCase().includes(q)) ||
      (s.contactPerson && s.contactPerson.toLowerCase().includes(q));

    let matchesCategory = selectedCategory === "ALL";
    if (!matchesCategory && s.category) {
      const catLower = s.category.toLowerCase();
      const selLower = selectedCategory.toLowerCase();
      matchesCategory =
        catLower.includes(selLower) ||
        (selectedCategory === "Education" &&
          (catLower.includes("edu") ||
            s.title.toLowerCase().includes("edu") ||
            s.title.toLowerCase().includes("nursing") ||
            s.title.toLowerCase().includes("vamika") ||
            s.title.toLowerCase().includes("coaching") ||
            s.title.toLowerCase().includes("tuition") ||
            s.title.includes("શિક્ષણ") ||
            s.title.includes("નર્સિંગ")));
    }
    return matchesSearch && matchesCategory;
  });

  return (
    <div className="min-h-screen bg-[#070c18] text-white flex flex-col items-center py-6 px-3 font-sans">
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Cinzel:wght@600;700;800&family=Noto+Sans+Gujarati:wght@400;600;700&display=swap');
        .font-cinzel { font-family: 'Cinzel', serif; }
        .font-gujarati { font-family: 'Noto Sans Gujarati', sans-serif; }
      `}</style>

      {/* Top Navbar */}
      <div className="w-full max-w-4xl flex items-center justify-between bg-[#0d1b3e] border border-[#c9a227]/50 rounded-xl px-4 py-3 mb-4 shadow-lg">
        <Link href="/matrimony" className="flex items-center gap-2 text-[#FFE066] font-cinzel font-bold text-sm hover:underline">
          &larr; વણકર સમાજ મેટ્રિમોની (Home)
        </Link>
        <span className="text-xs text-amber-200 font-gujarati">સમાજ વ્યવસાય & સેવા ડિરેક્ટરી</span>
      </div>

      {/* Main Container */}
      <div className="w-full max-w-4xl bg-[#0d1b3e] border-2 border-[#c9a227] rounded-2xl shadow-2xl overflow-hidden font-gujarati">
        
        {/* Header Banner */}
        <div className="relative w-full h-44 md:h-52 overflow-hidden border-b-2 border-[#c9a227]">
          <Image
            src="/layoutimages/WhatsApp Image 2026-09-08 at 10.08.43 PM.jpeg"
            alt="Services Header Vankar Samaj"
            fill
            priority
            className="object-cover object-top"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-[#0d1b3e] via-black/40 to-transparent flex items-end justify-center pb-4 px-4 text-center">
            <div>
              <h1 className="font-cinzel font-extrabold text-2xl md:text-3xl text-[#FFE066] drop-shadow-md">
                SAMAJ BUSINESS & SERVICES DIRECTORY
              </h1>
              <p className="font-gujarati text-xs md:text-sm text-amber-200 drop-shadow mt-1">
                ઓલ ગુજરાત વણકર સમાજના સ્થાનિક વેપારીઓ, કારીગરો અને વ્યાવસાયિક સેવાઓની અધિકૃત સૂચિ
              </p>
            </div>
          </div>
        </div>

        <div className="p-5 md:p-8 space-y-6">

          {/* Promotion / Auto-Sync Banner */}
          <div className="bg-gradient-to-r from-amber-950/60 via-[#102347] to-amber-950/60 border border-[#D4AF37]/50 rounded-2xl p-4 flex flex-col sm:flex-row items-center justify-between gap-4 shadow-lg">
            <div className="flex items-center gap-3">
              <span className="text-3xl">💼</span>
              <div>
                <h2 className="text-sm font-bold text-[#FFE066]">
                  શું તમે વણકર સમાજના વેપારી કે વ્યવસાયી છો?
                </h2>
                <p className="text-xs text-amber-100/90 mt-0.5">
                  તમારી મેટ્રિમોની પ્રોફાઇલમાં બિઝનેસ વિગત ઉમેરો &mdash; તમારી પેઢી આપોઆપ આ ડિરેક્ટરીમાં લિસ્ટ થઈ જશે!
                </p>
              </div>
            </div>
            <Link
              href="/profile"
              className="whitespace-nowrap px-4 py-2 bg-gradient-to-r from-[#D4AF37] to-[#F3E5AB] text-[#041026] text-xs font-black rounded-xl hover:scale-105 transition-all shadow"
            >
              મારી પેઢી જોડો ➔
            </Link>
          </div>

          {/* Search & Filter Controls */}
          <div className="space-y-3">
            <div className="relative">
              <span className="absolute left-3.5 top-1/2 -translate-y-1/2 text-sm text-[#D4AF37]">🔍</span>
              <input
                type="text"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="સેવા, વ્યવસાય અથવા વેપારીનું નામ શોધો (Search business, category)..."
                className="w-full bg-[#070c18] border border-[#c9a227]/40 rounded-xl py-3 pl-10 pr-10 text-xs md:text-sm text-white placeholder-slate-400 focus:outline-none focus:border-[#FFE066]"
              />
              {search && (
                <button
                  onClick={() => setSearch("")}
                  className="absolute right-3.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-white text-xs font-bold"
                >
                  ✕
                </button>
              )}
            </div>

            {/* Category Filter Pills */}
            <div className="flex items-center gap-2 overflow-x-auto pb-1">
              {categories.map((cat) => (
                <button
                  key={cat.id}
                  onClick={() => setSelectedCategory(cat.id)}
                  className={`px-3 py-1.5 rounded-xl text-xs font-bold transition-all whitespace-nowrap ${
                    selectedCategory === cat.id
                      ? "bg-[#D4AF37] text-[#041026]"
                      : "bg-[#070c18] border border-[#c9a227]/30 text-amber-200 hover:border-[#D4AF37]"
                  }`}
                >
                  {cat.label}
                </button>
              ))}
            </div>
          </div>

          {/* Services Grid */}
          {loading ? (
            <div className="text-center py-12 text-[#D4AF37] text-xs font-bold">
              ⏳ સેવાઓ લોડ થઈ રહી છે...
            </div>
          ) : filteredServices.length === 0 ? (
            <div className="text-center py-12 text-slate-300 text-xs">
              કોઈ સેવા મળી નથી. કૃપા કરીને અન્ય કીવર્ડ સાથે પ્રયાસ કરો.
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              {filteredServices.map((svc) => (
                <div
                  key={svc.id}
                  onClick={() => handleOpenService(svc)}
                  className="p-4 bg-[#070c18] border border-[#c9a227]/40 hover:border-[#FFE066] rounded-2xl transition-all flex flex-col justify-between shadow-md group cursor-pointer hover:-translate-y-0.5"
                >
                  <div className="flex items-start justify-between gap-3 mb-2">
                    <div className="flex items-center gap-2.5">
                      <span className="text-2xl p-2 rounded-xl bg-[#0d1b3e] border border-amber-500/20">{svc.icon || "🤝"}</span>
                      <div>
                        <h3 className="text-xs md:text-sm font-bold text-white group-hover:text-[#FFE066] transition-colors line-clamp-1">
                          {svc.title}
                        </h3>
                        <span className="text-[10px] text-amber-300/80">
                          {svc.category || "વ્યવસાય"}
                        </span>
                      </div>
                    </div>
                  </div>

                  {svc.description && (
                    <p className="text-[11px] text-slate-300 line-clamp-2 mb-3">
                      {svc.description}
                    </p>
                  )}

                  <div className="flex items-center justify-between pt-2 border-t border-amber-500/15">
                    <span className="text-[10.5px] font-bold text-emerald-400 bg-emerald-950/60 px-2 py-0.5 rounded-md border border-emerald-500/30">
                      {svc._count?.persons ? `${svc._count.persons} ઉપલબ્ધ વેપારી` : "સક્રિય સેવા"}
                    </span>
                    <button
                      type="button"
                      className="px-3 py-1.5 bg-[#c9a227] text-[#0d1b3e] font-extrabold text-xs rounded-xl group-hover:bg-[#FFE066]"
                    >
                      સંપર્ક કરો ➔
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}

          {/* Central Samaj Helpline Card */}
          <div className="bg-[#070c18] border border-[#c9a227]/30 rounded-2xl p-5 space-y-3">
            <h3 className="font-cinzel text-base font-bold text-[#FFE066] text-center">
              CENTRAL SAMAJ HELPLINE & SUPPORT
            </h3>
            <div className="text-xs space-y-2 text-amber-200/90">
              <div className="flex justify-between border-b border-amber-500/20 pb-2">
                <span>લગ્ન પ્રસંગ સહાય અને પૂછપરછ:</span>
                <a href="tel:+919876543210" className="text-[#FFE066] font-bold">+91 98765 43210</a>
              </div>
              <div className="flex justify-between border-b border-amber-500/20 pb-2">
                <span>નવી પેઢી / વ્યવસાય ડિરેક્ટરી નોંધણી સહાય:</span>
                <a href="tel:+919876543211" className="text-[#FFE066] font-bold">+91 98765 43211</a>
              </div>
            </div>
          </div>

          {/* Bottom Actions */}
          <div className="pt-4 border-t border-[#c9a227]/30 flex flex-col sm:flex-row gap-3">
            <Link
              href="/matrimony"
              className="flex-1 py-3 rounded-xl bg-[#070c18] border border-[#c9a227]/60 text-[#FFE066] font-bold text-xs text-center hover:bg-[#c9a227]/20 transition-all"
            >
              &larr; મેટ્રિમોની હોમ પેજ (Matrimony Home)
            </Link>
            <Link
              href="/profile"
              className="flex-1 py-3 rounded-xl bg-[#D4AF37] text-[#041026] font-extrabold text-xs text-center hover:bg-[#FFE066] transition-all shadow"
            >
              તમારી પ્રોફાઇલમાં વ્યવસાય ઉમેરો (Update Profile)
            </Link>
          </div>

        </div>

      </div>

      {/* Detailed Service Provider Modal */}
      {activeService && (
        <div
          className="fixed inset-0 bg-black/85 backdrop-blur-md flex items-center justify-center p-4 z-50 font-gujarati"
          onClick={() => setActiveService(null)}
        >
          <div
            className="bg-[#0d1b3e] border-2 border-[#c9a227] rounded-2xl max-w-lg w-full max-h-[85vh] overflow-y-auto p-6 text-white space-y-4 shadow-2xl"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Modal Header */}
            <div className="flex items-start justify-between border-b border-amber-500/25 pb-3">
              <div className="flex items-center gap-3">
                <span className="text-3xl p-2 rounded-xl bg-[#070c18] border border-amber-500/30">
                  {activeService.icon || "🤝"}
                </span>
                <div>
                  <h3 className="font-cinzel text-base md:text-lg font-bold text-[#FFE066]">
                    {activeService.title}
                  </h3>
                  <span className="text-xs text-amber-200">
                    {activeService.category || "સમાજ અધિકૃત સેવા"}
                  </span>
                </div>
              </div>
              <button
                onClick={() => setActiveService(null)}
                className="text-slate-400 hover:text-white text-lg font-bold"
              >
                ✕
              </button>
            </div>

            {activeService.description && (
              <p className="text-xs text-amber-100 bg-[#070c18] p-3 rounded-xl border border-amber-500/20">
                {activeService.description}
              </p>
            )}

            {/* Service Providers List */}
            <div className="space-y-3">
              <h4 className="text-xs font-bold uppercase tracking-wider text-amber-300">
                અધિકૃત સમાજ વેપારીઓ અને પ્રોવાઇડર ({servicePersons.length})
              </h4>

              {loadingPersons ? (
                <div className="text-center py-6 text-xs text-amber-200">
                  ⏳ વેપારીઓની વિગત લોડ થઈ રહી છે...
                </div>
              ) : (
                <div className="space-y-3">
                  {servicePersons.map((p) => {
                    const cleanPhone = p.phone.replace(/[^0-9]/g, "");
                    const waPhone = cleanPhone.length === 10 ? `91${cleanPhone}` : cleanPhone;
                    return (
                      <div
                        key={p.id}
                        className="bg-[#070c18] border border-amber-500/30 rounded-xl p-3.5 space-y-2.5"
                      >
                        <div className="flex items-start justify-between gap-2">
                          <div>
                            <div className="text-sm font-bold text-white">{p.name}</div>
                            {p.city && (
                              <div className="text-xs text-slate-300">
                                📍 {p.city} {p.experience ? `• ${p.experience}` : ""}
                              </div>
                            )}
                          </div>
                          <span className="text-[10px] font-bold bg-emerald-950/80 text-emerald-400 border border-emerald-500/40 px-2 py-0.5 rounded">
                            સમાજ વેરિફાઇડ
                          </span>
                        </div>

                        {p.description && (
                          <p className="text-xs text-amber-100/90">{p.description}</p>
                        )}

                        <div className="flex gap-2 pt-1">
                          <a
                            href={`tel:${cleanPhone}`}
                            className="flex-1 py-2 bg-[#D4AF37] text-[#041026] text-xs font-black rounded-lg text-center hover:bg-[#FFE066] flex items-center justify-center gap-1.5"
                          >
                            <span>📞</span> કોલ કરો
                          </a>
                          <a
                            href={`https://wa.me/${waPhone}?text=${encodeURIComponent(`નમસ્તે, મેં વણકર સમાજ ડિરેક્ટરીમાંથી તમારી સેવા (${activeService.title}) જોઈ સંપર્ક કર્યો છે.`)}`}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="flex-1 py-2 bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-bold rounded-lg text-center flex items-center justify-center gap-1.5"
                          >
                            <span>💬</span> WhatsApp
                          </a>
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>

            <button
              onClick={() => setActiveService(null)}
              className="w-full py-2.5 bg-[#070c18] border border-[#c9a227]/50 text-[#FFE066] font-bold text-xs rounded-xl hover:bg-amber-950/40"
            >
              બંધ કરો (Close)
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
