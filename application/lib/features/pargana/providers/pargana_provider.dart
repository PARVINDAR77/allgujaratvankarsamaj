import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/profile_model.dart';
import '../../../../shared/repositories/directory_repository.dart';
import '../../profile/providers/profile_provider.dart';

class ParganaModel {
  final String id;
  final String name;
  final String gujaratiName;
  final String? code;
  final String districtRegion;
  final String? villageCount;
  final String? areaDescription;
  final String? leaderName;
  final String? contactPhone;
  final int totalCount;
  final List<ProfileModel> profiles;

  const ParganaModel({
    required this.id,
    required this.name,
    required this.gujaratiName,
    this.code,
    required this.districtRegion,
    this.villageCount,
    this.areaDescription,
    this.leaderName,
    this.contactPhone,
    this.totalCount = 0,
    this.profiles = const [],
  });

  String get displayName => gujaratiName.trim().isNotEmpty ? gujaratiName : name;

  int get memberCount => profiles.isNotEmpty ? profiles.length : totalCount;

  ParganaModel copyWith({
    String? id,
    String? name,
    String? gujaratiName,
    String? code,
    String? districtRegion,
    String? villageCount,
    String? areaDescription,
    String? leaderName,
    String? contactPhone,
    int? totalCount,
    List<ProfileModel>? profiles,
  }) {
    return ParganaModel(
      id: id ?? this.id,
      name: name ?? this.name,
      gujaratiName: gujaratiName ?? this.gujaratiName,
      code: code ?? this.code,
      districtRegion: districtRegion ?? this.districtRegion,
      villageCount: villageCount ?? this.villageCount,
      areaDescription: areaDescription ?? this.areaDescription,
      leaderName: leaderName ?? this.leaderName,
      contactPhone: contactPhone ?? this.contactPhone,
      totalCount: totalCount ?? this.totalCount,
      profiles: profiles ?? this.profiles,
    );
  }
}

