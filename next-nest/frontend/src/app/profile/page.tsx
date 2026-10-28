"use client";

import React, { useState, useEffect } from "react";
import Image from "next/image";
import Link from "next/link";
import { useRouter } from "next/navigation";

interface UserProfile {
  fullName: string;
  email: string;
  phone: string;
  fullPhotoUrl?: string | null;
  isVerified: boolean;
  isPhoneVerified?: boolean;
  isEmailVerified?: boolean;
  nativePlace?: string;
  pargana?: string;
  education?: string;
  occupation?: string;
  bio?: string;
}

export default function MyProfilePage() {
  const router = useRouter();

  // Profile data state
  const [profile, setProfile] = useState<UserProfile>({
    fullName: "",
    email: "",
    phone: "",
    fullPhotoUrl: null,
    isVerified: false,
    isPhoneVerified: false,
    isEmailVerified: false,
    nativePlace: "",
    pargana: "",
    education: "",
    occupation: "",
    bio: "",
  });

  const [isLoading, setIsLoading] = useState(true);

  // Modals state
  const [isEditOpen, setIsEditOpen] = useState(false);
  const [isPrivacyOpen, setIsPrivacyOpen] = useState(false);
  const [isPolicyOpen, setIsPolicyOpen] = useState(false);
  const [isPasswordOpen, setIsPasswordOpen] = useState(false);
  const [isDeleteOpen, setIsDeleteOpen] = useState(false);
  const [deleteStep, setDeleteStep] = useState<"reason" | "confirm">("reason");
  const [selectedReason, setSelectedReason] = useState("");

  // Edit form state
  const [editForm, setEditForm] = useState({
    fullName: "",
    phone: "",
    email: "",
    nativePlace: "",
    education: "",
    occupation: "",
    bio: "",
  });

  // Contact OTP Verification modal state
  const [otpModal, setOtpModal] = useState<{
    isOpen: boolean;
    isPhone: boolean;
    target: string;
    masked: string;
    code: string;
    cooldown: number;
    isVerifying: boolean;
    isResending: boolean;
    error: string;
  }>({
    isOpen: false,
    isPhone: true,
    target: "",
    masked: "",
    code: "",
    cooldown: 0,
    isVerifying: false,
    isResending: false,
    error: "",
  });

  useEffect(() => {
    let t: NodeJS.Timeout;
    if (otpModal.isOpen && otpModal.cooldown > 0) {
      t = setTimeout(() => {
        setOtpModal((prev) => ({ ...prev, cooldown: Math.max(0, prev.cooldown - 1) }));
      }, 1000);
    }
    return () => clearTimeout(t);
  }, [otpModal.isOpen, otpModal.cooldown]);

  // Privacy settings state (retains previous options)
  const [privacySettings, setPrivacySettings] = useState({
    phoneVisibility: "Only Verified Samaj Members (માત્ર ખરાઈ થયેલ સભ્યો)",
    photoAccess: "Visible to All Registered Users (તમામ નોંધાયેલ સભ્યો)",
    familyInfo: "Restricted to Mutual Interest (પરસ્પર સંમતિ પર)",
    directCall: true,
  });

  // Password update form state
  const [passwordForm, setPasswordForm] = useState({
    currentPassword: "",
    newPassword: "",
    confirmPassword: "",
  });

  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 3500);
  };

  // Fetch real profile on mount
  useEffect(() => {
    async function loadProfile() {
      try {
        const token =
          typeof window !== "undefined"
            ? localStorage.getItem("accessToken") ||
              localStorage.getItem("token") ||
              localStorage.getItem("adminToken")
            : null;

        let storedUser: any = null;
        try {
          const uStr =
            typeof window !== "undefined"
              ? localStorage.getItem("user") || localStorage.getItem("adminUser")
              : null;
          if (uStr) storedUser = JSON.parse(uStr);
        } catch (_) {}

        if (!token) {
          router.replace("/login");
          return;
        }

        const headers: Record<string, string> = {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        };

        const res = await fetch("/api/v1/profiles/me", {
          headers,
          credentials: "include",
        });

        if (res.ok) {
          const data = await res.json();
          if (data) {
            setProfile({
              fullName:
                data.fullName ||
                (data.firstName
                  ? `${data.firstName} ${data.lastName || ""}`.trim()
                  : "") ||
                storedUser?.name ||
                "",
              email:
                data.contactEmail ||
                data.email ||
                data.user?.email ||
                storedUser?.email ||
                "",
              phone:
                data.contactPhone ||
                data.phone ||
                data.user?.phone ||
                storedUser?.phone ||
                "",
              fullPhotoUrl: data.fullPhotoUrl || data.photoUrl || null,
              isVerified:
                data.isVerified === true ||
                data.verificationStatus === "VERIFIED",
              isPhoneVerified:
                data.isPhoneVerified === true ||
                data.user?.isPhoneVerified === true ||
                storedUser?.isPhoneVerified === true,
              isEmailVerified:
                data.isEmailVerified === true ||
                data.user?.isEmailVerified === true ||
                storedUser?.isEmailVerified === true,
              nativePlace: data.nativePlace || data.city || data.pargana || "",
              pargana:
                data.pargana?.name ||
                data.pargana ||
                data.nativePlace ||
                "",
              education: data.education || "",
              occupation: data.occupation || "",
              bio: data.about || data.bio || "",
            });
          }
        } else if (res.status === 404) {
          // Candidate registered but hasn't filled biodata yet
          if (storedUser) {
            setProfile({
              fullName: storedUser.name || "",
              email: storedUser.email || "",
              phone: storedUser.phone || "",
              fullPhotoUrl: null,
              isVerified: false,
              isPhoneVerified: storedUser?.isPhoneVerified === true,
              isEmailVerified: storedUser?.isEmailVerified === true,
              nativePlace: "",
              pargana: "",
              education: "",
              occupation: "",
              bio: "",
            });
          }
        }
      } catch (err) {
        console.warn("Could not fetch /profiles/me:", err);
      } finally {
        setIsLoading(false);
      }
    }

    loadProfile();
  }, [router]);

  // Open Edit Profile modal with current values
  const handleOpenEdit = () => {
    setEditForm({
      fullName: profile.fullName,
      phone: profile.phone,
      email: profile.email,
      nativePlace: profile.nativePlace || "",
      education: profile.education || "",
      occupation: profile.occupation || "",
      bio: profile.bio || "",
    });
    setIsEditOpen(true);
  };

  // Save Edit Profile
  const handleSaveProfile = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editForm.fullName.trim()) {
      showToast("કૃપા કરીને પૂરું નામ દાખલ કરો (Please enter your full name)");
      return;
    }

    setProfile((prev) => ({
      ...prev,
      fullName: editForm.fullName.trim(),
      phone: editForm.phone.trim(),
      email: editForm.email.trim(),
      nativePlace: editForm.nativePlace.trim(),
      education: editForm.education.trim(),
      occupation: editForm.occupation.trim(),
      bio: editForm.bio.trim(),
    }));

    try {
      const token =
        typeof window !== "undefined"
          ? localStorage.getItem("accessToken") ||
            localStorage.getItem("token") ||
            localStorage.getItem("adminToken")
          : null;

      const nameParts = editForm.fullName.trim().split(" ");
      const firstName = nameParts[0] || "";
      const lastName = nameParts.slice(1).join(" ") || "";

      const res = await fetch("/api/v1/profiles/me", {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          ...(token ? { Authorization: `Bearer ${token}` } : {}),
        },
        credentials: "include",
        body: JSON.stringify({
          firstName,
          lastName,
          nativePlace: editForm.nativePlace,
          education: editForm.education,
          occupation: editForm.occupation,
          about: editForm.bio,
          bio: editForm.bio,
          contactPhone: editForm.phone.trim(),
          contactEmail: editForm.email.trim(),
        }),
      });

      if (res.status === 404) {
        // MatrimonialProfile does not exist yet; create it
        await fetch("/api/v1/profiles", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            ...(token ? { Authorization: `Bearer ${token}` } : {}),
          },
          credentials: "include",
          body: JSON.stringify({
            firstName,
            lastName,
            gender: "Male",
            maritalStatus: "NEVER_MARRIED",
            dateOfBirth: "1995-01-01T00:00:00.000Z",
            nativePlace: editForm.nativePlace,
            education: editForm.education,
            occupation: editForm.occupation,
            about: editForm.bio,
            contactPhone: editForm.phone.trim(),
            contactEmail: editForm.email.trim(),
          }),
        });
      }
    } catch (_) {}

    setIsEditOpen(false);
    showToast("પ્રોફાઇલ સફળતાપૂર્વક અપડેટ થઈ ગઈ છે! (Profile updated)");
  };

  // Dispatch Contact Verification OTP (Phone SMS or Email)
  const handleSendContactOtp = async (isPhone: boolean) => {
    const target = isPhone
      ? editForm.phone.trim().replace(/\D/g, "")
      : editForm.email.trim();
    if (isPhone && target.length !== 10) {
      showToast("કૃપા કરીને માન્ય 10-અંકનો મોબાઇલ નંબર દાખલ કરો");
      return;
    }
    if (!isPhone && (!target.includes("@") || !target.includes("."))) {
      showToast("કૃપા કરીને માન્ય ઈમેઈલ સરનામું દાખલ કરો");
      return;
    }

    try {
      let token =
        typeof window !== "undefined"
          ? localStorage.getItem("accessToken") ||
            localStorage.getItem("token") ||
            localStorage.getItem("adminToken") ||
            localStorage.getItem("jwt")
          : null;
      if (!token && typeof document !== "undefined") {
        const match = document.cookie.match(/(?:^|;\s*)(?:accessToken|token|jwt)=([^;]+)/);
        if (match) token = match[1];
      }
      const apiBase = process.env.NEXT_PUBLIC_API_URL || "/api/v1";
      const res = await fetch(`${apiBase}/auth/profile/send-contact-otp`, {
        method: "POST",
        credentials: "include",
        headers: {
          "Content-Type": "application/json",
          ...(token ? { Authorization: `Bearer ${token}` } : {}),
        },
        body: JSON.stringify({
          name: editForm.fullName.trim(),
          phone: isPhone ? target : undefined,
          email: !isPhone ? target : undefined,
          channel: isPhone ? "SMS" : "EMAIL",
        }),
      });
      const data = await res.json();
      if (res.ok && data.success) {
        setOtpModal({
          isOpen: true,
          isPhone,
          target,
          masked: isPhone
            ? data.maskedPhone || target
            : data.maskedEmail || target,
          code: "",
          cooldown: data.resendCooldownSeconds || 60,
          isVerifying: false,
          isResending: false,
          error: "",
        });
      } else {
        showToast(data.message || `ચકાસણી કોડ મોકલવામાં નિષ્ફળતા (${res.status})`);
      }
    } catch {
      showToast("સર્વર સાથે કનેક્ટ કરવામાં નિષ્ફળતા");
    }
  };

  // Verify Contact OTP Code
  const handleVerifyContactOtp = async (e: React.FormEvent) => {
    e.preventDefault();
    if (otpModal.code.trim().length !== 6) {
      setOtpModal((prev) => ({
        ...prev,
        error: "કૃપા કરીને 6-અંકનો OTP કોડ દાખલ કરો",
      }));
      return;
    }
    setOtpModal((prev) => ({ ...prev, isVerifying: true, error: "" }));

    try {
      let token =
        typeof window !== "undefined"
          ? localStorage.getItem("accessToken") ||
            localStorage.getItem("token") ||
            localStorage.getItem("adminToken") ||
            localStorage.getItem("jwt")
          : null;
      if (!token && typeof document !== "undefined") {
        const match = document.cookie.match(/(?:^|;\s*)(?:accessToken|token|jwt)=([^;]+)/);
        if (match) token = match[1];
      }
      const apiBase = process.env.NEXT_PUBLIC_API_URL || "/api/v1";
      const res = await fetch(`${apiBase}/auth/profile/verify-contact-otp`, {
        method: "POST",
        credentials: "include",
        headers: {
          "Content-Type": "application/json",
          ...(token ? { Authorization: `Bearer ${token}` } : {}),
        },
        body: JSON.stringify({
          phone: otpModal.isPhone ? otpModal.target : undefined,
          email: !otpModal.isPhone ? otpModal.target : undefined,
          phoneOtp: otpModal.isPhone ? otpModal.code.trim() : undefined,
          emailOtp: !otpModal.isPhone ? otpModal.code.trim() : undefined,
        }),
      });
      const data = await res.json();
      if (res.ok && data.success) {
        setOtpModal((prev) => ({ ...prev, isOpen: false }));
        setProfile((prev) => ({
          ...prev,
          phone: otpModal.isPhone ? otpModal.target : prev.phone,
          email: !otpModal.isPhone ? otpModal.target : prev.email,
          isPhoneVerified: otpModal.isPhone ? true : prev.isPhoneVerified,
          isEmailVerified: !otpModal.isPhone ? true : prev.isEmailVerified,
        }));
        showToast(
          otpModal.isPhone
            ? "✓ મોબાઇલ નંબર સફળતાપૂર્વક ચકાસાયેલ છે! (Mobile number verified!)"
            : "✓ ઈમેઈલ સરનામું સફળતાપૂર્વક ચકાસાયેલ છે! (Email address verified!)"
        );
      } else {
        setOtpModal((prev) => ({
          ...prev,
          isVerifying: false,
          error: data.message || "ખોટો OTP કોડ",
        }));
      }
    } catch {
      setOtpModal((prev) => ({
        ...prev,
        isVerifying: false,
        error: "સર્વર સાથે કનેક્ટ કરવામાં નિષ્ફળતા",
      }));
    }
  };

  // Save Privacy Settings
  const handleSavePrivacy = () => {
    setIsPrivacyOpen(false);
    showToast("ગોપનીયતા સેટિંગ્સ સફળતાપૂર્વક સાચવવામાં આવી છે! (Privacy saved)");
  };

  // Save Password Change
  const handleSavePassword = async (e: React.FormEvent) => {
    e.preventDefault();
    if (passwordForm.newPassword.length < 6) {
      showToast("નવો પાસવર્ડ ઓછામાં ઓછો 6 અક્ષરનો હોવો જોઈએ (Min 6 chars)");
      return;
    }
    if (passwordForm.newPassword !== passwordForm.confirmPassword) {
      showToast("બંને પાસવર્ડ સરખા હોવા જોઈએ (Passwords must match)");
      return;
    }

    try {
      const token =
        typeof window !== "undefined"
          ? localStorage.getItem("accessToken") ||
            localStorage.getItem("token") ||
            localStorage.getItem("adminToken")
          : null;

      const res = await fetch("/api/v1/auth/change-password", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          ...(token ? { Authorization: `Bearer ${token}` } : {}),
        },
        credentials: "include",
        body: JSON.stringify({
          currentPassword: passwordForm.currentPassword,
          newPassword: passwordForm.newPassword,
        }),
      });

      if (!res.ok) {
        const errorData = await res.json().catch(() => null);
        showToast(errorData?.message || "પાસવર્ડ બદલવામાં નિષ્ફળતા. હાલનો પાસવર્ડ તપાસો.");
        return;
      }
    } catch (_) {}

    setIsPasswordOpen(false);
    setPasswordForm({ currentPassword: "", newPassword: "", confirmPassword: "" });
    showToast("પાસવર્ડ સફળતાપૂર્વક બદલાઈ ગયો છે! (Password updated)");
  };

  // Delete Account
  const handleConfirmDelete = async () => {
    try {
      const token =
        typeof window !== "undefined"
          ? localStorage.getItem("accessToken") ||
            localStorage.getItem("token") ||
            localStorage.getItem("adminToken")
          : null;

      await fetch("/api/v1/auth/account/me", {
        method: "DELETE",
        headers: {
          "Content-Type": "application/json",
          ...(token ? { Authorization: `Bearer ${token}` } : {}),
        },
        credentials: "include",
      });
    } catch (_) {}

    handleLogout();
  };

  // Logout
  const handleLogout = () => {
    if (typeof window !== "undefined") {
      localStorage.removeItem("accessToken");
      localStorage.removeItem("token");
      localStorage.removeItem("adminToken");
      document.cookie = "admin_token=; Max-Age=0; path=/;";
    }
    router.push("/login");
  };

  const deleteReasons = [
    "I found my match elsewhere (મને અન્ય જગ્યાએ યોગ્ય મેળ મળ્યો છે)",
    "I am not finding the app useful (મને વેબસાઈટ ઉપયોગી લાગતી નથી)",
    "Privacy concerns (ગોપનીયતા સંબંધિત ચિંતા)",
    "I am getting too many notifications (વધુ પડતા નોટિફિકેશન)",
    "Other reasons (અન્ય કારણ)",
  ];

  if (isLoading) {
    return (
      <div className="min-h-screen bg-[#F8FAFC] flex flex-col items-center justify-center font-sans p-4">
        <div className="w-12 h-12 border-4 border-[#C49B24] border-t-transparent rounded-full animate-spin mb-4" />
        <p className="text-slate-600 font-semibold font-gujarati text-sm">
          પ્રોફાઇલ વિગતો લોડ થઈ રહી છે... (Loading Profile...)
        </p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#F8FAFC] text-slate-800 flex flex-col font-sans pb-24">
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Cinzel:wght@600;700;800&family=Noto+Sans+Gujarati:wght@400;500;600;700&display=swap');
        .font-cinzel { font-family: 'Cinzel', serif; }
        .font-gujarati { font-family: 'Noto Sans Gujarati', sans-serif; }
      `}</style>

      {/* Top Banner & Header Bar */}
      <header className="bg-white border-b border-slate-200 sticky top-0 z-30 shadow-xs">
        <div className="max-w-xl mx-auto px-4 py-3.5 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Link
              href="/matrimony"
              className="text-[#C49B24] hover:text-[#A8821B] p-1.5 rounded-lg hover:bg-amber-50 transition-colors"
              title="Back to Home"
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.2} d="M15 19l-7-7 7-7" />
              </svg>
            </Link>
            <h1 className="text-xl md:text-2xl font-bold text-[#C49B24] font-gujarati tracking-tight">
              My Profile (મારી પ્રોફાઇલ)
            </h1>
          </div>
          <Link
            href="/matrimony"
            className="text-xs font-semibold text-slate-500 hover:text-[#C49B24] px-2.5 py-1 rounded-md border border-slate-200 hover:border-[#C49B24] transition-all"
          >
            મેટ્રિમોની હોમ
          </Link>
        </div>
      </header>

      {/* Toast Notification */}
      {toastMessage && (
        <div className="fixed top-16 left-1/2 -translate-x-1/2 z-50 bg-slate-900 text-amber-200 px-4 py-2.5 rounded-xl shadow-xl border border-amber-400/40 text-xs md:text-sm font-semibold flex items-center gap-2 animate-bounce">
          <span>✓</span>
          <span>{toastMessage}</span>
        </div>
      )}

      {/* Main Content Container */}
      <main className="max-w-xl w-full mx-auto px-4 py-5 flex-1 flex flex-col gap-4 font-gujarati">
        {/* Profile Card (Exact replica of mobile phone layout) */}
        <section className="bg-white rounded-2xl border border-[#D4AF37]/40 shadow-xs p-6 text-center relative overflow-hidden transition-all hover:shadow-md">
          {/* Subtle gold top glow */}
          <div className="absolute top-0 left-0 right-0 h-1 bg-gradient-to-r from-amber-200 via-[#C49B24] to-amber-200" />

          {/* Avatar Circle */}
          <div className="relative mx-auto w-24 h-24 mb-3.5">
            <div className="w-24 h-24 rounded-full bg-slate-100 border-2 border-slate-200 flex items-center justify-center overflow-hidden shadow-inner mx-auto relative">
              {profile.fullPhotoUrl ? (
                <Image
                  src={profile.fullPhotoUrl}
                  alt={profile.fullName}
                  fill
                  className="object-cover"
                />
              ) : (
                <svg
                  className="w-14 h-14 text-slate-400"
                  fill="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z" />
                </svg>
              )}
            </div>
            {profile.isVerified && (
              <span
                className="absolute bottom-0 right-1 bg-[#C49B24] text-white p-1 rounded-full shadow-md"
                title="Verified Profile"
              >
                <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={3} d="M5 13l4 4L19 7" />
                </svg>
              </span>
            )}
          </div>

          {/* Full Name */}
          <h2 className="text-xl md:text-2xl font-bold text-slate-900 leading-tight">
            {profile.fullName}
          </h2>

          {/* Email / Mobile subtitle */}
          <p className="text-sm text-slate-500 mt-1 select-all font-sans">
            {profile.email || profile.phone}
          </p>

          {/* Verified Member Badge */}
          <div className="mt-3 flex justify-center">
            {profile.isVerified ? (
              <div className="inline-flex items-center gap-1.5 px-3.5 py-1 rounded-full border border-[#C49B24] bg-amber-50/60 text-[#C49B24] text-xs font-semibold shadow-xs">
                <svg className="w-3.5 h-3.5 fill-[#C49B24]" viewBox="0 0 24 24">
                  <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z" />
                </svg>
                <span>Verified Member</span>
              </div>
            ) : (
              <span className="inline-flex items-center gap-1 px-3 py-0.5 rounded-full border border-slate-300 bg-slate-50 text-slate-500 text-xs font-medium">
                સભ્ય (Member - ચકાસણી બાકી)
              </span>
            )}
          </div>
        </section>

        {/* Menu Navigation Tiles (Exact replica of mobile list) */}
        <section className="flex flex-col gap-3">
          {/* 1. Edit Profile */}
          <button
            type="button"
            onClick={handleOpenEdit}
            className="w-full bg-white rounded-xl border border-slate-200 shadow-xs hover:border-[#C49B24]/70 hover:shadow-md p-3.5 md:p-4 flex items-center justify-between text-left transition-all duration-200 group"
          >
            <div className="flex items-center gap-3.5">
              <div className="w-10 h-10 rounded-xl bg-[#FEF9E7] text-[#C49B24] flex items-center justify-center shrink-0 shadow-inner group-hover:scale-105 transition-transform">
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"
                  />
                </svg>
              </div>
              <div>
                <h3 className="font-bold text-slate-800 text-sm md:text-base group-hover:text-[#C49B24] transition-colors">
                  Edit Profile (પ્રોફાઇલ સુધારો)
                </h3>
                <p className="text-xs text-slate-500">
                  વ્યક્તિગત માહિતી, શિક્ષણ, વ્યવસાય અને પરિચય અપડેટ કરો
                </p>
              </div>
            </div>
            <span className="text-slate-400 group-hover:text-[#C49B24] group-hover:translate-x-1 transition-all">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.2} d="M9 5l7 7-7 7" />
              </svg>
            </span>
          </button>

          {/* 2. Privacy & Contact */}
          <button
            type="button"
            onClick={() => setIsPrivacyOpen(true)}
            className="w-full bg-white rounded-xl border border-slate-200 shadow-xs hover:border-[#C49B24]/70 hover:shadow-md p-3.5 md:p-4 flex items-center justify-between text-left transition-all duration-200 group"
          >
            <div className="flex items-center gap-3.5">
              <div className="w-10 h-10 rounded-xl bg-[#FEF9E7] text-[#C49B24] flex items-center justify-center shrink-0 shadow-inner group-hover:scale-105 transition-transform">
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"
                  />
                </svg>
              </div>
              <div>
                <h3 className="font-bold text-slate-800 text-sm md:text-base group-hover:text-[#C49B24] transition-colors">
                  Privacy & Contact (ગોપનીયતા)
                </h3>
                <p className="text-xs text-slate-500">
                  ફોન નંબર, ફોટો અને સીધા કોલિંગના સુરક્ષા સેટિંગ્સ
                </p>
              </div>
            </div>
            <span className="text-slate-400 group-hover:text-[#C49B24] group-hover:translate-x-1 transition-all">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.2} d="M9 5l7 7-7 7" />
              </svg>
            </span>
          </button>

          {/* 3. Privacy Policy */}
          <button
            type="button"
            onClick={() => setIsPolicyOpen(true)}
            className="w-full bg-white rounded-xl border border-slate-200 shadow-xs hover:border-[#C49B24]/70 hover:shadow-md p-3.5 md:p-4 flex items-center justify-between text-left transition-all duration-200 group"
          >
            <div className="flex items-center gap-3.5">
              <div className="w-10 h-10 rounded-xl bg-[#FEF9E7] text-[#C49B24] flex items-center justify-center shrink-0 shadow-inner group-hover:scale-105 transition-transform">
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"
                  />
                </svg>
              </div>
              <div>
                <h3 className="font-bold text-slate-800 text-sm md:text-base group-hover:text-[#C49B24] transition-colors">
                  Privacy Policy (ગોપનીયતા નીતિ)
                </h3>
                <p className="text-xs text-slate-500">
                  સમાજ નિયમો, ડેટા સુરક્ષા અને શરતો
                </p>
              </div>
            </div>
            <span className="text-slate-400 group-hover:text-[#C49B24] group-hover:translate-x-1 transition-all">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.2} d="M9 5l7 7-7 7" />
              </svg>
            </span>
          </button>

          {/* 4. Verified Profile Details */}
          <Link
            href="/verified-profile"
            className="w-full bg-white rounded-xl border border-slate-200 shadow-xs hover:border-[#C49B24]/70 hover:shadow-md p-3.5 md:p-4 flex items-center justify-between text-left transition-all duration-200 group"
          >
            <div className="flex items-center gap-3.5">
              <div className="w-10 h-10 rounded-xl bg-[#FEF9E7] text-[#C49B24] flex items-center justify-center shrink-0 shadow-inner group-hover:scale-105 transition-transform">
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z"
                  />
                </svg>
              </div>
              <div>
                <h3 className="font-bold text-slate-800 text-sm md:text-base group-hover:text-[#C49B24] transition-colors">
                  Verified Profile Details
                </h3>
                <p className="text-xs text-slate-500">
                  ઓળખપત્ર, આધાર અને પરગણા મંડળ માન્યતા સ્થિતિ
                </p>
              </div>
            </div>
            <span className="text-slate-400 group-hover:text-[#C49B24] group-hover:translate-x-1 transition-all">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.2} d="M9 5l7 7-7 7" />
              </svg>
            </span>
          </Link>

          {/* 5. Update Password */}
          <button
            type="button"
            onClick={() => setIsPasswordOpen(true)}
            className="w-full bg-white rounded-xl border border-slate-200 shadow-xs hover:border-[#C49B24]/70 hover:shadow-md p-3.5 md:p-4 flex items-center justify-between text-left transition-all duration-200 group"
          >
            <div className="flex items-center gap-3.5">
              <div className="w-10 h-10 rounded-xl bg-[#FEF9E7] text-[#C49B24] flex items-center justify-center shrink-0 shadow-inner group-hover:scale-105 transition-transform">
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z"
                  />
                </svg>
              </div>
              <div>
                <h3 className="font-bold text-slate-800 text-sm md:text-base group-hover:text-[#C49B24] transition-colors">
                  Update Password (પાસવર્ડ બદલો)
                </h3>
                <p className="text-xs text-slate-500">
                  તમારો નવો ગુપ્ત પાસવર્ડ સેટ કરો
                </p>
              </div>
            </div>
            <span className="text-slate-400 group-hover:text-[#C49B24] group-hover:translate-x-1 transition-all">
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.2} d="M9 5l7 7-7 7" />
              </svg>
            </span>
          </button>
        </section>

        {/* Danger Action Buttons (Exact replica of mobile layout) */}
        <section className="flex flex-col gap-3 mt-3">
          {/* Delete Account Button */}
          <button
            type="button"
            onClick={() => {
              setDeleteStep("reason");
              setSelectedReason("");
              setIsDeleteOpen(true);
            }}
            className="w-full py-3.5 px-4 rounded-xl border-2 border-[#991B1B] text-[#991B1B] bg-white font-bold text-sm md:text-base flex items-center justify-center gap-2 hover:bg-red-50/70 transition-all shadow-xs active:scale-[0.99]"
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
              />
            </svg>
            <span>Delete Account (એકાઉન્ટ કાઢી નાખો)</span>
          </button>

          {/* Logout Button */}
          <button
            type="button"
            onClick={handleLogout}
            className="w-full py-3.5 px-4 rounded-xl bg-[#DC2626] hover:bg-[#B91C1C] text-white font-bold text-sm md:text-base flex items-center justify-center gap-2 transition-all shadow-xs hover:shadow-md active:scale-[0.99]"
          >
            <svg className="w-5 h-5 rotate-180" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2.2}
                d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"
              />
            </svg>
            <span>Logout (લોગઆઉટ)</span>
          </button>
        </section>
      </main>

      {/* Bottom Navigation Bar (Matching Mobile App) */}
      <nav className="fixed bottom-0 left-0 right-0 bg-[#041126] border-t border-[#C49B24]/40 z-30 shadow-2xl">
        <div className="max-w-xl mx-auto flex items-center justify-around py-2 px-1 text-slate-300 text-[11px] font-medium">
          <Link
            href="/matrimony"
            className="flex flex-col items-center gap-0.5 hover:text-[#FFE066] transition-colors py-1 px-3"
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
            </svg>
            <span>હોમ</span>
          </Link>
          <Link
            href="/search"
            className="flex flex-col items-center gap-0.5 hover:text-[#FFE066] transition-colors py-1 px-3"
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
            <span>શોધો</span>
          </Link>
          <Link
            href="/mutual-interest"
            className="flex flex-col items-center gap-0.5 hover:text-[#FFE066] transition-colors py-1 px-3"
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
            </svg>
            <span>મેળ</span>
          </Link>
          <Link
            href="/services"
            className="flex flex-col items-center gap-0.5 hover:text-[#FFE066] transition-colors py-1 px-3"
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
            </svg>
            <span>મેસેજ</span>
          </Link>
          <Link
            href="/profile"
            className="flex flex-col items-center gap-0.5 text-[#C49B24] font-bold py-1 px-3"
          >
            <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z" />
            </svg>
            <span>પ્રોફાઇલ</span>
          </Link>
        </div>
      </nav>

      {/* ========================================================= */}
      {/* 1. EDIT PROFILE MODAL */}
      {/* ========================================================= */}
      {isEditOpen && (
        <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl border border-amber-200/80 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100">
              <h3 className="font-bold text-lg text-slate-900 font-gujarati flex items-center gap-2">
                <span className="text-[#C49B24]">✏️</span> Edit Profile (પ્રોફાઇલ સુધારો)
              </h3>
              <button
                type="button"
                onClick={() => setIsEditOpen(false)}
                className="text-slate-400 hover:text-slate-600 text-xl font-bold p-1"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleSaveProfile} className="space-y-4 mt-4 font-gujarati text-sm">
              <div>
                <label className="block font-bold text-slate-700 text-xs mb-1">
                  પૂરું નામ (Full Name) *
                </label>
                <input
                  type="text"
                  value={editForm.fullName}
                  onChange={(e) => setEditForm({ ...editForm, fullName: e.target.value })}
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-300 focus:outline-none focus:border-[#C49B24]"
                  placeholder="તમારું પૂરું નામ લખો"
                  required
                />
              </div>

              <div>
                <div className="flex items-center justify-between mb-1">
                  <label className="block font-bold text-slate-700 text-xs">
                    મોબાઇલ નંબર (Mobile Phone - 10 અંક) *
                  </label>
                  {profile.isPhoneVerified && editForm.phone.trim().replace(/\D/g, "") === profile.phone.trim().replace(/\D/g, "") ? (
                    <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-bold bg-green-50 text-green-700 border border-green-300">
                      ✓ ચકાસાયેલ (Verified)
                    </span>
                  ) : editForm.phone.trim().replace(/\D/g, "").length === 10 ? (
                    <button
                      type="button"
                      onClick={() => handleSendContactOtp(true)}
                      className="px-2.5 py-0.5 text-[11px] font-bold bg-[#C49B24] hover:bg-[#A8821B] text-black rounded transition-colors shadow-xs"
                    >
                      ચકાસો (Verify Code)
                    </button>
                  ) : null}
                </div>
                <input
                  type="text"
                  maxLength={10}
                  value={editForm.phone}
                  onChange={(e) => setEditForm({ ...editForm, phone: e.target.value })}
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-300 focus:outline-none focus:border-[#C49B24]"
                  placeholder="10 અંકનો મોબાઇલ નંબર"
                />
              </div>

              <div>
                <div className="flex items-center justify-between mb-1">
                  <label className="block font-bold text-slate-700 text-xs">
                    ઈમેઈલ સરનામું (Email Address)
                  </label>
                  {profile.isEmailVerified && editForm.email.trim().toLowerCase() === profile.email.trim().toLowerCase() ? (
                    <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-bold bg-green-50 text-green-700 border border-green-300">
                      ✓ ચકાસાયેલ (Verified)
                    </span>
                  ) : editForm.email.trim().includes("@") ? (
                    <button
                      type="button"
                      onClick={() => handleSendContactOtp(false)}
                      className="px-2.5 py-0.5 text-[11px] font-bold bg-[#C49B24] hover:bg-[#A8821B] text-black rounded transition-colors shadow-xs"
                    >
                      ચકાસો (Verify Code)
                    </button>
                  ) : null}
                </div>
                <input
                  type="email"
                  value={editForm.email}
                  onChange={(e) => setEditForm({ ...editForm, email: e.target.value })}
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-300 focus:outline-none focus:border-[#C49B24]"
                  placeholder="તમારું ઈમેઈલ સરનામું લખો"
                />
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                <div>
                  <label className="block font-bold text-slate-700 text-xs mb-1">
                    મૂળ ગામ / વતન (Native Place)
                  </label>
                  <input
                    type="text"
                    value={editForm.nativePlace}
                    onChange={(e) => setEditForm({ ...editForm, nativePlace: e.target.value })}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-300 focus:outline-none focus:border-[#C49B24]"
                    placeholder="દા.ત. પાટણ, વિસનગર"
                  />
                </div>

                <div>
                  <label className="block font-bold text-slate-700 text-xs mb-1">
                    શિક્ષણ (Education)
                  </label>
                  <input
                    type="text"
                    value={editForm.education}
                    onChange={(e) => setEditForm({ ...editForm, education: e.target.value })}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-slate-300 focus:outline-none focus:border-[#C49B24]"
                    placeholder="દા.ત. B.Tech / MBA / Graduate"
                  />
                </div>
              </div>

              <div>
                <label className="block font-bold text-slate-700 text-xs mb-1">
                  વ્યવસાય / નોકરી (Occupation / Job)
                </label>
                <input
                  type="text"
                  value={editForm.occupation}
                  onChange={(e) => setEditForm({ ...editForm, occupation: e.target.value })}
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-300 focus:outline-none focus:border-[#C49B24]"
                  placeholder="દા.ત. Software Engineer / Govt. Officer / Business"
                />
              </div>

              <div>
                <label className="block font-bold text-slate-700 text-xs mb-1">
                  તમારા વિશે સંક્ષિપ્ત પરિચય (Bio / About)
                </label>
                <textarea
                  rows={3}
                  value={editForm.bio}
                  onChange={(e) => setEditForm({ ...editForm, bio: e.target.value })}
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-300 focus:outline-none focus:border-[#C49B24] text-xs leading-relaxed"
                  placeholder="તમારા પરિચય અને અપેક્ષાઓ વિશે લખો..."
                />
              </div>

              <div className="pt-3 flex gap-3">
                <button
                  type="button"
                  onClick={() => setIsEditOpen(false)}
                  className="w-1/2 py-2.5 rounded-xl border border-slate-300 text-slate-600 font-bold hover:bg-slate-50 transition-colors"
                >
                  રદ કરો (Cancel)
                </button>
                <button
                  type="submit"
                  className="w-1/2 py-2.5 rounded-xl bg-[#C49B24] hover:bg-[#A8821B] text-white font-bold transition-colors shadow-xs"
                >
                  સેવ કરો (Save)
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ========================================================= */}
      {/* CONTACT OTP VERIFICATION MODAL */}
      {/* ========================================================= */}
      {otpModal.isOpen && (
        <div className="fixed inset-0 z-50 bg-black/70 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-[#041126] text-white rounded-2xl max-w-sm w-full p-6 shadow-2xl border-2 border-[#D4AF37]">
            <div className="flex items-center justify-between pb-3 border-b border-white/10">
              <h3 className="font-bold text-base text-[#D4AF37] font-gujarati flex items-center gap-2">
                <span>{otpModal.isPhone ? "📱" : "✉️"}</span>
                {otpModal.isPhone ? "મોબાઇલ ચકાસણી (Mobile Verify)" : "ઈમેઈલ ચકાસણી (Email Verify)"}
              </h3>
              <button
                type="button"
                onClick={() => setOtpModal((prev) => ({ ...prev, isOpen: false }))}
                className="text-white/60 hover:text-white text-xl font-bold p-1"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleVerifyContactOtp} className="space-y-4 mt-4 font-gujarati">
              <p className="text-xs text-white/80 leading-relaxed">
                ચકાસણી માટે <b className="text-[#FFE066]">{otpModal.masked}</b> પર 6-અંકનો OTP કોડ મોકલવામાં આવ્યો છે:
                <br />
                <span className="text-[11px] text-white/60">(Enter 6-digit OTP code sent to your {otpModal.isPhone ? "mobile" : "email"})</span>
              </p>

              <div>
                <input
                  type="text"
                  maxLength={6}
                  value={otpModal.code}
                  onChange={(e) => setOtpModal((prev) => ({ ...prev, code: e.target.value.replace(/\D/g, "") }))}
                  className="w-full text-center text-2xl tracking-[0.5em] font-mono font-bold py-2.5 px-3 bg-black/40 rounded-xl border border-[#D4AF37] text-white focus:outline-none focus:border-amber-400"
                  placeholder="123456"
                  autoFocus
                />
              </div>

              {otpModal.error && (
                <div className="p-2.5 bg-red-950/60 border border-red-500 rounded-lg text-xs text-red-300">
                  {otpModal.error}
                </div>
              )}

              <div className="flex items-center justify-between text-xs pt-1">
                <button
                  type="button"
                  disabled={otpModal.cooldown > 0 || otpModal.isResending}
                  onClick={() => handleSendContactOtp(otpModal.isPhone)}
                  className={`underline ${otpModal.cooldown > 0 ? "text-white/40 cursor-not-allowed" : "text-[#D4AF37] hover:text-amber-300"}`}
                >
                  {otpModal.cooldown > 0 ? `Resend in ${otpModal.cooldown}s` : "Resend Code (ફરી કોડ મોકલો)"}
                </button>
              </div>

              <div className="pt-2 flex gap-3">
                <button
                  type="button"
                  onClick={() => setOtpModal((prev) => ({ ...prev, isOpen: false }))}
                  className="w-1/2 py-2 rounded-xl border border-white/20 text-white/70 hover:bg-white/5 font-semibold text-xs transition-colors"
                >
                  Cancel (રદ કરો)
                </button>
                <button
                  type="submit"
                  disabled={otpModal.isVerifying}
                  className="w-1/2 py-2 rounded-xl bg-[#D4AF37] hover:bg-[#c49b24] text-black font-bold text-xs transition-colors shadow-md flex items-center justify-center gap-1"
                >
                  {otpModal.isVerifying ? "Verifying..." : "Verify (ચકાસો)"}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ========================================================= */}
      {/* 2. PRIVACY & CONTACT MODAL */}
      {/* ========================================================= */}
      {isPrivacyOpen && (
        <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl border border-amber-200/80 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100">
              <h3 className="font-bold text-lg text-slate-900 font-gujarati flex items-center gap-2">
                <span className="text-[#C49B24]">📇</span> Privacy & Contact (ગોપનીયતા)
              </h3>
              <button
                type="button"
                onClick={() => setIsPrivacyOpen(false)}
                className="text-slate-400 hover:text-slate-600 text-xl font-bold p-1"
              >
                ✕
              </button>
            </div>

            <div className="space-y-4 mt-4 font-gujarati text-xs">
              <div className="space-y-1.5">
                <label className="block text-slate-800 font-bold text-sm">
                  ૧. ફોન નંબર દર્શાવવો (Phone Number Visibility):
                </label>
                <select
                  value={privacySettings.phoneVisibility}
                  onChange={(e) =>
                    setPrivacySettings({ ...privacySettings, phoneVisibility: e.target.value })
                  }
                  className="w-full bg-slate-50 border border-slate-300 rounded-xl p-3 text-slate-800 focus:outline-none focus:border-[#C49B24] font-medium"
                >
                  <option>Only Verified Samaj Members (માત્ર ખરાઈ થયેલ સભ્યો)</option>
                  <option>Mutual Interest Accepted Only (સંમતિ બાદ જ)</option>
                  <option>Hide Phone Number (કોઈને પણ ના દર્શાવો)</option>
                </select>
              </div>

              <div className="space-y-1.5">
                <label className="block text-slate-800 font-bold text-sm">
                  ૨. ફોટો દર્શાવવાની પરવાનગી (Profile Photo Access):
                </label>
                <select
                  value={privacySettings.photoAccess}
                  onChange={(e) =>
                    setPrivacySettings({ ...privacySettings, photoAccess: e.target.value })
                  }
                  className="w-full bg-slate-50 border border-slate-300 rounded-xl p-3 text-slate-800 focus:outline-none focus:border-[#C49B24] font-medium"
                >
                  <option>Visible to All Registered Users (તમામ નોંધાયેલ સભ્યો)</option>
                  <option>Visible Only on Request (વિનંતી પર જ દર્શાવો)</option>
                  <option>Protected with Password (પાસવર્ડ વડે સુરક્ષિત)</option>
                </select>
              </div>

              <div className="space-y-1.5">
                <label className="block text-slate-800 font-bold text-sm">
                  ૩. કુટુંબની વિગતો (Family Details Access):
                </label>
                <select
                  value={privacySettings.familyInfo}
                  onChange={(e) =>
                    setPrivacySettings({ ...privacySettings, familyInfo: e.target.value })
                  }
                  className="w-full bg-slate-50 border border-slate-300 rounded-xl p-3 text-slate-800 focus:outline-none focus:border-[#C49B24] font-medium"
                >
                  <option>Restricted to Mutual Interest (પરસ્પર સંમતિ પર)</option>
                  <option>Public to All Verified Samaj Members (તમામ વણકર સભ્યો)</option>
                </select>
              </div>

              <div className="flex items-center justify-between bg-amber-50/50 p-4 rounded-xl border border-amber-200/60">
                <div>
                  <span className="block font-bold text-slate-900 text-sm">
                    ૪. સીધો કોલ સ્વીકારો (Direct Calling):
                  </span>
                  <span className="text-slate-500 text-xs">
                    અન્ય ચકાસાયેલ સભ્યો દ્વારા સીધા કોલ કરવાની મંજૂરી
                  </span>
                </div>
                <button
                  type="button"
                  onClick={() =>
                    setPrivacySettings({ ...privacySettings, directCall: !privacySettings.directCall })
                  }
                  className={`w-12 h-6 flex items-center rounded-full p-1 transition-colors duration-300 ${
                    privacySettings.directCall ? "bg-[#C49B24] justify-end" : "bg-slate-300 justify-start"
                  }`}
                >
                  <div className="w-4 h-4 rounded-full bg-white shadow-md" />
                </button>
              </div>

              <div className="pt-3 flex gap-3">
                <button
                  type="button"
                  onClick={() => setIsPrivacyOpen(false)}
                  className="w-1/2 py-2.5 rounded-xl border border-slate-300 text-slate-600 font-bold hover:bg-slate-50 transition-colors"
                >
                  પાછા જાઓ (Back)
                </button>
                <button
                  type="button"
                  onClick={handleSavePrivacy}
                  className="w-1/2 py-2.5 rounded-xl bg-[#C49B24] hover:bg-[#A8821B] text-white font-bold transition-colors shadow-xs"
                >
                  સેવ કરો (Save Settings)
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* ========================================================= */}
      {/* 3. PRIVACY POLICY MODAL */}
      {/* ========================================================= */}
      {isPolicyOpen && (
        <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-lg w-full p-6 shadow-2xl border border-amber-200/80 max-h-[85vh] overflow-y-auto font-gujarati">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100">
              <h3 className="font-bold text-lg text-slate-900 flex items-center gap-2">
                <span className="text-[#C49B24]">🛡️</span> Privacy Policy (ગોપનીયતા નીતિ)
              </h3>
              <button
                type="button"
                onClick={() => setIsPolicyOpen(false)}
                className="text-slate-400 hover:text-slate-600 text-xl font-bold p-1"
              >
                ✕
              </button>
            </div>

            <div className="space-y-3 mt-4 text-xs text-slate-700 leading-relaxed">
              <p className="font-bold text-slate-900 text-sm">
                શ્રી અખિલ ગુજરાત વણકર સમાજ મેટ્રિમોની પોર્ટલ ગોપનીયતા નિયમાવલી:
              </p>
              <div className="p-3 bg-amber-50 rounded-xl border border-amber-200">
                <h4 className="font-bold text-slate-900 mb-1">૧. માહિતીની ગુપ્તતા (Confidentiality)</h4>
                <p>
                  તમારો મોબાઇલ નંબર અને અંગત દસ્તાવેજો માત્ર વણકર સમાજના અધિકૃત સભ્યો માટે જ સુરક્ષિત છે. અનધિકૃત ઉપયોગ સામે કડક કાનૂની પગલાં લેવામાં આવશે.
                </p>
              </div>
              <div className="p-3 bg-amber-50 rounded-xl border border-amber-200">
                <h4 className="font-bold text-slate-900 mb-1">૨. ફોટો અને બાયોડેટા સુરક્ષા</h4>
                <p>
                  કોઈપણ ઉમેદવારના ફોટાનો દુરુપયોગ કે સ્ક્રીનશોટ શેરિંગ સખત પ્રતિબંધિત છે.
                </p>
              </div>
              <div className="p-3 bg-amber-50 rounded-xl border border-amber-200">
                <h4 className="font-bold text-slate-900 mb-1">૩. એકાઉન્ટ રદ કરવાનો અધિકાર</h4>
                <p>
                  સભ્ય પોતાની ઇચ્છા મુજબ કોઈપણ સમયે પોતાનું એકાઉન્ટ અને બાયોડેટા કાયમી ધોરણે રદ (Delete) કરી શકે છે.
                </p>
              </div>
            </div>

            <div className="pt-4 mt-4 border-t border-slate-100">
              <button
                type="button"
                onClick={() => setIsPolicyOpen(false)}
                className="w-full py-2.5 rounded-xl bg-[#C49B24] hover:bg-[#A8821B] text-white font-bold transition-colors"
              >
                હું સમજુ છું (Close)
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ========================================================= */}
      {/* 4. UPDATE PASSWORD MODAL */}
      {/* ========================================================= */}
      {isPasswordOpen && (
        <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl border border-amber-200/80 font-gujarati">
            <div className="flex items-center justify-between pb-3 border-b border-slate-100">
              <h3 className="font-bold text-lg text-slate-900 flex items-center gap-2">
                <span className="text-[#C49B24]">🔑</span> Update Password (પાસવર્ડ બદલો)
              </h3>
              <button
                type="button"
                onClick={() => setIsPasswordOpen(false)}
                className="text-slate-400 hover:text-slate-600 text-xl font-bold p-1"
              >
                ✕
              </button>
            </div>

            <form onSubmit={handleSavePassword} className="space-y-3.5 mt-4 text-xs">
              <div>
                <label className="block font-bold text-slate-700 mb-1">
                  હાલનો પાસવર્ડ (Current Password) *
                </label>
                <input
                  type="password"
                  value={passwordForm.currentPassword}
                  onChange={(e) =>
                    setPasswordForm({ ...passwordForm, currentPassword: e.target.value })
                  }
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-300 focus:outline-none focus:border-[#C49B24]"
                  placeholder="••••••••"
                  required
                />
              </div>

              <div>
                <label className="block font-bold text-slate-700 mb-1">
                  નવો પાસવર્ડ (New Password - Min 6 chars) *
                </label>
                <input
                  type="password"
                  value={passwordForm.newPassword}
                  onChange={(e) =>
                    setPasswordForm({ ...passwordForm, newPassword: e.target.value })
                  }
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-300 focus:outline-none focus:border-[#C49B24]"
                  placeholder="ન્યૂનતમ 6 અક્ષરો"
                  required
                />
              </div>

              <div>
                <label className="block font-bold text-slate-700 mb-1">
                  પાસવર્ડ ખાતરી કરો (Confirm New Password) *
                </label>
                <input
                  type="password"
                  value={passwordForm.confirmPassword}
                  onChange={(e) =>
                    setPasswordForm({ ...passwordForm, confirmPassword: e.target.value })
                  }
                  className="w-full px-3.5 py-2.5 rounded-xl border border-slate-300 focus:outline-none focus:border-[#C49B24]"
                  placeholder="ફરીથી પાસવર્ડ દાખલ કરો"
                  required
                />
              </div>

              <div className="pt-3 flex gap-3">
                <button
                  type="button"
                  onClick={() => setIsPasswordOpen(false)}
                  className="w-1/2 py-2.5 rounded-xl border border-slate-300 text-slate-600 font-bold hover:bg-slate-50 transition-colors"
                >
                  રદ કરો
                </button>
                <button
                  type="submit"
                  className="w-1/2 py-2.5 rounded-xl bg-[#C49B24] hover:bg-[#A8821B] text-white font-bold transition-colors shadow-xs"
                >
                  પાસવર્ડ બદલો
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* ========================================================= */}
      {/* 5. DELETE ACCOUNT QUESTIONNAIRE MODAL */}
      {/* ========================================================= */}
      {isDeleteOpen && (
        <div className="fixed inset-0 z-50 bg-black/60 backdrop-blur-xs flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl border border-red-200 font-gujarati">
            {deleteStep === "reason" ? (
              <>
                <div className="flex items-center justify-between pb-3 border-b border-slate-100">
                  <h3 className="font-bold text-base md:text-lg text-red-800 flex items-center gap-2">
                    <span>⚠️</span> Why are you leaving? (તમે એકાઉન્ટ શા માટે રદ કરો છો?)
                  </h3>
                  <button
                    type="button"
                    onClick={() => setIsDeleteOpen(false)}
                    className="text-slate-400 hover:text-slate-600 text-xl font-bold p-1"
                  >
                    ✕
                  </button>
                </div>

                <p className="text-xs text-slate-500 mt-2">
                  કૃપા કરીને યોગ્ય કારણ પસંદ કરો જેથી અમે સમાજ સેવા સુધારી શકીએ:
                </p>

                <div className="space-y-2 mt-4 text-xs">
                  {deleteReasons.map((reason, idx) => (
                    <label
                      key={idx}
                      className={`flex items-start gap-2.5 p-3 rounded-xl border cursor-pointer transition-all ${
                        selectedReason === reason
                          ? "border-[#C49B24] bg-amber-50/60 font-semibold text-slate-900"
                          : "border-slate-200 hover:bg-slate-50 text-slate-700"
                      }`}
                    >
                      <input
                        type="radio"
                        name="deleteReason"
                        checked={selectedReason === reason}
                        onChange={() => setSelectedReason(reason)}
                        className="mt-0.5 accent-[#C49B24]"
                      />
                      <span>{reason}</span>
                    </label>
                  ))}
                </div>

                <div className="pt-4 mt-3 flex gap-3">
                  <button
                    type="button"
                    onClick={() => setIsDeleteOpen(false)}
                    className="w-1/2 py-2.5 rounded-xl border border-slate-300 text-slate-600 font-bold hover:bg-slate-50 transition-colors text-xs"
                  >
                    પાછા જાઓ (Cancel)
                  </button>
                  <button
                    type="button"
                    disabled={!selectedReason}
                    onClick={() => setDeleteStep("confirm")}
                    className={`w-1/2 py-2.5 rounded-xl font-bold text-xs transition-colors ${
                      selectedReason
                        ? "bg-red-700 hover:bg-red-800 text-white"
                        : "bg-slate-200 text-slate-400 cursor-not-allowed"
                    }`}
                  >
                    આગળ વધો (Next)
                  </button>
                </div>
              </>
            ) : (
              <>
                <div className="text-center py-2">
                  <div className="w-14 h-14 rounded-full bg-red-100 text-red-600 mx-auto flex items-center justify-center mb-3 text-2xl font-bold">
                    🗑️
                  </div>
                  <h3 className="font-bold text-lg text-slate-900">
                    શું તમે ખાતરીપૂર્વક એકાઉન્ટ રદ કરવા માંગો છો?
                  </h3>
                  <p className="text-xs text-slate-500 mt-1.5 leading-relaxed">
                    એકાઉન્ટ કાઢી નાખવાથી તમારો બાયોડેટા, ફોટો અને સંદેશાઓ કાયમી ધોરણે દૂર થઈ જશે. આ ક્રિયા પૂર્વવત્ કરી શકાશે નહીં.
                  </p>
                </div>

                <div className="pt-4 flex gap-3">
                  <button
                    type="button"
                    onClick={() => setDeleteStep("reason")}
                    className="w-1/2 py-2.5 rounded-xl border border-slate-300 text-slate-700 font-bold text-xs hover:bg-slate-50"
                  >
                    ના, પાછા જાઓ
                  </button>
                  <button
                    type="button"
                    onClick={handleConfirmDelete}
                    className="w-1/2 py-2.5 rounded-xl bg-red-700 hover:bg-red-800 text-white font-bold text-xs shadow-xs"
                  >
                    હા, કાયમી રદ કરો
                  </button>
                </div>
              </>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
