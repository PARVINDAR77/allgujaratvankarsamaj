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
      className="bg-[#0D1B32]/90 backdrop-blur-xl border border-[#997D20]/40 hover:border-[#D4AF37] p-4 rounded-2xl flex items-center gap-4 transition-all duration-300 group hover:bg-[#041026] shadow-lg hover:shadow-[0_8px_25px_rgba(212,175,55,0.2)] hover:-translate-y-0.5"
    >
      <div className="w-11 h-11 rounded-xl bg-gradient-to-tr from-[#D4AF37] via-[#F3E5AB] to-[#E8C95A] text-black text-xl flex items-center justify-center font-black shadow-md group-hover:scale-110 group-hover:rotate-3 transition-transform shrink-0">
        {icon}
      </div>
      <div className="min-w-0">
        <h4 className="text-xs font-extrabold text-white group-hover:text-[#F3E5AB] transition-colors truncate">
          {title}
        </h4>
        <p className="text-[11px] text-[#AAB7C8] mt-0.5 font-medium leading-tight truncate">{description}</p>
      </div>
    </Link>
  );
};

