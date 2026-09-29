import React from "react";

interface StatCardProps {
  title: string;
  value: string | number;
  change: string;
  isPositive?: boolean;
  comparisonText?: string;
  icon: string;
}

export const StatCard: React.FC<StatCardProps> = ({
  title,
  value,
  change,
  isPositive = true,
  comparisonText = "vs last month",
  icon,
}) => {
  return (
    <div
<<<<<<< HEAD
      style={{
        background: "linear-gradient(145deg, rgba(13, 27, 50, 0.9) 0%, rgba(4, 12, 26, 0.95) 100%)",
        backdropFilter: "blur(20px)",
        border: "1px solid rgba(212, 175, 55, 0.3)",
        borderRadius: "20px",
        padding: "24px",
        boxShadow: "0 15px 35px rgba(0, 0, 0, 0.5), inset 0 1px 0 rgba(255, 255, 255, 0.1)",
        position: "relative",
        overflow: "hidden",
        transition: "all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275)",
        display: "flex",
        flexDirection: "column",
        justifyContent: "space-between",
        minHeight: "160px"
      }}
      className="group hover:border-[#D4AF37] hover:-translate-y-2 hover:shadow-[0_20px_40px_rgba(212,175,55,0.25)]"
=======
        style={{ padding: "20px 22px", transition: "all 0.3s ease" }} className="group hover:border-admin-gold hover:-translate-y-1 hover:shadow-[0_12px_35px_rgba(212,175,55,0.2)] overflow-hidden relative border border-admin-gold/25 rounded-2xl shadow-[0_10px_30px_rgba(0,0,0,0.4)] backdrop-blur-md bg-admin-bg-glass"
      
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
    >
      {/* Decorative background glow */}
      <div 
        style={{
          position: "absolute",
          top: "-30px",
          right: "-30px",
          width: "120px",
          height: "120px",
          background: "radial-gradient(circle, rgba(212, 175, 55, 0.15) 0%, rgba(0,0,0,0) 70%)",
          borderRadius: "50%",
          zIndex: 0
        }}
        className="group-hover:scale-150 transition-transform duration-500"
      />

      {/* Top gold line accent */}
      <div
<<<<<<< HEAD
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          width: "100%",
          height: "4px",
          background: "linear-gradient(90deg, #F3E5AB 0%, #D4AF37 50%, #8A6D1C 100%)",
        }}
        className="opacity-80 group-hover:opacity-100 transition-opacity"
      />

      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", zIndex: 1, position: "relative" }}>
        <div style={{ minWidth: 0, flex: 1, paddingRight: "12px" }}>
          <span
            style={{
              display: "flex",
              alignItems: "center",
              gap: "8px",
              fontSize: "12px",
              fontWeight: 800,
              color: "#AAB7C8",
              textTransform: "uppercase",
              letterSpacing: "1.5px",
              lineHeight: 1.2,
            }}
=======
         style={{ left: "20px", right: "20px", height: "2px", background: "linear-gradient(90deg, transparent 0%, #D4AF37 50%, transparent 100%)", opacity: 0.7 }} className="absolute top-0"
      />

      <div  className="flex justify-between items-start">
        <div  style={{ minWidth: 0, paddingRight: "12px" }} className="flex-1">
          <span
              style={{ display: "block", lineHeight: 1.2 }} className="font-bold uppercase text-admin-muted text-[11px] tracking-[1px]" 
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
          >
            <span style={{ display: "inline-block", width: "8px", height: "8px", borderRadius: "50%", backgroundColor: "#D4AF37", boxShadow: "0 0 8px #D4AF37" }}></span>
            {title}
          </span>
          <h3
<<<<<<< HEAD
            style={{
              fontSize: "36px",
              fontWeight: 900,
              color: "#FFFFFF",
              marginTop: "12px",
              letterSpacing: "-1px",
              lineHeight: 1,
              textShadow: "0 2px 10px rgba(0,0,0,0.5)"
            }}
            className="group-hover:text-[#F3E5AB] transition-colors truncate"
=======
             style={{ fontSize: "26px", marginTop: "6px", letterSpacing: "-0.5px", lineHeight: 1.1 }}
            className="group-hover:text-admin-gold-light transition-colors truncate font-extrabold text-white"
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
          >
            {typeof value === "number" ? value.toLocaleString() : value}
          </h3>
        </div>

        <div
<<<<<<< HEAD
          style={{
            width: "56px",
            height: "56px",
            borderRadius: "16px",
            background: "linear-gradient(135deg, rgba(212, 175, 55, 0.25) 0%, rgba(4, 16, 38, 0.95) 100%)",
            border: "1px solid rgba(212, 175, 55, 0.5)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: "26px",
            boxShadow: "0 8px 20px rgba(0,0,0,0.3), inset 0 2px 5px rgba(255, 255, 255, 0.15)",
            flexShrink: 0,
          }}
          className="group-hover:scale-110 group-hover:rotate-3 transition-all duration-300"
=======
            style={{ width: "44px", height: "44px", background: "linear-gradient(135deg, rgba(212, 175, 55, 0.2) 0%, rgba(4, 16, 38, 0.9) 100%)", fontSize: "20px", boxShadow: "inset 0 1px 3px rgba(255, 255, 255, 0.1)" }} className="group-hover:scale-105 transition-transform flex justify-center items-center shrink-0 rounded-xl border border-admin-gold/40"
          
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
        >
          {icon}
        </div>
      </div>

      <div
<<<<<<< HEAD
        style={{
          marginTop: "auto",
          paddingTop: "20px",
          display: "flex",
          alignItems: "center",
          gap: "10px",
          zIndex: 1,
          position: "relative"
        }}
      >
        <span
          style={{
            fontWeight: 900,
            fontSize: "13px",
            padding: "6px 12px",
            borderRadius: "8px",
            display: "inline-flex",
            alignItems: "center",
            gap: "4px",
            backgroundColor: isPositive ? "rgba(16, 185, 129, 0.15)" : "rgba(244, 63, 94, 0.15)",
            color: isPositive ? "#10B981" : "#F43F5E",
            border: isPositive ? "1px solid rgba(16, 185, 129, 0.4)" : "1px solid rgba(244, 63, 94, 0.4)",
            boxShadow: isPositive ? "0 0 10px rgba(16, 185, 129, 0.2)" : "0 0 10px rgba(244, 63, 94, 0.2)",
          }}
=======
         style={{ marginTop: "16px" }} className="flex items-center text-xs gap-2"
      >
        <span
           style={{ padding: "3px 10px", borderRadius: "20px", display: "inline-flex", gap: "3px", backgroundColor: isPositive ? "rgba(16, 185, 129, 0.15)" : "rgba(244, 63, 94, 0.15)", color: isPositive ? "#34D399" : "#FB7185", border: isPositive ? "1px solid rgba(16, 185, 129, 0.35)" : "1px solid rgba(244, 63, 94, 0.35)" }} className="items-center font-bold text-[11px]"
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
        >
          {isPositive ? "▲" : "▼"} {change}
        </span>
<<<<<<< HEAD
        <span style={{ color: "#8E9BAE", fontSize: "12px", fontWeight: 600 }}>
=======
        <span  className="font-medium text-admin-muted text-[11px]">
>>>>>>> 93bf45cfc2cb4b74070f9201707de81b6a1b0388
          {comparisonText}
        </span>
      </div>
    </div>
  );
};




