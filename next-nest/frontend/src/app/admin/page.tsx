"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";

export default function AdminPage() {
  const router = useRouter();

  useEffect(() => {
    router.replace("/admin/dashboard");
  }, [router]);

  return (
    <div style={{ minHeight: "100vh", backgroundColor: "#061224", display: "flex", justifyContent: "center", alignItems: "center", color: "#D4AF37", fontFamily: "'Inter', sans-serif" }}>
      <p>Redirecting to Admin Dashboard...</p>
    </div>
  );
}
