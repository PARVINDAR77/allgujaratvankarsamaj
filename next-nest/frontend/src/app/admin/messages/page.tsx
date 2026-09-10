"use client";

import React from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";

const mockMessages = [
  { id: "msg-1", from: "Ramesh Vankar", to: "Hiralben Parmar", preview: "Jai Shree Krishna! Excited to talk...", time: "10 mins ago", flag: "CLEAN" },
  { id: "msg-2", from: "Hemantkumar Vankar", to: "Priyankaben Solanki", preview: "Please share father's contact number...", time: "1 hour ago", flag: "CLEAN" },
];

export default function AdminMessagesPage() {
  return (
    <AdminLayout title="Messages & Moderation" subtitle="Monitor platform communications according to community guidelines">
      <div className="bg-[#0F2040] border border-[#997D20]/30 rounded-2xl p-6 shadow-xl space-y-4">
        <h3 className="text-base font-bold text-white">Recent Communication Messages</h3>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-white">
            <thead className="bg-[#041026] text-[#D4AF37] uppercase text-[10px] tracking-wider border-b border-[#997D20]/30">
              <tr>
                <th className="py-3 px-4">From</th>
                <th className="py-3 px-4">To</th>
                <th className="py-3 px-4">Message Snippet</th>
                <th className="py-3 px-4">Time</th>
                <th className="py-3 px-4 text-right">Moderation</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#997D20]/10">
              {mockMessages.map((m) => (
                <tr key={m.id} className="hover:bg-[#041026]/50">
                  <td className="py-3.5 px-4 font-bold text-white">{m.from}</td>
                  <td className="py-3.5 px-4 text-[#D4AF37] font-semibold">{m.to}</td>
                  <td className="py-3.5 px-4 text-[#AAB7C8]">{m.preview}</td>
                  <td className="py-3.5 px-4 text-gray-400">{m.time}</td>
                  <td className="py-3.5 px-4 text-right">
                    <span className="px-2 py-0.5 rounded bg-emerald-950 text-emerald-400 border border-emerald-500/40 text-[10px] font-bold">
                      {m.flag}
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
