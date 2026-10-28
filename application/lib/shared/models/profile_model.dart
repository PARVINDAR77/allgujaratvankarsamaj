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
  final String? idProofNumber;

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
  final bool isPhoneVerified;
  final bool isEmailVerified;

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

  // Privacy Settings
  final String? privacySettings;
  final String? mobilePrivacy;
  final String? emailPrivacy;
  final String? addressPrivacy;
  final String? guardianPrivacy;
  final bool shareClassGroup;
  final bool showInMatrimony;

  const ProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.photoUrl,
    this.photos,
    this.idProofType,
    this.idProofFrontUrl,
    this.idProofBackUrl,
    this.idProofNumber,
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
    this.isPhoneVerified = false,
    this.isEmailVerified = false,
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
    this.privacySettings,
    this.mobilePrivacy,
    this.emailPrivacy,
    this.addressPrivacy,
    this.guardianPrivacy,
    this.shareClassGroup = false,
    this.showInMatrimony = true,
  });

  String get fullName => '$firstName $lastName'.trim().isEmpty ? 'Member' : '$firstName $lastName'.trim();

  String get shortId {
    if (id.isEmpty) return 'AGVS';
    if (id.contains('-')) {
      final prefix = id.split('-').first.toUpperCase();
      return prefix;
    }
    if (id.length > 8) {
      return id.substring(0, 8).toUpperCase();
    }
    return id.toUpperCase();
  }

  String get displayId => '#$shortId';

  String get cleanDisplayId {
    final raw = id.trim();
    if (raw.toUpperCase().startsWith('VNK')) return raw.toUpperCase();
    if (raw.contains('-')) {
      final part = raw.split('-').first.toUpperCase();
      return 'VNK-$part';
    }
    if (raw.length > 8) {
      return 'VNK-${raw.substring(0, 6).toUpperCase()}';
    }
    if (raw.isNotEmpty) {
      return 'VNK-$raw'.toUpperCase();
    }
    return '#$shortId';
  }


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

  // Privacy Resolution
  String get effectiveMobilePrivacy => mobilePrivacy?.trim().isNotEmpty == true
      ? mobilePrivacy!
      : (isFemale ? 'માત્ર મને' : 'બધા માટે');

  String get effectiveEmailPrivacy => emailPrivacy?.trim().isNotEmpty == true
      ? emailPrivacy!
      : (isFemale ? 'માત્ર મને' : 'બધા માટે');

  String get effectiveAddressPrivacy => addressPrivacy?.trim().isNotEmpty == true
      ? addressPrivacy!
      : 'પરિવારજનો';

  String get effectiveGuardianPrivacy => guardianPrivacy?.trim().isNotEmpty == true
      ? guardianPrivacy!
      : 'બધા માટે';

  bool isMobileBlockedForViewer({bool isOwner = false}) {
    if (isOwner) return false;
    final priv = effectiveMobilePrivacy;
    if (priv == 'માત્ર મને') return true;
    if (priv == 'બધા માટે') return false;
    if (isFemale) return true;
    return false;
  }

  bool isEmailBlockedForViewer({bool isOwner = false}) {
    if (isOwner) return false;
    final priv = effectiveEmailPrivacy;
    if (priv == 'માત્ર મને') return true;
    if (priv == 'બધા માટે') return false;
    if (isFemale) return true;
    return false;
  }

  bool isAddressBlockedForViewer({bool isOwner = false}) {
    if (isOwner) return false;
    final priv = effectiveAddressPrivacy;
    if (priv == 'માત્ર મને') return true;
    return false;
  }

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

  bool get isMarried => checkIsMarried(maritalStatus);

  static bool checkIsMarried(dynamic val) {
    if (val == null) return false;
    final s = val.toString().trim();
    if (s.isEmpty) return false;
    return normalizeMaritalStatusToApi(s) == 'MARRIED';
  }

  static String normalizeMaritalStatusToDisplay(dynamic val) {
    if (val == null) return 'Never Married (અપરિણીત)';
    final s = val.toString().trim();
    final u = s.toUpperCase();
    if (s.isEmpty) return 'Never Married (અપરિણીત)';

    if (u.contains('DIVORCED') || (s.contains('છૂટાછેડા') && !s.contains('રાહમાં'))) {
      return 'Divorced (છૂટાછેડા લીધેલ)';
    }
    if (u.contains('WIDOW') || s.contains('વિધવા') || s.contains('વિધુર')) {
      return 'Widowed (વિધવા / વિધુર)';
    }
    if (u.contains('SEPARATED') || u.contains('AWAITING') || s.contains('રાહમાં')) {
      return 'Awaiting Divorce (છૂટાછેડાની રાહમાં)';
    }
    if ((u.contains('MARRIED') && !u.contains('NEVER') && !u.contains('UNMARRIED')) ||
        (s.contains('પરિણીત') && !s.contains('અપરિણીત')) ||
        (s.contains('વિવાહિત') && !s.contains('અવિવાહિત'))) {
      return 'Married (પરિણીત)';
    }
    return 'Never Married (અપરિણીત)';
  }

  static String normalizeMaritalStatusToApi(dynamic val) {
    if (val == null) return 'NEVER_MARRIED';
    final s = val.toString().trim();
    final u = s.toUpperCase();
    if (s.isEmpty) return 'NEVER_MARRIED';

    if (u.contains('DIVORCED') || (s.contains('છૂટાછેડા') && !s.contains('રાહમાં'))) {
      return 'DIVORCED';
    }
    if (u.contains('WIDOW') || s.contains('વિધવા') || s.contains('વિધુર')) {
      return 'WIDOWED';
    }
    if (u.contains('SEPARATED') || u.contains('AWAITING') || s.contains('રાહમાં')) {
      return 'SEPARATED';
    }
    if ((u.contains('MARRIED') && !u.contains('NEVER') && !u.contains('UNMARRIED')) ||
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
      if (p != null &&
          p.trim().isNotEmpty &&
          p != 'Not specified' &&
          p != 'Not Specified' &&
          !parts.contains(p.trim())) {
        parts.add(p.trim());
      }
    }
    addPart(pargana.isNotEmpty ? pargana : nativePlace);
    addPart(taluka.isNotEmpty ? taluka : city);
    addPart(district.isNotEmpty ? district : state);
    if (country != null && country != 'India' && country!.isNotEmpty) {
      addPart(country);
    }
    return parts.isEmpty ? 'ગુજરાત (Gujarat)' : parts.join(', ');
  }

  String get displayProfession {
    final parts = <String>[];
    void addPart(String? p) {
      if (p != null &&
          p.trim().isNotEmpty &&
          p != 'Not specified' &&
          p != 'Not Specified' &&
          !parts.contains(p.trim())) {
        parts.add(p.trim());
      }
    }
    addPart(designation);
    addPart(employmentType);
    addPart(department);
    if (parts.isEmpty) {
      return isFemale ? 'ગૃહકાર્ય / અભ્યાસ' : 'ખાનગી / વ્યવસાય';
    }
    return parts.join(' - ');
  }

  int get brothersMarried => _extractSiblingMetric('bm', 'brothersMarried', 'brothers_married', r'(?:married\s+brothers?|brothers?\s+married|ભાઈ\s*પરિણિત|પરિણિત\s*ભાઈ)');
  int get brothersUnmarried => _extractSiblingMetric('bu', 'brothersUnmarried', 'brothers_unmarried', r'(?:unmarried\s+brothers?|brothers?\s+unmarried|ભાઈ\s*અપરિણિત|અપરિણિત\s*ભાઈ)');
  int get sistersMarried => _extractSiblingMetric('sm', 'sistersMarried', 'sisters_married', r'(?:married\s+sisters?|sisters?\s+married|બહેન\s*પરિણિત|પરિણિત\s*બહેન)');
  int get sistersUnmarried => _extractSiblingMetric('su', 'sistersUnmarried', 'sisters_unmarried', r'(?:unmarried\s+sisters?|sisters?\s+unmarried|બહેન\s*અપરિણિત|અપરિણિત\s*બહેન)');

  int _extractSiblingMetric(String key1, String key2, String key3, String regexPattern) {
    final s = siblings?.trim() ?? '';
    if (s.isEmpty) return 0;
    if (s.startsWith('{') && s.endsWith('}')) {
      try {
        final decoded = jsonDecode(s);
        if (decoded is Map) {
          final val = decoded[key1] ?? decoded[key2] ?? decoded[key3];
          if (val != null) return int.tryParse(val.toString()) ?? 0;
        }
      } catch (_) {}
    }
    var normalized = s;
    const guj = ['૦', '૧', '૨', '૩', '૪', '૫', '૬', '૭', '૮', '૯'];
    for (int i = 0; i < 10; i++) {
      normalized = normalized.replaceAll(guj[i], i.toString());
    }
    final match = RegExp('(\\d+)\\s*$regexPattern', caseSensitive: false).firstMatch(normalized);
    if (match != null) {
      return int.tryParse(match.group(1)!) ?? 0;
    }
    final matchReverse = RegExp('$regexPattern\\s*(\\d+)', caseSensitive: false).firstMatch(normalized);
    if (matchReverse != null) {
      return int.tryParse(matchReverse.group(1)!) ?? 0;
    }
    return 0;
  }

  String get displaySiblingDetails {
    final s = siblings?.trim() ?? '';
    if (s.isEmpty) return '';
    if (s.startsWith('{') && s.endsWith('}')) {
      try {
        final decoded = jsonDecode(s);
        if (decoded is Map) {
          final d = decoded['details'] ?? decoded['notes'] ?? decoded['desc'] ?? '';
          return d.toString().trim();
        }
      } catch (_) {}
    }
    return s;
  }

  String get displaySiblings {
    final s = siblings?.trim() ?? '';
    if (s.isEmpty) return 'Not specified';
    if (s.startsWith('{') && s.endsWith('}')) {
      try {
        final decoded = jsonDecode(s);
        if (decoded is Map) {
          final bm = brothersMarried;
          final bu = brothersUnmarried;
          final sm = sistersMarried;
          final su = sistersUnmarried;
          final details = displaySiblingDetails;

          final parts = <String>[];
          if (bm > 0 || bu > 0) {
            parts.add('Brothers: $bm Married, $bu Unmarried');
          }
          if (sm > 0 || su > 0) {
            parts.add('Sisters: $sm Married, $su Unmarried');
          }
          if (parts.isEmpty && (bm + bu + sm + su == 0)) {
            parts.add('No brothers or sisters');
          }
          if (details.isNotEmpty) {
            parts.add('($details)');
          }
          return parts.join(' | ');
        }
      } catch (_) {}
    }
    return s;
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
    String? idDocNumber = json['idProofNumber']?.toString() ?? json['id_proof_number']?.toString();

    if (json['verification'] is Map) {
      idDocType ??= json['verification']['documentType']?.toString();
      idDocFront ??= json['verification']['documentUrl']?.toString();
      idDocBack ??= json['verification']['documentBackUrl']?.toString();
      final vDocType = json['verification']['documentType']?.toString();
      if (idDocNumber == null && vDocType != null) {
        final match = RegExp(r'\[ID:\s*([^\]]+)\]', caseSensitive: false).firstMatch(vDocType);
        if (match != null) idDocNumber = match.group(1)?.trim();
      }
    }

    // Extract privacy settings
    String? rawPrivacy = json['privacySettings']?.toString() ?? json['privacy_settings']?.toString();
    String? mobPriv = json['mobilePrivacy']?.toString();
    String? emPriv = json['emailPrivacy']?.toString();
    String? addrPriv = json['addressPrivacy']?.toString();
    String? guardPriv = json['guardianPrivacy']?.toString();
    bool shareClass = json['shareClassGroup'] == true;

    if (rawPrivacy != null && rawPrivacy.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawPrivacy);
        if (decoded is Map) {
          mobPriv ??= decoded['mobile']?.toString();
          emPriv ??= decoded['email']?.toString();
          addrPriv ??= decoded['address']?.toString();
          guardPriv ??= decoded['guardian']?.toString();
          if (decoded['shareClassGroup'] != null) {
            shareClass = decoded['shareClassGroup'] == true;
          }
        }
      } catch (_) {}
    }

    bool phoneVer = false;
    bool emailVer = false;
    if (json['user'] is Map) {
      phoneVer = json['user']['isPhoneVerified'] == true ||
          json['user']['is_phone_verified'] == 1 ||
          json['user']['is_phone_verified'] == true;
      emailVer = json['user']['isEmailVerified'] == true ||
          json['user']['is_email_verified'] == 1 ||
          json['user']['is_email_verified'] == true;
    }
    phoneVer = phoneVer ||
        json['isPhoneVerified'] == true ||
        json['is_phone_verified'] == 1 ||
        json['is_phone_verified'] == true;
    emailVer = emailVer ||
        json['isEmailVerified'] == true ||
        json['is_email_verified'] == 1 ||
        json['is_email_verified'] == true;

    return ProfileModel(
      id: (json['id'] ?? '').toString(),
      firstName: rawFirst,
      lastName: rawLast,
      photoUrl: (json['photoUrl'] ?? json['photo_url']) as String?,
      photos: parsedPhotos,
      idProofType: idDocType,
      idProofFrontUrl: idDocFront,
      idProofBackUrl: idDocBack,
      idProofNumber: idDocNumber,
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
      isPhoneVerified: phoneVer,
      isEmailVerified: emailVer,
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
      privacySettings: rawPrivacy,
      mobilePrivacy: mobPriv,
      emailPrivacy: emPriv,
      addressPrivacy: addrPriv,
      guardianPrivacy: guardPriv,
      shareClassGroup: shareClass,
      showInMatrimony: (json['showInMatrimony'] ?? json['show_in_matrimony']) as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    final isBusinessGovPlaceholder = employmentType.contains('Business') &&
        (department.contains('Government') ||
         department.contains('સરકાર') ||
         department.contains('Select'));

    final map = <String, dynamic>{
      if (id.isNotEmpty && !id.startsWith('NEW')) 'id': id,
      'firstName': firstName.trim().isNotEmpty ? firstName.trim() : 'New',
      'lastName': lastName.trim().isNotEmpty ? lastName.trim() : 'User',
      if (photoUrl != null && photoUrl!.trim().isNotEmpty) 'photoUrl': photoUrl!.trim(),
      if (photos != null && photos!.isNotEmpty) 'photos': photos,
      if (idProofType != null && idProofType!.trim().isNotEmpty) 'idProofType': idProofType!.trim(),
      if (idProofFrontUrl != null && idProofFrontUrl!.trim().isNotEmpty) 'idProofFrontUrl': idProofFrontUrl!.trim(),
      if (idProofBackUrl != null && idProofBackUrl!.trim().isNotEmpty) 'idProofBackUrl': idProofBackUrl!.trim(),
      if (idProofNumber != null && idProofNumber!.trim().isNotEmpty) 'idProofNumber': idProofNumber!.trim(),
      'gender': normalizeGenderToApi(gender).isNotEmpty ? normalizeGenderToApi(gender) : 'MALE',
      'maritalStatus': normalizeMaritalStatusToApi(maritalStatus).isNotEmpty ? normalizeMaritalStatusToApi(maritalStatus) : 'NEVER_MARRIED',
      'dateOfBirth': dateOfBirth.trim().isNotEmpty ? dateOfBirth.trim() : '2000-01-01',
      if (education.trim().isNotEmpty && education != 'Select Degree') 'education': education.trim(),
      if (employmentType.trim().isNotEmpty) 'occupation': employmentType.trim(),
      if (department.trim().isNotEmpty && !isBusinessGovPlaceholder) 'organizationName': department.trim(),
      if (designation.trim().isNotEmpty) 'designation': designation.trim(),
      if (annualIncome != null && annualIncome!.trim().isNotEmpty && annualIncome != 'Select Income') 'annualIncome': annualIncome!.trim(),
      if (pargana.trim().isNotEmpty && pargana != 'Select Pargana') 'nativePlace': pargana.trim() else if (nativePlace != null && nativePlace!.trim().isNotEmpty) 'nativePlace': nativePlace!.trim(),
      if (taluka.trim().isNotEmpty) 'city': taluka.trim() else if (city != null && city!.trim().isNotEmpty) 'city': city!.trim(),
      if (district.trim().isNotEmpty) 'state': district.trim() else if (state != null && state!.trim().isNotEmpty) 'state': state!.trim(),
      'country': country?.trim().isNotEmpty == true ? country!.trim() : 'India',
      if (addressLine != null && addressLine!.trim().isNotEmpty) 'addressLine': addressLine!.trim(),
      if (pincode != null && pincode!.trim().isNotEmpty) 'pincode': pincode!.trim(),
      'isPhysicallyDisabled': isPhysicallyDisabled,
      if (pwbdCategory != null && pwbdCategory!.trim().isNotEmpty && !pwbdCategory!.contains('Select')) 'pwbdCategory': pwbdCategory!.trim(),
      'isAbroad': isAbroad,
      if (abroadCountry != null && abroadCountry!.trim().isNotEmpty && !abroadCountry!.contains('Select')) 'abroadCountry': abroadCountry!.trim(),
      if (businessIndustry != null && businessIndustry!.trim().isNotEmpty && !businessIndustry!.contains('Select')) 'businessIndustry': businessIndustry!.trim(),
      if (businessService != null && businessService!.trim().isNotEmpty && !businessService!.contains('Select')) 'businessService': businessService!.trim(),
      if (about != null && about!.trim().isNotEmpty) 'about': about!.trim(),
      if (religion != null && religion!.trim().isNotEmpty && religion != 'Select Religion') 'religion': religion!.trim(),
      if (caste != null && caste!.trim().isNotEmpty) 'caste': caste!.trim(),
      if (subcaste != null && subcaste!.trim().isNotEmpty) 'subcaste': subcaste!.trim(),
      if (bloodGroup != null && bloodGroup!.trim().isNotEmpty && !bloodGroup!.contains('Select')) 'bloodGroup': bloodGroup!.trim(),
      'isVankar': isVankar,
      if (motherTongue != null && motherTongue!.trim().isNotEmpty) 'motherTongue': motherTongue!.trim(),
      if (fatherName != null && fatherName!.trim().isNotEmpty) 'fatherName': fatherName!.trim(),
      if (fatherOccupation != null && fatherOccupation!.trim().isNotEmpty) 'fatherOccupation': fatherOccupation!.trim(),
      if (fatherContact != null && fatherContact!.trim().isNotEmpty) 'fatherContact': fatherContact!.trim(),
      if (motherName != null && motherName!.trim().isNotEmpty) 'motherName': motherName!.trim(),
      if (motherOccupation != null && motherOccupation!.trim().isNotEmpty) 'motherOccupation': motherOccupation!.trim(),
      if (guardianContact != null && guardianContact!.trim().isNotEmpty) 'guardianContact': guardianContact!.trim(),
      if (siblings != null && siblings!.trim().isNotEmpty) 'siblings': siblings!.trim(),
      if (mamasVillage != null && mamasVillage!.trim().isNotEmpty) 'mamasVillage': mamasVillage!.trim(),
      if (altPhone != null && altPhone!.trim().isNotEmpty) 'altPhone': altPhone!.trim(),
      if (contactPhone != null && contactPhone!.trim().isNotEmpty) 'contactPhone': contactPhone!.trim(),
      if (contactEmail != null && contactEmail!.trim().isNotEmpty) 'contactEmail': contactEmail!.trim(),
      if (privacySettings != null) 'privacySettings': privacySettings,
      if (mobilePrivacy != null) 'mobilePrivacy': mobilePrivacy,
      if (emailPrivacy != null) 'emailPrivacy': emailPrivacy,
      if (addressPrivacy != null) 'addressPrivacy': addressPrivacy,
      if (guardianPrivacy != null) 'guardianPrivacy': guardianPrivacy,
      'shareClassGroup': shareClassGroup,
      'showInMatrimony': showInMatrimony,
    };

    return map;
  }
}
