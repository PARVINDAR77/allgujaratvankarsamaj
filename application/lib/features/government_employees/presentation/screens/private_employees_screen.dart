import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../profile/providers/profile_provider.dart';
import '../../../../shared/constants/app_data.dart';

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
      'id': '1001',
      'name': 'Rahul K. Solanki',
      'dept': 'IT / Software Development',
      'post': 'Software Engineer',
      'district': 'Ahmedabad',
      'taluka': 'Ahmedabad City',
      'icon': Icons.computer,
      'iconColor': const Color(0xFF0056D2),
    },
    {
      'id': '1002',
      'name': 'Amit P. Parmar',
      'dept': 'Banking / Financial Services (BFSI)',
      'post': 'Chartered Accountant',
      'district': 'Surat',
      'taluka': 'Choryasi',
      'icon': Icons.account_balance_wallet,
      'iconColor': const Color(0xFF4CAF50),
    },
    {
      'id': '1003',
      'name': 'Dr. Priya V. Vankar',
      'dept': 'Healthcare / Medical / Hospital',
      'post': 'Doctor',
      'district': 'Vadodara',
      'taluka': 'Vadodara City',
      'icon': Icons.local_hospital,
      'iconColor': const Color(0xFFE91E63),
    },
    {
      'id': '1004',
      'name': 'Jayesh M. Chavda',
      'dept': 'Business / Self-Employed',
      'post': 'Business Owner',
      'district': 'Rajkot',
      'taluka': 'Rajkot City',
      'icon': Icons.store,
      'iconColor': const Color(0xFFFF9800),
    },
    {
      'id': '1005',
      'name': 'Ketan R. Rathod',
      'dept': 'Engineering / Manufacturing',
      'post': 'Civil Engineer',
      'district': 'Gandhinagar',
      'taluka': 'Gandhinagar',
      'icon': Icons.engineering,
      'iconColor': const Color(0xFF9C27B0),
    },
    {
      'id': '1006',
      'name': 'Bhavik B. Makwana',
      'dept': 'Textile / Garments',
      'post': 'Proprietor',
      'district': 'Surat',
      'taluka': 'Kamrej',
      'icon': Icons.shopping_bag,
      'iconColor': const Color(0xFF009688),
    },
    {
      'id': '1007',
      'name': 'Nilesh D. Vaghela',
      'dept': 'Diamond / Jewelry',
      'post': 'Director',
      'district': 'Bhavnagar',
      'taluka': 'Bhavnagar City',
      'icon': Icons.diamond,
      'iconColor': const Color(0xFF3F51B5),
    },
    {
      'id': '1008',
      'name': 'Hardik S. Jadav',
      'dept': 'Sales / Marketing / Business Development',
      'post': 'Marketing Manager',
      'district': 'Mehsana',
      'taluka': 'Mehsana City',
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
             (p.businessIndustry != null && p.businessIndustry!.isNotEmpty) ||
             (p.businessService != null && p.businessService!.isNotEmpty);
    }).toList();

    if (privateProfiles.isNotEmpty) {
      return privateProfiles.map((p) {
        String sector = 'Private Industry & Services';
        if (p.businessIndustry != null && p.businessIndustry!.isNotEmpty && p.businessIndustry != 'Select Industry') {
          sector = p.businessIndustry!;
        } else if (p.department.isNotEmpty && p.department != 'General') {
          sector = p.department;
        } else if (p.employmentType.isNotEmpty) {
          sector = p.employmentType;
        }

        String role = 'Professional / Employee';
        if (p.designation.isNotEmpty && p.designation != 'Employee') {
          role = p.designation;
        } else if (p.businessService != null && p.businessService!.isNotEmpty && p.businessService != 'Select Service') {
          role = p.businessService!;
        }

        return {
          'id': p.id.length > 5 ? p.id.substring(p.id.length - 4) : p.id,
          'name': p.fullName,
          'dept': sector,
          'post': role,
          'district': p.district.isNotEmpty ? p.district : 'Ahmedabad',
          'taluka': p.taluka.isNotEmpty ? p.taluka : 'Ahmedabad City',
          'photoUrl': p.photoUrl,
          'profile': p,
          'icon': Icons.business_center,
          'iconColor': const Color(0xFF0056D2),
        };
      }).toList();
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
    final list = _allData.map((e) => e['district'] as String).toSet().toList();
    for (final d in _districtTalukas.keys) {
      if (!list.contains(d)) list.add(d);
    }
    list.sort();
    return ['All', ...list];
  }

  List<String> get _talukas {
    if (_district == 'All') {
      return ['All'];
    }
    final list = _districtTalukas[_district] ?? [];
    return ['All', ...list];
  }

  List<Map<String, dynamic>> get _filteredData {
    return _allData.where((item) {
      if (_sector != 'All' && item['dept'] != _sector) return false;
      if (_post != 'All' && item['post'] != _post) return false;
      if (_district != 'All' && item['district'] != _district) return false;
      if (_taluka != 'All' && item['taluka'] != _taluka) return false;
      if (_searchController.text.isNotEmpty && 
          !item['name'].toString().toLowerCase().contains(_searchController.text.toLowerCase())) {
        return false;
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF0056D2),
              radius: 18,
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                data['name'].toString(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF041126)),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Sector (ક્ષેત્ર)', _getTranslatedText(data['dept'].toString())),
            const Divider(height: 16),
            _buildDetailRow('Role (હોદ્દો)', _getTranslatedText(data['post'].toString())),
            const Divider(height: 16),
            _buildDetailRow('District (જિલ્લો)', _getTranslatedText(data['district'].toString())),
            const Divider(height: 16),
            _buildDetailRow('Taluka (તાલુકો)', _getTranslatedText(data['taluka'].toString())),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('બંધ કરો (Close)', style: TextStyle(color: Color(0xFF0056D2), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF041126))),
        ],
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
      backgroundColor: const Color(0xFFF0F8FF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 850;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    // Header Stack
                    SizedBox(
                      height: isDesktop ? 240 : 200,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: isDesktop ? 200 : 160,
                            child: Image.asset(
                              'assets/images/vankar_header_banner.png',
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              errorBuilder: (context, error, stackTrace) => Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF041126), Color(0xFF0A2540)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'VANKAR SAMAJ',
                                    style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF041126),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    if (context.canPop()) {
                                      context.pop();
                                    } else {
                                      context.go('/home');
                                    }
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    child: Row(
                                      children: [
                                        Icon(Icons.arrow_back, color: Color(0xFFD4AF37), size: 16),
                                        SizedBox(width: 4),
                                        Text('પાછા જાઓ (Back)', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: const Color(0xFFF3C34D), width: 2.5),
                                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFF0056D2),
                                    radius: isDesktop ? 24 : 20,
                                    child: Icon(Icons.business_center, color: Colors.white, size: isDesktop ? 28 : 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Private Job & Business Directory',
                                        style: TextStyle(color: const Color(0xFF0056D2), fontSize: isDesktop ? 22 : 18, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'ખાનગી નોકરી અને વેપાર ડિરેક્ટરી',
                                        style: TextStyle(color: const Color(0xFF0056D2), fontSize: isDesktop ? 14 : 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Filters Section
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F9FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Column(
                        children: [
                          if (isDesktop)
                            Row(
                              children: [
                                Expanded(child: _buildDropdown('Sector (ક્ષેત્ર / વેપાર)', _sector, _sectors, (v) => setState(() => _sector = v!))),
                                const SizedBox(width: 8),
                                Expanded(child: _buildDropdown('Role (હોદ્દો / પદ)', _post, _posts, (v) => setState(() => _post = v!))),
                                const SizedBox(width: 8),
                                Expanded(child: _buildDropdown('District (જિલ્લો)', _district, _districts, (v) {
                                  setState(() {
                                    _district = v!;
                                    _taluka = 'All';
                                  });
                                })),
                                const SizedBox(width: 8),
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
                          Row(
                            children: [
                              Expanded(
                                flex: isDesktop ? 6 : 3,
                                child: SizedBox(
                                  height: 40,
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.search, color: Color(0xFF0056D2), size: 20),
                                      hintText: 'Search by Name (નામથી શોધો)...',
                                      hintStyle: const TextStyle(fontSize: 12),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Colors.grey),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {});
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF00A2FF),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 0),
                                          minimumSize: const Size(0, 40),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        child: const Text('Search\n(શોધો)', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, height: 1.1)),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _resetFilters,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFE91E63),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 0),
                                          minimumSize: const Size(0, 40),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.refresh, size: 14),
                                            SizedBox(width: 2),
                                            Text('Reset\n(રીસેટ)', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, height: 1.1)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Table Section
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        physics: const BouncingScrollPhysics(),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Table Header
                                Row(
                                  children: [
                                    _buildHeaderCell('#', const Color(0xFF00A2FF), 40),
                                    _buildHeaderCell('Photo\n(ફોટો)', const Color(0xFF0056D2), 70),
                                    _buildHeaderCell('Name\n(નામ)', const Color(0xFFE91E63), 160),
                                    _buildHeaderCell('Sector / Industry\n(ક્ષેત્ર / વેપાર)', const Color(0xFF4CAF50), 160),
                                    _buildHeaderCell('Role / Post\n(હોદ્દો / પદ)', const Color(0xFFFF9800), 140),
                                    _buildHeaderCell('District\n(જિલ્લો)', const Color(0xFF9C27B0), 120),
                                    _buildHeaderCell('Action\n(વિગત)', const Color(0xFF0056D2), 80),
                                  ],
                                ),
                                // Table Body
                                if (ref.watch(profileNotifierProvider).isLoading)
                                  const Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: Center(child: CircularProgressIndicator(color: Color(0xFF0056D2))),
                                  )
                                else if (_filteredData.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: Center(child: Text('No private employees found matching criteria.', style: TextStyle(fontSize: 14, color: Colors.black54))),
                                  )
                                else
                                  ..._filteredData.map((data) {
                                    final isEven = _filteredData.indexOf(data) % 2 == 0;
                                    return Container(
                                      color: isEven ? Colors.blue.shade50.withValues(alpha: 0.3) : Colors.white,
                                      child: Row(
                                        children: [
                                          _buildDataCell(
                                            Text(data['id']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0056D2))),
                                            40,
                                          ),
                                          _buildDataCell(
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundColor: Colors.blue.shade50,
                                              backgroundImage: (data['photoUrl'] != null && data['photoUrl'].toString().isNotEmpty)
                                                  ? NetworkImage(data['photoUrl'].toString())
                                                  : null,
                                              child: (data['photoUrl'] == null || data['photoUrl'].toString().isEmpty)
                                                  ? const Icon(Icons.person, color: Color(0xFF0056D2), size: 20)
                                                  : null,
                                            ),
                                            70,
                                          ),
                                          _buildDataCell(
                                            Text(data['name']!, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0056D2), fontSize: 13)),
                                            160,
                                          ),
                                          _buildDataCell(
                                            Row(
                                              children: [
                                                Icon(data['icon'] as IconData? ?? Icons.business_center, color: data['iconColor'] as Color? ?? Colors.grey.shade800, size: 16),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    _getTranslatedText(data['dept']!),
                                                    style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            160,
                                          ),
                                          _buildDataCell(
                                            Text(_getTranslatedText(data['post']!), style: const TextStyle(color: Color(0xFF0056D2), fontSize: 12)),
                                            140,
                                          ),
                                          _buildDataCell(
                                            Text(_getTranslatedText(data['district']!), style: const TextStyle(color: Colors.black87, fontSize: 12)),
                                            120,
                                          ),
                                          _buildDataCell(
                                            ElevatedButton.icon(
                                              onPressed: () => _showEmployeeDetails(data),
                                              icon: const Icon(Icons.remove_red_eye, size: 12),
                                              label: const Text('View', style: TextStyle(fontSize: 11)),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF4CAF50),
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                                minimumSize: const Size(60, 26),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                              ),
                                            ),
                                            80,
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, Color color, double width) {
    return Container(
      width: width,
      height: 48,
      color: color,
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11, height: 1.2),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDataCell(Widget child, double width) {
    return Container(
      width: width,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.blue.shade100, width: 0.5),
          bottom: BorderSide(color: Colors.blue.shade100, width: 0.5),
        ),
      ),
      child: child,
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(Icons.business_center, color: Colors.grey.shade500, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: Colors.white,
                menuMaxHeight: 350,
                borderRadius: BorderRadius.circular(16),
                elevation: 4,
                icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade500, size: 16),
                style: const TextStyle(color: Colors.black87, fontSize: 12),
                selectedItemBuilder: (BuildContext context) {
                  return options.map<Widget>((String val) {
                    final displayVal = val == 'All' ? label : _getTranslatedText(val);
                    return Container(
                      alignment: Alignment.centerLeft,
                      child: Text(displayVal, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0056D2))),
                    );
                  }).toList();
                },
                items: options.map((String val) {
                  final displayVal = val == 'All' ? label : _getTranslatedText(val);
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                      ),
                      child: Row(
                        children: [
                          Icon(val == 'All' ? Icons.filter_list : Icons.business, size: 16, color: val == value ? const Color(0xFFE91E63) : Colors.blue.shade300),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              displayVal,
                              style: TextStyle(
                                fontWeight: val == value ? FontWeight.bold : FontWeight.w500,
                                color: val == value ? const Color(0xFFE91E63) : Colors.black87,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (val == value)
                            const Icon(Icons.check_circle, size: 16, color: Color(0xFFE91E63)),
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
