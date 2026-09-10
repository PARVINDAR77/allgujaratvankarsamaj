"use client";

import { useState } from "react";
import Image from "next/image";
import Link from "next/link";

export default function RegisterPage() {
  const [form, setForm] = useState({
    name: "", phone: "", email: "", password: "", confirm: "", gender: "",
  });
  const [showPass, setShowPass] = useState(false);
  const [loading, setLoading] = useState(false);

  function update(field: string, value: string) {
    setForm((f) => ({ ...f, [field]: value }));
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (form.password !== form.confirm) {
      alert("Passwords do not match!");
      return;
    }
    setLoading(true);
    try {
      const res = await fetch("http://localhost:3000/api/v1/auth/register", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          name: form.name,
          phone: form.phone,
          email: form.email,
          password: form.password,
          gender: form.gender,
        }),
      });
      const data = await res.json();
      if (res.ok) {
        alert("Registration successful! Please login.");
        window.location.href = "/login";
      } else {
        alert(data.message || "Registration failed. Please try again.");
      }
    } catch {
      alert("Unable to connect to server. Please try again.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <>
      <style>{`
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
        html, body { width: 100%; min-height: 100%; overflow-x: hidden; }

        .reg-page {
          min-height: 100vh;
          width: 100%;
          background: linear-gradient(160deg, #0a120a 0%, #0d1b3e 50%, #0a120a 100%);
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          padding: 24px 16px;
          font-family: 'Inter', sans-serif;
          position: relative;
        }
        .reg-page::before {
          content: '';
          position: absolute;
          top: -20%;left: 50%;transform: translateX(-50%);
          width: 600px;height: 600px;
          background: radial-gradient(circle, rgba(26,90,46,0.08) 0%, transparent 70%);
          pointer-events: none;
        }
        .reg-card {
          width: 100%; max-width: 440px;
          background: linear-gradient(160deg, rgba(10,18,10,0.98) 0%, rgba(13,27,62,0.95) 100%);
          border: 2px solid #c9a227;
          border-radius: 20px;
          box-shadow: 0 20px 60px rgba(0,0,0,0.6), 0 0 40px rgba(212,175,55,0.08);
          padding: 28px 24px 24px;
          position: relative; z-index: 2;
        }
        .gold-line {
          height: 2px;
          background: linear-gradient(90deg,transparent,#c9a227,#FFE066,#c9a227,transparent);
          border-radius: 99px;
          margin-bottom: 20px;
        }
        .logo-area { text-align: center; margin-bottom: 20px; }
        .logo-img {
          width: 64px; height: 64px;
          border-radius: 50%; border: 2px solid #c9a227;
          object-fit: cover; display: block; margin: 0 auto 10px;
          box-shadow: 0 0 16px rgba(212,175,55,0.3);
        }
        .logo-title {
          font-family: 'Cinzel', serif; font-size: 1.3rem; font-weight: 900;
          background: linear-gradient(135deg,#FFE066,#D4AF37,#B8860B);
          -webkit-background-clip: text; -webkit-text-fill-color: transparent;
          background-clip: text;
        }
        .logo-sub {
          color: rgba(212,175,55,0.65); font-size: 0.65rem;
          font-family: 'Noto Sans Gujarati',sans-serif;
          letter-spacing: 0.05em; margin-top: 4px;
        }
        .form-group { margin-bottom: 14px; }
        .form-label {
          display: block; color: rgba(255,220,100,0.85);
          font-size: 0.76rem; font-weight: 600; margin-bottom: 5px;
          letter-spacing: 0.04em;
        }
        .input-wrap { position: relative; display: flex; align-items: center; }
        .input-icon { position: absolute; left: 12px; font-size: 0.9rem; opacity: 0.7; pointer-events: none; }
        .form-input {
          width: 100%;
          background: rgba(255,255,255,0.05);
          border: 1.5px solid rgba(212,175,55,0.3);
          border-radius: 10px;
          color: #fff; font-family: 'Inter',sans-serif;
          font-size: 0.88rem;
          padding: 11px 12px 11px 38px;
          outline: none;
          transition: border-color .25s, box-shadow .25s;
        }
        .form-input:focus {
          border-color: #c9a227;
          box-shadow: 0 0 0 3px rgba(212,175,55,0.12);
        }
        .form-input::placeholder { color: rgba(255,255,255,0.28); }
        .show-pass {
          position: absolute; right: 12px;
          background: none; border: none; cursor: pointer;
          color: rgba(212,175,55,0.65); font-size: 0.95rem; padding: 0;
        }
        .show-pass:hover { color: #FFE066; }
        .gender-row { display: flex; gap: 10px; }
        .gender-btn {
          flex: 1; padding: 10px 6px;
          border-radius: 10px; border: 1.5px solid rgba(212,175,55,0.3);
          background: rgba(255,255,255,0.04);
          color: rgba(255,255,255,0.6);
          font-family: 'Inter',sans-serif; font-size: 0.82rem;
          cursor: pointer; transition: all .2s;
          display: flex; align-items: center; justify-content: center; gap: 6px;
        }
        .gender-btn.selected {
          border-color: #c9a227; background: rgba(212,175,55,0.12);
          color: #FFE066; font-weight: 600;
        }
        .btn-submit {
          width: 100%; padding: 13px;
          border-radius: 50px; border: 2px solid #c9a227;
          background: linear-gradient(135deg,#1a602e 0%,#0c3518 100%);
          color: #FFE066;
          font-family: 'Cinzel',serif; font-size: 0.95rem; font-weight: 700;
          letter-spacing: 0.06em; cursor: pointer;
          transition: all .25s ease;
          box-shadow: 0 4px 20px rgba(10,55,25,.5), 0 0 16px rgba(212,175,55,.12);
          margin-top: 6px;
          display: flex; align-items: center; justify-content: center; gap: 8px;
        }
        .btn-submit:hover:not(:disabled) {
          transform: translateY(-2px);
          box-shadow: 0 8px 28px rgba(10,55,25,.7), 0 0 28px rgba(212,175,55,.3);
        }
        .btn-submit:disabled { opacity: 0.6; cursor: not-allowed; }
        .card-footer {
          text-align: center; margin-top: 18px; padding-top: 16px;
          border-top: 1px solid rgba(212,175,55,0.18);
        }
        .card-footer p { color: rgba(255,255,255,0.45); font-size: 0.76rem; margin-bottom: 5px; }
        .card-footer a { color: #c9a227; font-weight: 600; text-decoration: none; font-size: 0.8rem; }
        .card-footer a:hover { color: #FFE066; }
        .back-link {
          display: inline-flex; align-items: center; gap: 6px;
          color: rgba(212,175,55,0.6); text-decoration: none;
          font-size: 0.75rem; margin-top: 16px;
          font-family: 'Inter',sans-serif; transition: color .2s;
        }
        .back-link:hover { color: #FFE066; }
        @keyframes spin { to { transform: rotate(360deg); } }
        .spinner {
          width: 15px; height: 15px;
          border: 2px solid rgba(255,220,100,0.3);
          border-top-color: #FFE066; border-radius: 50%;
          animation: spin .7s linear infinite;
        }
      `}</style>

      <div className="reg-page">
        <div className="reg-card">
          <div className="gold-line" />

          <div className="logo-area">
            <Image
              src="/vankar-samaj-banner.jpg"
              alt="Vankar Samaj"
              width={64} height={64}
              className="logo-img"
              style={{ width: 64, height: 64 }}
            />
            <h1 className="logo-title">VANKAR SAMAJ</h1>
            <p className="logo-sub">એક સમાજ · એક વિશ્વાસ · એક પરિવાર</p>
          </div>

          <form onSubmit={handleSubmit}>
            {/* Full Name */}
            <div className="form-group">
              <label className="form-label" htmlFor="name">👤 Full Name</label>
              <div className="input-wrap">
                <span className="input-icon">✏️</span>
                <input id="name" type="text" className="form-input"
                  placeholder="Enter your full name"
                  value={form.name} onChange={(e) => update("name", e.target.value)} required />
              </div>
            </div>

            {/* Gender */}
            <div className="form-group">
              <label className="form-label">⚧ Gender</label>
              <div className="gender-row">
                {[["🧔 Male","Male"],["👩 Female","Female"]].map(([label, val]) => (
                  <button key={val} type="button"
                    className={`gender-btn ${form.gender === val ? "selected" : ""}`}
                    onClick={() => update("gender", val)}>
                    {label}
                  </button>
                ))}
              </div>
            </div>

            {/* Mobile */}
            <div className="form-group">
              <label className="form-label" htmlFor="reg-phone">📱 Mobile Number</label>
              <div className="input-wrap">
                <span className="input-icon" style={{ fontSize: "0.75rem", left: "10px" }}>+91</span>
                <input id="reg-phone" type="tel" className="form-input"
                  placeholder="10-digit mobile number"
                  value={form.phone} onChange={(e) => update("phone", e.target.value)}
                  maxLength={10} required style={{ paddingLeft: "48px" }} />
              </div>
            </div>

            {/* Email */}
            <div className="form-group">
              <label className="form-label" htmlFor="email">📧 Email (Optional)</label>
              <div className="input-wrap">
                <span className="input-icon">✉️</span>
                <input id="email" type="email" className="form-input"
                  placeholder="your@email.com"
                  value={form.email} onChange={(e) => update("email", e.target.value)} />
              </div>
            </div>

            {/* Password */}
            <div className="form-group">
              <label className="form-label" htmlFor="reg-pass">🔒 Password</label>
              <div className="input-wrap">
                <span className="input-icon">🔑</span>
                <input id="reg-pass" type={showPass ? "text" : "password"} className="form-input"
                  placeholder="Create a password"
                  value={form.password} onChange={(e) => update("password", e.target.value)} required />
                <button type="button" className="show-pass"
                  onClick={() => setShowPass(!showPass)}>
                  {showPass ? "🙈" : "👁️"}
                </button>
              </div>
            </div>

            {/* Confirm Password */}
            <div className="form-group">
              <label className="form-label" htmlFor="confirm">✅ Confirm Password</label>
              <div className="input-wrap">
                <span className="input-icon">🔒</span>
                <input id="confirm" type={showPass ? "text" : "password"} className="form-input"
                  placeholder="Confirm your password"
                  value={form.confirm} onChange={(e) => update("confirm", e.target.value)} required />
              </div>
            </div>

            <button type="submit" className="btn-submit" disabled={loading} id="register-submit-btn">
              {loading
                ? <><div className="spinner" /> Registering…</>
                : <>👥 Register Now &nbsp;›</>
              }
            </button>
          </form>

          <div className="card-footer">
            <p>Already have an account?</p>
            <Link href="/login">👤 Login Here</Link>
          </div>
        </div>

        <Link href="/" className="back-link">← Back to Home</Link>
      </div>
    </>
  );
}
