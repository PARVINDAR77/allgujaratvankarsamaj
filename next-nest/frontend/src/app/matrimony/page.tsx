"use client";

import React from "react";
import Image from "next/image";
import Link from "next/link";

export default function MatrimonyPage() {
  const actions = [
    { title: "વર શોધો (Find Groom / Boy)", href: "/search?lookingFor=Groom", icon: "👨", desc: "ચકાસાયેલ વર ઉમેદવારો" },
    { title: "કન્યા શોધો (Find Bride / Girl)", href: "/search?lookingFor=Bride", icon: "👰", desc: "ચકાસાયેલ કન્યા ઉમેદવારો" },
    { title: "યોગ્ય પસંદગી (Find Match)", href: "/search", icon: "💍", desc: "મનપસંદ ફિલ્ટર્સ વડે શોધો" },
    { title: "પ્રોફાઇલ બનાવો (Create Profile)", href: "/profile", icon: "📝", desc: "તમારી માહિતી ઉમેરો" },
    { title: "પરગણા વાઇઝ શોધો (Pargana Search)", href: "/pargana", icon: "📍", desc: "૩૫, ૨૭, ૧૬, ૧૪ પરગણા" },
    { title: "સરકારી કર્મચારી (Govt Employees)", href: "/government-employees", icon: "🏛️", desc: "ચકાસાયેલ સરકારી અધિકારીઓ અને કર્મચારીઓ" },
    { title: "વેરિફાઇડ પ્રોફાઇલ્સ (Verified Profiles)", href: "/verified-profile", icon: "✅", desc: "મંડળ માન્ય પ્રોફાઇલ્સ" },
  ];

  return (
    <div className="min-h-screen bg-[#070c18] text-white flex flex-col items-center py-6 px-3 font-sans">
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Cinzel:wght@600;700;800&family=Noto+Sans+Gujarati:wght@400;600;700&display=swap');
        .font-cinzel { font-family: 'Cinzel', serif; }
        .font-gujarati { font-family: 'Noto Sans Gujarati', sans-serif; }
      `}</style>

      {/* Top Navbar */}
      <div className="w-full max-w-4xl flex items-center justify-between bg-[#0d1b3e] border border-[#c9a227]/50 rounded-xl px-4 py-3 mb-4 shadow-lg">
        <span className="font-cinzel font-bold text-base text-[#FFE066]">VANKAR SAMAJ MATRIMONY</span>
        <span className="text-xs text-amber-200 font-gujarati">વણકર સમાજ મેટ્રિમોની</span>
      </div>

      {/* Main Container */}
      <div className="w-full max-w-4xl bg-[#0d1b3e] border-2 border-[#c9a227] rounded-2xl shadow-2xl overflow-hidden font-gujarati">
        
        {/* Cropped Top Peacock Header Banner */}
        <div className="relative w-full h-48 md:h-64 overflow-hidden border-b-2 border-[#c9a227]">
          <Image
            src="/layoutimages/WhatsApp Image 2026-09-08 at 10.08.42 PM (1).jpeg"
            alt="Matrimony Hub Header Vankar Samaj"
            fill
            priority
            className="object-cover object-top"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-[#0d1b3e] via-transparent to-black/40 flex items-end justify-center pb-4 px-4 text-center">
            <div>
              <span className="text-2xl">🪔</span>
              <h1 className="font-cinzel font-extrabold text-2xl md:text-3xl text-[#FFE066] drop-shadow-md">
                શ્રી વણકર સમાજ મેટ્રિમોની
              </h1>
              <p className="font-gujarati text-xs md:text-sm text-amber-200 drop-shadow mt-0.5">
                તમામ પરગણા મંડળના વેરિફાઇડ ઉમેદવારો માટેનું વિશ્વાસપાત્ર પ્લેટફોર્મ
              </p>
            </div>
          </div>
        </div>

        {/* Native Action Grid Body */}
        <div className="p-5 md:p-8 space-y-6">
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {actions.map((act, index) => (
              <Link
                key={index}
                href={act.href}
                className="p-5 bg-[#070c18] border border-[#c9a227]/40 hover:border-[#FFE066] rounded-2xl flex flex-col justify-between transition-all duration-300 hover:-translate-y-1 shadow-md group"
              >
                <div>
                  <span className="text-3xl mb-2 block">{act.icon}</span>
                  <h3 className="font-bold text-sm md:text-base text-white group-hover:text-[#FFE066] transition-colors">
                    {act.title}
                  </h3>
                  <p className="text-xs text-amber-200/70 mt-1">{act.desc}</p>
                </div>
                <div className="mt-4 text-right text-xs font-bold text-[#FFE066] group-hover:translate-x-1 transition-transform">
                  આગળ વધો &rarr;
                </div>
              </Link>
            ))}
          </div>

          {/* Bottom Quick Links */}
          <div className="pt-4 border-t border-[#c9a227]/30 flex flex-wrap justify-between items-center text-xs gap-3">
            <Link href="/services" className="px-4 py-2 bg-[#070c18] border border-[#c9a227]/50 rounded-xl text-[#FFE066] font-semibold hover:bg-[#c9a227]/20 transition-all">
              સમાજ સેવાઓ (Services) &rarr;
            </Link>
            <Link href="/mutual-interest" className="px-4 py-2 bg-[#070c18] border border-[#c9a227]/50 rounded-xl text-amber-200 hover:bg-[#c9a227]/20 transition-all">
              પરસ્પર સંમતિ (Mutual Interest) &rarr;
            </Link>
          </div>

        </div>

      </div>
    </div>
  );
}
