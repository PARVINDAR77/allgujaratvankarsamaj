// Seed comprehensive wedding services for All Gujarat Vankar Samaj
const BASE_URL = process.env.API_URL || 'https://allgujaratvankarsamaj.com/api/v1';

const weddingServices = [
  {
    title: 'Photography & Cinematography (ફોટોગ્રાફી & વિડિયો)',
    category: 'Wedding',
    icon: '📸',
    description: 'લગ્ન પ્રસંગ 4K સિનેમેટોગ્રાફી, પ્રી-વેડિંગ શૂટ, કેન્ડિડ ફોટોગ્રાફી અને આલ્બમ ડિઝાઇન.',
  },
  {
    title: 'Catering & Halwai Services (કેટરિંગ & રસોઈ સેવા)',
    category: 'Wedding',
    icon: '🍲',
    description: 'શ્રી વણકર સમાજ લગ્ન ભોજન સમારંભ, મહારાજ રસોઈ, ગુજરાતી થાળી, મીઠાઈ અને લાઇવ કાઉન્ટર.',
  },
  {
    title: 'Wedding Car Rental (લગ્ન કાર રેન્ટલ & વરઘોડો)',
    category: 'Wedding',
    icon: '🚗',
    description: 'વરરાજા આગમન માટે ડેકોરેટેડ લક્ઝરી કાર, ઓડી, બીએમડબલ્યુ, ઇનોવા અને વરઘોડો સ્પેશિયલ કાર.',
  },
  {
    title: 'DJ Sound & Disco Lighting (ડીજે સાઉન્ડ & લાઇટ્સ)',
    category: 'Wedding',
    icon: '🎵',
    description: 'રાસ-ગરબા, સંગીત સંધ્યા અને ડીજે નાઇટ માટે પાવરફુલ સાઉન્ડ સિસ્ટમ, એલઇડી વોલ અને ફોગ/સ્મોક.',
  },
  {
    title: 'Brass Band & Dhol Players (બેન્ડ-વાજા & ઢોલી ગ્રુપ)',
    category: 'Wedding',
    icon: '🥁',
    description: 'જાન આગમન, વરઘોડો અને ફુલેકા માટે પ્રખ્યાત બેન્ડ વાજા પાર્ટી, નાસિક ઢોલ અને શરણાઈ વાદક.',
  },
  {
    title: 'Bridal Makeup & Beauty Care (બ્રાઇડલ મેકઅપ & પાર્લર)',
    category: 'Wedding',
    icon: '💄',
    description: 'દુલ્હન એચડી બ્રાઇડલ મેકઅપ, હેરસ્ટાઇલ, પ્રી-બ્રાઇડલ પેકેજ અને સાડી/ચણિયાચોળી ડ્રેપિંગ.',
  },
  {
    title: 'Mehendi Artist (મહેંદી ડિઝાઇનર & આર્ટિસ્ટ)',
    category: 'Wedding',
    icon: '🎨',
    description: 'દુલ્હન બ્રાઇડલ મહેંદી, મારવાડી/અરેબિક પેટર્ન અને મહેંદી રસમ માટે પ્રોફેશનલ આર્ટિસ્ટ્સ.',
  },
  {
    title: 'Banquet Hall & Party Plot (વાડી & હોલ બુકિંગ)',
    category: 'Wedding',
    icon: '🏰',
    description: 'લગ્ન પ્રસંગ અને સંગીત માટે સમાજ વાડી, એસી બેન્ક્વેટ હોલ અને લક્ઝરી પાર્ટી પ્લોટ બુકિંગ સહાય.',
  },
  {
    title: 'Kankotri & Wedding Invitation Cards (કંકોતરી પ્રિન્ટિંગ)',
    category: 'Wedding',
    icon: '💌',
    description: 'આકર્ષક ગુજરાતી કંકોતરી, રોયલ વેડિંગ કાર્ડ્સ, ડિજિટલ ઈ-ઇન્વાઇટ અને વિડિયો આમંત્રણ.',
  },
  {
    title: 'Stage, Flower & Entry Gate Decoration (સ્ટેજ & ફ્લાવર)',
    category: 'Wedding',
    icon: '🌸',
    description: 'થીમ બેઝ્ડ સ્ટેજ ડેકોરેશન, તાજા ફૂલોની સજાવટ, હલ્દી ડેકોર અને ગ્રાન્ડ એન્ટ્રી ગેટ સેટઅપ.',
  },
  {
    title: 'Live YouTube Streaming (યુટ્યુબ લાઇવ પ્રસારણ)',
    category: 'Wedding',
    icon: '🎥',
    description: 'દેશ-વિદેશમાં બેઠેલા સ્નેહીજનો માટે હાઇ-ડેફિનેશન લાઇવ ટેલિકાસ્ટ (YouTube/Facebook Live).',
  },
  {
    title: 'Jan / Barat Bus & Tempo Transport (જાન માટે બસ & ટેમ્પો)',
    category: 'Wedding',
    icon: '🚌',
    description: 'જાનૈયાઓ માટે ૨૪/૩૨/૫૬ સીટર લક્ઝરી બસો, મિની બસ, ઇકો અને ટેમ્પો ટ્રાવેલર બુકિંગ.',
  },
  {
    title: 'Jewelry & Bridal Attire Rental (દુલ્હન દાગીના & ચણિયાચોળી)',
    category: 'Wedding',
    icon: '💍',
    description: 'લગ્ન માટે કુંદન, એડી, બ્રાઇડલ જ્વેલરી સેટ અને ડિઝાઇનર ચણિયાચોળી/શેરવાની ભાડેથી મેળવો.',
  },
  {
    title: 'Groom Buggy & Vintage Car (વરરાજા બગી & વિન્ટેજ કાર)',
    category: 'Wedding',
    icon: '🚘',
    description: 'શાહી વરઘોડા માટે લક્ઝરી બગી, સજાવટ કરેલ ઘોડી, વિન્ટેજ કાર અને સ્પેશિયલ એન્ટ્રી કોન્સેપ્ટ.',
  },
  {
    title: 'Welcome Hostess & Event Security (વેલકમ ગર્લ્સ & સિક્યોરિટી)',
    category: 'Wedding',
    icon: '💁‍♀️',
    description: 'મહેમાનોના સ્વાગત માટે ટ્રેઇન્ડ વેલકમ ગર્લ્સ અને પ્રસંગની વ્યવસ્થા માટે બાઉન્સર સિક્યોરિટી.',
  }
];

