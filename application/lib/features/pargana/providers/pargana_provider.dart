import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/api_config.dart';

class ParganaModel {
  final String id;
  final String name;
  final String? gujaratiName;
  final String? code;
  final String? description;
  final String? villageCount;
  final String? districtRegion;
  final String? leaderName;
  final String? contactPhone;
  final int totalCount;
  final bool isActive;

  ParganaModel({
    required this.id,
    required this.name,
    this.gujaratiName,
    this.code,
    this.description,
    this.villageCount,
    this.districtRegion,
    this.leaderName,
    this.contactPhone,
    required this.totalCount,
    required this.isActive,
  });

  factory ParganaModel.fromJson(Map<String, dynamic> json) {
    return ParganaModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      gujaratiName: json['gujaratiName'],
      code: json['code'],
      description: json['description'],
      villageCount: json['computedVillageCount'] ?? json['villageCount'],
      districtRegion: json['districtRegion'],
      leaderName: json['leaderName'],
      contactPhone: json['contactPhone'],
      totalCount: json['totalCount'] is int ? json['totalCount'] : int.tryParse(json['totalCount']?.toString() ?? '0') ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }
}

final parganasProvider = FutureProvider<List<ParganaModel>>((ref) async {
  const apiConfig = ApiConfig();
  final dio = Dio();

  try {
    final response = await dio.get('${apiConfig.baseUrl}/parganas', options: Options(responseType: ResponseType.json)).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200 && response.data is List) {
      final List<dynamic> data = response.data;
      return data.map((json) => ParganaModel.fromJson(json)).toList();
    }
  } catch (e) {
    // Fallback list matching seed data if backend network is unreachable
  }

  return [
    ParganaModel(
      id: 'pg-1',
      name: '35 Gam Pargana (Idar)',
      gujaratiName: '૩૫ ગામ પરગણું (ઈડર)',
      villageCount: '35 Gam',
      districtRegion: 'Idar, Sabarkantha, Aravalli',
      description: 'ઈડર, સાબરકાંઠા અને અરાવલ્લી પંથકના વણકર સમાજ ગામો',
      leaderName: 'Rameshbhai Vankar (Idar)',
      contactPhone: '+91 98765 43210',
      totalCount: 485,
      isActive: true,
    ),
    ParganaModel(
      id: 'pg-2',
      name: '27 Gam Pargana (Mehsana & Patan)',
      gujaratiName: '૨૭ ગામ પરગણું (મહેસાણા-પાટણ)',
      villageCount: '27 Gam',
      districtRegion: 'Mehsana, Patan, Banaskantha',
      description: 'ઉત્તર ગુજરાત મહેસાણા, પાટણ અને સિદ્ધપુર પંથક',
      leaderName: 'Kishorbhai Parmar',
      contactPhone: '+91 98765 43211',
      totalCount: 320,
      isActive: true,
    ),
    ParganaModel(
      id: 'pg-3',
      name: '16 Gam Pargana (Charotar)',
      gujaratiName: '૧૬ ગામ પરગણું (ચરોતર)',
      villageCount: '16 Gam',
      districtRegion: 'Anand, Kheda, Nadiad',
      description: 'આણંદ, ખેડા અને નડિયાદ ચરોતર પંથક',
      leaderName: 'Pravinbhai Solanki',
      contactPhone: '+91 98765 43212',
      totalCount: 210,
      isActive: true,
    ),
    ParganaModel(
      id: 'pg-4',
      name: '14 Gam Pargana (South Gujarat)',
      gujaratiName: '૧૪ ગામ પરગણું (દક્ષિણ ગુજરાત)',
      villageCount: '14 Gam',
      districtRegion: 'Surat, Navsari, Valsad, Bharuch',
      description: 'સુરત, નવસારી, વલસાડ અને ભરૂચ પંથક',
      leaderName: 'Dineshbhai Vankar',
      contactPhone: '+91 98765 43213',
      totalCount: 140,
      isActive: true,
    ),
    ParganaModel(
      id: 'pg-5',
      name: 'Chorasi Pargana (84 Gam)',
      gujaratiName: 'ચોરાસી (૮૪ ગામ) પરગણું',
      villageCount: '84 Gam',
      districtRegion: 'Ahmedabad, Gandhinagar',
      description: 'અમદાવાદ, દસક્રોઈ અને ગાંધીનગર વિસ્તાર',
      leaderName: 'Harshadbhai Vankar',
      contactPhone: '+91 98765 43214',
      totalCount: 290,
      isActive: true,
    ),
  ];
});
