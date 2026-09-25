"use client";

import React, { useEffect, useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { StatusBadge } from "@/components/admin/StatusBadge";
import { adminApi, SamajServicePersonItem } from "@/lib/admin-api";

export default function AdminCommunityPage() {
  const [people, setPeople] = useState<SamajServicePersonItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    adminApi.getSamajServicePersons()
      .then((data) => {
        setPeople(Array.isArray(data) ? data : (data as any).items || []);
        setError(null);
      })
      .catch((err) => {
        console.error("Community fetch error:", err);
        setError(err.message || "Failed to load community directory");
      })
      .finally(() => setLoading(false));
  }, []);

  return (
    <AdminLayout title="Community Directory" subtitle="Directory of Samaj leaders, trustees, and verified members">
      <div className="bg-admin-border border border-admin-gold-dark/30 rounded-2xl p-6 shadow-xl space-y-4">
        <h3 className="text-base font-bold text-white">Samaj Directory Members</h3>
        
        {error && (
          <div className="rounded-xl bg-red-500/10 text-red-300 border border-red-600 p-4">
            {error}
          </div>
        )}

        <div className="overflow-x-auto">
          <table className="w-full text-left text-xs text-white">
            <thead className="bg-admin-card text-admin-gold uppercase text-[10px] tracking-wider border-b border-admin-gold-dark/30">
              <tr>
                <th className="py-3 px-4">Member Name</th>
                <th className="py-3 px-4">Role / Position</th>
                <th className="py-3 px-4">Service Category</th>
                <th className="py-3 px-4">City</th>
                <th className="py-3 px-4 text-right">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-[#997D20]/10">
              {loading ? (
                <tr>
                  <td colSpan={5} className="py-8 text-center text-admin-muted font-bold">
                    <span className="animate-spin inline-block mr-2">⚙️</span>
                    Loading community directory...
                  </td>
                </tr>
              ) : people.length === 0 ? (
                <tr>
                  <td colSpan={5} className="py-8 text-center text-admin-muted">
                    No community leaders found in the directory.
                  </td>
                </tr>
              ) : (
                people.map((c) => (
                  <tr key={c.id} className="hover:bg-admin-card/50 transition-colors">
                    <td className="py-3.5 px-4 font-bold text-white">{c.name} {c.gujaratiName ? `(${c.gujaratiName})` : ''}</td>
                    <td className="py-3.5 px-4 text-admin-gold font-semibold">{c.description || "Directory Member"}</td>
                    <td className="py-3.5 px-4 text-white">{c.service?.title || "Community"}</td>
                    <td className="py-3.5 px-4 text-admin-muted-light">{c.city || "Gujarat"}</td>
                    <td className="py-3.5 px-4 text-right">
                      <StatusBadge status={c.isActive ? "ACTIVE" : "INACTIVE"} />
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
