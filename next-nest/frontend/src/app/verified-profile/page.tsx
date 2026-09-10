"use client";

import React, { useState } from "react";
import Image from "next/image";
import Link from "next/link";

export default function VerifiedProfilePage() {
  const [activeModal, setActiveModal] = useState<string | null>(null);

  const verificationItems = [
    {
      id: "mobile",
      title: "૧. મોબાઇલ ઓટીપી ખરાઈ (Mobile OTP Verification)",
      status: "Verified (ચકાસાયેલ)",
      desc: "મોબાઇલ નંબર અને આધાર લિંક્ડ ઓટીપી દ્વારા ચકાસણી પૂર્ણ થયેલ છે.",
      icon: "📱",
    },
    {
      id: "profile",
      title: "૨. આઇડી અને સરનામું ખરાઈ (Government ID Verification)",
      status: "Verified (આધાર / ચૂંટણી કાર્ડ)",
      desc: "સરકારી આધાર કાર્ડ / ચૂંટણી ઓળખપત્ર દ્વારા નામ અને સરનામાની ખરાઈ.",
      icon: "🪪",
    },
    {
      id: "samaj",
      title: "૩. વણકર સમાજ મંડળ ખરાઈ (Samaj Mandal Verification)",
      status: "Approved (સમાજ મંડળ માન્ય)",
      desc: "પરગણા મંડળના સ્થાનિક હોદ્દેદારો દ્વારા કુટુંબની ઓળખની ચકાસણી.",
      icon: "🏛️",
    },
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
        <span className="text-xs text-amber-200 font-gujarati">વેરિફાઇડ પ્રોફાઇલ (Verified Profiles)</span>
      </div>

      {/* Main Container */}
      <div className="w-full max-w-4xl bg-[#0d1b3e] border-2 border-[#c9a227] rounded-2xl shadow-2xl overflow-hidden font-gujarati">
        
        {/* Cropped Top Peacock Header Banner */}
        <div className="relative w-full h-44 md:h-56 overflow-hidden border-b-2 border-[#c9a227]">
          <Image
            src="/layoutimages/WhatsApp Image 2026-09-08 at 10.08.44 PM (1).jpeg"
            alt="Verified Profile Header Vankar Samaj"
            fill
            priority
            className="object-cover object-top"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-[#0d1b3e] via-transparent to-black/40 flex items-end justify-center pb-3 px-4 text-center">
            <div>
              <span className="px-3 py-1 bg-emerald-900/90 border border-emerald-400 text-emerald-200 text-[10px] font-bold rounded-full uppercase tracking-wider">
                100% Verified Profiles
              </span>
              <h1 className="font-cinzel font-extrabold text-2xl md:text-3xl text-[#FFE066] drop-shadow-md mt-1">
                VERIFIED SAMAJ PROFILES
              </h1>
              <p className="font-gujarati text-xs md:text-sm text-amber-200 drop-shadow">
                ખરાઈ થયેલ પ્રોફાઇલ્સ - સુરક્ષિત અને વિશ્વાસપાત્ર વણકર મેટ્રિમોની
              </p>
            </div>
          </div>
        </div>

        {/* Native Verification Body */}
        <div className="p-5 md:p-8 space-y-6">
          
          <div className="space-y-4">
            {verificationItems.map((item) => (
              <div
                key={item.id}
                onClick={() => setActiveModal(item.id)}
                className="cursor-pointer bg-[#070c18] border border-[#c9a227]/40 hover:border-[#FFE066] p-4 md:p-5 rounded-2xl flex items-center justify-between transition-all duration-300 group shadow-md"
              >
                <div className="flex items-center gap-4">
                  <span className="text-3xl">{item.icon}</span>
                  <div>
                    <h4 className="font-bold text-white text-sm md:text-base group-hover:text-[#FFE066] transition-colors">
                      {item.title}
                    </h4>
                    <p className="text-xs text-amber-200/70 mt-0.5">{item.desc}</p>
                  </div>
                </div>
                <span className="text-xs px-3 py-1.5 rounded-full bg-emerald-950 border border-emerald-500/60 text-emerald-300 font-bold whitespace-nowrap">
                  {item.status}
                </span>
              </div>
            ))}
          </div>

          {/* Trust Box */}
          <div className="bg-[#070c18] border border-[#c9a227]/30 p-5 rounded-2xl text-center space-y-1.5">
            <h4 className="font-cinzel font-bold text-base text-[#FFE066]">
              શા માટે વેરિફાઇડ પ્રોફાઇલ પસંદ કરવી?
            </h4>
            <p className="text-xs text-amber-100/90 leading-relaxed">
              વેરિફાઇડ પ્રોફાઇલ દ્વારા બનાવટી માહિતીથી સુરક્ષા મળે છે અને સંબંધીઓ વચ્ચે સુગમતા વધે છે.
            </p>
          </div>

          {/* Actions */}
          <div className="pt-4 border-t border-[#c9a227]/30 flex gap-4">
            <Link
              href="/search"
              className="w-1/2 py-3.5 rounded-xl bg-gradient-to-r from-[#c9a227] to-[#FFE066] text-[#0d1b3e] font-extrabold text-xs text-center shadow-xl hover:brightness-110 transition-all font-cinzel"
            >
              વેરિફાઇડ પ્રોફાઇલ શોધો
            </Link>
            <Link
              href="/matrimony"
              className="w-1/2 py-3.5 rounded-xl bg-[#070c18] border border-[#c9a227]/60 text-[#FFE066] font-bold text-xs text-center hover:bg-[#c9a227]/20 transition-all"
            >
              મુખ્ય હોમ પેજ
            </Link>
          </div>

        </div>

      </div>

      {/* Modal */}
      {activeModal && (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4 z-50 font-gujarati">
          <div className="bg-[#0d1b3e] border-2 border-[#c9a227] rounded-2xl max-w-md w-full p-6 text-white space-y-4 shadow-2xl">
            <h3 className="font-cinzel text-lg font-bold text-[#FFE066]">
              VERIFICATION DETAILS
            </h3>
            <p className="text-xs text-amber-100 leading-relaxed">
              આ પ્રોફાઇલ શ્રી વણકર સમાજ મંડળ અને ઓનલાઇન આધાર સરનામા સિસ્ટમ દ્વારા વિગતવાર પ્રમાણિત થયેલ છે.
            </p>
            <button
              onClick={() => setActiveModal(null)}
              className="w-full py-2.5 bg-[#070c18] border border-[#c9a227]/50 text-[#FFE066] font-bold text-xs rounded-xl"
            >
              સમજાયું (OK)
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
