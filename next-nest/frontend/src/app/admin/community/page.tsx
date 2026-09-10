"use client";

import React from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { StatusBadge } from "@/components/admin/StatusBadge";

const mockCommunity = [
  { id: "cm-1", name: "Ramesh Vankar", role: "Samaj Trustee", pargana: "35 Pargana", city: "Ahmedabad", status: "ACTIVE" },
  { id: "cm-2", name: "Hiralben Parmar", role: "Directory Member", pargana: "27 Pargana", city: "Vadodara", status: "ACTIVE" },
  { id: "cm-3", name: "Maheshkumar Vankar", role: "Executive Board", pargana: "16 Pargana", city: "Surat", status: "ACTIVE" },
];

export default function AdminCommunityPage() {
  return (
    <AdminLayout title="Community Directory" subtitle="Directory of Samaj leaders, trustees, and verified members">
      <div className="bg-[#0F2040] border border-[#997D20]/30 rounded-2xl p-6 shadow-xl space-y-4">
        <h3 className="text-base font-bold text-white">Samaj Directory Members</h3>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-white">
            <thead className="bg-[#041026] text-[#D4AF37] uppercase text-[10px] tracking-wider border-b border-[#997D20]/30">
              <tr>
                <th className="py-3 px-4">Member Name</th>
                <th className="py-3 px-4">Role / Position</th>
                <th className="py-3 px-4">Pargana</th>
                <th className="py-3 px-4">City</th>
                <th className="py-3 px-4 text-right">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#997D20]/10">
              {mockCommunity.map((c) => (
                <tr key={c.id} className="hover:bg-[#041026]/50">
                  <td className="py-3.5 px-4 font-bold text-white">{c.name}</td>
                  <td className="py-3.5 px-4 text-[#D4AF37] font-semibold">{c.role}</td>
                  <td className="py-3.5 px-4 text-white">{c.pargana}</td>
                  <td className="py-3.5 px-4 text-[#AAB7C8]">{c.city}</td>
                  <td className="py-3.5 px-4 text-right"><StatusBadge status={c.status} /></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </AdminLayout>
  );
}