/// Provider that fetches and aggregates all Parganas from:
/// 1. Backend REST API (/parganas)
/// 2. DirectoryRepository (135+ comprehensive Gujarat Parganas)
/// 3. Dynamically linked Member Profiles
final allParganasProvider = FutureProvider<List<ParganaModel>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  final profileState = ref.watch(profileNotifierProvider);
  final profiles = profileState.profiles;

  List<ParganaModel> apiParganas = [];

  // 1. Fetch from live API
  try {
    final response = await dio.get('/parganas');
    dynamic raw = response.data;
    if (raw is String) {
      try {
        raw = jsonDecode(raw);
      } catch (_) {}
    }
    if (raw is Map<String, dynamic> && raw.containsKey('data')) {
      raw = raw['data'];
    }
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          final m = Map<String, dynamic>.from(item);
          apiParganas.add(ParganaModel(
            id: m['id']?.toString() ?? '',
            name: m['name']?.toString() ?? '',
            gujaratiName: m['gujaratiName']?.toString() ?? '',
            code: m['code']?.toString(),
            districtRegion: m['districtRegion']?.toString() ?? 'ગુજરાત',
            villageCount: m['villageCount']?.toString(),
            areaDescription: m['description']?.toString(),
            leaderName: m['leaderName']?.toString(),
            contactPhone: m['contactPhone']?.toString(),
            totalCount: int.tryParse(m['totalCount']?.toString() ?? '0') ?? 0,
          ));
        }
      }
    }
  } catch (e) {
    // Fallback gracefully if API is slow or offline
  }

  // 2. Fetch all repository parganas & district names
  final repoParganas = DirectoryRepository.getAllParganas();
  final repoDistricts = DirectoryRepository().getAllDistricts();
  final districtMap = <String, String>{};
  for (final d in repoDistricts) {
    districtMap[d.id] = d.nameGu;
  }
  // Also common district ID map
  final customDistrictMap = <String, String>{
    'd101': 'સુરત / વલસાડ',
    'd102': 'ભરૂચ',
    'd103': 'વડોદરા',
    'd104': 'આણંદ',
    'd105': 'ખેડા / નડિયાદ',
    'd106': 'અરવલ્લી / મહીસાગર',
    'd107': 'સાબરકાંઠા',
    'd108': 'પંચમહાલ / દાહોદ',
    'd109': 'અમદાવાદ / ગાંધીનગર',
    'd110': 'સાબરકાંઠા',
    'd111': 'બનાસકાંઠા',
    'd112': 'સુરેન્દ્રનગર',
    'd113': 'ભાવનગર',
    'd114': 'અમરેલી / સૌરાષ્ટ્ર',
    'd115': 'કચ્છ',
    'd116': 'મોરબી / રાજકોટ',
  };

  final Map<String, ParganaModel> parganaMap = {};

  // First insert API parganas
  for (final p in apiParganas) {
    final key = _normalizeKey(p.gujaratiName.isNotEmpty ? p.gujaratiName : p.name);
    if (key.isNotEmpty) {
      parganaMap[key] = p;
    }
  }

  // Then complement with DirectoryRepository parganas
  for (final rp in repoParganas) {
    final key = _normalizeKey(rp.nameGu.isNotEmpty ? rp.nameGu : rp.nameEn);
    if (key.isEmpty) continue;

    final resolvedDistrict = districtMap[rp.districtId] ??
        customDistrictMap[rp.districtId] ??
        'ગુજરાત';

    if (!parganaMap.containsKey(key)) {
      parganaMap[key] = ParganaModel(
        id: rp.id,
        name: rp.nameEn.isNotEmpty ? rp.nameEn : rp.nameGu,
        gujaratiName: rp.nameGu,
        code: rp.id,
        districtRegion: resolvedDistrict,
        villageCount: _extractVillageCount(rp.nameGu, rp.areaDescriptionGu),
        areaDescription: rp.areaDescriptionGu,
        leaderName: null,
        contactPhone: null,
        totalCount: 0,
      );
    } else {
      // Merge area description or district if missing
      final existing = parganaMap[key]!;
      parganaMap[key] = existing.copyWith(
        areaDescription: (existing.areaDescription == null || existing.areaDescription!.isEmpty)
            ? rp.areaDescriptionGu
            : existing.areaDescription,
        districtRegion: existing.districtRegion == 'ગુજરાત' ? resolvedDistrict : existing.districtRegion,
        villageCount: existing.villageCount ?? _extractVillageCount(rp.nameGu, rp.areaDescriptionGu),
      );
    }
  }

  // 3. Connect Profiles with Parganas
  final Map<String, List<ProfileModel>> profilesPerPargana = {};
  final List<ProfileModel> unmatchedProfiles = [];

  for (final profile in profiles) {
    final candidatePargana = profile.pargana.trim();

    bool matched = false;

    if (candidatePargana.isNotEmpty) {
      final candKey = _normalizeKey(candidatePargana);

      // Direct match
      for (final entry in parganaMap.entries) {
        if (_isMatch(entry.key, candKey, entry.value.displayName, candidatePargana)) {
          profilesPerPargana.putIfAbsent(entry.key, () => []).add(profile);
          matched = true;
          break;
        }
      }

      // If still not matched, check if it's a user-entered custom pargana (like "JADAR", "kaniyol")
      if (!matched && candidatePargana.isNotEmpty) {
        final customKey = candKey;
        profilesPerPargana.putIfAbsent(customKey, () => []).add(profile);
        if (!parganaMap.containsKey(customKey)) {
          final regionStr = profile.district.isNotEmpty
              ? profile.district
              : (profile.city != null && profile.city!.isNotEmpty ? profile.city! : 'ગુજરાત');
          parganaMap[customKey] = ParganaModel(
            id: 'custom_${candidatePargana.toLowerCase()}',
            name: candidatePargana,
            gujaratiName: candidatePargana,
            districtRegion: regionStr,
            villageCount: '૧ ગામ',
            areaDescription: profile.taluka.isNotEmpty ? 'તાલુકો: ${profile.taluka}' : null,
            totalCount: 1,
          );
        }
        matched = true;
      }
    }

    if (!matched) {
      unmatchedProfiles.add(profile);
    }
  }

  // Also if unmatchedProfiles exist, create a catch-all "અન્ય (Other)" group so no profile is omitted
  if (unmatchedProfiles.isNotEmpty) {
    final otherKey = 'other_pargana';
    profilesPerPargana[otherKey] = unmatchedProfiles;
    if (!parganaMap.containsKey(otherKey)) {
      parganaMap[otherKey] = ParganaModel(
        id: otherKey,
        name: 'Other',
        gujaratiName: 'અન્ય (Other)',
        districtRegion: 'ગુજરાત',
        villageCount: '${unmatchedProfiles.length} પરિવારો',
        areaDescription: 'અન્ય અથવા અસ્પષ્ટ પરગણાં ધરાવતા સભ્યો',
        totalCount: unmatchedProfiles.length,
      );
    }
  }

  // 4. Attach matched profiles to each ParganaModel
  final List<ParganaModel> result = [];
  for (final entry in parganaMap.entries) {
    final matchedList = profilesPerPargana[entry.key] ?? [];
    result.add(entry.value.copyWith(
      profiles: matchedList,
      totalCount: matchedList.isNotEmpty ? matchedList.length : entry.value.totalCount,
    ));
  }

  // Sort: Put Parganas with registered members first, then alphabetically/numerically
  result.sort((a, b) {
    if (a.profiles.isNotEmpty && b.profiles.isEmpty) return -1;
    if (a.profiles.isEmpty && b.profiles.isNotEmpty) return 1;
    return a.displayName.compareTo(b.displayName);
  });

  return result;
});

String _normalizeKey(String input) {
  return input
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-zA-Z0-9\u0A80-\u0AFF]'), '')
      .trim();
}

bool _isMatch(String keyA, String keyB, String fullA, String fullB) {
  if (keyA == keyB) return true;
  if (keyA.contains(keyB) || keyB.contains(keyA)) return true;
  final lowerA = fullA.toLowerCase().trim();
  final lowerB = fullB.toLowerCase().trim();
  if (lowerA.contains(lowerB) || lowerB.contains(lowerA)) return true;
  return false;
}

String? _extractVillageCount(String title, String? desc) {
  final combined = '$title ${desc ?? ''}';
  final match = RegExp(r'(\d+|[૦-૯]+)\s*ગામ').firstMatch(combined);
  if (match != null) {
    return match.group(0);
  }
  return null;
}
