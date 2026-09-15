import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/providers/api_config_provider.dart';

class SamajServiceModel {
  final String id;
  final String title;
  final String category;
  final String icon;
  final String contactPhone;
  final String contactPerson;
  final String description;
  final bool isActive;
  final int personsCount;

  const SamajServiceModel({
    required this.id,
    required this.title,
    required this.category,
    required this.icon,
    required this.contactPhone,
    required this.contactPerson,
    required this.description,
    required this.isActive,
    this.personsCount = 0,
  });

  factory SamajServiceModel.fromJson(Map<String, dynamic> json) {
    int count = 0;
    if (json['_count'] != null && json['_count']['persons'] != null) {
      count = (json['_count']['persons'] as num).toInt();
    }

    return SamajServiceModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      icon: json['icon'] as String? ?? '🤝',
      contactPhone: json['contactPhone'] as String? ?? '',
      contactPerson: json['contactPerson'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      personsCount: count,
    );
  }
}

class SamajServicePersonModel {
  final String id;
  final String serviceId;
  final String name;
  final String gujaratiName;
  final String photoUrl;
  final String phone;
  final String address;
  final String city;
  final String description;
  final String experience;
  final bool isActive;
  final String serviceTitle;
  final String serviceCategory;
  final String serviceIcon;

  const SamajServicePersonModel({
    required this.id,
    required this.serviceId,
    required this.name,
    required this.gujaratiName,
    required this.photoUrl,
    required this.phone,
    required this.address,
    required this.city,
    required this.description,
    required this.experience,
    required this.isActive,
    required this.serviceTitle,
    required this.serviceCategory,
    required this.serviceIcon,
  });

  factory SamajServicePersonModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? service = json['service'] as Map<String, dynamic>?;

