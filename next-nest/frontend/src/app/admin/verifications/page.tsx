"use client";

import React, { useState, useEffect } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { StatusBadge } from "@/components/admin/StatusBadge";
import { adminApi } from "@/lib/admin-api";

export default function AdminVerificationsPage() {
  const [items, setItems] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState("ALL");
  const [search, setSearch] = useState("");

  const fetchVerifications = async () => {
    try {
      setLoading(true);
      const data = await adminApi.getVerifications();
      setItems(Array.isArray(data) ? data : (data as any).data || []);
      setError(null);
    } catch (err: any) {
      console.error(err);
      setError(err.message || "Failed to fetch verifications");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchVerifications();
  }, []);

  const updateStatus = async (id: string, action: string) => {
    let reason;
    if (action === "REJECTED") {
      reason = window.prompt("Please enter a rejection reason:");
      if (reason === null) return; // User cancelled
    }
    
    try {
      await adminApi.updateVerificationStatus(id, action, reason);
      await fetchVerifications();
    } catch (err: any) {
      alert("Failed to update status: " + (err.message || "Unknown error"));
    }
  };

  const filteredItems = items.filter((item) => {
    const matchesSearch = item.profile?.name?.toLowerCase().includes(search.toLowerCase()) || item.documentType?.toLowerCase().includes(search.toLowerCase());
    const matchesFilter = filter === "ALL" || item.status === filter;
    return matchesSearch && matchesFilter;
  });

  return (
    <AdminLayout title="Verification Management" subtitle="Approve or reject submitted community profile proofs">
      <div  className="flex flex-col gap-6">
        {/* Search & Status Filter Bar */}
        <div
            className="flex justify-between items-center flex-wrap border border-admin-gold/25 gap-4 rounded-2xl shadow-[0_10px_30px_rgba(0,0,0,0.4)] backdrop-blur-md bg-admin-bg-glass py-[18px] px-6" 
        >
          <div  style={{ minWidth: "300px" }} className="relative">
            <input
              type="text"
              placeholder="Search member or document type..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              style={{
                width: "100%",
                backgroundColor: "#041026",
                border: "1px solid rgba(212, 175, 55, 0.35)",
                borderRadius: "12px",
                padding: "10px 14px 10px 38px",
                fontSize: "12px",
                color: "#FFFFFF",
                outline: "none",
              }}
            />
            <span   className="absolute text-admin-muted text-[13px] left-3 top-[11px]" >🔍</span>
          </div>

          <div  className="flex gap-2">
            {["ALL", "PENDING", "VERIFIED", "REJECTED"].map((tab) => (
              <button
                key={tab}
                onClick={() => setFilter(tab)}
                style={{
                  padding: "8px 16px",
                  borderRadius: "12px",
                  fontSize: "12px",
                  fontWeight: 800,
                  border: "none",
                  cursor: "pointer",
                  backgroundColor: filter === tab ? "#D4AF37" : "#041026",
                  color: filter === tab ? "#041026" : "#8E9BAE",
                  boxShadow: filter === tab ? "0 4px 12px rgba(212, 175, 55, 0.3)" : "none",
                }}
                className="transition-all"
              >
                {tab}
              </button>
            ))}
          </div>
        </div>

        {/* Verification Submissions Table */}
        <div
            className="border border-admin-gold/25 p-6 rounded-2xl shadow-[0_10px_30px_rgba(0,0,0,0.4)] backdrop-blur-md bg-admin-bg-glass" 
        >
          <div  style={{ marginBottom: "20px" }} className="flex justify-between items-center">
            <h3  style={{ margin: 0 }} className="flex items-center font-extrabold text-white text-base gap-2">
              <span>🛡️</span> Verification Review Requests
            </h3>
            <span
                style={{ borderRadius: "20px" }} className="font-extrabold bg-admin-card text-admin-gold border border-admin-gold/30 text-[11px] py-1.5 px-3.5" 
            >
              Pending Queue: {items.filter(i => i.status === "PENDING").length}
            </span>
          </div>

          <div  className="overflow-hidden border border-admin-gold/20 rounded-xl">
            <table  className="w-full text-left border-collapse text-white text-xs">
              <thead>
                <tr  className="bg-admin-card border-b border-admin-gold/30">
                  <th   className="font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[18px] tracking-[1px]" >Member Name</th>
                  <th   className="font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[18px] tracking-[1px]" >Verification Type</th>
                  <th   className="font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[18px] tracking-[1px]" >Pargana</th>
                  <th   className="font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[18px] tracking-[1px]" >Submitted Date</th>
                  <th   className="font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[18px] tracking-[1px]" >Status</th>
                  <th   className="text-right font-extrabold uppercase text-admin-gold text-[10px] py-[14px] px-[18px] tracking-[1px]" >Actions</th>
                </tr>
              </thead>
              <tbody  className="bg-admin-card">
                {filteredItems.map((item) => (
                  <tr key={item.id}  className="hover:bg-admin-card/70 transition-colors border-b border-admin-gold/10">
                    <td  className="font-bold text-white py-[14px] px-[18px]">{item.profile?.name || "Unknown"}</td>
                    <td  className="font-medium text-admin-muted py-[14px] px-[18px]">{item.documentType || "Unknown"}</td>
                    <td  className="font-semibold text-white py-[14px] px-[18px]">{item.profile?.pargana?.name || "N/A"}</td>
                    <td   className="text-admin-muted-lighter text-[11px] py-[14px] px-[18px] font-mono" >{new Date(item.createdAt).toLocaleDateString()}</td>
                    <td  className="py-[14px] px-[18px]">
                      <StatusBadge status={item.status} />
                    </td>
                    <td  className="text-right py-[14px] px-[18px]">
                      <div  className="flex justify-end gap-2">
                        <button
                          onClick={() => updateStatus(item.id, "VERIFIED")}
                          style={{
                            padding: "6px 14px",
                            borderRadius: "8px",
                            backgroundColor: "rgba(6, 78, 59, 0.6)",
                            color: "#6EE7B7",
                            border: "1px solid rgba(16, 185, 129, 0.4)",
                            fontSize: "11px",
                            fontWeight: 800,
                            cursor: "pointer",
                          }}
                          className="hover:bg-emerald-800 transition-colors"
                        >
                          Approve
                        </button>
                        <button
                          onClick={() => updateStatus(item.id, "REJECTED")}
                          style={{
                            padding: "6px 14px",
                            borderRadius: "8px",
                            backgroundColor: "rgba(136, 19, 55, 0.6)",
                            color: "#FDA4AF",
                            border: "1px solid rgba(244, 63, 94, 0.4)",
                            fontSize: "11px",
                            fontWeight: 800,
                            cursor: "pointer",
                          }}
                          className="hover:bg-rose-800 transition-colors"
                        >
                          Reject
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}


