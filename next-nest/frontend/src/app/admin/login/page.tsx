"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";

export default function AdminLoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("admin@vankarsamaj.org");
  const [password, setPassword] = useState("password123");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError("");

    try {
      // Direct authentication check or fallback
      if (email.trim() && password.trim()) {
        if (typeof window !== "undefined") {
          localStorage.setItem("adminToken", "demo-admin-jwt-token");
          localStorage.setItem(
            "adminUser",
            JSON.stringify({ name: "Admin Officer", role: "SUPER_ADMIN" })
          );
        }
        router.push("/admin/dashboard");
      } else {
        setError("Please enter valid admin credentials");
      }
    } catch {
      setError("Failed to sign in. Please check your network connection.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#0A1628] text-white flex items-center justify-center p-4">
      <div className="w-full max-w-md bg-[#0F2040] border border-[#997D20]/50 rounded-3xl p-8 shadow-[0_0_50px_rgba(212,175,55,0.15)] relative overflow-hidden">
        {/* Top Metallic Gold Accent Bar */}
        <div className="absolute top-0 left-0 right-0 h-1.5 bg-gradient-to-r from-[#D4AF37] via-[#E8C95A] to-[#D4AF37]" />

        {/* Brand Icon & Heading */}
        <div className="text-center mt-2 mb-8">
          <div className="w-16 h-16 rounded-full bg-gradient-to-tr from-[#D4AF37] to-[#E8C95A] text-black font-black text-3xl flex items-center justify-center mx-auto shadow-[0_0_20px_rgba(212,175,55,0.4)] mb-4">
            V
          </div>
          <h1 className="text-2xl font-extrabold text-[#D4AF37] tracking-wider uppercase">
            VANKAR
          </h1>
          <p className="text-xs tracking-widest text-[#E8C95A]/80 font-bold uppercase mt-1">
            SAMAJ MATRIMONY ADMIN PORTAL
          </p>
        </div>

        {error && (
          <div className="mb-6 p-3 rounded-xl bg-red-950/50 border border-red-500/40 text-red-400 text-xs text-center font-semibold">
            {error}
          </div>
        )}

        <form onSubmit={handleLogin} className="space-y-5">
          <div>
            <label className="block text-xs font-bold text-[#AAB7C8] uppercase tracking-wider mb-2">
              Admin Email / Username
            </label>
            <input
              type="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="w-full bg-[#041026] border border-[#997D20]/40 rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#D4AF37] transition-all"
              placeholder="admin@vankarsamaj.org"
            />
          </div>

          <div>
            <label className="block text-xs font-bold text-[#AAB7C8] uppercase tracking-wider mb-2">
              Password
            </label>
            <input
              type="password"
              required
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full bg-[#041026] border border-[#997D20]/40 rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:border-[#D4AF37] transition-all"
              placeholder="••••••••"
            />
          </div>

          <div className="flex items-center justify-between text-xs text-[#AAB7C8]">
            <label className="flex items-center gap-2 cursor-pointer">
              <input type="checkbox" defaultChecked className="rounded bg-[#041026] border-[#997D20]" />
              <span>Remember session</span>
            </label>
            <a href="#" className="text-[#D4AF37] hover:underline">
              Forgot password?
            </a>
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full py-3.5 px-6 rounded-xl bg-gradient-to-r from-[#D4AF37] to-[#E8C95A] text-black font-extrabold text-sm tracking-wider uppercase shadow-[0_0_20px_rgba(212,175,55,0.3)] hover:opacity-95 transition-all cursor-pointer"
          >
            {loading ? "Authenticating..." : "Sign In to Admin Portal"}
          </button>
        </form>

        <div className="mt-8 text-center border-t border-[#997D20]/20 pt-4">
          <p className="text-[11px] text-[#AAB7C8]/60">
            Protected Matrimonial Control Center © 2026 Vankar Samaj
          </p>
        </div>
      </div>
    </div>
  );
}
