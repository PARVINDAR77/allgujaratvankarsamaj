class AppData {
  static const List<String> privateSectors = [
    'Select Category',
    'IT / Software Development',
    'Banking / Financial Services (BFSI)',
    'Healthcare / Medical / Hospital',
    'Engineering / Manufacturing',
    'Education / Teaching',
    'Sales / Marketing / Business Development',
    'Admin / HR / Operations',
    'Retail / FMCG',
    'Textile / Garments',
    'Diamond / Jewelry',
    'Construction / Real Estate',
    'Telecommunications / ISP',
    'BPO / KPO / Customer Service',
    'Logistics / Supply Chain / Transport',
    'Pharmaceutical / Biotech',
    'Agriculture / Dairy / Fertilizers',
    'Automobile / Auto Components',
    'Media / Entertainment / Advertising',
    'Travel / Tourism / Hospitality',
    'Legal / Consulting',
    'Export / Import',
    'Accounting / Taxation',
    'Oil & Gas / Energy',
    'Other (અન્ય)'
  ];

  static const List<String> businessSectors = [
    'Select Category',
    'Retail / Shop (કરિયાણા/અન્ય દુકાન)',
    'Wholesale / Trading (જથ્થાબંધ વેપાર)',
    'Manufacturing / Factory (ઉત્પાદન)',
    'Agriculture / Farming (ખેતી)',
    'Real Estate / Construction',
    'Consultancy / Professional Services',
    'Textile / Clothing Business',
    'Diamond Trading / Cutting',
    'Hotel / Restaurant / Food Business',
    'Transport / Logistics',
    'IT / Technology Services',
    'Healthcare / Pharmacy Clinic',
    'Event Management / Decor',
    'Beauty Parlor / Salon',
    'Automobile / Garage / Spares',
    'Hardware / Building Materials',
    'E-commerce / Online Business',
    'Education / Tuition Classes',
    'Other (અન્ય)'
  ];

  static const List<String> incomeRanges = [
    'Select Income',
    '₹0–1 લાખ',
    '₹1–2 લાખ',
    '₹2–3 લાખ',
    '₹3–4 લાખ',
    '₹4–5 લાખ',
    '₹5–7 લાખ',
    '₹7–10 લાખ',
    '₹10–15 લાખ',
    '₹15–20 લાખ',
    '₹20–30 લાખ',
    '₹30–50 લાખ',
    '₹50 લાખ–₹1 કરોડ',
    '₹1 કરોડથી વધુ',
  ];

  static const List<String> religionOptions = [
    'Select Religion',
    'હિન્દુ ધર્મ (Hinduism)',
    'ઇસ્લામ ધર્મ (Islam)',
    'ખ્રિસ્તી ધર્મ (Christianity)',
    'શીખ ધર્મ (Sikhism)',
    'બૌદ્ધ ધર્મ (Buddhism)',
    'જૈન ધર્મ (Jainism)',
    'યહૂદી ધર્મ (Judaism)',
    'પારસી / ઝોરાષ્ટ્રિયન ધર્મ (Zoroastrianism)',
    'બહાઈ ધર્મ (Baháʼí Faith)',
    'અન્ય ધર્મો / આદિવાસી પરંપરાઓ',
    'કોઈ ધર્મ નહીં / ધર્મ જાહેર નથી (No religion / Not stated)',
  ];

  static const Map<String, List<String>> gujaratDistricts = {
    'Select District': ['Select Taluka'],
    'Ahmedabad': [
      'Ahmedabad City', 'Bavla', 'Daskroi', 'Detroj-Rampura', 'Dhandhuka',
      'Dholera', 'Dholka', 'Mandal', 'Sanand', 'Viramgam'
    ],
    'Amreli': [
      'Amreli', 'Babra', 'Bagasara', 'Dhari', 'Jafrabad', 'Khambha',
      'Kunkavav Vadia', 'Lathi', 'Lilia', 'Rajula', 'Savar Kundla'
    ],
    'Anand': [
      'Anand', 'Anklav', 'Borsad', 'Khambhat', 'Petlad', 'Sojitra', 'Tarapur', 'Umreth'
    ],
    'Aravalli': [
      'Bayad', 'Bhiloda', 'Dhansura', 'Malpur', 'Meghraj', 'Modasa'
    ],
    'Banaskantha': [
      'Amirgadh', 'Bhabhar', 'Dantiwada', 'Danta', 'Deesa', 'Deodar',
      'Dhanera', 'Kankrej', 'Lakhani', 'Palanpur', 'Suigam', 'Tharad', 'Vadgam', 'Vav'
    ],
    'Bharuch': [
      'Bharuch', 'Amod', 'Ankleshwar', 'Hansot', 'Jambusar', 'Netrang', 'Vagra', 'Valia', 'Jhagadia'
    ],
    'Bhavnagar': [
      'Bhavnagar', 'Gariadhar', 'Ghogha', 'Jesar', 'Mahuva', 'Palitana',
      'Sihor', 'Talaja', 'Umrala', 'Vallabhipur'
    ],
    'Botad': [
      'Botad', 'Barwala', 'Gadhada', 'Ranpur'
    ],
    'Chhota Udaipur': [
      'Chhota Udaipur', 'Bodeli', 'Jetpur Pavi', 'Kavant', 'Nasvadi', 'Sankheda'
    ],
    'Dahod': [
      'Dahod', 'Devgadh Baria', 'Dhanpur', 'Fatepura', 'Garbada', 'Limkheda', 'Sanjeli', 'Jhalod'
    ],
    'Dang': [
      'Ahwa', 'Subir', 'Waghai'
    ],
    'Devbhoomi Dwarka': [
      'Bhanvad', 'Kalyanpur', 'Khambhalia', 'Okhamandal'
    ],
    'Gandhinagar': [
      'Gandhinagar', 'Dehgam', 'Kalol', 'Mansa'
    ],
    'Gir Somnath': [
      'Gir Gadhada', 'Kodinar', 'Sutrapada', 'Talala', 'Una', 'Patan-Veraval'
    ],
    'Jamnagar': [
      'Jamnagar', 'Dhrol', 'Jamjodhpur', 'Jodiya', 'Kalavad', 'Lalpur'
    ],
    'Junagadh': [
      'Junagadh City', 'Bhesan', 'Junagadh Rural', 'Keshod', 'Malia Hatina', 'Manavadar', 'Mangrol', 'Mendarda', 'Vanthali', 'Visavadar'
    ],
    'Kheda': [
      'Nadiad', 'Balasinor', 'Dakhor', 'Galteshwar', 'Kapadvanj', 'Kathlal', 'Kheda', 'Mahudha', 'Matar', 'Mehmedabad', 'Thasra', 'Vaso'
    ],
    'Kutch': [
      'Bhuj', 'Abdasa', 'Anjar', 'Bhachau', 'Gandhidham', 'Lakhpat', 'Mandvi', 'Mundra', 'Nakhatrana', 'Rapar'
    ],
    'Mahisagar': [
      'Lunawada', 'Balasinor', 'Kadana', 'Khanpur', 'Santrampur', 'Virpur'
    ],
    'Mehsana': [
      'Mehsana', 'Becharaji', 'Jotana', 'Kadi', 'Kheralu', 'Satlasana', 'Unjha', 'Vadnagar', 'Vijapur', 'Visnagar'
    ],
    'Morbi': [
      'Morbi', 'Halvad', 'Maliya', 'Tankara', 'Wankaner'
    ],
    'Narmada': [
      'Rajpipla', 'Dediapada', 'Garudeshwar', 'Nandod', 'Sagbara', 'Tilakwada'
    ],
    'Navsari': [
      'Navsari', 'Vansda', 'Chikhli', 'Gandevi', 'Jalalpore', 'Khergam'
    ],
    'Panchmahal': [
      'Godhra', 'Ghoghaba', 'Halol', 'Jambughoda', 'Kalol', 'Morwa Hadaf', 'Shehera'
    ],
    'Patan': [
      'Patan', 'Chanasma', 'Harij', 'Radhanpur', 'Sami', 'Santalpur', 'Sarasvati', 'Sidhpur', 'Shankheshwar'
    ],
    'Porbandar': [
      'Porbandar', 'Kutiyana', 'Ranavav'
    ],
    'Rajkot': [
      'Rajkot', 'Dhoraji', 'Gondal', 'Jam Kandorna', 'Jasdan', 'Jetpur', 'Kotada Sangani', 'Lodhika', 'Paddhari', 'Upleta', 'Vinchhiya'
    ],
    'Sabarkantha': [
      'Himmatnagar', 'Idar', 'Khedbrahma', 'Poshina', 'Prantij', 'Talod', 'Vadali', 'Vijaynagar'
    ],
    'Surat': [
      'Surat City', 'Bardoli', 'Choryasi', 'Kamrej', 'Mahuva', 'Mandvi', 'Mangrol', 'Olpad', 'Palsana', 'Umarpada'
    ],
    'Surendranagar': [
      'Surendranagar', 'Chotila', 'Chuda', 'Dasada', 'Dhrangadhra', 'Lakhtar', 'Limbdi', 'Muli', 'Sayla', 'Thangadh', 'Wadhwan'
    ],
    'Tapi': [
      'Vyara', 'Nizar', 'Songadh', 'Uchhal', 'Valod', 'Kukarmunda', 'Dolvan'
    ],
    'Vadodara': [
      'Vadodara', 'Dabhoi', 'Desar', 'Karjan', 'Padra', 'Savli', 'Sinor', 'Vaghodia'
    ],
    'Valsad': [
      'Valsad', 'Dharampur', 'Kaprada', 'Pardi', 'Umbergaon', 'Vapi'
    ]
  };

  static const List<String> educationDegrees = [
    'Select Degree',
    'No Formal Education',
    'Primary School',
    '5th Fail',
    '5th Pass',
    '8th Fail',
    '8th Pass',
    '10th Fail',
    '10th Pass / SSC',
    '12th Fail',
    '12th Pass / HSC',
    '12th Arts',
    '12th Commerce',
    '12th Science',
    '12th Vocational',
    'ITI',
    'Certificate Course',
    'Computer Certificate',
    'CCC',
    'Tally',
    'Vocational Course',
    'Diploma',
    'Polytechnic Diploma',
    'Diploma in Engineering',
    'Diploma in Civil Engineering',
    'Diploma in Mechanical Engineering',
    'Diploma in Electrical Engineering',
    'Diploma in Computer Engineering',
    'Diploma in Electronics',
    'Diploma in Pharmacy',
    'Diploma in Nursing',
    'Other Diploma',
    'B.A.',
    'B.Com.',
    'B.Sc.',
    'B.B.A.',
    'B.C.A.',
    'B.S.W.',
    'B.Ed.',
    'B.P.Ed.',
    'B.Lib.',
    'B.Pharm.',
    'B.Sc. Nursing',
    'B.A.M.S.',
    'B.H.M.S.',
    'B.D.S.',
    'M.B.B.S.',
    'B.E.',
    'B.Tech.',
    'B.Arch.',
    'B.Des.',
    'B.F.A.',
    'B.Voc.',
    'Other Bachelor\'s Degree',
    'M.A.',
    'M.Com.',
    'M.Sc.',
    'M.B.A.',
    'M.C.A.',
    'M.S.W.',
    'M.Ed.',
    'M.P.Ed.',
    'M.Lib.',
    'M.Pharm.',
    'M.E.',
    'M.Tech.',
    'M.Arch.',
    'M.Des.',
    'L.L.M.',
    'M.D.',
    'M.S. (Medical)',
    'M.D.S.',
    'Other Master\'s Degree',
    'C.A.',
    'C.M.A.',
    'C.S.',
    'C.F.A.',
    'C.P.A.',
    'A.C.C.A.',
    'C.W.A.',
    'L.L.B.',
    'Advocate',
    'Architect',
    'Engineer',
    'Doctor',
    'Dentist',
    'Pharmacist',
    'M.Phil.',
    'Ph.D.',
    'D.Litt.',
    'D.Sc.',
    'D.L.',
    'Post-Doctoral',
    'Studying',
    'Pursuing Degree',
    'Pursuing Diploma',
    'Other Qualification (અન્ય)',
    'Not Applicable',
    'Not Specified'
  ];

  static const List<String> abroadCountries = [
    'Select Country (દેશ પસંદ કરો)',
    'Afghanistan — અફઘાનિસ્તાન', 'Albania — અલ્બેનિયા', 'Algeria — અલ્જીરિયા', 'Andorra — એન્ડોરા', 'Angola — અંગોલા',
    'Antigua and Barbuda — એન્ટિગુઆ અને બાર્બુડા', 'Argentina — આર્જેન્ટિના', 'Armenia — આર્મેનિયા', 'Australia — ઓસ્ટ્રેલિયા',
    'Austria — ઓસ્ટ્રિયા', 'Azerbaijan — અઝરબૈજાન', 'Bahamas — બહામાસ', 'Bahrain — બહેરીન', 'Bangladesh — બાંગ્લાદેશ',
    'Barbados — બાર્બાડોસ', 'Belarus — બેલારુસ', 'Belgium — બેલ્જિયમ', 'Belize — બેલીઝ', 'Benin — બેનિન',
    'Bhutan — ભૂટાન', 'Bolivia — બોલિવિયા', 'Bosnia and Herzegovina — બોસ્નિયા અને હર્ઝેગોવિના', 'Botswana — બોત્સ્વાના',
    'Brazil — બ્રાઝિલ', 'Brunei — બ્રુનેઈ', 'Bulgaria — બલ્ગેરિયા', 'Burkina Faso — બુર્કિના ફાસો', 'Burundi — બુરુન્ડી',
    'Cabo Verde — કાબો વર્ડે', 'Cambodia — કંબોડિયા', 'Cameroon — કેમરૂન', 'Canada — કેનેડા', 'Central African Republic — મધ્ય આફ્રિકન પ્રજાસત્તાક',
    'Chad — ચાડ', 'Chile — ચિલી', 'China — ચીન', 'Colombia — કોલંબિયા', 'Comoros — કોમોરોસ',
    'Congo — કોંગો', 'Costa Rica — કોસ્ટા રિકા', 'Côte d\'Ivoire — કોટ દિ\'વોઆર', 'Croatia — ક્રોએશિયા', 'Cuba — ક્યુબા',
    'Cyprus — સાયપ્રસ', 'Czechia — ચેકિયા', 'Democratic Republic of the Congo — ડેમોક્રેટિક રિપબ્લિક ઓફ કોંગો', 'Denmark — ડેનમાર્ક',
    'Djibouti — જિબુટી', 'Dominica — ડોમિનિકા', 'Dominican Republic — ડોમિનિકન રિપબ્લિક', 'Ecuador — એક્વાડોર', 'Egypt — ઇજિપ્ત',
    'El Salvador — અલ સાલ્વાડોર', 'Equatorial Guinea — ઇક્વેટોરિયલ ગિની', 'Eritrea — એરિટ્રિયા', 'Estonia — એસ્ટોનિયા', 'Eswatini — એસ્વાતિની',
    'Ethiopia — ઇથોપિયા', 'Fiji — ફિજી', 'Finland — ફિનલેન્ડ', 'France — ફ્રાન્સ', 'Gabon — ગેબોન',
    'Gambia — ગેમ્બિયા', 'Georgia — જ્યોર્જિયા', 'Germany — જર્મની', 'Ghana — ઘાના', 'Greece — ગ્રીસ',
    'Grenada — ગ્રેનેડા', 'Guatemala — ગ્વાટેમાલા', 'Guinea — ગિની', 'Guinea-Bissau — ગિની-બિસાઉ', 'Guyana — ગયાના',
    'Haiti — હૈતી', 'Honduras — હોન્ડુરાસ', 'Hungary — હંગેરી', 'Iceland — આઇસલેન્ડ', 'India — ભારત',
    'Indonesia — ઇન્ડોનેશિયા', 'Iran — ઈરાન', 'Iraq — ઈરાક', 'Ireland — આયર્લેન્ડ', 'Israel — ઇઝરાયેલ',
    'Italy — ઇટાલી', 'Jamaica — જમૈકા', 'Japan — જાપાન', 'Jordan — જોર્ડન', 'Kazakhstan — કઝાકિસ્તાન',
    'Kenya — કેન્યા', 'Kiribati — કિરિબાટી', 'Kuwait — કુવૈત', 'Kyrgyzstan — કિર્ગિઝસ્તાન', 'Laos — લાઓસ',
    'Latvia — લાતવિયા', 'Lebanon — લેબનોન', 'Lesotho — લેસોથો', 'Liberia — લાઇબેરિયા', 'Libya — લિબિયા',
    'Liechtenstein — લિખ્ટેનસ્ટાઇન', 'Lithuania — લિથુઆનિયા', 'Luxembourg — લક્ઝમબર્ગ', 'Madagascar — મેડાગાસ્કર', 'Malawi — માલાવી',
    'Malaysia — મલેશિયા', 'Maldives — માલદીવ', 'Mali — માલી', 'Malta — માલ્ટા', 'Marshall Islands — માર્શલ ટાપુઓ',
    'Mauritania — મોરિટાનિયા', 'Mauritius — મોરિશિયસ', 'Mexico — મેક્સિકો', 'Micronesia — માઇક્રોનેશિયા', 'Moldova — મોલડોવા',
    'Monaco — મોનાકો', 'Mongolia — મંગોલિયા', 'Montenegro — મોન્ટેનેગ્રો', 'Morocco — મોરોક્કો', 'Mozambique — મોઝામ્બિક',
    'Myanmar — મ્યાનમાર', 'Namibia — નામિબિયા', 'Nauru — નાઉરુ', 'Nepal — નેપાળ', 'Netherlands — નેધરલેન્ડ્સ',
    'New Zealand — ન્યૂઝીલેન્ડ', 'Nicaragua — નિકારાગુઆ', 'Niger — નાઇજર', 'Nigeria — નાઇજીરિયા', 'North Korea — ઉત્તર કોરિયા',
    'North Macedonia — ઉત્તર મેસેડોનિયા', 'Norway — નોર્વે', 'Oman — ઓમાન', 'Pakistan — પાકિસ્તાન', 'Palau — પલાઉ',
    'Palestine — પેલેસ્ટાઇન', 'Panama — પનામા', 'Papua New Guinea — પાપુઆ ન્યૂ ગિની', 'Paraguay — પેરાગ્વે', 'Peru — પેરુ',
    'Philippines — ફિલિપાઇન્સ', 'Poland — પોલેન્ડ', 'Portugal — પોર્ટુગલ', 'Qatar — કતાર', 'Romania — રોમાનિયા',
    'Russia — રશિયા', 'Rwanda — રવાંડા', 'Saint Kitts and Nevis — સેન્ટ કિટ્સ અને નેવિસ', 'Saint Lucia — સેન્ટ લુસિયા', 'Saint Vincent and the Grenadines — સેન્ટ વિન્સેન્ટ અને ગ્રેનેડાઇન્સ',
    'Samoa — સામોઆ', 'San Marino — સાન મેરિનો', 'São Tomé and Príncipe — સાઓ તોમે અને પ્રિન્સિપે', 'Saudi Arabia — સાઉદી અરેબિયા', 'Senegal — સેનેગલ',
    'Serbia — સર્બિયા', 'Seychelles — સેશેલ્સ', 'Sierra Leone — સિયેરા લિયોન', 'Singapore — સિંગાપોર', 'Slovakia — સ્લોવાકિયા',
    'Slovenia — સ્લોવેનિયા', 'Solomon Islands — સોલોમન ટાપુઓ', 'Somalia — સોમાલિયા', 'South Africa — દક્ષિણ આફ્રિકા', 'South Korea — દક્ષિણ કોરિયા',
    'South Sudan — દક્ષિણ સુદાન', 'Spain — સ્પેન', 'Sri Lanka — શ્રીલંકા', 'Sudan — સુદાન', 'Suriname — સુરીનામ',
    'Sweden — સ્વીડન', 'Switzerland — સ્વિટ્ઝર્લેન્ડ', 'Syria — સીરિયા', 'Tajikistan — તાજિકિસ્તાન', 'Tanzania — તાન્ઝાનિયા',
    'Thailand — થાઇલેન્ડ', 'Timor-Leste — તિમોર-લેસ્તે', 'Togo — ટોગો', 'Tonga — ટોંગા', 'Trinidad and Tobago — ટ્રિનિડાડ અને ટોબેગો',
    'Tunisia — ટ્યુનિશિયા', 'Türkiye — તુર્કિયે', 'Turkmenistan — તુર્કમેનિસ્તાન', 'Tuvalu — તુવાલુ', 'Uganda — યુગાન્ડા',
    'Ukraine — યુક્રેન', 'United Arab Emirates — સંયુક્ત આરબ અમીરાત', 'United Kingdom — યુનાઇટેડ કિંગડમ', 'United States — યુનાઇટેડ સ્ટેટ્સ', 'Uruguay — ઉરુગ્વે',
    'Uzbekistan — ઉઝબેકિસ્તાન', 'Vanuatu — વનુઆતુ', 'Vatican City — વેટિકન સિટી', 'Venezuela — વેનેઝુએલા', 'Vietnam — વિયેતનામ',
    'Yemen — યમન', 'Zambia — ઝામ્બિયા', 'Zimbabwe — ઝિમ્બાબ્વે',
    'Other Country (અન્ય દેશ)'
  ];
}
