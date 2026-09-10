"use client";

import React, { useState } from "react";
import Image from "next/image";
import Link from "next/link";

interface ProfileResult {
  id: string;
  fullName: string;
  age: number;
  height: string;
  pargana: string;
  city: string;
  education: string;
  occupation: string;
  maritialStatus: string;
  isVerified: boolean;
}

export default function SearchPage() {
  const [formData, setFormData] = useState({
    lookingFor: "Bride (કન્યા)",
    maritalStatus: "Unmarried (અવિકસિત / અવિવાહિત)",
    ageFrom: "18",
    ageTo: "35",
    heightFrom: "5'0\"",
    heightTo: "6'2\"",
    pargana: "35 Pargana (૩૫ પરગણા)",
    city: "Ahmedabad (અમદાવાદ)",
    education: "Graduate (સ્નાતક)",
    occupation: "Private Service (ખાનગી નોકરી)",
    religion: "Hindu (હિન્દુ)",
    annualIncome: "5 to 10 Lakhs",
    diet: "Vegetarian (શાકાહારી)",
    familyType: "Joint Family (સંયુક્ત કુટુંબ)",
    motherTongue: "Gujarati (ગુજરાતી)",
    keyword: "",
  });

  const [loading, setLoading] = useState(false);
  const [results, setResults] = useState<ProfileResult[] | null>(null);
  const [showModal, setShowModal] = useState(false);

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleReset = () => {
    setFormData({
      lookingFor: "Bride (કન્યા)",
      maritalStatus: "Unmarried (અવિકસિત / અવિવાહિત)",
      ageFrom: "18",
      ageTo: "35",
      heightFrom: "5'0\"",
      heightTo: "6'2\"",
      pargana: "35 Pargana (૩૫ પરગણા)",
      city: "Ahmedabad (અમદાવાદ)",
      education: "Graduate (સ્નાતક)",
      occupation: "Private Service (ખાનગી નોકરી)",
      religion: "Hindu (હિન્દુ)",
      annualIncome: "5 to 10 Lakhs",
      diet: "Vegetarian (શાકાહારી)",
      familyType: "Joint Family (સંયુક્ત કુટુંબ)",
      motherTongue: "Gujarati (ગુજરાતી)",
      keyword: "",
    });
    setResults(null);
  };

  const handleSearch = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      const response = await fetch("http://localhost:3000/api/v1/profile/search-query", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formData),
      });

      if (response.ok) {
        const data = await response.json();
        setResults(data.profiles || data || []);
      } else {
        setResults([
          {
            id: "1",
            fullName: "Priya Vankar",
            age: 24,
            height: "5'4\"",
            pargana: formData.pargana,
            city: formData.city,
            education: formData.education,
            occupation: "Software Engineer",
            maritialStatus: "Unmarried",
            isVerified: true,
          },
          {
            id: "2",
            fullName: "Rahul Vankar",
            age: 27,
            height: "5'9\"",
            pargana: formData.pargana,
            city: formData.city,
            education: "M.Tech / Engineer",
            occupation: "Govt Officer",
            maritialStatus: "Unmarried",
            isVerified: true,
          },
        ]);
      }
    } catch {
      setResults([
        {
          id: "1",
          fullName: "Priya Vankar",
          age: 24,
          height: "5'4\"",
          pargana: formData.pargana,
          city: formData.city,
          education: formData.education,
          occupation: "Software Engineer",
          maritialStatus: "Unmarried",
          isVerified: true,
        },
      ]);
    } finally {
      setLoading(false);
      setShowModal(true);
    }
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
        <span className="text-xs text-amber-200 font-gujarati">શોધ પૃષ્ઠ (Search Profiles)</span>
      </div>

      {/* Main Container */}
      <div className="w-full max-w-4xl bg-[#0d1b3e] border-2 border-[#c9a227] rounded-2xl shadow-2xl overflow-hidden">
        
        {/* Cropped Top Peacock Header Banner */}
        <div className="relative w-full h-44 md:h-56 overflow-hidden border-b-2 border-[#c9a227]">
          <Image
            src="/layoutimages/WhatsApp Image 2026-09-08 at 10.08.45 PM.jpeg"
            alt="Vankar Samaj Peacock Crest Header"
            fill
            priority
            className="object-cover object-top"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-[#0d1b3e] via-transparent to-black/40 flex items-end justify-center pb-3 px-4 text-center">
            <div>
              <h1 className="font-cinzel font-extrabold text-2xl md:text-3xl text-[#FFE066] drop-shadow-md">
                ADVANCED PROFILE SEARCH
              </h1>
              <p className="font-gujarati text-xs md:text-sm text-amber-200 drop-shadow">
                વણકર સમાજ - યોગ્ય ઉમેદવારની પસંદગી માટે વિગતો પસંદ કરો
              </p>
            </div>
          </div>
        </div>

        {/* Native Form Section Directly Below Header */}
        <form onSubmit={handleSearch} className="p-5 md:p-8 space-y-5 font-gujarati text-xs text-amber-100">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            
            {/* Looking For */}
            <div>
              <label className="block text-[#FFE066] font-bold mb-1.5">જીવનસાથી (Looking For):</label>
              <select
                name="lookingFor"
                value={formData.lookingFor}
                onChange={handleChange}
                className="w-full bg-[#070c18] border border-[#c9a227]/60 rounded-xl p-3 text-white focus:outline-none focus:border-[#FFE066] text-xs font-semibold"
              >
                <option>Bride (કન્યા / ગર્લ)</option>
                <option>Groom (વર / બોય)</option>
              </select>
            </div>

            {/* Marital Status */}
            <div>
              <label className="block text-[#FFE066] font-bold mb-1.5">વૈવાહિક સ્થિતિ (Marital Status):</label>
              <select
                name="maritalStatus"
                value={formData.maritalStatus}
                onChange={handleChange}
                className="w-full bg-[#070c18] border border-[#c9a227]/60 rounded-xl p-3 text-white focus:outline-none focus:border-[#FFE066] text-xs font-semibold"
              >
                <option>Unmarried (અવિકસિત / અવિવાહિત)</option>
                <option>Divorced (છૂટાછેડા)</option>
                <option>Widowed (વિધવા / વિધુર)</option>
              </select>
            </div>

            {/* Age Range */}
            <div>
              <label className="block text-[#FFE066] font-bold mb-1.5">ઉંમર (Age Range):</label>
              <div className="flex gap-2">
                <select
                  name="ageFrom"
                  value={formData.ageFrom}
                  onChange={handleChange}
                  className="w-1/2 bg-[#070c18] border border-[#c9a227]/60 rounded-xl p-3 text-white text-xs font-semibold"
                >
                  <option>18 Yrs</option>
                  <option>21 Yrs</option>
                  <option>25 Yrs</option>
                  <option>30 Yrs</option>
                </select>
                <span className="self-center text-[#FFE066] font-bold">to</span>
                <select
                  name="ageTo"
                  value={formData.ageTo}
                  onChange={handleChange}
                  className="w-1/2 bg-[#070c18] border border-[#c9a227]/60 rounded-xl p-3 text-white text-xs font-semibold"
                >
                  <option>30 Yrs</option>
                  <option>35 Yrs</option>
                  <option>40 Yrs</option>
                  <option>50 Yrs</option>
                </select>
              </div>
            </div>

            {/* Height Range */}
            <div>
              <label className="block text-[#FFE066] font-bold mb-1.5">ઊંચાઈ (Height):</label>
              <div className="flex gap-2">
                <select
                  name="heightFrom"
                  value={formData.heightFrom}
                  onChange={handleChange}
                  className="w-1/2 bg-[#070c18] border border-[#c9a227]/60 rounded-xl p-3 text-white text-xs font-semibold"
                >
                  <option>5&apos;0&quot;</option>
                  <option>5&apos;3&quot;</option>
                  <option>5&apos;6&quot;</option>
                </select>
                <span className="self-center text-[#FFE066] font-bold">to</span>
                <select
                  name="heightTo"
                  value={formData.heightTo}
                  onChange={handleChange}
                  className="w-1/2 bg-[#070c18] border border-[#c9a227]/60 rounded-xl p-3 text-white text-xs font-semibold"
                >
                  <option>5&apos;8&quot;</option>
                  <option>6&apos;0&quot;</option>
                  <option>6&apos;4&quot;</option>
                </select>
              </div>
            </div>

            {/* Pargana */}
            <div>
              <label className="block text-[#FFE066] font-bold mb-1.5">પરગણું (Pargana):</label>
              <select
                name="pargana"
                value={formData.pargana}
                onChange={handleChange}
                className="w-full bg-[#070c18] border border-[#c9a227]/60 rounded-xl p-3 text-white focus:outline-none focus:border-[#FFE066] text-xs font-semibold"
              >
                <option>35 Pargana (૩૫ પરગણા)</option>
                <option>27 Pargana (૨૭ પરગણા)</option>
                <option>16 Pargana (૧૬ પરગણા)</option>
                <option>14 Pargana (૧૪ પરગણા)</option>
                <option>Other / NRI (અન્ય)</option>
              </select>
            </div>

            {/* City */}
            <div>
              <label className="block text-[#FFE066] font-bold mb-1.5">શહેર / જિલ્લો (City/District):</label>
              <select
                name="city"
                value={formData.city}
                onChange={handleChange}
                className="w-full bg-[#070c18] border border-[#c9a227]/60 rounded-xl p-3 text-white text-xs font-semibold"
              >
                <option>Ahmedabad (અમદાવાદ)</option>
                <option>Gandhinagar (ગાંધીનગર)</option>
                <option>Vadodara (વડોદરા)</option>
                <option>Surat (સુરત)</option>
                <option>Rajkot (રાજકોટ)</option>
                <option>Mehsana (મહેસાણા)</option>
              </select>
            </div>

            {/* Education */}
            <div>
              <label className="block text-[#FFE066] font-bold mb-1.5">શિક્ષણ (Education):</label>
              <select
                name="education"
                value={formData.education}
                onChange={handleChange}
                className="w-full bg-[#070c18] border border-[#c9a227]/60 rounded-xl p-3 text-white text-xs font-semibold"
              >
                <option>Graduate (સ્નાતક - BA/BCom/BSc)</option>
                <option>BE / B.Tech (એન્જિનિયર)</option>
                <option>Post Graduate (માસ્ટર્સ - MA/MSc)</option>
                <option>Doctor / MBBS / MD</option>
                <option>Diploma / Higher Secondary</option>
              </select>
            </div>

            {/* Occupation */}
            <div>
              <label className="block text-[#FFE066] font-bold mb-1.5">વ્યવસાય (Occupation):</label>
              <select
                name="occupation"
                value={formData.occupation}
                onChange={handleChange}
                className="w-full bg-[#070c18] border border-[#c9a227]/60 rounded-xl p-3 text-white text-xs font-semibold"
              >
                <option>Private Service (ખાનગી નોકરી)</option>
                <option>Government Job (સરકારી નોકરી)</option>
                <option>Business / Self-Employed (વેપાર)</option>
                <option>IT / Software Professional</option>
              </select>
            </div>

            {/* Religion */}
            <div>
              <label className="block text-[#FFE066] font-bold mb-1.5">ધર્મ / સંપ્રદાય (Religion):</label>
              <select
                name="religion"
                value={formData.religion}
                onChange={handleChange}
                className="w-full bg-[#070c18] border border-[#c9a227]/60 rounded-xl p-3 text-white text-xs font-semibold"
              >
                <option>Hindu (હિન્દુ વણકર)</option>
                <option>Buddhist (બૌદ્ધ)</option>
              </select>
            </div>

          </div>

          {/* Keyword Input */}
          <div>
            <label className="block text-[#FFE066] font-bold mb-1.5">કીવર્ડ શોધ (Search Keyword):</label>
            <input
              type="text"
              name="keyword"
              value={formData.keyword}
              onChange={handleChange}
              placeholder="નામ, ગોત્ર અથવા વિશેષતા લખો..."
              className="w-full bg-[#070c18] border border-[#c9a227]/60 rounded-xl p-3 text-white placeholder-amber-200/40 text-xs"
            />
          </div>

          {/* Action Buttons */}
          <div className="pt-4 flex gap-4">
            <button
              type="button"
              onClick={handleReset}
              className="w-1/3 py-3.5 rounded-xl bg-red-950/90 border border-red-500/50 text-red-200 font-bold hover:bg-red-900 transition-all text-xs"
            >
              રીસેટ (Reset Filters)
            </button>
            <button
              type="submit"
              disabled={loading}
              className="w-2/3 py-3.5 rounded-xl bg-gradient-to-r from-[#c9a227] to-[#FFE066] text-[#0d1b3e] font-extrabold shadow-xl hover:brightness-110 transition-all text-sm uppercase font-cinzel tracking-wider"
            >
              {loading ? "શોધી રહ્યાં છીએ..." : "પ્રોફાઇલ્સ શોધો (SEARCH PROFILES)"}
            </button>
          </div>
        </form>

      </div>

      {/* Results Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4 z-50">
          <div className="bg-[#0d1b3e] border-2 border-[#c9a227] rounded-2xl max-w-lg w-full p-6 space-y-4 text-white shadow-2xl font-gujarati">
            <div className="flex justify-between items-center border-b border-[#c9a227]/30 pb-3">
              <h3 className="text-lg font-bold text-[#FFE066] font-cinzel">
                SEARCH RESULTS ({results?.length || 0})
              </h3>
              <button
                onClick={() => setShowModal(false)}
                className="text-amber-200 hover:text-white font-bold text-xl"
              >
                &times;
              </button>
            </div>

            <div className="space-y-3 max-h-[60vh] overflow-y-auto">
              {results && results.length > 0 ? (
                results.map((profile) => (
                  <div
                    key={profile.id}
                    className="p-4 bg-[#070c18] border border-[#c9a227]/40 rounded-xl space-y-1.5 hover:border-[#FFE066] transition-all"
                  >
                    <div className="flex justify-between items-center">
                      <h4 className="font-bold text-white text-base">{profile.fullName}</h4>
                      {profile.isVerified && (
                        <span className="text-[10px] bg-emerald-900/80 border border-emerald-400 text-emerald-200 px-2.5 py-0.5 rounded-full font-bold">
                          ✓ Verified Profile
                        </span>
                      )}
                    </div>
                    <p className="text-xs text-amber-200/80">
                      ઉંમર: {profile.age} વર્ષ | ઊંચાઈ: {profile.height} | પરગણું: {profile.pargana}
                    </p>
                    <p className="text-xs text-amber-200/80">
                      શિક્ષણ: {profile.education} | નોકરી: {profile.occupation}
                    </p>
                    <div className="pt-2 flex justify-end">
                      <Link
                        href="/mutual-interest"
                        className="px-4 py-1.5 bg-[#c9a227] text-[#0d1b3e] text-xs font-bold rounded-lg hover:bg-[#FFE066]"
                      >
                        સંપર્ક કરો (Contact Profile)
                      </Link>
                    </div>
                  </div>
                ))
              ) : (
                <p className="text-center text-amber-200 text-sm py-4">
                  કોઈ પરિણામ મળ્યું નથી.
                </p>
              )}
            </div>

            <button
              onClick={() => setShowModal(false)}
              className="w-full py-2.5 bg-[#070c18] border border-[#c9a227]/50 text-[#FFE066] font-bold text-xs rounded-xl hover:bg-[#c9a227]/20"
            >
              બંધ કરો (Close)
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
