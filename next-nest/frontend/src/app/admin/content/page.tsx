"use client";

import React from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";

export default function AdminContentPage() {
  const pagesList = [
    { name: "Terms & Conditions", icon: "📄" },
    { name: "Privacy Policy", icon: "🔒" },
    { name: "Samaj Rules & Guidelines", icon: "⚖️" },
    { name: "Frequently Asked Questions (FAQs)", icon: "❓" },
    { name: "About Vankar Samaj Matrimony", icon: "ℹ️" },
  ];

  return (
    <AdminLayout title="Pages & CMS Content" subtitle="Manage static pages, FAQs, Terms, and Samaj Announcements">
      <div style={{ display: "flex", flexDirection: "column", gap: "28px" }}>
        
        {/* Header Intro */}
        <div style={{
          padding: "20px 24px",
          background: "linear-gradient(135deg, rgba(212, 175, 55, 0.15) 0%, rgba(4, 16, 38, 0.8) 100%)",
          borderRadius: "16px",
          borderLeft: "4px solid #D4AF37",
          border: "1px solid rgba(212, 175, 55, 0.2)",
          display: "flex",
          alignItems: "center",
          gap: "16px",
          boxShadow: "0 8px 32px rgba(0, 0, 0, 0.3)"
        }}>
          <div style={{ fontSize: "32px", filter: "drop-shadow(0 0 10px rgba(212, 175, 55, 0.6))" }}>✨</div>
          <div>
            <h2 style={{ fontSize: "18px", fontWeight: 800, color: "#FFFFFF", marginBottom: "4px" }}>Content Management System</h2>
            <p style={{ fontSize: "13px", color: "#8E9BAE", fontWeight: 500, lineHeight: 1.5 }}>
              Use these tools to keep the community portal up-to-date. Changes to public pages and announcements will reflect instantly on the user-facing website.
            </p>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          
          {/* Left Column: Public Pages */}
          <div style={{
            backgroundColor: "rgba(13, 27, 50, 0.85)",
            backdropFilter: "blur(16px)",
            border: "1px solid rgba(212, 175, 55, 0.25)",
            borderRadius: "20px",
            padding: "28px",
            boxShadow: "0 15px 40px rgba(0, 0, 0, 0.4)",
            display: "flex",
            flexDirection: "column"
          }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "24px" }}>
              <h3 style={{ fontSize: "18px", fontWeight: 800, color: "#FFFFFF", display: "flex", alignItems: "center", gap: "10px", margin: 0 }}>
                <span>🌐</span> Public Application Pages
              </h3>
            </div>
            
            <div style={{ display: "flex", flexDirection: "column", gap: "12px", flex: 1 }}>
              {pagesList.map((p, idx) => (
                <div 
                  key={idx} 
                  className="group"
                  style={{ 
                    display: "flex", 
                    justifyContent: "space-between", 
                    alignItems: "center", 
                    padding: "16px 20px", 
                    borderRadius: "14px", 
                    backgroundColor: "rgba(4, 16, 38, 0.6)", 
                    border: "1px solid rgba(212, 175, 55, 0.15)",
                    transition: "all 0.3s ease",
                  }}
                >
                  <div style={{ display: "flex", alignItems: "center", gap: "12px" }}>
                    <span style={{ fontSize: "18px", opacity: 0.8 }} className="group-hover:opacity-100 group-hover:scale-110 transition-all">{p.icon}</span>
                    <span style={{ fontWeight: 600, color: "#E2E8F0", fontSize: "14px" }} className="group-hover:text-white transition-colors">{p.name}</span>
                  </div>
                  <button 
                    style={{
                      padding: "8px 16px",
                      borderRadius: "8px",
                      backgroundColor: "rgba(212, 175, 55, 0.1)",
                      border: "1px solid rgba(212, 175, 55, 0.4)",
                      color: "#D4AF37",
                      fontWeight: 700,
                      fontSize: "12px",
                      cursor: "pointer",
                      transition: "all 0.3s ease",
                    }}
                    className="hover:bg-[#D4AF37] hover:text-black hover:shadow-[0_0_15px_rgba(212,175,55,0.4)]"
                  >
                    Edit Page
                  </button>
                </div>
              ))}
            </div>
          </div>

          {/* Right Column: Announcements */}
          <div style={{
            backgroundColor: "rgba(13, 27, 50, 0.85)",
            backdropFilter: "blur(16px)",
            border: "1px solid rgba(212, 175, 55, 0.25)",
            borderRadius: "20px",
            padding: "28px",
            boxShadow: "0 15px 40px rgba(0, 0, 0, 0.4)",
            display: "flex",
            flexDirection: "column"
          }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "24px" }}>
              <h3 style={{ fontSize: "18px", fontWeight: 800, color: "#FFFFFF", display: "flex", alignItems: "center", gap: "10px", margin: 0 }}>
                <span>📢</span> Homepage Announcements
              </h3>
              <span style={{ fontSize: "12px", color: "#8E9BAE", fontWeight: 600, backgroundColor: "rgba(255,255,255,0.05)", padding: "4px 10px", borderRadius: "20px" }}>
                1 Active
              </span>
            </div>
            
            <div style={{ display: "flex", flexDirection: "column", gap: "16px", flex: 1 }}>
              
              {/* Announcement Card */}
              <div 
                className="group relative overflow-hidden"
                style={{
                  padding: "20px",
                  borderRadius: "16px",
                  backgroundColor: "rgba(4, 16, 38, 0.8)",
                  border: "1px solid rgba(212, 175, 55, 0.3)",
                  transition: "all 0.3s ease",
                }}
              >
                <div style={{ position: "absolute", top: 0, left: 0, width: "4px", height: "100%", background: "#D4AF37", boxShadow: "0 0 10px #D4AF37" }}></div>
                
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: "8px", paddingLeft: "10px" }}>
                  <h4 style={{ fontWeight: 800, color: "#F3E5AB", fontSize: "15px", lineHeight: 1.3 }}>
                    Upcoming Vankar Samaj Matrimonial Sammelan 2026
                  </h4>
                  <div style={{ display: "flex", gap: "6px" }}>
                    <button style={{ background: "none", border: "none", color: "#8E9BAE", cursor: "pointer" }} className="hover:text-white">✏️</button>
                    <button style={{ background: "none", border: "none", color: "#8E9BAE", cursor: "pointer" }} className="hover:text-rose-400">🗑️</button>
                  </div>
                </div>
                <p style={{ color: "#CBD5E1", fontSize: "13px", lineHeight: 1.5, marginBottom: "16px", paddingLeft: "10px" }}>
                  Annual youth introduction fair scheduled in Ahmedabad next month. All verified members are encouraged to participate.
                </p>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", paddingLeft: "10px" }}>
                  <span style={{ fontSize: "11px", color: "#64748B", fontWeight: 600 }}>Published: 2 days ago</span>
                  <span style={{ fontSize: "10px", fontWeight: 800, color: "#10B981", backgroundColor: "rgba(16, 185, 129, 0.1)", padding: "4px 8px", borderRadius: "6px", border: "1px solid rgba(16, 185, 129, 0.2)" }}>
                    LIVE
                  </span>
                </div>
              </div>

              {/* Add New Button */}
              <button 
                style={{
                  marginTop: "auto",
                  width: "100%",
                  padding: "16px",
                  borderRadius: "14px",
                  background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
                  color: "#041026",
                  fontWeight: 900,
                  fontSize: "14px",
                  textTransform: "uppercase",
                  letterSpacing: "1px",
                  border: "none",
                  cursor: "pointer",
                  boxShadow: "0 10px 25px rgba(212, 175, 55, 0.3)",
                  display: "flex",
                  justifyContent: "center",
                  alignItems: "center",
                  gap: "10px",
                  transition: "all 0.3s ease",
                }}
                className="hover:scale-[1.02] hover:shadow-[0_15px_35px_rgba(212,175,55,0.5)] active:scale-95"
              >
                <span style={{ fontSize: "18px" }}>⊕</span>
                Create New Announcement
              </button>
            </div>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
