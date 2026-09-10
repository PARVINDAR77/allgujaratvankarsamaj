"use client";

import React from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";

const mockShortlists = [
  { id: "s-1", user: "Ramesh Vankar", shortlistedProfile: "Hiralben Parmar", pargana: "27 Pargana", date: "2026-09-09" },
  { id: "s-2", user: "Hemantkumar Vankar", shortlistedProfile: "Priyankaben Solanki", pargana: "14 Pargana", date: "2026-09-10" },
];

export default function AdminShortlistsPage() {
  return (
    <AdminLayout title="Shortlist Activity" subtitle="View candidate shortlisting trends across Samaj regions">
      <div className="bg-[#0F2040] border border-[#997D20]/30 rounded-2xl p-6 shadow-xl space-y-4">
        <h3 className="text-base font-bold text-white">Recent Profile Shortlists</h3>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-white">
            <thead className="bg-[#041026] text-[#D4AF37] uppercase text-[10px] tracking-wider border-b border-[#997D20]/30">
              <tr>
                <th className="py-3 px-4">User</th>
                <th className="py-3 px-4">Shortlisted Profile</th>
                <th className="py-3 px-4">Pargana</th>
                <th className="py-3 px-4">Date</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#997D20]/10">
              {mockShortlists.map((s) => (
                <tr key={s.id} className="hover:bg-[#041026]/50">
                  <td className="py-3.5 px-4 font-bold text-white">{s.user}</td>
                  <td className="py-3.5 px-4 text-[#D4AF37] font-semibold">{s.shortlistedProfile}</td>
                  <td className="py-3.5 px-4 text-[#AAB7C8]">{s.pargana}</td>
                  <td className="py-3.5 px-4 text-gray-300">{s.date}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </AdminLayout>
  );
}
