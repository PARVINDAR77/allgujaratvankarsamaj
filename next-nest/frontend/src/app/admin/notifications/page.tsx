"use client";

import React, { useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";

export default function AdminNotificationsPage() {
  const [title, setTitle] = useState("");
  const [message, setMessage] = useState("");
  const [audience, setAudience] = useState("ALL");
  const [sent, setSent] = useState(false);

  const handleSend = (e: React.FormEvent) => {
    e.preventDefault();
    setSent(true);
    setTimeout(() => {
      setTitle("");
      setMessage("");
      setSent(false);
    }, 3000);
  };

  return (
    <AdminLayout title="Notification Manager" subtitle="Broadcast mobile & push notifications to community members">
      <div className="max-w-2xl bg-[#0F2040] border border-[#997D20]/30 rounded-2xl p-6 shadow-xl space-y-6">
        <h3 className="text-base font-bold text-white">Create Broadcast Notification</h3>

        {sent && (
          <div className="p-3 rounded-xl bg-emerald-950/80 border border-emerald-500/40 text-emerald-400 text-xs font-bold">
            ✓ Broadcast notification dispatched successfully!
          </div>
        )}

        <form onSubmit={handleSend} className="space-y-4 text-xs">
          <div>
            <label className="block text-[#AAB7C8] font-bold uppercase mb-1">Target Audience</label>
            <select
              value={audience}
              onChange={(e) => setAudience(e.target.value)}
              className="w-full bg-[#041026] border border-[#997D20]/40 rounded-xl px-4 py-2.5 text-white focus:outline-none focus:border-[#D4AF37]"
            >
              <option value="ALL">All Registered Members</option>
              <option value="35">35 Pargana Members</option>
              <option value="27">27 Pargana Members</option>
              <option value="16">16 Pargana Members</option>
              <option value="14">14 Pargana Members</option>
              <option value="VERIFIED">Verified Profiles Only</option>
            </select>
          </div>

          <div>
            <label className="block text-[#AAB7C8] font-bold uppercase mb-1">Notification Title</label>
            <input
              type="text"
              required
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              placeholder="e.g. New Profiles Verified in your Pargana"
              className="w-full bg-[#041026] border border-[#997D20]/40 rounded-xl px-4 py-2.5 text-white focus:outline-none focus:border-[#D4AF37]"
            />
          </div>

          <div>
            <label className="block text-[#AAB7C8] font-bold uppercase mb-1">Message Body</label>
            <textarea
              rows={4}
              required
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              placeholder="Enter message text..."
              className="w-full bg-[#041026] border border-[#997D20]/40 rounded-xl px-4 py-2.5 text-white focus:outline-none focus:border-[#D4AF37]"
            />
          </div>

          <button
            type="submit"
            className="w-full py-3 rounded-xl bg-gradient-to-r from-[#D4AF37] to-[#E8C95A] text-black font-extrabold uppercase shadow-lg hover:opacity-95"
          >
            📢 Send Broadcast Notification
          </button>
        </form>
      </div>
    </AdminLayout>
  );
}
