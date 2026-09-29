"use client";

import React, { useEffect, useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { StatusBadge } from "@/components/admin/StatusBadge";
import { adminApi } from "@/lib/admin-api";

export default function AdminInterestsPage() {
  const [interests, setInterests] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    adminApi.getMatches()
      .then((data) => {
        setInterests(Array.isArray(data) ? data : (data as any).items || []);
        setError(null);
      })
      .catch((err) => {
        console.error("Interests fetch error:", err);
        setError(err.message || "Failed to load interests");
      })
      .finally(() => setLoading(false));
  }, []);

  return (
    <AdminLayout title="Express Interest Moderation" subtitle="Monitor member interest expressions and response rates">
      <div className="bg-admin-border border border-admin-gold-dark/30 rounded-2xl p-6 shadow-xl space-y-4">
        <h3 className="text-base font-bold text-white">Interest Requests Log</h3>
        
        {error && (
          <div className="rounded-xl bg-red-500/10 text-red-300 border border-red-600 p-4">
            {error}
          </div>
        )}

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-white">
            <thead className="bg-admin-card text-admin-gold uppercase text-[10px] tracking-wider border-b border-admin-gold-dark/30">
              <tr>
                <th className="py-3 px-4">Sender</th>
                <th className="py-3 px-4">Receiver</th>
                <th className="py-3 px-4">Status</th>
                <th className="py-3 px-4">Date</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#997D20]/10">
              {loading ? (
                <tr>
                  <td colSpan={4} className="py-8 text-center text-admin-muted font-bold">
                    <span className="animate-spin inline-block mr-2">⚙️</span>
                    Loading interests...
                  </td>
                </tr>
              ) : interests.length === 0 ? (
                <tr>
                  <td colSpan={4} className="py-8 text-center text-admin-muted">
                    No interests recorded.
                  </td>
                </tr>
              ) : (
                interests.map((i) => (
                  <tr key={i.id} className="hover:bg-admin-card/50 transition-colors">
                    <td className="py-3.5 px-4 font-bold text-white">
                      {i.userA?.profile?.firstName || "User A"} {i.userA?.profile?.lastName || ""}
                    </td>
                    <td className="py-3.5 px-4 text-admin-gold font-semibold">
                      {i.userB?.profile?.firstName || "User B"} {i.userB?.profile?.lastName || ""}
                    </td>
                    <td className="py-3.5 px-4"><StatusBadge status={i.status || "PENDING"} /></td>
                    <td className="py-3.5 px-4 text-gray-300">
                      {new Date(i.createdAt || i.date).toLocaleDateString()}
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
