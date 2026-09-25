"use client";

import React, { useEffect, useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { adminApi } from "@/lib/admin-api";

export default function AdminPhotosPage() {
  const [photos, setPhotos] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    adminApi.getPendingPhotos()
      .then((data) => {
        setPhotos(Array.isArray(data) ? data : (data as any).items || []);
        setError(null);
      })
      .catch((err) => {
        console.error("Photos fetch error:", err);
        setError(err.message || "Failed to load pending photos");
      })
      .finally(() => setLoading(false));
  }, []);

  const setStatus = (id: string, status: string) => {
    setPhotos((prev) => prev.filter((p) => p.id !== id));
    // Here we could call an update API to set photo status or profile status.
    // adminApi.updateProfileStatus(id, status === "APPROVED" ? "ACTIVE" : "REJECTED");
  };

  return (
    <AdminLayout title="Photos Management" subtitle="Review and moderate profile photo uploads">
      <div className="space-y-6">
        {error && (
          <div className="rounded-xl bg-red-500/10 text-red-300 border border-red-600 p-4">
            {error}
          </div>
        )}

        {loading ? (
          <div className="py-12 text-center text-admin-muted font-bold text-sm">
            <span className="animate-spin inline-block mr-2">⚙️</span>
            Loading profile photos...
          </div>
        ) : photos.length === 0 ? (
          <div className="py-12 text-center text-admin-muted bg-admin-card rounded-2xl border border-admin-gold/20 shadow-xl">
            No pending photos to moderate.
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
            {photos.map((p) => (
              <div key={p.id} className="bg-admin-border border border-admin-gold-dark/30 rounded-2xl overflow-hidden shadow-xl">
                <div className="h-48 bg-admin-card flex items-center justify-center border-b border-admin-gold-dark/20 relative">
                  {p.photoUrl ? (
                    // eslint-disable-next-line @next/next/no-img-element
                    <img src={p.photoUrl} alt="Profile" className="w-full h-full object-cover" />
                  ) : (
                    <div className="w-20 h-20 rounded-full bg-gradient-to-tr from-[#D4AF37] to-[#E8C95A] text-black font-black text-2xl flex items-center justify-center shadow-lg">
                      {(p.firstName || "U").charAt(0)}
                    </div>
                  )}
                  <span className="absolute top-3 right-3 px-2 py-0.5 rounded text-[9px] font-bold bg-amber-950 text-amber-400 border border-amber-500/40">
                    PENDING
                  </span>
                </div>
                <div className="p-4 space-y-2">
                  <h4 className="font-bold text-white text-sm">{p.firstName} {p.lastName}</h4>
                  <p className="text-[11px] text-admin-muted-light">
                    {new Date(p.createdAt).toLocaleDateString()}
                  </p>
                  <div className="flex gap-2 pt-2">
                    <button
                      onClick={() => setStatus(p.id, "APPROVED")}
                      className="flex-1 py-1.5 rounded bg-emerald-950/60 text-emerald-400 border border-emerald-500/40 text-xs font-bold hover:bg-emerald-900 cursor-pointer"
                    >
                      Approve
                    </button>
                    <button
                      onClick={() => setStatus(p.id, "REJECTED")}
                      className="flex-1 py-1.5 rounded bg-rose-950/60 text-rose-400 border border-rose-500/40 text-xs font-bold hover:bg-rose-900 cursor-pointer"
                    >
                      Reject
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </AdminLayout>
  );
}
