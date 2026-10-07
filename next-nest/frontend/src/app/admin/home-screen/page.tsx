"use client";

import { useState, useEffect } from "react";
import { fetchFromBackend } from "@/lib/api";
import { AdminLayout } from "@/components/admin/AdminLayout";

export default function HomeScreenConfigPage() {
  const [configs, setConfigs] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);

  const routeOptions = [
    { label: "Samaj Ratna", value: "/samaj-ratna" },
    { label: "Advertisement", value: "/advertisement" },
    { label: "Live Counter", value: "/statistics" },
    { label: "Happy Birthday", value: "/birthdays" },
    { label: "Advanced Search", value: "/advanced-search" },
    { label: "Verified Profile", value: "/verified-profile" },
    { label: "Create Profile", value: "/profile/create" },
  ];

  useEffect(() => {
    fetchConfigs();
  }, []);

  const fetchConfigs = async () => {
    setIsLoading(true);
    try {
      const res = await fetchFromBackend("/home-buttons");
      if (res.statusCode === 200) {
        setConfigs(res.data?.data || []);
      } else {
        alert("Failed to load configs");
      }
    } catch (e) {
      alert("Error loading configs");
    }
    setIsLoading(false);
  };



  const handleSave = async () => {
    setIsSaving(true);
    try {
      const token = localStorage.getItem("adminToken") || localStorage.getItem("token") || "";
      const url = process.env.NEXT_PUBLIC_API_URL || "/api/v1";
      const response = await fetch(`${url}/admin/home-buttons`, {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${token}`
        },
        body: JSON.stringify(configs)
      });
      
      if (response.ok) {
        alert("Home screen configurations saved successfully!");
      } else {
        const errText = await response.text();
        alert(`Failed to save configurations (Status: ${response.status})\n\nResponse: ${errText}`);
      }
    } catch (e: any) {
      alert(`Error saving configurations: ${e.message}`);
    }
    setIsSaving(false);
  };

  if (isLoading) return (
    <AdminLayout title="Home Screen Management">
      <div style={{ padding: "60px", textAlign: "center", display: "flex", flexDirection: "column", alignItems: "center", gap: "16px" }}>
        <div style={{ width: "40px", height: "40px", border: "3px solid #D4AF37", borderTopColor: "transparent", borderRadius: "50%" }} className="animate-spin"></div>
        <p style={{ color: "#D4AF37", fontSize: "14px", fontWeight: 800, textTransform: "uppercase", letterSpacing: "2px", margin: 0 }}>Loading configurations...</p>
      </div>
    </AdminLayout>
  );

  return (
    <AdminLayout title="Home Screen Management">
      <div style={{ display: "flex", flexDirection: "column", gap: "28px", paddingBottom: "48px" }}>
        {/* Header */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <div>
            <h1 style={{ fontSize: "28px", fontWeight: "900", color: "#FFFFFF", margin: "0 0 8px 0", display: "flex", alignItems: "center", gap: "12px", letterSpacing: "-0.5px" }}>
              <span style={{ filter: "drop-shadow(0 0 8px rgba(212,175,55,0.8))" }}>📱</span> 
              Home Screen Management
            </h1>
            <p style={{ color: "#8E9BAE", fontSize: "14px", margin: 0, fontWeight: 500 }}>
              Manage the routes and appearance for the 5 bottom buttons on the Flutter App Home Screen.
            </p>
          </div>
        </div>
        
        {/* Dynamic Bottom Buttons block */}
        <div 
          style={{ 
            background: "linear-gradient(145deg, rgba(13, 27, 50, 0.9) 0%, rgba(4, 12, 26, 0.95) 100%)",
            backdropFilter: "blur(20px)",
            borderRadius: "16px", 
            border: "1px solid rgba(212, 175, 55, 0.3)", 
            overflow: "hidden",
            boxShadow: "0 10px 30px rgba(0, 0, 0, 0.4), inset 0 1px 0 rgba(255, 255, 255, 0.05)"
          }}
        >
          <div style={{ padding: "20px 24px", borderBottom: "1px solid rgba(212, 175, 55, 0.2)", background: "rgba(4, 16, 38, 0.6)" }}>
            <h2 style={{ margin: 0, fontSize: "18px", fontWeight: 800, color: "#D4AF37", textTransform: "uppercase", letterSpacing: "1px" }}>Dynamic Bottom Buttons (Appearance)</h2>
          </div>
          <div style={{ padding: "24px", display: "flex", flexDirection: "column", gap: "16px" }}>
            {configs.map((config, i) => (
              <div key={config.buttonId} style={{ display: "flex", gap: "20px", alignItems: "center", padding: "16px 20px", background: "rgba(13, 27, 50, 0.5)", border: "1px solid rgba(255,255,255,0.05)", borderRadius: "12px" }}>
                
                {/* Number circle */}
                <div style={{ width: "48px", height: "48px", borderRadius: "50%", background: "linear-gradient(135deg, rgba(212,175,55,0.2) 0%, rgba(243,229,171,0.05) 100%)", border: "1px solid rgba(212,175,55,0.5)", color: "#D4AF37", display: "flex", alignItems: "center", justifyContent: "center", fontSize: "18px", fontWeight: 900, flexShrink: 0 }}>
                  {config.buttonId}
                </div>

                {/* Inputs */}
                <div style={{ flex: 1, display: "flex", flexDirection: "column", gap: "12px" }}>
                  <div style={{ display: "flex", flexDirection: "column", gap: "6px" }}>
                    <label style={{ fontSize: "11px", color: "#8E9BAE", fontWeight: 700, textTransform: "uppercase", letterSpacing: "1px" }}>Title</label>
                    <input 
                      type="text" 
                      value={config.title} 
                      onChange={(e) => {
                        const newConfigs = [...configs];
                        newConfigs[i].title = e.target.value;
                        setConfigs(newConfigs);
                      }}
                      style={{
                        width: "100%",
                        background: "rgba(4, 16, 38, 0.8)",
                        border: "1px solid rgba(212, 175, 55, 0.3)",
                        borderRadius: "8px",
                        padding: "10px 14px",
                        color: "#FFFFFF",
                        fontSize: "15px",
                        fontWeight: 700,
                        outline: "none",
                        transition: "all 0.3s ease",
                      }}
                      onFocus={(e) => { e.target.style.borderColor = "#D4AF37"; e.target.style.boxShadow = "0 0 10px rgba(212,175,55,0.2)"; }}
                      onBlur={(e) => { e.target.style.borderColor = "rgba(212, 175, 55, 0.3)"; e.target.style.boxShadow = "none"; }}
                    />
                  </div>
                  <div style={{ display: "flex", flexDirection: "column", gap: "6px" }}>
                    <label style={{ fontSize: "11px", color: "#8E9BAE", fontWeight: 700, textTransform: "uppercase", letterSpacing: "1px" }}>Subtitle</label>
                    <input 
                      type="text" 
                      value={config.subtitle} 
                      onChange={(e) => {
                        const newConfigs = [...configs];
                        newConfigs[i].subtitle = e.target.value;
                        setConfigs(newConfigs);
                      }}
                      style={{
                        width: "100%",
                        background: "rgba(4, 16, 38, 0.5)",
                        border: "1px solid rgba(255, 255, 255, 0.1)",
                        borderRadius: "8px",
                        padding: "8px 12px",
                        color: "#CBD5E1",
                        fontSize: "13px",
                        outline: "none",
                        transition: "all 0.3s ease",
                      }}
                      onFocus={(e) => { e.target.style.borderColor = "rgba(212,175,55,0.4)"; }}
                      onBlur={(e) => { e.target.style.borderColor = "rgba(255, 255, 255, 0.1)"; }}
                    />
                  </div>
                </div>

                {/* Destination & Action */}
                <div style={{ width: "220px", display: "flex", flexDirection: "column", gap: "12px", justifyContent: "center" }}>
                  <div style={{ display: "flex", flexDirection: "column", gap: "6px" }}>
                    <label style={{ fontSize: "11px", color: "#8E9BAE", fontWeight: 700, textTransform: "uppercase", letterSpacing: "1px" }}>Destination Route</label>
                    <input 
                      type="text" 
                      value={config.route} 
                      onChange={(e) => {
                        const newConfigs = [...configs];
                        newConfigs[i].route = e.target.value;
                        setConfigs(newConfigs);
                      }}
                      style={{
                        padding: "10px 14px", 
                        background: "rgba(0,0,0,0.3)", 
                        borderRadius: "8px", 
                        border: "1px solid rgba(255,255,255,0.2)", 
                        color: "#FFFFFF", 
                        fontSize: "13px", 
                        fontWeight: 600,
                        outline: "none",
                        transition: "all 0.3s ease"
                      }}
                      onFocus={(e) => { e.target.style.borderColor = "#D4AF37"; }}
                      onBlur={(e) => { e.target.style.borderColor = "rgba(255, 255, 255, 0.2)"; }}
                    />
                  </div>
                  
                  {(config.route.includes("/samaj-ratna") || config.route.includes("/advertisement") || config.route.includes("/education")) && (
                    <a 
                      href={config.route.includes("/samaj-ratna") ? "/admin/samaj-ratna" : config.route.includes("/education") ? "/admin/education" : `/admin/advertisements${config.route.includes("?") ? config.route.substring(config.route.indexOf("?")) : ""}`}
                      style={{
                        textAlign: "center",
                        padding: "8px 12px",
                        background: "rgba(59, 130, 246, 0.15)",
                        color: "#60A5FA",
                        border: "1px solid rgba(59, 130, 246, 0.3)",
                        borderRadius: "8px",
                        fontSize: "12px",
                        fontWeight: 700,
                        textDecoration: "none",
                        transition: "all 0.2s"
                      }}
                      onMouseOver={(e) => e.currentTarget.style.background = "rgba(59, 130, 246, 0.25)"}
                      onMouseOut={(e) => e.currentTarget.style.background = "rgba(59, 130, 246, 0.15)"}
                    >
                      Manage Content
                    </a>
                  )}
                </div>
              </div>
            ))}

            <div style={{ display: "flex", justifyContent: "flex-end", marginTop: "16px" }}>
              <button 
                onClick={handleSave} 
                disabled={isSaving} 
                style={{
                  background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
                  color: "#041026",
                  border: "none",
                  padding: "12px 32px",
                  borderRadius: "12px",
                  fontWeight: 900,
                  fontSize: "14px",
                  cursor: isSaving ? "not-allowed" : "pointer",
                  opacity: isSaving ? 0.7 : 1,
                  boxShadow: "0 6px 20px rgba(212, 175, 55, 0.4)",
                  textTransform: "uppercase",
                  letterSpacing: "1px",
                  transition: "all 0.3s"
                }}
              >
                {isSaving ? "Saving..." : "Save Appearance"}
              </button>
            </div>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
