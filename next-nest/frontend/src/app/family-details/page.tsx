"use client";

import React from "react";
import Image from "next/image";
import Link from "next/link";

export default function FamilyDetailsPage() {
  const familyMembers = [
    { relation: "પિતા (Father)", name: "રામેશભાઈ વણકર", occupation: "નિવૃત્ત સરકારી કર્મચારી (Govt Retd)" },
    { relation: "માતા (Mother)", name: "સવિતાબેન વણકર", occupation: "ગૃહિણી (Home Maker)" },
    { relation: "ભાઈ (Brother)", name: "જિગ્નેશ વણકર", occupation: "સોફ્ટવેર એન્જિનિયર (TCS)" },
    { relation: "બહેન (Sister)", name: "સ્વાતિ વણકર", occupation: "પરિણિત (માણસા)" },
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
        <Link href="/matrimony" className="flex items-center gap-2 text-[#FFE066] font-cinzel font-bold text-sm hover:underline">
          &larr; વણકર સમાજ મેટ્રિમોની (Home)
        </Link>
        <span className="text-xs text-amber-200 font-gujarati">કૌટુંબિક વિગતો (Family Details)</span>
      </div>

      {/* Main Container */}
      <div className="w-full max-w-4xl bg-[#0d1b3e] border-2 border-[#c9a227] rounded-2xl shadow-2xl overflow-hidden font-gujarati">
        
        {/* Cropped Top Peacock Header Banner */}
        <div className="relative w-full h-44 md:h-56 overflow-hidden border-b-2 border-[#c9a227]">
          <Image
            src="/layoutimages/WhatsApp Image 2026-09-08 at 10.08.43 PM (1).jpeg"
            alt="Family Details Header Vankar Samaj"
            fill
            priority
            className="object-cover object-top"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-[#0d1b3e] via-transparent to-black/40 flex items-end justify-center pb-3 px-4 text-center">
            <div>
              <span className="px-3 py-1 bg-[#c9a227]/20 border border-[#FFE066]/50 text-[#FFE066] text-[10px] font-bold rounded-full uppercase">
                Verified Samaj Family
              </span>
              <h1 className="font-cinzel font-extrabold text-2xl md:text-3xl text-[#FFE066] drop-shadow-md mt-1">
                FAMILY BACKGROUND DETAILS
              </h1>
              <p className="font-gujarati text-xs md:text-sm text-amber-200 drop-shadow">
                ઉમેદવારના પરિવાર અને મોસાળની માહિતી
              </p>
            </div>
          </div>
        </div>

        {/* Native Family Details Body */}
        <div className="p-5 md:p-8 space-y-6">
          
          {/* Family Members Table */}
          <div className="space-y-3">
            {familyMembers.map((mem, i) => (
              <div
                key={i}
                className="p-4 bg-[#070c18] border border-[#c9a227]/40 rounded-2xl flex items-center justify-between text-xs shadow-md"
              >
                <div>
                  <span className="text-[#FFE066] font-bold block text-xs">{mem.relation}</span>
                  <span className="text-white font-bold text-sm md:text-base">{mem.name}</span>
                </div>
                <span className="text-amber-200/90 text-xs font-semibold bg-[#0d1b3e] px-3 py-1.5 rounded-xl border border-[#c9a227]/30">
                  {mem.occupation}
                </span>
              </div>
            ))}
          </div>

          {/* Address Box */}
          <div className="bg-[#070c18] border border-[#c9a227]/30 p-5 rounded-2xl space-y-1.5 text-xs">
            <h4 className="font-cinzel font-bold text-sm text-[#FFE066]">વતન અને સરનામું (Native & Address):</h4>
            <p className="text-amber-100/90">મૂળ વતન: સાણંદ, જિલ્લો: અમદાવાદ (૩૫ પરગણા)</p>
            <p className="text-amber-100/90">હાલનું સરનામું: બોપલ, અમદાવાદ</p>
          </div>

          {/* Bottom Actions */}
          <div className="pt-4 border-t border-[#c9a227]/30 flex gap-4">
            <Link
              href="/mutual-interest"
              className="w-1/2 py-3.5 bg-gradient-to-r from-[#c9a227] to-[#FFE066] text-[#0d1b3e] text-center font-extrabold text-xs rounded-xl shadow-xl hover:brightness-110 font-cinzel tracking-wider"
            >
              સંપર્ક વિનંતી
            </Link>
            <Link
              href="/matrimony"
              className="w-1/2 py-3.5 bg-[#070c18] border border-[#c9a227]/60 text-[#FFE066] text-center font-bold text-xs rounded-xl hover:bg-[#c9a227]/20 transition-all"
            >
              હોમ (Home)
            </Link>
          </div>

        </div>

      </div>
    </div>
  );
}
