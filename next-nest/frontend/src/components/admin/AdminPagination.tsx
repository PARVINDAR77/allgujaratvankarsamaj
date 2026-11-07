"use client";

import React from "react";

export interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
  hasNextPage?: boolean;
  hasPreviousPage?: boolean;
}

interface AdminPaginationProps {
  meta: PaginationMeta;
  onPageChange: (newPage: number) => void;
  isLoading?: boolean;
}

export const AdminPagination: React.FC<AdminPaginationProps> = ({
  meta,
  onPageChange,
  isLoading = false,
}) => {
  const { page, limit, total, totalPages } = meta;

  if (total === 0 || totalPages <= 1) {
    return null;
  }

  const startItem = Math.min((page - 1) * limit + 1, total);
  const endItem = Math.min(page * limit, total);

  // Generate page numbers with ellipsis
  const getPageNumbers = () => {
    const pages: (number | string)[] = [];
    const maxVisible = 5;

    if (totalPages <= maxVisible + 2) {
      for (let i = 1; i <= totalPages; i++) {
        pages.push(i);
      }
    } else {
      pages.push(1);
      const leftBound = Math.max(2, page - 1);
      const rightBound = Math.min(totalPages - 1, page + 1);

      if (leftBound > 2) {
        pages.push("...");
      }

      for (let i = leftBound; i <= rightBound; i++) {
        pages.push(i);
      }

      if (rightBound < totalPages - 1) {
        pages.push("...");
      }

      pages.push(totalPages);
    }

    return pages;
  };

  return (
    <div className="flex flex-col sm:flex-row items-center justify-between gap-4 mt-6 p-4 rounded-xl border border-admin-gold/30 bg-[#09152b]/90 backdrop-blur-md shadow-lg">
      <div className="text-xs text-slate-300 font-medium">
        Showing <span className="text-admin-gold font-bold">{startItem}</span> to{" "}
        <span className="text-admin-gold font-bold">{endItem}</span> of{" "}
        <span className="text-admin-gold font-bold">{total}</span> records
        <span className="ml-2 text-[10px] text-slate-400 bg-black/40 px-2 py-0.5 rounded-full border border-admin-gold/20">
          (15 per page)
        </span>
      </div>

      <div className="flex items-center gap-1.5 flex-wrap">
        <button
          onClick={() => onPageChange(page - 1)}
          disabled={page <= 1 || isLoading}
          className={`px-3 py-1.5 rounded-lg text-xs font-semibold flex items-center gap-1 border transition-all ${
            page <= 1 || isLoading
              ? "border-slate-800 text-slate-600 bg-slate-900/30 cursor-not-allowed"
              : "border-admin-gold/40 text-admin-gold bg-[#0d1d3a] hover:bg-admin-gold hover:text-black cursor-pointer shadow-sm active:scale-95"
          }`}
          title="Previous 15 records"
        >
          <span>←</span>
          <span>Previous (પાછળ)</span>
        </button>

        <div className="flex items-center gap-1 px-1">
          {getPageNumbers().map((p, idx) => {
            if (p === "...") {
              return (
                <span key={`ellipsis-${idx}`} className="px-2 text-slate-500 text-xs">
                  ...
                </span>
              );
            }

            const pageNum = Number(p);
            const isActive = pageNum === page;

            return (
              <button
                key={pageNum}
                onClick={() => onPageChange(pageNum)}
                disabled={isActive || isLoading}
                className={`min-w-8 h-8 px-2 rounded-lg text-xs font-bold transition-all ${
                  isActive
                    ? "bg-gradient-to-r from-amber-500 to-amber-600 text-black shadow-md shadow-amber-500/20 cursor-default"
                    : "border border-admin-gold/20 text-slate-300 hover:border-admin-gold/60 hover:text-white bg-[#061022]"
                }`}
              >
                {pageNum}
              </button>
            );
          })}
        </div>

        <button
          onClick={() => onPageChange(page + 1)}
          disabled={page >= totalPages || isLoading}
          className={`px-3 py-1.5 rounded-lg text-xs font-semibold flex items-center gap-1 border transition-all ${
            page >= totalPages || isLoading
              ? "border-slate-800 text-slate-600 bg-slate-900/30 cursor-not-allowed"
              : "border-admin-gold/40 text-admin-gold bg-[#0d1d3a] hover:bg-admin-gold hover:text-black cursor-pointer shadow-sm active:scale-95"
          }`}
          title="Next 15 records"
        >
          <span>Next 15 (આગળની 15)</span>
          <span>→</span>
        </button>
      </div>
    </div>
  );
};

