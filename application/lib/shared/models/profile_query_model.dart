import 'profile_model.dart';

class ProfileQueryModel {
  final int page;
  final int limit;
  final String? gender;
  final int? ageMin;
  final int? ageMax;
  final String? districtId;
  final String? talukaId;
  final String? occupationCategory;
  final String? verification;
  final String? status;
  final String? search;
  final String? sortBy;
  final String? sortOrder;

  const ProfileQueryModel({
    this.page = 1,
    this.limit = 10,
    this.gender,
    this.ageMin,
    this.ageMax,
    this.districtId,
    this.talukaId,
    this.occupationCategory,
    this.verification,
    this.status,
    this.search,
    this.sortBy = 'createdAt',
    this.sortOrder = 'desc',
  });

  ProfileQueryModel copyWith({
    int? page,
    int? limit,
    String? gender,
    bool clearGender = false,
    int? ageMin,
    int? ageMax,
    bool clearAge = false,
    String? districtId,
    String? talukaId,
    String? occupationCategory,
    String? verification,
    String? status,
    String? search,
    bool clearSearch = false,
    String? sortBy,
    String? sortOrder,
  }) {
    return ProfileQueryModel(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      gender: clearGender ? null : (gender ?? this.gender),
      ageMin: clearAge ? null : (ageMin ?? this.ageMin),
      ageMax: clearAge ? null : (ageMax ?? this.ageMax),
      districtId: districtId ?? this.districtId,
      talukaId: talukaId ?? this.talukaId,
      occupationCategory: occupationCategory ?? this.occupationCategory,
      verification: verification ?? this.verification,
      status: status ?? this.status,
      search: clearSearch ? null : (search ?? this.search),
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (gender != null && gender!.isNotEmpty)
        'gender': ProfileModel.normalizeGenderToApi(gender),
      if (ageMin != null) 'ageMin': ageMin,
      if (ageMax != null) 'ageMax': ageMax,
      if (districtId != null) 'districtId': districtId,
      if (talukaId != null) 'talukaId': talukaId,
      if (occupationCategory != null) 'occupationCategory': occupationCategory,
      if (verification != null) 'verification': verification,
      if (status != null) 'status': status,
      if (search != null) 'search': search,
      if (sortBy != null) 'sortBy': sortBy,
      if (sortOrder != null) 'sortOrder': sortOrder,
    };
    return map;
  }
}
