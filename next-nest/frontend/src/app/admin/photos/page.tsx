"use client";

import React, { useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";

const mockPhotos = [
  { id: "ph-1", uploader: "Vikram Vankar", pargana: "35 Pargana", uploadedAt: "10 mins ago", status: "PENDING" },
  { id: "ph-2", uploader: "Aarti Vankar", pargana: "27 Pargana", uploadedAt: "45 mins ago", status: "PENDING" },
  { id: "ph-3", uploader: "Hemantkumar Vankar", pargana: "16 Pargana", uploadedAt: "2 hours ago", status: "APPROVED" },
  { id: "ph-4", uploader: "Hiralben Parmar", pargana: "27 Pargana", uploadedAt: "5 hours ago", status: "APPROVED" },
];

export default function AdminPhotosPage() {
  const [photos, setPhotos] = useState(mockPhotos);

  const setStatus = (id: string, status: string) => {
    setPhotos((prev) => prev.map((p) => (p.id === id ? { ...p, status } : p)));
  };

  return (
    <AdminLayout title="Photos Management" subtitle="Review and moderate profile photo uploads">
      <div className="space-y-6">
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
          {photos.map((p) => (
            <div key={p.id} className="bg-[#0F2040] border border-[#997D20]/30 rounded-2xl overflow-hidden shadow-xl">
              <div className="h-48 bg-[#041026] flex items-center justify-center border-b border-[#997D20]/20 relative">
                <div className="w-20 h-20 rounded-full bg-gradient-to-tr from-[#D4AF37] to-[#E8C95A] text-black font-black text-2xl flex items-center justify-center shadow-lg">
                  {p.uploader.charAt(0)}
                </div>
                <span className={`absolute top-3 right-3 px-2 py-0.5 rounded text-[9px] font-bold ${
                  p.status === "APPROVED" ? "bg-emerald-950 text-emerald-400 border border-emerald-500/40" : "bg-amber-950 text-amber-400 border border-amber-500/40"
                }`}>
                  {p.status}
                </span>
              </div>
              <div className="p-4 space-y-2">
                <h4 className="font-bold text-white text-sm">{p.uploader}</h4>
                <p className="text-[11px] text-[#AAB7C8]">{p.pargana} • {p.uploadedAt}</p>
                <div className="flex gap-2 pt-2">
                  <button
                    onClick={() => setStatus(p.id, "APPROVED")}
                    className="flex-1 py-1.5 rounded bg-emerald-950/60 text-emerald-400 border border-emerald-500/40 text-xs font-bold hover:bg-emerald-900"
                  >
                    Approve
                  </button>
                  <button
                    onClick={() => setStatus(p.id, "REJECTED")}
                    className="flex-1 py-1.5 rounded bg-rose-950/60 text-rose-400 border border-rose-500/40 text-xs font-bold hover:bg-rose-900"
                  >
                    Reject
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </AdminLayout>
  );
}
