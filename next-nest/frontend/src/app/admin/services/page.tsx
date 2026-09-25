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
      <div  className="flex flex-col gap-6">
        
        {/* Page Header */}
        <div  className="flex justify-between items-center flex-wrap gap-4">
          <div>
            <h1  style={{ margin: 0 }} className="font-extrabold text-admin-gold text-2xl">
              🤝 Samaj Services & Persons Directory (સમાજ સેવાઓ)
            </h1>
            <p  style={{ color: "rgba(255, 255, 255, 0.7)", margin: "4px 0 0 0" }} className="text-sm">
              Manage relational Samaj Services (Categories) and associated Service Persons.
            </p>
          </div>

          <div  style={{ gap: "12px" }} className="flex">
            {activeTab === "services" ? (
              <button
                onClick={openCreateService}
                  style={{ padding: "12px 22px", background: "linear-gradient(90deg, #D4AF37 0%, #F3E5AB 50%, #C59B27 100%)", color: "#000", boxShadow: "0 0 15px rgba(212, 175, 55, 0.3)" }} className="flex items-center font-extrabold cursor-pointer text-sm gap-2 rounded-xl border-none" 
              >
                <span>✨</span>
                <span>Add Service Category</span>
              </button>
            ) : (
              <button
                onClick={openCreatePerson}
                  style={{ padding: "12px 22px", background: "linear-gradient(90deg, #10B981 0%, #A7F3D0 100%)", color: "#000", boxShadow: "0 0 15px rgba(16, 185, 129, 0.3)" }} className="flex items-center font-extrabold cursor-pointer text-sm gap-2 rounded-xl border-none" 
              >
                <span>👤</span>
                <span>Add Service Person</span>
              </button>
            )}
          </div>
        </div>

        {/* Tab Navigation */}
        <div  style={{ gap: "12px", borderBottom: "1.5px solid rgba(212, 175, 55, 0.3)", paddingBottom: "12px" }} className="flex">
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
            <span  style={{ padding: "2px 8px", borderRadius: "10px", backgroundColor: "#D4AF37", color: "#000", fontWeight: 900 }} className="text-[11px]">
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
            <span  style={{ padding: "2px 8px", borderRadius: "10px", backgroundColor: "#10B981", color: "#000", fontWeight: 900 }} className="text-[11px]">
              {persons.length}
            </span>
          </button>
        </div>

        {/* SECTION 1: SERVICES TAB */}
        {activeTab === "services" && (
          <div  style={{ backgroundColor: "#061224", border: "1.5px solid rgba(212, 175, 55, 0.3)", padding: "20px" }} className="rounded-2xl">
            <div  style={{ marginBottom: "16px" }} className="flex justify-between items-center">
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
              <div  style={{ padding: "40px" }} className="text-center text-admin-gold">Loading Samaj Services...</div>
            ) : filteredServices.length === 0 ? (
              <div  style={{ padding: "40px", color: "rgba(255, 255, 255, 0.6)" }} className="text-center">No services found. Click "Add Service Category" to add one.</div>
            ) : (
              <div style={{ overflowX: "auto" }}>
                <table  style={{ color: "#FFF" }} className="w-full border-collapse text-sm">
                  <thead>
                    <tr  style={{ borderBottom: "1.5px solid rgba(212, 175, 55, 0.3)" }} className="text-left">
                      <th  style={{ padding: "12px" }} className="text-admin-gold">Service Title</th>
                      <th  style={{ padding: "12px" }} className="text-admin-gold">Category</th>
                      <th  style={{ padding: "12px" }} className="text-admin-gold">Associated Persons</th>
                      <th  style={{ padding: "12px" }} className="text-admin-gold">Status</th>
                      <th  style={{ padding: "12px" }} className="text-right text-admin-gold">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {filteredServices.map((svc) => (
                      <tr key={svc.id} style={{ borderBottom: "1px solid rgba(255, 255, 255, 0.08)" }}>
                        <td  style={{ padding: "14px 12px" }} className="font-bold">
                          <span style={{ marginRight: "10px", fontSize: "18px" }}>{svc.icon || "🤝"}</span>
                          <span>{svc.title}</span>
                        </td>
                        <td style={{ padding: "14px 12px" }}>
                          <span  style={{ padding: "4px 10px", backgroundColor: "rgba(212, 175, 55, 0.15)", color: "#F3E5AB" }} className="font-semibold text-xs rounded-xl">
                            {svc.category || "General"}
                          </span>
                        </td>
                        <td style={{ padding: "14px 12px" }}>
                          <span  style={{ padding: "4px 10px", backgroundColor: "rgba(16, 185, 129, 0.15)", color: "#A7F3D0" }} className="font-bold text-xs rounded-xl">
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
                        <td  style={{ padding: "14px 12px" }} className="text-right">
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
          <div  style={{ backgroundColor: "#061224", border: "1.5px solid rgba(16, 185, 129, 0.3)", padding: "20px" }} className="rounded-2xl">
            <div  style={{ marginBottom: "16px" }} className="flex justify-between items-center">
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
              <div  style={{ padding: "40px", color: "#10B981" }} className="text-center">Loading Service Persons...</div>
            ) : filteredPersons.length === 0 ? (
              <div  style={{ padding: "40px", color: "rgba(255, 255, 255, 0.6)" }} className="text-center">No service persons registered yet. Click "Add Service Person" above to add one.</div>
            ) : (
              <div style={{ overflowX: "auto" }}>
                <table  style={{ color: "#FFF" }} className="w-full border-collapse text-sm">
                  <thead>
                    <tr  style={{ borderBottom: "1.5px solid rgba(16, 185, 129, 0.3)" }} className="text-left">
                      <th style={{ padding: "12px", color: "#A7F3D0" }}>Person Name</th>
                      <th style={{ padding: "12px", color: "#A7F3D0" }}>Gujarati Name</th>
                      <th style={{ padding: "12px", color: "#A7F3D0" }}>Assigned Service</th>
                      <th style={{ padding: "12px", color: "#A7F3D0" }}>Phone</th>
                      <th style={{ padding: "12px", color: "#A7F3D0" }}>City / Locality</th>
                      <th style={{ padding: "12px", color: "#A7F3D0" }}>Status</th>
                      <th  style={{ padding: "12px", color: "#A7F3D0" }} className="text-right">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {filteredPersons.map((person) => (
                      <tr key={person.id} style={{ borderBottom: "1px solid rgba(255, 255, 255, 0.08)" }}>
                        <td  style={{ padding: "14px 12px" }} className="font-bold">
                          <span  style={{ marginRight: "10px" }} className="text-base">👤</span>
                          <span>{person.name}</span>
                        </td>
                        <td style={{ padding: "14px 12px", color: "rgba(255, 255, 255, 0.85)", fontFamily: "sans-serif" }}>
                          {person.gujaratiName || "-"}
                        </td>
                        <td style={{ padding: "14px 12px" }}>
                          <span  style={{ padding: "4px 10px", backgroundColor: "rgba(212, 175, 55, 0.15)", color: "#F3E5AB" }} className="font-bold text-xs rounded-xl">
                            {person.service?.icon || "🤝"} {person.service?.title || "Service"}
                          </span>
                        </td>
                        <td  style={{ padding: "14px 12px", color: "#10B981" }} className="font-bold">{person.phone}</td>
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
                        <td  style={{ padding: "14px 12px" }} className="text-right">
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
          <div  style={{ inset: 0, backgroundColor: "rgba(0, 0, 0, 0.85)", zIndex: 100, padding: "20px" }} className="flex justify-center items-center fixed">
            <div  style={{ backgroundColor: "#061224", border: "2px solid #D4AF37", maxWidth: "520px", color: "#FFF", boxShadow: "0 0 30px rgba(212, 175, 55, 0.3)" }} className="w-full p-6 rounded-2xl">
              <h2  style={{ fontSize: "18px", margin: "0 0 16px 0" }} className="font-extrabold text-admin-gold">
                {editingService ? "Edit Samaj Service Category" : "Add New Samaj Service Category"}
              </h2>

              <form onSubmit={handleServiceSubmit}  className="flex flex-col gap-[14px]">
                <div>
                  <label  style={{ color: "rgba(212, 175, 55, 0.9)", display: "block", marginBottom: "4px" }} className="font-bold text-xs">
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
                    <label  style={{ color: "rgba(212, 175, 55, 0.9)", display: "block", marginBottom: "4px" }} className="font-bold text-xs">
                      Category Mapping
                    </label>
                    <select
                      value={svcCategory}
                      onChange={(e) => setSvcCategory(e.target.value)}
                      style={{ width: "100%", padding: "10px", borderRadius: "8px", backgroundColor: "#041026", border: "1px solid rgba(212, 175, 55, 0.4)", color: "#FFF" }}
                    >
                      <optgroup label="🏠 1. ઘર અને દૈનિક જીવનની સેવાઓ (Home & Daily Life)">
                        <option value="Home & Daily Life Services">🏠 1. ઘર અને દૈનિક જીવનની સેવાઓ (Main Category)</option>
                        <option value="Construction">🏠 ઘર બાંધકામ / Construction</option>
                        <option value="Mason Work">🧱 Mason / Raj Mistri (રાજ મિસ્ત્રી)</option>
                        <option value="Painter">🎨 Painter (કલરકામ & પેઇન્ટિંગ)</option>
                        <option value="Plumber">🔧 Plumber (પ્લમ્બિંગ & ગીઝર)</option>
                        <option value="Electrician">⚡ Electrician (ઇલેક્ટ્રિશિયન & વાયરિંગ)</option>
                        <option value="AC & Fridge Repair">❄️ AC / Fridge Repair (એસી & ફ્રિજ રીપેર)</option>
                        <option value="Carpenter">🪚 Carpenter (સુથારીકામ & ફર્નિચર)</option>
                        <option value="Aluminium & Glass">🪟 Aluminium / Glass Work</option>
                        <option value="Furniture & Interior">🚪 Furniture / Interior Design</option>
                        <option value="House Cleaning">🧹 House Cleaning & Housekeeping</option>
                        <option value="Pest Control">🐜 Pest Control (ઉધઇ & જંતુનાશક)</option>
                        <option value="Packers & Movers">🚚 Packers & Movers (શિફ્ટિંગ)</option>
                      </optgroup>
                      <optgroup label="🚗 2. Vehicle & Transport">
                        <option value="Vehicle & Transport">🚗 2. Vehicle & Transport (Main Category)</option>
                        <option value="Car Rental">🚗 Car Rental (કાર રેન્ટલ & બુકિંગ)</option>
                        <option value="Bike Repair">🛵 Bike / Scooter Repair</option>
                        <option value="Car Garage">🚘 Car Repair / Garage</option>
                        <option value="Tyre & Puncture">🛞 Tyre & Puncture (પંચર સર્વિસ)</option>
                        <option value="Battery Service">🔋 Battery Service</option>
                        <option value="Taxi Service">🚕 Taxi / Cab Service</option>
                        <option value="Bus & Tempo">🚌 Bus / Tempo Transport</option>
                        <option value="Goods Transport">🚛 Goods Transport (માલસામાન)</option>
                        <option value="Driver Service">🚗 Driver Service (ડ્રાઇવર)</option>
                        <option value="Parking Service">🅿️ Parking Service</option>
                      </optgroup>
                      <optgroup label="💻 3. Computer & Digital Services">
                        <option value="Computer & Digital Services">💻 3. Computer & Digital Services (Main Category)</option>
                        <option value="Computer Repair">💻 Computer / Laptop Repair</option>
                        <option value="Printer Repair">🖨️ Printer Repair & Cartridge</option>
                        <option value="Mobile Repair">📱 Mobile Repair (મોબાઇલ સર્વિસ)</option>
                        <option value="Website Development">🌐 Website Development</option>
                        <option value="App Development">📱 App Development</option>
                        <option value="Graphic Design">🎨 Graphic Design & Banner</option>
                        <option value="Printing & Xerox">🖨️ Printing / Xerox Press</option>
                        <option value="Photo Studio">📸 Photo Studio & Photography</option>
                        <option value="Online Form Filling">🪪 Online Form Filling (સરકારી ફોર્મ)</option>
                        <option value="Document Scanning">📄 Document Scanning & PDF</option>
                        <option value="Digital Payment">💳 Digital Payment Assistance</option>
                      </optgroup>
                      <optgroup label="📚 4. Education Services">
                        <option value="Education Services">📚 4. Education Services (Main Category)</option>
                        <option value="Tuition & Coaching">👨🏫 Tuition / Coaching Classes</option>
                        <option value="School Admission">🏫 School Admission Guidance</option>
                        <option value="College Admission">🎓 College Admission Guidance</option>
                        <option value="Competitive Exams">📝 Competitive Exam Coaching (GPSC/TET)</option>
                        <option value="Career Guidance">💼 Career Guidance & Mentorship</option>
                        <option value="Foreign Study">🌍 Foreign Study Guidance (વિદેશ અભ્યાસ)</option>
                        <option value="Books & Stationery">📖 Books / Stationery Shop</option>
                        <option value="Computer Training">💻 Computer Training Institute</option>
                        <option value="English Speaking">🗣️ English Speaking Course</option>
                        <option value="Scholarship Info">🏆 Scholarship Information</option>
                      </optgroup>
                      <optgroup label="💼 5. Job & Business Services">
                        <option value="Job & Business Services">💼 5. Job & Business Services (Main Category)</option>
                        <option value="Job Placement">💼 Job Placement (નોકરી માહિતી)</option>
                        <option value="Skilled Jobs">👷 Skilled Worker Jobs</option>
                        <option value="Private Jobs">🏢 Private Job Information</option>
                        <option value="Government Jobs">🏛️ Government Job Guidance</option>
                        <option value="Resume & CV">📄 Resume / CV Making</option>
                        <option value="Interview Prep">💼 Interview Preparation</option>
                        <option value="Business Directory">🏪 Business Directory (વેપારી ડિરેક્ટરી)</option>
                        <option value="Business Networking">🤝 Business Networking</option>
                        <option value="Business Consultant">📈 Business Consultant</option>
                        <option value="GST & Tax">🧾 GST / Tax Consultant</option>
                      </optgroup>
                      <optgroup label="⚖️ 6. Legal & Financial Services">
                        <option value="Legal & Financial Services">⚖️ 6. Legal & Financial Services (Main Category)</option>
                        <option value="Advocate & Legal">⚖️ Advocate / Legal Advice (વકીલ સલાહ)</option>
                        <option value="Document Writer">📑 Document Writer (દસ્તાવેજ લેખક)</option>
                        <option value="Bank Loan">🏦 Bank Loan Assistance (હોમ/બિઝનેસ લોન)</option>
                        <option value="Financial Consultant">💰 Financial Consultant</option>
                        <option value="Income Tax">🧾 Income Tax / GST Filing</option>
                        <option value="Property Docs">🏠 Property Documents & Registry</option>
                        <option value="Insurance Agent">📜 Insurance Agent (લાઇફ/મેડીક્લેમ)</option>
                        <option value="Finance Services">💳 Loan / Finance Services</option>
                        <option value="Banking Assistance">🏦 Banking Assistance</option>
                      </optgroup>
                      <optgroup label="🏥 7. Health & Emergency">
                        <option value="Health & Emergency">🏥 7. Health & Emergency (Main Category)</option>
                        <option value="Hospital">🏥 Hospital (હોસ્પિટલ)</option>
                        <option value="Doctor">👨⚕️ Doctor (ડૉક્ટર પેનલ)</option>
                        <option value="Dentist">🦷 Dentist (દાંતના ડૉક્ટર)</option>
                        <option value="Eye Care">👓 Eye Care (આંખના ડૉક્ટર/ચશ્મા)</option>
                        <option value="Medical Store">💊 Medical Store (દવાની દુકાન)</option>
                        <option value="Ambulance">🚑 Ambulance (એમ્બ્યુલન્સ ૨૪x૭)</option>
                        <option value="Blood Bank">🩸 Blood Donor Directory (રક્તદાતા)</option>
                        <option value="Diagnostic Lab">🧪 Laboratory / Diagnostic</option>
                        <option value="Home Nursing">🧑⚕️ Home Nursing Care</option>
                        <option value="Elderly Assistance">♿ Elderly Assistance (વરિષ્ઠ સહાય)</option>
                      </optgroup>
                      <optgroup label="🏪 8. Business & Local Shops">
                        <option value="Business & Local Shops">🏪 8. Business & Local Shops (Main Category)</option>
                        <option value="Grocery Shop">🛒 Grocery (કરિયાણું)</option>
                        <option value="Garments">👗 Clothes / Garments (કપડાં)</option>
                        <option value="Footwear">👟 Footwear (શૂઝ/ચંપલ)</option>
                        <option value="Mobile Shop">📱 Mobile Shop (મોબાઇલ દુકાન)</option>
                        <option value="Electronics">💻 Electronics Shop</option>
                        <option value="Furniture Shop">🪑 Furniture Shop</option>
                        <option value="Jewellery">💎 Jewellery (સોના-ચાંદી જ્વેલર્સ)</option>
                        <option value="Bakery">🍰 Bakery & Sweets</option>
                        <option value="Restaurant">🍽️ Restaurant / Food Zone</option>
                        <option value="Printing Press">🖨️ Printing Press</option>
                      </optgroup>
                      <optgroup label="🧑🔧 9. Skilled Professionals">
                        <option value="Skilled Professionals">🧑🔧 9. Skilled Professionals (Main Category)</option>
                        <option value="Electrician Trade">👨🔧 Electrician (ઇલેક્ટ્રિશિયન)</option>
                        <option value="Plumber Trade">🔧 Plumber (પ્લમ્બર)</option>
                        <option value="Carpenter Trade">🪚 Carpenter (સુથાર)</option>
                        <option value="Welder">🔨 Welder (વેલ્ડર)</option>
                        <option value="Mason Trade">🧱 Mason (રાજ મિસ્ત્રી)</option>
                        <option value="Painter Trade">🎨 Painter (પેઇન્ટર)</option>
                        <option value="Computer Tech">👨💻 Computer Technician</option>
                        <option value="Mobile Tech">📱 Mobile Technician</option>
                        <option value="Mechanic">🚗 Mechanic (કાર/મોટર ગેરેજ)</option>
                        <option value="AC Tech">❄️ AC Technician</option>
                        <option value="TV Tech">📺 TV Technician</option>
                      </optgroup>
                    </select>
                  </div>

                  <div>
                    <label  style={{ color: "rgba(212, 175, 55, 0.9)", display: "block", marginBottom: "4px" }} className="font-bold text-xs">
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
                  <label  style={{ color: "rgba(212, 175, 55, 0.9)", display: "block", marginBottom: "4px" }} className="font-bold text-xs">
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

                <div  className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    id="svcActiveCheck"
                    checked={svcActive}
                    onChange={(e) => setSvcActive(e.target.checked)}
                  />
                  <label htmlFor="svcActiveCheck"  style={{ color: "#FFF" }} className="text-[13px]">
                    Make Active in Flutter Mobile App
                  </label>
                </div>

                <div  style={{ marginTop: "12px" }} className="flex justify-end gap-[10px]">
                  <button
                    type="button"
                    onClick={() => setShowServiceModal(false)}
                    style={{ padding: "10px 18px", borderRadius: "8px", backgroundColor: "transparent", border: "1px solid rgba(255,255,255,0.3)", color: "#FFF", cursor: "pointer" }}
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                      style={{ backgroundColor: "#D4AF37", color: "#000" }} className="font-extrabold cursor-pointer rounded-lg border-none py-2.5 px-[22px]" 
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
          <div  style={{ inset: 0, backgroundColor: "rgba(0, 0, 0, 0.85)", zIndex: 100, padding: "20px" }} className="flex justify-center items-center fixed">
            <div  style={{ backgroundColor: "#061224", border: "2px solid #10B981", maxWidth: "560px", color: "#FFF", boxShadow: "0 0 30px rgba(16, 185, 129, 0.3)" }} className="w-full p-6 rounded-2xl">
              <h2  style={{ fontSize: "18px", color: "#10B981", margin: "0 0 16px 0" }} className="font-extrabold">
                {editingPerson ? "Edit Service Person Details" : "Add Service Person under Category"}
              </h2>

              <form onSubmit={handlePersonSubmit}  className="flex flex-col gap-[14px]">
                <div>
                  <label  style={{ color: "#A7F3D0", display: "block", marginBottom: "4px" }} className="font-bold text-xs">
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
                    <label  style={{ color: "#A7F3D0", display: "block", marginBottom: "4px" }} className="font-bold text-xs">
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
                    <label  style={{ color: "#A7F3D0", display: "block", marginBottom: "4px" }} className="font-bold text-xs">
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
                    <label  style={{ color: "#A7F3D0", display: "block", marginBottom: "4px" }} className="font-bold text-xs">
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
                    <label  style={{ color: "#A7F3D0", display: "block", marginBottom: "4px" }} className="font-bold text-xs">
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
                    <label  style={{ color: "#A7F3D0", display: "block", marginBottom: "4px" }} className="font-bold text-xs">
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
                    <label  style={{ color: "#A7F3D0", display: "block", marginBottom: "4px" }} className="font-bold text-xs">
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
                  <label  style={{ color: "#A7F3D0", display: "block", marginBottom: "4px" }} className="font-bold text-xs">
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

                <div  className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    id="personActiveCheck"
                    checked={personActive}
                    onChange={(e) => setPersonActive(e.target.checked)}
                  />
                  <label htmlFor="personActiveCheck"  style={{ color: "#FFF" }} className="text-[13px]">
                    Publish person profile actively in mobile app
                  </label>
                </div>

                <div  style={{ marginTop: "12px" }} className="flex justify-end gap-[10px]">
                  <button
                    type="button"
                    onClick={() => setShowPersonModal(false)}
                    style={{ padding: "10px 18px", borderRadius: "8px", backgroundColor: "transparent", border: "1px solid rgba(255,255,255,0.3)", color: "#FFF", cursor: "pointer" }}
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                      style={{ backgroundColor: "#10B981", color: "#000" }} className="font-extrabold cursor-pointer rounded-lg border-none py-2.5 px-[22px]" 
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
          <div  style={{ inset: 0, backgroundColor: "rgba(0, 0, 0, 0.85)", zIndex: 110, padding: "20px" }} className="flex justify-center items-center fixed">
            <div  style={{ backgroundColor: "#061224", border: "2px solid #EF4444", maxWidth: "480px", color: "#FFF", boxShadow: "0 0 30px rgba(239, 68, 68, 0.4)" }} className="w-full p-6 rounded-2xl">
              <div style={{ fontSize: "36px", marginBottom: "8px" }}>⚠️</div>
              <h2  style={{ fontSize: "18px", color: "#EF4444", margin: "0 0 8px 0" }} className="font-extrabold">
                Confirm Service Deletion
              </h2>
              <p  style={{ color: "rgba(255, 255, 255, 0.9)", lineHeight: 1.5, margin: "0 0 16px 0" }} className="text-sm">
                Deleting this service (<strong>{serviceToDelete.title}</strong>) will also automatically remove all service persons associated with this service!
              </p>
              <div   style={{ padding: "12px", backgroundColor: "rgba(239, 68, 68, 0.15)", border: "1px solid rgba(239, 68, 68, 0.3)", marginBottom: "20px" }} className="text-xs rounded-lg text-red-300" >
                💡 <strong>Recommended:</strong> Instead of deleting, you can click "Disable / Deactivate" in the table to hide this service from the Flutter app without deleting historical data.
              </div>
              <div  className="flex justify-end gap-[10px]">
                <button
                  onClick={() => setServiceToDelete(null)}
                  style={{ padding: "10px 18px", borderRadius: "8px", backgroundColor: "transparent", border: "1px solid rgba(255,255,255,0.3)", color: "#FFF", cursor: "pointer" }}
                >
                  Cancel
                </button>
                <button
                  onClick={confirmDeleteService}
                    style={{ backgroundColor: "#EF4444", color: "#FFF" }} className="font-extrabold cursor-pointer rounded-lg border-none py-2.5 px-[22px]" 
                >
                  Yes, Delete Service & Persons
                </button>
              </div>
            </div>
          </div>
        )}

        {/* DELETE CONFIRMATION MODAL FOR PERSON */}
        {personToDelete && (
          <div  style={{ inset: 0, backgroundColor: "rgba(0, 0, 0, 0.85)", zIndex: 110, padding: "20px" }} className="flex justify-center items-center fixed">
            <div  style={{ backgroundColor: "#061224", border: "2px solid #EF4444", maxWidth: "440px", color: "#FFF", boxShadow: "0 0 30px rgba(239, 68, 68, 0.4)" }} className="w-full p-6 rounded-2xl">
              <h2  style={{ fontSize: "18px", color: "#EF4444", margin: "0 0 8px 0" }} className="font-extrabold">
                Delete Service Person
              </h2>
              <p  style={{ color: "rgba(255, 255, 255, 0.9)", margin: "0 0 20px 0" }} className="text-sm">
                Are you sure you want to remove <strong>{personToDelete.name}</strong> from the service directory?
              </p>
              <div  className="flex justify-end gap-[10px]">
                <button
                  onClick={() => setPersonToDelete(null)}
                  style={{ padding: "10px 18px", borderRadius: "8px", backgroundColor: "transparent", border: "1px solid rgba(255,255,255,0.3)", color: "#FFF", cursor: "pointer" }}
                >
                  Cancel
                </button>
                <button
                  onClick={confirmDeletePerson}
                    style={{ backgroundColor: "#EF4444", color: "#FFF" }} className="font-extrabold cursor-pointer rounded-lg border-none py-2.5 px-[22px]" 
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
