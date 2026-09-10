"use client";

import React, { useState } from "react";
import Image from "next/image";
import Link from "next/link";

export default function ServicesPage() {
  const [modalService, setModalService] = useState<string | null>(null);

  const serviceList = [
    { id: "mandap", title: "મંડપ ડેકોરેશન (Mandap Service)", icon: "🎪", phone: "+91 98765 43210" },
    { id: "photo", title: "ફોટોગ્રાફી વિડિયો (Photography)", icon: "📸", phone: "+91 98765 43211" },
    { id: "live", title: "યુટ્યુબ લાઇવ પ્રસારણ (YouTube Live)", icon: "🎥", phone: "+91 98765 43212" },
    { id: "car", title: "લગ્ન કાર રેન્ટલ (Wedding Car)", icon: "🚗", phone: "+91 98765 43213" },
    { id: "eco", title: "ઇકો / મિની બસ (Eco Rental)", icon: "🚐", phone: "+91 98765 43214" },
    { id: "dir", title: "વણકર બિઝનેસ ડિરેક્ટરી (Directory)", icon: "📖", phone: "+91 98765 43215" },
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
        <span className="text-xs text-amber-200 font-gujarati">સમાજ સેવાઓ (Samaj Services)</span>
      </div>

      {/* Main Container */}
      <div className="w-full max-w-4xl bg-[#0d1b3e] border-2 border-[#c9a227] rounded-2xl shadow-2xl overflow-hidden font-gujarati">
        
        {/* Cropped Top Peacock Header Banner */}
        <div className="relative w-full h-44 md:h-56 overflow-hidden border-b-2 border-[#c9a227]">
          <Image
            src="/layoutimages/WhatsApp Image 2026-09-08 at 10.08.43 PM.jpeg"
            alt="Services Header Vankar Samaj"
            fill
            priority
            className="object-cover object-top"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-[#0d1b3e] via-transparent to-black/40 flex items-end justify-center pb-3 px-4 text-center">
            <div>
              <h1 className="font-cinzel font-extrabold text-2xl md:text-3xl text-[#FFE066] drop-shadow-md">
                SAMAJ SERVICES DIRECTORY
              </h1>
              <p className="font-gujarati text-xs md:text-sm text-amber-200 drop-shadow">
                શ્રી વણકર સમાજ લગ્ન પ્રસંગ સેવાઓ અને સ્થાનિક વ્યવસાય ડિરેક્ટરી
              </p>
            </div>
          </div>
        </div>

        {/* Native Services Grid Body */}
        <div className="p-5 md:p-8 space-y-6">
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {serviceList.map((svc) => (
              <div
                key={svc.id}
                className="p-4 bg-[#070c18] border border-[#c9a227]/40 hover:border-[#FFE066] rounded-2xl transition-all flex items-center justify-between shadow-md group"
              >
                <div className="flex items-center gap-3">
                  <span className="text-2xl">{svc.icon}</span>
                  <span className="text-xs md:text-sm font-bold text-white group-hover:text-[#FFE066] transition-colors">
                    {svc.title}
                  </span>
                </div>
                <button
                  onClick={() => setModalService(svc.title)}
                  className="px-3 py-1.5 bg-[#c9a227] text-[#0d1b3e] font-extrabold text-xs rounded-xl hover:bg-[#FFE066]"
                >
                  સંપર્ક
                </button>
              </div>
            ))}
          </div>

          {/* Helpline Table */}
          <div className="bg-[#070c18] border border-[#c9a227]/30 rounded-2xl p-5 space-y-3">
            <h3 className="font-cinzel text-base font-bold text-[#FFE066] text-center">
              DIRECT SAMITI HELPLINE
            </h3>
            <div className="text-xs space-y-2 text-amber-200/90">
              <div className="flex justify-between border-b border-amber-500/20 pb-2">
                <span>લગ્ન કાર બુકિંગ હેલ્પલાઇન:</span>
                <a href="tel:+919876543210" className="text-[#FFE066] font-bold">+91 98765 43210</a>
              </div>
              <div className="flex justify-between border-b border-amber-500/20 pb-2">
                <span>મંડળ લાઇવ સ્ટ્રીમિંગ સપોર્ટ:</span>
                <a href="tel:+919876543211" className="text-[#FFE066] font-bold">+91 98765 43211</a>
              </div>
            </div>
          </div>

          {/* Bottom Actions */}
          <div className="pt-4 border-t border-[#c9a227]/30">
            <Link
              href="/matrimony"
              className="block w-full py-3.5 rounded-xl bg-[#070c18] border border-[#c9a227]/60 text-[#FFE066] font-bold text-xs text-center hover:bg-[#c9a227]/20 transition-all"
            >
              મુખ્ય હોમ પેજ (Home)
            </Link>
          </div>

        </div>

      </div>

      {/* Modal */}
      {modalService && (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4 z-50 font-gujarati">
          <div className="bg-[#0d1b3e] border-2 border-[#c9a227] rounded-2xl max-w-sm w-full p-6 text-white space-y-4 shadow-2xl">
            <h3 className="font-cinzel text-base font-bold text-[#FFE066]">
              {modalService}
            </h3>
            <p className="text-xs text-amber-100">
              શ્રી વણકર સમાજના અધિકૃત સર્વિસ પ્રોવાઇડર સાથે વાત કરવા માટે નીચે બટન પર ક્લિક કરો.
            </p>
            <div className="flex gap-3">
              <a
                href="tel:+919876543210"
                className="w-1/2 py-2.5 bg-[#c9a227] text-[#0d1b3e] font-bold text-center text-xs rounded-xl"
              >
                કોલ કરો (Call)
              </a>
              <button
                onClick={() => setModalService(null)}
                className="w-1/2 py-2.5 bg-[#070c18] border border-[#c9a227]/50 text-[#FFE066] font-bold text-xs rounded-xl"
              >
                બંધ કરો
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
