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
        style={{ border: "1px solid rgba(212, 175, 55, 0.22)", borderRadius: "14px", transition: "all 0.25s ease", textDecoration: "none", boxShadow: "0 6px 20px rgba(0, 0, 0, 0.3)" }} className="group hover:bg-admin-card hover:border-admin-gold hover:shadow-[0_8px_25px_rgba(212,175,55,0.2)] hover:-translate-y-0.5 flex items-center py-[14px] px-[18px] gap-[14px] backdrop-blur-md bg-admin-bg-glass"
      
    >
      <div
          style={{ width: "40px", height: "40px", color: "#041026", fontSize: "18px", boxShadow: "0 4px 12px rgba(212, 175, 55, 0.3)" }} className="group-hover:scale-105 transition-transform flex justify-center items-center font-extrabold shrink-0 rounded-xl bg-gradient-to-br from-admin-gold via-admin-gold-light to-admin-gold-border"
        
      >
        {icon}
      </div>
      <div  style={{ minWidth: 0 }} className="flex-1">
        <h4
           style={{ lineHeight: 1.2 }}
          className="group-hover:text-admin-gold-light transition-colors truncate font-bold text-white text-[13px]"
        >
          {title}
        </h4>
        <p
           style={{ marginTop: "3px", lineHeight: 1.3 }}
          className="truncate font-medium text-admin-muted text-[11px]"
        >
          {description}
        </p>
      </div>
    </Link>
  );
};


