const BASE_URL = 'http://localhost:3000/api/v1';

const services = [
  // 1. Home & Daily Life Services
  { title: 'ઘર બાંધકામ / Construction', category: 'Home & Daily Life Services', icon: '🏠' },
  { title: 'Mason / Raj Mistri', category: 'Home & Daily Life Services', icon: '🧱' },
  { title: 'Painter', category: 'Home & Daily Life Services', icon: '🎨' },
  { title: 'Plumber', category: 'Home & Daily Life Services', icon: '🔧' },
  { title: 'Electrician', category: 'Home & Daily Life Services', icon: '⚡' },
  { title: 'AC / Fridge Repair', category: 'Home & Daily Life Services', icon: '❄️' },
  { title: 'Carpenter', category: 'Home & Daily Life Services', icon: '🪚' },
  { title: 'Aluminium / Glass Work', category: 'Home & Daily Life Services', icon: '🪟' },
  { title: 'Furniture / Interior', category: 'Home & Daily Life Services', icon: '🚪' },
  { title: 'House Cleaning', category: 'Home & Daily Life Services', icon: '🧹' },
  { title: 'Pest Control', category: 'Home & Daily Life Services', icon: '🐜' },
  { title: 'Packers & Movers', category: 'Home & Daily Life Services', icon: '🚚' },

  // 2. Vehicle & Transport
  { title: 'Car Rental', category: 'Vehicle & Transport', icon: '🚗' },
  { title: 'Bike/Scooter Repair', category: 'Vehicle & Transport', icon: '🛵' },
  { title: 'Car Repair / Garage', category: 'Vehicle & Transport', icon: '🚘' },
  { title: 'Tyre & Puncture', category: 'Vehicle & Transport', icon: '🛞' },
  { title: 'Battery Service', category: 'Vehicle & Transport', icon: '🔋' },
  { title: 'Taxi / Cab', category: 'Vehicle & Transport', icon: '🚕' },
  { title: 'Bus / Tempo', category: 'Vehicle & Transport', icon: '🚌' },
  { title: 'Goods Transport', category: 'Vehicle & Transport', icon: '🚛' },
  { title: 'Driver Service', category: 'Vehicle & Transport', icon: '🚗' },
  { title: 'Parking Service', category: 'Vehicle & Transport', icon: '🅿️' },

  // 3. Computer & Digital Services
  { title: 'Computer/Laptop Repair', category: 'Computer & Digital Services', icon: '💻' },
  { title: 'Printer Repair', category: 'Computer & Digital Services', icon: '🖨️' },
  { title: 'Mobile Repair', category: 'Computer & Digital Services', icon: '📱' },
  { title: 'Website Development', category: 'Computer & Digital Services', icon: '🌐' },
  { title: 'App Development', category: 'Computer & Digital Services', icon: '📱' },
  { title: 'Graphic Design', category: 'Computer & Digital Services', icon: '🎨' },
  { title: 'Printing / Xerox', category: 'Computer & Digital Services', icon: '🖨️' },
  { title: 'Photo Studio', category: 'Computer & Digital Services', icon: '📸' },
  { title: 'Online Form Filling', category: 'Computer & Digital Services', icon: '🪪' },
  { title: 'Document Scanning', category: 'Computer & Digital Services', icon: '📄' },
  { title: 'Digital Payment Assistance', category: 'Computer & Digital Services', icon: '💳' },

  // 4. Education Services
  { title: 'Tuition / Coaching', category: 'Education Services', icon: '👨‍🏫' },
  { title: 'School Admission Guidance', category: 'Education Services', icon: '🏫' },
  { title: 'College Admission Guidance', category: 'Education Services', icon: '🎓' },
  { title: 'Competitive Exam Coaching', category: 'Education Services', icon: '📝' },
  { title: 'Career Guidance', category: 'Education Services', icon: '💼' },
  { title: 'Foreign Study Guidance', category: 'Education Services', icon: '🌍' },
  { title: 'Books / Stationery', category: 'Education Services', icon: '📖' },
  { title: 'Computer Training', category: 'Education Services', icon: '💻' },
  { title: 'English Speaking', category: 'Education Services', icon: '🗣️' },
  { title: 'Scholarship Information', category: 'Education Services', icon: '🏆' },

  // 5. Job & Business Services
  { title: 'Job Placement', category: 'Job & Business Services', icon: '💼' },
  { title: 'Skilled Worker Jobs', category: 'Job & Business Services', icon: '👷' },
  { title: 'Private Job Information', category: 'Job & Business Services', icon: '🏢' },
  { title: 'Government Job Guidance', category: 'Job & Business Services', icon: '🏛️' },
  { title: 'Resume / CV Making', category: 'Job & Business Services', icon: '📄' },
  { title: 'Interview Preparation', category: 'Job & Business Services', icon: '💼' },
  { title: 'Business Directory', category: 'Job & Business Services', icon: '🏪' },
  { title: 'Business Networking', category: 'Job & Business Services', icon: '🤝' },
  { title: 'Business Consultant', category: 'Job & Business Services', icon: '📈' },
  { title: 'GST / Tax Consultant', category: 'Job & Business Services', icon: '🧾' },

  // 6. Legal & Financial Services
  { title: 'Advocate / Legal Advice', category: 'Legal & Financial Services', icon: '⚖️' },
  { title: 'Document Writer', category: 'Legal & Financial Services', icon: '📑' },
  { title: 'Bank Loan Assistance', category: 'Legal & Financial Services', icon: '🏦' },
  { title: 'Financial Consultant', category: 'Legal & Financial Services', icon: '💰' },
  { title: 'Income Tax / GST', category: 'Legal & Financial Services', icon: '🧾' },
  { title: 'Property Documents', category: 'Legal & Financial Services', icon: '🏠' },
  { title: 'Insurance Agent', category: 'Legal & Financial Services', icon: '📜' },
  { title: 'Loan / Finance Services', category: 'Legal & Financial Services', icon: '💳' },
  { title: 'Banking Assistance', category: 'Legal & Financial Services', icon: '🏦' },

  // 7. Health & Emergency
  { title: 'Hospital', category: 'Health & Emergency', icon: '🏥' },
  { title: 'Doctor', category: 'Health & Emergency', icon: '👨‍⚕️' },
  { title: 'Dentist', category: 'Health & Emergency', icon: '🦷' },
  { title: 'Eye Care', category: 'Health & Emergency', icon: '👓' },
  { title: 'Medical Store', category: 'Health & Emergency', icon: '💊' },
  { title: 'Ambulance', category: 'Health & Emergency', icon: '🚑' },
  { title: 'Blood Donor Directory', category: 'Health & Emergency', icon: '🩸' },
  { title: 'Laboratory / Diagnostic', category: 'Health & Emergency', icon: '🧪' },
  { title: 'Home Nursing', category: 'Health & Emergency', icon: '🧑‍⚕️' },
  { title: 'Elderly Assistance', category: 'Health & Emergency', icon: '♿' },

  // 8. Business & Local Shops
  { title: 'Grocery', category: 'Business & Local Shops', icon: '🛒' },
  { title: 'Clothes / Garments', category: 'Business & Local Shops', icon: '👗' },
  { title: 'Footwear', category: 'Business & Local Shops', icon: '👟' },
  { title: 'Mobile Shop', category: 'Business & Local Shops', icon: '📱' },
  { title: 'Electronics', category: 'Business & Local Shops', icon: '💻' },
  { title: 'Furniture', category: 'Business & Local Shops', icon: '🪑' },
  { title: 'Jewellery', category: 'Business & Local Shops', icon: '💎' },
  { title: 'Bakery', category: 'Business & Local Shops', icon: '🍰' },
  { title: 'Restaurant / Food', category: 'Business & Local Shops', icon: '🍽️' },
  { title: 'Printing Press', category: 'Business & Local Shops', icon: '🖨️' },

  // 9. Skilled Professionals
  { title: 'Electrician', category: 'Skilled Professionals', icon: '👨‍🔧' },
  { title: 'Plumber', category: 'Skilled Professionals', icon: '🔧' },
  { title: 'Carpenter', category: 'Skilled Professionals', icon: '🪚' },
  { title: 'Welder', category: 'Skilled Professionals', icon: '🔨' },
  { title: 'Mason', category: 'Skilled Professionals', icon: '🧱' },
  { title: 'Painter', category: 'Skilled Professionals', icon: '🎨' },
  { title: 'Computer Technician', category: 'Skilled Professionals', icon: '👨‍💻' },
  { title: 'Mobile Technician', category: 'Skilled Professionals', icon: '📱' },
  { title: 'Mechanic', category: 'Skilled Professionals', icon: '🚗' },
  { title: 'AC Technician', category: 'Skilled Professionals', icon: '❄️' },
  { title: 'TV Technician', category: 'Skilled Professionals', icon: '📺' },

  // 10. Event & Wedding Planning
  { title: 'AC Repair & Services', category: 'Event & Wedding Planning', icon: '❄️' },
  { title: 'Audio & Sound System Rental', category: 'Event & Wedding Planning', icon: '🔈' },
  { title: 'Beauty Parlor & Bridal Makeup', category: 'Event & Wedding Planning', icon: '💄' },
  { title: 'Banquet Hall Booking', category: 'Event & Wedding Planning', icon: '🏰' },
  { title: 'Brass Band & Dhol', category: 'Event & Wedding Planning', icon: '🥁' },
  { title: 'Cameraman & Photography', category: 'Event & Wedding Planning', icon: '📷' },
  { title: 'Car Rental (Luxury & Wedding Cars)', category: 'Event & Wedding Planning', icon: '🚗' },
  { title: 'Catering Services', category: 'Event & Wedding Planning', icon: '🍲' },
  { title: 'Drone Videography & Aerial Shots', category: 'Event & Wedding Planning', icon: '🚁' },
  { title: 'DJ Sound & Disco Lighting', category: 'Event & Wedding Planning', icon: '🎶' },
  { title: 'Event Management & Planning', category: 'Event & Wedding Planning', icon: '📅' },
  { title: 'Electrical Works & Lighting', category: 'Event & Wedding Planning', icon: '💡' },
  { title: 'Flower Decoration & Stage Setup', category: 'Event & Wedding Planning', icon: '🌸' },
  { title: 'Food Stalls & Live Counters', category: 'Event & Wedding Planning', icon: '🍕' },
  { title: 'Generator Rental', category: 'Event & Wedding Planning', icon: '🔌' },
  { title: 'Graphic Design & Banner Printing', category: 'Event & Wedding Planning', icon: '🎨' },
  { title: 'Haldi & Mehendi Decoration', category: 'Event & Wedding Planning', icon: '🎉' },
  { title: 'Hair Styling & Unisex Salon', category: 'Event & Wedding Planning', icon: '✂️' },
  { title: 'Invitation Card Printing & E-Invites', category: 'Event & Wedding Planning', icon: '✉️' },
  { title: 'Interior Decoration', category: 'Event & Wedding Planning', icon: '🏠' },
  { title: 'Jewelry Rental & Bridal Accessories', category: 'Event & Wedding Planning', icon: '💍' },
  { title: 'Juggler & Mascot Entertainment', category: 'Event & Wedding Planning', icon: '🤹' },
  { title: 'Kankotri & Wedding Card Shop', category: 'Event & Wedding Planning', icon: '💌' },
  { title: 'Kitchen Catering & Halwai Services', category: 'Event & Wedding Planning', icon: '👨‍🍳' },
  { title: 'Live YouTube & Facebook Streaming', category: 'Event & Wedding Planning', icon: '🎥' },
  { title: 'LED Screen (Video Wall) Setup', category: 'Event & Wedding Planning', icon: '📺' },
  { title: 'Mandap & Shamiana Decoration', category: 'Event & Wedding Planning', icon: '🎪' },
  { title: 'Mehendi Artist', category: 'Event & Wedding Planning', icon: '🖌️' },
  { title: 'Name Entry Setup & Cold Pyro Effects', category: 'Event & Wedding Planning', icon: '✨' },
  { title: 'Nursery & Floral Supply', category: 'Event & Wedding Planning', icon: '🪴' },
  { title: 'Online Cyber Cafe Services', category: 'Event & Wedding Planning', icon: '💻' },
  { title: 'Officers & Bouncer Security Services', category: 'Event & Wedding Planning', icon: '🛡️' },
  { title: 'Pre-Wedding Photography & Cinematography', category: 'Event & Wedding Planning', icon: '📸' },
  { title: 'Printing & Flex Shop', category: 'Event & Wedding Planning', icon: '🖨️' },
  { title: 'Quick Car Wash & Detailing', category: 'Event & Wedding Planning', icon: '🧼' },
  { title: 'Quick Courier & Transport', category: 'Event & Wedding Planning', icon: '📦' },
  { title: 'Rental Cars, Buses & Tempo Travellers', category: 'Event & Wedding Planning', icon: '🚌' },
  { title: 'RO Water Filter Service', category: 'Event & Wedding Planning', icon: '🚰' },
  { title: 'Stage & Entry Gate Decoration', category: 'Event & Wedding Planning', icon: '⛩️' },
  { title: 'Tailoring Shop', category: 'Event & Wedding Planning', icon: '🧵' },
  { title: 'Tent, Chair & Table Rental', category: 'Event & Wedding Planning', icon: '⛺' },
  { title: 'Tours & Travels Booking', category: 'Event & Wedding Planning', icon: '✈️' },
  { title: 'Utility Repair Services', category: 'Event & Wedding Planning', icon: '🛠️' },
  { title: 'Umbrella & Outdoor Canopy Rental', category: 'Event & Wedding Planning', icon: '⛱️' },
  { title: 'Video Shooting (4K / Cinematic HD)', category: 'Event & Wedding Planning', icon: '📹' },
  { title: 'Vintage Car Rental for Groom Entry', category: 'Event & Wedding Planning', icon: '🚘' },
  { title: 'Wedding Planning & Coordination', category: 'Event & Wedding Planning', icon: '📋' },
  { title: 'Water Tanker Supply', category: 'Event & Wedding Planning', icon: '💧' },
  { title: 'Welcome Girls & Hostess', category: 'Event & Wedding Planning', icon: '💁‍♀️' },
  { title: 'Xerox, Lamination & Document Printing', category: 'Event & Wedding Planning', icon: '🖨️' },
  { title: 'Zari & Embroidery Works', category: 'Event & Wedding Planning', icon: '🧵' },
  { title: 'Groom Wear & Sherwani Rental', category: 'Event & Wedding Planning', icon: '👔' },

  // 11. Agriculture & Farming
  { title: 'બીયારણની દુકાન — Seed Shop', category: 'Agriculture & Farming', icon: '🌱' },
  { title: 'ખાતર — Fertilizer Shop', category: 'Agriculture & Farming', icon: '🧪' },
  { title: 'જંતુનાશક દવા — Pesticide Shop', category: 'Agriculture & Farming', icon: '🐛' },
  { title: 'કૃષિ દવા — Agro Chemical Shop', category: 'Agriculture & Farming', icon: '🌿' },
  { title: 'ટ્રેક્ટર — Tractor Dealer', category: 'Agriculture & Farming', icon: '🚜' },
  { title: 'ખેતીનાં સાધનો — Farm Equipment', category: 'Agriculture & Farming', icon: '⚙️' },
  { title: 'સિંચાઈ સાધનો — Irrigation Equipment', category: 'Agriculture & Farming', icon: '💧' },
  { title: 'ડ્રિપ સિંચાઈ — Drip Irrigation', category: 'Agriculture & Farming', icon: '💦' },
  { title: 'કૃષિ મશીનરી — Agricultural Machinery', category: 'Agriculture & Farming', icon: '🌾' },
  { title: 'પશુ આહાર — Cattle Feed Shop', category: 'Agriculture & Farming', icon: '🐄' },
  { title: 'ડેરી સાધનો — Dairy Equipment', category: 'Agriculture & Farming', icon: '🐄' },
  { title: 'નર્સરી — Plant Nursery', category: 'Agriculture & Farming', icon: '🌳' },
  { title: 'અનાજ ખરીદ-વેચાણ — Grain Trading', category: 'Agriculture & Farming', icon: '🌾' },
  { title: 'શાકભાજી / ફળ વેપારી — Fruits & Vegetables', category: 'Agriculture & Farming', icon: '🥬' },
  { title: 'કૃષિ સેવા — Agricultural Services', category: 'Agriculture & Farming', icon: '🧑‍🌾' },

  // 12. Trolley, Caster Wheel & Cane Products
  { title: 'Trolley Manufacturer', category: 'Trolley, Caster Wheel & Cane Products', icon: '🛒' },
  { title: 'Caster Wheel', category: 'Trolley, Caster Wheel & Cane Products', icon: '⚙️' },
  { title: 'Trolley Wheel', category: 'Trolley, Caster Wheel & Cane Products', icon: '🔘' },
  { title: 'Industrial Trolley', category: 'Trolley, Caster Wheel & Cane Products', icon: '🏭' },
  { title: 'Cane Basket', category: 'Trolley, Caster Wheel & Cane Products', icon: '🧺' },
  { title: 'Cane Products', category: 'Trolley, Caster Wheel & Cane Products', icon: '🧺' },
  { title: 'Trolley Repair & Parts', category: 'Trolley, Caster Wheel & Cane Products', icon: '🔧' },
  { title: 'Material Handling Equipment', category: 'Trolley, Caster Wheel & Cane Products', icon: '🚚' },
  { title: 'Shopping Trolley', category: 'Trolley, Caster Wheel & Cane Products', icon: '🛍️' },
  { title: 'Hospital Trolley', category: 'Trolley, Caster Wheel & Cane Products', icon: '🏥' }
];

