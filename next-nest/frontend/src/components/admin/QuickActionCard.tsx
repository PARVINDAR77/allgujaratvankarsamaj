import React from "react";
import Link from "next/link";

interface QuickActionCardProps {
  title: string;
  description: string;
  icon: string;
  href: string;
}

export const QuickActionCard: React.FC<QuickActionCardProps> = ({
  title,
  description,
  icon,
  href,
}) => {
  return (
    <Link
      href={href}
      style={{
        border: "1px solid rgba(212, 175, 55, 0.22)",
        borderRadius: "16px",
        transition: "all 0.25s cubic-bezier(0.4, 0, 0.2, 1)",
        textDecoration: "none",
        boxShadow: "0 6px 20px rgba(0, 0, 0, 0.35)",
        backgroundColor: "rgba(11, 25, 48, 0.75)",
        backdropFilter: "blur(16px)",
      }}
      className="group hover:bg-[#0E2242] hover:border-[#D4AF37] hover:shadow-[0_10px_25px_rgba(212,175,55,0.2)] hover:-translate-y-1 flex items-center py-4 px-4.5 gap-3.5"
    >
      <div
        style={{
          width: "44px",
          height: "44px",
          color: "#041026",
          fontSize: "20px",
          boxShadow: "0 4px 14px rgba(212, 175, 55, 0.35)",
          background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
        }}
        className="group-hover:scale-105 transition-transform flex justify-center items-center font-black shrink-0 rounded-xl"
      >
        {icon}
      </div>

      <div style={{ minWidth: 0 }} className="flex-1">
        <h4
          style={{ lineHeight: 1.25, color: "#FFFFFF" }}
          className="group-hover:text-[#F3E5AB] transition-colors truncate font-bold text-sm"
        >
          {title}
        </h4>
        <p
          style={{ marginTop: "3px", lineHeight: 1.3, color: "#94A3B8" }}
          className="truncate font-medium text-xs"
        >
          {description}
        </p>
      </div>

      <div className="text-[#D4AF37] opacity-60 group-hover:opacity-100 group-hover:translate-x-1 transition-all text-sm font-black shrink-0">
        →
      </div>
    </Link>
  );
};
