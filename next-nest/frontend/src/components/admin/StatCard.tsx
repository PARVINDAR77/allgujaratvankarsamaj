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
        background: "linear-gradient(145deg, rgba(13, 28, 54, 0.92) 0%, rgba(5, 13, 27, 0.96) 100%)",
        backdropFilter: "blur(20px)",
        border: "1px solid rgba(212, 175, 55, 0.28)",
        borderRadius: "20px",
        padding: "24px 22px",
        boxShadow: "0 15px 35px rgba(0, 0, 0, 0.55), inset 0 1px 0 rgba(255, 255, 255, 0.1)",
        position: "relative",
        overflow: "hidden",
        transition: "all 0.35s cubic-bezier(0.175, 0.885, 0.32, 1.275)",
        display: "flex",
        flexDirection: "column",
        justifyContent: "space-between",
        minHeight: "165px",
      }}
      className="group hover:border-[#D4AF37] hover:-translate-y-1.5 hover:shadow-[0_20px_40px_rgba(212,175,55,0.22)] cursor-default"
    >
      {/* Decorative top accent gold gradient bar */}
      <div
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          width: "100%",
          height: "3px",
          background: "linear-gradient(90deg, #F3E5AB 0%, #D4AF37 50%, #8A6D1C 100%)",
        }}
        className="opacity-90 group-hover:opacity-100 transition-opacity"
      />

      {/* Decorative subtle ambient corner glow */}
      <div
        style={{
          position: "absolute",
          top: "-30px",
          right: "-30px",
          width: "130px",
          height: "130px",
          background: "radial-gradient(circle, rgba(212, 175, 55, 0.18) 0%, rgba(0,0,0,0) 70%)",
          borderRadius: "50%",
          zIndex: 0,
          pointerEvents: "none",
        }}
        className="group-hover:scale-125 transition-transform duration-500"
      />

      {/* Card Content Row */}
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", zIndex: 1, position: "relative" }}>
        <div style={{ minWidth: 0, flex: 1, paddingRight: "10px" }}>
          {/* Title with Dot Indicator */}
          <span
            style={{
              display: "flex",
              alignItems: "center",
              gap: "7px",
              fontSize: "11.5px",
              fontWeight: 800,
              color: "#94A3B8",
              textTransform: "uppercase",
              letterSpacing: "1.3px",
              lineHeight: 1.2,
            }}
          >
            <span
              style={{
                display: "inline-block",
                width: "7px",
                height: "7px",
                borderRadius: "50%",
                backgroundColor: "#D4AF37",
                boxShadow: "0 0 8px #D4AF37",
              }}
            />
            {title}
          </span>

          {/* Metric Value */}
          <h3
            style={{
              fontSize: "34px",
              fontWeight: 900,
              color: "#FFFFFF",
              marginTop: "12px",
              letterSpacing: "-0.5px",
              lineHeight: 1,
              textShadow: "0 2px 12px rgba(0,0,0,0.6)",
            }}
            className="group-hover:text-[#F3E5AB] transition-colors truncate"
          >
            {typeof value === "number" ? value.toLocaleString() : value}
          </h3>
        </div>

        {/* Emblemed Icon Container */}
        <div
          style={{
            width: "54px",
            height: "54px",
            borderRadius: "16px",
            background: "linear-gradient(135deg, rgba(212, 175, 55, 0.25) 0%, rgba(4, 16, 38, 0.95) 100%)",
            border: "1.5px solid rgba(212, 175, 55, 0.5)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: "24px",
            boxShadow: "0 8px 22px rgba(0,0,0,0.35), inset 0 1px 3px rgba(255, 255, 255, 0.2)",
            flexShrink: 0,
          }}
          className="group-hover:scale-110 group-hover:rotate-3 transition-all duration-300"
        >
          {icon}
        </div>
      </div>

      {/* Comparison & Trend Pill Footer */}
      <div
        style={{
          marginTop: "auto",
          paddingTop: "18px",
          display: "flex",
          alignItems: "center",
          gap: "9px",
          zIndex: 1,
          position: "relative",
        }}
      >
        <span
          style={{
            fontWeight: 800,
            fontSize: "12px",
            padding: "5px 10px",
            borderRadius: "8px",
            display: "inline-flex",
            alignItems: "center",
            gap: "4px",
            backgroundColor: isPositive ? "rgba(16, 185, 129, 0.16)" : "rgba(244, 63, 94, 0.16)",
            color: isPositive ? "#34D399" : "#FB7185",
            border: isPositive ? "1px solid rgba(16, 185, 129, 0.4)" : "1px solid rgba(244, 63, 94, 0.4)",
            boxShadow: isPositive ? "0 0 10px rgba(16, 185, 129, 0.15)" : "0 0 10px rgba(244, 63, 94, 0.15)",
          }}
        >
          {isPositive ? "▲" : "▼"} {change}
        </span>
        <span style={{ color: "#8E9BAE", fontSize: "11.5px", fontWeight: 600 }}>
          {comparisonText}
        </span>
      </div>
    </div>
  );
};
