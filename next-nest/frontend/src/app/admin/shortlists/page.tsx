"use client";

import React, { useEffect, useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { adminApi } from "@/lib/admin-api";

export default function AdminShortlistsPage() {
  const [shortlists, setShortlists] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    adminApi.getShortlists()
      .then((data) => {
        setShortlists(Array.isArray(data) ? data : (data as any).items || []);
        setError(null);
      })
      .catch((err) => {
        console.error("Shortlists fetch error:", err);
        setError(err.message || "Failed to load shortlists");
      })
      .finally(() => setLoading(false));
  }, []);

  return (
    <AdminLayout title="Shortlist Activity" subtitle="View candidate shortlisting trends across Samaj regions">
      <div className="bg-admin-border border border-admin-gold-dark/30 rounded-2xl p-6 shadow-xl space-y-4">
        <h3 className="text-base font-bold text-white">Recent Profile Shortlists</h3>
        
        {error && (
          <div className="rounded-xl bg-red-500/10 text-red-300 border border-red-600 p-4">
            {error}
          </div>
        )}

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-white">
            <thead className="bg-admin-card text-admin-gold uppercase text-[10px] tracking-wider border-b border-admin-gold-dark/30">
              <tr>
                <th className="py-3 px-4">User</th>
                <th className="py-3 px-4">Shortlisted Profile</th>
                <th className="py-3 px-4">Pargana</th>
                <th className="py-3 px-4">Date</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#997D20]/10">
              {loading ? (
                <tr>
                  <td colSpan={4} className="py-8 text-center text-admin-muted font-bold">
                    <span className="animate-spin inline-block mr-2">⚙️</span>
                    Loading shortlists...
                  </td>
                </tr>
              ) : shortlists.length === 0 ? (
                <tr>
                  <td colSpan={4} className="py-8 text-center text-admin-muted">
                    No shortlists found.
                  </td>
                </tr>
              ) : (
                shortlists.map((s) => (
                  <tr key={s.id} className="hover:bg-admin-card/50 transition-colors">
                    <td className="py-3.5 px-4 font-bold text-white">
                      {s.user?.profile?.firstName || s.user?.email || "Unknown User"} {s.user?.profile?.lastName || ""}
                    </td>
                    <td className="py-3.5 px-4 text-admin-gold font-semibold">
                      {s.profile?.firstName || "Unknown"} {s.profile?.lastName || ""}
                    </td>
                    <td className="py-3.5 px-4 text-admin-muted-light">{s.profile?.city || "Unknown Pargana"}</td>
                    <td className="py-3.5 px-4 text-gray-300">
                      {new Date(s.createdAt || s.date || new Date()).toLocaleDateString()}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </AdminLayout>
  );
}
