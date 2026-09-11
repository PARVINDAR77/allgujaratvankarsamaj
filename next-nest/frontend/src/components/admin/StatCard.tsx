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
    <div className="bg-[#0B172A]/95 backdrop-blur-xl border border-[#997D20]/40 hover:border-[#D4AF37] rounded-2xl pt-7 pb-6 px-6 transition-all duration-300 shadow-[0_10px_30px_rgba(0,0,0,0.5)] hover:shadow-[0_10px_35px_rgba(212,175,55,0.25)] group hover:-translate-y-1 relative">
      {/* Top gold line accent */}
      <div className="absolute top-0 left-6 right-6 h-[2px] bg-gradient-to-r from-transparent via-[#D4AF37] to-transparent opacity-70 group-hover:opacity-100 transition-opacity" />

      <div className="flex justify-between items-start pt-1">
        <div className="min-w-0 pr-2">
          <span className="block text-xs font-bold text-[#AAB7C8] uppercase tracking-widest leading-relaxed">
            {title}
          </span>
          <h3 className="text-2xl lg:text-3xl font-black text-white mt-2 group-hover:text-[#F3E5AB] transition-colors tracking-tight truncate">
            {typeof value === "number" ? value.toLocaleString() : value}
          </h3>
        </div>

        <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-[#041026] to-[#0D1E3A] border border-[#D4AF37]/50 flex items-center justify-center text-2xl shadow-inner group-hover:scale-110 group-hover:border-[#D4AF37] transition-all shrink-0">
          {icon}
        </div>
      </div>

      <div className="mt-5 flex items-center gap-2 text-xs">
        <span
          className={`font-black flex items-center gap-1 px-2.5 py-0.5 rounded-full text-[11px] ${
            isPositive
              ? "bg-emerald-500/15 text-emerald-300 border border-emerald-500/40"
              : "bg-rose-500/15 text-rose-300 border border-rose-500/40"
          }`}
        >
          {isPositive ? "↑" : "↓"} {change}
        </span>
        <span className="text-[#AAB7C8]/80 text-[11px] font-medium">{comparisonText}</span>
      </div>
    </div>
  );
};



