"use client";

import { useState, useEffect, useRef } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { fetchFromBackend, getImageUrl } from "@/lib/api";

function extractYouTubeId(url: string): string | null {
  if (!url) return null;
  const match = url.match(/(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|shorts\/|watch\?.+&v=))([\w-]{11})/);
  return match ? match[1] : null;
}

export default function EducationAdminPage() {
  const [formData, setFormData] = useState({
    headerTitle: "Education for Better Tomorrow",
    headerSubtitle: "શિક્ષણ અને ઉજ્જવળ ભવિષ્ય માર્ગદર્શન",
    box1Title: "શિક્ષણ માર્ગદર્શિકા અને પરિપત્રો (PDF)",
    box1Subtitle: "Download Official Educational PDF Guidelines & Circulars",
    box1PdfUrl: "",
    box1FileName: "career_guidance_2026.pdf",
    box2Title: "શિક્ષણ પ્રેરણા સંદેશ & કારકિર્દી સલાહ",
    box2Content:
      "શિક્ષણ એ જીવનનો સૌથી મહત્વનો પાયો છે. આપણા વણકર સમાજના દરેક દીકરા અને દીકરી ઉચ્ચ શિક્ષણ મેળવી સમાજ અને દેશનું નામ રોશન કરે તે અમારો મુખ્ય સંકલ્પ છે. ધોરણ ૧૦ અને ૧૨ પછીના વિવિધ અભ્યાસક્રમો, સ્કોલરશીપ સહાય, અને સરકારી ભરતીઓની તૈયારી માટે સમાજ સદાય તમારી સાથે છે. જ્ઞાન એ જ શક્તિ છે, અને શિક્ષણ દ્વારા જ પ્રગતિ શક્ય છે.",
    box2Author: "શિક્ષણ સમિતિ, ઓલ ગુજરાત વણકર સમાજ",
    box3Title: "શૈક્ષણિક સેમિનાર & કારકિર્દી માર્ગદર્શન",
    box3YoutubeUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    box3Description: "ઉચ્ચ અભ્યાસ અને કારકિર્દી પસંદગી અંગે વિશેષ માર્ગદર્શન વ્યાખ્યાન.",
    box4Title: "યુવા પ્રેરણા સંવાદ & સફળતાની વાર્તાઓ",
    box4YoutubeUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    box4Description: "સમાજના તેજસ્વી તારલાઓ અને અધિકારીઓના પ્રેરણાદાયી અનુભવો.",
    isActive: true,
  });

  const [isLoading, setIsLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);
  const [isUploadingPdf, setIsUploadingPdf] = useState(false);
  const [saveSuccess, setSaveSuccess] = useState(false);
  const [saveError, setSaveError] = useState("");
  const fileInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    fetchEducationData();
  }, []);

  const fetchEducationData = async () => {
    setIsLoading(true);
    setSaveError("");
    try {
      const res = await fetchFromBackend("/admin/education");
      if (res.statusCode === 200 && res.data?.data) {
        const d = res.data.data;
        setFormData((prev) => ({
          ...prev,
          headerTitle: d.headerTitle ?? prev.headerTitle,
          headerSubtitle: d.headerSubtitle ?? prev.headerSubtitle,
          box1Title: d.box1Title ?? prev.box1Title,
          box1Subtitle: d.box1Subtitle ?? prev.box1Subtitle,
          box1PdfUrl: d.box1PdfUrl ?? "",
          box1FileName: d.box1FileName ?? "",
          box2Title: d.box2Title ?? prev.box2Title,
          box2Content: d.box2Content ?? "",
          box2Author: d.box2Author ?? "",
          box3Title: d.box3Title ?? prev.box3Title,
          box3YoutubeUrl: d.box3YoutubeUrl ?? "",
          box3Description: d.box3Description ?? "",
          box4Title: d.box4Title ?? prev.box4Title,
          box4YoutubeUrl: d.box4YoutubeUrl ?? "",
          box4Description: d.box4Description ?? "",
          isActive: d.isActive !== undefined ? d.isActive : true,
        }));
      }
    } catch (e: any) {
      console.error("Error loading education content", e);
    }
    setIsLoading(false);
  };

  const handlePdfUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    if (!file.name.toLowerCase().endsWith(".pdf")) {
      alert("Please select a valid PDF document (.pdf)");
      return;
    }

    setIsUploadingPdf(true);
    try {
      const uploadData = new FormData();
      uploadData.append("file", file);

      const apiUrl = process.env.NEXT_PUBLIC_API_URL || "/api/v1";
      const token = localStorage.getItem("adminToken") || localStorage.getItem("token") || "";

      const res = await fetch(`${apiUrl}/storage/upload`, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
        },
        body: uploadData,
      });

      if (res.ok) {
        const json = await res.json();
        const uploadedUrl = json.url || json.data?.url || "";
        if (uploadedUrl) {
          setFormData((prev) => ({
            ...prev,
            box1PdfUrl: uploadedUrl,
            box1FileName: file.name,
          }));
          alert(`✅ PDF uploaded successfully: ${file.name}\nRemember to click 'Save & Publish All Changes' to make it live!`);
        } else {
          alert("File uploaded, but URL was not returned.");
        }
      } else {
        const errText = await res.text();
        alert(`PDF upload failed (HTTP ${res.status}): ${errText}`);
      }
    } catch (err: any) {
      alert(`Error uploading PDF: ${err.message}`);
    }
    setIsUploadingPdf(false);
    if (fileInputRef.current) {
      fileInputRef.current.value = "";
    }
  };

  const handleRemovePdf = () => {
    if (window.confirm("Are you sure you want to remove the current PDF from Box 1?")) {
      setFormData((prev) => ({
        ...prev,
        box1PdfUrl: "",
        box1FileName: "",
      }));
    }
  };

  const handleClearBox2 = () => {
    if (window.confirm("Are you sure you want to clear the written paragraph in Box 2?")) {
      setFormData((prev) => ({
        ...prev,
        box2Content: "",
      }));
    }
  };

  const handleClearYoutube1 = () => {
    if (window.confirm("Are you sure you want to clear the YouTube video link in Box 3?")) {
      setFormData((prev) => ({
        ...prev,
        box3YoutubeUrl: "",
      }));
    }
  };

  const handleClearYoutube2 = () => {
    if (window.confirm("Are you sure you want to clear the YouTube video link in Box 4?")) {
      setFormData((prev) => ({
        ...prev,
        box4YoutubeUrl: "",
      }));
    }
  };

  const handleSave = async (e?: React.FormEvent) => {
    if (e) e.preventDefault();
    setIsSaving(true);
    setSaveSuccess(false);
    setSaveError("");

    try {
      const token = localStorage.getItem("adminToken") || localStorage.getItem("token") || "";
      const apiUrl = process.env.NEXT_PUBLIC_API_URL || "/api/v1";

      // Explicitly extract only the valid payload fields (never send id, createdAt, updatedAt)
      const payload = {
        headerTitle: formData.headerTitle,
        headerSubtitle: formData.headerSubtitle,
        box1Title: formData.box1Title,
        box1Subtitle: formData.box1Subtitle,
        box1PdfUrl: formData.box1PdfUrl.trim(),
        box1FileName: formData.box1FileName.trim(),
        box2Title: formData.box2Title,
        box2Content: formData.box2Content,
        box2Author: formData.box2Author,
        box3Title: formData.box3Title,
        box3YoutubeUrl: formData.box3YoutubeUrl.trim(),
        box3Description: formData.box3Description,
        box4Title: formData.box4Title,
        box4YoutubeUrl: formData.box4YoutubeUrl.trim(),
        box4Description: formData.box4Description,
        isActive: formData.isActive,
      };

      const res = await fetch(`${apiUrl}/admin/education`, {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(payload),
      });

      if (res.ok) {
        setSaveSuccess(true);
        setTimeout(() => setSaveSuccess(false), 5000);
        alert("✅ Education 4-box content successfully saved and published!");
      } else {
        const err = await res.text();
        setSaveError(`Failed to save (HTTP ${res.status}): ${err}`);
        alert(`Failed to save (Status: ${res.status})\n\n${err}`);
      }
    } catch (e: any) {
      setSaveError(`Save error: ${e.message}`);
      alert(`Save error: ${e.message}`);
    }
    setIsSaving(false);
  };

  const youtube1Id = extractYouTubeId(formData.box3YoutubeUrl);
  const youtube2Id = extractYouTubeId(formData.box4YoutubeUrl);

  if (isLoading) {
    return (
      <AdminLayout title="Education Management">
        <div style={{ padding: "60px", textAlign: "center", display: "flex", flexDirection: "column", alignItems: "center", gap: "16px" }}>
          <div style={{ width: "40px", height: "40px", border: "3px solid #D4AF37", borderTopColor: "transparent", borderRadius: "50%" }} className="animate-spin"></div>
          <p style={{ color: "#D4AF37", fontSize: "14px", fontWeight: 800, textTransform: "uppercase", letterSpacing: "2px", margin: 0 }}>
            Loading Education Content...
          </p>
        </div>
      </AdminLayout>
    );
  }

  return (
    <AdminLayout title="Education Management" subtitle="Manage the 4 dynamic boxes for 'Education for Better Tomorrow'">
      <div style={{ display: "flex", flexDirection: "column", gap: "28px", paddingBottom: "48px" }}>
        {/* Top Header & Save Button */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", flexWrap: "wrap", gap: "16px" }}>
          <div>
            <h1 style={{ fontSize: "28px", fontWeight: "900", color: "#FFFFFF", margin: "0 0 6px 0", display: "flex", alignItems: "center", gap: "12px" }}>
              <span style={{ filter: "drop-shadow(0 0 8px rgba(212,175,55,0.8))" }}>🎓</span>
              Education for Better Tomorrow
            </h1>
            <p style={{ color: "#8E9BAE", fontSize: "14px", margin: 0, fontWeight: 500 }}>
              Live content management for the 4 boxes: PDF circulars, written guidance paragraph, and 2 educational YouTube videos.
            </p>
          </div>
          <div style={{ display: "flex", gap: "12px", alignItems: "center" }}>
            <button
              onClick={fetchEducationData}
              type="button"
              style={{
                backgroundColor: "rgba(255,255,255,0.08)",
                color: "#E2E8F0",
                fontWeight: 700,
                fontSize: "13px",
                padding: "12px 18px",
                borderRadius: "10px",
                border: "1px solid rgba(255,255,255,0.15)",
                cursor: "pointer",
              }}
            >
              🔄 Reload
            </button>
            <button
              onClick={() => handleSave()}
              disabled={isSaving}
              style={{
                background: "linear-gradient(135deg, #D4AF37 0%, #AA7C11 100%)",
                color: "#041026",
                fontWeight: 800,
                fontSize: "14px",
                padding: "12px 28px",
                borderRadius: "12px",
                border: "none",
                cursor: isSaving ? "not-allowed" : "pointer",
                boxShadow: "0 4px 15px rgba(212,175,55,0.4)",
                display: "flex",
                alignItems: "center",
                gap: "8px",
              }}
            >
              {isSaving ? "Saving Content..." : "💾 Save & Publish All Changes"}
            </button>
          </div>
        </div>

        {saveSuccess && (
          <div style={{ padding: "14px 20px", backgroundColor: "rgba(16, 185, 129, 0.2)", border: "1px solid #10B981", borderRadius: "12px", color: "#34D399", fontWeight: 700, fontSize: "14px" }}>
            ✅ Education 4-box content successfully saved and published! Live on Flutter app.
          </div>
        )}

        {saveError && (
          <div style={{ padding: "14px 20px", backgroundColor: "rgba(239, 68, 68, 0.2)", border: "1px solid #EF4444", borderRadius: "12px", color: "#FCA5A5", fontWeight: 700, fontSize: "14px" }}>
            ❌ {saveError}
          </div>
        )}

        {/* Header Settings */}
        <div
          style={{
            background: "linear-gradient(145deg, rgba(13, 27, 50, 0.9) 0%, rgba(4, 12, 26, 0.95) 100%)",
            borderRadius: "16px",
            border: "1px solid rgba(212, 175, 55, 0.3)",
            padding: "24px",
            boxShadow: "0 10px 30px rgba(0,0,0,0.4)",
          }}
        >
          <h2 style={{ fontSize: "18px", fontWeight: 800, color: "#D4AF37", marginBottom: "16px", display: "flex", alignItems: "center", gap: "8px" }}>
            <span>📌</span> Screen Titles (મથાળું)
          </h2>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(280px, 1fr))", gap: "16px" }}>
            <div>
              <label style={{ display: "block", color: "#D4AF37", fontSize: "12px", fontWeight: 700, marginBottom: "6px" }}>
                Main Title (English)
              </label>
              <input
                type="text"
                value={formData.headerTitle}
                onChange={(e) => setFormData({ ...formData, headerTitle: e.target.value })}
                style={{ width: "100%", padding: "10px 14px", borderRadius: "8px", backgroundColor: "#061329", border: "1px solid rgba(212,175,55,0.3)", color: "#FFFFFF" }}
              />
            </div>
            <div>
              <label style={{ display: "block", color: "#D4AF37", fontSize: "12px", fontWeight: 700, marginBottom: "6px" }}>
                Subtitle (ગુજરાતી પેટા મથાળું)
              </label>
              <input
                type="text"
                value={formData.headerSubtitle}
                onChange={(e) => setFormData({ ...formData, headerSubtitle: e.target.value })}
                style={{ width: "100%", padding: "10px 14px", borderRadius: "8px", backgroundColor: "#061329", border: "1px solid rgba(212,175,55,0.3)", color: "#FFFFFF" }}
              />
            </div>
          </div>
        </div>

        {/* 4 BOXES GRID */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(380px, 1fr))", gap: "24px" }}>
          {/* BOX 1: PDF Document */}
          <div
            style={{
              background: "linear-gradient(145deg, rgba(13, 27, 50, 0.9) 0%, rgba(4, 12, 26, 0.95) 100%)",
              borderRadius: "16px",
              border: "1.5px solid rgba(239, 68, 68, 0.4)",
              padding: "24px",
              display: "flex",
              flexDirection: "column",
              gap: "14px",
              boxShadow: "0 8px 24px rgba(239, 68, 68, 0.15)",
            }}
          >
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
                <span style={{ fontSize: "24px" }}>📄</span>
                <div>
                  <h3 style={{ margin: 0, fontSize: "16px", fontWeight: 800, color: "#EF4444" }}>BOX 1: PDF Resources & Guidelines</h3>
                  <span style={{ fontSize: "12px", color: "#8E9BAE" }}>શૈક્ષણિક PDF સાહિત્ય & પરિપત્રો</span>
                </div>
              </div>
              <span style={{ padding: "4px 10px", borderRadius: "20px", backgroundColor: "rgba(239,68,68,0.2)", color: "#EF4444", fontSize: "11px", fontWeight: 800 }}>
                PDF DATA
              </span>
            </div>

            <div>
              <label style={{ display: "block", color: "#EF4444", fontSize: "12px", fontWeight: 700, marginBottom: "4px" }}>
                Box 1 Title (મથાળું)
              </label>
              <input
                type="text"
                value={formData.box1Title}
                onChange={(e) => setFormData({ ...formData, box1Title: e.target.value })}
                style={{ width: "100%", padding: "8px 12px", borderRadius: "8px", backgroundColor: "#061329", border: "1px solid rgba(239,68,68,0.3)", color: "#FFFFFF" }}
              />
            </div>

            <div>
              <label style={{ display: "block", color: "#EF4444", fontSize: "12px", fontWeight: 700, marginBottom: "4px" }}>
                Subtitle / Description
              </label>
              <input
                type="text"
                value={formData.box1Subtitle}
                onChange={(e) => setFormData({ ...formData, box1Subtitle: e.target.value })}
                style={{ width: "100%", padding: "8px 12px", borderRadius: "8px", backgroundColor: "#061329", border: "1px solid rgba(239,68,68,0.3)", color: "#FFFFFF" }}
              />
            </div>

            {/* PDF Upload / Remove Action */}
            <div style={{ padding: "16px", borderRadius: "10px", backgroundColor: "rgba(239,68,68,0.08)", border: "1px dashed rgba(239,68,68,0.4)" }}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "10px", flexWrap: "wrap", gap: "8px" }}>
                <span style={{ fontSize: "12px", fontWeight: 700, color: "#FFFFFF" }}>Upload / Replace PDF:</span>
                <input
                  ref={fileInputRef}
                  type="file"
                  accept=".pdf,application/pdf"
                  onChange={handlePdfUpload}
                  style={{ display: "none" }}
                />
                <button
                  type="button"
                  onClick={() => fileInputRef.current?.click()}
                  disabled={isUploadingPdf}
                  style={{
                    backgroundColor: "#EF4444",
                    color: "#FFFFFF",
                    fontSize: "12px",
                    fontWeight: 700,
                    padding: "6px 14px",
                    borderRadius: "6px",
                    border: "none",
                    cursor: isUploadingPdf ? "not-allowed" : "pointer",
                  }}
                >
                  {isUploadingPdf ? "Uploading..." : "📂 Choose PDF File"}
                </button>
              </div>

              {formData.box1PdfUrl ? (
                <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: "8px", padding: "10px", backgroundColor: "#040E1E", borderRadius: "6px", border: "1px solid rgba(239,68,68,0.3)" }}>
                  <div style={{ overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap", fontSize: "12px", color: "#F87171", flex: 1 }}>
                    📎 {formData.box1FileName || formData.box1PdfUrl}
                  </div>
                  <div style={{ display: "flex", gap: "8px", alignItems: "center" }}>
                    <a
                      href={getImageUrl(formData.box1PdfUrl)}
                      target="_blank"
                      rel="noopener noreferrer"
                      style={{ color: "#D4AF37", fontSize: "12px", fontWeight: 800, textDecoration: "underline", whiteSpace: "nowrap" }}
                    >
                      View PDF ↗
                    </a>
                    <button
                      type="button"
                      onClick={handleRemovePdf}
                      style={{
                        backgroundColor: "rgba(239,68,68,0.2)",
                        color: "#F87171",
                        border: "1px solid rgba(239,68,68,0.5)",
                        fontSize: "11px",
                        fontWeight: 700,
                        padding: "3px 8px",
                        borderRadius: "4px",
                        cursor: "pointer",
                      }}
                    >
                      🗑️ Remove PDF
                    </button>
                  </div>
                </div>
              ) : (
                <div style={{ fontSize: "12px", color: "#94A3B8", fontStyle: "italic", padding: "6px 0" }}>
                  ℹ️ No PDF currently attached. (Click &quot;Choose PDF File&quot; to upload)
                </div>
              )}
            </div>

            <div>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "4px" }}>
                <label style={{ color: "#8E9BAE", fontSize: "11px" }}>
                  Direct PDF URL or File Path:
                </label>
                {formData.box1PdfUrl && (
                  <button
                    type="button"
                    onClick={() => setFormData({ ...formData, box1PdfUrl: "", box1FileName: "" })}
                    style={{ background: "none", border: "none", color: "#EF4444", fontSize: "11px", cursor: "pointer", textDecoration: "underline" }}
                  >
                    Clear URL
                  </button>
                )}
              </div>
              <input
                type="text"
                value={formData.box1PdfUrl}
                onChange={(e) => setFormData({ ...formData, box1PdfUrl: e.target.value })}
                placeholder="/uploads/sample.pdf or https://..."
                style={{ width: "100%", padding: "6px 10px", borderRadius: "6px", backgroundColor: "#061329", border: "1px solid rgba(255,255,255,0.1)", color: "#FFFFFF", fontSize: "12px" }}
              />
            </div>
          </div>

          {/* BOX 2: Written Paragraph */}
          <div
            style={{
              background: "linear-gradient(145deg, rgba(13, 27, 50, 0.9) 0%, rgba(4, 12, 26, 0.95) 100%)",
              borderRadius: "16px",
              border: "1.5px solid rgba(212, 175, 55, 0.4)",
              padding: "24px",
              display: "flex",
              flexDirection: "column",
              gap: "14px",
              boxShadow: "0 8px 24px rgba(212, 175, 55, 0.15)",
            }}
          >
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
                <span style={{ fontSize: "24px" }}>✍️</span>
                <div>
                  <h3 style={{ margin: 0, fontSize: "16px", fontWeight: 800, color: "#D4AF37" }}>BOX 2: Written Paragraph / Guidance</h3>
                  <span style={{ fontSize: "12px", color: "#8E9BAE" }}>શિક્ષણ પ્રેરણા સંદેશ & લેખ</span>
                </div>
              </div>
              <div style={{ display: "flex", gap: "6px", alignItems: "center" }}>
                {formData.box2Content && (
                  <button
                    type="button"
                    onClick={handleClearBox2}
                    style={{
                      background: "none",
                      border: "1px solid rgba(212,175,55,0.3)",
                      color: "#F3E5AB",
                      fontSize: "11px",
                      padding: "2px 8px",
                      borderRadius: "6px",
                      cursor: "pointer",
                    }}
                  >
                    🧹 Clear
                  </button>
                )}
                <span style={{ padding: "4px 10px", borderRadius: "20px", backgroundColor: "rgba(212,175,55,0.2)", color: "#D4AF37", fontSize: "11px", fontWeight: 800 }}>
                  PARAGRAPH
                </span>
              </div>
            </div>

            <div>
              <label style={{ display: "block", color: "#D4AF37", fontSize: "12px", fontWeight: 700, marginBottom: "4px" }}>
                Box 2 Title (મથાળું)
              </label>
              <input
                type="text"
                value={formData.box2Title}
                onChange={(e) => setFormData({ ...formData, box2Title: e.target.value })}
                style={{ width: "100%", padding: "8px 12px", borderRadius: "8px", backgroundColor: "#061329", border: "1px solid rgba(212,175,55,0.3)", color: "#FFFFFF" }}
              />
            </div>

            <div>
              <label style={{ display: "block", color: "#D4AF37", fontSize: "12px", fontWeight: 700, marginBottom: "4px" }}>
                Author / Designation (લેખક / સમિતિ)
              </label>
              <input
                type="text"
                value={formData.box2Author}
                onChange={(e) => setFormData({ ...formData, box2Author: e.target.value })}
                style={{ width: "100%", padding: "8px 12px", borderRadius: "8px", backgroundColor: "#061329", border: "1px solid rgba(212,175,55,0.3)", color: "#FFFFFF" }}
              />
            </div>

            <div>
              <div style={{ display: "flex", justifyContent: "space-between", marginBottom: "4px" }}>
                <label style={{ color: "#D4AF37", fontSize: "12px", fontWeight: 700 }}>
                  Written Paragraph Content (પ્રેરણા સંદેશ / વિગતવાર લેખ)
                </label>
                <span style={{ fontSize: "11px", color: "#8E9BAE" }}>
                  {formData.box2Content.length} characters
                </span>
              </div>
              <textarea
                rows={6}
                value={formData.box2Content}
                onChange={(e) => setFormData({ ...formData, box2Content: e.target.value })}
                placeholder="અહીં શિક્ષણ અંગેનો પ્રેરણાત્મક સંદેશ અથવા કારકિર્દી માર્ગદર્શન લખો..."
                style={{
                  width: "100%",
                  padding: "12px",
                  borderRadius: "8px",
                  backgroundColor: "#061329",
                  border: "1px solid rgba(212,175,55,0.3)",
                  color: "#FFFFFF",
                  fontSize: "13px",
                  lineHeight: "1.6",
                }}
              />
            </div>
          </div>

          {/* BOX 3: YouTube Video 1 */}
          <div
            style={{
              background: "linear-gradient(145deg, rgba(13, 27, 50, 0.9) 0%, rgba(4, 12, 26, 0.95) 100%)",
              borderRadius: "16px",
              border: "1.5px solid rgba(59, 130, 246, 0.4)",
              padding: "24px",
              display: "flex",
              flexDirection: "column",
              gap: "14px",
              boxShadow: "0 8px 24px rgba(59, 130, 246, 0.15)",
            }}
          >
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
                <span style={{ fontSize: "24px" }}>🎥</span>
                <div>
                  <h3 style={{ margin: 0, fontSize: "16px", fontWeight: 800, color: "#60A5FA" }}>BOX 3: YouTube Video 1</h3>
                  <span style={{ fontSize: "12px", color: "#8E9BAE" }}>શૈક્ષણિક વિડિઓ ૧</span>
                </div>
              </div>
              <div style={{ display: "flex", gap: "6px", alignItems: "center" }}>
                {formData.box3YoutubeUrl && (
                  <button
                    type="button"
                    onClick={handleClearYoutube1}
                    style={{
                      backgroundColor: "rgba(239,68,68,0.15)",
                      color: "#F87171",
                      border: "1px solid rgba(239,68,68,0.4)",
                      fontSize: "11px",
                      fontWeight: 700,
                      padding: "2px 8px",
                      borderRadius: "6px",
                      cursor: "pointer",
                    }}
                  >
                    🗑️ Remove
                  </button>
                )}
                <span style={{ padding: "4px 10px", borderRadius: "20px", backgroundColor: "rgba(59,130,246,0.2)", color: "#60A5FA", fontSize: "11px", fontWeight: 800 }}>
                  YOUTUBE 1
                </span>
              </div>
            </div>

            <div>
              <label style={{ display: "block", color: "#60A5FA", fontSize: "12px", fontWeight: 700, marginBottom: "4px" }}>
                Video 1 Title (વિડિઓ મથાળું)
              </label>
              <input
                type="text"
                value={formData.box3Title}
                onChange={(e) => setFormData({ ...formData, box3Title: e.target.value })}
                style={{ width: "100%", padding: "8px 12px", borderRadius: "8px", backgroundColor: "#061329", border: "1px solid rgba(59,130,246,0.3)", color: "#FFFFFF" }}
              />
            </div>

            <div>
              <label style={{ display: "block", color: "#60A5FA", fontSize: "12px", fontWeight: 700, marginBottom: "4px" }}>
                YouTube URL (વિડિઓ લિંક)
              </label>
              <input
                type="text"
                value={formData.box3YoutubeUrl}
                onChange={(e) => setFormData({ ...formData, box3YoutubeUrl: e.target.value })}
                placeholder="https://www.youtube.com/watch?v=... or leave blank to remove"
                style={{ width: "100%", padding: "8px 12px", borderRadius: "8px", backgroundColor: "#061329", border: "1px solid rgba(59,130,246,0.3)", color: "#FFFFFF" }}
              />
            </div>

            <div>
              <label style={{ display: "block", color: "#60A5FA", fontSize: "12px", fontWeight: 700, marginBottom: "4px" }}>
                Short Description / Highlights
              </label>
              <input
                type="text"
                value={formData.box3Description}
                onChange={(e) => setFormData({ ...formData, box3Description: e.target.value })}
                style={{ width: "100%", padding: "8px 12px", borderRadius: "8px", backgroundColor: "#061329", border: "1px solid rgba(59,130,246,0.3)", color: "#FFFFFF" }}
              />
            </div>

            {/* Video Live Thumbnail Preview */}
            {youtube1Id ? (
              <div style={{ position: "relative", borderRadius: "8px", overflow: "hidden", aspectRatio: "16/9", backgroundColor: "#000" }}>
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img
                  src={`https://img.youtube.com/vi/${youtube1Id}/hqdefault.jpg`}
                  alt="YouTube 1 Preview"
                  style={{ width: "100%", height: "100%", objectFit: "cover" }}
                />
                <div style={{ position: "absolute", inset: 0, display: "flex", justifyContent: "center", alignItems: "center", backgroundColor: "rgba(0,0,0,0.3)" }}>
                  <span style={{ fontSize: "36px", filter: "drop-shadow(0 2px 8px rgba(0,0,0,0.8))" }}>▶️</span>
                </div>
              </div>
            ) : (
              <div style={{ padding: "20px", textAlign: "center", backgroundColor: "rgba(0,0,0,0.2)", borderRadius: "8px", color: "#64748B", fontSize: "12px" }}>
                No YouTube URL set for Box 3. (Add link above to preview)
              </div>
            )}
          </div>

          {/* BOX 4: YouTube Video 2 */}
          <div
            style={{
              background: "linear-gradient(145deg, rgba(13, 27, 50, 0.9) 0%, rgba(4, 12, 26, 0.95) 100%)",
              borderRadius: "16px",
              border: "1.5px solid rgba(168, 85, 247, 0.4)",
              padding: "24px",
              display: "flex",
              flexDirection: "column",
              gap: "14px",
              boxShadow: "0 8px 24px rgba(168, 85, 247, 0.15)",
            }}
          >
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <div style={{ display: "flex", alignItems: "center", gap: "10px" }}>
                <span style={{ fontSize: "24px" }}>🎬</span>
                <div>
                  <h3 style={{ margin: 0, fontSize: "16px", fontWeight: 800, color: "#C084FC" }}>BOX 4: YouTube Video 2</h3>
                  <span style={{ fontSize: "12px", color: "#8E9BAE" }}>શૈક્ષણિક વિડિઓ ૨</span>
                </div>
              </div>
              <div style={{ display: "flex", gap: "6px", alignItems: "center" }}>
                {formData.box4YoutubeUrl && (
                  <button
                    type="button"
                    onClick={handleClearYoutube2}
                    style={{
                      backgroundColor: "rgba(239,68,68,0.15)",
                      color: "#F87171",
                      border: "1px solid rgba(239,68,68,0.4)",
                      fontSize: "11px",
                      fontWeight: 700,
                      padding: "2px 8px",
                      borderRadius: "6px",
                      cursor: "pointer",
                    }}
                  >
                    🗑️ Remove
                  </button>
                )}
                <span style={{ padding: "4px 10px", borderRadius: "20px", backgroundColor: "rgba(168,85,247,0.2)", color: "#C084FC", fontSize: "11px", fontWeight: 800 }}>
                  YOUTUBE 2
                </span>
              </div>
            </div>

            <div>
              <label style={{ display: "block", color: "#C084FC", fontSize: "12px", fontWeight: 700, marginBottom: "4px" }}>
                Video 2 Title (વિડિઓ મથાળું)
              </label>
              <input
                type="text"
                value={formData.box4Title}
                onChange={(e) => setFormData({ ...formData, box4Title: e.target.value })}
                style={{ width: "100%", padding: "8px 12px", borderRadius: "8px", backgroundColor: "#061329", border: "1px solid rgba(168,85,247,0.3)", color: "#FFFFFF" }}
              />
            </div>

            <div>
              <label style={{ display: "block", color: "#C084FC", fontSize: "12px", fontWeight: 700, marginBottom: "4px" }}>
                YouTube URL (વિડિઓ લિંક)
              </label>
              <input
                type="text"
                value={formData.box4YoutubeUrl}
                onChange={(e) => setFormData({ ...formData, box4YoutubeUrl: e.target.value })}
                placeholder="https://www.youtube.com/watch?v=... or leave blank to remove"
                style={{ width: "100%", padding: "8px 12px", borderRadius: "8px", backgroundColor: "#061329", border: "1px solid rgba(168,85,247,0.3)", color: "#FFFFFF" }}
              />
            </div>

            <div>
              <label style={{ display: "block", color: "#C084FC", fontSize: "12px", fontWeight: 700, marginBottom: "4px" }}>
                Short Description / Highlights
              </label>
              <input
                type="text"
                value={formData.box4Description}
                onChange={(e) => setFormData({ ...formData, box4Description: e.target.value })}
                style={{ width: "100%", padding: "8px 12px", borderRadius: "8px", backgroundColor: "#061329", border: "1px solid rgba(168,85,247,0.3)", color: "#FFFFFF" }}
              />
            </div>

            {/* Video Live Thumbnail Preview */}
            {youtube2Id ? (
              <div style={{ position: "relative", borderRadius: "8px", overflow: "hidden", aspectRatio: "16/9", backgroundColor: "#000" }}>
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img
                  src={`https://img.youtube.com/vi/${youtube2Id}/hqdefault.jpg`}
                  alt="YouTube 2 Preview"
                  style={{ width: "100%", height: "100%", objectFit: "cover" }}
                />
                <div style={{ position: "absolute", inset: 0, display: "flex", justifyContent: "center", alignItems: "center", backgroundColor: "rgba(0,0,0,0.3)" }}>
                  <span style={{ fontSize: "36px", filter: "drop-shadow(0 2px 8px rgba(0,0,0,0.8))" }}>▶️</span>
                </div>
              </div>
            ) : (
              <div style={{ padding: "20px", textAlign: "center", backgroundColor: "rgba(0,0,0,0.2)", borderRadius: "8px", color: "#64748B", fontSize: "12px" }}>
                No YouTube URL set for Box 4. (Add link above to preview)
              </div>
            )}
          </div>
        </div>

        {/* Floating Save Bar on Scroll */}
        <div
          style={{
            position: "sticky",
            bottom: "20px",
            background: "rgba(4, 16, 38, 0.95)",
            backdropFilter: "blur(12px)",
            padding: "16px 24px",
            borderRadius: "14px",
            border: "1px solid rgba(212, 175, 55, 0.4)",
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            boxShadow: "0 10px 30px rgba(0,0,0,0.6)",
            zIndex: 40,
          }}
        >
          <span style={{ color: "#E2E8F0", fontSize: "13px", fontWeight: 600 }}>
            Make sure to click &quot;Save & Publish&quot; after adding, editing, or removing any data.
          </span>
          <button
            onClick={() => handleSave()}
            disabled={isSaving}
            style={{
              background: "linear-gradient(135deg, #D4AF37 0%, #AA7C11 100%)",
              color: "#041026",
              fontWeight: 800,
              fontSize: "14px",
              padding: "10px 24px",
              borderRadius: "10px",
              border: "none",
              cursor: isSaving ? "not-allowed" : "pointer",
              boxShadow: "0 4px 12px rgba(212,175,55,0.3)",
            }}
          >
            {isSaving ? "Saving..." : "💾 Save & Publish All Changes"}
          </button>
        </div>
      </div>
    </AdminLayout>
  );
}
