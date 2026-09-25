"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";

export default function AdminLoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("admin@vankarsamaj.org");
  const [password, setPassword] = useState("password123");
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError("");

    try {
      if (email.trim() && password.trim()) {
        const { adminApi } = await import("../../../lib/admin-api");
        const data = await adminApi.login(email, password);
        
        if (typeof window !== "undefined") {
          localStorage.setItem("adminUser", JSON.stringify(data.user));
        }
        router.push("/admin/dashboard");
      } else {
        setError("Please enter valid administrator credentials.");
      }
    } catch (err: any) {
      setError(err.message || "Unable to connect to authentication services.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div
       style={{ minHeight: "100vh", backgroundColor: "#061224", color: "#ffffff", fontFamily: "'Inter', system-ui, sans-serif", boxSizing: "border-box" }} className="flex justify-center items-center w-full relative p-6"
    >
      {/* Background Radial Glow */}
      <div
         style={{ top: "-100px", left: "-100px", width: "400px", height: "400px", background: "radial-gradient(circle, rgba(212, 175, 55, 0.15) 0%, rgba(0, 0, 0, 0) 70%)", pointerEvents: "none" }} className="absolute rounded-full"
      />
      <div
         style={{ bottom: "-100px", right: "-100px", width: "400px", height: "400px", background: "radial-gradient(circle, rgba(153, 125, 32, 0.2) 0%, rgba(0, 0, 0, 0) 70%)", pointerEvents: "none" }} className="absolute rounded-full"
      />

      {/* Main Login Card */}
      <div
         style={{ maxWidth: "460px", backgroundColor: "#0F2243", border: "1.5px solid rgba(212, 175, 55, 0.4)", borderRadius: "24px", padding: "40px 32px", boxShadow: "0 20px 50px rgba(0, 0, 0, 0.7), 0 0 30px rgba(212, 175, 55, 0.1)", zIndex: 10, boxSizing: "border-box" }} className="w-full relative"
      >
        {/* Top Gold Accent Bar */}
        <div
           style={{ height: "6px", background: "linear-gradient(90deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)", borderTopLeftRadius: "24px", borderTopRightRadius: "24px" }} className="absolute top-0 left-0 right-0"
        />

        {/* Brand Icon Header */}
        <div  style={{ marginBottom: "28px", marginTop: "8px" }} className="text-center">
          <div
              style={{ width: "72px", height: "72px", color: "#000000", fontWeight: 900, fontSize: "36px", margin: "0 auto 16px auto", boxShadow: "0 0 25px rgba(212, 175, 55, 0.5)", border: "2px solid #FFE899" }} className="flex justify-center items-center rounded-full bg-gradient-to-br from-admin-gold via-admin-gold-light to-admin-gold-border" 
          >
            V
          </div>
          <h1
             style={{ fontSize: "22px", fontWeight: 900, letterSpacing: "2px", margin: "0 0 4px 0" }} className="uppercase text-admin-gold"
          >
            VANKAR SAMAJ
          </h1>
          <p
             style={{ color: "rgba(243, 229, 171, 0.9)", letterSpacing: "1.5px", margin: 0 }} className="font-bold uppercase text-xs"
          >
            Matrimony Admin Control Center
          </p>
        </div>

        {error && (
          <div
             style={{ marginBottom: "20px", padding: "12px 16px", backgroundColor: "rgba(136, 19, 55, 0.8)", border: "1px solid rgba(244, 63, 94, 0.5)", color: "#fecdd3" }} className="text-center font-bold text-[13px] rounded-xl"
          >
            ⚠️ {error}
          </div>
        )}

        <form onSubmit={handleLogin}  style={{ gap: "20px" }} className="flex flex-col">
          {/* Email Field */}
          <div>
            <label
                style={{ display: "block", marginBottom: "8px" }} className="font-extrabold uppercase text-admin-gold text-xs tracking-[1px]" 
            >
              Admin Email / Username *
            </label>
            <div  className="relative">
              <span
                 style={{ left: "14px", top: "50%", transform: "translateY(-50%)" }} className="absolute text-base"
              >
                ✉️
              </span>
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                style={{
                  width: "100%",
                  backgroundColor: "#041026",
                  border: "1.5px solid rgba(153, 125, 32, 0.5)",
                  borderRadius: "14px",
                  padding: "14px 16px 14px 44px",
                  fontSize: "14px",
                  color: "#ffffff",
                  fontWeight: 600,
                  outline: "none",
                  boxSizing: "border-box",
                }}
                placeholder="admin@vankarsamaj.org"
              />
            </div>
          </div>

          {/* Password Field */}
          <div>
            <label
                style={{ display: "block", marginBottom: "8px" }} className="font-extrabold uppercase text-admin-gold text-xs tracking-[1px]" 
            >
              Password *
            </label>
            <div  className="relative">
              <span
                 style={{ left: "14px", top: "50%", transform: "translateY(-50%)" }} className="absolute text-base"
              >
                🔒
              </span>
              <input
                type={showPassword ? "text" : "password"}
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                style={{
                  width: "100%",
                  backgroundColor: "#041026",
                  border: "1.5px solid rgba(153, 125, 32, 0.5)",
                  borderRadius: "14px",
                  padding: "14px 50px 14px 44px",
                  fontSize: "14px",
                  color: "#ffffff",
                  fontWeight: 600,
                  outline: "none",
                  boxSizing: "border-box",
                }}
                placeholder="••••••••"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                style={{
                  position: "absolute",
                  right: "14px",
                  top: "50%",
                  transform: "translateY(-50%)",
                  background: "none",
                  border: "none",
                  color: "#AAB7C8",
                  fontSize: "12px",
                  fontWeight: 700,
                  cursor: "pointer",
                }}
              >
                {showPassword ? "Hide" : "Show"}
              </button>
            </div>
          </div>

          {/* Remember Session & Forgot Password */}
          <div
             style={{ color: "#AAB7C8", marginTop: "2px" }} className="flex justify-between items-center text-xs"
          >
            <label  style={{ userSelect: "none" }} className="flex items-center cursor-pointer gap-2">
              <input
                type="checkbox"
                defaultChecked
                 style={{ accentColor: "#D4AF37", width: "16px", height: "16px" }} className="cursor-pointer"
              />
              <span  style={{ color: "#d1d5db" }} className="font-semibold">Remember session</span>
            </label>
            <a href="#"  style={{ textDecoration: "none" }} className="font-bold text-admin-gold">
              Forgot password?
            </a>
          </div>

          {/* Submit Button */}
          <button
            type="submit"
            disabled={loading}
              style={{ padding: "16px 24px", borderRadius: "14px", background: "linear-gradient(90deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)", color: "#000000", fontWeight: 900, letterSpacing: "1.5px", boxShadow: "0 0 20px rgba(212, 175, 55, 0.4)", marginTop: "8px" }} className="w-full uppercase cursor-pointer text-sm border-none" 
          >
            {loading ? "Authenticating..." : "🔑 Sign In to Admin Control Center"}
          </button>
        </form>

        {/* Footer */}
        <div  style={{ marginTop: "28px", borderTop: "1px solid rgba(153, 125, 32, 0.2)", paddingTop: "16px" }} className="text-center">
          <p  style={{ color: "rgba(170, 183, 200, 0.7)", margin: 0 }} className="font-semibold text-[11px]">
            Protected Matrimonial Control Center © 2026 All Gujarat Vankar Samaj
          </p>
        </div>
      </div>
    </div>
  );
}
