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
  });

  String get fullName => '$firstName $lastName';

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

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      photoUrl: (json['photoUrl'] ?? json['photo_url']) as String?,
      gender: normalizeGenderToDisplay(json['gender']),
      maritalStatus: json['maritalStatus'] as String? ?? 'Never Married (અપરિણીત)',
      dateOfBirth: json['dateOfBirth'] as String? ?? '',
      education: json['education'] as String? ?? '',
      employmentType: json['employmentType'] as String? ?? '',
      department: json['department'] as String? ?? '',
      designation: json['designation'] as String? ?? '',
      district: json['district'] as String? ?? '',
      taluka: json['taluka'] as String? ?? '',
      pargana: json['pargana'] as String? ?? '',
      isVerified: json['isVerified'] as bool?,
      isPhysicallyDisabled: json['isPhysicallyDisabled'] as bool?,
      pwbdCategory: json['pwbdCategory'] as String?,
      isAbroad: json['isAbroad'] as bool?,
      abroadCountry: json['abroadCountry'] as String?,
      businessIndustry: json['businessIndustry'] as String?,
      businessService: json['businessService'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'photoUrl': photoUrl,
      'gender': normalizeGenderToApi(gender),
      'maritalStatus': maritalStatus.contains('Divorced') ? 'DIVORCED' : (maritalStatus.contains('Widow') ? 'WIDOWED' : (maritalStatus.contains('Awaiting') ? 'SEPARATED' : 'NEVER_MARRIED')),
      'dateOfBirth': dateOfBirth, 
      'education': education,
      'occupation': employmentType,
      'organizationName': department,
      'designation': designation,
      'nativePlace': pargana,
      'city': taluka,
      'state': district,
      'country': 'India',
      'isPhysicallyDisabled': isPhysicallyDisabled,
      'pwbdCategory': pwbdCategory,
      'isAbroad': isAbroad,
      'abroadCountry': abroadCountry,
      'businessIndustry': businessIndustry,
      'businessService': businessService,
    };
    
    // Do not include 'id' and 'isVerified' in the payload. 
    // They are controlled by the backend and will fail validation.
    
    return map;
  }
}
