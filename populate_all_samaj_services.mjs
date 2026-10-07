// Script to insert all requested Samaj Services into the live system via Admin API
import https from 'https';

const API_BASE = 'https://allgujaratvankarsamaj.com/api/v1';

const servicesData = [
  // 1. ઘર અને દૈનિક જીવનની સેવાઓ (Home & Daily Life Services)
  { title: 'ઘર બાંધકામ / Construction', category: 'Home & Daily Life Services', icon: '🏠', description: 'ઘર બાંધકામ, સિવિલ વર્ક અને કોન્ટ્રાક્ટ સેવાઓ' },
  { title: 'Mason / Raj Mistri', category: 'Home & Daily Life Services', icon: '🧱', description: 'રાજ મિસ્ત્રી, કડિયો, પ્લાસ્ટર અને ચણતર કામ' },
  { title: 'Painter', category: 'Home & Daily Life Services', icon: '🎨', description: 'ઘર/ઓફિસ કલરકામ, પેઇન્ટિંગ અને વુડન પોલિશિંગ' },
  { title: 'Plumber', category: 'Home & Daily Life Services', icon: '🔧', description: 'પ્લમ્બિંગ ફિટિંગ, પાઇપલાઇન રીપેર અને બાથરૂમ ફિટિંગ' },
  { title: 'Electrician', category: 'Home & Daily Life Services', icon: '⚡', description: 'ઇલેક્ટ્રિક વાયરિંગ, સ્વિચબોર્ડ, ગીઝર અને મોટર ફિટિંગ' },
  { title: 'AC / Fridge Repair', category: 'Home & Daily Life Services', icon: '❄️', description: 'એસી સર્વિસિંગ, ગેસ ચાર્જિંગ, ફ્રિજ અને વોશિંગ મશીન રીપેર' },
  { title: 'Carpenter', category: 'Home & Daily Life Services', icon: '🪚', description: 'સુથારીકામ, ફર્નિચર બનાવટ, દરવાજા ફિટિંગ' },
  { title: 'Aluminium / Glass Work', category: 'Home & Daily Life Services', icon: '🪟', description: 'એલ્યુમિનિયમ સેક્શન, સ્લાઇડિંગ વિન્ડો અને ગ્લાસ વર્ક' },
  { title: 'Furniture / Interior', category: 'Home & Daily Life Services', icon: '🚪', description: 'ઘર/ઓફિસ ઇન્ટિરિયર ડેકોરેશન, મોડ્યુલર કિચન' },
  { title: 'House Cleaning', category: 'Home & Daily Life Services', icon: '🧹', description: 'ડીપ હોમ ક્લીનિંગ, સોફા વોશ અને વોશરૂમ સફાઈ' },
  { title: 'Pest Control', category: 'Home & Daily Life Services', icon: '🐜', description: 'દીમક, વાંદો, મચ્છર અને જીવજંતુ નિયંત્રણ' },
  { title: 'Packers & Movers', category: 'Home & Daily Life Services', icon: '🚚', description: 'ઘર/ઓફિસ સામાન શિફ્ટિંગ અને સુરક્ષિત ટ્રાન્સપોર્ટ' },

  // 2. Vehicle & Transport
  { title: 'Car Rental', category: 'Vehicle & Transport', icon: '🚗', description: 'કાર રેન્ટલ, સેલ્ફ ડ્રાઈવ અને લગ્ન/પ્રવાસ વાહન બુકિંગ' },
  { title: 'Bike/Scooter Repair', category: 'Vehicle & Transport', icon: '🛵', description: 'ટુ-વ્હીલર સર્વિસિંગ, એન્જિન ઓઇલ અને રીપેરીંગ' },
  { title: 'Car Repair / Garage', category: 'Vehicle & Transport', icon: '🚘', description: 'ફોર-વ્હીલર ગેરેજ, ડેન્ટિંગ-પેઇન્ટિંગ અને એન્જિન કામ' },
  { title: 'Tyre & Puncture', category: 'Vehicle & Transport', icon: '🛞', description: 'ટાયર પંચર, ટ્યુબલેસ રીપેર, ન્યુ ટાયર અને વ્હીલ એલાઈનમેન્ટ' },
  { title: 'Battery Service', category: 'Vehicle & Transport', icon: '🔋', description: 'કાર/બાઇક બેટરી ચાર્જિંગ, જમ્પસ્ટાર્ટ અને નવી બેટરી' },
  { title: 'Taxi / Cab', category: 'Vehicle & Transport', icon: '🚕', description: 'લોકલ અને આઉટસ્ટેશન ટેક્સી/કેબ સેવા' },
  { title: 'Bus / Tempo', category: 'Vehicle & Transport', icon: '🚌', description: 'પ્રવાસ, લગ્ન અને ધાર્મિક યાત્રા માટે લક્ઝરી બસ/ટેમ્પો' },
  { title: 'Goods Transport', category: 'Vehicle & Transport', icon: '🚛', description: 'માલસામાન પરિવહન, ટેમ્પો અને ટ્રક લોજિસ્ટિક્સ' },
  { title: 'Driver Service', category: 'Vehicle & Transport', icon: '🚗', description: 'પર્સનલ ડ્રાઈવર, આઉટસ્ટેશન અને ઇમરજન્સી ડ્રાઇવર' },
  { title: 'Parking Service', category: 'Vehicle & Transport', icon: '🅿️', description: 'સુરક્ષિત પાર્કિંગ સુવિધા અને ગેરેજ પાર્કિંગ' },

  // 3. Computer & Digital Services
  { title: 'Computer/Laptop Repair', category: 'Computer & Digital Services', icon: '💻', description: 'ડેસ્કટોપ, લેપટોપ ફોર્મેટ, સોફ્ટવેર ઇન્સ્ટોલેશન અને હાર્ડવેર રીપેર' },
  { title: 'Printer Repair', category: 'Computer & Digital Services', icon: '🖨️', description: 'પ્રિન્ટર રીપેરીંગ, કાર્ટ્રીજ રીફિલિંગ અને ટોનર સપ્લાય' },
  { title: 'Mobile Repair', category: 'Computer & Digital Services', icon: '📱', description: 'સ્માર્ટફોન સ્ક્રીન, બેટરી, ચાર્જિંગ પોર્ટ અને સોફ્ટવેર કામ' },
  { title: 'Website Development', category: 'Computer & Digital Services', icon: '🌐', description: 'બિઝનેસ વેબસાઇટ, પોર્ટલ ડેવલપમેન્ટ અને હોસ્ટિંગ' },
  { title: 'App Development', category: 'Computer & Digital Services', icon: '📱', description: 'એન્ડ્રોઇડ અને આઇઓએસ મોબાઇલ એપ ડેવલપમેન્ટ' },
  { title: 'Graphic Design', category: 'Computer & Digital Services', icon: '🎨', description: 'લોગો, બેનર, સોશિયલ મીડિયા પોસ્ટ અને બ્રોશર ડિઝાઇનિંગ' },
  { title: 'Printing / Xerox', category: 'Computer & Digital Services', icon: '🖨️', description: 'ઝેરોક્ષ, કલર પ્રિન્ટ, લેમિનેશન અને બાઇન્ડિંગ સેવા' },
  { title: 'Photo Studio', category: 'Computer & Digital Services', icon: '📸', description: 'પાસપોર્ટ ફોટો, પોર્ટ્રેટ, ઇવેન્ટ ફોટોગ્રાફી અને વિડીયોગ્રાફી' },
  { title: 'Online Form Filling', category: 'Computer & Digital Services', icon: '🪪', description: 'સરકારી યોજનાઓ, સ્પર્ધાત્મક પરીક્ષા અને કોલેજ ઓનલાઇન ફોર્મ' },
  { title: 'Document Scanning', category: 'Computer & Digital Services', icon: '📄', description: 'હાઇ-ક્વોલિટી પીડીએફ સ્કેનિંગ અને ડિજિટાઈઝેશન' },
  { title: 'Digital Payment Assistance', category: 'Computer & Digital Services', icon: '💳', description: 'યુપીઆઈ, ઓનલાઇન બેંકિંગ અને ડિજિટલ ટ્રાન્ઝેક્શન સહાય' },

  // 4. Education Services
  { title: 'Tuition / Coaching', category: 'Education Services', icon: '👨‍🏫', description: 'પ્રાથમિક, માધ્યમિક અને ઉચ્ચત્તર માધ્યમિક ટ્યુશન ક્લાસીસ' },
  { title: 'School Admission Guidance', category: 'Education Services', icon: '🏫', description: 'શાળા પ્રવેશ પ્રક્રિયા, RTE ફોર્મ અને માર્ગદર્શન' },
  { title: 'College Admission Guidance', category: 'Education Services', icon: '🎓', description: 'ડિગ્રી, ડિપ્લોમા, એન્જિનિયરિંગ અને મેડિકલ પ્રવેશ સલાહ' },
  { title: 'Competitive Exam Coaching', category: 'Education Services', icon: '📝', description: 'GPSC, UPSC, Talati, Clerk અને TET/TAT કોચિંગ' },
  { title: 'Career Guidance', category: 'Education Services', icon: '💼', description: 'ધો. ૧૦ અને ૧૨ પછી શ્રેષ્ઠ કારકિર્દી પસંદગી કાઉન્સેલિંગ' },
  { title: 'Foreign Study Guidance', category: 'Education Services', icon: '🌍', description: 'વિદેશ અભ્યાસ માટે વિઝા, યુનિવર્સિટી અને IELTS ગાઇડન્સ' },
  { title: 'Books / Stationery', category: 'Education Services', icon: '📖', description: 'શિક્ષણ પુસ્તકો, નોટબુક, ગાઇડ અને સ્ટેશનરી સામગ્રી' },
  { title: 'Computer Training', category: 'Education Services', icon: '💻', description: 'બેઝિક કમ્પ્યુટર, CCC, Tally, DCA અને કોડિંગ કોર્સ' },
  { title: 'English Speaking', category: 'Education Services', icon: '🗣️', description: 'સ્પોકન ઇંગ્લિશ અને પર્સનાલિટી ડેવલપમેન્ટ ક્લાસીસ' },
  { title: 'Scholarship Information', category: 'Education Services', icon: '🏆', description: 'સરકારી અને સમાજ સ્કોલરશીપ સહાય ફોર્મ માહિતી' },

  // 5. Job & Business Services
  { title: 'Job Placement', category: 'Job & Business Services', icon: '💼', description: 'સમાજના યુવાઓ માટે પ્રાઇવેટ અને કોર્પોરેટ જોબ પ્લેસમેન્ટ' },
  { title: 'Skilled Worker Jobs', category: 'Job & Business Services', icon: '👷', description: 'કુશળ કારીગરો માટે રોજગારી અને વર્ક ઓર્ડર માહિતી' },
  { title: 'Private Job Information', category: 'Job & Business Services', icon: '🏢', description: 'ગુજરાતભરમાં પ્રાઇવેટ કંપનીઓની તાજી નોકરી માહિતી' },
  { title: 'Government Job Guidance', category: 'Job & Business Services', icon: '🏛️', description: 'સરકારી ભરતી નોટિફિકેશન, સિલેબસ અને પરીક્ષા અપડેટ્સ' },
  { title: 'Resume / CV Making', category: 'Job & Business Services', icon: '📄', description: 'પ્રોફેશનલ રિઝ્યુમ, બાયોડેટા અને લિંક્ડઇન પ્રોફાઇલ ક્રિએશન' },
  { title: 'Interview Preparation', category: 'Job & Business Services', icon: '💼', description: 'ઇન્ટરવ્યુ મોક ટેસ્ટ, પ્રશ્નોત્તરી અને પ્રિપેરેશન માર્ગદર્શન' },
  { title: 'Business Directory', category: 'Job & Business Services', icon: '🏪', description: 'સમાજ ઉદ્યોગ સાહસિકો અને વેપારીઓની બિઝનેસ ડિરેક્ટરી' },
  { title: 'Business Networking', category: 'Job & Business Services', icon: '🤝', description: 'બીટુબી કનેક્શન, વેપારી મીટિંગ અને ક્લાયન્ટ રેફરલ' },
  { title: 'Business Consultant', category: 'Job & Business Services', icon: '📈', description: 'સ્ટાર્ટઅપ સલાહ, બિઝનેસ ગ્રોથ સ્ટ્રેટેજી અને પ્લાનિંગ' },
  { title: 'GST / Tax Consultant', category: 'Job & Business Services', icon: '🧾', description: 'જીએસટી રજિસ્ટ્રેશન, રિટર્ન ફાઇલિંગ અને એકાઉન્ટિંગ' },

  // 6. Legal & Financial Services
  { title: 'Advocate / Legal Advice', category: 'Legal & Financial Services', icon: '⚖️', description: 'સિવિલ, ક્રિમિનલ, રેવન્યુ અને ફેમિલી મેટર્સ કાનૂની સલાહ' },
  { title: 'Document Writer', category: 'Legal & Financial Services', icon: '📑', description: 'દસ્તાવેજ લેખક, સોગંદનામા, કરાર અને એગ્રીમેન્ટ' },
  { title: 'Bank Loan Assistance', category: 'Legal & Financial Services', icon: '🏦', description: 'હોમ લોન, પર્સનલ લોન, બિઝનેસ લોન અને મોર્ગેજ સહાય' },
  { title: 'Financial Consultant', category: 'Legal & Financial Services', icon: '💰', description: 'રોકાણ, મ્યુચ્યુઅલ ફંડ અને નાણાકીય આયોજન સલાહ' },
  { title: 'Income Tax / GST', category: 'Legal & Financial Services', icon: '🧾', description: 'ઇન્કમ ટેક્સ રિટર્ન (ITR), પાન કાર્ડ અને ટીડીએસ સહાય' },
  { title: 'Property Documents', category: 'Legal & Financial Services', icon: '🏠', description: 'જમીન-મકાન દસ્તાવેજ, ૭/૧૨ ૮-અ ઉતારા અને ટાઇટલ ક્લિયરન્સ' },
  { title: 'Insurance Agent', category: 'Legal & Financial Services', icon: '📜', description: 'લાઇફ ઇન્સ્યોરન્સ (LIC), હેલ્થ પોલિસી અને વાહન વીમો' },
  { title: 'Loan / Finance Services', category: 'Legal & Financial Services', icon: '💳', description: 'સરળ વ્યાજે લોન અને ફાઇનાન્સિયલ સોલ્યુશન્સ' },
  { title: 'Banking Assistance', category: 'Legal & Financial Services', icon: '🏦', description: 'બેંક ખાતું ખોલવું, કેવાયસી અને સરકારી સબસિડી લોન' },

  // 7. Health & Emergency
  { title: 'Hospital', category: 'Health & Emergency', icon: '🏥', description: 'મલ્ટીસ્પેશિયાલિટી હોસ્પિટલ, ઇનપેશન્ટ અને સર્જરી સુવિધા' },
  { title: 'Doctor', category: 'Health & Emergency', icon: '👨‍⚕️', description: 'જનરલ ફિઝિશિયન, એમડી અને બાળરોગ નિષ્ણાત' },
  { title: 'Dentist', category: 'Health & Emergency', icon: '🦷', description: 'દાંતના રોગોની સારવાર, રૂટ કેનાલ અને ડેન્ટલ કેર' },
  { title: 'Eye Care', category: 'Health & Emergency', icon: '👓', description: 'આંખની તપાસ, ચશ્મા નંબર, મોતિયા ઓપરેશન માર્ગદર્શન' },
  { title: 'Medical Store', category: 'Health & Emergency', icon: '💊', description: 'જેનેરિક અને બ્રાન્ડેડ દવાઓ, હોમ ડિલિવરી' },
  { title: 'Ambulance', category: 'Health & Emergency', icon: '🚑', description: '૨૪ કલાક ઇમરજન્સી એમ્બ્યુલન્સ અને ઓક્સિજન સુવિધા' },
  { title: 'Blood Donor Directory', category: 'Health & Emergency', icon: '🩸', description: 'ઇમરજન્સી બ્લડ ડોનર યાદી અને રક્તદાન કેમ્પ' },
  { title: 'Laboratory / Diagnostic', category: 'Health & Emergency', icon: '🧪', description: 'લોહી-પેશાબ તપાસ, એક્સ-રે, સોનોગ્રાફી અને ઇસીજી' },
  { title: 'Home Nursing', category: 'Health & Emergency', icon: '🧑‍⚕️', description: 'દર્દીની ઘરે બેઠા નર્સિંગ કેર, ડ્રેસિંગ અને ઇન્જેક્શન' },
  { title: 'Elderly Assistance', category: 'Health & Emergency', icon: '♿', description: 'વડીલોની સંભાળ, વ્હીલચેર અને સહાયક સાધનો' },

  // 8. Business & Local Shops
  { title: 'Grocery', category: 'Business & Local Shops', icon: '🛒', description: 'કરિયાણું, અનાજ-કઠોળ અને દૈનિક ઘરવખરી સામાન' },
  { title: 'Clothes / Garments', category: 'Business & Local Shops', icon: '👗', description: 'રેડીમેડ કપડાં, સાડી, સૂટ અને ફેમિલી વેર' },
  { title: 'Footwear', category: 'Business & Local Shops', icon: '👟', description: 'શૂઝ, ચંપલ, સેન્ડલ અને લેધર ફૂટવેર' },
  { title: 'Mobile Shop', category: 'Business & Local Shops', icon: '📱', description: 'નવા/જૂના મોબાઇલ, એસેસરીઝ અને રિચાર્જ' },
  { title: 'Electronics', category: 'Business & Local Shops', icon: '💻', description: 'ટીવી, ફ્રિજ, વોશિંગ મશીન અને હોમ એપ્લાયન્સીસ' },
  { title: 'Furniture', category: 'Business & Local Shops', icon: '🪑', description: 'લાકડા અને લોખંડનું ઘર/ઓફિસ ફર્નિચર શોરૂમ' },
  { title: 'Jewellery', category: 'Business & Local Shops', icon: '💎', description: 'સોના-ચાંદીના ઘરેણાં અને ફેન્સી જ્વેલરી' },
  { title: 'Bakery', category: 'Business & Local Shops', icon: '🍰', description: 'કેક, પેસ્ટ્રી, બિસ્કિટ, બ્રેડ અને નમકીન' },
  { title: 'Restaurant / Food', category: 'Business & Local Shops', icon: '🍽️', description: 'ગુજરાતી થાળી, પંજાબી અને ફાસ્ટ ફૂડ રેસ્ટોરન્ટ' },
  { title: 'Printing Press', category: 'Business & Local Shops', icon: '🖨️', description: 'કંકોતરી, કાર્ડ્સ, ફ્લેક્સ બેનર અને બુક પ્રિન્ટિંગ' },

  // 9. Skilled Professionals
  { title: 'Electrician', category: 'Skilled Professionals', icon: '👨‍🔧', description: 'પ્રોફેશનલ ઇલેક્ટ્રિશિયન વાયરિંગ અને ફોલ્ટ રીપેરિંગ' },
  { title: 'Plumber', category: 'Skilled Professionals', icon: '🔧', description: 'સેનેટરી ફિટિંગ, ડ્રેનેજ અને નળ રીપેરિંગ' },
  { title: 'Carpenter', category: 'Skilled Professionals', icon: '🪚', description: 'કુશળ સુથાર કારીગર, વુડન વર્ક અને રિનોવેશન' },
  { title: 'Welder', category: 'Skilled Professionals', icon: '🔨', description: 'ફેબ્રિકેશન, લોખંડના ગેટ, ગ્રીલ અને વેલ્ડિંગ વર્ક' },
  { title: 'Mason', category: 'Skilled Professionals', icon: '🧱', description: 'કુશળ કડિયો, ટાઇલ્સ ફિટિંગ અને બાંધકામ' },
  { title: 'Painter', category: 'Skilled Professionals', icon: '🎨', description: 'એક્સટીરિયર/ઇન્ટીરિયર કલર સ્પેશિયાલિસ્ટ' },
  { title: 'Computer Technician', category: 'Skilled Professionals', icon: '👨‍💻', description: 'હાર્ડવેર, નેટવર્કિંગ અને સોફ્ટવેર એક્સપર્ટ' },
  { title: 'Mobile Technician', category: 'Skilled Professionals', icon: '📱', description: 'ચિપ લેવલ મોબાઇલ મધરબોર્ડ અને ડિસ્પ્લે રીપેર' },
  { title: 'Mechanic', category: 'Skilled Professionals', icon: '🚗', description: 'ઓટોમોબાઇલ ડીઝલ અને પેટ્રોલ મિકેનિક' },
  { title: 'AC Technician', category: 'Skilled Professionals', icon: '❄️', description: 'એસી ઇન્સ્ટોલેશન, કોપર પાઇપિંગ અને ગેસ ચાર્જિંગ' },
  { title: 'TV Technician', category: 'Skilled Professionals', icon: '📺', description: 'એલઇડી/સ્માર્ટ ટીવી પેનલ રીપેર અને મધરબોર્ડ કામ' },

  // 10. Agriculture & Farming — પેટા Categories
  { title: 'બીયારણની દુકાન — Seed Shop', category: 'Agriculture & Farming', icon: '🌱', description: 'ઉત્તમ ગુણવત્તાવાળા હાઇબ્રિડ બીયારણ અને પાક બિયારણ' },
  { title: 'ખાતર — Fertilizer Shop', category: 'Agriculture & Farming', icon: '🧪', description: 'ઓર્ગેનિક અને કેમિકલ ખાતર, યુરિયા, ડીએપી ખાતર' },
  { title: 'જંતુનાશક દવા — Pesticide Shop', category: 'Agriculture & Farming', icon: '🐛', description: 'પાક સંરક્ષણ જંતુનાશક દવાઓ અને સ્પ્રે' },
  { title: 'કૃષિ દવા — Agro Chemical Shop', category: 'Agriculture & Farming', icon: '🌿', description: 'એગ્રો કેમિકલ્સ, ટોનિક અને ફ્લાવરિંગ બૂસ્ટર' },
  { title: 'ટ્રેક્ટર — Tractor Dealer', category: 'Agriculture & Farming', icon: '🚜', description: 'નવા/જૂના ટ્રેક્ટર ખરીદ-વેચાણ અને સર્વિસ' },
  { title: 'ખેતીનાં સાધનો — Farm Equipment', category: 'Agriculture & Farming', icon: '⚙️', description: 'હળ, રોટાવેટર, કલ્ટીવેટર અને થ્રેશર' },
  { title: 'સિંચાઈ સાધનો — Irrigation Equipment', category: 'Agriculture & Farming', icon: '💧', description: 'પીવીસી પાઇપ, સ્પ્રિંકલર અને સબમર્સિબલ પંપ' },
  { title: 'ડ્રિપ સિંચાઈ — Drip Irrigation', category: 'Agriculture & Farming', icon: '💦', description: 'ટપક સિંચાઈ પદ્ધતિ, ફિલ્ટર અને પાઇપલાઇન ફિટિંગ' },
  { title: 'કૃષિ મશીનરી — Agricultural Machinery', category: 'Agriculture & Farming', icon: '🌾', description: 'હારવેસ્ટર, કટર મશીન અને સ્પ્રેયર પંપ' },
  { title: 'પશુ આહાર — Cattle Feed Shop', category: 'Agriculture & Farming', icon: '🐄', description: 'દૂધાળા પશુઓ માટે ખાણ, ખોળ અને પશુ આહાર' },
  { title: 'ડેરી સાધનો — Dairy Equipment', category: 'Agriculture & Farming', icon: '🐄', description: 'મિલ્કિંગ મશીન, કેન, ચિલિંગ પ્લાન્ટ અને ડેરી સાધનો' },
  { title: 'નર્સરી — Plant Nursery', category: 'Agriculture & Farming', icon: '🌳', description: 'ફળ-ફૂલના રોપા, કલમો અને ઓર્ગેનિક છોડ' },
  { title: 'અનાજ ખરીદ-વેચાણ — Grain Trading', category: 'Agriculture & Farming', icon: '🌾', description: 'ઘઉં, કપાસ, જીરું, એરંડા અને અનાજ હોલસેલ વેપાર' },
  { title: 'શાકભાજી / ફળ વેપારી — Fruits & Vegetables', category: 'Agriculture & Farming', icon: '🥬', description: 'તાજા શાકભાજી અને ફળોના હોલસેલ વેપારી' },
  { title: 'કૃષિ સેવા — Agricultural Services', category: 'Agriculture & Farming', icon: '🧑‍🌾', description: 'જમીન ચકાસણી, ખેતી સલાહ અને ડ્રોન સ્પ્રે સેવા' },

  // 11. Trolley, Caster Wheel & Cane Products
  { title: 'Trolley & Caster Wheel Shop', category: 'Trolley, Caster Wheel & Cane Products', icon: '🛒', description: 'દરેક પ્રકારની ટ્રોલી અને કેસ્ટર વ્હીલનું રિટેલ/હોલસેલ વેચાણ' },
  { title: 'Trolley Wheel & Caster Manufacturer', category: 'Trolley, Caster Wheel & Cane Products', icon: '🔘', description: 'ટ્રોલી વ્હીલ અને હેવી ડ્યુટી કેસ્ટર મેન્યુફેક્ચરિંગ' },
  { title: 'Cane Basket Manufacturer', category: 'Trolley, Caster Wheel & Cane Products', icon: '🧺', description: 'નેતરની ટોપલીઓ, કેન બાસ્કેટ અને હેન્ડીક્રાફ્ટ ઉત્પાદન' },
  { title: 'Trolley & Cane Products', category: 'Trolley, Caster Wheel & Cane Products', icon: '🛒', description: 'ટ્રોલી અને નેતરની બનાવટોનું સંયુક્ત ડીલરશીપ' },
  { title: 'Industrial Trolley & Wheel Supplier', category: 'Trolley, Caster Wheel & Cane Products', icon: '🏭', description: 'ફેક્ટરી/ઇન્ડસ્ટ્રી માટે હેવી મટીરીયલ હેન્ડલિંગ ટ્રોલી' },
  { title: 'Cane Basket & Trolley Manufacturer', category: 'Trolley, Caster Wheel & Cane Products', icon: '🧺', description: 'ઉચ્ચ ગુણવત્તાવાળી કેન બાસ્કેટ અને પ્લેટફોર્મ ટ્રોલી' },
  { title: 'Trolley, Wheel & Basket Manufacturing', category: 'Trolley, Caster Wheel & Cane Products', icon: '🏭', description: 'ટ્રોલી, રબર/નાયલોન વ્હીલ્સ અને બાસ્કેટ બનાવટ' },
  { title: 'Caster Wheel & Trolley Parts', category: 'Trolley, Caster Wheel & Cane Products', icon: '⚙️', description: 'કેસ્ટર વ્હીલ બેરિંગ, સ્પેરપાર્ટ્સ અને કસ્ટમ ફિટિંગ' },
  { title: 'Cane Products & Trolley Solutions', category: 'Trolley, Caster Wheel & Cane Products', icon: '🧺', description: 'ટ્રોલી સોલ્યુશન્સ અને ડેકોરેટિવ કેન પ્રોડક્ટ્સ' },
  { title: 'Trolley & Caster Wheel Manufacturing', category: 'Trolley, Caster Wheel & Cane Products', icon: '🏭', description: 'સ્ટેનલેસ સ્ટીલ અને એમએસ ટ્રોલી મેન્યુફેક્ચરિંગ' },
  { title: 'Trolley Manufacturer', category: 'Trolley, Caster Wheel & Cane Products', icon: '🛒', description: 'કસ્ટમ પ્લેટફોર્મ, વેરહાઉસ અને હેન્ડ ટ્રોલી ઉત્પાદક' },
  { title: 'Caster Wheel', category: 'Trolley, Caster Wheel & Cane Products', icon: '⚙️', description: 'પીયુ, પીપી, રબર અને નાયલોન કેસ્ટર વ્હીલ્સ' },
  { title: 'Trolley Wheel', category: 'Trolley, Caster Wheel & Cane Products', icon: '🔘', description: 'સોલિડ રબર, ન્યુમેટિક અને હેવી વ્હીલ્સ' },
  { title: 'Industrial Trolley', category: 'Trolley, Caster Wheel & Cane Products', icon: '🏭', description: 'ફેક્ટરી યુઝ, ડ્રમ ટ્રોલી અને ટૂલ ટ્રોલી' },
  { title: 'Cane Basket', category: 'Trolley, Caster Wheel & Cane Products', icon: '🧺', description: 'પરંપરાગત નેતરની ટોપલીઓ અને બાસ્કેટ' },
  { title: 'Cane Products', category: 'Trolley, Caster Wheel & Cane Products', icon: '🧺', description: 'નેતરનું ફર્નિચર, બેઠક, કલાત્મક વસ્તુઓ' },
  { title: 'Trolley Repair & Parts', category: 'Trolley, Caster Wheel & Cane Products', icon: '🔧', description: 'ટ્રોલી રીપેરીંગ, વ્હીલ બદલવું અને વેલ્ડિંગ' },
  { title: 'Material Handling Equipment', category: 'Trolley, Caster Wheel & Cane Products', icon: '🚚', description: 'હાઇડ્રોલિક પેલેટ ટ્રક અને મટીરીયલ લિફ્ટિંગ સાધનો' },
  { title: 'Shopping Trolley', category: 'Trolley, Caster Wheel & Cane Products', icon: '🛍️', description: 'સુપરમાર્કેટ અને રિટેલ સ્ટોર શોપિંગ ટ્રોલી' },
  { title: 'Hospital Trolley', category: 'Trolley, Caster Wheel & Cane Products', icon: '🏥', description: 'મેડિકલ, સ્ટ્રેચર, ડ્રેસિંગ અને હોસ્પિટલ ટ્રોલી' },
];

