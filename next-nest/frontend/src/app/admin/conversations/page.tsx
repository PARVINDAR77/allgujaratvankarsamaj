"use client";

import React from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";

const mockConversations = [
  { id: "c-1", participants: "Ramesh Vankar & Hiralben Parmar", messageCount: 14, lastActive: "10 mins ago", status: "ACTIVE" },
  { id: "c-2", participants: "Hemantkumar Vankar & Priyankaben Solanki", messageCount: 8, lastActive: "1 hour ago", status: "ACTIVE" },
];

export default function AdminConversationsPage() {
  return (
    <AdminLayout title="Active Conversations" subtitle="Overview of candidate message threads & engagement">
      <div className="bg-[#0F2040] border border-[#997D20]/30 rounded-2xl p-6 shadow-xl space-y-4">
        <h3 className="text-base font-bold text-white">Member Conversations</h3>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-white">
            <thead className="bg-[#041026] text-[#D4AF37] uppercase text-[10px] tracking-wider border-b border-[#997D20]/30">
              <tr>
                <th className="py-3 px-4">Participants</th>
                <th className="py-3 px-4">Total Messages</th>
                <th className="py-3 px-4">Last Activity</th>
                <th className="py-3 px-4 text-right">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#997D20]/10">
              {mockConversations.map((c) => (
                <tr key={c.id} className="hover:bg-[#041026]/50">
                  <td className="py-3.5 px-4 font-bold text-white">{c.participants}</td>
                  <td className="py-3.5 px-4 font-extrabold text-[#D4AF37]">{c.messageCount}</td>
                  <td className="py-3.5 px-4 text-[#AAB7C8]">{c.lastActive}</td>
                  <td className="py-3.5 px-4 text-right">
                    <span className="px-2 py-0.5 rounded bg-emerald-950 text-emerald-400 border border-emerald-500/40 text-[10px] font-bold">
                      {c.status}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </AdminLayout>
  );
}
