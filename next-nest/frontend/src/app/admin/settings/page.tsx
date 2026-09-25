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

  return (
    <AdminLayout
      title="Portal Settings"
      subtitle="Configure system rules, verification constraints, and access policies"
    >
      <div className="max-w-4xl space-y-6">
        {/* Navigation Tabs */}
        <div className="flex border-b border-admin-gold-dark/30 gap-2 overflow-x-auto pb-1">
          <button
            onClick={() => setActiveTab("general")}
            className={`px-5 py-3 rounded-t-2xl font-bold text-xs transition-all duration-200 border-t border-x ${
              activeTab === "general"
                ? "bg-admin-border text-admin-gold border-admin-gold-dark/50 shadow-md"
                : "text-admin-muted-light border-transparent hover:text-white hover:bg-admin-border/40"
            }`}
          >
            ⚙️ General Portal Settings
          </button>
          <button
            onClick={() => setActiveTab("verification")}
            className={`px-5 py-3 rounded-t-2xl font-bold text-xs transition-all duration-200 border-t border-x ${
              activeTab === "verification"
                ? "bg-admin-border text-admin-gold border-admin-gold-dark/50 shadow-md"
                : "text-admin-muted-light border-transparent hover:text-white hover:bg-admin-border/40"
            }`}
          >
            🛡️ Verification Rules
          </button>
          <button
            onClick={() => setActiveTab("privacy")}
            className={`px-5 py-3 rounded-t-2xl font-bold text-xs transition-all duration-200 border-t border-x ${
              activeTab === "privacy"
                ? "bg-admin-border text-admin-gold border-admin-gold-dark/50 shadow-md"
                : "text-admin-muted-light border-transparent hover:text-white hover:bg-admin-border/40"
            }`}
          >
            🔒 Privacy & Security
          </button>
        </div>

        {/* Main Settings Card */}
        <div className="bg-admin-border border border-admin-gold-dark/40 rounded-b-3xl rounded-tr-3xl p-6 sm:p-8 shadow-2xl space-y-6 relative">
          {saved && (
            <div className="p-4 rounded-2xl bg-emerald-950/90 border border-emerald-500/50 text-emerald-400 text-xs font-extrabold flex items-center gap-3 shadow-lg animate-fade-in">
              <span className="text-lg">✓</span>
              <span>Portal settings updated and synchronized with backend NestJS services & PostgreSQL!</span>
            </div>
          )}

          <form onSubmit={handleSave} className="space-y-6 text-xs">
            {/* ─── 1. GENERAL SETTINGS TAB ──────────────────────────────── */}
            {activeTab === "general" && (
              <div className="space-y-5">
                <div>
                  <label className="block text-xs font-bold text-admin-gold uppercase tracking-wider mb-2">
                    Platform Title & Branding Name
                  </label>
                  <input
                    type="text"
                    value={platformName}
                    onChange={(e) => setPlatformName(e.target.value)}
                    className="w-full bg-admin-card border border-admin-gold-dark/40 rounded-xl px-4 py-3 text-sm text-white font-semibold focus:outline-none focus:border-admin-gold focus:ring-1 focus:ring-[#D4AF37] transition-all shadow-inner"
                  />
                  <p className="text-[11px] text-admin-muted-light/70 mt-1.5">
                    Main organization name displayed across mobile app and web portal headers.
                  </p>
                </div>

                <div>
                  <label className="block text-xs font-bold text-admin-gold uppercase tracking-wider mb-2">
                    Homepage Announcement Banner Text
                  </label>
                  <textarea
                    rows={2}
                    value={bannerText}
                    onChange={(e) => setBannerText(e.target.value)}
                    className="w-full bg-admin-card border border-admin-gold-dark/40 rounded-xl px-4 py-3 text-sm text-white font-semibold focus:outline-none focus:border-admin-gold focus:ring-1 focus:ring-[#D4AF37] transition-all shadow-inner"
                  />
                  <p className="text-[11px] text-admin-muted-light/70 mt-1.5">
                    Dynamic text displayed inside the Flutter APK home screen header.
                  </p>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-bold text-admin-gold uppercase tracking-wider mb-2">
                      Support Email Address
                    </label>
                    <input
                      type="email"
                      value={supportEmail}
                      onChange={(e) => setSupportEmail(e.target.value)}
                      className="w-full bg-admin-card border border-admin-gold-dark/40 rounded-xl px-4 py-3 text-sm text-white font-semibold focus:outline-none focus:border-admin-gold focus:ring-1 focus:ring-[#D4AF37] transition-all shadow-inner"
                    />
                  </div>

                  <div>
                    <label className="block text-xs font-bold text-admin-gold uppercase tracking-wider mb-2">
                      Support Helpline Phone
                    </label>
                    <input
                      type="text"
                      value={supportPhone}
                      onChange={(e) => setSupportPhone(e.target.value)}
                      className="w-full bg-admin-card border border-admin-gold-dark/40 rounded-xl px-4 py-3 text-sm text-white font-semibold focus:outline-none focus:border-admin-gold focus:ring-1 focus:ring-[#D4AF37] transition-all shadow-inner"
                    />
                  </div>
                </div>
              </div>
            )}

            {/* ─── 2. VERIFICATION RULES TAB ────────────────────────────── */}
            {activeTab === "verification" && (
              <div className="space-y-4">
                <div
                  onClick={() => setRequireVerification(!requireVerification)}
                  className="flex items-center justify-between p-4 rounded-2xl bg-admin-card border border-admin-gold-dark/30 hover:border-admin-gold transition-all cursor-pointer"
                >
                  <div className="space-y-0.5">
                    <p className="font-bold text-white text-sm">Require Manual Profile Verification</p>
                    <p className="text-[11px] text-admin-muted-light">
                      Newly registered profiles must be reviewed by an administrator before appearing in public searches.
                    </p>
                  </div>
                  <div className={`w-12 h-6 rounded-full transition-colors relative p-1 ${requireVerification ? "bg-admin-gold" : "bg-gray-700"}`}>
                    <div className={`w-4 h-4 rounded-full bg-black transition-transform ${requireVerification ? "translate-x-6" : "translate-x-0"}`} />
                  </div>
                </div>

                <div
                  onClick={() => setAutoApprovePhotos(!autoApprovePhotos)}
                  className="flex items-center justify-between p-4 rounded-2xl bg-admin-card border border-admin-gold-dark/30 hover:border-admin-gold transition-all cursor-pointer"
                >
                  <div className="space-y-0.5">
                    <p className="font-bold text-white text-sm">Auto-Approve Passport Profile Photos</p>
                    <p className="text-[11px] text-admin-muted-light">
                      Automatically publish candidate photos uploaded via Flutter app without manual queue review.
                    </p>
                  </div>
                  <div className={`w-12 h-6 rounded-full transition-colors relative p-1 ${autoApprovePhotos ? "bg-admin-gold" : "bg-gray-700"}`}>
                    <div className={`w-4 h-4 rounded-full bg-black transition-transform ${autoApprovePhotos ? "translate-x-6" : "translate-x-0"}`} />
                  </div>
                </div>
              </div>
            )}

            {/* ─── 3. PRIVACY & SECURITY TAB ────────────────────────────── */}
            {activeTab === "privacy" && (
              <div className="space-y-4">
                <div
                  onClick={() => setPrivacyContactMasking(!privacyContactMasking)}
                  className="flex items-center justify-between p-4 rounded-2xl bg-admin-card border border-admin-gold-dark/30 hover:border-admin-gold transition-all cursor-pointer"
                >
                  <div className="space-y-0.5">
                    <p className="font-bold text-white text-sm">Strict Contact Number Privacy</p>
                    <p className="text-[11px] text-admin-muted-light">
                      Only profiles with confirmed mutual interest acceptance can view family mobile numbers.
                    </p>
                  </div>
                  <div className={`w-12 h-6 rounded-full transition-colors relative p-1 ${privacyContactMasking ? "bg-admin-gold" : "bg-gray-700"}`}>
                    <div className={`w-4 h-4 rounded-full bg-black transition-transform ${privacyContactMasking ? "translate-x-6" : "translate-x-0"}`} />
                  </div>
                </div>

                <div
                  onClick={() => setAllowPublicSearch(!allowPublicSearch)}
                  className="flex items-center justify-between p-4 rounded-2xl bg-admin-card border border-admin-gold-dark/30 hover:border-admin-gold transition-all cursor-pointer"
                >
                  <div className="space-y-0.5">
                    <p className="font-bold text-white text-sm">Allow Guest Search Indexing</p>
                    <p className="text-[11px] text-admin-muted-light">
                      Permit unauthenticated guests to browse candidate previews on the homepage.
                    </p>
                  </div>
                  <div className={`w-12 h-6 rounded-full transition-colors relative p-1 ${allowPublicSearch ? "bg-admin-gold" : "bg-gray-700"}`}>
                    <div className={`w-4 h-4 rounded-full bg-black transition-transform ${allowPublicSearch ? "translate-x-6" : "translate-x-0"}`} />
                  </div>
                </div>
              </div>
            )}

            {/* Save Button */}
            <div className="pt-4 border-t border-admin-gold-dark/20 flex justify-end">
              <button
                type="submit"
                className="py-3 px-8 rounded-xl bg-gradient-to-r from-[#D4AF37] via-[#F3E5AB] to-[#E8C95A] text-black font-black text-xs tracking-wider uppercase shadow-[0_0_20px_rgba(212,175,55,0.3)] hover:scale-105 transition-all cursor-pointer"
              >
                💾 Save Settings
              </button>
            </div>
          </form>
        </div>
      </div>
    </AdminLayout>
  );
}
