"use client";

import React from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";

const mockParganas = [
  { id: "pg-1", name: "35 Pargana", region: "Central Gujarat", members: 4850, profiles: 3200, matches: 1240 },
  { id: "pg-2", name: "27 Pargana", region: "North Gujarat", members: 3200, profiles: 2100, matches: 890 },
  { id: "pg-3", name: "16 Pargana", region: "South Gujarat", members: 2100, profiles: 1400, matches: 580 },
  { id: "pg-4", name: "14 Pargana", region: "Saurashtra / Kutch", members: 1400, profiles: 950, matches: 410 },
  { id: "pg-5", name: "Other Pargana", region: "Outstation / NRI", members: 998, profiles: 680, matches: 210 },
];

export default function AdminParganasPage() {
  return (
    <AdminLayout title="Pargana Management" subtitle="Manage Vankar Samaj regional divisions, member counts & matches">
      <div className="space-y-6">
        <div className="bg-[#0F2040] border border-[#997D20]/30 rounded-2xl p-4 flex justify-between items-center">
          <h3 className="text-sm font-bold text-white">All Vankar Samaj Pargana Divisions</h3>
          <button className="px-4 py-2 rounded-xl bg-gradient-to-r from-[#D4AF37] to-[#E8C95A] text-black font-bold text-xs uppercase shadow-md">
            + Add New Pargana
          </button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
          {mockParganas.map((p) => (
            <div key={p.id} className="bg-[#0F2040] border border-[#997D20]/30 hover:border-[#D4AF37] rounded-2xl p-5 shadow-xl transition-all">
              <div className="flex justify-between items-start mb-3">
                <div>
                  <h4 className="text-base font-extrabold text-[#D4AF37]">{p.name}</h4>
                  <p className="text-xs text-[#AAB7C8]">{p.region}</p>
                </div>
                <div className="w-9 h-9 rounded-full bg-[#041026] border border-[#997D20]/40 flex items-center justify-center text-base">
                  🏛️
                </div>
              </div>

              <div className="space-y-2 text-xs border-t border-[#997D20]/20 pt-3 my-3">
                <div className="flex justify-between"><span className="text-[#AAB7C8]">Total Members:</span> <strong className="text-white">{p.members.toLocaleString()}</strong></div>
                <div className="flex justify-between"><span className="text-[#AAB7C8]">Matrimonial Profiles:</span> <strong className="text-white">{p.profiles.toLocaleString()}</strong></div>
                <div className="flex justify-between"><span className="text-[#AAB7C8]">Successful Matches:</span> <strong className="text-[#D4AF37]">{p.matches.toLocaleString()}</strong></div>
              </div>

              <div className="flex gap-2">
                <button className="flex-1 py-1.5 rounded bg-[#041026] border border-[#997D20]/40 text-[#D4AF37] text-xs font-bold hover:bg-[#D4AF37] hover:text-black transition-all">
                  Edit Pargana
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </AdminLayout>
  );
}
