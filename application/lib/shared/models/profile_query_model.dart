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
    int? ageMin,
    int? ageMax,
    String? districtId,
    String? talukaId,
    String? occupationCategory,
    String? verification,
    String? status,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) {
    return ProfileQueryModel(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      gender: gender ?? this.gender,
      ageMin: ageMin ?? this.ageMin,
      ageMax: ageMax ?? this.ageMax,
      districtId: districtId ?? this.districtId,
      talukaId: talukaId ?? this.talukaId,
      occupationCategory: occupationCategory ?? this.occupationCategory,
      verification: verification ?? this.verification,
      status: status ?? this.status,
      search: search ?? this.search,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (gender != null) 'gender': gender,
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
