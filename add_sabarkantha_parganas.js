const API_BASE = "https://allgujaratvankarsamaj.com/api/v1";

const sabarkanthaParganas = [
  {
    serial: "103",
    name: "35 Gam Pargana (Idar)",
    gujaratiName: "૧૦૩. ૩૫ પરગણું - પાંત્રીસ ગામ (ઈડર)",
    code: "PARGANA_35_IDAR",
    villageCount: "૩૫ ગામ (35 Gam)",
    districtRegion: "ઈડર, સાબરકાંઠા (Idar, Sabarkantha)",
    description: "સાબરકાંઠા જિલ્લાના ઈડર પંથકનું ૩૫ ગામ પરગણું (પાંત્રીસ ગામ)",
    leaderName: "Rameshbhai Vankar (Idar)",
    contactPhone: "+91 98765 43210",
    isActive: true,
  },
  {
    serial: "104",
    name: "16 Gam Pargana (Solsu - Idar)",
    gujaratiName: "૧૦૪. સોળસું પરગણું - ૧૬ ગામ (ઈડર)",
    code: "SK_104_PARGANA_16_IDAR",
    villageCount: "૧૬ ગામ (16 Gam)",
    districtRegion: "ઈડર, સાબરકાંઠા (Idar, Sabarkantha)",
    description: "સાબરકાંઠા જિલ્લાના ઈડર પંથકનું સોળસું પરગણું (૧૬ ગામ)",
    leaderName: "પ્રમુખશ્રી - સોળસું પરગણું (ઈડર)",
    contactPhone: "",
    isActive: true,
  },
  {
    serial: "105",
    name: "14 Gam Pargana (Chaudsu - Idar)",
    gujaratiName: "૧૦૫. ચૌદસું પરગણું - ૧૪ ગામ (ઈડર)",
    code: "SK_105_PARGANA_14_IDAR",
    villageCount: "૧૪ ગામ (14 Gam)",
    districtRegion: "ઈડર, સાબરકાંઠા (Idar, Sabarkantha)",
    description: "સાબરકાંઠા જિલ્લાના ઈડર પંથકનું ચૌદસું પરગણું (૧૪ ગામ)",
    leaderName: "પ્રમુખશ્રી - ચૌદસું પરગણું (ઈડર)",
    contactPhone: "",
    isActive: true,
  },
  {
    serial: "106",
    name: "27 Gam Pargana (Sattavisu - Himatnagar)",
    gujaratiName: "૧૦૬. સત્તાવીસનું પરગણું - ૨૭ ગામ (હિમતનગર)",
    code: "SK_106_PARGANA_27_HMT",
    villageCount: "૨૭ ગામ (27 Gam)",
    districtRegion: "હિમતનગર, સાબરકાંઠા (Himatnagar, Sabarkantha)",
    description: "સાબરકાંઠા જિલ્લાના હિમતનગર પંથકનું સત્તાવીસનું પરગણું (૨૭ ગામ)",
    leaderName: "પ્રમુખશ્રી - સત્તાવીસનું પરગણું (હિમતનગર)",
    contactPhone: "",
    isActive: true,
  },
  {
    serial: "107",
    name: "52 Gam Pargana (Bavan Shri Vankar Samaj)",
    gujaratiName: "૧૦૭. બાવન શ્રી વણકર સમાજ - ૫૨ ગામ",
    code: "SK_107_PARGANA_52",
    villageCount: "૫૨ ગામ (52 Gam)",
    districtRegion: "સાબરકાંઠા (Sabarkantha)",
    description: "સાબરકાંઠા જિલ્લાનું બાવન શ્રી વણકર સમાજ પરગણું (૫૨ ગામ)",
    leaderName: "પ્રમુખશ્રી - બાવન શ્રી વણકર સમાજ",
    contactPhone: "",
    isActive: true,
  },
  {
    serial: "108",
    name: "27 Gam Pargana (Sattavisi - Khedbrahma)",
    gujaratiName: "૧૦૮. સત્તાવીસ પરગણું - ૨૭ ગામ (ખેડબ્રહ્મા)",
    code: "SK_108_PARGANA_27_KHED",
    villageCount: "૨૭ ગામ (27 Gam)",
    districtRegion: "ખેડબ્રહ્મા, સાબરકાંઠા (Khedbrahma, Sabarkantha)",
    description: "સાબરકાંઠા જિલ્લાના ખેડબ્રહ્મા પંથકનું સત્તાવીસ પરગણું (૨૭ ગામ)",
    leaderName: "પ્રમુખશ્રી - સત્તાવીસ પરગણું (ખેડબ્રહ્મા)",
    contactPhone: "",
    isActive: true,
  },
  {
    serial: "109",
    name: "Solsoti Pargana Vankar Samaj",
    gujaratiName: "૧૦૯. સોળસોતી પરગણા વણકર સમાજ",
    code: "SK_109_PARGANA_SOLSOTI",
    villageCount: "સોળસોતી ગામો",
    districtRegion: "સાબરકાંઠા (Sabarkantha)",
    description: "સાબરકાંઠા જિલ્લાનું સોળસોતી પરગણા વણકર સમાજ",
    leaderName: "પ્રમુખશ્રી - સોળસોતી પરગણા વણકર સમાજ",
    contactPhone: "",
    isActive: true,
  },
  {
    serial: "110",
    name: "125 Gam Pargana (Savaso Gam)",
    gujaratiName: "૧૧૦. સવાસો ગામનું પરગણું - ૧૨૫ ગામ",
    code: "SK_110_PARGANA_125",
    villageCount: "૧૨૫ ગામ (125 Gam)",
    districtRegion: "સાબરકાંઠા (Sabarkantha)",
    description: "સાબરકાંઠા જિલ્લાનું સવાસો ગામનું પરગણું (૧૨૫ ગામ)",
    leaderName: "પ્રમુખશ્રી - સવાસો ગામનું પરગણું",
    contactPhone: "",
    isActive: true,
  },
  {
    serial: "111",
    name: "Prajamidharmi Pargana (Ad Athha)",
    gujaratiName: "૧૧૧. પ્રજામીધર્મી પરગણું (અડ અઠ્ઠાનું પરગણું)",
    code: "SK_111_PARGANA_AD_ATHHA",
    villageCount: "અડ અઠ્ઠા ગામો",
    districtRegion: "સાબરકાંઠા (Sabarkantha)",
    description: "સાબરકાંઠા જિલ્લાનું પ્રજામીધર્મી પરગણું (અડ અઠ્ઠાનું પરગણું)",
    leaderName: "પ્રમુખશ્રી - પ્રજામીધર્મી પરગણું",
    contactPhone: "",
    isActive: true,
  },
  {
    serial: "112",
    name: "08 Gam Pargana (Aath Gam)",
    gujaratiName: "૧૧૨. આઠ (૦૮) ગામ પરગણું - ૮ ગામ",
    code: "SK_112_PARGANA_08",
    villageCount: "૦૮ ગામ (08 Gam)",
    districtRegion: "સાબરકાંઠા (Sabarkantha)",
    description: "સાબરકાંઠા જિલ્લાનું આઠ (૦૮) ગામ પરગણું",
    leaderName: "પ્રમુખશ્રી - આઠ ગામ પરગણું",
    contactPhone: "",
    isActive: true,
  },
  {
    serial: "113",
    name: "Barsi Pargana",
    gujaratiName: "૧૧૩. બારસી પરગણું - બારસી ગામો",
    code: "SK_113_PARGANA_BARSI",
    villageCount: "બારસી ગામો",
    districtRegion: "સાબરકાંઠા (Sabarkantha)",
    description: "સાબરકાંઠા જિલ્લાનું બારસી પરગણું",
    leaderName: "પ્રમુખશ્રી - બારસી પરગણું",
    contactPhone: "",
    isActive: true,
  },
];

