import React from "react";

interface StatusBadgeProps {
  status: string;
}

export const StatusBadge: React.FC<StatusBadgeProps> = ({ status }) => {
  const normalized = (status || "").toUpperCase();

  let styles = "bg-gray-800 text-gray-300 border-gray-600";
  if (normalized === "ACTIVE" || normalized === "VERIFIED" || normalized === "SUCCESS" || normalized === "APPROVED") {
    styles = "bg-emerald-950/60 text-emerald-400 border-emerald-500/40";
  } else if (normalized === "PENDING" || normalized === "WARNING") {
    styles = "bg-amber-950/60 text-amber-400 border-amber-500/40";
  } else if (normalized === "INACTIVE" || normalized === "REJECTED" || normalized === "SUSPENDED" || normalized === "DELETED") {
    styles = "bg-rose-950/60 text-rose-400 border-rose-500/40";
  } else if (normalized === "INFO") {
    styles = "bg-sky-950/60 text-sky-400 border-sky-500/40";
  }

  return (
    <span className={`px-2.5 py-1 rounded-full text-[10px] font-bold tracking-wider uppercase border ${styles}`}>
      {status}
    </span>
  );
};
