"use client";

import React from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { StatusBadge } from "@/components/admin/StatusBadge";

const mockMatches = [
  { id: "m-1", candidateA: "Ramesh Vankar (35 Pargana)", candidateB: "Priyankaben Solanki (14 Pargana)", matchScore: "94%", status: "MUTUAL_INTEREST", date: "2026-09-08" },
  { id: "m-2", candidateA: "Hemantkumar Vankar (16 Pargana)", candidateB: "Hiralben Parmar (27 Pargana)", matchScore: "89%", status: "ACCEPTED", date: "2026-09-09" },
  { id: "m-3", candidateA: "Vikram Vankar (35 Pargana)", candidateB: "Aarti Vankar (27 Pargana)", matchScore: "82%", status: "PENDING", date: "2026-09-10" },
];

export default function AdminMatchesPage() {
  return (
    <AdminLayout title="Matchmaking Management" subtitle="Monitor mutual interests, shortlists & match connectivity">
      <div className="bg-[#0F2040] border border-[#997D20]/30 rounded-2xl p-6 shadow-xl space-y-4">
        <h3 className="text-base font-bold text-white">Active Matrimonial Matches</h3>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-white">
            <thead className="bg-[#041026] text-[#D4AF37] uppercase text-[10px] tracking-wider border-b border-[#997D20]/30">
              <tr>
                <th className="py-3 px-4">Candidate A</th>
                <th className="py-3 px-4">Candidate B</th>
                <th className="py-3 px-4">Compatibility</th>
                <th className="py-3 px-4">Status</th>
                <th className="py-3 px-4">Match Date</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#997D20]/10">
              {mockMatches.map((m) => (
                <tr key={m.id} className="hover:bg-[#041026]/50">
                  <td className="py-3.5 px-4 font-bold text-white">{m.candidateA}</td>
                  <td className="py-3.5 px-4 font-bold text-white">{m.candidateB}</td>
                  <td className="py-3.5 px-4 font-extrabold text-[#D4AF37]">{m.matchScore}</td>
                  <td className="py-3.5 px-4"><StatusBadge status={m.status} /></td>
                  <td className="py-3.5 px-4 text-gray-300">{m.date}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </AdminLayout>
  );
}