async function syncParganas() {
  console.log("Fetching existing parganas from Admin API...");
  const res = await fetch(`${API_BASE}/admin/parganas`);
  const existing = await res.json();
  console.log(`Found ${existing.length} existing parganas in DB.`);

  for (const item of sabarkanthaParganas) {
    // Check if matching pargana exists by code or name or gujaratiName
    const matched = existing.find(
      (e) =>
        e.code === item.code ||
        (item.code === "PARGANA_35_IDAR" && e.code === "PARGANA_35_IDAR") ||
        e.name.toLowerCase() === item.name.toLowerCase() ||
        (e.gujaratiName && e.gujaratiName.includes(item.serial))
    );

    if (matched) {
      console.log(`Updating existing Pargana [${item.serial}]: ${matched.name} (id: ${matched.id})...`);
      const updateRes = await fetch(`${API_BASE}/admin/parganas/${matched.id}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          name: item.name,
          gujaratiName: item.gujaratiName,
          code: item.code,
          villageCount: item.villageCount,
          districtRegion: item.districtRegion,
          description: item.description,
          leaderName: item.leaderName || matched.leaderName,
          contactPhone: item.contactPhone || matched.contactPhone,
          isActive: true,
        }),
      });
      const updated = await updateRes.json();
      console.log(`Updated successfully:`, updated.id, updated.gujaratiName);
    } else {
      console.log(`Creating new Pargana [${item.serial}]: ${item.name}...`);
      const createRes = await fetch(`${API_BASE}/admin/parganas`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          name: item.name,
          gujaratiName: item.gujaratiName,
          code: item.code,
          villageCount: item.villageCount,
          districtRegion: item.districtRegion,
          description: item.description,
          leaderName: item.leaderName,
          contactPhone: item.contactPhone,
          isActive: true,
        }),
      });
      const created = await createRes.json();
      console.log(`Created successfully:`, created.id, created.gujaratiName);
    }
  }

  console.log("\nVerifying updated parganas list...");
  const finalRes = await fetch(`${API_BASE}/admin/parganas`);
  const finalList = await finalRes.json();
  console.log(`Total parganas in DB now: ${finalList.length}`);
  finalList.forEach((p, idx) => {
    console.log(`${idx + 1}. [${p.code}] ${p.gujaratiName || p.name} (${p.villageCount || "N/A"}) - ${p.districtRegion || "N/A"}`);
  });
}

syncParganas().catch(console.error);