    return SamajServicePersonModel(
      id: json['id'] as String? ?? '',
      serviceId: json['serviceId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      gujaratiName: json['gujaratiName'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      description: json['description'] as String? ?? '',
      experience: json['experience'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      serviceTitle: service?['title'] as String? ?? '',
      serviceCategory: service?['category'] as String? ?? '',
      serviceIcon: service?['icon'] as String? ?? '🤝',
    );
  }
}

const List<SamajServiceModel> _defaultSamajServices = [
  // 1. ઘર અને દૈનિક જીવનની સેવાઓ (Home & Daily Life)
  SamajServiceModel(
    id: 'srv-001',
    title: 'ઘર બાંધકામ અને સિવિલ વર્ક (Construction & Mason)',
    category: 'Home & Daily Life Services',
    icon: '🏠',
    contactPhone: '+91 98790 12345',
    contactPerson: 'રાજ મિસ્ત્રી રમેશભાઈ વણકર',
    description: 'ઘર બાંધકામ, રાજ મિસ્ત્રી (Mason Work), આરસીસી અને પ્લાસ્ટર કામકાજ સિંગલ ક્લિકથી.',
    isActive: true,
    personsCount: 15,
  ),
  SamajServiceModel(
    id: 'srv-002',
    title: 'પ્લમ્બિંગ અને ઇલેક્ટ્રિશિયન સર્વિસ (Plumber & Electrician)',
    category: 'Home & Daily Life Services',
    icon: '🔧',
    contactPhone: '+91 98250 67890',
    contactPerson: 'મહેશકુમાર પરમાર',
    description: 'ઇમરજન્સી વાયરિંગ, પ્લમ્બિંગ ફિટિંગ, ગીઝર અને મોટર સુધારણા સેવાઓ.',
    isActive: true,
    personsCount: 22,
  ),
  SamajServiceModel(
    id: 'srv-003',
    title: 'કલરકામ, પેઇન્ટિંગ અને એસી/ફ્રિજ રીપેર',
    category: 'Home & Daily Life Services',
    icon: '🎨',
    contactPhone: '+91 97123 45678',
    contactPerson: 'હસમુખભાઈ ચૌહાણ (Painter)',
    description: 'ઘર/ઓફિસ કલરકામ, વુડન પોલિશ, એસી સર્વિસિંગ, ફ્રિજ અને વોશિંગ મશીન રીપેર.',
    isActive: true,
    personsCount: 18,
  ),
  SamajServiceModel(
    id: 'srv-004',
    title: 'સુથારીકામ, એલ્યુમિનિયમ અને ગ્લાસ વર્ક (Carpenter)',
    category: 'Home & Daily Life Services',
    icon: '🪚',
    contactPhone: '+91 99099 88776',
    contactPerson: 'જીગ્નેશભાઈ સોલંકી',
    description: 'ફર્નિચર બનાવટ, દરવાજા ફિટિંગ, એલ્યુમિનિયમ સેક્શન અને ગ્લાસ વિન્ડો વુડવર્ક.',
    isActive: true,
    personsCount: 14,
  ),
  SamajServiceModel(
    id: 'srv-005',
    title: 'પેકર્સ & મુવર્સ અને પેસ્ટ કંટ્રોલ (Packers & Cleaning)',
    category: 'Home & Daily Life Services',
    icon: '🚚',
    contactPhone: '+91 94260 11223',
    contactPerson: 'પંકજભાઈ રાઠોડ',
    description: 'ઘર સામાન શિફ્ટિંગ, ડીપ ક્લીનિંગ અને ઉધઇ/જંતુનાશક પેસ્ટ કંટ્રોલ સેવાઓ.',
    isActive: true,
    personsCount: 10,
  ),

  // 2. Vehicle & Transport
  SamajServiceModel(
    id: 'srv-006',
    title: 'ગાડી બુકિંગ અને ટેક્સી સર્વિસ (Car Rental & Cab)',
    category: 'Vehicle & Transport',
    icon: '🚗',
    contactPhone: '+91 98980 11223',
    contactPerson: 'અશ્વિનભાઈ વાઘેલા (Taxi)',
    description: 'લગ્ન પ્રસંગ, પ્રવાસ કે ઇમરજન્સી માટે કાર રેન્ટલ, ટેક્સી અને ડ્રાઇવર બુકિંગ.',
    isActive: true,
    personsCount: 28,
  ),
  SamajServiceModel(
    id: 'srv-007',
    title: 'ઓટો/ગેરેજ, પંચર અને બેટરી સર્વિસ (Garage & Puncture)',
    category: 'Vehicle & Transport',
    icon: '🛞',
    contactPhone: '+91 98765 43210',
    contactPerson: 'કિરણભાઈ રોહિત (Garage)',
    description: 'ટુ-વીલર/ફોર-વીલર ગેરેજ, ટાયર પંચર, ઓન-રોડ આસિસ્ટન્સ અને કાર બેટરી.',
    isActive: true,
    personsCount: 19,
  ),
  SamajServiceModel(
    id: 'srv-008',
    title: 'માલસામાન ટ્રાન્સપોર્ટ અને બસ/ટેમ્પો (Goods Transport)',
    category: 'Vehicle & Transport',
    icon: '🚛',
    contactPhone: '+91 97234 56789',
    contactPerson: 'ભાવનાબેન પરમાર (Transport)',
    description: 'ટેમ્પો બુકિંગ, આઇશર ટ્રાન્સપોર્ટ અને યાત્રા માટે લક્ઝરી બસ બુકિંગ.',
    isActive: true,
    personsCount: 12,
  ),

  // 3. Computer & Digital Services
  SamajServiceModel(
    id: 'srv-009',
    title: 'કોમ્પ્યુટર/મોબાઇલ રીપેર અને પ્રિન્ટર સર્વિસ',
    category: 'Computer & Digital Services',
    icon: '💻',
    contactPhone: '+91 94270 99887',
    contactPerson: 'દિનેશભાઈ ચૌહાણ (Hardware)',
    description: 'લેપટોપ, કોમ્પ્યુટર સુધારણા, સ્માર્ટફોન ડિસ્પ્લે અને પ્રિન્ટર કાર્ટ્રેજ રીફિલિંગ.',
    isActive: true,
    personsCount: 25,
  ),
  SamajServiceModel(
    id: 'srv-010',
    title: 'વેબસાઇટ, મોબાઇલ એપ અને ગ્રાફિક ડિઝાઇનિંગ',
    category: 'Computer & Digital Services',
    icon: '🌐',
    contactPhone: '+91 99789 44556',
    contactPerson: 'અલ્પેશ પરમાર (IT Dev)',
    description: 'સમાજ ઉદ્યોગો માટે વેબસાઇટ ડેવલપમેન્ટ, બિઝનેસ એપ અને સોશિયલ મીડિયા ડિઝાઇન.',
    isActive: true,
    personsCount: 16,
  ),
  SamajServiceModel(
    id: 'srv-011',
    title: 'ઓનલાઇન ફોર્મ, ઝેરોક્ષ અને ફોટો સ્ટુડિયો',
    category: 'Computer & Digital Services',
    icon: '📸',
    contactPhone: '+91 98241 22334',
    contactPerson: 'કાંતિલાલ વણકર',
    description: 'સરકારી ભરતી ફોર્મ, પાન કાર્ડ/આધાર અપડેટ, પ્રિન્ટિંગ પ્રેસ અને ફોટોગ્રાફી.',
    isActive: true,
    personsCount: 30,
  ),

  // 4. Education Services
  SamajServiceModel(
    id: 'srv-012',
    title: 'ટ્યુશન ક્લાસીસ અને સ્પર્ધાત્મક પરીક્ષા કોચિંગ',
    category: 'Education Services',
    icon: '📚',
    contactPhone: '+91 98989 98989',
    contactPerson: 'પ્રો. સંજયભાઈ વણકર',
    description: 'ધો. ૧ થી ૧૨ ટ્યુશન, GPSC/TET/TAT/SSC પરીક્ષા માર્ગદર્શન અને પુસ્તક સહાય.',
    isActive: true,
    personsCount: 24,
  ),
  SamajServiceModel(
    id: 'srv-013',
    title: 'એડમિશન ગાઇડન્સ અને વિદેશ અભ્યાસ (Foreign Study)',
    category: 'Education Services',
    icon: '🎓',
    contactPhone: '+91 98255 12345',
    contactPerson: 'ભાવેશભાઈ કાપડિયા',
    description: 'એન્જિનિયરિંગ/મેડિકલ એડમિશન, વિદેશ સ્ટુડન્ટ વીઝા અને સ્કોલરશીપ માહિતી.',
    isActive: true,
    personsCount: 11,
  ),

  // 5. Job & Business Services
  SamajServiceModel(
    id: 'srv-014',
    title: 'સમાજ જોબ પ્લેસમેન્ટ અને રિઝ્યુમ બિલ્ડર',
    category: 'Job & Business Services',
    icon: '💼',
    contactPhone: '+91 97111 22334',
    contactPerson: 'મનીષભાઈ ચૌહાણ (HR)',
    description: 'પ્રાઇવેટ અને સ્કિલ્ડ જોબ માહિતી, સીવી બનાવવા અને ઇન્ટરવ્યુ તૈયારી.',
    isActive: true,
    personsCount: 38,
  ),
  SamajServiceModel(
    id: 'srv-015',
    title: 'બિઝનેસ કન્સલ્ટન્ટ, GST અને ટેક્સ કન્સલ્ટન્ટ',
    category: 'Job & Business Services',
    icon: '🧾',
    contactPhone: '+91 98799 33445',
    contactPerson: 'સીએ પ્રતિક સોલંકી',
    description: 'નવો બિઝનેસ રજીસ્ટ્રેશન, GST ફાઇલિંગ, ઇનકમ ટેક્સ રિટર્ન અને એકાઉન્ટિંગ.',
    isActive: true,
    personsCount: 14,
  ),

  // 6. Legal & Financial Services
  SamajServiceModel(
    id: 'srv-016',
    title: 'વકીલ સલાહ, દસ્તાવેજ અને પ્રોપર્ટી ગાઇડન્સ (Advocate)',
    category: 'Legal & Financial Services',
    icon: '⚖️',
    contactPhone: '+91 98251 44556',
    contactPerson: 'એડવોકેટ હસમુખ ચૌહાણ',
    description: 'કાનૂની સલાહ, જમીન-મિલકત દસ્તાવેજ લેખન, સોગંદનામા અને રેવન્યુ કેસ.',
    isActive: true,
    personsCount: 17,
  ),
  SamajServiceModel(
    id: 'srv-017',
    title: 'બેંક લોન અને ઇન્સ્યોરન્સ કન્સલ્ટન્ટ (Bank Loan & Insurance)',
    category: 'Legal & Financial Services',
    icon: '🏦',
    contactPhone: '+91 99090 55667',
    contactPerson: 'કિરીટભાઈ પરમાર (Banker)',
    description: 'હોમ લોન, બિઝનેસ લોન, પર્સનલ લોન, લાઇફ/મેડીક્લેમ ઇન્સ્યોરન્સ સહાય.',
    isActive: true,
    personsCount: 21,
  ),

  // 7. Health & Emergency
  SamajServiceModel(
    id: 'srv-018',
    title: 'હોસ્પિટલ, ડૉક્ટર અને ડેન્ટલ કેર (Health & Doctor)',
    category: 'Health & Emergency',
    icon: '🏥',
    contactPhone: '+91 98791 66778',
    contactPerson: 'ડૉ. મહેશ પરમાર (MD)',
    description: 'સમાજ ડૉક્ટર્સ પેનલ, આંખના ડૉક્ટર, દાંતના ડૉક્ટર અને મફત આરોગ્ય કેમ્પ.',
    isActive: true,
    personsCount: 32,
  ),
  SamajServiceModel(
    id: 'srv-019',
    title: 'એમ્બ્યુલન્સ અને બ્લડ ડોનેશન ડિરેક્ટરી (Ambulance & Blood)',
    category: 'Health & Emergency',
    icon: '🩸',
    contactPhone: '+91 98252 77889',
    contactPerson: 'રક્તદાતા ગ્રુપ કંટ્રોલ',
    description: '૨૪x૭ ઇમરજન્સી એમ્બ્યુલન્સ, બ્લડ ડોનર નેટવર્ક અને લેબોરેટરી રિપોર્ટ સહાય.',
    isActive: true,
    personsCount: 45,
  ),

  // 8. Business & Local Shops
  SamajServiceModel(
    id: 'srv-020',
    title: 'કરિયાણું, કપડાં, ફર્નિચર અને જ્વેલર્સ શોપ',
    category: 'Business & Local Shops',
    icon: '🏪',
    contactPhone: '+91 99781 88990',
    contactPerson: 'વણકર ટ્રેડર્સ ગ્રુપ',
    description: 'સમાજના વેપારીઓનું હોલસેલ ગ્રોસરી, રેડીમેડ ગારમેન્ટ્સ, શૂઝ અને જ્વેલરી શોપિંગ.',
    isActive: true,
    personsCount: 60,
  ),

  // 9. Skilled Professionals
  SamajServiceModel(
    id: 'srv-021',
    title: 'વેલ્ડિંગ, મશીનરી અને ટેકનિશિયન વર્ક (Technicians)',
    category: 'Skilled Professionals',
    icon: '🧑🔧',
    contactPhone: '+91 98792 99001',
    contactPerson: 'પ્રકાશભાઈ વાઘેલા',
    description: 'ગ્રીલ/ગેટ વેલ્ડિંગ વર્ક, ટીવી ટેકનિશિયન, સીસીટીવી કેમેરા ફિટિંગ અને મશીનરી વર્ક.',
    isActive: true,
    personsCount: 29,
  ),
];

final samajServicesProvider = FutureProvider<List<SamajServiceModel>>((ref) async {
  final dio = ref.watch(dioClientProvider).dio;
  try {
    final response = await dio.get('/samaj-services');
    if (response.statusCode == 200 && response.data is List) {
      final list = (response.data as List)
          .map((item) => SamajServiceModel.fromJson(item as Map<String, dynamic>))
          .where((item) => item.isActive)
          .toList();
      if (list.isNotEmpty) return list;
    }
  } catch (e) {
    print('Failed to fetch public samaj services from backend: $e');
  }
  return _defaultSamajServices;
});

final samajServicePersonsProvider = FutureProvider.family<List<SamajServicePersonModel>, String>((ref, serviceId) async {
  final dio = ref.watch(dioClientProvider).dio;
  try {
    final response = await dio.get('/samaj-services/$serviceId/persons');
    if (response.statusCode == 200 && response.data is List) {
      final list = (response.data as List)
          .map((item) => SamajServicePersonModel.fromJson(item as Map<String, dynamic>))
          .where((item) => item.isActive)
          .toList();
      if (list.isNotEmpty) return list;
    }
  } catch (e) {
    print('Failed to fetch service persons for service $serviceId: $e');
  }
  return const [];
});
