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

final samajServicesProvider = FutureProvider<List<SamajServiceModel>>((ref) async {
  final dio = ref.watch(dioClientProvider).dio;
  try {
    final response = await dio.get('/samaj-services');
    if (response.statusCode == 200 && response.data is List) {
      return (response.data as List)
          .map((item) => SamajServiceModel.fromJson(item as Map<String, dynamic>))
          .where((item) => item.isActive)
          .toList();
    }
  } catch (e) {
    print('Failed to fetch public samaj services from backend: $e');
  }
  return const [];
});

final samajServicePersonsProvider = FutureProvider.family<List<SamajServicePersonModel>, String>((ref, serviceId) async {
  final dio = ref.watch(dioClientProvider).dio;
  try {
    final response = await dio.get('/samaj-services/$serviceId/persons');
    if (response.statusCode == 200 && response.data is List) {
      return (response.data as List)
          .map((item) => SamajServicePersonModel.fromJson(item as Map<String, dynamic>))
          .where((item) => item.isActive)
          .toList();
    }
  } catch (e) {
    print('Failed to fetch service persons for service $serviceId: $e');
  }
  return const [];
});
