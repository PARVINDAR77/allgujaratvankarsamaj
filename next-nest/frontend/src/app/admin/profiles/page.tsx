"use client";

import React, { useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { StatusBadge } from "@/components/admin/StatusBadge";

const mockProfiles = [
  { id: "p-1", name: "Ramesh Vankar", age: 29, gender: "MALE", pargana: "35 Pargana", city: "Ahmedabad", education: "B.Tech IT", occupation: "Software Engineer", status: "VERIFIED" },
  { id: "p-2", name: "Hiralben Parmar", age: 26, gender: "FEMALE", pargana: "27 Pargana", city: "Vadodara", education: "M.Com", occupation: "Accountant", status: "VERIFIED" },
  { id: "p-3", name: "Hemantkumar Vankar", age: 31, gender: "MALE", pargana: "16 Pargana", city: "Surat", education: "MBBS", occupation: "Doctor", status: "PENDING" },
  { id: "p-4", name: "Priyankaben Solanki", age: 24, gender: "FEMALE", pargana: "14 Pargana", city: "Rajkot", education: "B.Sc Nursing", occupation: "Nurse", status: "PENDING" },
  { id: "p-5", name: "Mahesh Vankar", age: 28, gender: "MALE", pargana: "35 Pargana", city: "Gandhinagar", education: "MBA", occupation: "Bank Manager", status: "VERIFIED" },
];

export default function AdminProfilesPage() {
  const [profiles, setProfiles] = useState(mockProfiles);
  const [search, setSearch] = useState("");
  const [selectedProfile, setSelectedProfile] = useState<typeof mockProfiles[0] | null>(null);

  const filtered = profiles.filter(
    (p) =>
      p.name.toLowerCase().includes(search.toLowerCase()) ||
      p.city.toLowerCase().includes(search.toLowerCase()) ||
      p.pargana.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <AdminLayout title="Profiles Management" subtitle="Review, approve & feature matrimonial candidate profiles">
      <div className="space-y-6">
        {/* Search Header */}
        <div className="bg-[#0F2040] border border-[#997D20]/30 rounded-2xl p-4 flex flex-col sm:flex-row justify-between items-center gap-4 shadow-lg">
          <div className="relative w-full sm:w-80">
            <input
              type="text"
              placeholder="Search profiles by name, city, pargana..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full bg-[#041026] border border-[#997D20]/40 rounded-xl px-4 py-2.5 pl-9 text-xs text-white placeholder-[#AAB7C8]/60 focus:outline-none focus:border-[#D4AF37]"
            />
            <span className="absolute left-3 top-2.5 text-xs text-[#AAB7C8]">🔍</span>
          </div>
          <div className="text-xs text-[#D4AF37] font-bold bg-[#041026] px-3 py-1.5 rounded-xl border border-[#997D20]/30">
            Total Profiles: {profiles.length}
          </div>
        </div>

        {/* Profile Cards Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-5">
          {filtered.map((p) => (
            <div key={p.id} className="bg-[#0F2040] border border-[#997D20]/30 hover:border-[#D4AF37] rounded-2xl p-5 shadow-xl transition-all duration-300 flex flex-col justify-between group">
              <div>
                <div className="flex justify-between items-start gap-2 mb-3">
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 rounded-full bg-gradient-to-tr from-[#D4AF37] via-[#F3E5AB] to-[#E8C95A] text-black font-black text-lg flex items-center justify-center shadow-md shrink-0">
                      {p.name.charAt(0)}
                    </div>
                    <div className="min-w-0">
                      <h3 className="text-sm font-bold text-white group-hover:text-[#D4AF37] transition-colors truncate">{p.name}</h3>
                      <p className="text-[11px] text-[#AAB7C8] truncate">{p.age} yrs • {p.gender} • {p.city}</p>
                    </div>
                  </div>
                  <div className="shrink-0">
                    <StatusBadge status={p.status} />
                  </div>
                </div>

                <div className="space-y-1.5 text-xs text-gray-300 py-3 border-y border-[#997D20]/20 my-3">
                  <p className="flex justify-between"><span className="text-[#AAB7C8]">Pargana:</span> <strong className="text-white">{p.pargana}</strong></p>
                  <p className="flex justify-between"><span className="text-[#AAB7C8]">Education:</span> <span className="text-gray-200">{p.education}</span></p>
                  <p className="flex justify-between"><span className="text-[#AAB7C8]">Occupation:</span> <span className="text-gray-200">{p.occupation}</span></p>
                </div>
              </div>

              <div className="flex gap-2 pt-1">
                <button
                  onClick={() => setSelectedProfile(p)}
                  className="flex-1 py-2 rounded-xl bg-[#041026] border border-[#997D20]/40 text-[#D4AF37] text-xs font-bold hover:bg-[#D4AF37] hover:text-black transition-all"
                >
                  View Full Profile
                </button>
                <button
                  onClick={() =>
                    setProfiles((prev) =>
                      prev.map((item) =>
                        item.id === p.id ? { ...item, status: item.status === "VERIFIED" ? "PENDING" : "VERIFIED" } : item
                      )
                    )
                  }
                  className={`px-3 py-2 rounded-xl text-xs font-bold border transition-colors ${
                    p.status === "VERIFIED"
                      ? "bg-rose-950/60 text-rose-400 border-rose-500/40 hover:bg-rose-900"
                      : "bg-emerald-950/60 text-emerald-400 border-emerald-500/40 hover:bg-emerald-900"
                  }`}
                >
                  {p.status === "VERIFIED" ? "Unverify" : "Approve"}
                </button>
              </div>
            </div>
          ))}
        </div>

        {/* Profile Detail Modal */}
        {selectedProfile && (
          <div className="fixed inset-0 bg-black/80 z-50 flex items-center justify-center p-4" onClick={() => setSelectedProfile(null)}>
            <div className="bg-[#0F2040] border border-[#997D20] rounded-3xl p-6 max-w-md w-full shadow-2xl space-y-4 relative" onClick={(e) => e.stopPropagation()}>
              <button onClick={() => setSelectedProfile(null)} className="absolute top-4 right-4 text-[#AAB7C8] text-lg hover:text-white">✕</button>
              
              <div className="flex items-center gap-4">
                <div className="w-14 h-14 rounded-full bg-gradient-to-tr from-[#D4AF37] to-[#E8C95A] text-black font-black text-2xl flex items-center justify-center shadow-lg">
                  {selectedProfile.name.charAt(0)}
                </div>
                <div>
                  <h3 className="text-lg font-bold text-white">{selectedProfile.name}</h3>
                  <p className="text-xs text-[#D4AF37] font-semibold">{selectedProfile.pargana} Candidate</p>
                </div>
              </div>

              <div className="space-y-2 text-xs text-gray-300 border-t border-[#997D20]/20 pt-4">
                <p><strong className="text-[#AAB7C8]">Age / Gender:</strong> {selectedProfile.age} years • {selectedProfile.gender}</p>
                <p><strong className="text-[#AAB7C8]">City of Residence:</strong> {selectedProfile.city}</p>
                <p><strong className="text-[#AAB7C8]">Education:</strong> {selectedProfile.education}</p>
                <p><strong className="text-[#AAB7C8]">Occupation:</strong> {selectedProfile.occupation}</p>
                <p><strong className="text-[#AAB7C8]">Verification Status:</strong> <StatusBadge status={selectedProfile.status} /></p>
              </div>

              <div className="pt-2">
                <button onClick={() => setSelectedProfile(null)} className="w-full py-2.5 rounded-xl bg-gradient-to-r from-[#D4AF37] to-[#E8C95A] text-black font-bold text-xs uppercase">
                  Close Window
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </AdminLayout>
  );
}
