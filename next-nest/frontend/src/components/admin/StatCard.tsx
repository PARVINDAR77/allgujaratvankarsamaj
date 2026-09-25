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
        style={{ padding: "20px 22px", transition: "all 0.3s ease" }} className="group hover:border-admin-gold hover:-translate-y-1 hover:shadow-[0_12px_35px_rgba(212,175,55,0.2)] overflow-hidden relative border border-admin-gold/25 rounded-2xl shadow-[0_10px_30px_rgba(0,0,0,0.4)] backdrop-blur-md bg-admin-bg-glass"
      
    >
      {/* Top gold line accent */}
      <div
         style={{ left: "20px", right: "20px", height: "2px", background: "linear-gradient(90deg, transparent 0%, #D4AF37 50%, transparent 100%)", opacity: 0.7 }} className="absolute top-0"
      />

      <div  className="flex justify-between items-start">
        <div  style={{ minWidth: 0, paddingRight: "12px" }} className="flex-1">
          <span
              style={{ display: "block", lineHeight: 1.2 }} className="font-bold uppercase text-admin-muted text-[11px] tracking-[1px]" 
          >
            {title}
          </span>
          <h3
             style={{ fontSize: "26px", marginTop: "6px", letterSpacing: "-0.5px", lineHeight: 1.1 }}
            className="group-hover:text-admin-gold-light transition-colors truncate font-extrabold text-white"
          >
            {typeof value === "number" ? value.toLocaleString() : value}
          </h3>
        </div>

        <div
            style={{ width: "44px", height: "44px", background: "linear-gradient(135deg, rgba(212, 175, 55, 0.2) 0%, rgba(4, 16, 38, 0.9) 100%)", fontSize: "20px", boxShadow: "inset 0 1px 3px rgba(255, 255, 255, 0.1)" }} className="group-hover:scale-105 transition-transform flex justify-center items-center shrink-0 rounded-xl border border-admin-gold/40"
          
        >
          {icon}
        </div>
      </div>

      <div
         style={{ marginTop: "16px" }} className="flex items-center text-xs gap-2"
      >
        <span
           style={{ padding: "3px 10px", borderRadius: "20px", display: "inline-flex", gap: "3px", backgroundColor: isPositive ? "rgba(16, 185, 129, 0.15)" : "rgba(244, 63, 94, 0.15)", color: isPositive ? "#34D399" : "#FB7185", border: isPositive ? "1px solid rgba(16, 185, 129, 0.35)" : "1px solid rgba(244, 63, 94, 0.35)" }} className="items-center font-bold text-[11px]"
        >
          {isPositive ? "↑" : "↓"} {change}
        </span>
        <span  className="font-medium text-admin-muted text-[11px]">
          {comparisonText}
        </span>
      </div>
    </div>
  );
};




