"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import Image from "next/image";

export default function LoginPage() {
  const router = useRouter();
  const [identifier, setIdentifier] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    const idTrimmed = identifier.trim();
    if (!idTrimmed || !password.trim()) {
      setError("કૃપા કરીને મોબાઇલ નંબર/ઈમેલ અને પાસવર્ડ દાખલ કરો (Please enter credentials)");
      return;
    }

    setLoading(true);
    setError("");

    try {
      const isEmail = idTrimmed.includes("@");
      const payload: Record<string, string> = {
        password: password.trim(),
      };
      if (isEmail) {
        payload.email = idTrimmed;
      } else {
        payload.phone = idTrimmed;
      }

      const apiBase = process.env.NEXT_PUBLIC_API_URL || "/api/v1";
      const res = await fetch(`${apiBase}/auth/login`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        credentials: "include",
        body: JSON.stringify(payload),
      });

      const data = await res.json().catch(() => ({}));

      if (!res.ok) {
        throw new Error(data.message || `Login failed (Status: ${res.status})`);
      }

      if (typeof window !== "undefined") {
        if (data.accessToken) {
          localStorage.setItem("accessToken", data.accessToken);
          localStorage.setItem("token", data.accessToken);
        }
        if (data.user) {
          localStorage.setItem("user", JSON.stringify(data.user));
        }

        const role = data.user?.role;
        const isAdmin =
          role === "ADMIN" ||
          role === "SUPER_ADMIN" ||
          role === "VERIFICATION_ADMIN";

        if (isAdmin) {
          if (data.accessToken) localStorage.setItem("adminToken", data.accessToken);
          localStorage.setItem("adminUser", JSON.stringify(data.user));
          router.push("/admin/dashboard");
        } else {
          router.push("/profile");
        }
      }
    } catch (err: any) {
      setError(err.message || "લોગિન કરવામાં નિષ્ફળતા. કૃપા કરીને વિગતો ફરી તપાસો.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div
      style={{
        minHeight: "100vh",
        backgroundColor: "#061224",
        color: "#ffffff",
        fontFamily: "'Inter', system-ui, sans-serif",
        boxSizing: "border-box",
      }}
      className="flex justify-center items-center w-full relative p-4"
    >
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Cinzel:wght@600;700;800&family=Noto+Sans+Gujarati:wght@400;600;700&display=swap');
        .font-cinzel { font-family: 'Cinzel', serif; }
        .font-gujarati { font-family: 'Noto Sans Gujarati', sans-serif; }
      `}</style>

      {/* Background Radial Glow */}
      <div
        style={{
          top: "-80px",
          left: "-80px",
          width: "360px",
          height: "360px",
          background: "radial-gradient(circle, rgba(212, 175, 55, 0.15) 0%, rgba(0, 0, 0, 0) 70%)",
          pointerEvents: "none",
        }}
        className="absolute rounded-full"
      />
      <div
        style={{
          bottom: "-80px",
          right: "-80px",
          width: "360px",
          height: "360px",
          background: "radial-gradient(circle, rgba(153, 125, 32, 0.2) 0%, rgba(0, 0, 0, 0) 70%)",
          pointerEvents: "none",
        }}
        className="absolute rounded-full"
      />

      {/* Main Login Card */}
      <div
        style={{
          maxWidth: "440px",
          backgroundColor: "#0F2243",
          border: "1.5px solid rgba(212, 175, 55, 0.45)",
          borderRadius: "24px",
          padding: "36px 28px",
          boxShadow: "0 20px 50px rgba(0, 0, 0, 0.7), 0 0 30px rgba(212, 175, 55, 0.1)",
          zIndex: 10,
          boxSizing: "border-box",
        }}
        className="w-full relative font-gujarati"
      >
        {/* Top Gold Accent Bar */}
        <div
          style={{
            height: "5px",
            background: "linear-gradient(90deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
            borderTopLeftRadius: "24px",
            borderTopRightRadius: "24px",
          }}
          className="absolute top-0 left-0 right-0"
        />

        {/* Brand Icon Header */}
        <div style={{ marginBottom: "24px", marginTop: "4px" }} className="text-center">
          <div
            style={{
              width: "68px",
              height: "68px",
              color: "#000000",
              fontWeight: 900,
              fontSize: "32px",
              margin: "0 auto 14px auto",
              boxShadow: "0 0 20px rgba(212, 175, 55, 0.5)",
              border: "2px solid #FFE899",
            }}
            className="flex justify-center items-center rounded-full bg-gradient-to-br from-[#D4AF37] via-[#F3E5AB] to-[#C59B27]"
          >
            V
          </div>
          <h1
            style={{ fontSize: "20px", fontWeight: 900, letterSpacing: "1.5px", margin: "0 0 4px 0" }}
            className="uppercase text-[#FFE066] font-cinzel"
          >
            VANKAR SAMAJ
          </h1>
          <p
            style={{ color: "rgba(243, 229, 171, 0.9)", letterSpacing: "1px", margin: 0 }}
            className="font-bold uppercase text-xs"
          >
            સભ્ય અને ઉમેદવાર લોગિન (Member Login)
          </p>
        </div>

        {error && (
          <div
            style={{
              marginBottom: "18px",
              padding: "10px 14px",
              backgroundColor: "rgba(136, 19, 55, 0.85)",
              border: "1px solid rgba(244, 63, 94, 0.5)",
              color: "#fecdd3",
            }}
            className="text-center font-semibold text-xs rounded-xl"
          >
            ⚠️ {error}
          </div>
        )}

        <form onSubmit={handleLogin} style={{ display: "flex", flexDirection: "column", gap: "18px" }}>
          {/* Mobile or Email Field */}
          <div>
            <label
              style={{ display: "block", marginBottom: "6px" }}
              className="font-bold text-[#FFE066] text-xs"
            >
              મોબાઇલ નંબર અથવા ઈમેલ (Mobile or Email) *
            </label>
            <input
              type="text"
              value={identifier}
              onChange={(e) => setIdentifier(e.target.value)}
              placeholder="દા.ત. 9876543210 અથવા user@example.com"
              required
              style={{
                width: "100%",
                padding: "12px 14px",
                backgroundColor: "#07142A",
                border: "1px solid rgba(212, 175, 55, 0.35)",
                borderRadius: "12px",
                color: "#ffffff",
                fontSize: "14px",
                outline: "none",
                boxSizing: "border-box",
              }}
            />
          </div>

          {/* Password Field */}
          <div>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "6px" }}>
              <label className="font-bold text-[#FFE066] text-xs">પાસવર્ડ (Password) *</label>
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                style={{ background: "none", border: "none", color: "#D4AF37", fontSize: "11px", cursor: "pointer" }}
              >
                {showPassword ? "Hide" : "Show"}
              </button>
            </div>
            <input
              type={showPassword ? "text" : "password"}
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="••••••••"
              required
              style={{
                width: "100%",
                padding: "12px 14px",
                backgroundColor: "#07142A",
                border: "1px solid rgba(212, 175, 55, 0.35)",
                borderRadius: "12px",
                color: "#ffffff",
                fontSize: "14px",
                outline: "none",
                boxSizing: "border-box",
              }}
            />
          </div>

          {/* Submit Button */}
          <button
            type="submit"
            disabled={loading}
            style={{
              width: "100%",
              padding: "13px",
              marginTop: "6px",
              background: "linear-gradient(135deg, #D4AF37 0%, #FFE066 100%)",
              color: "#0B1A30",
              fontWeight: 800,
              fontSize: "14px",
              borderRadius: "12px",
              border: "none",
              cursor: loading ? "not-allowed" : "pointer",
              boxShadow: "0 6px 16px rgba(212, 175, 55, 0.35)",
            }}
          >
            {loading ? "ચકાસી રહ્યું છે... (Signing in...)" : "લોગિન કરો (Sign In)"}
          </button>

          {/* Registration & Links */}
          <div style={{ textAlign: "center", marginTop: "12px", fontSize: "13px", color: "rgba(255, 255, 255, 0.75)" }}>
            નવા સભ્ય છો?{" "}
            <Link href="/register" style={{ color: "#FFE066", fontWeight: "bold", textDecoration: "underline" }}>
              નોંધણી કરો (Register Here)
            </Link>
          </div>

          <div style={{ textAlign: "center", fontSize: "12px", color: "rgba(255, 255, 255, 0.5)", marginTop: "4px" }}>
            <Link href="/admin/login" style={{ color: "rgba(212, 175, 55, 0.8)", textDecoration: "none" }}>
              🔐 એડમિન લોગિન પોર્ટલ (Admin Portal) &rarr;
            </Link>
          </div>
        </form>
      </div>
    </div>
  );
}