function httpRequest(url, options = {}, postData = null) {
  return new Promise((resolve, reject) => {
    const req = https.request(url, options, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          resolve({ status: res.statusCode, data: json });
        } catch (e) {
          resolve({ status: res.statusCode, data, raw: true });
        }
      });
    });
    req.on('error', reject);
    if (postData) {
      req.write(postData);
    }
    req.end();
  });
}

async function run() {
  console.log('🚀 Starting insertion of all Samaj Services into Live Application...');

  // Step 1: Login as Admin
  console.log('🔐 Authenticating as Admin...');
  const loginBody = JSON.stringify({ email: 'admin@vankarsamaj.com', password: 'Admin@123' });
  const loginRes = await httpRequest(`${API_BASE}/auth/login`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(loginBody),
    },
  }, loginBody);

  if (loginRes.status !== 200 || !loginRes.data.accessToken) {
    throw new Error(`Admin login failed: ${JSON.stringify(loginRes.data)}`);
  }

  const token = loginRes.data.accessToken;
  console.log('✅ Admin login successful!');

  // Step 2: Fetch existing services
  console.log('📥 Fetching existing services to prevent duplicates...');
  const existingRes = await httpRequest(`${API_BASE}/admin/samaj-services`, {
    method: 'GET',
    headers: { Authorization: `Bearer ${token}` },
  });

  const existingServices = Array.isArray(existingRes.data) ? existingRes.data : [];
  console.log(`📊 Found ${existingServices.length} existing services.`);
  const existingTitles = new Set(existingServices.map(s => `${s.title.toLowerCase().trim()}|${s.category.toLowerCase().trim()}`));

  // Step 3: Insert services
  let createdCount = 0;
  let skippedCount = 0;

  console.log(`\n⏳ Inserting ${servicesData.length} Samaj Services...`);

  for (let i = 0; i < servicesData.length; i++) {
    const item = servicesData[i];
    const key = `${item.title.toLowerCase().trim()}|${item.category.toLowerCase().trim()}`;

    if (existingTitles.has(key)) {
      console.log(`⏩ [${i + 1}/${servicesData.length}] Already exists: ${item.icon} ${item.title} (${item.category})`);
      skippedCount++;
      continue;
    }

    const payload = JSON.stringify({
      title: item.title,
      category: item.category,
      icon: item.icon,
      description: item.description || null,
      isActive: true,
      sortOrder: i + 1,
    });

    const res = await httpRequest(`${API_BASE}/admin/samaj-services`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(payload),
      },
    }, payload);

    if (res.status === 201) {
      console.log(`✅ [${i + 1}/${servicesData.length}] Created: ${item.icon} ${item.title} [${item.category}]`);
      createdCount++;
      existingTitles.add(key);
    } else {
      console.error(`❌ [${i + 1}/${servicesData.length}] Failed: ${item.title} - Status: ${res.status}`, res.data);
    }

    // Small delay between requests to be gentle on server
    await new Promise(r => setTimeout(r, 60));
  }

  console.log(`\n=============================================`);
  console.log(`🎉 Insertion Complete!`);
  console.log(`✨ Created: ${createdCount}`);
  console.log(`⏭️  Skipped (Already existed): ${skippedCount}`);

  // Step 4: Verification
  console.log('\n🔍 Verifying all Samaj Services in Live Application...');
  const verifyRes = await httpRequest(`${API_BASE}/samaj-services`);
  if (Array.isArray(verifyRes.data)) {
    console.log(`✅ Total Active Samaj Services in Live App: ${verifyRes.data.length}`);
    const byCategory = {};
    for (const s of verifyRes.data) {
      byCategory[s.category] = (byCategory[s.category] || 0) + 1;
    }
    console.log('\n📊 Category Breakdown:');
    for (const [cat, count] of Object.entries(byCategory)) {
      console.log(`   • ${cat}: ${count} services`);
    }
  }
}

run().catch(console.error);
