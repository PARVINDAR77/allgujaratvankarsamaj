"use client";

import React, { useEffect, useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { adminApi } from "@/lib/admin-api";

export default function AdminSettingsPage() {
  const [activeTab, setActiveTab] = useState<"general" | "verification" | "privacy">("general");
  const [saved, setSaved] = useState(false);
  const [loading, setLoading] = useState(true);

  // Settings State
  const [platformName, setPlatformName] = useState("All Gujarat Vankar Samaj Matrimony");
  const [bannerText, setBannerText] = useState("Welcome to All Gujarat Vankar Samaj Matrimony — Find Your Ideal Life Partner Within Our Community");
  const [supportEmail, setSupportEmail] = useState("support@vankarsamaj.org");
  const [supportPhone, setSupportPhone] = useState("+91 98765 43210");
  const [requireVerification, setRequireVerification] = useState(true);
  const [autoApprovePhotos, setAutoApprovePhotos] = useState(false);
  const [privacyContactMasking, setPrivacyContactMasking] = useState(true);
  const [allowPublicSearch, setAllowPublicSearch] = useState(false);

  useEffect(() => {
    async function loadSettings() {
      try {
        const settings = await adminApi.getSettings();
        if (settings) {
          if (settings.siteTitle) setPlatformName(settings.siteTitle);
          if (settings.bannerText) setBannerText(settings.bannerText);
          if (settings.contactEmail) setSupportEmail(settings.contactEmail);
          if (settings.contactPhone) setSupportPhone(settings.contactPhone);
        }
      } catch (e) {
        console.error("Failed to load settings from API", e);
      } finally {
        setLoading(false);
      }
    }
    loadSettings();
  }, []);

  const handleSave = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await adminApi.updateSettings({
        siteTitle: platformName,
        bannerText: bannerText,
        contactEmail: supportEmail,
        contactPhone: supportPhone,
        registrationEnabled: true,
        maintenanceMode: false,
      });
      setSaved(true);
      setTimeout(() => setSaved(false), 3500);
    } catch (err) {
      alert("Failed to save settings to NestJS API server.");
    }
  };

  const inputStyle = {
    width: "100%",
    backgroundColor: "rgba(4, 16, 38, 0.6)",
    border: "1px solid rgba(212, 175, 55, 0.3)",
    borderRadius: "12px",
    padding: "16px",
    color: "#FFFFFF",
    fontSize: "14px",
    fontWeight: 600,
    outline: "none",
    transition: "all 0.3s ease",
    boxShadow: "inset 0 2px 10px rgba(0,0,0,0.2)"
  };

  return (
    <AdminLayout
      title="Portal Settings"
      subtitle="Configure system rules, verification constraints, and access policies"
    >
      <div style={{ maxWidth: "1000px", display: "flex", flexDirection: "column", gap: "24px" }}>
        
        {/* Navigation Tabs */}
        <div style={{ display: "flex", gap: "12px", borderBottom: "1px solid rgba(212, 175, 55, 0.2)", paddingBottom: "16px" }}>
          {[
            { id: "general", label: "General Portal Settings", icon: "⚙️" },
            { id: "verification", label: "Verification Rules", icon: "🛡️" },
            { id: "privacy", label: "Privacy & Security", icon: "🔒" },
          ].map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id as any)}
              style={{
                display: "flex",
                alignItems: "center",
                gap: "8px",
                padding: "12px 24px",
                borderRadius: "12px",
                border: activeTab === tab.id ? "1px solid rgba(212, 175, 55, 0.5)" : "1px solid transparent",
                backgroundColor: activeTab === tab.id ? "rgba(212, 175, 55, 0.15)" : "transparent",
                color: activeTab === tab.id ? "#D4AF37" : "#8E9BAE",
                fontWeight: 700,
                fontSize: "14px",
                cursor: "pointer",
                transition: "all 0.3s ease",
              }}
              className="hover:bg-[#041026] hover:text-white"
            >
              <span>{tab.icon}</span>
              {tab.label}
            </button>
          ))}
        </div>

        {/* Main Settings Card */}
        <div style={{
          backgroundColor: "rgba(13, 27, 50, 0.85)",
          backdropFilter: "blur(16px)",
          border: "1px solid rgba(212, 175, 55, 0.25)",
          borderRadius: "20px",
          padding: "32px",
          boxShadow: "0 15px 40px rgba(0, 0, 0, 0.4)",
          position: "relative"
        }}>
          {saved && (
            <div style={{
              padding: "16px 24px",
              borderRadius: "14px",
              backgroundColor: "rgba(6, 78, 59, 0.8)",
              border: "1px solid rgba(16, 185, 129, 0.5)",
              color: "#6EE7B7",
              fontWeight: 800,
              display: "flex",
              alignItems: "center",
              gap: "12px",
              marginBottom: "24px",
              boxShadow: "0 8px 25px rgba(16, 185, 129, 0.2)"
            }}>
              <span style={{ fontSize: "20px" }}>✓</span>
              <span>Portal settings updated and synchronized with backend NestJS services & PostgreSQL!</span>
            </div>
          )}

          <form onSubmit={handleSave} style={{ display: "flex", flexDirection: "column", gap: "28px" }}>
            
            {/* ─── 1. GENERAL SETTINGS TAB ──────────────────────────────── */}
            {activeTab === "general" && (
              <>
                <div>
                  <label style={{ display: "block", fontSize: "12px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px", marginBottom: "8px" }}>
                    Platform Title & Branding Name
                  </label>
                  <input
                    type="text"
                    value={platformName}
                    onChange={(e) => setPlatformName(e.target.value)}
                    style={inputStyle}
                    className="focus:border-[#D4AF37] focus:shadow-[0_0_15px_rgba(212,175,55,0.2)]"
                  />
                  <p style={{ fontSize: "12px", color: "#8E9BAE", marginTop: "8px" }}>
                    Main organization name displayed across mobile app and web portal headers.
                  </p>
                </div>

                <div>
                  <label style={{ display: "block", fontSize: "12px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px", marginBottom: "8px" }}>
                    Homepage Announcement Banner Text
                  </label>
                  <textarea
                    rows={2}
                    value={bannerText}
                    onChange={(e) => setBannerText(e.target.value)}
                    style={{ ...inputStyle, resize: "vertical" }}
                    className="focus:border-[#D4AF37] focus:shadow-[0_0_15px_rgba(212,175,55,0.2)]"
                  />
                  <p style={{ fontSize: "12px", color: "#8E9BAE", marginTop: "8px" }}>
                    Dynamic text displayed inside the Flutter APK home screen header.
                  </p>
                </div>

                <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "24px" }}>
                  <div>
                    <label style={{ display: "block", fontSize: "12px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px", marginBottom: "8px" }}>
                      Support Email Address
                    </label>
                    <input
                      type="email"
                      value={supportEmail}
                      onChange={(e) => setSupportEmail(e.target.value)}
                      style={inputStyle}
                      className="focus:border-[#D4AF37] focus:shadow-[0_0_15px_rgba(212,175,55,0.2)]"
                    />
                  </div>
                  <div>
                    <label style={{ display: "block", fontSize: "12px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px", marginBottom: "8px" }}>
                      Support Helpline Phone
                    </label>
                    <input
                      type="text"
                      value={supportPhone}
                      onChange={(e) => setSupportPhone(e.target.value)}
                      style={inputStyle}
                      className="focus:border-[#D4AF37] focus:shadow-[0_0_15px_rgba(212,175,55,0.2)]"
                    />
                  </div>
                </div>
              </>
            )}

            {/* ─── 2. VERIFICATION RULES TAB ────────────────────────────── */}
            {activeTab === "verification" && (
              <div style={{ display: "flex", flexDirection: "column", gap: "16px" }}>
                <div
                  onClick={() => setRequireVerification(!requireVerification)}
                  style={{
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "space-between",
                    padding: "20px",
                    borderRadius: "16px",
                    backgroundColor: "rgba(4, 16, 38, 0.6)",
                    border: "1px solid rgba(212, 175, 55, 0.2)",
                    cursor: "pointer",
                    transition: "all 0.3s ease",
                  }}
                  className="hover:border-[#D4AF37] hover:bg-[rgba(212,175,55,0.05)]"
                >
                  <div>
                    <h4 style={{ fontSize: "15px", fontWeight: 800, color: "#FFFFFF", marginBottom: "4px" }}>Require Manual Profile Verification</h4>
                    <p style={{ fontSize: "13px", color: "#8E9BAE" }}>Newly registered profiles must be reviewed by an administrator before appearing in public searches.</p>
                  </div>
                  <div style={{ width: "48px", height: "24px", borderRadius: "12px", backgroundColor: requireVerification ? "#D4AF37" : "#1E293B", position: "relative", transition: "all 0.3s ease" }}>
                    <div style={{ width: "20px", height: "20px", borderRadius: "50%", backgroundColor: "#041026", position: "absolute", top: "2px", left: requireVerification ? "26px" : "2px", transition: "all 0.3s ease" }} />
                  </div>
                </div>

                <div
                  onClick={() => setAutoApprovePhotos(!autoApprovePhotos)}
                  style={{
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "space-between",
                    padding: "20px",
                    borderRadius: "16px",
                    backgroundColor: "rgba(4, 16, 38, 0.6)",
                    border: "1px solid rgba(212, 175, 55, 0.2)",
                    cursor: "pointer",
                    transition: "all 0.3s ease",
                  }}
                  className="hover:border-[#D4AF37] hover:bg-[rgba(212,175,55,0.05)]"
                >
                  <div>
                    <h4 style={{ fontSize: "15px", fontWeight: 800, color: "#FFFFFF", marginBottom: "4px" }}>Auto-Approve Passport Profile Photos</h4>
                    <p style={{ fontSize: "13px", color: "#8E9BAE" }}>Automatically publish candidate photos uploaded via Flutter app without manual queue review.</p>
                  </div>
                  <div style={{ width: "48px", height: "24px", borderRadius: "12px", backgroundColor: autoApprovePhotos ? "#D4AF37" : "#1E293B", position: "relative", transition: "all 0.3s ease" }}>
                    <div style={{ width: "20px", height: "20px", borderRadius: "50%", backgroundColor: "#041026", position: "absolute", top: "2px", left: autoApprovePhotos ? "26px" : "2px", transition: "all 0.3s ease" }} />
                  </div>
                </div>
              </div>
            )}

            {/* ─── 3. PRIVACY & SECURITY TAB ────────────────────────────── */}
            {activeTab === "privacy" && (
              <div style={{ display: "flex", flexDirection: "column", gap: "16px" }}>
                <div
                  onClick={() => setPrivacyContactMasking(!privacyContactMasking)}
                  style={{
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "space-between",
                    padding: "20px",
                    borderRadius: "16px",
                    backgroundColor: "rgba(4, 16, 38, 0.6)",
                    border: "1px solid rgba(212, 175, 55, 0.2)",
                    cursor: "pointer",
                    transition: "all 0.3s ease",
                  }}
                  className="hover:border-[#D4AF37] hover:bg-[rgba(212,175,55,0.05)]"
                >
                  <div>
                    <h4 style={{ fontSize: "15px", fontWeight: 800, color: "#FFFFFF", marginBottom: "4px" }}>Strict Contact Number Privacy</h4>
                    <p style={{ fontSize: "13px", color: "#8E9BAE" }}>Only profiles with confirmed mutual interest acceptance can view family mobile numbers.</p>
                  </div>
                  <div style={{ width: "48px", height: "24px", borderRadius: "12px", backgroundColor: privacyContactMasking ? "#D4AF37" : "#1E293B", position: "relative", transition: "all 0.3s ease" }}>
                    <div style={{ width: "20px", height: "20px", borderRadius: "50%", backgroundColor: "#041026", position: "absolute", top: "2px", left: privacyContactMasking ? "26px" : "2px", transition: "all 0.3s ease" }} />
                  </div>
                </div>

                <div
                  onClick={() => setAllowPublicSearch(!allowPublicSearch)}
                  style={{
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "space-between",
                    padding: "20px",
                    borderRadius: "16px",
                    backgroundColor: "rgba(4, 16, 38, 0.6)",
                    border: "1px solid rgba(212, 175, 55, 0.2)",
                    cursor: "pointer",
                    transition: "all 0.3s ease",
                  }}
                  className="hover:border-[#D4AF37] hover:bg-[rgba(212,175,55,0.05)]"
                >
                  <div>
                    <h4 style={{ fontSize: "15px", fontWeight: 800, color: "#FFFFFF", marginBottom: "4px" }}>Allow Guest Search Indexing</h4>
                    <p style={{ fontSize: "13px", color: "#8E9BAE" }}>Permit unauthenticated guests to browse candidate previews on the homepage.</p>
                  </div>
                  <div style={{ width: "48px", height: "24px", borderRadius: "12px", backgroundColor: allowPublicSearch ? "#D4AF37" : "#1E293B", position: "relative", transition: "all 0.3s ease" }}>
                    <div style={{ width: "20px", height: "20px", borderRadius: "50%", backgroundColor: "#041026", position: "absolute", top: "2px", left: allowPublicSearch ? "26px" : "2px", transition: "all 0.3s ease" }} />
                  </div>
                </div>
              </div>
            )}

            {/* Save Button */}
            <div style={{ display: "flex", justifyContent: "flex-end", paddingTop: "24px", borderTop: "1px solid rgba(212, 175, 55, 0.2)" }}>
              <button
                type="submit"
                style={{
                  padding: "16px 32px",
                  borderRadius: "12px",
                  background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
                  color: "#041026",
                  fontWeight: 900,
                  fontSize: "14px",
                  textTransform: "uppercase",
                  letterSpacing: "1px",
                  border: "none",
                  cursor: "pointer",
                  boxShadow: "0 10px 25px rgba(212, 175, 55, 0.4)",
                  display: "flex",
                  alignItems: "center",
                  gap: "10px",
                  transition: "all 0.3s ease",
                }}
                className="hover:scale-[1.05] hover:shadow-[0_15px_35px_rgba(212,175,55,0.6)] active:scale-95"
              >
                <span style={{ fontSize: "18px" }}>💾</span>
                Save Settings
              </button>
            </div>
          </form>
        </div>
      </div>
    </AdminLayout>
  );
}
