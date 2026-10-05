"use client";

import React, { useEffect, useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { adminApi } from "@/lib/admin-api";

export default function AdminNotificationsPage() {
  const [title, setTitle] = useState("");
  const [message, setMessage] = useState("");
  const [audience, setAudience] = useState("ALL");
  const [route, setRoute] = useState("/search");
  const [notifications, setNotifications] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [statusMsg, setStatusMsg] = useState<{ type: "success" | "error"; text: string } | null>(null);

  const loadNotifications = async () => {
    try {
      setLoading(true);
      const data = await adminApi.getNotifications();
      setNotifications(Array.isArray(data) ? data : []);
    } catch (e: any) {
      console.error("Failed to load notifications:", e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadNotifications();
  }, []);

  const handleSend = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim() || !message.trim()) return;

    try {
      setSubmitting(true);
      setStatusMsg(null);
      await adminApi.createNotification({
        title: title.trim(),
        message: message.trim(),
        target: audience,
        route: route.trim() || undefined,
      });

      setStatusMsg({ type: "success", text: "Broadcast notification dispatched and synchronized successfully!" });
      setTitle("");
      setMessage("");
      loadNotifications();
      setTimeout(() => setStatusMsg(null), 4000);
    } catch (err: any) {
      setStatusMsg({ type: "error", text: err.message || "Failed to send broadcast notification" });
    } finally {
      setSubmitting(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (confirm("Are you sure you want to delete this broadcast notification?")) {
      try {
        await adminApi.deleteNotification(id);
        loadNotifications();
      } catch (err: any) {
        alert("Failed to delete notification: " + err.message);
      }
    }
  };

  return (
    <AdminLayout title="Notification Manager" subtitle="Broadcast real-time mobile & push notifications to community members">
      <div style={{ display: "flex", flexDirection: "column", gap: "28px", maxWidth: "900px" }}>
        
        {/* Creation Form */}
        <div style={{
          backgroundColor: "rgba(13, 27, 50, 0.85)",
          backdropFilter: "blur(16px)",
          border: "1px solid rgba(212, 175, 55, 0.25)",
          borderRadius: "20px",
          padding: "28px",
          boxShadow: "0 15px 40px rgba(0, 0, 0, 0.4)",
        }}>
          <h3 style={{ fontSize: "18px", fontWeight: 800, color: "#FFFFFF", marginBottom: "20px", display: "flex", alignItems: "center", gap: "10px" }}>
            <span>📢</span> Create Broadcast Notification
          </h3>

          {statusMsg && (
            <div style={{
              padding: "12px 18px",
              borderRadius: "12px",
              marginBottom: "20px",
              fontSize: "13px",
              fontWeight: 700,
              backgroundColor: statusMsg.type === "success" ? "rgba(6, 78, 59, 0.8)" : "rgba(136, 19, 55, 0.8)",
              border: `1px solid ${statusMsg.type === "success" ? "rgba(16, 185, 129, 0.5)" : "rgba(244, 63, 94, 0.5)"}`,
              color: statusMsg.type === "success" ? "#6EE7B7" : "#FDA4AF",
            }}>
              {statusMsg.type === "success" ? "✓ " : "✕ "} {statusMsg.text}
            </div>
          )}

          <form onSubmit={handleSend} style={{ display: "flex", flexDirection: "column", gap: "16px" }}>
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "16px" }}>
              <div>
                <label style={{ display: "block", color: "#8E9BAE", marginBottom: "6px", fontSize: "12px", fontWeight: 700, textTransform: "uppercase" }}>Target Audience</label>
                <select
                  value={audience}
                  onChange={(e) => setAudience(e.target.value)}
                  style={{ width: "100%", padding: "10px", borderRadius: "8px", border: "1px solid rgba(212,175,55,0.3)", backgroundColor: "#041026", color: "#FFF", fontSize: "13px" }}
                >
                  <option value="ALL">All Registered Members</option>
                  <option value="35">35 Gam Pargana Members</option>
                  <option value="27">27 Gam Pargana Members</option>
                  <option value="16">16 Gam Pargana Members</option>
                  <option value="14">14 Gam Pargana Members</option>
                  <option value="VERIFIED">Verified Profiles Only</option>
                </select>
              </div>

              <div>
                <label style={{ display: "block", color: "#8E9BAE", marginBottom: "6px", fontSize: "12px", fontWeight: 700, textTransform: "uppercase" }}>App Screen Link (Route)</label>
                <select
                  value={route}
                  onChange={(e) => setRoute(e.target.value)}
                  style={{ width: "100%", padding: "10px", borderRadius: "8px", border: "1px solid rgba(212,175,55,0.3)", backgroundColor: "#041026", color: "#FFF", fontSize: "13px" }}
                >
                  <option value="/search">Candidate Search Screen</option>
                  <option value="/samaj-ratna">Samaj Ratna Section</option>
                  <option value="/advertisement">Advertisements & Offers</option>
                  <option value="/statistics">Community Statistics</option>
                  <option value="/birthdays">Birthdays & Anniversaries</option>
                  <option value="/services">Samaj Services</option>
                </select>
              </div>
            </div>

            <div>
              <label style={{ display: "block", color: "#8E9BAE", marginBottom: "6px", fontSize: "12px", fontWeight: 700, textTransform: "uppercase" }}>Notification Title *</label>
              <input
                type="text"
                required
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="e.g. નવી પ્રોફાઇલ્સ ઉપલબ્ધ છે / New Profiles Added"
                style={{ width: "100%", padding: "10px", borderRadius: "8px", border: "1px solid rgba(212,175,55,0.3)", backgroundColor: "#041026", color: "#FFF", fontSize: "13px" }}
              />
            </div>

            <div>
              <label style={{ display: "block", color: "#8E9BAE", marginBottom: "6px", fontSize: "12px", fontWeight: 700, textTransform: "uppercase" }}>Message Body *</label>
              <textarea
                rows={3}
                required
                value={message}
                onChange={(e) => setMessage(e.target.value)}
                placeholder="Enter detailed message text..."
                style={{ width: "100%", padding: "10px", borderRadius: "8px", border: "1px solid rgba(212,175,55,0.3)", backgroundColor: "#041026", color: "#FFF", fontSize: "13px" }}
              />
            </div>

            <button
              type="submit"
              disabled={submitting}
              style={{
                padding: "14px 24px",
                borderRadius: "12px",
                background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
                color: "#041026",
                fontWeight: 900,
                fontSize: "13px",
                textTransform: "uppercase",
                letterSpacing: "1px",
                border: "none",
                cursor: submitting ? "not-allowed" : "pointer",
                boxShadow: "0 4px 14px rgba(212, 175, 55, 0.4)",
                transition: "all 0.3s",
                opacity: submitting ? 0.7 : 1,
              }}
            >
              {submitting ? "Broadcasting..." : "📢 Send Real Broadcast Notification"}
            </button>
          </form>
        </div>

        {/* Existing Notifications History */}
        <div style={{
          backgroundColor: "rgba(13, 27, 50, 0.85)",
          backdropFilter: "blur(16px)",
          border: "1px solid rgba(212, 175, 55, 0.25)",
          borderRadius: "20px",
          padding: "28px",
          boxShadow: "0 15px 40px rgba(0, 0, 0, 0.4)",
        }}>
          <h3 style={{ fontSize: "18px", fontWeight: 800, color: "#FFFFFF", marginBottom: "16px", display: "flex", alignItems: "center", gap: "10px" }}>
            <span>📜</span> Broadcast History ({notifications.length})
          </h3>

          {loading ? (
            <div style={{ padding: "40px", textAlign: "center", color: "#8E9BAE" }}>Loading notifications...</div>
          ) : notifications.length === 0 ? (
            <div style={{ padding: "30px", textAlign: "center", color: "#8E9BAE" }}>
              No broadcast notifications sent yet. Create one above to notify community members.
            </div>
          ) : (
            <div style={{ overflowX: "auto" }}>
              <table style={{ width: "100%", borderCollapse: "collapse", color: "#FFF", fontSize: "13px" }}>
                <thead>
                  <tr style={{ borderBottom: "1px solid rgba(212,175,55,0.3)", textAlign: "left", color: "#D4AF37", fontSize: "11px", textTransform: "uppercase", letterSpacing: "1px" }}>
                    <th style={{ padding: "12px 14px" }}>Title & Message</th>
                    <th style={{ padding: "12px 14px" }}>Audience</th>
                    <th style={{ padding: "12px 14px" }}>Route</th>
                    <th style={{ padding: "12px 14px" }}>Date</th>
                    <th style={{ padding: "12px 14px", textAlign: "right" }}>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {notifications.map((n) => (
                    <tr key={n.id} style={{ borderBottom: "1px solid rgba(255,255,255,0.05)" }}>
                      <td style={{ padding: "12px 14px" }}>
                        <div style={{ fontWeight: 700, color: "#FFFFFF" }}>{n.title}</div>
                        <div style={{ color: "#8E9BAE", fontSize: "12px", marginTop: "2px" }}>{n.message}</div>
                      </td>
                      <td style={{ padding: "12px 14px" }}>
                        <span style={{ padding: "3px 8px", borderRadius: "12px", backgroundColor: "rgba(212,175,55,0.15)", color: "#F3E5AB", fontSize: "11px", fontWeight: 700 }}>
                          {n.target}
                        </span>
                      </td>
                      <td style={{ padding: "12px 14px", color: "#8E9BAE", fontSize: "12px" }}>{n.route || "Default"}</td>
                      <td style={{ padding: "12px 14px", color: "#8E9BAE", fontSize: "11px", whiteSpace: "nowrap" }}>
                        {new Date(n.createdAt).toLocaleDateString()}
                      </td>
                      <td style={{ padding: "12px 14px", textAlign: "right" }}>
                        <button
                          onClick={() => handleDelete(n.id)}
                          style={{
                            backgroundColor: "rgba(244, 63, 94, 0.15)",
                            color: "#FDA4AF",
                            border: "1px solid rgba(244, 63, 94, 0.3)",
                            borderRadius: "8px",
                            padding: "6px 12px",
                            cursor: "pointer",
                            fontSize: "11px",
                            fontWeight: 700,
                          }}
                        >
                          Delete
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </AdminLayout>
  );
}