async function seedServices() {
  console.log('🌱 Starting seed of Samaj Services into database...');
  
  // First get admin token
  let token = '';
  try {
    const loginRes = await fetch(`${BASE_URL}/auth/admin/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'admin@vankarsamaj.com', password: 'Admin@123' }),
    });
    if (loginRes.ok) {
      const data = await loginRes.json();
      token = data.token || data.access_token || '';
    }
  } catch (e) {
    console.log('Could not login as admin, trying without token...');
  }

  const headers = {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
  };

  let created = 0;
  let skipped = 0;

  for (const service of services) {
    service.isActive = true; // explicitly set
    try {
      const res = await fetch(`${BASE_URL}/admin/samaj-services`, {
        method: 'POST',
        headers,
        body: JSON.stringify(service),
      });
      
      if (res.ok) {
        created++;
      } else {
        const err = await res.text();
        console.log(`⚠️  Failed (${res.status}): ${service.title.substring(0, 40)} - ${err.substring(0, 80)}`);
        skipped++;
      }
    } catch (e) {
      console.log(`❌ Error: ${service.title.substring(0, 40)} - ${e.message}`);
      skipped++;
    }
    
    // Small delay to avoid overwhelming the server
    await new Promise(r => setTimeout(r, 100));
  }

  console.log(`\n🎉 Done! Created: ${created} | Skipped/Failed: ${skipped}`);
  
  // Verify
  const verifyRes = await fetch(`${BASE_URL}/samaj-services`);
  const allServices = await verifyRes.json();
  console.log(`\n📊 Total services now in DB: ${allServices.length}`);
}

seedServices().catch(console.error);
