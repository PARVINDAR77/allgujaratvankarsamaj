import 'dart:convert';

class ProfileModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? photoUrl;
  final List<String>? photos;
  final String? idProofType;
  final String? idProofFrontUrl;
  final String? idProofBackUrl;

  // Personal
  final String gender;
  final String maritalStatus;
  final String dateOfBirth;
  final String? bloodGroup;
  final bool? isVankar;
  final String? motherTongue;

  // Employment & Education
  final String education;
  final String employmentType;
  final String department;
  final String designation;
  final String? annualIncome;

  // Location
  final String district;
  final String taluka;
  final String pargana;
  final String? addressLine;
  final String? pincode;

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

  // Family Details
  final String? fatherName;
  final String? fatherOccupation;
  final String? fatherContact;
  final String? motherName;
  final String? motherOccupation;
  final String? guardianContact;
  final String? siblings;
  final String? mamasVillage;

  // Contact Details
  final String? contactPhone;
  final String? altPhone;
  final String? contactEmail;

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
    this.photos,
    this.idProofType,
    this.idProofFrontUrl,
    this.idProofBackUrl,
    required this.gender,
    required this.maritalStatus,
    required this.dateOfBirth,
    this.bloodGroup,
    this.isVankar = true,
    this.motherTongue = 'Gujarati (ગુજરાતી)',
    required this.education,
    required this.employmentType,
    required this.department,
    required this.designation,
    this.annualIncome,
    required this.district,
    required this.taluka,
    required this.pargana,
    this.addressLine,
    this.pincode,
    this.isVerified,
    this.isPhysicallyDisabled,
    this.pwbdCategory,
    this.isAbroad,
    this.abroadCountry,
    this.businessIndustry,
    this.businessService,
    this.fatherName,
    this.fatherOccupation,
    this.fatherContact,
    this.motherName,
    this.motherOccupation,
    this.guardianContact,
    this.siblings,
    this.mamasVillage,
    this.contactPhone,
    this.altPhone,
    this.contactEmail,
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
    if (s.contains('FEMALE') ||
        s.contains('WOMAN') ||
        s.contains('GIRL') ||
        s.contains('સ્ત્રી') ||
        s.contains('કન્યા') ||
        s.contains('BRIDE')) {
      return true;
    }
    // Heuristic protection for female candidates if database defaulted them to MALE:
    final f = firstName.toUpperCase().trim();
    if (f.endsWith('BEN') ||
        f.endsWith('BAHEN') ||
        f.contains('બેન') ||
        f.contains('બહેન') ||
        f == 'DIPIKA' ||
        f == 'SAKSHI' ||
        f == 'POOJA' ||
        f == 'PRIYA' ||
        f == 'DULA' ||
        f == 'DULABEN' ||
        f == 'HEENA' ||
        f == 'PAYAL' ||
        f == 'KINJAL') {
      return true;
    }
    return false;
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
    if (val == null) return '';
    final s = val.toString().toUpperCase().trim();
    if (s.isEmpty || s == 'ALL' || s == 'ANY') return '';
    if (s.contains('FEMALE') ||
        s.contains('WOMAN') ||
        s.contains('GIRL') ||
        s.contains('સ્ત્રી') ||
        s.contains('કન્યા') ||
        s.contains('BRIDE')) {
      return 'FEMALE';
    }
    if (s.contains('MALE') ||
        s.contains('MAN') ||
        s.contains('BOY') ||
        s.contains('પુરુષ') ||
        s.contains('વર') ||
        s.contains('GROOM')) {
      return 'MALE';
    }
    return '';
  }

  String get displayMaritalStatus => normalizeMaritalStatusToDisplay(maritalStatus);

  static String normalizeMaritalStatusToDisplay(dynamic val) {
    if (val == null) return 'Never Married (અપરિણીત)';
    final s = val.toString().trim();
    if (s.isEmpty) return 'Never Married (અપરિણીત)';

    if (s.contains('DIVORCED') || (s.contains('Divorced') && !s.contains('Awaiting')) || (s.contains('છૂટાછેડા') && !s.contains('રાહમાં'))) {
      return 'Divorced (છૂટાછેડા લીધેલ)';
    }
    if (s.contains('WIDOW') || s.contains('Widow') || s.contains('વિધવા') || s.contains('વિધુર')) {
      return 'Widowed (વિધવા / વિધુર)';
    }
    if (s.contains('SEPARATED') || s.contains('Awaiting') || s.contains('રાહમાં')) {
      return 'Awaiting Divorce (છૂટાછેડાની રાહમાં)';
    }
    if ((s.contains('MARRIED') && !s.contains('NEVER')) ||
        (s.contains('Married') && !s.contains('Never')) ||
        (s.contains('પરિણીત') && !s.contains('અપરિણીત')) ||
        (s.contains('વિવાહિત') && !s.contains('અવિવાહિત'))) {
      return 'Married (પરિણીત)';
    }
    return 'Never Married (અપરિણીત)';
  }

  static String normalizeMaritalStatusToApi(dynamic val) {
    if (val == null) return 'NEVER_MARRIED';
    final s = val.toString().trim();
    if (s.isEmpty) return 'NEVER_MARRIED';

    if (s.contains('DIVORCED') || (s.contains('Divorced') && !s.contains('Awaiting')) || (s.contains('છૂટાછેડા') && !s.contains('રાહમાં'))) {
      return 'DIVORCED';
    }
    if (s.contains('WIDOW') || s.contains('Widow') || s.contains('વિધવા') || s.contains('વિધુર')) {
      return 'WIDOWED';
    }
    if (s.contains('SEPARATED') || s.contains('Awaiting') || s.contains('રાહમાં')) {
      return 'SEPARATED';
    }
    if ((s.contains('MARRIED') && !s.contains('NEVER')) ||
        (s.contains('Married') && !s.contains('Never')) ||
        (s.contains('પરિણીત') && !s.contains('અપરિણીત')) ||
        (s.contains('વિવાહિત') && !s.contains('અવિવાહિત'))) {
      return 'MARRIED';
    }
    return 'NEVER_MARRIED';
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
    if (country != null && country != 'India' && country!.isNotEmpty) {
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

    var rawDistrict = extractString(json['district'] ?? json['state']);
    var rawTaluka = extractString(json['taluka'] ?? json['city']);
    var rawPargana = extractString(json['pargana'] ?? json['nativePlace'] ?? json['native_place']);
    var rawEmployment = extractString(json['employmentType'] ?? json['occupation']);
    var rawDepartment = extractString(json['department'] ?? json['organizationName'] ?? json['organization_name']);
    var rawDesignation = extractString(json['designation']);

    // Fallbacks from nested governmentEmployment relation if present
    if (json['governmentEmployment'] is Map) {
      final govt = json['governmentEmployment'] as Map;
      if (rawDepartment.isEmpty) {
        rawDepartment = extractString(govt['department']);
        if (rawDepartment.isEmpty && govt['employmentType'] != null) {
          rawDepartment = govt['employmentType'] == 'CENTRAL_GOVT' ? 'Central Government (કેન્દ્ર સરકાર)' : 'State Government (રાજ્ય સરકાર)';
        }
      }
      if (rawDesignation.isEmpty) {
        rawDesignation = extractString(govt['designation']);
      }
      if (rawEmployment.isEmpty) {
        rawEmployment = extractString(govt['employmentType']);
        if (rawEmployment.isEmpty) {
          rawEmployment = 'Government Sector (સરકારી નોકરી / સેકટર)';
        }
      }
    }

    // Extract user contact if nested
    String? userPhone;
    String? userEmail;
    if (json['user'] is Map) {
      userPhone = json['user']['phone']?.toString();
      userEmail = json['user']['email']?.toString();
    }

    var rawFirst = (json['firstName'] ?? json['first_name'] ?? '').toString().trim();
    var rawLast = (json['lastName'] ?? json['last_name'] ?? '').toString().trim();
    if (rawFirst.isEmpty && (json['fullName'] != null || json['name'] != null)) {
      final combined = (json['fullName'] ?? json['name']).toString().trim();
      final parts = combined.split(' ');
      if (parts.isNotEmpty) {
        rawFirst = parts.first;
        if (parts.length > 1) {
          rawLast = parts.sublist(1).join(' ');
        }
      }
    }
    final rawFirstUpper = rawFirst.toUpperCase();
    String resolvedGender = normalizeGenderToDisplay(json['gender']);
    if (rawFirstUpper.endsWith('BEN') ||
        rawFirstUpper.endsWith('BAHEN') ||
        rawFirstUpper.contains('બેન') ||
        rawFirstUpper.contains('બહેન') ||
        ['DIPIKA', 'SAKSHI', 'POOJA', 'PRIYA', 'DULA', 'DULABEN', 'HEENA', 'PAYAL', 'KINJAL'].contains(rawFirstUpper)) {
      resolvedGender = 'Female (સ્ત્રી)';
    }

    List<String>? parsedPhotos;
    final rawPhotos = json['photos'];
    if (rawPhotos is List) {
      parsedPhotos = rawPhotos.map((e) => e.toString()).toList();
    } else if (rawPhotos is String && rawPhotos.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawPhotos);
        if (decoded is List) {
          parsedPhotos = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {
        parsedPhotos = [rawPhotos];
      }
    }

    String? idDocType = json['idProofType']?.toString();
    String? idDocFront = json['idProofFrontUrl']?.toString();
    String? idDocBack = json['idProofBackUrl']?.toString();
    if (json['verification'] is Map) {
      idDocType ??= json['verification']['documentType']?.toString();
      idDocFront ??= json['verification']['documentUrl']?.toString();
      idDocBack ??= json['verification']['documentBackUrl']?.toString();
    }

    return ProfileModel(
      id: (json['id'] ?? '').toString(),
      firstName: rawFirst,
      lastName: rawLast,
      photoUrl: (json['photoUrl'] ?? json['photo_url']) as String?,
      photos: parsedPhotos,
      idProofType: idDocType,
      idProofFrontUrl: idDocFront,
      idProofBackUrl: idDocBack,
      gender: resolvedGender,
      maritalStatus: normalizeMaritalStatusToDisplay(json['maritalStatus'] ?? json['marital_status'] ?? json['maritialStatus']),
      dateOfBirth: (json['dateOfBirth'] ?? json['date_of_birth'] ?? '').toString(),
      bloodGroup: (json['bloodGroup'] ?? json['blood_group'])?.toString(),
      isVankar: (json['isVankar'] ?? json['is_vankar']) as bool? ?? true,
      motherTongue: (json['motherTongue'] ?? json['mother_tongue'])?.toString() ?? 'Gujarati (ગુજરાતી)',
      education: (json['education'] ?? '').toString(),
      employmentType: rawEmployment,
      department: rawDepartment,
      designation: rawDesignation,
      annualIncome: (json['annualIncome'] ?? json['annual_income'] ?? json['yearlyIncome'] ?? json['income'])?.toString(),
      district: rawDistrict,
      taluka: rawTaluka,
      pargana: rawPargana,
      addressLine: (json['addressLine'] ?? json['address_line'] ?? json['address'])?.toString(),
      pincode: (json['pincode'])?.toString(),
      isVerified: (json['isVerified'] ?? json['is_verified']) as bool?,
      isPhysicallyDisabled: (json['isPhysicallyDisabled'] ?? json['is_physically_disabled']) as bool?,
      pwbdCategory: (json['pwbdCategory'] ?? json['pwbd_category']) as String?,
      isAbroad: (json['isAbroad'] ?? json['is_abroad']) as bool?,
      abroadCountry: (json['abroadCountry'] ?? json['abroad_country']) as String?,
      businessIndustry: (json['businessIndustry'] ?? json['business_industry']) as String?,
      businessService: (json['businessService'] ?? json['business_service']) as String?,
      fatherName: (json['fatherName'] ?? json['father_name'])?.toString(),
      fatherOccupation: (json['fatherOccupation'] ?? json['father_occupation'])?.toString(),
      fatherContact: (json['fatherContact'] ?? json['father_contact'] ?? json['fatherPhone'])?.toString(),
      motherName: (json['motherName'] ?? json['mother_name'])?.toString(),
      motherOccupation: (json['motherOccupation'] ?? json['mother_occupation'])?.toString(),
      guardianContact: (json['guardianContact'] ?? json['guardian_contact'])?.toString(),
      siblings: (json['siblings'] ?? json['brothersSisters'])?.toString(),
      mamasVillage: (json['mamasVillage'] ?? json['mamas_village'] ?? json['mosal'])?.toString(),
      contactPhone: (json['contactPhone'] ?? json['phone'] ?? userPhone ?? json['altPhone'] ?? json['alt_phone'])?.toString(),
      altPhone: (json['altPhone'] ?? json['alt_phone'] ?? json['whatsapp'])?.toString(),
      contactEmail: (json['contactEmail'] ?? json['contact_email'] ?? userEmail)?.toString(),
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
      if (id.isNotEmpty && !id.startsWith('NEW')) 'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'photoUrl': photoUrl,
      if (photos != null && photos!.isNotEmpty) 'photos': photos,
      if (idProofType != null) 'idProofType': idProofType,
      if (idProofFrontUrl != null) 'idProofFrontUrl': idProofFrontUrl,
      if (idProofBackUrl != null) 'idProofBackUrl': idProofBackUrl,
      'gender': normalizeGenderToApi(gender),
      'maritalStatus': normalizeMaritalStatusToApi(maritalStatus),
      'dateOfBirth': dateOfBirth,
      'education': education,
      'occupation': employmentType,
      'organizationName': department,
      'designation': designation,
      'annualIncome': annualIncome,
      'nativePlace': pargana.isNotEmpty ? pargana : nativePlace,
      'city': taluka.isNotEmpty ? taluka : city,
      'state': district.isNotEmpty ? district : state,
      'country': country ?? 'India',
      'addressLine': addressLine,
      'pincode': pincode,
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
      'bloodGroup': bloodGroup,
      'isVankar': isVankar,
      'motherTongue': motherTongue,
      'fatherName': fatherName,
      'fatherOccupation': fatherOccupation,
      'fatherContact': fatherContact,
      'motherName': motherName,
      'motherOccupation': motherOccupation,
      'guardianContact': guardianContact,
      'siblings': siblings,
      'mamasVillage': mamasVillage,
      'altPhone': altPhone,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
    };

    return map;
  }
}
