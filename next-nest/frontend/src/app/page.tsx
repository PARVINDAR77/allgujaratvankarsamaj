"use client";

import Image from "next/image";

export default function Home() {
  return (
    <>
      <style>{`
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

        html, body {
          width: 100%;
          min-height: 100vh;
          background: #060b06;
          overflow-x: hidden;
          display: flex;
          flex-direction: column;
          align-items: center;
        }

        .poster-wrap {
          position: relative;
          width: 100%;
          max-width: 760px;
          margin: 0 auto;
          background: #060b06;
          box-shadow: 0 0 50px rgba(0, 0, 0, 0.9), 0 0 30px rgba(212, 175, 55, 0.15);
        }

        .poster-inner {
          position: relative;
          width: 100%;
          line-height: 0;
        }

        .poster-img {
          display: block;
          width: 100%;
          height: auto;
        }

        /* ── INTERACTIVE HOTSPOTS ── */
        .ov {
          position: absolute;
          cursor: pointer;
          text-decoration: none;
          background: rgba(212, 175, 55, 0);
          transition: all 0.25s ease-in-out;
          z-index: 10;
        }

        .ov:hover {
          background: rgba(212, 175, 55, 0.15);
          box-shadow: 0 0 20px rgba(255, 224, 102, 0.6), inset 0 0 15px rgba(255, 224, 102, 0.3);
          border: 2px solid #FFE066;
        }

        /* ── LOGIN button ── */
        .ov-login {
          left: 18.2%;
          top: 83.5%;
          width: 31.5%;
          height: 5.4%;
          border-radius: 50px;
        }

        /* ── REGISTRATION button ── */
        .ov-register {
          left: 50.3%;
          top: 83.5%;
          width: 31.5%;
          height: 5.4%;
          border-radius: 50px;
        }

        /* ── 5 SERVICE OVALS ── */
        .ov-govt {
          left: 1.5%;
          top: 53.8%;
          width: 18.5%;
          height: 21.2%;
          border-radius: 50%;
        }

        .ov-matri {
          left: 21.2%;
          top: 53.8%;
          width: 18.5%;
          height: 21.2%;
          border-radius: 50%;
        }

        .ov-job {
          left: 40.8%;
          top: 53.8%;
          width: 18.5%;
          height: 21.2%;
          border-radius: 50%;
        }

        .ov-svc {
          left: 60.5%;
          top: 53.8%;
          width: 18.5%;
          height: 21.2%;
          border-radius: 50%;
        }

        .ov-std {
          left: 80.2%;
          top: 53.8%;
          width: 18.5%;
          height: 21.2%;
          border-radius: 50%;
        }
      `}</style>

      <div className="poster-wrap">
        <div className="poster-inner">

          {/* ── Full poster image ── */}
          <Image
            src="/vankar-samaj-banner.jpg"
            alt="All Gujarat Vankar Samaj – Portal"
            width={1000}
            height={1485}
            priority
            className="poster-img"
          />

          {/* ── LOGIN ── */}
          <a href="/login" className="ov ov-login" id="btn-login" aria-label="Login" />

          {/* ── REGISTRATION ── */}
          <a href="/register" className="ov ov-register" id="btn-register" aria-label="Register" />

          {/* ── GOVERNMENT EMPLOYEES ── */}
          <a href="/services" className="ov ov-govt" aria-label="Government Employees" />

          {/* ── MATRIMONY ── */}
          <a href="/matrimony" className="ov ov-matri" aria-label="Matrimony – Find Your Life Partner" />

          {/* ── PRIVATE JOB ── */}
          <a href="/services" className="ov ov-job" aria-label="Private Job Opportunities" />

          {/* ── VANKAR SAMAJ SERVICES ── */}
          <a href="/services" className="ov ov-svc" aria-label="Vankar Samaj Services" />

          {/* ── STUDENTS (12+) ── */}
          <a href="/services" className="ov ov-std" aria-label="Students 12+" />

        </div>
      </div>
    </>
  );
}
