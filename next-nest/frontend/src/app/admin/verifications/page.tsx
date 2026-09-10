"use client";

import React, { useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { StatusBadge } from "@/components/admin/StatusBadge";

const mockVerifications = [
  { id: "v-1", name: "Hemantkumar Vankar", type: "Govt ID & Passport Photo", pargana: "16 Pargana", date: "2026-09-09", status: "VERIFIED" },
  { id: "v-2", name: "Hiralben Parmar", type: "Family Address & Mosal Proof", pargana: "27 Pargana", date: "2026-09-09", status: "VERIFIED" },
  { id: "v-3", name: "Mehul Vankar", type: "Higher Education Degree", pargana: "35 Pargana", date: "2026-09-10", status: "PENDING" },
  { id: "v-4", name: "Aarti Vankar", type: "Profile Photo Verification", pargana: "14 Pargana", date: "2026-09-10", status: "PENDING" },
  { id: "v-5", name: "Sanjay Solanki", type: "Income & Salary Slip", pargana: "35 Pargana", date: "2026-09-08", status: "REJECTED" },
];

export default function AdminVerificationsPage() {
  const [items, setItems] = useState(mockVerifications);

  const updateStatus = (id: string, status: string) => {
    setItems((prev) => prev.map((item) => (item.id === id ? { ...item, status } : item)));
  };

  return (
    <AdminLayout title="Verification Management" subtitle="Approve or reject submitted community profile proofs">
      <div className="space-y-6">
        <div className="bg-[#0F2040] border border-[#997D20]/30 rounded-2xl p-6 shadow-xl">
          <div className="flex justify-between items-center mb-6">
            <h3 className="text-base font-bold text-white">Verification Submissions</h3>
            <span className="text-xs text-[#D4AF37] font-semibold">Pending: {items.filter(i => i.status === "PENDING").length}</span>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs text-white">
              <thead className="bg-[#041026] text-[#D4AF37] uppercase text-[10px] tracking-wider border-b border-[#997D20]/30">
                <tr>
                  <th className="py-3 px-4">Member Name</th>
                  <th className="py-3 px-4">Verification Type</th>
                  <th className="py-3 px-4">Pargana</th>
                  <th className="py-3 px-4">Submitted Date</th>
                  <th className="py-3 px-4">Status</th>
                  <th className="py-3 px-4 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-[#997D20]/10">
                {items.map((item) => (
                  <tr key={item.id} className="hover:bg-[#041026]/50 transition-colors">
                    <td className="py-3.5 px-4 font-bold text-white">{item.name}</td>
                    <td className="py-3.5 px-4 text-[#AAB7C8]">{item.type}</td>
                    <td className="py-3.5 px-4 text-white">{item.pargana}</td>
                    <td className="py-3.5 px-4 text-gray-300">{item.date}</td>
                    <td className="py-3.5 px-4">
                      <StatusBadge status={item.status} />
                    </td>
                    <td className="py-3.5 px-4 text-right space-x-2">
                      <button
                        onClick={() => updateStatus(item.id, "VERIFIED")}
                        className="px-2.5 py-1 rounded bg-emerald-950/60 text-emerald-400 border border-emerald-500/40 text-[10px] font-bold hover:bg-emerald-900"
                      >
                        Approve
                      </button>
                      <button
                        onClick={() => updateStatus(item.id, "REJECTED")}
                        className="px-2.5 py-1 rounded bg-rose-950/60 text-rose-400 border border-rose-500/40 text-[10px] font-bold hover:bg-rose-900"
                      >
                        Reject
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
