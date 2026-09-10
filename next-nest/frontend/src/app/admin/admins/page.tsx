"use client";

import React from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { StatusBadge } from "@/components/admin/StatusBadge";

const mockAdmins = [
  { id: "adm-1", name: "Admin Officer", email: "admin@vankarsamaj.org", role: "SUPER_ADMIN", status: "ACTIVE" },
  { id: "adm-2", name: "Verification Lead", email: "verify@vankarsamaj.org", role: "VERIFICATION_ADMIN", status: "ACTIVE" },
  { id: "adm-3", name: "Content Moderator", email: "content@vankarsamaj.org", role: "MODERATOR", status: "ACTIVE" },
];

export default function AdminAdminsPage() {
  return (
    <AdminLayout title="Admin User Management" subtitle="Manage administrator staff & role permissions">
      <div className="bg-[#0F2040] border border-[#997D20]/30 rounded-2xl p-6 shadow-xl space-y-4">
        <div className="flex justify-between items-center">
          <h3 className="text-base font-bold text-white">Administrator Accounts</h3>
          <button className="px-4 py-2 rounded-xl bg-gradient-to-r from-[#D4AF37] to-[#E8C95A] text-black font-bold text-xs uppercase">
            + Create New Admin
          </button>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-white">
            <thead className="bg-[#041026] text-[#D4AF37] uppercase text-[10px] tracking-wider border-b border-[#997D20]/30">
              <tr>
                <th className="py-3 px-4">Name</th>
                <th className="py-3 px-4">Email</th>
                <th className="py-3 px-4">Role</th>
                <th className="py-3 px-4 text-right">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#997D20]/10">
              {mockAdmins.map((a) => (
                <tr key={a.id} className="hover:bg-[#041026]/50">
                  <td className="py-3.5 px-4 font-bold text-white">{a.name}</td>
                  <td className="py-3.5 px-4 text-[#AAB7C8]">{a.email}</td>
                  <td className="py-3.5 px-4 font-extrabold text-[#D4AF37]">{a.role}</td>
                  <td className="py-3.5 px-4 text-right"><StatusBadge status={a.status} /></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </AdminLayout>
  );
}
