class ProfileModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? photoUrl;

  // Personal
  final String gender;
  final String maritalStatus;
  final String dateOfBirth;

  // Employment & Education
  final String education;
  final String employmentType;
  final String department;
  final String designation;

  // Location
  final String district;
  final String taluka;
  final String pargana;

  // Verification (Prisma: is_verified Boolean @default(false))
  final bool? isVerified;

  // Disability
  final bool? isPhysicallyDisabled;
  final String? pwbdCategory;

  // Abroad
  final bool? isAbroad;
  final String? abroadCountry;

  // Business
  final String? businessIndustry;
  final String? businessService;

  // Additional database fields
  final String? about;
  final String? religion;
  final String? caste;
  final String? subcaste;
  final String? city;
  final String? state;
  final String? country;
  final String? nativePlace;

  const ProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.photoUrl,
    required this.gender,
    required this.maritalStatus,
    required this.dateOfBirth,
    required this.education,
    required this.employmentType,
    required this.department,
    required this.designation,
    required this.district,
    required this.taluka,
    required this.pargana,
    this.isVerified,
    this.isPhysicallyDisabled,
    this.pwbdCategory,
    this.isAbroad,
    this.abroadCountry,
    this.businessIndustry,
    this.businessService,
    this.about,
    this.religion,
    this.caste,
    this.subcaste,
    this.city,
    this.state,
    this.country,
    this.nativePlace,
  });

  String get fullName => '$firstName $lastName'.trim().isEmpty ? 'Member' : '$firstName $lastName'.trim();

  bool get isFemale {
    final s = gender.toUpperCase();
    return s.contains('FEMALE') ||
        s.contains('WOMAN') ||
        s.contains('GIRL') ||
        s.contains('સ્ત્રી') ||
        s.contains('કન્યા') ||
        s.contains('BRIDE');
  }

  bool get isMale => !isFemale;

  String get displayGender => isFemale ? 'Female (સ્ત્રી)' : 'Male (પુરુષ)';

  static String normalizeGenderToDisplay(dynamic val) {
    if (val == null) return 'Male (પુરુષ)';
    final s = val.toString().toUpperCase();
    if (s.contains('FEMALE') ||
        s.contains('WOMAN') ||
        s.contains('GIRL') ||
        s.contains('સ્ત્રી') ||
        s.contains('કન્યા') ||
        s.contains('BRIDE')) {
      return 'Female (સ્ત્રી)';
    }
    return 'Male (પુરુષ)';
  }

  static String normalizeGenderToApi(dynamic val) {
    if (val == null) return 'MALE';
    final s = val.toString().toUpperCase();
    if (s.contains('FEMALE') ||
        s.contains('WOMAN') ||
        s.contains('GIRL') ||
        s.contains('સ્ત્રી') ||
        s.contains('કન્યા') ||
        s.contains('BRIDE')) {
      return 'FEMALE';
    }
    return 'MALE';
  }

  String? get fullPhotoUrl {
    if (photoUrl == null || photoUrl!.trim().isEmpty) return null;
    final clean = photoUrl!.trim();
    if (clean.startsWith('http://') || clean.startsWith('https://')) return clean;
    final relative = clean.startsWith('/') ? clean : '/$clean';
    return 'https://allgujaratvankarsamaj.com$relative';
  }

  int? get age {
    if (dateOfBirth.isEmpty) return null;
    try {
      final dt = DateTime.tryParse(dateOfBirth);
      if (dt != null) {
        final today = DateTime.now();
        int a = today.year - dt.year;
        if (today.month < dt.month || (today.month == dt.month && today.day < dt.day)) {
          a--;
        }
        return a >= 0 ? a : null;
      }
    } catch (_) {}
    return null;
  }

  String get displayDob {
    if (dateOfBirth.isEmpty) return 'Not specified';
    try {
      final dt = DateTime.tryParse(dateOfBirth);
      if (dt != null) {
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final day = dt.day.toString().padLeft(2, '0');
        final month = months[dt.month - 1];
        final year = dt.year;
        final a = age;
        if (a != null && a > 0) {
          return '$day $month $year ($a yrs)';
        }
        return '$day $month $year';
      }
    } catch (_) {}
    return dateOfBirth;
  }

  String get displayLocation {
    final parts = <String>[];
    void addPart(String? p) {
      if (p != null && p.trim().isNotEmpty && p != 'Not specified' && !parts.contains(p.trim())) {
        parts.add(p.trim());
      }
    }
    addPart(pargana.isNotEmpty ? pargana : nativePlace);
    addPart(taluka.isNotEmpty ? taluka : city);
    addPart(district.isNotEmpty ? district : state);
    if (country != null && country != 'India') {
      addPart(country);
    }
    return parts.isEmpty ? 'Not specified' : parts.join(', ');
  }

  String get displayProfession {
    final parts = <String>[];
    void addPart(String? p) {
      if (p != null && p.trim().isNotEmpty && p != 'Not specified' && !parts.contains(p.trim())) {
        parts.add(p.trim());
      }
    }
    addPart(designation);
    addPart(employmentType);
    addPart(department);
    return parts.isEmpty ? 'Not specified' : parts.join(' - ');
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    String extractString(dynamic val) {
      if (val == null) return '';
      if (val is Map) return val['name']?.toString() ?? '';
      return val.toString().trim();
    }

    final rawDistrict = extractString(json['district'] ?? json['state']);
    final rawTaluka = extractString(json['taluka'] ?? json['city']);
    final rawPargana = extractString(json['pargana'] ?? json['nativePlace'] ?? json['native_place']);
    final rawEmployment = extractString(json['employmentType'] ?? json['occupation']);
    final rawDepartment = extractString(json['department'] ?? json['organizationName'] ?? json['organization_name']);
    final rawDesignation = extractString(json['designation']);

    return ProfileModel(
      id: (json['id'] ?? '').toString(),
      firstName: (json['firstName'] ?? json['first_name'] ?? '').toString(),
      lastName: (json['lastName'] ?? json['last_name'] ?? '').toString(),
      photoUrl: (json['photoUrl'] ?? json['photo_url']) as String?,
      gender: normalizeGenderToDisplay(json['gender']),
      maritalStatus: (json['maritalStatus'] ?? json['marital_status'] ?? 'Never Married (અપરિણીત)').toString(),
      dateOfBirth: (json['dateOfBirth'] ?? json['date_of_birth'] ?? '').toString(),
      education: (json['education'] ?? '').toString(),
      employmentType: rawEmployment,
      department: rawDepartment,
      designation: rawDesignation,
      district: rawDistrict,
      taluka: rawTaluka,
      pargana: rawPargana,
      isVerified: (json['isVerified'] ?? json['is_verified']) as bool?,
      isPhysicallyDisabled: (json['isPhysicallyDisabled'] ?? json['is_physically_disabled']) as bool?,
      pwbdCategory: (json['pwbdCategory'] ?? json['pwbd_category']) as String?,
      isAbroad: (json['isAbroad'] ?? json['is_abroad']) as bool?,
      abroadCountry: (json['abroadCountry'] ?? json['abroad_country']) as String?,
      businessIndustry: (json['businessIndustry'] ?? json['business_industry']) as String?,
      businessService: (json['businessService'] ?? json['business_service']) as String?,
      about: (json['about']) as String?,
      religion: (json['religion']) as String?,
      caste: (json['caste']) as String?,
      subcaste: (json['subcaste']) as String?,
      city: extractString(json['city']),
      state: extractString(json['state']),
      country: (json['country']) as String?,
      nativePlace: (json['nativePlace'] ?? json['native_place']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'photoUrl': photoUrl,
      'gender': normalizeGenderToApi(gender),
      'maritalStatus': maritalStatus.contains('Divorced')
          ? 'DIVORCED'
          : (maritalStatus.contains('Widow')
              ? 'WIDOWED'
              : (maritalStatus.contains('Awaiting') ? 'SEPARATED' : 'NEVER_MARRIED')),
      'dateOfBirth': dateOfBirth,
      'education': education,
      'occupation': employmentType,
      'organizationName': department,
      'designation': designation,
      'nativePlace': pargana.isNotEmpty ? pargana : nativePlace,
      'city': taluka.isNotEmpty ? taluka : city,
      'state': district.isNotEmpty ? district : state,
      'country': country ?? 'India',
      'isPhysicallyDisabled': isPhysicallyDisabled,
      'pwbdCategory': pwbdCategory,
      'isAbroad': isAbroad,
      'abroadCountry': abroadCountry,
      'businessIndustry': businessIndustry,
      'businessService': businessService,
      'about': about,
      'religion': religion,
      'caste': caste,
      'subcaste': subcaste,
    };

    return map;
  }
}
