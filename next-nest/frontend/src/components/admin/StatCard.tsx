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
      style={{
        backgroundColor: "rgba(13, 27, 50, 0.85)",
        backdropFilter: "blur(16px)",
        border: "1px solid rgba(212, 175, 55, 0.25)",
        borderRadius: "16px",
        padding: "20px 22px",
        boxShadow: "0 10px 30px rgba(0, 0, 0, 0.4)",
        position: "relative",
        overflow: "hidden",
        transition: "all 0.3s ease",
      }}
      className="group hover:border-[#D4AF37] hover:-translate-y-1 hover:shadow-[0_12px_35px_rgba(212,175,55,0.2)]"
    >
      {/* Top gold line accent */}
      <div
        style={{
          position: "absolute",
          top: 0,
          left: "20px",
          right: "20px",
          height: "2px",
          background: "linear-gradient(90deg, transparent 0%, #D4AF37 50%, transparent 100%)",
          opacity: 0.7,
        }}
      />

      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
        <div style={{ minWidth: 0, flex: 1, paddingRight: "12px" }}>
          <span
            style={{
              display: "block",
              fontSize: "11px",
              fontWeight: 700,
              color: "#8E9BAE",
              textTransform: "uppercase",
              letterSpacing: "1px",
              lineHeight: 1.2,
            }}
          >
            {title}
          </span>
          <h3
            style={{
              fontSize: "26px",
              fontWeight: 800,
              color: "#FFFFFF",
              marginTop: "6px",
              letterSpacing: "-0.5px",
              lineHeight: 1.1,
            }}
            className="group-hover:text-[#F3E5AB] transition-colors truncate"
          >
            {typeof value === "number" ? value.toLocaleString() : value}
          </h3>
        </div>

        <div
          style={{
            width: "44px",
            height: "44px",
            borderRadius: "12px",
            background: "linear-gradient(135deg, rgba(212, 175, 55, 0.2) 0%, rgba(4, 16, 38, 0.9) 100%)",
            border: "1px solid rgba(212, 175, 55, 0.4)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: "20px",
            boxShadow: "inset 0 1px 3px rgba(255, 255, 255, 0.1)",
            flexShrink: 0,
          }}
          className="group-hover:scale-105 transition-transform"
        >
          {icon}
        </div>
      </div>

      <div
        style={{
          marginTop: "16px",
          display: "flex",
          alignItems: "center",
          gap: "8px",
          fontSize: "12px",
        }}
      >
        <span
          style={{
            fontWeight: 700,
            fontSize: "11px",
            padding: "3px 10px",
            borderRadius: "20px",
            display: "inline-flex",
            alignItems: "center",
            gap: "3px",
            backgroundColor: isPositive ? "rgba(16, 185, 129, 0.15)" : "rgba(244, 63, 94, 0.15)",
            color: isPositive ? "#34D399" : "#FB7185",
            border: isPositive ? "1px solid rgba(16, 185, 129, 0.35)" : "1px solid rgba(244, 63, 94, 0.35)",
          }}
        >
          {isPositive ? "↑" : "↓"} {change}
        </span>
        <span style={{ color: "#8E9BAE", fontSize: "11px", fontWeight: 500 }}>
          {comparisonText}
        </span>
      </div>
    </div>
  );
};




