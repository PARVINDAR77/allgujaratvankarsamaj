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
  SamajServiceModel(
    id: 'srv-001',
    title: 'વણકર સમાજ છાત્રાલય અને એજ્યુકેશન હેલ્પ',
    category: 'Education',
    icon: '🎓',
    contactPhone: '+91 98790 12345',
    contactPerson: 'રમેશભાઈ વણકર',
    description: 'સમાજના વિદ્યાર્થીઓ માટે હોસ્ટેલ સહાય, સ્કોલરશીપ અને સ્પર્ધાત્મક પરીક્ષા માર્ગદર્શન પ્લેટફોર્મ.',
    isActive: true,
    personsCount: 12,
  ),
  SamajServiceModel(
    id: 'srv-002',
    title: 'સમાજ જનરલ મેડિકલ અને આરોગ્ય કેમ્પ',
    category: 'Medical',
    icon: '🏥',
    contactPhone: '+91 98250 67890',
    contactPerson: 'ડૉ. મહેશકુમાર પરમાર',
    description: 'મફત નિદાન કેમ્પ, બ્લડ ડોનેશન અને સમાજના દર્દીઓ માટે હોસ્પિટલ ડિસ્કાઉન્ટ સહાય.',
    isActive: true,
    personsCount: 8,
  ),
  SamajServiceModel(
    id: 'srv-003',
    title: 'વણકર સમાજ લીગલ અને એડવોકેટ કાઉન્સિલ',
    category: 'Legal',
    icon: '⚖️',
    contactPhone: '+91 97123 45678',
    contactPerson: 'એડવોકેટ હસમુખભાઈ ચૌહાણ',
    description: 'સમાજના લોકો માટે મફત કાનૂની સલાહ, જમીન-મિલકત માર્ગદર્શન અને સોગંદનામા સહાય.',
    isActive: true,
    personsCount: 5,
  ),
  SamajServiceModel(
    id: 'srv-004',
    title: 'સમાજ બિઝનેસ નેટવર્ક અને રોજગાર સહાય',
    category: 'Employment',
    icon: '💼',
    contactPhone: '+91 99099 88776',
    contactPerson: 'જીગ્નેશભાઈ સોલંકી',
    description: 'યુવાનો માટે જોબ પ્લેસમેન્ટ, લઘુ ઉદ્યોગ લોન માર્ગદર્શન અને બિઝનેસ ડિરેક્ટરી.',
    isActive: true,
    personsCount: 15,
  ),
  SamajServiceModel(
    id: 'srv-005',
    title: 'સમૂહ લગ્ન અને મેટ્રિમોનિયલ સંમેલન',
    category: 'Matrimonial',
    icon: '💒',
    contactPhone: '+91 94260 11223',
    contactPerson: 'પંકજભાઈ રાઠોડ',
    description: 'વર્ષિક સમૂહ લગ્ન આયોજન અને સમાજ પરિચય સંમેલન સેવાઓ.',
    isActive: true,
    personsCount: 20,
  ),
  SamajServiceModel(
    id: 'srv-006',
    title: 'સરકારી યોજના માર્ગદર્શન કેન્દ્ર',
    category: 'Government Schemes',
    icon: '🏛️',
    contactPhone: '+91 98980 11223',
    contactPerson: 'અશ્વિનભાઈ વાઘેલા',
    description: 'ડિજિટલ ગુજરાત, શિષ્યવૃત્તિ, વિદેશ અભ્યાસ લોન અને સરકારી યોજનાઓની માહિતી.',
    isActive: true,
    personsCount: 10,
  ),
  SamajServiceModel(
    id: 'srv-007',
    title: 'વણકર સમાજ રક્તદાતા નેટવર્ક (Blood Bank)',
    category: 'Blood Donation',
    icon: '🩸',
    contactPhone: '+91 98765 43210',
    contactPerson: 'કિરણભાઈ રોહિત',
    description: 'ઇમરજન્સીમાં 24x7 રક્તદાતાઓની ડિરેક્ટરી અને રક્તદાન કેમ્પ સેવાઓ.',
    isActive: true,
    personsCount: 35,
  ),
  SamajServiceModel(
    id: 'srv-008',
    title: 'મહિલા સશક્તિકરણ અને ગૃહ ઉદ્યોગ પંખ',
    category: 'Mahila Vikas',
    icon: '👩‍💼',
    contactPhone: '+91 97234 56789',
    contactPerson: 'ભાવનાબેન પરમાર',
    description: 'મહિલાઓ માટે સેલ્ફ હેલ્પ ગ્રુપ, બ્યુટી પાર્લર/સિલાઇ તાલીમ અને ગૃહ ઉદ્યોગ વેચાણ મંચ.',
    isActive: true,
    personsCount: 14,
  ),
  SamajServiceModel(
    id: 'srv-009',
    title: 'સમાજ હોલ અને વાડી બુકિંગ સેવા',
    category: 'Community Hall',
    icon: '🏰',
    contactPhone: '+91 94270 99887',
    contactPerson: 'દિનેશભાઈ ચૌહાણ',
    description: 'લગ્ન પ્રસંગો, બેસણું અને સામાજિક પ્રસંગો માટે સમાજ હોલ/વાડી રજીસ્ટ્રેશન.',
    isActive: true,
    personsCount: 6,
  ),
  SamajServiceModel(
    id: 'srv-010',
    title: 'યુવા પાંખ અને રમત-ગમત મહોત્સવ',
    category: 'Sports & Youth',
    icon: '🏆',
    contactPhone: '+91 99789 44556',
    contactPerson: 'વિશાલભાઈ સોલંકી',
    description: 'સમાજના યુવા રમતવીરો પ્રોત્સાહન, ક્રિકેટ ટૂર્નામેન્ટ અને સાંસ્કૃતિક સ્પર્ધાઓ.',
    isActive: true,
    personsCount: 18,
  ),
  SamajServiceModel(
    id: 'srv-011',
    title: 'વરિષ્ઠ નાગરિક અને પેન્શનર સલાહ',
    category: 'Senior Citizen',
    icon: '👴',
    contactPhone: '+91 98241 22334',
    contactPerson: 'કાંતિલાલ વણકર (નિવૃત્ત DySP)',
    description: 'વડીલો માટે પેન્શન પ્રશ્નો, વય વંદના યોજના અને વડીલ મિલન કેન્દ્ર.',
    isActive: true,
    personsCount: 9,
  ),
  SamajServiceModel(
    id: 'srv-012',
    title: 'ઇમરજન્સી હેલ્પલાઇન સેવા (24x7)',
    category: 'Emergency',
    icon: '🚨',
    contactPhone: '+91 98989 98989',
    contactPerson: 'સમાજ કંટ્રોલ રૂમ',
    description: 'અકસ્માત, હોસ્પિટલ ઇમરજન્સી અથવા આપાતકાલીન સ્થિતિમાં સમાજ સહાયતા.',
    isActive: true,
    personsCount: 25,
  ),
  SamajServiceModel(
    id: 'srv-013',
    title: 'વણકર સમાજ ઓલ ઇન્ડિયા ટ્રેડર ડિરેક્ટરી',
    category: 'Business Directory',
    icon: '🏬',
    contactPhone: '+91 98255 12345',
    contactPerson: 'ભાવેશભાઈ કાપડિયા',
    description: 'ટેક્સટાઇલ, બિલ્ડર, ડૉક્ટર, સીએ અને સમાજના તમામ વેપારીઓની બિઝનેસ ડિરેક્ટરી.',
    isActive: true,
    personsCount: 50,
  ),
  SamajServiceModel(
    id: 'srv-014',
    title: 'કરિયર કાઉન્સેલિંગ અને આઇટી ગાઇડન્સ',
    category: 'Career Guidance',
    icon: '💻',
    contactPhone: '+91 97111 22334',
    contactPerson: 'અલ્પેશ પરમાર (Software Lead)',
    description: 'આઇટી, આર્ટિફિશિયલ ઇન્ટેલિજન્સ અને કોડિંગ ક્ષેત્રે યુવાનો માટે મેન્ટોરશિપ.',
    isActive: true,
    personsCount: 11,
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
