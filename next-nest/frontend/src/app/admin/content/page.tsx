"use client";

import React from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";

export default function AdminContentPage() {
  return (
    <AdminLayout title="Pages & CMS Content" subtitle="Manage static pages, FAQs, Terms, and Samaj Announcements">
      <div className="space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="bg-[#0F2040] border border-[#997D20]/30 rounded-2xl p-6 shadow-xl space-y-4">
            <h3 className="text-base font-bold text-white">Public Application Pages</h3>
            <div className="space-y-2">
              {["Terms & Conditions", "Privacy Policy", "Samaj Rules & Guidelines", "Frequently Asked Questions (FAQs)", "About Vankar Samaj Matrimony"].map((p, idx) => (
                <div key={idx} className="flex justify-between items-center p-3 rounded-xl bg-[#041026] border border-[#997D20]/20 text-xs">
                  <span className="font-semibold text-white">{p}</span>
                  <button className="px-3 py-1 rounded bg-[#0F2040] border border-[#997D20]/40 text-[#D4AF37] font-bold hover:bg-[#D4AF37] hover:text-black">
                    Edit Page
                  </button>
                </div>
              ))}
            </div>
          </div>

          <div className="bg-[#0F2040] border border-[#997D20]/30 rounded-2xl p-6 shadow-xl space-y-4">
            <h3 className="text-base font-bold text-white">Homepage Announcements</h3>
            <div className="space-y-3 text-xs text-[#AAB7C8]">
              <div className="p-3 rounded-xl bg-[#041026] border border-[#997D20]/20 space-y-1">
                <h4 className="font-bold text-[#D4AF37]">Upcoming Vankar Samaj Matrimonial Sammelan 2026</h4>
                <p>Annual youth introduction fair scheduled in Ahmedabad next month.</p>
                <span className="text-[10px] text-gray-400">Published: 2 days ago</span>
              </div>
              <button className="w-full py-2.5 rounded-xl bg-gradient-to-r from-[#D4AF37] to-[#E8C95A] text-black font-bold uppercase shadow-md">
                + Create New Announcement
              </button>
            </div>
          </div>
        </div>
      </div>
    </AdminLayout>
  );
}
