"use client";

import { useState } from "react";
import Image from "next/image";
import Link from "next/link";

export default function LoginPage() {
  const [phone, setPhone] = useState("");
  const [password, setPassword] = useState("");
  const [showPass, setShowPass] = useState(false);
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    try {
      const res = await fetch("http://localhost:3000/api/v1/auth/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ phone, password }),
      });
      const data = await res.json();
      if (res.ok) {
        localStorage.setItem("token", data.access_token);
        window.location.href = "/matrimony";
      } else {
        alert(data.message || "Login failed. Please check your credentials.");
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

        @import url('https://fonts.googleapis.com/css2?family=Cinzel:wght@700;900&family=Noto+Sans+Gujarati:wght@600&family=Inter:wght@400;500;600;700&display=swap');

        .login-page {
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
          overflow: hidden;
        }

        /* Ambient glow */
        .login-page::before {
          content: '';
          position: absolute;
          top: -30%;
          left: 50%;
          transform: translateX(-50%);
          width: 600px;
          height: 600px;
          background: radial-gradient(circle, rgba(212,175,55,0.08) 0%, transparent 70%);
          pointer-events: none;
        }

        /* ── CARD ── */
        .login-card {
          width: 100%;
          max-width: 420px;
          background: linear-gradient(160deg, rgba(13,27,62,0.95) 0%, rgba(10,18,10,0.98) 100%);
          border: 2px solid #c9a227;
          border-radius: 20px;
          box-shadow:
            0 0 0 1px rgba(212,175,55,0.15),
            0 20px 60px rgba(0,0,0,0.6),
            0 0 40px rgba(212,175,55,0.08);
          padding: 32px 28px 28px;
          position: relative;
          z-index: 2;
        }

        /* top gold line */
        .gold-line {
          height: 2px;
          background: linear-gradient(90deg, transparent, #c9a227, #FFE066, #c9a227, transparent);
          border-radius: 99px;
          margin-bottom: 24px;
        }

        /* ── LOGO AREA ── */
        .logo-area {
          text-align: center;
          margin-bottom: 24px;
        }
        .logo-img {
          width: 80px;
          height: 80px;
          border-radius: 50%;
          border: 2px solid #c9a227;
          object-fit: cover;
          object-position: top center;
          box-shadow: 0 0 20px rgba(212,175,55,0.3);
          margin: 0 auto 12px;
          display: block;
        }
        .logo-title {
          font-family: 'Cinzel', serif;
          font-size: 1.5rem;
          font-weight: 900;
          background: linear-gradient(135deg, #FFE066 0%, #D4AF37 50%, #B8860B 100%);
          -webkit-background-clip: text;
          -webkit-text-fill-color: transparent;
          background-clip: text;
          line-height: 1.1;
          margin-bottom: 4px;
        }
        .logo-sub {
          font-family: 'Noto Sans Gujarati', sans-serif;
          color: rgba(212,175,55,0.75);
          font-size: 0.72rem;
          letter-spacing: 0.06em;
        }
        .logo-tagline {
          font-family: 'Cinzel', serif;
          color: #c9a227;
          font-size: 0.6rem;
          letter-spacing: 0.25em;
          margin-top: 6px;
          opacity: 0.8;
        }

        /* ── FORM ── */
        .form-label {
          display: block;
          color: rgba(255,220,100,0.85);
          font-size: 0.78rem;
          font-weight: 600;
          margin-bottom: 6px;
          letter-spacing: 0.04em;
        }
        .form-group { margin-bottom: 18px; }

        .input-wrap {
          position: relative;
          display: flex;
          align-items: center;
        }
        .input-icon {
          position: absolute;
          left: 14px;
          font-size: 1rem;
          pointer-events: none;
          opacity: 0.7;
        }
        .form-input {
          width: 100%;
          background: rgba(255,255,255,0.05);
          border: 1.5px solid rgba(212,175,55,0.35);
          border-radius: 10px;
          color: #fff;
          font-family: 'Inter', sans-serif;
          font-size: 0.9rem;
          padding: 12px 14px 12px 42px;
          outline: none;
          transition: border-color .25s, box-shadow .25s;
        }
        .form-input:focus {
          border-color: #c9a227;
          box-shadow: 0 0 0 3px rgba(212,175,55,0.15);
        }
        .form-input::placeholder { color: rgba(255,255,255,0.3); }

        .show-pass {
          position: absolute;
          right: 14px;
          background: none;
          border: none;
          cursor: pointer;
          color: rgba(212,175,55,0.7);
          font-size: 1rem;
          padding: 0;
          line-height: 1;
        }
        .show-pass:hover { color: #FFE066; }

        /* ── SUBMIT BUTTON ── */
        .btn-submit {
          width: 100%;
          padding: 13px;
          border-radius: 50px;
          border: 2px solid #c9a227;
          background: linear-gradient(135deg, #1a3d7a 0%, #0c1e45 100%);
          color: #FFE066;
          font-family: 'Cinzel', serif;
          font-size: 1rem;
          font-weight: 700;
          letter-spacing: 0.08em;
          cursor: pointer;
          transition: all .25s ease;
          box-shadow: 0 4px 20px rgba(10,30,70,.5), 0 0 16px rgba(212,175,55,.15);
          margin-top: 8px;
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 8px;
        }
        .btn-submit:hover:not(:disabled) {
          transform: translateY(-2px);
          box-shadow: 0 8px 28px rgba(10,30,70,.7), 0 0 28px rgba(212,175,55,.35);
        }
        .btn-submit:disabled { opacity: 0.6; cursor: not-allowed; }

        /* ── FOOTER LINKS ── */
        .card-footer {
          text-align: center;
          margin-top: 20px;
          padding-top: 18px;
          border-top: 1px solid rgba(212,175,55,0.2);
        }
        .card-footer p {
          color: rgba(255,255,255,0.5);
          font-size: 0.78rem;
          margin-bottom: 6px;
        }
        .card-footer a {
          color: #c9a227;
          font-weight: 600;
          text-decoration: none;
          font-size: 0.82rem;
          transition: color .2s;
        }
        .card-footer a:hover { color: #FFE066; }

        .back-link {
          display: inline-flex;
          align-items: center;
          gap: 6px;
          color: rgba(212,175,55,0.6);
          text-decoration: none;
          font-size: 0.75rem;
          margin-top: 16px;
          transition: color .2s;
          font-family: 'Inter', sans-serif;
        }
        .back-link:hover { color: #FFE066; }

        /* spinner */
        @keyframes spin { to { transform: rotate(360deg); } }
        .spinner {
          width: 16px; height: 16px;
          border: 2px solid rgba(255,220,100,0.3);
          border-top-color: #FFE066;
          border-radius: 50%;
          animation: spin .7s linear infinite;
        }
      `}</style>

      <div className="login-page">

        {/* ── CARD ── */}
        <div className="login-card">
          <div className="gold-line" />

          {/* Logo */}
          <div className="logo-area">
            <Image
              src="/vankar-samaj-banner.jpg"
              alt="Vankar Samaj"
              width={80}
              height={80}
              className="logo-img"
              style={{ width: 80, height: 80 }}
            />
            <h1 className="logo-title">VANKAR SAMAJ</h1>
            <p className="logo-sub">એક સમાજ · એક વિશ્વાસ · એક પરિવાર</p>
            <p className="logo-tagline">UNITY · SERVICE · PROGRESS</p>
          </div>

          {/* Form */}
          <form onSubmit={handleSubmit}>
            <div className="form-group">
              <label className="form-label" htmlFor="phone">📱 Mobile Number</label>
              <div className="input-wrap">
                <span className="input-icon">+91</span>
                <input
                  id="phone"
                  type="tel"
                  className="form-input"
                  placeholder="Enter your mobile number"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  maxLength={10}
                  required
                  style={{ paddingLeft: "52px" }}
                />
              </div>
            </div>

            <div className="form-group">
              <label className="form-label" htmlFor="password">🔒 Password</label>
              <div className="input-wrap">
                <span className="input-icon" style={{ left: "14px" }}>🔑</span>
                <input
                  id="password"
                  type={showPass ? "text" : "password"}
                  className="form-input"
                  placeholder="Enter your password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                />
                <button
                  type="button"
                  className="show-pass"
                  onClick={() => setShowPass(!showPass)}
                  aria-label="Toggle password visibility"
                >
                  {showPass ? "🙈" : "👁️"}
                </button>
              </div>
            </div>

            <div style={{ textAlign: "right", marginBottom: "18px", marginTop: "-10px" }}>
              <a
                href="/forgot-password"
                style={{
                  color: "rgba(212,175,55,0.65)",
                  fontSize: "0.75rem",
                  textDecoration: "none",
                }}
              >
                Forgot Password?
              </a>
            </div>

            <button
              type="submit"
              className="btn-submit"
              disabled={loading}
              id="login-submit-btn"
            >
              {loading ? (
                <><div className="spinner" /> Logging in…</>
              ) : (
                <>👤 Login &nbsp;›</>
              )}
            </button>
          </form>

          {/* Footer */}
          <div className="card-footer">
            <p>Don&apos;t have an account?</p>
            <Link href="/register">✨ Register Now — It&apos;s Free</Link>
          </div>
        </div>

        {/* Back to home */}
        <Link href="/" className="back-link">
          ← Back to Home
        </Link>

      </div>
    </>
  );
}
