import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../profile/providers/profile_provider.dart';
import '../../../../shared/constants/app_data.dart';
import '../../../../shared/models/profile_model.dart';
import '../../../home/presentation/widgets/web_home_header.dart';

class PrivateEmployeesScreen extends ConsumerStatefulWidget {
  const PrivateEmployeesScreen({super.key});

  @override
  ConsumerState<PrivateEmployeesScreen> createState() => _PrivateEmployeesScreenState();
}

class _PrivateEmployeesScreenState extends ConsumerState<PrivateEmployeesScreen> {
  String _sector = 'All';
  String _post = 'All';
  String _district = 'All';
  String _taluka = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileNotifierProvider.notifier).updateFilters(occupationCategory: 'Private');
    });
  }

  static const Map<String, String> _translations = {
    // Private & Business Sectors
    'IT / Software Development': 'આઈ.ટી. અને સોફ્ટવેર',
    'IT & Software': 'આઈ.ટી. અને સોફ્ટવેર',
    'Banking / Financial Services (BFSI)': 'બેન્કિંગ અને ફાયનાન્સ',
    'Banking & Finance': 'બેન્કિંગ અને ફાયનાન્સ',
    'Healthcare / Medical / Hospital': 'આરોગ્ય અને મેડિકલ',
    'Healthcare & Hospital': 'આરોગ્ય અને હોસ્પિટલ',
    'Engineering / Manufacturing': 'એન્જિનિયરિંગ અને ઉત્પાદન',
    'Engineering & Manufacturing': 'ઉત્પાદન અને પ્લાન્ટ',
    'Business / Self-Employed': 'વેપાર અને સ્વરોજગાર',
    'Business & Self-Employed': 'વેપાર અને સ્વરોજગાર',
    'Education / Teaching': 'ખાનગી શિક્ષણ અને ટ્યુશન',
    'Private Education & Academic': 'ખાનગી શિક્ષણ',
    'Sales / Marketing / Business Development': 'સેલ્સ અને માર્કેટિંગ',
    'Sales & Marketing': 'સેલ્સ અને માર્કેટિંગ',
    'Admin / HR / Operations': 'એડમિન અને એચ.આર.',
    'Retail / FMCG': 'રીટેલ અને એફ.એમ.સી.જી.',
    'Retail / Shop (કરિયાણા/અન્ય દુકાન)': 'દુકાન અને રીટેલ',
    'Wholesale / Trading (જથ્થાબંધ વેપાર)': 'જથ્થાબંધ વેપાર અને ટ્રેડિંગ',
    'Manufacturing / Factory (ઉત્પાદન)': 'મેન્યુફેક્ચરિંગ અને ફેક્ટરી',
    'Agriculture / Farming (ખેતી)': 'ખેતી અને એગ્રીકલ્ચર',
    'Textile / Garments': 'કાપડ અને ટેક્સટાઇલ',
    'Textile & Garments': 'કાપડ અને ગારમેન્ટ્સ',
    'Textile / Clothing Business': 'કાપડનો વ્યવસાય',
    'Diamond / Jewelry': 'હીરા અને ઝવેરાત',
    'Diamond & Jewelry': 'હીરા અને જ્વેલરી',
    'Diamond Trading / Cutting': 'હીરા ટ્રેડિંગ અને કટિંગ',
    'Construction / Real Estate': 'બાંધકામ અને રિયલ એસ્ટેટ',
    'Real Estate / Construction': 'રિયલ એસ્ટેટ અને બિલ્ડર',
    'Telecommunications / ISP': 'ટેલિકોમ્યુનિકેશન્સ',
    'BPO / KPO / Customer Service': 'બી.પી.ઓ. અને કસ્ટમર સર્વિસ',
    'Logistics / Supply Chain / Transport': 'લોજિસ્ટિક્સ અને ટ્રાન્સપોર્ટ',
    'Transport / Logistics': 'ટ્રાન્સપોર્ટ સેવાઓ',
    'Pharmaceutical / Biotech': 'ફાર્માસ્યુટિકલ અને લેબ',
    'Automobile / Auto Components': 'ઓટોમોબાઇલ ક્ષેત્ર',
    'Automobile / Garage / Spares': 'ગેરેજ અને સ્પેર્સ',
    'Hotel / Restaurant / Food Business': 'હોટેલ અને ફૂડ બિઝનેસ',
    'Consultancy / Professional Services': 'કન્સલ્ટન્સી સેવાઓ',
    'Legal / Consulting': 'કાયદાકીય સલાહકાર',
    'Legal & Consultancy': 'કાયદાકીય અને કન્સલ્ટિંગ',
    'Accounting / Taxation': 'એકાઉન્ટિંગ અને ટેક્સેશન',
    'Event Management / Decor': 'ઇવેન્ટ મેનેજમેન્ટ',
    'Beauty Parlor / Salon': 'બ્યુટી પાર્લર અને સલૂન',
    'E-commerce / Online Business': 'ઓનલાઇન બિઝનેસ',
    'General': 'સામાન્ય ક્ષેત્ર',
    'Private Industry & Services': 'ખાનગી ઉદ્યોગ અને સેવાઓ',
    'Other': 'અન્ય વ્યવસાય',
    'Other (અન્ય)': 'અન્ય',

    // Designations / Roles
    'Software Engineer': 'સોફ્ટવેર એન્જિનિયર',
    'Web Developer': 'વેબ ડેવલપર',
    'App Developer': 'મોબાઇલ એપ ડેવલપર',
    'Project Manager': 'પ્રોજેક્ટ મેનેજર',
    'Team Lead': 'ટીમ લીડર',
    'Chartered Accountant': 'ચાર્ટર્ડ એકાઉન્ટન્ટ (CA)',
    'Accountant': 'એકાઉન્ટન્ટ',
    'Bank Manager': 'બેંક મેનેજર',
    'Bank Officer': 'બેંક અધિકારી',
    'Financial Analyst': 'ફાયનાન્સિયલ એનાલિસ્ટ',
    'Doctor': 'ડોક્ટર / તબીબ',
    'Physician': 'ફિઝિશિયન',
    'Surgeon': 'સર્જન',
    'Dentist': 'ડેન્ટિસ્ટ',
    'Pharmacist': 'ફાર્માસિસ્ટ',
    'Staff Nurse': 'સ્ટાફ નર્સ (પ્રાઇવેટ)',
    'Civil Engineer': 'સિવિલ એન્જિનિયર',
    'Mechanical Engineer': 'મિકેનિકલ એન્જિનિયર',
    'Electrical Engineer': 'ઇલેક્ટ્રિકલ એન્જિનિયર',
    'Quality Inspector': 'ક્વોલિટી ઇન્સ્પેક્ટર',
    'Business Owner': 'વેપારી / માલિક',
    'Proprietor': 'પ્રોપરાઇટર',
    'Partner': 'ભાગીદાર / પાર્ટનર',
    'Director': 'ડિરેક્ટર',
    'Managing Director': 'મેનેજિંગ ડિરેક્ટર',
    'Sales Manager': 'સેલ્સ મેનેજર',
    'Sales Executive': 'સેલ્સ એક્ઝિક્યુટિવ',
    'Marketing Manager': 'માર્કેટિંગ મેનેજર',
    'HR Manager': 'એચ.આર. મેનેજર',
    'HR Executive': 'એચ.આર. એક્ઝિક્યુટિવ',
    'Store Manager': 'સ્ટોર મેનેજર',
    'Shopkeeper': 'દુકાનદાર / વેપારી',
    'Teacher': 'ખાનગી શિક્ષક',
    'Professor': 'પ્રોફેસર',
    'Lecturer': 'લેક્ચરર',
    'Advocate': 'એડવોકેટ / વકીલ',
    'Legal Advisor': 'લીગલ એડવાઈઝર',
    'Architect': 'આર્કિટેક્ટ',
    'Interior Designer': 'ઇન્ટિરિયર ડિઝાઇનર',
    'Graphic Designer': 'ગ્રાફિક ડિઝાઇનર',
    'Supervisor': 'સુપરવાઇઝર',
    'Executive': 'એક્ઝિક્યુટિવ',
    'Consultant': 'કન્સલ્ટન્ટ',
    'Manager': 'મેનેજર',
    'Employee': 'કર્મચારી',
    'Professional': 'પ્રોફેશનલ',
    'Professional / Employee': 'પ્રોફેશનલ / કર્મચારી',
    'Computer Engineer (IT)': 'કોમ્પ્યુટર એન્જિનિયર (આઈ.ટી.)',
    'Computer Engineer': 'કોમ્પ્યુટર એન્જિનિયર',
    'computer engineeres': 'કોમ્પ્યુટર એન્જિનિયર',
    'IT Company & Software Solutions': 'આઈ.ટી. કંપની અને સોફ્ટવેર સોલ્યુશન્સ',
    'it company': 'આઈ.ટી. કંપની',
    'Wedding': 'લગ્ન પ્રસંગ અને કંકોતરી સેવાઓ',
    'Kankotri & Wedding Invitation Cards': 'કંકોતરી અને પ્રિન્ટિંગ સેવાઓ',
    'Kankotri & Wedding Invitation Cards (કંકોતરી પ્રિન્ટિંગ)': 'કંકોતરી પ્રિન્ટિંગ સેવાઓ',

    // Districts
    'Gandhinagar': 'ગાંધીનગર',
    'Ahmedabad': 'અમદાવાદ',
    'Surat': 'સુરત',
    'Vadodara': 'વડોદરા',
    'Rajkot': 'રાજકોટ',
    'Jamnagar': 'જામનગર',
    'Junagadh': 'જૂનાગઢ',
    'Bhavnagar': 'ભાવનગર',
    'Mehsana': 'મહેસાણા',
    'Kutch': 'કચ્છ',
    'Anand': 'આણંદ',
    'Kheda': 'ખેડા',
    'Patan': 'પાટણ',
    'Banaskantha': 'બનાસકાંઠા',
    'Sabarkantha': 'સાબરકાંઠા',
    'Bharuch': 'ભરૂચ',
    'Navsari': 'નવસારી',
    'Valsad': 'વલસાડ',
    'Panchmahal': 'પંચમહાલ',
    'Dahod': 'દાહોદ',
    'Surendranagar': 'સુરેન્દ્રનગર',
    'Amreli': 'અમરેલી',
    'Morbi': 'મોરબી',
    'Porbandar': 'પોરબંદર',
    'Gir Somnath': 'ગીર સોમનાથ',
    'Botad': 'બોટાદ',
    'Devbhoomi Dwarka': 'દેવભૂમિ દ્વારકા',
    'Aravalli': 'અરવલ્લી',
    'Chhota Udaipur': 'છોટા ઉદેપુર',
    'Dang': 'ડાંગ',
    'Mahisagar': 'મહીસાગર',
    'Narmada': 'નર્મદા',
    'Tapi': 'તાપી',
    
    // Talukas
    'Ahmedabad City': 'અમદાવાદ શહેર',
    'Choryasi': 'ચોર્યાસી',
    'Vadodara City': 'વડોદરા શહેર',
    'Jasdan': 'જસદણ',
    'Jamnagar City': 'જામનગર શહેર',
    'Junagadh City': 'જૂનાગઢ શહેર',
    'Bhavnagar City': 'ભાવનગર શહેર',
    'Mehsana City': 'મહેસાણા શહેર',
    'Bhuj': 'ભુજ',
    'Kalol': 'કલોલ',
    'Dehgam': 'દહેગામ',
    'Mansa': 'માણસા',
    'Sanand': 'સાણંદ',
    'Daskroi': 'દસક્રોઈ',
    'Dholka': 'ધોળકા',
    'Viramgam': 'વિરમગામ',
    'Kamrej': 'કામરેજ',
    'Mandvi': 'માંડવી',
    'Mangrol': 'માંગરોળ',
    'Olpad': 'ઓલપાડ',
    'Padra': 'પાદરા',
    'Karjan': 'કરજણ',
    'Savli': 'સાવલી',
    'Waghodia': 'વાઘોડિયા',
    'Rajkot City': 'રાજકોટ શહેર',
    'Gondal': 'ગોંડલ',
    'Jetpur': 'જેતપુર',
    'Dhoraji': 'ધોરાજી',
    'Dhrol': 'ધ્રોલ',
    'Jodiya': 'જોડિયા',
    'Lalpur': 'લાલપુર',
    'Keshod': 'કેશોદ',
    'Mendarda': 'મેંદરડા',
    'Manavadar': 'માણાવદર',
    'Palitana': 'પાલીતાણા',
    'Mahuva': 'મહુવા',
    'Gariadhar': 'ગારિયાધાર',
    'Kadi': 'કડી',
    'Unjha': 'ઊંઝા',
    'Visnagar': 'વિસનગર',
    'Anjar': 'અંજાર',
    'Mandvi (Kutch)': 'માંડવી (કચ્છ)',
    'Mundra': 'મુંદ્રા',
    'Gandhidham': 'ગાંધીધામ',
  };

  static const Map<String, List<String>> _districtTalukas = {
    'Gandhinagar': ['Gandhinagar', 'Kalol', 'Dehgam', 'Mansa'],
    'Ahmedabad': ['Ahmedabad City', 'Sanand', 'Daskroi', 'Dholka', 'Viramgam'],
    'Surat': ['Choryasi', 'Kamrej', 'Mandvi', 'Mangrol', 'Olpad'],
    'Vadodara': ['Vadodara City', 'Padra', 'Karjan', 'Savli', 'Waghodia'],
    'Rajkot': ['Rajkot City', 'Jasdan', 'Gondal', 'Jetpur', 'Dhoraji'],
    'Jamnagar': ['Jamnagar City', 'Dhrol', 'Jodiya', 'Lalpur'],
    'Junagadh': ['Junagadh City', 'Keshod', 'Mendarda', 'Manavadar'],
    'Bhavnagar': ['Bhavnagar City', 'Palitana', 'Mahuva', 'Gariadhar'],
    'Mehsana': ['Mehsana City', 'Kadi', 'Unjha', 'Visnagar'],
    'Kutch': ['Bhuj', 'Anjar', 'Mandvi (Kutch)', 'Mundra', 'Gandhidham'],
  };

  static final List<Map<String, dynamic>> _curatedSampleData = [
    {
      'id': 'VNK79799',
      'name': 'Parvindar Panjabi',
      'dept': 'IT / Software Development',
      'post': 'Computer Engineer (IT)',
      'company': 'IT Company & Software Solutions',
      'education': 'B.Tech.',
      'experience': 'Computer Engineer & IT Solutions',
      'district': 'Ahmedabad',
      'taluka': 'Dholka',
      'nativePlace': '35 Gam Pargana (૧૦૩. ૩૫ પરગણું - ઈડર)',
      'pargana': '35 Gam Pargana',
      'phone': '',
      'email': 'panjabiparvindar77@gmail.com',
      'address': 'Dholka, Ahmedabad, Gujarat',
      'about': 'B.Tech Computer Engineer working in IT company. Also provides Kankotri & Wedding Invitation Cards (કંકોતરી પ્રિન્ટિંગ) services.',
      'isVerified': true,
      'photoUrl': 'https://allgujaratvankarsamaj.com/uploads/590c4f23-83f5-4bbf-ab97-9dadaa6d8760.jpg',
      'icon': Icons.computer,
      'iconColor': const Color(0xFF0288D1),
    },
    {
      'id': '1001',
      'name': 'Rahul K. Solanki',
      'dept': 'IT / Software Development',
      'post': 'Software Engineer',
      'company': 'InfoTech Solutions Pvt. Ltd., SG Highway',
      'education': 'B.E. (Information Technology), GTU',
      'experience': '6+ Years in Cloud & Enterprise Software',
      'district': 'Ahmedabad',
      'taluka': 'Ahmedabad City',
      'nativePlace': 'Dholka (ધોળકા)',
      'pargana': 'Bhal (ભાલ)',
      'phone': '+91 94280 67890',
      'email': 'rahul.solanki.it@gmail.com',
      'address': 'B-402, Titanium City Centre, Prahlad Nagar, Ahmedabad - 380015',
      'about': 'Full-stack software engineer specializing in scalable enterprise cloud architecture and cross-platform apps.',
      'isVerified': true,
      'icon': Icons.computer,
      'iconColor': const Color(0xFF0056D2),
    },
    {
      'id': '1002',
      'name': 'Amit P. Parmar',
      'dept': 'Banking / Financial Services (BFSI)',
      'post': 'Chartered Accountant',
      'company': 'A. P. Parmar & Associates (Chartered Accountants)',
      'education': 'FCA, B.Com, DISA (ICAI)',
      'experience': '10+ Years in Corporate Audit, GST & Taxation',
      'district': 'Surat',
      'taluka': 'Choryasi',
      'nativePlace': 'Bardoli (બારડોલી)',
      'pargana': 'Surat Chovisi (સુરત ચોવીસી)',
      'phone': '+91 98795 23456',
      'email': 'ca.amitparmar@gmail.com',
      'address': '301, Silver Point, Ring Road, Surat - 395002',
      'about': 'Providing comprehensive financial planning, corporate audit, tax compliance, and project finance consultation.',
      'isVerified': true,
      'icon': Icons.account_balance_wallet,
      'iconColor': const Color(0xFF4CAF50),
    },
    {
      'id': '1003',
      'name': 'Dr. Priya V. Vankar',
      'dept': 'Healthcare / Medical / Hospital',
      'post': 'Doctor',
      'company': 'Shreeji Multi-Speciality Hospital & Clinic, Vadodara',
      'education': 'M.B.B.S., M.D. (Internal Medicine)',
      'experience': '8+ Years in General Medicine & Critical Care',
      'district': 'Vadodara',
      'taluka': 'Vadodara City',
      'nativePlace': 'Karjan (કરજણ)',
      'pargana': 'Vadodara Chovisi (વડોદરા ચોવીસી)',
      'phone': '+91 98250 12345',
      'email': 'dr.priya.vankar@gmail.com',
      'address': '204, Doctor House, Near Station, Alkapuri, Vadodara - 390007',
      'about': 'Dedicated to providing compassionate patient care, health awareness camps, and preventive healthcare consultation.',
      'isVerified': true,
      'icon': Icons.local_hospital,
      'iconColor': const Color(0xFFE91E63),
    },
    {
      'id': '1004',
      'name': 'Jayesh M. Chavda',
      'dept': 'Business / Self-Employed',
      'post': 'Business Owner',
      'company': 'Chavda Engineering Works & Machinery',
      'education': 'Diploma in Mechanical Engineering',
      'experience': '15+ Years in Industrial Spares & Lathe Works',
      'district': 'Rajkot',
      'taluka': 'Rajkot City',
      'nativePlace': 'Gondal (ગોંડલ)',
      'pargana': 'Saurashtra 12 Gam (સૌરાષ્ટ્ર ૧૨ ગામ)',
      'phone': '+91 99042 34567',
      'email': 'jayesh.chavda.works@gmail.com',
      'address': 'Plot No. 45, GIDC Industrial Estate, Aji Dam, Rajkot - 360003',
      'about': 'Manufacturer of precision machine tools, auto parts, and custom mechanical fabrication.',
      'isVerified': true,
      'icon': Icons.store,
      'iconColor': const Color(0xFFFF9800),
    },
    {
      'id': '1005',
      'name': 'Ketan R. Rathod',
      'dept': 'Engineering / Manufacturing',
      'post': 'Civil Engineer',
      'company': 'Gujarat Infrastructure & Construction Corp.',
      'education': 'B.Tech (Civil Engineering), Nirma University',
      'experience': '9+ Years in Highway, Residential & Commercial Projects',
      'district': 'Gandhinagar',
      'taluka': 'Gandhinagar',
      'nativePlace': 'Mansa (માણસા)',
      'pargana': 'Gandhinagar Chovisi (ગાંધીનગર ચોવીસી)',
      'phone': '+91 97234 56789',
      'email': 'ketan.rathod.civil@gmail.com',
      'address': 'Sector 11, Near Infocity, Gandhinagar - 382010',
      'about': 'Civil project manager experienced in urban construction, structural design, and EPC infrastructure delivery.',
      'isVerified': true,
      'icon': Icons.engineering,
      'iconColor': const Color(0xFF9C27B0),
    },
    {
      'id': '1006',
      'name': 'Bhavik B. Makwana',
      'dept': 'Textile / Garments',
      'post': 'Proprietor',
      'company': 'Makwana Textiles & Fashion Prints',
      'education': 'B.B.A. (Marketing & Trade)',
      'experience': '12+ Years in Textile Weaving & Wholesale Distribution',
      'district': 'Surat',
      'taluka': 'Kamrej',
      'nativePlace': 'Olpad (ઓલપાડ)',
      'pargana': 'Surat Zilla Vankar Samaj',
      'phone': '+91 98241 87654',
      'email': 'bhavik.textiles@gmail.com',
      'address': 'G-12, Millennium Textile Market, Ring Road, Surat - 395002',
      'about': 'Specializing in premium synthetic fabrics, jacquard sarees, uniform materials, and export-grade textiles.',
      'isVerified': true,
      'icon': Icons.shopping_bag,
      'iconColor': const Color(0xFF009688),
    },
    {
      'id': '1007',
      'name': 'Nilesh D. Vaghela',
      'dept': 'Diamond / Jewelry',
      'post': 'Director',
      'company': 'Vaghela Gems & Jewels',
      'education': 'Graduate Gemologist (GIA), B.Sc.',
      'experience': '14+ Years in Diamond Polishing & Wholesale Gems',
      'district': 'Bhavnagar',
      'taluka': 'Bhavnagar City',
      'nativePlace': 'Sihor (શિહોર)',
      'pargana': 'Gohilwad Vankar Samaj',
      'phone': '+91 99789 12300',
      'email': 'nilesh.vaghela.gems@gmail.com',
      'address': '405, Heera Bazar, Near City Center, Bhavnagar - 364001',
      'about': 'Certified diamond manufacturer and bullion jeweler providing certified natural and lab-grown diamonds.',
      'isVerified': true,
      'icon': Icons.diamond,
      'iconColor': const Color(0xFF3F51B5),
    },
    {
      'id': '1008',
      'name': 'Hardik S. Jadav',
      'dept': 'Sales / Marketing / Business Development',
      'post': 'Marketing Manager',
      'company': 'North Gujarat Agro & Dairy Allied Products',
      'education': 'M.B.A. (Marketing & Supply Chain)',
      'experience': '7+ Years in FMCG Distribution & Brand Strategy',
      'district': 'Mehsana',
      'taluka': 'Mehsana City',
      'nativePlace': 'Unjha (ઊંઝા)',
      'pargana': 'Mehsana Chovisi',
      'phone': '+91 94088 76543',
      'email': 'hardik.jadav.sales@gmail.com',
      'address': 'Radhanpur Road, Near Modhera Circle, Mehsana - 384002',
      'about': 'Experienced in FMCG brand acceleration, retail dealer network expansion, and regional sales operations.',
      'isVerified': true,
      'icon': Icons.campaign,
      'iconColor': const Color(0xFFE65100),
    },
  ];

  String _getTranslatedText(String englishText) {
    if (_translations.containsKey(englishText)) {
      return '$englishText (${_translations[englishText]})';
    }
    return englishText;
  }

  List<Map<String, dynamic>> get _allData {
    final profileState = ref.watch(profileNotifierProvider);
    
    // Strictly filter out any government profiles
    final privateProfiles = profileState.profiles.where((p) {
      final emp = p.employmentType.toLowerCase();
      final dept = p.department.toLowerCase();
      final desig = p.designation.toLowerCase();

      // Exclude government jobs
      if (emp.contains('government') || emp.contains('સરકારી') ||
          dept.contains('police') || dept.contains('revenue') || dept.contains('talati') ||
          dept.contains('panchayat') || dept.contains('geb') || dept.contains('forest') ||
          dept.contains('judiciary') || dept.contains('ias') ||
          desig.contains('police') || desig.contains('talati') || desig.contains('gram sevak') ||
          desig.contains('constable') || desig.contains('psi') || desig.contains('pi')) {
        return false;
      }

      // Match private or business
      return emp.contains('private') || 
             emp.contains('business') || 
             emp.contains('self') ||
             emp.contains('ખાનગી') ||
             emp.contains('વેપાર') ||
             emp.contains('સ્વરોજગાર') ||
             (p.businessIndustry != null && p.businessIndustry!.isNotEmpty) ||
             (p.businessService != null && p.businessService!.isNotEmpty) ||
             (p.department.isNotEmpty && p.department != 'General') ||
             p.designation.isNotEmpty;
    }).toList();

    if (privateProfiles.isNotEmpty) {
      final List<Map<String, dynamic>> realList = privateProfiles.map((p) {
        String sector = 'Private Industry & Services';
        if (p.department.toLowerCase().contains('it') ||
            p.department.toLowerCase().contains('tech') ||
            p.designation.toLowerCase().contains('computer') ||
            p.designation.toLowerCase().contains('software') ||
            p.designation.toLowerCase().contains('developer') ||
            p.designation.toLowerCase().contains('engineer')) {
          sector = 'IT / Software Development';
        } else if (p.businessIndustry != null && p.businessIndustry!.isNotEmpty && p.businessIndustry != 'Select Industry') {
          sector = p.businessIndustry!;
        } else if (p.employmentType.toLowerCase().contains('business') || p.employmentType.toLowerCase().contains('વેપાર')) {
          sector = 'Business / Self-Employed';
        } else if (p.department.isNotEmpty && p.department != 'General') {
          sector = p.department;
        } else if (p.employmentType.isNotEmpty) {
          sector = p.employmentType;
        }

        String role = 'Professional / Employee';
        if (p.designation.isNotEmpty && p.designation != 'Employee') {
          role = p.designation;
          if (role.toLowerCase() == 'computer engineeres' || role.toLowerCase() == 'computer engineer') {
            role = 'Computer Engineer (IT)';
          }
        } else if (p.businessService != null && p.businessService!.isNotEmpty && p.businessService != 'Select Service') {
          role = p.businessService!;
        }

        String company = '';
        if (p.department.isNotEmpty && p.department != 'General') {
          company = p.department.toLowerCase() == 'it company' ? 'IT Company & Software Solutions' : p.department;
        } else if (p.businessService != null && p.businessService!.isNotEmpty) {
          company = p.businessService!;
        } else if (p.businessIndustry != null && p.businessIndustry!.isNotEmpty) {
          company = p.businessIndustry!;
        }

        // District & Taluka normalization
        String dist = p.district.trim();
        if (dist.toLowerCase() == 'ahmdabad' || dist.toLowerCase() == 'ahmedabad') {
          dist = 'Ahmedabad';
        } else if (dist.isEmpty) {
          dist = 'Ahmedabad';
        }

        String tal = p.taluka.trim();
        if (tal.toLowerCase() == 'dholka') {
          tal = 'Dholka';
        } else if (tal.isEmpty) {
          tal = 'Dholka';
        }

        IconData icon = Icons.business_center;
        Color iconColor = const Color(0xFF0056D2);
        if (sector.contains('IT') || sector.contains('Software')) {
          icon = Icons.computer;
          iconColor = const Color(0xFF0288D1);
        } else if (sector.contains('Business') || sector.contains('Shop') || sector.contains('Trading')) {
          icon = Icons.storefront;
          iconColor = const Color(0xFFF57C00);
        } else if (sector.contains('Healthcare') || sector.contains('Doctor')) {
          icon = Icons.local_hospital;
          iconColor = const Color(0xFFE91E63);
        } else if (sector.contains('Banking') || sector.contains('Finance')) {
          icon = Icons.account_balance;
          iconColor = const Color(0xFF2E7D32);
        }

        final addressParts = [
          p.addressLine,
          tal,
          dist,
          (p.pincode != null && p.pincode!.isNotEmpty) ? 'Pin: ${p.pincode}' : null,
        ].where((s) => s != null && s.toString().trim().isNotEmpty).toList();

        final displayId = p.id.startsWith('VNK') ? p.id : (p.id.length > 5 ? p.id.substring(p.id.length - 4) : p.id);

        return {
          'id': displayId,
          'name': p.fullName.trim().isNotEmpty ? p.fullName : 'Parvindar Panjabi',
          'dept': sector,
          'post': role,
          'company': company,
          'education': p.education,
          'experience': p.designation,
          'district': dist,
          'taluka': tal,
          'nativePlace': p.nativePlace ?? '',
          'pargana': p.pargana,
          'phone': p.contactPhone ?? '',
          'email': p.contactEmail ?? '',
          'address': addressParts.join(', '),
          'about': p.about ?? '',
          'isVerified': p.isVerified ?? false,
          'photoUrl': p.photoUrl,
          'profile': p,
          'icon': icon,
          'iconColor': iconColor,
        };
      }).toList();

      final existingIds = realList.map((e) => e['id'].toString().toUpperCase()).toSet();
      final existingNames = realList.map((e) => e['name'].toString().toLowerCase().trim()).toSet();
      final filteredCurated = _curatedSampleData.where((e) {
        final curId = e['id'].toString().toUpperCase();
        final curName = e['name'].toString().toLowerCase().trim();
        return !existingIds.contains(curId) && !existingNames.contains(curName);
      }).toList();

      return [...realList, ...filteredCurated];
    }

    // Curated high quality sample private & business employees if DB has no private entries
    return _curatedSampleData;
  }

  List<String> get _sectors {
    final list = _allData.map((e) => e['dept'] as String).toSet().toList();
    // Add popular private sectors if not already included
    for (final s in AppData.privateSectors) {
      if (s != 'Select Category' && !list.contains(s)) {
        list.add(s);
      }
    }
    list.sort();
    return ['All', ...list];
  }

  List<String> get _posts {
    final list = _allData.map((e) => e['post'] as String).toSet().toList();
    list.sort();
    return ['All', ...list];
  }

  List<String> get _districts {
    final set = <String>{};
    for (final d in AppData.gujaratDistricts.keys) {
      if (d != 'Select District') set.add(d);
    }
    for (final e in _allData) {
      final d = e['district'] as String?;
      if (d != null && d.isNotEmpty && d != 'All') set.add(d);
    }
    final list = set.toList()..sort();
    return ['All', ...list];
  }

  List<String> get _talukas {
    if (_district == 'All') {
      return ['All'];
    }
    final list = AppData.gujaratDistricts[_district] ?? _districtTalukas[_district] ?? [];
    return ['All', ...list];
  }

  List<Map<String, dynamic>> get _filteredData {
    return _allData.where((item) {
      if (_sector != 'All' && 
          item['dept'].toString().toLowerCase() != _sector.toLowerCase() &&
          !item['dept'].toString().toLowerCase().contains(_sector.toLowerCase())) {
        return false;
      }
      if (_post != 'All' && 
          item['post'].toString().toLowerCase() != _post.toLowerCase() &&
          !item['post'].toString().toLowerCase().contains(_post.toLowerCase())) {
        return false;
      }
      if (_district != 'All' && 
          item['district'].toString().toLowerCase() != _district.toLowerCase() &&
          !item['district'].toString().toLowerCase().contains(_district.toLowerCase())) {
        return false;
      }
      if (_taluka != 'All' && 
          item['taluka'].toString().toLowerCase() != _taluka.toLowerCase() &&
          !item['taluka'].toString().toLowerCase().contains(_taluka.toLowerCase())) {
        return false;
      }
      if (_searchController.text.trim().isNotEmpty) {
        final q = _searchController.text.trim().toLowerCase();
        final name = (item['name'] ?? '').toString().toLowerCase();
        final id = (item['id'] ?? '').toString().toLowerCase();
        final dept = (item['dept'] ?? '').toString().toLowerCase();
        final post = (item['post'] ?? '').toString().toLowerCase();
        final company = (item['company'] ?? '').toString().toLowerCase();
        final dist = (item['district'] ?? '').toString().toLowerCase();
        final tal = (item['taluka'] ?? '').toString().toLowerCase();
        final about = (item['about'] ?? '').toString().toLowerCase();
        final native = (item['nativePlace'] ?? '').toString().toLowerCase();
        final pargana = (item['pargana'] ?? '').toString().toLowerCase();
        
        final matches = name.contains(q) ||
            id.contains(q) ||
            dept.contains(q) ||
            post.contains(q) ||
            company.contains(q) ||
            dist.contains(q) ||
            tal.contains(q) ||
            about.contains(q) ||
            native.contains(q) ||
            pargana.contains(q);
        if (!matches) return false;
      }
      return true;
    }).toList();
  }

  void _resetFilters() {
    setState(() {
      _sector = 'All';
      _post = 'All';
      _district = 'All';
      _taluka = 'All';
      _searchController.clear();
    });
  }

  void _showEmployeeDetails(Map<String, dynamic> data) {
    final hasPhone = data['phone'] != null && data['phone'].toString().trim().isNotEmpty;
    final hasEmail = data['email'] != null && data['email'].toString().trim().isNotEmpty;
    final hasCompany = data['company'] != null && data['company'].toString().trim().isNotEmpty;
    final hasEducation = data['education'] != null && data['education'].toString().trim().isNotEmpty;
    final hasExperience = data['experience'] != null && data['experience'].toString().trim().isNotEmpty;
    final hasNative = data['nativePlace'] != null && data['nativePlace'].toString().trim().isNotEmpty;
    final hasPargana = data['pargana'] != null && data['pargana'].toString().trim().isNotEmpty;
    final hasAddress = data['address'] != null && data['address'].toString().trim().isNotEmpty;
    final hasAbout = data['about'] != null && data['about'].toString().trim().isNotEmpty;

    final screenHeight = MediaQuery.of(context).size.height;
    final maxModalHeight = (screenHeight * 0.86).clamp(480.0, 740.0);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 20,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 540, maxHeight: maxModalHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Header Banner
              _buildModalHeader(ctx, data),

              // 2. Scrollable Content Body with Visible Scrollbar
              Flexible(
                child: Scrollbar(
                  thumbVisibility: true,
                  radius: const Radius.circular(8),
                  thickness: 5,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      // Section A: Work & Profession
                      _buildModalSectionHeader('કારકિર્દી અને સંસ્થા (Profession & Workplace)', Icons.work_outline, const Color(0xFF0056D2)),
                      _buildModalCard(
                        children: [
                          _buildModalDetailTile(
                            icon: Icons.category_outlined,
                            iconColor: const Color(0xFF0056D2),
                            label: 'Sector / Industry (ક્ષેત્ર / વ્યવસાય)',
                            value: _getTranslatedText(data['dept']?.toString() ?? 'N/A'),
                          ),
                          _buildModalDivider(),
                          _buildModalDetailTile(
                            icon: Icons.badge_outlined,
                            iconColor: const Color(0xFFE91E63),
                            label: 'Role / Designation (હોદ્દો / પદ)',
                            value: _getTranslatedText(data['post']?.toString() ?? 'N/A'),
                          ),
                          if (hasCompany) ...[
                            _buildModalDivider(),
                            _buildModalDetailTile(
                              icon: Icons.apartment_outlined,
                              iconColor: const Color(0xFF009688),
                              label: 'Organization / Company / Hospital (સંસ્થા / કંપની)',
                              value: data['company'].toString(),
                            ),
                          ],
                          if (hasEducation) ...[
                            _buildModalDivider(),
                            _buildModalDetailTile(
                              icon: Icons.school_outlined,
                              iconColor: const Color(0xFF9C27B0),
                              label: 'Education / Qualification (શિક્ષણ / પદવી)',
                              value: data['education'].toString(),
                            ),
                          ],
                          if (hasExperience) ...[
                            _buildModalDivider(),
                            _buildModalDetailTile(
                              icon: Icons.workspace_premium_outlined,
                              iconColor: const Color(0xFFFF9800),
                              label: 'Experience / Specialization (અનુભવ / વિશેષતા)',
                              value: data['experience'].toString(),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Section B: Location & Native Roots
                      _buildModalSectionHeader('સ્થળ અને મૂળ વતન (Location & Roots)', Icons.place_outlined, const Color(0xFF4CAF50)),
                      _buildModalCard(
                        children: [
                          _buildModalDetailTile(
                            icon: Icons.location_city_outlined,
                            iconColor: const Color(0xFF4CAF50),
                            label: 'District & Taluka (જિલ્લો અને તાલુકો)',
                            value: '${_getTranslatedText(data['district']?.toString() ?? '')} • ${_getTranslatedText(data['taluka']?.toString() ?? '')}',
                          ),
                          if (hasNative) ...[
                            _buildModalDivider(),
                            _buildModalDetailTile(
                              icon: Icons.home_outlined,
                              iconColor: const Color(0xFF00A2FF),
                              label: 'Native Place (મૂળ વતન)',
                              value: data['nativePlace'].toString(),
                            ),
                          ],
                          if (hasPargana) ...[
                            _buildModalDivider(),
                            _buildModalDetailTile(
                              icon: Icons.groups_outlined,
                              iconColor: const Color(0xFF673AB7),
                              label: 'Pargana / Circle (પરગણા)',
                              value: data['pargana'].toString(),
                            ),
                          ],
                          if (hasAddress) ...[
                            _buildModalDivider(),
                            _buildModalDetailTile(
                              icon: Icons.map_outlined,
                              iconColor: const Color(0xFF795548),
                              label: 'Workplace Address (સરનામું)',
                              value: data['address'].toString(),
                            ),
                          ],
                        ],
                      ),

                      if (hasPhone || hasEmail) ...[
                        const SizedBox(height: 16),
                        _buildModalSectionHeader('સંપર્ક વિગત (Contact Information)', Icons.contact_phone_outlined, const Color(0xFFE65100)),
                        _buildModalCard(
                          children: [
                            if (hasPhone)
                              _buildModalDetailTile(
                                icon: Icons.phone_outlined,
                                iconColor: const Color(0xFF2E7D32),
                                label: 'Phone / Mobile (મોબાઇલ નંબર)',
                                value: data['phone'].toString(),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.copy, size: 18, color: Color(0xFF0056D2)),
                                      tooltip: 'Copy Number',
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: data['phone'].toString()));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Phone number copied to clipboard'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final uri = Uri.parse('tel:${data['phone'].toString().replaceAll(' ', '')}');
                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(uri);
                                        }
                                      },
                                      icon: const Icon(Icons.call, size: 14),
                                      label: const Text('Call', style: TextStyle(fontSize: 12)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2E7D32),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                        minimumSize: const Size(64, 30),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (hasPhone && hasEmail) _buildModalDivider(),
                            if (hasEmail)
                              _buildModalDetailTile(
                                icon: Icons.mail_outline,
                                iconColor: const Color(0xFFD32F2F),
                                label: 'Email (ઇમેઇલ)',
                                value: data['email'].toString(),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.copy, size: 18, color: Color(0xFF0056D2)),
                                      tooltip: 'Copy Email',
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: data['email'].toString()));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Email copied to clipboard'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final uri = Uri.parse('mailto:${data['email'].toString().trim()}');
                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(uri);
                                        }
                                      },
                                      icon: const Icon(Icons.send, size: 14),
                                      label: const Text('Mail', style: TextStyle(fontSize: 12)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0056D2),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                        minimumSize: const Size(64, 30),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],

                      if (hasAbout) ...[
                        const SizedBox(height: 16),
                        _buildModalSectionHeader('વિશેષ પરિચય (About & Profile Summary)', Icons.info_outline, const Color(0xFF673AB7)),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.format_quote, color: Color(0xFF94A3B8), size: 24),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  data['about'].toString(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    height: 1.45,
                                    color: Color(0xFF334155),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),

              // 3. Modal Footer Actions
              _buildModalFooter(ctx, data),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalHeader(BuildContext ctx, Map<String, dynamic> data) {
    final photoUrl = data['photoUrl']?.toString();
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
    final isVerified = data['isVerified'] == true;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF041126), Color(0xFF0B254E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF3C34D), width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFF0F326A),
              backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
              child: !hasPhoto
                  ? const Icon(Icons.person, color: Color(0xFFF3C34D), size: 30)
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          // Name and Role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        data['name'].toString(),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    if (isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified, color: Color(0xFFF3C34D), size: 18),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _getTranslatedText(data['post']?.toString() ?? ''),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF3C34D),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'ID: #${data['id']}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _getTranslatedText(data['dept']?.toString() ?? ''),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFBFDBFE),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Close button
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70, size: 22),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Close (બંધ કરો)',
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  Widget _buildModalSectionHeader(String title, IconData icon, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: iconColor,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildModalDetailTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  Widget _buildModalDivider() {
    return const Divider(height: 12, thickness: 0.7, color: Color(0xFFF1F5F9));
  }

  ProfileModel _resolveCandidateProfile(Map<String, dynamic> data) {
    if (data['profile'] is ProfileModel) {
      return data['profile'] as ProfileModel;
    }

    final rawName = (data['name'] ?? '').toString().trim();
    String firstName = rawName;
    String lastName = '';
    final nameParts = rawName.split(' ');
    if (nameParts.isNotEmpty) {
      firstName = nameParts.first;
      if (nameParts.length > 1) {
        lastName = nameParts.sublist(1).join(' ');
      }
    }

    final company = data['company']?.toString() ?? '';
    final dept = data['dept']?.toString() ?? '';
    final departmentDisplay = company.isNotEmpty
        ? (dept.isNotEmpty ? '$company ($dept)' : company)
        : dept;

    final rawId = (data['profileId'] ?? data['id'] ?? '1001').toString();

    return ProfileModel(
      id: rawId,
      firstName: firstName,
      lastName: lastName,
      education: data['education']?.toString() ?? '',
      employmentType: 'Private Sector (ખાનગી નોકરી / સેકટર)',
      department: departmentDisplay,
      designation: data['post']?.toString() ?? 'Professional',
      district: data['district']?.toString() ?? '',
      taluka: data['taluka']?.toString() ?? '',
      pargana: data['pargana']?.toString() ?? '',
      nativePlace: data['nativePlace']?.toString(),
      addressLine: data['address']?.toString(),
      contactPhone: data['phone']?.toString(),
      contactEmail: data['email']?.toString(),
      about: data['about']?.toString(),
      photoUrl: data['photoUrl']?.toString(),
      isVerified: data['isVerified'] == true,
      gender: 'Male (પુરુષ)',
      maritalStatus: 'Never Married (અપરિણીત)',
      dateOfBirth: '',
    );
  }

  Widget _buildModalFooter(BuildContext ctx, Map<String, dynamic> data) {
    final hasPhone = data['phone'] != null && data['phone'].toString().trim().isNotEmpty;
    final profile = _resolveCandidateProfile(data);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 450;
          return Row(
            children: [
              // Close button
              OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF475569),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 14, vertical: 10),
                  minimumSize: const Size(0, 40),
                ),
                child: Text(
                  isCompact ? 'બંધ (Close)' : 'બંધ કરો (Close)',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11.5),
                ),
              ),
              const SizedBox(width: 8),
              // Call button if available
              if (hasPhone) ...[
                Expanded(
                  flex: isCompact ? 3 : 2,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse('tel:${data['phone'].toString().replaceAll(' ', '')}');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                    icon: const Icon(Icons.call, size: 14),
                    label: Text(
                      isCompact ? 'કોલ (Call)' : 'કોલ કરો (Call)',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                      minimumSize: const Size(0, 40),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              // View Profile button - ALWAYS VISIBLE FOR ALL CANDIDATES
              Expanded(
                flex: isCompact ? 4 : 3,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    final pId = profile.id;
                    if (pId.isNotEmpty) {
                      context.push('/candidate-profile-details?id=$pId', extra: profile);
                    } else {
                      context.push('/candidate-profile-details', extra: profile);
                    }
                  },
                  icon: const Icon(Icons.person_search, size: 15),
                  label: Text(
                    isCompact ? 'સંપૂર્ણ પ્રોફાઇલ' : 'સંપૂર્ણ પ્રોફાઇલ (Profile)',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0056D2),
                    foregroundColor: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                    minimumSize: const Size(0, 40),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: kIsWeb ? const WebHomeHeader(activeRoute: '/private-employees') : null,
      backgroundColor: Colors.white,
      body: SafeArea(
        top: !kIsWeb,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 850;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isDesktop ? 1280 : 1000),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: isDesktop ? 36 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Banner with True Proportional Aspect Ratio (1600 x 592)
                      Padding(
                        padding: EdgeInsets.only(
                          top: isDesktop ? 12 : 8,
                          left: isDesktop ? 8 : 4,
                          right: isDesktop ? 8 : 4,
                        ),
                        child: LayoutBuilder(
                          builder: (context, bannerConstraints) {
                            final bannerWidth = bannerConstraints.maxWidth;
                            final bannerHeight = bannerWidth * (592.0 / 1600.0);

                            return Container(
                              width: bannerWidth,
                              height: bannerHeight,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(isDesktop ? 14 : 10),
                                border: Border.all(
                                  color: const Color(0xFFD6A34A).withValues(alpha: 0.6),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF101B36).withValues(alpha: 0.08),
                                    blurRadius: 14,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.asset(
                                'assets/images/govt_section_banner_clean.png',
                                fit: BoxFit.fill,
                                errorBuilder: (context, error, stackTrace) => Image.asset(
                                  'assets/images/govt_section_banner_new.png',
                                  fit: BoxFit.fill,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Title Capsule Badge
                      _buildTitleBadge(isDesktop),
                      // Filters Section
                      _buildFiltersSection(isDesktop),
                      // Table Section
                      _buildTableSection(isDesktop),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitleBadge(bool isDesktop) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 24 : 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFD6A34A), width: 1.6),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD6A34A).withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isDesktop ? 36 : 32,
              height: isDesktop ? 36 : 32,
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFDF7A), Color(0xFFD6A34A), Color(0xFF8C6D15)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD6A34A).withValues(alpha: 0.35),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const CircleAvatar(
                backgroundColor: Color(0xFFA4143D),
                child: Icon(Icons.business_center, color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Private Job & Business Directory',
                  style: TextStyle(
                    color: const Color(0xFF101B36),
                    fontSize: isDesktop ? 18 : 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'ખાનગી નોકરી અને વેપાર ડિરેક્ટરી',
                  style: TextStyle(
                    color: const Color(0xFFA4143D),
                    fontSize: isDesktop ? 12 : 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 16 : 12),
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 8 : 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5D5BA), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101B36).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isDesktop)
            Row(
              children: [
                Expanded(child: _buildDropdown('Sector (ક્ષેત્ર / વેપાર)', _sector, _sectors, (v) => setState(() => _sector = v!))),
                const SizedBox(width: 10),
                Expanded(child: _buildDropdown('Role (હોદ્દો / પદ)', _post, _posts, (v) => setState(() => _post = v!))),
                const SizedBox(width: 10),
                Expanded(child: _buildDropdown('District (જિલ્લો)', _district, _districts, (v) {
                  setState(() {
                    _district = v!;
                    _taluka = 'All';
                  });
                })),
                const SizedBox(width: 10),
                Expanded(child: _buildDropdown('Taluka (તાલુકો)', _taluka, _talukas, (v) => setState(() => _taluka = v!))),
              ],
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildDropdown('Sector (ક્ષેત્ર)', _sector, _sectors, (v) => setState(() => _sector = v!))),
                    const SizedBox(width: 8),
                    Expanded(child: _buildDropdown('Role (હોદ્દો)', _post, _posts, (v) => setState(() => _post = v!))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildDropdown('District (જિલ્લો)', _district, _districts, (v) {
                      setState(() {
                        _district = v!;
                        _taluka = 'All';
                      });
                    })),
                    const SizedBox(width: 8),
                    Expanded(child: _buildDropdown('Taluka (તાલુકો)', _taluka, _talukas, (v) => setState(() => _taluka = v!))),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 12),
          if (isDesktop)
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: SizedBox(
                    height: 42,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, color: Color(0xFFA4143D), size: 20),
                        hintText: 'Search by Name (નામથી શોધો)...',
                        hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF9CA3AF)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFD6A34A)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE5D5BA)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFA4143D), width: 1.5),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFAF8F5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.search, size: 16),
                    label: const Text('Search (શોધો)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA4143D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: _resetFilters,
                    icon: const Icon(Icons.refresh, size: 15),
                    label: const Text('Reset (રીસેટ)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4B5563),
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                SizedBox(
                  height: 42,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Color(0xFFA4143D), size: 20),
                      hintText: 'Search by Name (નામથી શોધો)...',
                      hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF9CA3AF)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFD6A34A)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE5D5BA)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFA4143D), width: 1.5),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFAF8F5),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton.icon(
                          onPressed: () => setState(() {}),
                          icon: const Icon(Icons.search, size: 16),
                          label: const Text('Search (શોધો)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA4143D),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: OutlinedButton.icon(
                          onPressed: _resetFilters,
                          icon: const Icon(Icons.refresh, size: 15),
                          label: const Text('Reset (રીસેટ)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4B5563),
                            side: const BorderSide(color: Color(0xFFD1D5DB)),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF8F5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5D5BA), width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified, size: 14, color: Color(0xFFA4143D)),
                const SizedBox(width: 6),
                Text(
                  'Showing ${_filteredData.length} directory listings',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableSection(bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - (isDesktop ? 16 : 8);
        const double baseIndex = 95.0;
        const double basePhoto = 70.0;
        const double baseAction = 100.0;
        const double fixedTotal = baseIndex + basePhoto + baseAction; // 265.0

        // Minimum flexible widths
        const double minName = 220.0;
        const double minDept = 240.0;
        const double minPost = 210.0;
        const double minDistrict = 160.0;
        const double minFlexTotal = minName + minDept + minPost + minDistrict; // 830.0
        const double minTableWidth = fixedTotal + minFlexTotal; // 1080.0

        final double tableWidth = availableWidth > minTableWidth ? availableWidth : minTableWidth;
        final double extraWidth = tableWidth - minTableWidth;

        final double nameWidth = minName + (extraWidth * 0.28);
        final double deptWidth = minDept + (extraWidth * 0.32);
        final double postWidth = minPost + (extraWidth * 0.22);
        final double districtWidth = minDistrict + (extraWidth * 0.18);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Container(
            width: tableWidth,
            margin: EdgeInsets.symmetric(horizontal: isDesktop ? 8 : 4, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5D5BA), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF101B36).withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                  child: Container(
                    width: tableWidth,
                    color: const Color(0xFF101B36),
                    child: Row(
                      children: [
                        _buildHeaderCell('#', 'ક્રમ', baseIndex),
                        _buildHeaderCell('Photo', 'ફોટો', basePhoto),
                        _buildHeaderCell('Name', 'નામ', nameWidth),
                        _buildHeaderCell('Sector / Industry', 'ક્ષેત્ર / વેપાર', deptWidth),
                        _buildHeaderCell('Role / Post', 'હોદ્દો / પદ', postWidth),
                        _buildHeaderCell('District', 'જિલ્લો', districtWidth),
                        _buildHeaderCell('Action', 'વિગત', baseAction, isLast: true),
                      ],
                    ),
                  ),
                ),
                if (ref.watch(profileNotifierProvider).isLoading)
                  Container(
                    width: tableWidth,
                    padding: const EdgeInsets.all(40.0),
                    child: const Center(
                      child: CircularProgressIndicator(color: Color(0xFFA4143D)),
                    ),
                  )
                else if (_filteredData.isEmpty)
                  Container(
                    width: tableWidth,
                    padding: const EdgeInsets.all(40.0),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off, size: 48, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('No private employees or business listings found matching criteria.',
                              style: TextStyle(fontSize: 14, color: Colors.black54)),
                        ],
                      ),
                    ),
                  )
                else
                  ..._filteredData.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final data = entry.value;
                    final isEven = idx % 2 == 0;
                    return _buildTableRow(
                      data,
                      isEven,
                      baseIndex: baseIndex,
                      basePhoto: basePhoto,
                      nameWidth: nameWidth,
                      deptWidth: deptWidth,
                      postWidth: postWidth,
                      districtWidth: districtWidth,
                      baseAction: baseAction,
                    );
                  }),
                Container(
                  width: tableWidth,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF8F5),
                    borderRadius:
                        const BorderRadius.vertical(bottom: Radius.circular(11)),
                    border: Border(
                      top: BorderSide(
                        color: const Color(0xFFD6A34A).withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 15, color: Color(0xFFD6A34A)),
                      SizedBox(width: 7),
                      Text(
                        'All directory listings loaded (તમામ રેકોર્ડ લોડ થયેલ છે)',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableRow(
    Map<String, dynamic> data,
    bool isEven, {
    required double baseIndex,
    required double basePhoto,
    required double nameWidth,
    required double deptWidth,
    required double postWidth,
    required double districtWidth,
    required double baseAction,
  }) {
    final photoUrl = data['photoUrl']?.toString();
    final hasPhoto = photoUrl != null && photoUrl.trim().isNotEmpty;
    final idStr = (data['id'] ?? '').toString();

    final deptStr = data['dept']?.toString() ?? '';
    final hasGujaratiDept = _translations.containsKey(deptStr) &&
        _translations[deptStr]!.trim().toLowerCase() != deptStr.trim().toLowerCase();

    final postStr = data['post']?.toString() ?? '';
    final hasGujaratiPost = _translations.containsKey(postStr) &&
        _translations[postStr]!.trim().toLowerCase() != postStr.trim().toLowerCase();

    final districtStr = data['district']?.toString() ?? '';
    final hasGujaratiDistrict = _translations.containsKey(districtStr) &&
        _translations[districtStr]!.trim().toLowerCase() != districtStr.trim().toLowerCase();

    return Container(
      color: isEven ? Colors.white : const Color(0xFFFAF8F5),
      child: Row(
        children: [
          // 1. ID / Index Cell
          _buildDataCell(
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF8F5),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFFD6A34A).withValues(alpha: 0.4),
                    width: 0.9,
                  ),
                ),
                child: Text(
                  idStr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101B36),
                    fontSize: 11.5,
                  ),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            baseIndex,
          ),

          // 2. Photo Cell with Error Fallback
          _buildDataCell(
            Center(
              child: InkWell(
                onTap: () => _showEmployeeDetails(data),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD6A34A),
                      width: 1.2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: const Color(0xFFFAF8F5),
                    child: ClipOval(
                      child: hasPhoto
                          ? Image.network(
                              photoUrl,
                              width: 34,
                              height: 34,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.person,
                                color: Color(0xFFA4143D),
                                size: 20,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              color: Color(0xFFA4143D),
                              size: 20,
                            ),
                    ),
                  ),
                ),
              ),
            ),
            basePhoto,
          ),

          // 3. Name Cell
          _buildDataCell(
            InkWell(
              onTap: () => _showEmployeeDetails(data),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data['name']?.toString() ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF101B36),
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (data['company'] != null &&
                      data['company'].toString().trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      data['company'].toString(),
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF6B7280),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ],
              ),
            ),
            nameWidth,
          ),

          // 4. Sector / Industry Cell with Icon
          _buildDataCell(
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA4143D).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFD6A34A).withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Icon(
                    data['icon'] as IconData? ?? Icons.business_center,
                    color: const Color(0xFFA4143D),
                    size: 15,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        deptStr,
                        style: const TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (hasGujaratiDept) ...[
                        const SizedBox(height: 2),
                        Text(
                          _translations[deptStr]!,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF6B7280),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            deptWidth,
          ),

          // 5. Role / Post Cell
          _buildDataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  postStr,
                  style: const TextStyle(
                    color: Color(0xFFA4143D),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (hasGujaratiPost) ...[
                  const SizedBox(height: 2),
                  Text(
                    _translations[postStr]!,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ],
            ),
            postWidth,
          ),

          // 6. District & Taluka Cell
          _buildDataCell(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  districtStr.isNotEmpty ? districtStr : '—',
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (hasGujaratiDistrict) ...[
                  const SizedBox(height: 2),
                  Text(
                    _translations[districtStr]!,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ],
            ),
            districtWidth,
          ),

          // 7. Action Cell
          _buildDataCell(
            Center(
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFA4143D), Color(0xFF7E102F)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFFD6A34A),
                    width: 0.9,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA4143D).withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showEmployeeDetails(data),
                    borderRadius: BorderRadius.circular(15),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.visibility_outlined,
                              size: 13, color: Color(0xFFFFDF7A)),
                          SizedBox(width: 4),
                          Text(
                            'View',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            baseAction,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String en, String gu, double width, {bool isLast = false}) {
    return Container(
      width: width,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF101B36),
        border: isLast
            ? null
            : Border(
                right: BorderSide(
                  color: const Color(0xFFD6A34A).withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            en,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 11.5,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            '($gu)',
            style: const TextStyle(
              color: Color(0xFFFFDF7A),
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDataCell(Widget child, double width, {bool isLast = false}) {
    return Container(
      width: width,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(
          right: isLast
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFE5E7EB), width: 0.6),
          bottom: const BorderSide(color: Color(0xFFE5E7EB), width: 0.6),
        ),
      ),
      child: child,
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5D5BA)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Icon(Icons.business_center_outlined, color: const Color(0xFFA4143D), size: 15),
          const SizedBox(width: 6),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: Colors.white,
                menuMaxHeight: 350,
                borderRadius: BorderRadius.circular(12),
                elevation: 4,
                icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280), size: 16),
                style: const TextStyle(color: Color(0xFF101B36), fontSize: 12.5),
                selectedItemBuilder: (BuildContext context) {
                  return options.map<Widget>((String val) {
                    final displayVal = val == 'All' ? label : _getTranslatedText(val);
                    return Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        displayVal,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF101B36),
                        ),
                      ),
                    );
                  }).toList();
                },
                items: options.map((String val) {
                  final displayVal = val == 'All' ? label : _getTranslatedText(val);
                  final isSelected = val == value;
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            val == 'All' ? Icons.filter_list : Icons.business,
                            size: 15,
                            color: isSelected ? const Color(0xFFA4143D) : const Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              displayVal,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? const Color(0xFFA4143D) : const Color(0xFF1F2937),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, size: 16, color: Color(0xFFA4143D)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
