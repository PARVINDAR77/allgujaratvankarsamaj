"use client";

import React from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";

export default function AdminReportsPage() {
  return (
    <AdminLayout title="Reports & Analytics" subtitle="Comprehensive platform statistics & growth metrics">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-admin-border border border-admin-gold-dark/30 rounded-2xl p-6 shadow-xl space-y-3">
          <h4 className="text-xs font-bold text-admin-muted-light uppercase">Monthly Registrations</h4>
          <p className="text-3xl font-extrabold text-admin-gold">1,248</p>
          <p className="text-xs text-emerald-400">↑ 12% vs last month</p>
        </div>
        <div className="bg-admin-border border border-admin-gold-dark/30 rounded-2xl p-6 shadow-xl space-y-3">
          <h4 className="text-xs font-bold text-admin-muted-light uppercase">Profile Verifications</h4>
          <p className="text-3xl font-extrabold text-admin-gold">856</p>
          <p className="text-xs text-emerald-400">↑ 8% vs last month</p>
        </div>
        <div className="bg-admin-border border border-admin-gold-dark/30 rounded-2xl p-6 shadow-xl space-y-3">
          <h4 className="text-xs font-bold text-admin-muted-light uppercase">Successful Marriages</h4>
          <p className="text-3xl font-extrabold text-admin-gold">342</p>
          <p className="text-xs text-emerald-400">↑ 15% vs last month</p>
        </div>
      </div>
    </AdminLayout>
  );
}