async function seed() {
  console.log(`Connecting to: ${BASE_URL}`);

  // Fetch existing services to avoid duplicates
  let existingTitles = [];
  try {
    const res = await fetch(`${BASE_URL}/samaj-services`);
    if (res.ok) {
      const data = await res.json();
      existingTitles = data.map(s => s.title.toLowerCase());
      console.log(`Found ${data.length} existing services.`);
    }
  } catch (err) {
    console.error('Error fetching existing services:', err.message);
  }

  let added = 0;
  for (const s of weddingServices) {
    const isDuplicate = existingTitles.some(t => t.includes(s.title.toLowerCase()) || s.title.toLowerCase().includes(t));
    if (isDuplicate) {
      console.log(`⏩ Skipping duplicate: ${s.title}`);
      continue;
    }

    try {
      const res = await fetch(`${BASE_URL}/admin/samaj-services`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: s.title,
          category: s.category,
          icon: s.icon,
          description: s.description,
          isActive: true
        })
      });

      if (res.ok) {
        console.log(`✅ Added: ${s.title}`);
        added++;
      } else {
        const text = await res.text();
        console.log(`❌ Failed: ${s.title} - ${res.status}: ${text}`);
      }
    } catch (e) {
      console.error(`❌ Error adding ${s.title}:`, e.message);
    }

    await new Promise(r => setTimeout(r, 120));
  }

  console.log(`\n🎉 Completed! Added ${added} wedding services successfully.`);
}

seed();
