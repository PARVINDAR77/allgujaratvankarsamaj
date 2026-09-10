"use client";

import React, { useState } from "react";
import Image from "next/image";
import Link from "next/link";

export default function MutualInterestPage() {
  const [modalType, setModalType] = useState<string | null>(null);
  const [msgSent, setMsgSent] = useState(false);

  const handleSendMsg = () => {
    setMsgSent(true);
    setTimeout(() => {
      setMsgSent(false);
      setModalType(null);
    }, 2000);
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
        <span className="text-xs text-amber-200 font-gujarati">પરસ્પર સંમતિ (Mutual Interest)</span>
      </div>

      {/* Main Container */}
      <div className="w-full max-w-4xl bg-[#0d1b3e] border-2 border-[#c9a227] rounded-2xl shadow-2xl overflow-hidden font-gujarati">
        
        {/* Cropped Top Peacock Header Banner */}
        <div className="relative w-full h-44 md:h-56 overflow-hidden border-b-2 border-[#c9a227]">
          <Image
            src="/layoutimages/WhatsApp Image 2026-09-08 at 10.08.44 PM (2).jpeg"
            alt="Mutual Interest Header Vankar Samaj"
            fill
            priority
            className="object-cover object-top"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-[#0d1b3e] via-transparent to-black/40 flex items-end justify-center pb-3 px-4 text-center">
            <div>
              <span className="px-3 py-1 bg-amber-900/90 border border-amber-400 text-[#FFE066] text-[10px] font-bold rounded-full uppercase">
                Mutual Interest Confirmed
              </span>
              <h1 className="font-cinzel font-extrabold text-2xl md:text-3xl text-[#FFE066] drop-shadow-md mt-1">
                MUTUAL INTEREST ACCEPTED
              </h1>
              <p className="font-gujarati text-xs md:text-sm text-amber-200 drop-shadow">
                બંને પક્ષો વચ્ચે પરસ્પર પસંદગી પૂર્ણ થયેલ છે
              </p>
            </div>
          </div>
        </div>

        {/* Native Body Section */}
        <div className="p-5 md:p-8 space-y-6">
          
          {/* Profiles Comparison Card */}
          <div className="grid grid-cols-2 gap-4 bg-[#070c18] border border-[#c9a227]/40 p-5 rounded-2xl text-center shadow-md">
            <div className="space-y-2">
              <div className="w-14 h-14 rounded-full bg-[#c9a227]/20 border border-[#FFE066] mx-auto flex items-center justify-center text-2xl">
                👦
              </div>
              <h4 className="font-bold text-white text-xs md:text-sm">વર પક્ષ (Groom Side)</h4>
              <p className="text-xs text-amber-200/70">૩૫ પરગણા | અમદાવાદ</p>
            </div>
            <div className="space-y-2 border-l border-amber-500/20 pl-2">
              <div className="w-14 h-14 rounded-full bg-[#c9a227]/20 border border-[#FFE066] mx-auto flex items-center justify-center text-2xl">
                👩
              </div>
              <h4 className="font-bold text-white text-xs md:text-sm">કન્યા પક્ષ (Bride Side)</h4>
              <p className="text-xs text-amber-200/70">૨૭ પરગણા | વડોદરા</p>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <button
              onClick={() => setModalType("message")}
              className="py-3.5 bg-gradient-to-r from-[#c9a227] to-[#FFE066] text-[#0d1b3e] font-extrabold text-xs rounded-xl shadow-xl hover:brightness-110 font-cinzel tracking-wider"
            >
              સંદેશ મોકલો (SEND MESSAGE)
            </button>
            <button
              onClick={() => setModalType("call")}
              className="py-3.5 bg-[#070c18] border border-[#c9a227]/60 text-[#FFE066] font-bold text-xs rounded-xl hover:bg-[#c9a227]/20 transition-all"
            >
              સીધો સંપર્ક કરો (CALL DIRECTLY)
            </button>
          </div>

          {/* Bottom Navigation */}
          <div className="pt-4 border-t border-[#c9a227]/30 flex gap-4">
            <Link
              href="/family-details"
              className="w-1/2 py-3 bg-[#070c18] border border-[#c9a227]/60 text-amber-200 text-center font-bold text-xs rounded-xl hover:bg-[#c9a227]/20 transition-all"
            >
              કુટુંબ વિગત (Family Info)
            </Link>
            <Link
              href="/matrimony"
              className="w-1/2 py-3 bg-[#070c18] border border-[#c9a227]/60 text-[#FFE066] text-center font-bold text-xs rounded-xl hover:bg-[#c9a227]/20 transition-all"
            >
              હોમ (Home)
            </Link>
          </div>

        </div>

      </div>

      {/* Modal */}
      {modalType && (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4 z-50 font-gujarati">
          <div className="bg-[#0d1b3e] border-2 border-[#c9a227] rounded-2xl max-w-sm w-full p-6 text-white space-y-4 shadow-2xl">
            <h3 className="font-cinzel text-base font-bold text-[#FFE066]">
              {modalType === "message" ? "SEND SAMAJ MESSAGE" : "DIRECT CALL DETAILS"}
            </h3>

            {msgSent ? (
              <div className="p-3 bg-emerald-950 text-emerald-200 text-xs font-bold text-center rounded-xl">
                ✓ તમારો સંદેશ સફળતાપૂર્વક મોકલાઈ ગયો છે!
              </div>
            ) : modalType === "message" ? (
              <div className="space-y-3">
                <textarea
                  rows={3}
                  placeholder="તમારો સંદેશ અહીં લખો..."
                  className="w-full bg-[#070c18] border border-[#c9a227]/60 rounded-xl p-3 text-xs text-white placeholder-amber-200/40"
                />
                <button
                  onClick={handleSendMsg}
                  className="w-full py-2.5 bg-[#c9a227] text-[#0d1b3e] font-bold text-xs rounded-xl"
                >
                  મોકલો (Send)
                </button>
              </div>
            ) : (
              <div className="space-y-2 text-center text-xs">
                <p className="text-amber-200">અધિકૃત ફોન નંબર:</p>
                <a href="tel:+919876543210" className="block text-lg font-bold text-[#FFE066]">
                  +91 98765 43210
                </a>
              </div>
            )}

            <button
              onClick={() => setModalType(null)}
              className="w-full py-2 bg-[#070c18] border border-[#c9a227]/50 text-amber-200 font-bold text-xs rounded-xl"
            >
              બંધ કરો
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
