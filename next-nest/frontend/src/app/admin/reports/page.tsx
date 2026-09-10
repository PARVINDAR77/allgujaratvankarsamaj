"use client";

import React from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";

export default function AdminReportsPage() {
  return (
    <AdminLayout title="Reports & Analytics" subtitle="Comprehensive platform statistics & growth metrics">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-[#0F2040] border border-[#997D20]/30 rounded-2xl p-6 shadow-xl space-y-3">
          <h4 className="text-xs font-bold text-[#AAB7C8] uppercase">Monthly Registrations</h4>
          <p className="text-3xl font-extrabold text-[#D4AF37]">1,248</p>
          <p className="text-xs text-emerald-400">↑ 12% vs last month</p>
        </div>
        <div className="bg-[#0F2040] border border-[#997D20]/30 rounded-2xl p-6 shadow-xl space-y-3">
          <h4 className="text-xs font-bold text-[#AAB7C8] uppercase">Profile Verifications</h4>
          <p className="text-3xl font-extrabold text-[#D4AF37]">856</p>
          <p className="text-xs text-emerald-400">↑ 8% vs last month</p>
        </div>
        <div className="bg-[#0F2040] border border-[#997D20]/30 rounded-2xl p-6 shadow-xl space-y-3">
          <h4 className="text-xs font-bold text-[#AAB7C8] uppercase">Successful Marriages</h4>
          <p className="text-3xl font-extrabold text-[#D4AF37]">342</p>
          <p className="text-xs text-emerald-400">↑ 15% vs last month</p>
        </div>
      </div>
    </AdminLayout>
  );
}
