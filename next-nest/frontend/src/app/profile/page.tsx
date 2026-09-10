"use client";

import React, { useState } from "react";
import Image from "next/image";
import Link from "next/link";

export default function ProfilePrivacyPage() {
  const [settings, setSettings] = useState({
    phoneVisibility: "Only Verified Samaj Members (માત્ર ખરાઈ થયેલ સભ્યો)",
    photoAccess: "Visible to All Registered Users (તમામ નોંધાયેલ સભ્યો)",
    familyInfo: "Restricted to Mutual Interest (પરસ્પર સંમતિ પર)",
    directCall: true,
  });

  const [saved, setSaved] = useState(false);

  const handleToggle = () => {
    setSettings((prev) => ({ ...prev, directCall: !prev.directCall }));
  };

  const handleSelectChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    setSettings((prev) => ({ ...prev, [e.target.name]: e.target.value }));
  };

  const handleSave = () => {
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
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
        <span className="text-xs text-amber-200 font-gujarati">ગોપનીયતા સેટિંગ્સ (Privacy & Settings)</span>
      </div>

      {/* Main Container */}
      <div className="w-full max-w-4xl bg-[#0d1b3e] border-2 border-[#c9a227] rounded-2xl shadow-2xl overflow-hidden font-gujarati">
        
        {/* Cropped Top Peacock Header Banner */}
        <div className="relative w-full h-44 md:h-56 overflow-hidden border-b-2 border-[#c9a227]">
          <Image
            src="/layoutimages/WhatsApp Image 2026-09-08 at 10.08.44 PM.jpeg"
            alt="Profile Privacy Header Vankar Samaj"
            fill
            priority
            className="object-cover object-top"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-[#0d1b3e] via-transparent to-black/40 flex items-end justify-center pb-3 px-4 text-center">
            <div>
              <h1 className="font-cinzel font-extrabold text-2xl md:text-3xl text-[#FFE066] drop-shadow-md">
                PRIVACY & SECURITY SETTINGS
              </h1>
              <p className="font-gujarati text-xs md:text-sm text-amber-200 drop-shadow">
                તમારી પ્રોફાઇલ માહિતી અને ફોન નંબર કોણ જોઈ શકે તે નક્કી કરો
              </p>
            </div>
          </div>
        </div>

        {/* Native Settings Body Section */}
        <div className="p-5 md:p-8 space-y-6">
          
          {saved && (
            <div className="p-3.5 rounded-xl bg-emerald-950/90 border border-emerald-500/80 text-emerald-200 text-xs text-center font-bold">
              ✓ ગોપનીયતા સેટિંગ્સ સફળતાપૂર્વક અપડેટ થઈ ગયા છે!
            </div>
          )}

          <div className="space-y-5 text-xs text-amber-100">
            {/* Phone Visibility */}
            <div className="space-y-1.5">
              <label className="block text-[#FFE066] font-bold text-sm">
                ૧. ફોન નંબર દર્શાવવો (Phone Number Visibility):
              </label>
              <select
                name="phoneVisibility"
                value={settings.phoneVisibility}
                onChange={handleSelectChange}
                className="w-full bg-[#070c18] border border-[#c9a227]/60 rounded-xl p-3 text-white focus:outline-none focus:border-[#FFE066] font-semibold"
              >
                <option>Only Verified Samaj Members (માત્ર ખરાઈ થયેલ સભ્યો)</option>
                <option>Mutual Interest Accepted Only (સંમતિ બાદ જ)</option>
                <option>Hide Phone Number (કોઈને પણ ના દર્શાવો)</option>
              </select>
            </div>

            {/* Photo Access */}
            <div className="space-y-1.5">
              <label className="block text-[#FFE066] font-bold text-sm">
                ૨. ફોટો દર્શાવવાની પરવાનગી (Profile Photo Access):
              </label>
              <select
                name="photoAccess"
                value={settings.photoAccess}
                onChange={handleSelectChange}
                className="w-full bg-[#070c18] border border-[#c9a227]/60 rounded-xl p-3 text-white focus:outline-none focus:border-[#FFE066] font-semibold"
              >
                <option>Visible to All Registered Users (તમામ નોંધાયેલ સભ્યો)</option>
                <option>Visible Only on Request (વિનંતી પર જ દર્શાવો)</option>
                <option>Protected with Password (પાસવર્ડ વડે સુરક્ષિત)</option>
              </select>
            </div>

            {/* Family Information */}
            <div className="space-y-1.5">
              <label className="block text-[#FFE066] font-bold text-sm">
                ૩. કુટુંબની વિગતો (Family Details Access):
              </label>
              <select
                name="familyInfo"
                value={settings.familyInfo}
                onChange={handleSelectChange}
                className="w-full bg-[#070c18] border border-[#c9a227]/60 rounded-xl p-3 text-white focus:outline-none focus:border-[#FFE066] font-semibold"
              >
                <option>Restricted to Mutual Interest (પરસ્પર સંમતિ પર)</option>
                <option>Public to All Verified Samaj Members (તમામ વણકર સભ્યો)</option>
              </select>
            </div>

            {/* Direct Calling Switch */}
            <div className="flex items-center justify-between bg-[#070c18] p-4 rounded-xl border border-[#c9a227]/40">
              <div>
                <span className="block font-bold text-white text-sm">૪. સીધો કોલ સ્વીકારો (Direct Calling):</span>
                <span className="text-xs text-amber-200/70">અન્ય ચકાસાયેલ સભ્યો દ્વારા સીધા કોલ કરવાની મંજૂરી</span>
              </div>
              <button
                type="button"
                onClick={handleToggle}
                className={`w-14 h-7 flex items-center rounded-full p-1 transition-colors duration-300 ${
                  settings.directCall ? "bg-[#c9a227] justify-end" : "bg-gray-700 justify-start"
                }`}
              >
                <div className="w-5 h-5 rounded-full bg-[#0d1b3e] shadow-md" />
              </button>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="pt-4 border-t border-[#c9a227]/30 flex gap-4">
            <Link
              href="/matrimony"
              className="w-1/3 py-3.5 rounded-xl bg-[#070c18] border border-[#c9a227]/60 text-amber-200 text-center font-bold text-xs hover:bg-[#c9a227]/20 transition-all"
            >
              પાછા જાઓ (Back)
            </Link>
            <button
              type="button"
              onClick={handleSave}
              className="w-2/3 py-3.5 rounded-xl bg-gradient-to-r from-[#c9a227] to-[#FFE066] text-[#0d1b3e] font-extrabold text-xs shadow-xl hover:brightness-110 transition-all uppercase font-cinzel tracking-wider"
            >
              સેવ સેટિંગ્સ (SAVE SETTINGS)
            </button>
          </div>

        </div>

      </div>
    </div>
  );
}
