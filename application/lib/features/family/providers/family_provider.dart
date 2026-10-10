import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../profile/providers/profile_provider.dart';
import '../models/family_model.dart';

final familyDirectoryProvider = FutureProvider.autoDispose<List<FamilyModel>>((ref) async {
  final dio = ref.watch(apiClientProvider);

  // 1. Try dedicated live backend family-directory endpoint
  try {
    final response = await dio.get('/profiles/family-directory');
    dynamic raw = response.data;
    if (raw is String) {
      try {
        raw = jsonDecode(raw);
      } catch (_) {}
    }
    if (raw is Map<String, dynamic> && raw.containsKey('data')) {
      raw = raw['data'];
    }
    if (raw is List && raw.isNotEmpty) {
      final liveFamilies = raw
          .map((item) => FamilyModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      if (liveFamilies.isNotEmpty) {
        // Return live families first, followed by curated baseline
        return [...liveFamilies, ...FamilyModel.curatedSampleFamilies];
      }
    }
  } catch (_) {
    // Graceful fallback to profile state
  }

  // 2. Fallback to live registered matrimonial profiles
  try {
    final profileState = ref.watch(profileNotifierProvider);
    if (profileState.profiles.isNotEmpty) {
      final liveFromProfiles = profileState.profiles
          .map((p) => FamilyModel.fromProfile(p))
          .toList();
      return [...liveFromProfiles, ...FamilyModel.curatedSampleFamilies];
    }
  } catch (_) {}

  // 3. Fallback to direct /profiles API call if profileNotifier hasn't loaded yet
  try {
    final response = await dio.get('/profiles', queryParameters: {'limit': 50});
    final raw = response.data;
    if (raw is Map && raw['items'] is List) {
      final items = raw['items'] as List;
      final liveList = items.map((json) {
        final map = Map<String, dynamic>.from(json as Map);
        String rawLast = (map['lastName'] ?? '').toString().trim();
        String rawFirst = (map['firstName'] ?? '').toString().trim();
        if (rawLast.isEmpty && rawFirst.isEmpty) {
          rawLast = 'Vankar';
        }

        String headNameEng = rawFirst;
        String surnameEng = rawLast;

        if (rawLast.contains(' ')) {
          final parts = rawLast.split(RegExp(r'\s+'));
          surnameEng = parts.last;
          if (headNameEng.isEmpty) {
            headNameEng = parts.sublist(0, parts.length - 1).join(' ');
          }
        }
        if (surnameEng.isEmpty) surnameEng = 'Vankar';

        final surnameGuj = FamilyModel.translateSurnameToGuj(surnameEng);
        final headNameGuj = headNameEng.isNotEmpty ? FamilyModel.translateGivenNameToGuj(headNameEng) : '';
        final nameGuj = '$surnameGuj પરિવાર';
        final nameEng = headNameEng.isNotEmpty ? '$headNameEng $surnameEng Family' : '$surnameEng Family';

        final city = map['city']?.toString().isNotEmpty == true
            ? map['city'].toString()
            : (map['state']?.toString().isNotEmpty == true ? map['state'].toString() : 'Gujarat');
        final cityGuj = FamilyModel.translateCityToGuj(city);
        final mosal = map['mamasVillage']?.toString().isNotEmpty == true
            ? map['mamasVillage'].toString()
            : (map['nativePlace']?.toString().isNotEmpty == true ? map['nativePlace'].toString() : 'Gujarat');

        return FamilyModel(
          id: map['id']?.toString() ?? '',
          nameGuj: nameGuj,
          nameEng: nameEng,
          surname: surnameEng,
          headName: headNameEng,
          headNameGuj: headNameGuj,
          cityGuj: cityGuj,
          cityEng: city,
          details: 'મોસાળ: $mosal | Masal: $mosal',
          mosal: mosal,
          nativePlace: map['nativePlace']?.toString() ?? city,
          pargana: map['nativePlace']?.toString(),
          district: map['state']?.toString(),
          fatherName: map['fatherName']?.toString(),
          fatherOccupation: map['fatherOccupation']?.toString(),
          fatherContact: map['fatherContact']?.toString() ?? map['user']?['phone']?.toString(),
          motherName: map['motherName']?.toString(),
          motherOccupation: map['motherOccupation']?.toString(),
          guardianContact: map['guardianContact']?.toString(),
          siblings: map['siblings']?.toString(),
          address: map['addressLine']?.toString(),
          pincode: map['pincode']?.toString(),
          candidateName: '${map['firstName'] ?? ''} ${map['lastName'] ?? ''}'.trim(),
          candidateGender: map['gender']?.toString(),
          candidateEducation: map['education']?.toString(),
          candidateOccupation: map['occupation']?.toString() ?? map['designation']?.toString(),
          candidateId: map['id']?.toString(),
          photoUrl: map['photoUrl']?.toString(),
          isVerified: map['isVerified'] == true,
          isLiveMember: true,
        );
      }).toList();

      if (liveList.isNotEmpty) {
        return [...liveList, ...FamilyModel.curatedSampleFamilies];
      }
    }
  } catch (_) {}

  // 4. Default curated baseline
  return FamilyModel.curatedSampleFamilies;
});
