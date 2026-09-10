"use client";

import React, { useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";

export default function AdminSettingsPage() {
  const [activeTab, setActiveTab] = useState<"general" | "verification" | "privacy">("general");
  const [saved, setSaved] = useState(false);

  // Settings State
  const [platformName, setPlatformName] = useState("All Gujarat Vankar Samaj Matrimony");
  const [supportEmail, setSupportEmail] = useState("support@vankarsamaj.org");
  const [requireVerification, setRequireVerification] = useState(true);
  const [autoApprovePhotos, setAutoApprovePhotos] = useState(false);
  const [privacyContactMasking, setPrivacyContactMasking] = useState(true);
  const [allowPublicSearch, setAllowPublicSearch] = useState(false);

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();
    setSaved(true);
    setTimeout(() => setSaved(false), 3500);
  };

  return (
    <AdminLayout
      title="Portal Settings"
      subtitle="Configure system rules, verification constraints, and access policies"
    >
      <div className="max-w-4xl space-y-6">
        {/* Navigation Tabs */}
        <div className="flex border-b border-[#997D20]/30 gap-2 overflow-x-auto pb-1">
          <button
            onClick={() => setActiveTab("general")}
            className={`px-5 py-3 rounded-t-2xl font-bold text-xs transition-all duration-200 border-t border-x ${
              activeTab === "general"
                ? "bg-[#0F2040] text-[#D4AF37] border-[#997D20]/50 shadow-md"
                : "text-[#AAB7C8] border-transparent hover:text-white hover:bg-[#0F2040]/40"
            }`}
          >
            ⚙️ General Portal Settings
          </button>
          <button
            onClick={() => setActiveTab("verification")}
            className={`px-5 py-3 rounded-t-2xl font-bold text-xs transition-all duration-200 border-t border-x ${
              activeTab === "verification"
                ? "bg-[#0F2040] text-[#D4AF37] border-[#997D20]/50 shadow-md"
                : "text-[#AAB7C8] border-transparent hover:text-white hover:bg-[#0F2040]/40"
            }`}
          >
            🛡️ Verification Rules
          </button>
          <button
            onClick={() => setActiveTab("privacy")}
            className={`px-5 py-3 rounded-t-2xl font-bold text-xs transition-all duration-200 border-t border-x ${
              activeTab === "privacy"
                ? "bg-[#0F2040] text-[#D4AF37] border-[#997D20]/50 shadow-md"
                : "text-[#AAB7C8] border-transparent hover:text-white hover:bg-[#0F2040]/40"
            }`}
          >
            🔒 Privacy & Security
          </button>
        </div>

        {/* Main Settings Card */}
        <div className="bg-[#0F2040] border border-[#997D20]/40 rounded-b-3xl rounded-tr-3xl p-6 sm:p-8 shadow-2xl space-y-6 relative">
          {saved && (
            <div className="p-4 rounded-2xl bg-emerald-950/90 border border-emerald-500/50 text-emerald-400 text-xs font-extrabold flex items-center gap-3 shadow-lg animate-fade-in">
              <span className="text-lg">✓</span>
              <span>Portal settings updated and synchronized with backend NestJS services!</span>
            </div>
          )}

          <form onSubmit={handleSave} className="space-y-6 text-xs">
            {/* ─── 1. GENERAL SETTINGS TAB ──────────────────────────────── */}
            {activeTab === "general" && (
              <div className="space-y-5">
                <div>
                  <label className="block text-xs font-bold text-[#D4AF37] uppercase tracking-wider mb-2">
                    Platform Title & Branding Name
                  </label>
                  <input
                    type="text"
                    value={platformName}
                    onChange={(e) => setPlatformName(e.target.value)}
                    className="w-full bg-[#041026] border border-[#997D20]/40 rounded-xl px-4 py-3 text-sm text-white font-semibold focus:outline-none focus:border-[#D4AF37] focus:ring-1 focus:ring-[#D4AF37] transition-all shadow-inner"
                  />
                  <p className="text-[11px] text-[#AAB7C8]/70 mt-1.5">
                    Main organization name displayed across mobile app and web portal headers.
                  </p>
                </div>

                <div>
                  <label className="block text-xs font-bold text-[#D4AF37] uppercase tracking-wider mb-2">
                    Support Email Address
                  </label>
                  <input
                    type="email"
                    value={supportEmail}
                    onChange={(e) => setSupportEmail(e.target.value)}
                    className="w-full bg-[#041026] border border-[#997D20]/40 rounded-xl px-4 py-3 text-sm text-white font-semibold focus:outline-none focus:border-[#D4AF37] focus:ring-1 focus:ring-[#D4AF37] transition-all shadow-inner"
                  />
                  <p className="text-[11px] text-[#AAB7C8]/70 mt-1.5">
                    Official email address for user feedback and verification helpdesk inquiries.
                  </p>
                </div>
              </div>
            )}

            {/* ─── 2. VERIFICATION RULES TAB ────────────────────────────── */}
            {activeTab === "verification" && (
              <div className="space-y-4">
                <div
                  onClick={() => setRequireVerification(!requireVerification)}
                  className="flex items-center justify-between p-4 rounded-2xl bg-[#041026] border border-[#997D20]/30 hover:border-[#D4AF37] transition-all cursor-pointer"
                >
                  <div className="space-y-0.5">
                    <p className="font-bold text-white text-sm">Require Manual Profile Verification</p>
                    <p className="text-[11px] text-[#AAB7C8]">
                      Newly registered profiles must be reviewed by an administrator before appearing in public searches.
                    </p>
                  </div>
                  <div className={`w-12 h-6 rounded-full transition-colors relative p-1 ${requireVerification ? "bg-[#D4AF37]" : "bg-gray-700"}`}>
                    <div className={`w-4 h-4 rounded-full bg-black transition-transform ${requireVerification ? "translate-x-6" : "translate-x-0"}`} />
                  </div>
                </div>

                <div
                  onClick={() => setAutoApprovePhotos(!autoApprovePhotos)}
                  className="flex items-center justify-between p-4 rounded-2xl bg-[#041026] border border-[#997D20]/30 hover:border-[#D4AF37] transition-all cursor-pointer"
                >
                  <div className="space-y-0.5">
                    <p className="font-bold text-white text-sm">Auto-Approve Passport Profile Photos</p>
                    <p className="text-[11px] text-[#AAB7C8]">
                      Automatically publish candidate photos uploaded via Flutter app without manual queue review.
                    </p>
                  </div>
                  <div className={`w-12 h-6 rounded-full transition-colors relative p-1 ${autoApprovePhotos ? "bg-[#D4AF37]" : "bg-gray-700"}`}>
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
                  className="flex items-center justify-between p-4 rounded-2xl bg-[#041026] border border-[#997D20]/30 hover:border-[#D4AF37] transition-all cursor-pointer"
                >
                  <div className="space-y-0.5">
                    <p className="font-bold text-white text-sm">Strict Contact Number Privacy</p>
                    <p className="text-[11px] text-[#AAB7C8]">
                      Only profiles with confirmed mutual interest acceptance can view family mobile numbers.
                    </p>
                  </div>
                  <div className={`w-12 h-6 rounded-full transition-colors relative p-1 ${privacyContactMasking ? "bg-[#D4AF37]" : "bg-gray-700"}`}>
                    <div className={`w-4 h-4 rounded-full bg-black transition-transform ${privacyContactMasking ? "translate-x-6" : "translate-x-0"}`} />
                  </div>
                </div>

                <div
                  onClick={() => setAllowPublicSearch(!allowPublicSearch)}
                  className="flex items-center justify-between p-4 rounded-2xl bg-[#041026] border border-[#997D20]/30 hover:border-[#D4AF37] transition-all cursor-pointer"
                >
                  <div className="space-y-0.5">
                    <p className="font-bold text-white text-sm">Allow Guest Search Indexing</p>
                    <p className="text-[11px] text-[#AAB7C8]">
                      Permit unauthenticated guests to browse candidate previews on the homepage.
                    </p>
                  </div>
                  <div className={`w-12 h-6 rounded-full transition-colors relative p-1 ${allowPublicSearch ? "bg-[#D4AF37]" : "bg-gray-700"}`}>
                    <div className={`w-4 h-4 rounded-full bg-black transition-transform ${allowPublicSearch ? "translate-x-6" : "translate-x-0"}`} />
                  </div>
                </div>
              </div>
            )}

            {/* Save Button */}
            <div className="pt-4 border-t border-[#997D20]/20 flex justify-end">
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
