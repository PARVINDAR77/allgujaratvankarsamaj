"use client";

import React from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { StatusBadge } from "@/components/admin/StatusBadge";

const mockInterests = [
  { id: "i-1", sender: "Ramesh Vankar", receiver: "Hiralben Parmar", status: "ACCEPTED", date: "2026-09-08" },
  { id: "i-2", sender: "Hemantkumar Vankar", receiver: "Priyankaben Solanki", status: "PENDING", date: "2026-09-09" },
  { id: "i-3", sender: "Vikram Vankar", receiver: "Aarti Vankar", status: "DECLINED", date: "2026-09-10" },
];

export default function AdminInterestsPage() {
  return (
    <AdminLayout title="Express Interest Moderation" subtitle="Monitor member interest expressions and response rates">
      <div className="bg-[#0F2040] border border-[#997D20]/30 rounded-2xl p-6 shadow-xl space-y-4">
        <h3 className="text-base font-bold text-white">Interest Requests Log</h3>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-white">
            <thead className="bg-[#041026] text-[#D4AF37] uppercase text-[10px] tracking-wider border-b border-[#997D20]/30">
              <tr>
                <th className="py-3 px-4">Sender</th>
                <th className="py-3 px-4">Receiver</th>
                <th className="py-3 px-4">Status</th>
                <th className="py-3 px-4">Date</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#997D20]/10">
              {mockInterests.map((i) => (
                <tr key={i.id} className="hover:bg-[#041026]/50">
                  <td className="py-3.5 px-4 font-bold text-white">{i.sender}</td>
                  <td className="py-3.5 px-4 text-[#D4AF37] font-semibold">{i.receiver}</td>
                  <td className="py-3.5 px-4"><StatusBadge status={i.status} /></td>
                  <td className="py-3.5 px-4 text-gray-300">{i.date}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </AdminLayout>
  );
}
