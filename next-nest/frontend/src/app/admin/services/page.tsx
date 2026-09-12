"use client";

import React, { useEffect, useState } from "react";
import { AdminLayout } from "@/components/admin/AdminLayout";
import { adminApi, SamajServiceItem, SamajServicePersonItem } from "@/lib/admin-api";

export default function AdminServicesPage() {
  const [activeTab, setActiveTab] = useState<"services" | "persons">("services");
  
  // Data state
  const [services, setServices] = useState<SamajServiceItem[]>([]);
  const [persons, setPersons] = useState<SamajServicePersonItem[]>([]);
  const [loadingServices, setLoadingServices] = useState(true);
  const [loadingPersons, setLoadingPersons] = useState(true);

  // Service Modal state
  const [showServiceModal, setShowServiceModal] = useState(false);
  const [editingService, setEditingService] = useState<SamajServiceItem | null>(null);
  const [svcTitle, setSvcTitle] = useState("");
  const [svcCategory, setSvcCategory] = useState("Mandap");
  const [svcIcon, setSvcIcon] = useState("🎪");
  const [svcPerson, setSvcPerson] = useState("");
  const [svcPhone, setSvcPhone] = useState("");
  const [svcDesc, setSvcDesc] = useState("");
  const [svcActive, setSvcActive] = useState(true);

  // Person Modal state
  const [showPersonModal, setShowPersonModal] = useState(false);
  const [editingPerson, setEditingPerson] = useState<SamajServicePersonItem | null>(null);
  const [personServiceId, setPersonServiceId] = useState("");
  const [personName, setPersonName] = useState("");
  const [personGujaratiName, setPersonGujaratiName] = useState("");
  const [personPhotoUrl, setPersonPhotoUrl] = useState("");
  const [personPhone, setPersonPhone] = useState("");
  const [personAddress, setPersonAddress] = useState("");
  const [personCity, setPersonCity] = useState("Ahmedabad");
  const [personExperience, setPersonExperience] = useState("5+ Years");
  const [personDesc, setPersonDesc] = useState("");
  const [personActive, setPersonActive] = useState(true);

  // Delete Confirm Modal State
  const [serviceToDelete, setServiceToDelete] = useState<SamajServiceItem | null>(null);
  const [personToDelete, setPersonToDelete] = useState<SamajServicePersonItem | null>(null);

  // Search filter
  const [searchQuery, setSearchQuery] = useState("");

  const loadServices = async () => {
    try {
      setLoadingServices(true);
      const data = await adminApi.getSamajServices();
      setServices(data);
      if (data.length > 0 && !personServiceId) {
        setPersonServiceId(data[0].id);
      }
    } catch (e) {
      console.error("Failed to load services:", e);
    } finally {
      setLoadingServices(false);
    }
  };

  const loadPersons = async () => {
    try {
      setLoadingPersons(true);
      const data = await adminApi.getSamajServicePersons();
      setPersons(data);
    } catch (e) {
      console.error("Failed to load service persons:", e);
    } finally {
      setLoadingPersons(false);
    }
  };

  useEffect(() => {
    loadServices();
    loadPersons();
  }, []);

  // --- SERVICE ACTIONS ---
  const openCreateService = () => {
    setEditingService(null);
    setSvcTitle("");
    setSvcCategory("E – Electrical Works & Lighting");
    setSvcIcon("⚡");
    setSvcPerson("");
    setSvcPhone("");
    setSvcDesc("");
    setSvcActive(true);
    setShowServiceModal(true);
  };

  const openEditService = (s: SamajServiceItem) => {
    setEditingService(s);
    setSvcTitle(s.title);
    setSvcCategory(s.category || "General");
    setSvcIcon(s.icon || "🤝");
    setSvcPerson(s.contactPerson || "");
    setSvcPhone(s.contactPhone || "");
    setSvcDesc(s.description || "");
    setSvcActive(s.isActive);
    setShowServiceModal(true);
  };

  const handleServiceSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!svcTitle.trim()) return;

    try {
      if (editingService) {
        await adminApi.updateSamajService(editingService.id, {
          title: svcTitle,
          category: svcCategory,
          icon: svcIcon,
          contactPerson: svcPerson,
          contactPhone: svcPhone,
          description: svcDesc,
          isActive: svcActive,
        });
      } else {
        await adminApi.createSamajService({
          title: svcTitle,
          category: svcCategory,
          icon: svcIcon,
          contactPerson: svcPerson,
          contactPhone: svcPhone,
          description: svcDesc,
          isActive: svcActive,
        });
      }
      setShowServiceModal(false);
      loadServices();
    } catch (err) {
      console.error(err);
      alert("Failed to save service");
    }
  };

  const confirmDeleteService = async () => {
    if (!serviceToDelete) return;
    try {
      await adminApi.deleteSamajService(serviceToDelete.id);
      setServiceToDelete(null);
      loadServices();
      loadPersons();
    } catch (err) {
      console.error(err);
      alert("Failed to delete service");
    }
  };

  const toggleServiceStatus = async (item: SamajServiceItem) => {
    try {
      await adminApi.updateSamajService(item.id, { isActive: !item.isActive });
      loadServices();
    } catch (err) {
      console.error(err);
    }
  };

  // --- PERSON ACTIONS ---
  const openCreatePerson = () => {
    setEditingPerson(null);
    if (services.length > 0) {
      setPersonServiceId(services[0].id);
    }
    setPersonName("");
    setPersonGujaratiName("");
    setPersonPhotoUrl("");
    setPersonPhone("");
    setPersonAddress("");
    setPersonCity("Ahmedabad");
    setPersonExperience("5+ Years");
    setPersonDesc("");
    setPersonActive(true);
    setShowPersonModal(true);
  };

  const openEditPerson = (p: SamajServicePersonItem) => {
    setEditingPerson(p);
    setPersonServiceId(p.serviceId);
    setPersonName(p.name);
    setPersonGujaratiName(p.gujaratiName || "");
    setPersonPhotoUrl(p.photoUrl || "");
    setPersonPhone(p.phone);
    setPersonAddress(p.address || "");
    setPersonCity(p.city || "Ahmedabad");
    setPersonExperience(p.experience || "");
    setPersonDesc(p.description || "");
    setPersonActive(p.isActive);
    setShowPersonModal(true);
  };

  const handlePersonSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!personName.trim() || !personPhone.trim() || !personServiceId) {
      alert("Please fill in required fields (Service, Name, and Phone)");
      return;
    }

    try {
      if (editingPerson) {
        await adminApi.updateSamajServicePerson(editingPerson.id, {
          serviceId: personServiceId,
          name: personName,
          gujaratiName: personGujaratiName,
          photoUrl: personPhotoUrl,
          phone: personPhone,
          address: personAddress,
          city: personCity,
          experience: personExperience,
          description: personDesc,
          isActive: personActive,
        });
      } else {
        await adminApi.createSamajServicePerson({
          serviceId: personServiceId,
          name: personName,
          gujaratiName: personGujaratiName,
          photoUrl: personPhotoUrl,
          phone: personPhone,
          address: personAddress,
          city: personCity,
          experience: personExperience,
          description: personDesc,
          isActive: personActive,
        });
      }
      setShowPersonModal(false);
      loadPersons();
    } catch (err) {
      console.error(err);
      alert("Failed to save service person");
    }
  };

  const confirmDeletePerson = async () => {
    if (!personToDelete) return;
    try {
      await adminApi.deleteSamajServicePerson(personToDelete.id);
      setPersonToDelete(null);
      loadPersons();
    } catch (err) {
      console.error(err);
      alert("Failed to delete service person");
    }
  };

  const togglePersonStatus = async (item: SamajServicePersonItem) => {
    try {
      await adminApi.updateSamajServicePerson(item.id, { isActive: !item.isActive });
      loadPersons();
    } catch (err) {
      console.error(err);
    }
  };

  const filteredServices = services.filter(
    (s) =>
      s.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (s.category && s.category.toLowerCase().includes(searchQuery.toLowerCase()))
  );

  const filteredPersons = persons.filter(
    (p) =>
      p.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (p.gujaratiName && p.gujaratiName.toLowerCase().includes(searchQuery.toLowerCase())) ||
      (p.phone && p.phone.includes(searchQuery)) ||
      (p.service?.title && p.service.title.toLowerCase().includes(searchQuery.toLowerCase()))
  );

  return (
    <AdminLayout title="Samaj Services" subtitle="Manage Vankar Samaj service categories & contact persons">
      <div style={{ display: "flex", flexDirection: "column", gap: "24px" }}>
        
        {/* Page Header */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", flexWrap: "wrap", gap: "16px" }}>
          <div>
            <h1 style={{ fontSize: "24px", fontWeight: 800, color: "#D4AF37", margin: 0 }}>
              🤝 Samaj Services & Persons Directory (સમાજ સેવાઓ)
            </h1>
            <p style={{ fontSize: "14px", color: "rgba(255, 255, 255, 0.7)", margin: "4px 0 0 0" }}>
              Manage relational Samaj Services (Categories) and associated Service Persons.
            </p>
          </div>

          <div style={{ display: "flex", gap: "12px" }}>
            {activeTab === "services" ? (
              <button
                onClick={openCreateService}
                style={{
                  padding: "12px 22px",
                  background: "linear-gradient(90deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)",
                  border: "none",
                  borderRadius: "12px",
                  color: "#000",
                  fontWeight: 800,
                  fontSize: "14px",
                  cursor: "pointer",
                  boxShadow: "0 0 15px rgba(212, 175, 55, 0.3)",
                  display: "flex",
                  alignItems: "center",
                  gap: "8px",
                }}
              >
                <span>✨</span>
                <span>Add Service Category</span>
              </button>
            ) : (
              <button
                onClick={openCreatePerson}
                style={{
                  padding: "12px 22px",
                  background: "linear-gradient(90deg, #10B981 0%, #A7F3D0 100%)",
                  border: "none",
                  borderRadius: "12px",
                  color: "#000",
                  fontWeight: 800,
                  fontSize: "14px",
                  cursor: "pointer",
                  boxShadow: "0 0 15px rgba(16, 185, 129, 0.3)",
                  display: "flex",
                  alignItems: "center",
                  gap: "8px",
                }}
              >
                <span>👤</span>
                <span>Add Service Person</span>
              </button>
            )}
          </div>
        </div>

        {/* Tab Navigation */}
        <div style={{ display: "flex", gap: "12px", borderBottom: "1.5px solid rgba(212, 175, 55, 0.3)", paddingBottom: "12px" }}>
          <button
            onClick={() => setActiveTab("services")}
            style={{
              padding: "10px 24px",
              borderRadius: "10px",
              border: activeTab === "services" ? "1.5px solid #D4AF37" : "1px solid rgba(255,255,255,0.1)",
              backgroundColor: activeTab === "services" ? "rgba(212, 175, 55, 0.2)" : "transparent",
              color: activeTab === "services" ? "#F3E5AB" : "rgba(255,255,255,0.6)",
              fontWeight: 800,
              fontSize: "14px",
              cursor: "pointer",
              display: "flex",
              alignItems: "center",
              gap: "8px",
            }}
          >
            <span>🛠️ Section 1: Samaj Services</span>
            <span style={{ padding: "2px 8px", borderRadius: "10px", backgroundColor: "#D4AF37", color: "#000", fontSize: "11px", fontWeight: 900 }}>
              {services.length}
            </span>
          </button>

          <button
            onClick={() => setActiveTab("persons")}
            style={{
              padding: "10px 24px",
              borderRadius: "10px",
              border: activeTab === "persons" ? "1.5px solid #10B981" : "1px solid rgba(255,255,255,0.1)",
              backgroundColor: activeTab === "persons" ? "rgba(16, 185, 129, 0.2)" : "transparent",
              color: activeTab === "persons" ? "#A7F3D0" : "rgba(255,255,255,0.6)",
              fontWeight: 800,
              fontSize: "14px",
              cursor: "pointer",
              display: "flex",
              alignItems: "center",
              gap: "8px",
            }}
          >
            <span>👥 Section 2: Service Persons</span>
            <span style={{ padding: "2px 8px", borderRadius: "10px", backgroundColor: "#10B981", color: "#000", fontSize: "11px", fontWeight: 900 }}>
              {persons.length}
            </span>
          </button>
        </div>

        {/* SECTION 1: SERVICES TAB */}
        {activeTab === "services" && (
          <div style={{ backgroundColor: "#061224", borderRadius: "16px", border: "1.5px solid rgba(212, 175, 55, 0.3)", padding: "20px" }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "16px" }}>
              <input
                type="text"
                placeholder="Search services by title or category..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                style={{
                  width: "100%",
                  maxWidth: "400px",
                  padding: "10px 16px",
                  borderRadius: "10px",
                  backgroundColor: "#041026",
                  border: "1px solid rgba(212, 175, 55, 0.4)",
                  color: "#FFF",
                  fontSize: "14px",
                  outline: "none",
                }}
              />
            </div>

            {loadingServices ? (
              <div style={{ padding: "40px", textAlign: "center", color: "#D4AF37" }}>Loading Samaj Services...</div>
            ) : filteredServices.length === 0 ? (
              <div style={{ padding: "40px", textAlign: "center", color: "rgba(255, 255, 255, 0.6)" }}>No services found. Click "Add Service Category" to add one.</div>
            ) : (
              <div style={{ overflowX: "auto" }}>
                <table style={{ width: "100%", borderCollapse: "collapse", color: "#FFF", fontSize: "14px" }}>
                  <thead>
                    <tr style={{ borderBottom: "1.5px solid rgba(212, 175, 55, 0.3)", textAlign: "left" }}>
                      <th style={{ padding: "12px", color: "#D4AF37" }}>Service Title</th>
                      <th style={{ padding: "12px", color: "#D4AF37" }}>Category</th>
                      <th style={{ padding: "12px", color: "#D4AF37" }}>Associated Persons</th>
                      <th style={{ padding: "12px", color: "#D4AF37" }}>Status</th>
                      <th style={{ padding: "12px", color: "#D4AF37", textAlign: "right" }}>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {filteredServices.map((svc) => (
                      <tr key={svc.id} style={{ borderBottom: "1px solid rgba(255, 255, 255, 0.08)" }}>
                        <td style={{ padding: "14px 12px", fontWeight: 700 }}>
                          <span style={{ marginRight: "10px", fontSize: "18px" }}>{svc.icon || "🤝"}</span>
                          <span>{svc.title}</span>
                        </td>
                        <td style={{ padding: "14px 12px" }}>
                          <span style={{ padding: "4px 10px", borderRadius: "12px", backgroundColor: "rgba(212, 175, 55, 0.15)", color: "#F3E5AB", fontSize: "12px", fontWeight: 600 }}>
                            {svc.category || "General"}
                          </span>
                        </td>
                        <td style={{ padding: "14px 12px" }}>
                          <span style={{ padding: "4px 10px", borderRadius: "12px", backgroundColor: "rgba(16, 185, 129, 0.15)", color: "#A7F3D0", fontSize: "12px", fontWeight: 700 }}>
                            👤 {svc._count?.persons || 0} Persons
                          </span>
                        </td>
                        <td style={{ padding: "14px 12px" }}>
                          <button
                            onClick={() => toggleServiceStatus(svc)}
                            style={{
                              padding: "4px 12px",
                              borderRadius: "20px",
                              border: "none",
                              fontSize: "12px",
                              fontWeight: 700,
                              cursor: "pointer",
                              backgroundColor: svc.isActive ? "rgba(16, 185, 129, 0.2)" : "rgba(239, 68, 68, 0.2)",
                              color: svc.isActive ? "#10B981" : "#EF4444",
                            }}
                          >
                            {svc.isActive ? "Active" : "Disabled"}
                          </button>
                        </td>
                        <td style={{ padding: "14px 12px", textAlign: "right" }}>
                          <button
                            onClick={() => openEditService(svc)}
                            style={{
                              padding: "6px 14px",
                              marginRight: "8px",
                              borderRadius: "8px",
                              backgroundColor: "rgba(212, 175, 55, 0.2)",
                              border: "1px solid #D4AF37",
                              color: "#F3E5AB",
                              cursor: "pointer",
                              fontSize: "12px",
                              fontWeight: 700,
                            }}
                          >
                            Edit
                          </button>
                          <button
                            onClick={() => setServiceToDelete(svc)}
                            style={{
                              padding: "6px 14px",
                              borderRadius: "8px",
                              backgroundColor: "rgba(239, 68, 68, 0.2)",
                              border: "1px solid #EF4444",
                              color: "#FCA5A5",
                              cursor: "pointer",
                              fontSize: "12px",
                              fontWeight: 700,
                            }}
                          >
                            Delete
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        )}

        {/* SECTION 2: SERVICE PERSONS TAB */}
        {activeTab === "persons" && (
          <div style={{ backgroundColor: "#061224", borderRadius: "16px", border: "1.5px solid rgba(16, 185, 129, 0.3)", padding: "20px" }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "16px" }}>
              <input
                type="text"
                placeholder="Search persons by name, Gujarati name, phone, or service..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                style={{
                  width: "100%",
                  maxWidth: "400px",
                  padding: "10px 16px",
                  borderRadius: "10px",
                  backgroundColor: "#041026",
                  border: "1px solid rgba(16, 185, 129, 0.4)",
                  color: "#FFF",
                  fontSize: "14px",
                  outline: "none",
                }}
              />
            </div>

            {loadingPersons ? (
              <div style={{ padding: "40px", textAlign: "center", color: "#10B981" }}>Loading Service Persons...</div>
            ) : filteredPersons.length === 0 ? (
              <div style={{ padding: "40px", textAlign: "center", color: "rgba(255, 255, 255, 0.6)" }}>No service persons registered yet. Click "Add Service Person" above to add one.</div>
            ) : (
              <div style={{ overflowX: "auto" }}>
                <table style={{ width: "100%", borderCollapse: "collapse", color: "#FFF", fontSize: "14px" }}>
                  <thead>
                    <tr style={{ borderBottom: "1.5px solid rgba(16, 185, 129, 0.3)", textAlign: "left" }}>
                      <th style={{ padding: "12px", color: "#A7F3D0" }}>Person Name</th>
                      <th style={{ padding: "12px", color: "#A7F3D0" }}>Gujarati Name</th>
                      <th style={{ padding: "12px", color: "#A7F3D0" }}>Assigned Service</th>
                      <th style={{ padding: "12px", color: "#A7F3D0" }}>Phone</th>
                      <th style={{ padding: "12px", color: "#A7F3D0" }}>City / Locality</th>
                      <th style={{ padding: "12px", color: "#A7F3D0" }}>Status</th>
                      <th style={{ padding: "12px", color: "#A7F3D0", textAlign: "right" }}>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {filteredPersons.map((person) => (
                      <tr key={person.id} style={{ borderBottom: "1px solid rgba(255, 255, 255, 0.08)" }}>
                        <td style={{ padding: "14px 12px", fontWeight: 700 }}>
                          <span style={{ marginRight: "10px", fontSize: "16px" }}>👤</span>
                          <span>{person.name}</span>
                        </td>
                        <td style={{ padding: "14px 12px", color: "rgba(255, 255, 255, 0.85)", fontFamily: "sans-serif" }}>
                          {person.gujaratiName || "-"}
                        </td>
                        <td style={{ padding: "14px 12px" }}>
                          <span style={{ padding: "4px 10px", borderRadius: "12px", backgroundColor: "rgba(212, 175, 55, 0.15)", color: "#F3E5AB", fontSize: "12px", fontWeight: 700 }}>
                            {person.service?.icon || "🤝"} {person.service?.title || "Service"}
                          </span>
                        </td>
                        <td style={{ padding: "14px 12px", color: "#10B981", fontWeight: 700 }}>{person.phone}</td>
                        <td style={{ padding: "14px 12px", color: "rgba(255, 255, 255, 0.8)" }}>{person.city || "Ahmedabad"}</td>
                        <td style={{ padding: "14px 12px" }}>
                          <button
                            onClick={() => togglePersonStatus(person)}
                            style={{
                              padding: "4px 12px",
                              borderRadius: "20px",
                              border: "none",
                              fontSize: "12px",
                              fontWeight: 700,
                              cursor: "pointer",
                              backgroundColor: person.isActive ? "rgba(16, 185, 129, 0.2)" : "rgba(239, 68, 68, 0.2)",
                              color: person.isActive ? "#10B981" : "#EF4444",
                            }}
                          >
                            {person.isActive ? "Active" : "Disabled"}
                          </button>
                        </td>
                        <td style={{ padding: "14px 12px", textAlign: "right" }}>
                          <button
                            onClick={() => openEditPerson(person)}
                            style={{
                              padding: "6px 14px",
                              marginRight: "8px",
                              borderRadius: "8px",
                              backgroundColor: "rgba(16, 185, 129, 0.2)",
                              border: "1px solid #10B981",
                              color: "#A7F3D0",
                              cursor: "pointer",
                              fontSize: "12px",
                              fontWeight: 700,
                            }}
                          >
                            Edit
                          </button>
                          <button
                            onClick={() => setPersonToDelete(person)}
                            style={{
                              padding: "6px 14px",
                              borderRadius: "8px",
                              backgroundColor: "rgba(239, 68, 68, 0.2)",
                              border: "1px solid #EF4444",
                              color: "#FCA5A5",
                              cursor: "pointer",
                              fontSize: "12px",
                              fontWeight: 700,
                            }}
                          >
                            Delete
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        )}

        {/* MODAL: ADD / EDIT SAMAJ SERVICE */}
        {showServiceModal && (
          <div style={{ position: "fixed", inset: 0, backgroundColor: "rgba(0,0,0,0.85)", display: "flex", alignItems: "center", justifyContent: "center", zIndex: 100, padding: "20px" }}>
            <div style={{ backgroundColor: "#061224", border: "2px solid #D4AF37", borderRadius: "16px", padding: "24px", maxWidth: "520px", width: "100%", color: "#FFF", boxShadow: "0 0 30px rgba(212, 175, 55, 0.3)" }}>
              <h2 style={{ fontSize: "18px", fontWeight: 800, color: "#D4AF37", margin: "0 0 16px 0" }}>
                {editingService ? "Edit Samaj Service Category" : "Add New Samaj Service Category"}
              </h2>

              <form onSubmit={handleServiceSubmit} style={{ display: "flex", flexDirection: "column", gap: "14px" }}>
                <div>
                  <label style={{ fontSize: "12px", fontWeight: 700, color: "rgba(212, 175, 55, 0.9)", display: "block", marginBottom: "4px" }}>
                    Service Title (e.g. Electrician / મંડપ ડેકોરેશન) *
                  </label>
                  <input
                    type="text"
                    required
                    value={svcTitle}
                    onChange={(e) => setSvcTitle(e.target.value)}
                    placeholder="e.g. Electrical Works & Lighting"
                    style={{ width: "100%", padding: "10px", borderRadius: "8px", backgroundColor: "#041026", border: "1px solid rgba(212, 175, 55, 0.4)", color: "#FFF" }}
                  />
                </div>

                <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "12px" }}>
                  <div>
                    <label style={{ fontSize: "12px", fontWeight: 700, color: "rgba(212, 175, 55, 0.9)", display: "block", marginBottom: "4px" }}>
                      Category Mapping
                    </label>
                    <select
                      value={svcCategory}
                      onChange={(e) => setSvcCategory(e.target.value)}
                      style={{ width: "100%", padding: "10px", borderRadius: "8px", backgroundColor: "#041026", border: "1px solid rgba(212, 175, 55, 0.4)", color: "#FFF" }}
                    >
                      <option value="E – Electrical Works & Lighting">⚡ E – Electrical Works & Lighting</option>
                      <option value="A – AC Repair & Services | Audio & Sound">🔧 A – AC Repair & Sound</option>
                      <option value="B – Beauty Parlor & Bridal Makeup">💄 B – Beauty Parlor & Bridal</option>
                      <option value="C – Cameraman & Photography | Car Rental">📸 C – Photography & Car Rental</option>
                      <option value="D – Drone Videography | DJ Sound">🛸 D – Drone & DJ Sound</option>
                      <option value="M – Mandap & Decoration | Mehendi Artist">⛺ M – Mandap & Decoration</option>
                      <option value="General">🤝 General Service</option>
                    </select>
                  </div>

                  <div>
                    <label style={{ fontSize: "12px", fontWeight: 700, color: "rgba(212, 175, 55, 0.9)", display: "block", marginBottom: "4px" }}>
                      Icon / Emoji
                    </label>
                    <input
                      type="text"
                      value={svcIcon}
                      onChange={(e) => setSvcIcon(e.target.value)}
                      placeholder="⚡"
                      style={{ width: "100%", padding: "10px", borderRadius: "8px", backgroundColor: "#041026", border: "1px solid rgba(212, 175, 55, 0.4)", color: "#FFF" }}
                    />
                  </div>
                </div>

                <div>
                  <label style={{ fontSize: "12px", fontWeight: 700, color: "rgba(212, 175, 55, 0.9)", display: "block", marginBottom: "4px" }}>
                    Service Description
                  </label>
                  <textarea
                    rows={3}
                    value={svcDesc}
                    onChange={(e) => setSvcDesc(e.target.value)}
                    placeholder="Describe the service details..."
                    style={{ width: "100%", padding: "10px", borderRadius: "8px", backgroundColor: "#041026", border: "1px solid rgba(212, 175, 55, 0.4)", color: "#FFF" }}
                  />
                </div>

                <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
                  <input
                    type="checkbox"
                    id="svcActiveCheck"
                    checked={svcActive}
                    onChange={(e) => setSvcActive(e.target.checked)}
                  />
                  <label htmlFor="svcActiveCheck" style={{ fontSize: "13px", color: "#FFF" }}>
                    Make Active in Flutter Mobile App
                  </label>
                </div>

                <div style={{ display: "flex", justifyContent: "flex-end", gap: "10px", marginTop: "12px" }}>
                  <button
                    type="button"
                    onClick={() => setShowServiceModal(false)}
                    style={{ padding: "10px 18px", borderRadius: "8px", backgroundColor: "transparent", border: "1px solid rgba(255,255,255,0.3)", color: "#FFF", cursor: "pointer" }}
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    style={{ padding: "10px 22px", borderRadius: "8px", backgroundColor: "#D4AF37", border: "none", color: "#000", fontWeight: 800, cursor: "pointer" }}
                  >
                    {editingService ? "Save Changes" : "Create Service"}
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}

        {/* MODAL: ADD / EDIT SERVICE PERSON */}
        {showPersonModal && (
          <div style={{ position: "fixed", inset: 0, backgroundColor: "rgba(0,0,0,0.85)", display: "flex", alignItems: "center", justifyContent: "center", zIndex: 100, padding: "20px" }}>
            <div style={{ backgroundColor: "#061224", border: "2px solid #10B981", borderRadius: "16px", padding: "24px", maxWidth: "560px", width: "100%", color: "#FFF", boxShadow: "0 0 30px rgba(16, 185, 129, 0.3)" }}>
              <h2 style={{ fontSize: "18px", fontWeight: 800, color: "#10B981", margin: "0 0 16px 0" }}>
                {editingPerson ? "Edit Service Person Details" : "Add Service Person under Category"}
              </h2>

              <form onSubmit={handlePersonSubmit} style={{ display: "flex", flexDirection: "column", gap: "14px" }}>
                <div>
                  <label style={{ fontSize: "12px", fontWeight: 700, color: "#A7F3D0", display: "block", marginBottom: "4px" }}>
                    Select Associated Samaj Service Category *
                  </label>
                  <select
                    required
                    value={personServiceId}
                    onChange={(e) => setPersonServiceId(e.target.value)}
                    style={{ width: "100%", padding: "10px", borderRadius: "8px", backgroundColor: "#041026", border: "1px solid rgba(16, 185, 129, 0.4)", color: "#FFF", fontSize: "14px" }}
                  >
                    {services.map((s) => (
                      <option key={s.id} value={s.id}>
                        {s.icon || "🤝"} {s.title} ({s.category || "General"})
                      </option>
                    ))}
                  </select>
                </div>

                <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "12px" }}>
                  <div>
                    <label style={{ fontSize: "12px", fontWeight: 700, color: "#A7F3D0", display: "block", marginBottom: "4px" }}>
                      Person Full Name (English) *
                    </label>
                    <input
                      type="text"
                      required
                      value={personName}
                      onChange={(e) => setPersonName(e.target.value)}
                      placeholder="e.g. Rameshbhai Vankar"
                      style={{ width: "100%", padding: "10px", borderRadius: "8px", backgroundColor: "#041026", border: "1px solid rgba(16, 185, 129, 0.4)", color: "#FFF" }}
                    />
                  </div>

                  <div>
                    <label style={{ fontSize: "12px", fontWeight: 700, color: "#A7F3D0", display: "block", marginBottom: "4px" }}>
                      Gujarati Name (ગુજરાતી નામ)
                    </label>
                    <input
                      type="text"
                      value={personGujaratiName}
                      onChange={(e) => setPersonGujaratiName(e.target.value)}
                      placeholder="દા.ત. રમેશભાઈ વણકર"
                      style={{ width: "100%", padding: "10px", borderRadius: "8px", backgroundColor: "#041026", border: "1px solid rgba(16, 185, 129, 0.4)", color: "#FFF" }}
                    />
                  </div>
                </div>

                <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "12px" }}>
                  <div>
                    <label style={{ fontSize: "12px", fontWeight: 700, color: "#A7F3D0", display: "block", marginBottom: "4px" }}>
                      Phone Number *
                    </label>
                    <input
                      type="text"
                      required
                      value={personPhone}
                      onChange={(e) => setPersonPhone(e.target.value)}
                      placeholder="+91 98765 43210"
                      style={{ width: "100%", padding: "10px", borderRadius: "8px", backgroundColor: "#041026", border: "1px solid rgba(16, 185, 129, 0.4)", color: "#FFF" }}
                    />
                  </div>

                  <div>
                    <label style={{ fontSize: "12px", fontWeight: 700, color: "#A7F3D0", display: "block", marginBottom: "4px" }}>
                      City / Area Location
                    </label>
                    <input
                      type="text"
                      value={personCity}
                      onChange={(e) => setPersonCity(e.target.value)}
                      placeholder="e.g. Ahmedabad / Vadodara"
                      style={{ width: "100%", padding: "10px", borderRadius: "8px", backgroundColor: "#041026", border: "1px solid rgba(16, 185, 129, 0.4)", color: "#FFF" }}
                    />
                  </div>
                </div>

                <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "12px" }}>
                  <div>
                    <label style={{ fontSize: "12px", fontWeight: 700, color: "#A7F3D0", display: "block", marginBottom: "4px" }}>
                      Experience
                    </label>
                    <input
                      type="text"
                      value={personExperience}
                      onChange={(e) => setPersonExperience(e.target.value)}
                      placeholder="e.g. 5+ Years"
                      style={{ width: "100%", padding: "10px", borderRadius: "8px", backgroundColor: "#041026", border: "1px solid rgba(16, 185, 129, 0.4)", color: "#FFF" }}
                    />
                  </div>

                  <div>
                    <label style={{ fontSize: "12px", fontWeight: 700, color: "#A7F3D0", display: "block", marginBottom: "4px" }}>
                      Photo URL (Optional)
                    </label>
                    <input
                      type="text"
                      value={personPhotoUrl}
                      onChange={(e) => setPersonPhotoUrl(e.target.value)}
                      placeholder="https://..."
                      style={{ width: "100%", padding: "10px", borderRadius: "8px", backgroundColor: "#041026", border: "1px solid rgba(16, 185, 129, 0.4)", color: "#FFF" }}
                    />
                  </div>
                </div>

                <div>
                  <label style={{ fontSize: "12px", fontWeight: 700, color: "#A7F3D0", display: "block", marginBottom: "4px" }}>
                    Address / Workplace Details
                  </label>
                  <textarea
                    rows={2}
                    value={personAddress}
                    onChange={(e) => setPersonAddress(e.target.value)}
                    placeholder="Full workplace address..."
                    style={{ width: "100%", padding: "10px", borderRadius: "8px", backgroundColor: "#041026", border: "1px solid rgba(16, 185, 129, 0.4)", color: "#FFF" }}
                  />
                </div>

                <div style={{ display: "flex", alignItems: "center", gap: "8px" }}>
                  <input
                    type="checkbox"
                    id="personActiveCheck"
                    checked={personActive}
                    onChange={(e) => setPersonActive(e.target.checked)}
                  />
                  <label htmlFor="personActiveCheck" style={{ fontSize: "13px", color: "#FFF" }}>
                    Publish person profile actively in mobile app
                  </label>
                </div>

                <div style={{ display: "flex", justifyContent: "flex-end", gap: "10px", marginTop: "12px" }}>
                  <button
                    type="button"
                    onClick={() => setShowPersonModal(false)}
                    style={{ padding: "10px 18px", borderRadius: "8px", backgroundColor: "transparent", border: "1px solid rgba(255,255,255,0.3)", color: "#FFF", cursor: "pointer" }}
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    style={{ padding: "10px 22px", borderRadius: "8px", backgroundColor: "#10B981", border: "none", color: "#000", fontWeight: 800, cursor: "pointer" }}
                  >
                    {editingPerson ? "Save Changes" : "Create Person"}
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}

        {/* CASCADING DELETE CONFIRMATION MODAL FOR SERVICE */}
        {serviceToDelete && (
          <div style={{ position: "fixed", inset: 0, backgroundColor: "rgba(0,0,0,0.85)", display: "flex", alignItems: "center", justifyContent: "center", zIndex: 110, padding: "20px" }}>
            <div style={{ backgroundColor: "#061224", border: "2px solid #EF4444", borderRadius: "16px", padding: "24px", maxWidth: "480px", width: "100%", color: "#FFF", boxShadow: "0 0 30px rgba(239, 68, 68, 0.4)" }}>
              <div style={{ fontSize: "36px", marginBottom: "8px" }}>⚠️</div>
              <h2 style={{ fontSize: "18px", fontWeight: 800, color: "#EF4444", margin: "0 0 8px 0" }}>
                Confirm Service Deletion
              </h2>
              <p style={{ fontSize: "14px", color: "rgba(255,255,255,0.9)", lineHeight: 1.5, margin: "0 0 16px 0" }}>
                Deleting this service (<strong>{serviceToDelete.title}</strong>) will also automatically remove all service persons associated with this service!
              </p>
              <div style={{ padding: "12px", borderRadius: "8px", backgroundColor: "rgba(239, 68, 68, 0.15)", border: "1px solid rgba(239, 68, 68, 0.3)", fontSize: "12px", color: "#FCA5A5", marginBottom: "20px" }}>
                💡 <strong>Recommended:</strong> Instead of deleting, you can click "Disable / Deactivate" in the table to hide this service from the Flutter app without deleting historical data.
              </div>
              <div style={{ display: "flex", justifyContent: "flex-end", gap: "10px" }}>
                <button
                  onClick={() => setServiceToDelete(null)}
                  style={{ padding: "10px 18px", borderRadius: "8px", backgroundColor: "transparent", border: "1px solid rgba(255,255,255,0.3)", color: "#FFF", cursor: "pointer" }}
                >
                  Cancel
                </button>
                <button
                  onClick={confirmDeleteService}
                  style={{ padding: "10px 22px", borderRadius: "8px", backgroundColor: "#EF4444", border: "none", color: "#FFF", fontWeight: 800, cursor: "pointer" }}
                >
                  Yes, Delete Service & Persons
                </button>
              </div>
            </div>
          </div>
        )}

        {/* DELETE CONFIRMATION MODAL FOR PERSON */}
        {personToDelete && (
          <div style={{ position: "fixed", inset: 0, backgroundColor: "rgba(0,0,0,0.85)", display: "flex", alignItems: "center", justifyContent: "center", zIndex: 110, padding: "20px" }}>
            <div style={{ backgroundColor: "#061224", border: "2px solid #EF4444", borderRadius: "16px", padding: "24px", maxWidth: "440px", width: "100%", color: "#FFF", boxShadow: "0 0 30px rgba(239, 68, 68, 0.4)" }}>
              <h2 style={{ fontSize: "18px", fontWeight: 800, color: "#EF4444", margin: "0 0 8px 0" }}>
                Delete Service Person
              </h2>
              <p style={{ fontSize: "14px", color: "rgba(255,255,255,0.9)", margin: "0 0 20px 0" }}>
                Are you sure you want to remove <strong>{personToDelete.name}</strong> from the service directory?
              </p>
              <div style={{ display: "flex", justifyContent: "flex-end", gap: "10px" }}>
                <button
                  onClick={() => setPersonToDelete(null)}
                  style={{ padding: "10px 18px", borderRadius: "8px", backgroundColor: "transparent", border: "1px solid rgba(255,255,255,0.3)", color: "#FFF", cursor: "pointer" }}
                >
                  Cancel
                </button>
                <button
                  onClick={confirmDeletePerson}
                  style={{ padding: "10px 22px", borderRadius: "8px", backgroundColor: "#EF4444", border: "none", color: "#FFF", fontWeight: 800, cursor: "pointer" }}
                >
                  Delete Person
                </button>
              </div>
            </div>
          </div>
        )}

      </div>
    </AdminLayout>
  );
}
