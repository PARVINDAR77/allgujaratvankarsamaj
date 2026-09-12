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
        backgroundColor: "rgba(13, 27, 50, 0.85)",
        backdropFilter: "blur(16px)",
        border: "1px solid rgba(212, 175, 55, 0.22)",
        padding: "14px 18px",
        borderRadius: "14px",
        display: "flex",
        alignItems: "center",
        gap: "14px",
        transition: "all 0.25s ease",
        textDecoration: "none",
        boxShadow: "0 6px 20px rgba(0,0,0,0.3)",
      }}
      className="group hover:bg-[#041026] hover:border-[#D4AF37] hover:shadow-[0_8px_25px_rgba(212,175,55,0.2)] hover:-translate-y-0.5"
    >
      <div
        style={{
          width: "40px",
          height: "40px",
          borderRadius: "12px",
          background: "linear-gradient(135deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
          color: "#041026",
          fontSize: "18px",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          fontWeight: 800,
          boxShadow: "0 4px 12px rgba(212, 175, 55, 0.3)",
          flexShrink: 0,
        }}
        className="group-hover:scale-105 transition-transform"
      >
        {icon}
      </div>
      <div style={{ minWidth: 0, flex: 1 }}>
        <h4
          style={{
            fontSize: "13px",
            fontWeight: 700,
            color: "#FFFFFF",
            lineHeight: 1.2,
          }}
          className="group-hover:text-[#F3E5AB] transition-colors truncate"
        >
          {title}
        </h4>
        <p
          style={{
            fontSize: "11px",
            color: "#8E9BAE",
            marginTop: "3px",
            fontWeight: 500,
            lineHeight: 1.3,
          }}
          className="truncate"
        >
          {description}
        </p>
      </div>
    </Link>
  );
};


