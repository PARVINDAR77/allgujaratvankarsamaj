"use client";

import React from "react";
import Image from "next/image";
import Link from "next/link";
import { useRouter } from "next/navigation";

export default function ParganaOverviewPage() {
  const router = useRouter();

  const parganaList = [
    { id: "35", name: "૩૫ પરગણા (35 Pargana)", desc: "Ahmedabad, Gandhinagar, & Surrounding Regions", count: "1,450+ Profiles" },
    { id: "27", name: "૨૭ પરગણા (27 Pargana)", desc: "Vadodara & Central Gujarat Region", count: "980+ Profiles" },
    { id: "16", name: "૧૬ પરગણા (16 Pargana)", desc: "Mehsana & North Gujarat Region", count: "720+ Profiles" },
    { id: "14", name: "૧૪ પરગણા (14 Pargana)", desc: "Saurashtra & Kutch Region", count: "540+ Profiles" },
    { id: "other", name: "અન્ય પરગણા (Other / NRI)", desc: "Rest of India & International Global", count: "310+ Profiles" },
  ];

  const handleParganaClick = (pName: string) => {
    router.push(`/search?pargana=${encodeURIComponent(pName)}`);
  };

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
        <span className="text-xs text-amber-200 font-gujarati">પરગણા પસંદગી (Pargana Selection)</span>
      </div>

      {/* Main Container */}
      <div className="w-full max-w-4xl bg-[#0d1b3e] border-2 border-[#c9a227] rounded-2xl shadow-2xl overflow-hidden font-gujarati">
        
        {/* Cropped Top Peacock Header Banner */}
        <div className="relative w-full h-44 md:h-56 overflow-hidden border-b-2 border-[#c9a227]">
          <Image
            src="/layoutimages/WhatsApp Image 2026-09-08 at 10.08.42 PM.jpeg"
            alt="Pargana Directory Header Vankar Samaj"
            fill
            priority
            className="object-cover object-top"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-[#0d1b3e] via-transparent to-black/40 flex items-end justify-center pb-3 px-4 text-center">
            <div>
              <span className="px-3 py-1 bg-[#c9a227]/20 border border-[#FFE066]/50 text-[#FFE066] text-[10px] font-bold rounded-full uppercase">
                Pargana Mandal Regions
              </span>
              <h1 className="font-cinzel font-extrabold text-2xl md:text-3xl text-[#FFE066] drop-shadow-md mt-1">
                PARGANA MANDAL DIRECTORY
              </h1>
              <p className="font-gujarati text-xs md:text-sm text-amber-200 drop-shadow">
                વણકર સમાજના પરગણા મુજબ સીધી પ્રોફાઇલ શોધો
              </p>
            </div>
          </div>
        </div>

        {/* Native Pargana Badges Body */}
        <div className="p-5 md:p-8 space-y-6">
          
          <div className="space-y-3">
            {parganaList.map((p) => (
              <div
                key={p.id}
                onClick={() => handleParganaClick(p.name)}
                className="cursor-pointer p-4 md:p-5 bg-[#070c18] border border-[#c9a227]/40 hover:border-[#FFE066] rounded-2xl flex items-center justify-between transition-all duration-300 group shadow-md"
              >
                <div>
                  <h4 className="font-bold text-white text-sm md:text-base group-hover:text-[#FFE066] transition-colors">
                    {p.name}
                  </h4>
                  <p className="text-xs text-amber-200/70 mt-0.5">{p.desc}</p>
                </div>
                <span className="text-xs font-extrabold text-[#FFE066] bg-[#0d1b3e] px-3.5 py-1.5 rounded-xl border border-[#c9a227]/40 whitespace-nowrap">
                  {p.count}
                </span>
              </div>
            ))}
          </div>

          {/* Bottom Actions */}
          <div className="pt-4 border-t border-[#c9a227]/30 flex gap-4">
            <Link
              href="/search"
              className="w-1/2 py-3.5 bg-gradient-to-r from-[#c9a227] to-[#FFE066] text-[#0d1b3e] text-center font-extrabold text-xs rounded-xl shadow-xl hover:brightness-110 font-cinzel tracking-wider"
            >
              તમામ પ્રોફાઇલ્સ શોધો (Search All)
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
