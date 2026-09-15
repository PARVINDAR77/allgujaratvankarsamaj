"use client";

import React, { useState, useEffect } from "react";
import Link from "next/link";

interface GovtEmp {
  id: string;
  fullName: string;
  gender: string;
  age?: number;
  education: string;
  maritalStatus: string;
  districtName?: string;
  employmentType: string;
  departmentName: string;
  departmentGujaratiName: string;
  designationName: string;
  designationGujaratiName: string;
  officeLocation?: string;
  isVerified: boolean;
  isFeatured: boolean;
}

interface Department {
  id: string;
  name: string;
  gujaratiName?: string;
}

export default function GovernmentEmployeesPublicPage() {
  const [profiles, setProfiles] = useState<GovtEmp[]>([]);
  const [departments, setDepartments] = useState<Department[]>([]);
  const [loading, setLoading] = useState(true);
  const [gender, setGender] = useState("");
  const [deptId, setDeptId] = useState("");
  const [search, setSearch] = useState("");

  const API_BASE = "http://localhost:3000/api/v1";

  const loadDepartments = async () => {
    try {
      const res = await fetch(`${API_BASE}/government-employees/departments`);
      if (res.ok) {
        const data = await res.json();
        setDepartments(data || []);
      }
    } catch (e) {
      console.error(e);
    }
  };

  const loadProfiles = async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams();
      if (gender) params.append("gender", gender);
      if (deptId) params.append("departmentId", deptId);
      if (search) params.append("search", search);

      const res = await fetch(`${API_BASE}/government-employees?${params.toString()}`);
      if (res.ok) {
        const data = await res.json();
        setProfiles(data.items || []);
      }
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadDepartments();
    loadProfiles();
  }, []);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    loadProfiles();
  };

  const handleReset = () => {
    setGender("");
    setDeptId("");
    setSearch("");
    setTimeout(() => {
      loadProfiles();
    }, 50);
  };

  return (
    <div className="min-h-screen bg-[#F3F7FA] text-[#0F172A] font-sans pb-12">
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Cinzel:wght@600;700;800&family=Noto+Sans+Gujarati:wght@400;600;700&display=swap');
        .font-cinzel { font-family: 'Cinzel', serif; }
        .font-gujarati { font-family: 'Noto Sans Gujarati', sans-serif; }
      `}</style>

      {/* Top Header Navbar */}
      <div className="bg-[#003875] text-white px-4 py-3 flex items-center justify-between shadow-md">
        <Link href="/matrimony" className="flex items-center gap-2 text-white font-bold text-sm hover:underline">
          &larr; વણકર સમાજ મેટ્રિમોની (Home)
        </Link>
        <span className="text-xs font-bold text-[#FFE066] font-gujarati">સરકારી કર્મચારી લાઈવ સેક્શન</span>
      </div>

      {/* Hero Banner Header matching reference */}
      <div className="bg-gradient-to-b from-[#003875] to-[#0056B3] text-white py-8 px-4 text-center border-b-2 border-[#FFD700]">
        <div className="inline-flex items-center gap-2 bg-[#061A3A] border border-[#FFD700] rounded-full px-4 py-1.5 mb-3">
          <span>🏛️</span>
          <span className="font-cinzel font-bold text-xs text-[#FFD700] tracking-wider">
            Government Employee Matrimony Section
          </span>
        </div>
        <div className="my-2">
          <span className="inline-block bg-[#D90429] text-white font-bold text-xs px-4 py-1.5 rounded-full shadow-md">
            Government Employees • Trusted • Verified • Together
          </span>
        </div>
        <p className="font-gujarati text-xs md:text-sm text-slate-200 mt-2">
          સુરક્ષિત જીવનસાથી માટે સરકારી કર્મચારીઓ માટે વિશેષ મેટ્રિમોની સેવા
        </p>
      </div>

      {/* Trust Pillars */}
      <div className="bg-white border-b border-slate-200 py-4 px-4">
        <div className="max-w-4xl mx-auto grid grid-cols-2 md:grid-cols-4 gap-4 text-center">
          <div className="flex flex-col items-center">
            <span className="text-2xl">🏛️</span>
            <span className="font-bold text-xs text-slate-900 mt-1">Verified Profiles</span>
            <span className="text-[10px] text-slate-500">Only verified govt employees</span>
          </div>
          <div className="flex flex-col items-center">
            <span className="text-2xl">🛡️</span>
            <span className="font-bold text-xs text-slate-900 mt-1">Secure Platform</span>
            <span className="text-[10px] text-slate-500">Safe & trusted service</span>
          </div>
          <div className="flex flex-col items-center">
            <span className="text-2xl">👥</span>
            <span className="font-bold text-xs text-slate-900 mt-1">Wide Network</span>
            <span className="text-[10px] text-slate-500">All departments</span>
          </div>
          <div className="flex flex-col items-center">
            <span className="text-2xl">💖</span>
            <span className="font-bold text-xs text-slate-900 mt-1">Better Matches</span>
            <span className="text-[10px] text-slate-500">Find compatible life partners</span>
          </div>
        </div>
      </div>

      <div className="max-w-4xl mx-auto px-4 mt-6">
        {/* Search & Filter Container */}
        <form onSubmit={handleSearch} className="bg-[#0056B3] text-white p-5 rounded-2xl shadow-lg space-y-4">
          <div className="flex items-center gap-2 font-bold text-base">
            <span>🔍</span>
            <span>Search Government Employee Profiles</span>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-semibold mb-1 text-slate-200">Gender</label>
              <select
                value={gender}
                onChange={(e) => setGender(e.target.value)}
                className="w-full bg-white text-slate-900 text-xs rounded-lg p-2.5 outline-none"
              >
                <option value="">All Genders</option>
                <option value="MALE">Male / વર</option>
                <option value="FEMALE">Female / કન્યા</option>
              </select>
            </div>

            <div>
              <label className="block text-xs font-semibold mb-1 text-slate-200">Department</label>
              <select
                value={deptId}
                onChange={(e) => setDeptId(e.target.value)}
                className="w-full bg-white text-slate-900 text-xs rounded-lg p-2.5 outline-none"
              >
                <option value="">All Departments</option>
                {departments.map((d) => (
                  <option key={d.id} value={d.id}>
                    {d.name}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <div>
            <label className="block text-xs font-semibold mb-1 text-slate-200">Search Query</label>
            <input
              type="text"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search by Name, Designation, Office..."
              className="w-full bg-white text-slate-900 text-xs rounded-lg p-2.5 outline-none placeholder:text-slate-400"
            />
          </div>

          <div className="flex gap-3 pt-1">
            <button
              type="submit"
              className="flex-1 bg-[#007BFF] hover:bg-blue-600 text-white font-bold text-xs py-2.5 rounded-lg shadow transition-all"
            >
              Search Profiles
            </button>
            <button
              type="button"
              onClick={handleReset}
              className="bg-slate-200 hover:bg-slate-300 text-slate-900 font-bold text-xs px-4 py-2.5 rounded-lg transition-all"
            >
              Reset
            </button>
          </div>
        </form>

        {/* Profile Grid Title */}
        <div className="mt-8 mb-4 flex items-center gap-2 font-bold text-lg text-slate-900">
          <span>🌟</span>
          <span>Verified Government Employee Profiles</span>
        </div>

        {/* Profiles Grid */}
        {loading ? (
          <div className="py-12 text-center text-slate-500 text-sm">Loading Verified Government Profiles...</div>
        ) : profiles.length === 0 ? (
          <div className="bg-white border border-slate-200 rounded-2xl p-8 text-center text-slate-500 space-y-3">
            <div className="text-3xl">🔍</div>
            <div className="font-bold text-sm">No profiles found matching current criteria.</div>
            <button onClick={handleReset} className="text-xs bg-[#0056B3] text-white font-bold px-4 py-2 rounded-lg">
              Clear Filters
            </button>
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
            {profiles.map((p) => (
              <div key={p.id} className="bg-white border border-slate-200 rounded-2xl p-4 flex flex-col justify-between shadow-sm hover:shadow-md transition-shadow">
                <div>
                  <div className="flex justify-between items-start mb-3">
                    <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center font-bold text-blue-800 text-lg">
                      {p.fullName ? p.fullName[0] : "V"}
                    </div>
                    <span className="bg-emerald-500 text-white text-[10px] font-extrabold px-2 py-0.5 rounded-full flex items-center gap-1">
                      ✓ Verified
                    </span>
                  </div>

                  <span className={`inline-block text-[10px] font-bold px-2 py-0.5 rounded-full mb-2 ${p.gender === "FEMALE" ? "bg-indigo-100 text-indigo-800" : "bg-orange-100 text-orange-900"}`}>
                    {p.departmentName}
                  </span>

                  <h3 className="font-bold text-sm text-slate-900 truncate">{p.fullName}</h3>
                  <p className="text-xs text-slate-500">{p.age || 28} Years • {p.gender === "MALE" ? "Male" : "Female"}</p>
                  <p className="text-xs font-semibold text-slate-700 mt-1 truncate">{p.designationName}</p>
                  <p className="text-[11px] text-slate-500">📍 {p.districtName || "Gujarat"}</p>
                </div>

                <div className="mt-4 pt-3 border-t border-slate-100 flex gap-2">
                  <button
                    onClick={() => alert(`Viewing details for ${p.fullName}`)}
                    className="flex-1 py-1.5 border border-blue-600 text-blue-600 font-bold text-[10px] rounded-lg hover:bg-blue-50"
                  >
                    View Profile
                  </button>
                  <button
                    onClick={() => alert(`Interest sent to ${p.fullName}`)}
                    className="flex-1 py-1.5 bg-[#007BFF] text-white font-bold text-[10px] rounded-lg hover:bg-blue-700 shadow-sm"
                  >
                    Send Interest
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
