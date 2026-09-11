import React from "react";

interface StatusBadgeProps {
  status: string;
}

export const StatusBadge: React.FC<StatusBadgeProps> = ({ status }) => {
  const normalized = (status || "").toUpperCase();

  let styles = "bg-gray-900/80 text-gray-300 border-gray-600/50";
  let dotColor = "bg-gray-400";

  if (normalized === "ACTIVE" || normalized === "VERIFIED" || normalized === "SUCCESS" || normalized === "APPROVED") {
    styles = "bg-emerald-950/80 text-emerald-300 border-emerald-500/50 shadow-[0_0_10px_rgba(16,185,129,0.2)]";
    dotColor = "bg-emerald-400";
  } else if (normalized === "PENDING" || normalized === "WARNING") {
    styles = "bg-amber-950/80 text-amber-300 border-amber-500/50 shadow-[0_0_10px_rgba(245,158,11,0.2)]";
    dotColor = "bg-amber-400 animate-pulse";
  } else if (normalized === "INACTIVE" || normalized === "REJECTED" || normalized === "SUSPENDED" || normalized === "DELETED") {
    styles = "bg-rose-950/80 text-rose-300 border-rose-500/50 shadow-[0_0_10px_rgba(244,63,94,0.2)]";
    dotColor = "bg-rose-400";
  } else if (normalized === "INFO") {
    styles = "bg-sky-950/80 text-sky-300 border-sky-500/50 shadow-[0_0_10px_rgba(56,189,248,0.2)]";
    dotColor = "bg-sky-400";
  }

  return (
    <span className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[10px] font-black tracking-wider uppercase border ${styles}`}>
      <span className={`w-1.5 h-1.5 rounded-full ${dotColor}`} />
      <span>{status}</span>
    </span>
  );
};
