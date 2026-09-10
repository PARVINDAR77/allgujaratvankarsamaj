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
      className="bg-[#0F2040] border border-[#997D20]/30 hover:border-[#D4AF37] p-4 rounded-xl flex items-center gap-4 transition-all duration-300 group hover:bg-[#041026]"
    >
      <div className="w-10 h-10 rounded-lg bg-gradient-to-tr from-[#D4AF37] to-[#E8C95A] text-black text-xl flex items-center justify-center font-bold shadow-md group-hover:scale-110 transition-transform">
        {icon}
      </div>
      <div>
        <h4 className="text-sm font-bold text-white group-hover:text-[#D4AF37] transition-colors">
          {title}
        </h4>
        <p className="text-[11px] text-[#AAB7C8]/70 mt-0.5">{description}</p>
      </div>
    </Link>
  );
};
