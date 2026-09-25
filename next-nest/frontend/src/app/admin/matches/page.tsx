"use client";

import React, { useEffect, useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { StatusBadge } from "@/components/admin/StatusBadge";
import { adminApi } from "@/lib/admin-api";

export default function AdminMatchesPage() {
  const [matches, setMatches] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    adminApi.getMatches()
      .then((data) => {
        // Backend returns an array or an object with data property
        setMatches(Array.isArray(data) ? data : (data as any).items || []);
        setError(null);
      })
      .catch((err) => {
        console.error("Matches fetch error:", err);
        setError(err.message || "Failed to load matches");
      })
      .finally(() => setLoading(false));
  }, []);

  return (
    <AdminLayout title="Matchmaking Management" subtitle="Monitor mutual interests, shortlists & match connectivity">
      <div className="bg-admin-border border border-admin-gold-dark/30 rounded-2xl p-6 shadow-xl space-y-4">
        <h3 className="text-base font-bold text-white">Active Matrimonial Matches</h3>
        
        {error && (
          <div className="rounded-xl bg-red-500/10 text-red-300 border border-red-600 p-4">
            {error}
          </div>
        )}

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-white">
            <thead className="bg-admin-card text-admin-gold uppercase text-[10px] tracking-wider border-b border-admin-gold-dark/30">
              <tr>
                <th className="py-3 px-4">Candidate A</th>
                <th className="py-3 px-4">Candidate B</th>
                <th className="py-3 px-4">Compatibility</th>
                <th className="py-3 px-4">Status</th>
                <th className="py-3 px-4">Match Date</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#997D20]/10">
              {loading ? (
                <tr>
                  <td colSpan={5} className="py-8 text-center text-admin-muted font-bold">
                    <span className="animate-spin inline-block mr-2">⚙️</span>
                    Loading matches...
                  </td>
                </tr>
              ) : matches.length === 0 ? (
                <tr>
                  <td colSpan={5} className="py-8 text-center text-admin-muted">
                    No matches found in the system.
                  </td>
                </tr>
              ) : (
                matches.map((m) => (
                  <tr key={m.id} className="hover:bg-admin-card/50 transition-colors">
                    <td className="py-3.5 px-4 font-bold text-white">
                      {m.userA?.profile?.firstName || "Unknown"} {m.userA?.profile?.lastName || ""}
                    </td>
                    <td className="py-3.5 px-4 font-bold text-white">
                      {m.userB?.profile?.firstName || "Unknown"} {m.userB?.profile?.lastName || ""}
                    </td>
                    <td className="py-3.5 px-4 font-extrabold text-admin-gold">
                      {m.matchScore ? `${m.matchScore}%` : "Pending"}
                    </td>
                    <td className="py-3.5 px-4"><StatusBadge status={m.status || "PENDING"} /></td>
                    <td className="py-3.5 px-4 text-gray-300">
                      {new Date(m.createdAt || m.date).toLocaleDateString()}
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
