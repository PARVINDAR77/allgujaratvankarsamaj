"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";

export default function Home() {
  const router = useRouter();

  useEffect(() => {
    router.replace("/admin/dashboard");
  }, [router]);

  return (
    <div
      style={{
        width: "100vw",
        height: "100vh",
        backgroundColor: "#061026",
        color: "#D4AF37",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        fontFamily: "sans-serif",
        fontSize: "14px",
        fontWeight: 700,
      }}
    >
      <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
        <span className="animate-spin" style={{ fontSize: "24px" }}>⚙️</span>
        <span>Redirecting to All Gujarat Vankar Samaj Admin Panel...</span>
      </div>
    </div>
  );
}

