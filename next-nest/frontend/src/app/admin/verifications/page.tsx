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
  const [filter, setFilter] = useState("ALL");
  const [search, setSearch] = useState("");

  const updateStatus = (id: string, status: string) => {
    setItems((prev) => prev.map((item) => (item.id === id ? { ...item, status } : item)));
  };

  const filteredItems = items.filter((item) => {
    const matchesSearch = item.name.toLowerCase().includes(search.toLowerCase()) || item.type.toLowerCase().includes(search.toLowerCase());
    const matchesFilter = filter === "ALL" || item.status === filter;
    return matchesSearch && matchesFilter;
  });

  return (
    <AdminLayout title="Verification Management" subtitle="Approve or reject submitted community profile proofs">
      <div className="space-y-6">
        {/* Search & Status Filter Bar */}
        <div className="bg-[#0F2040] border border-[#997D20]/40 rounded-2xl p-4 flex flex-col sm:flex-row justify-between items-center gap-4 shadow-xl">
          <div className="relative w-full sm:w-80">
            <input
              type="text"
              placeholder="Search member or document type..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full bg-[#041026] border border-[#997D20]/40 rounded-xl px-4 py-2.5 pl-10 text-xs text-white placeholder-[#AAB7C8]/60 focus:outline-none focus:border-[#D4AF37]"
            />
            <span className="absolute left-3 top-3 text-xs text-[#AAB7C8]">🔍</span>
          </div>

          <div className="flex gap-2">
            {["ALL", "PENDING", "VERIFIED", "REJECTED"].map((tab) => (
              <button
                key={tab}
                onClick={() => setFilter(tab)}
                className={`px-3.5 py-2 rounded-xl text-xs font-extrabold transition-all ${
                  filter === tab
                    ? "bg-[#D4AF37] text-black shadow-md"
                    : "bg-[#041026] text-[#AAB7C8] border border-[#997D20]/30 hover:text-white"
                }`}
              >
                {tab}
              </button>
            ))}
          </div>
        </div>

        {/* Verification Submissions Table */}
        <div className="bg-[#0F2040] border border-[#997D20]/40 rounded-2xl p-6 shadow-xl">
          <div className="flex justify-between items-center mb-6">
            <h3 className="text-base font-bold text-white flex items-center gap-2">
              <span>🛡️</span> Verification Review Requests
            </h3>
            <span className="text-xs text-[#D4AF37] font-bold bg-[#041026] px-3 py-1 rounded-full border border-[#997D20]/40">
              Pending Queue: {items.filter(i => i.status === "PENDING").length}
            </span>
          </div>

          <div className="overflow-x-auto rounded-xl border border-[#997D20]/30">
            <table className="w-full text-left text-xs text-white border-collapse">
              <thead className="bg-[#041026] text-[#D4AF37] uppercase text-[10px] tracking-wider border-b border-[#997D20]/40">
                <tr>
                  <th className="py-3.5 px-4 font-extrabold min-w-[160px]">Member Name</th>
                  <th className="py-3.5 px-4 font-extrabold min-w-[200px]">Verification Type</th>
                  <th className="py-3.5 px-4 font-extrabold min-w-[110px]">Pargana</th>
                  <th className="py-3.5 px-4 font-extrabold min-w-[120px]">Submitted Date</th>
                  <th className="py-3.5 px-4 font-extrabold min-w-[100px]">Status</th>
                  <th className="py-3.5 px-4 font-extrabold text-right min-w-[160px]">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-[#997D20]/15 bg-[#0F2040]">
                {filteredItems.map((item) => (
                  <tr key={item.id} className="hover:bg-[#041026]/70 transition-colors">
                    <td className="py-3.5 px-4 font-bold text-white">{item.name}</td>
                    <td className="py-3.5 px-4 text-[#AAB7C8] font-medium">{item.type}</td>
                    <td className="py-3.5 px-4 text-white font-semibold">{item.pargana}</td>
                    <td className="py-3.5 px-4 text-gray-300 font-mono text-[11px]">{item.date}</td>
                    <td className="py-3.5 px-4">
                      <StatusBadge status={item.status} />
                    </td>
                    <td className="py-3.5 px-4 text-right space-x-2">
                      <button
                        onClick={() => updateStatus(item.id, "VERIFIED")}
                        className="px-3 py-1.5 rounded-lg bg-emerald-950 text-emerald-300 border border-emerald-500/50 text-[10px] font-extrabold hover:bg-emerald-800 transition-colors"
                      >
                        Approve
                      </button>
                      <button
                        onClick={() => updateStatus(item.id, "REJECTED")}
                        className="px-3 py-1.5 rounded-lg bg-rose-950 text-rose-300 border border-rose-500/50 text-[10px] font-extrabold hover:bg-rose-800 transition-colors"
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

