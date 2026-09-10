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
    <div className="bg-[#0F2040] border border-[#997D20]/30 hover:border-[#D4AF37] rounded-2xl p-5 transition-all duration-300 shadow-xl group hover:transform hover:-translate-y-1">
      <div className="flex justify-between items-start">
        <div>
          <p className="text-xs font-semibold text-[#AAB7C8] uppercase tracking-wider">
            {title}
          </p>
          <h3 className="text-2xl lg:text-3xl font-extrabold text-white mt-2 group-hover:text-[#D4AF37] transition-colors">
            {typeof value === "number" ? value.toLocaleString() : value}
          </h3>
        </div>

        <div className="w-12 h-12 rounded-xl bg-[#041026] border border-[#997D20]/40 flex items-center justify-center text-2xl shadow-inner">
          {icon}
        </div>
      </div>

      <div className="mt-4 flex items-center gap-2 text-xs">
        <span
          className={`font-bold flex items-center gap-0.5 px-2 py-0.5 rounded ${
            isPositive
              ? "bg-green-500/10 text-green-400 border border-green-500/20"
              : "bg-red-500/10 text-red-400 border border-red-500/20"
          }`}
        >
          {isPositive ? "↑" : "↓"} {change}
        </span>
        <span className="text-[#AAB7C8]/70 text-[11px]">{comparisonText}</span>
      </div>
    </div>
  );
};
