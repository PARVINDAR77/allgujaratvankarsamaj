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
        if (typeof window !== "undefined") {
          localStorage.setItem("adminToken", "demo-admin-jwt-token");
          localStorage.setItem(
            "adminUser",
            JSON.stringify({ name: "Admin Officer", role: "SUPER_ADMIN" })
          );
        }
        router.push("/admin/dashboard");
      } else {
        setError("Please enter valid administrator credentials.");
      }
    } catch {
      setError("Unable to connect to authentication services.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div
      style={{
        minHeight: "100vh",
        width: "100%",
        backgroundColor: "#061224",
        color: "#ffffff",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        padding: "24px",
        fontFamily: "'Inter', system-ui, sans-serif",
        position: "relative",
        boxSizing: "border-box",
      }}
    >
      {/* Background Radial Glow */}
      <div
        style={{
          position: "absolute",
          top: "-100px",
          left: "-100px",
          width: "400px",
          height: "400px",
          background: "radial-gradient(circle, rgba(212,175,55,0.15) 0%, rgba(0,0,0,0) 70%)",
          borderRadius: "50%",
          pointerEvents: "none",
        }}
      />
      <div
        style={{
          position: "absolute",
          bottom: "-100px",
          right: "-100px",
          width: "400px",
          height: "400px",
          background: "radial-gradient(circle, rgba(153,125,32,0.2) 0%, rgba(0,0,0,0) 70%)",
          borderRadius: "50%",
          pointerEvents: "none",
        }}
      />

      {/* Main Login Card */}
      <div
        style={{
          width: "100%",
          maxWidth: "460px",
          backgroundColor: "#0F2243",
          border: "1.5px solid rgba(212, 175, 55, 0.4)",
          borderRadius: "24px",
          padding: "40px 32px",
          boxShadow: "0 20px 50px rgba(0, 0, 0, 0.7), 0 0 30px rgba(212, 175, 55, 0.1)",
          position: "relative",
          zIndex: 10,
          boxSizing: "border-box",
        }}
      >
        {/* Top Gold Accent Bar */}
        <div
          style={{
            position: "absolute",
            top: 0,
            left: 0,
            right: 0,
            height: "6px",
            background: "linear-gradient(90deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
            borderTopLeftRadius: "24px",
            borderTopRightRadius: "24px",
          }}
        />

        {/* Brand Icon Header */}
        <div style={{ textAlign: "center", marginBottom: "28px", marginTop: "8px" }}>
          <div
            style={{
              width: "72px",
              height: "72px",
              borderRadius: "50%",
              background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
              color: "#000000",
              fontWeight: 900,
              fontSize: "36px",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              margin: "0 auto 16px auto",
              boxShadow: "0 0 25px rgba(212, 175, 55, 0.5)",
              border: "2px solid #FFE899",
            }}
          >
            V
          </div>
          <h1
            style={{
              fontSize: "22px",
              fontWeight: 900,
              color: "#D4AF37",
              letterSpacing: "2px",
              textTransform: "uppercase",
              margin: "0 0 4px 0",
            }}
          >
            VANKAR SAMAJ
          </h1>
          <p
            style={{
              fontSize: "12px",
              fontWeight: 700,
              color: "rgba(243, 229, 171, 0.9)",
              letterSpacing: "1.5px",
              textTransform: "uppercase",
              margin: 0,
            }}
          >
            Matrimony Admin Control Center
          </p>
        </div>

        {error && (
          <div
            style={{
              marginBottom: "20px",
              padding: "12px 16px",
              borderRadius: "12px",
              backgroundColor: "rgba(136, 19, 55, 0.8)",
              border: "1px solid rgba(244, 63, 94, 0.5)",
              color: "#fecdd3",
              fontSize: "13px",
              fontWeight: 700,
              textAlign: "center",
            }}
          >
            ⚠️ {error}
          </div>
        )}

        <form onSubmit={handleLogin} style={{ display: "flex", flexDirection: "column", gap: "20px" }}>
          {/* Email Field */}
          <div>
            <label
              style={{
                display: "block",
                fontSize: "12px",
                fontWeight: 800,
                color: "#D4AF37",
                textTransform: "uppercase",
                letterSpacing: "1px",
                marginBottom: "8px",
              }}
            >
              Admin Email / Username *
            </label>
            <div style={{ position: "relative" }}>
              <span
                style={{
                  position: "absolute",
                  left: "14px",
                  top: "50%",
                  transform: "translateY(-50%)",
                  fontSize: "16px",
                }}
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
              style={{
                display: "block",
                fontSize: "12px",
                fontWeight: 800,
                color: "#D4AF37",
                textTransform: "uppercase",
                letterSpacing: "1px",
                marginBottom: "8px",
              }}
            >
              Password *
            </label>
            <div style={{ position: "relative" }}>
              <span
                style={{
                  position: "absolute",
                  left: "14px",
                  top: "50%",
                  transform: "translateY(-50%)",
                  fontSize: "16px",
                }}
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
            style={{
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between",
              fontSize: "12px",
              color: "#AAB7C8",
              marginTop: "2px",
            }}
          >
            <label style={{ display: "flex", alignItems: "center", gap: "8px", cursor: "pointer", userSelect: "none" }}>
              <input
                type="checkbox"
                defaultChecked
                style={{ accentColor: "#D4AF37", width: "16px", height: "16px", cursor: "pointer" }}
              />
              <span style={{ fontWeight: 600, color: "#d1d5db" }}>Remember session</span>
            </label>
            <a href="#" style={{ color: "#D4AF37", fontWeight: 700, textDecoration: "none" }}>
              Forgot password?
            </a>
          </div>

          {/* Submit Button */}
          <button
            type="submit"
            disabled={loading}
            style={{
              width: "100%",
              padding: "16px 24px",
              borderRadius: "14px",
              background: "linear-gradient(90deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
              color: "#000000",
              fontWeight: 900,
              fontSize: "14px",
              letterSpacing: "1.5px",
              textTransform: "uppercase",
              border: "none",
              cursor: "pointer",
              boxShadow: "0 0 20px rgba(212, 175, 55, 0.4)",
              marginTop: "8px",
            }}
          >
            {loading ? "Authenticating..." : "🔑 Sign In to Admin Control Center"}
          </button>
        </form>

        {/* Footer */}
        <div style={{ marginTop: "28px", textAlign: "center", borderTop: "1px solid rgba(153, 125, 32, 0.2)", paddingTop: "16px" }}>
          <p style={{ fontSize: "11px", color: "rgba(170, 183, 200, 0.7)", fontWeight: 600, margin: 0 }}>
            Protected Matrimonial Control Center © 2026 All Gujarat Vankar Samaj
          </p>
        </div>
      </div>
    </div>
  );
}
