import 'package:flutter/material.dart';
import '../../../../shared/models/profile_model.dart';
import '../../../../core/config/app_config.dart';

class FamilyModel {
  final String id;
  final String nameGuj;
  final String nameEng;
  final String surname;
  final String cityGuj;
  final String cityEng;
  final String details;
  final String? headName;
  final String? headNameGuj;
  final String? mosal;
  final String? nativePlace;
  final String? pargana;
  final String? district;
  final String? taluka;
  final String? fatherName;
  final String? fatherOccupation;
  final String? fatherContact;
  final String? motherName;
  final String? motherOccupation;
  final String? guardianContact;
  final String? siblings;
  final String? address;
  final String? pincode;
  final String? candidateName;
  final String? candidateGender;
  final int? candidateAge;
  final String? candidateEducation;
  final String? candidateOccupation;
  final String? candidateId;
  final String? photoUrl;
  final bool isVerified;
  final bool isLiveMember;
  final IconData icon;

  const FamilyModel({
    required this.id,
    required this.nameGuj,
    required this.nameEng,
    required this.surname,
    required this.cityGuj,
    required this.cityEng,
    required this.details,
    this.headName,
    this.headNameGuj,
    this.mosal,
    this.nativePlace,
    this.pargana,
    this.district,
    this.taluka,
    this.fatherName,
    this.fatherOccupation,
    this.fatherContact,
    this.motherName,
    this.motherOccupation,
    this.guardianContact,
    this.siblings,
    this.address,
    this.pincode,
    this.candidateName,
    this.candidateGender,
    this.candidateAge,
    this.candidateEducation,
    this.candidateOccupation,
    this.candidateId,
    this.photoUrl,
    this.isVerified = false,
    this.isLiveMember = false,
    this.icon = Icons.home,
  });

  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    String rawSurname = (json['surname'] ?? json['nameEng']?.toString().replaceAll(' Family', '') ?? 'Vankar').toString().trim();
    String rawNameGuj = (json['nameGuj'] ?? '').toString().trim();
    String? headName = json['headName']?.toString().trim();
    String? headNameGuj = json['headNameGuj']?.toString().trim();

    // Clean up compound names if not yet split
    if (rawSurname.contains(' ')) {
      final parts = rawSurname.split(RegExp(r'\s+'));
      rawSurname = parts.last;
      if (headName == null || headName.isEmpty) {
        headName = parts.sublist(0, parts.length - 1).join(' ');
      }
    }
    if (rawSurname.isEmpty) rawSurname = 'Vankar';

    final surnameGuj = translateSurnameToGuj(rawSurname);
    if (headName != null && headName.isNotEmpty && (headNameGuj == null || headNameGuj.isEmpty)) {
      headNameGuj = translateGivenNameToGuj(headName);
    }

    // Fix incorrect 'વાંકર' in incoming nameGuj to 'વણકર'
    if (rawNameGuj.isNotEmpty) {
      rawNameGuj = rawNameGuj.replaceAll('વાંકર', 'વણકર');
    }
    final nameGuj = rawNameGuj.isNotEmpty ? rawNameGuj : '$surnameGuj પરિવાર';
    final nameEng = (headName != null && headName.isNotEmpty) ? '$headName $rawSurname Family' : '$rawSurname Family';

    final mosalVal = json['mosal']?.toString() ?? 'Gujarat';
    final detailsVal = json['details']?.toString() ?? 'મોસાળ: $mosalVal | Masal: $mosalVal';

    return FamilyModel(
      id: json['id']?.toString() ?? '',
      nameGuj: nameGuj,
      nameEng: json['nameEng']?.toString() ?? nameEng,
      surname: rawSurname,
      headName: headName,
      headNameGuj: headNameGuj,
      cityGuj: json['cityGuj']?.toString() ?? 'ગુજરાત',
      cityEng: json['cityEng']?.toString() ?? 'Gujarat',
      details: detailsVal,
      mosal: json['mosal']?.toString(),
      nativePlace: json['nativePlace']?.toString(),
      pargana: json['pargana']?.toString(),
      district: json['district']?.toString(),
      taluka: json['taluka']?.toString(),
      fatherName: json['fatherName']?.toString(),
      fatherOccupation: json['fatherOccupation']?.toString(),
      fatherContact: json['fatherContact']?.toString(),
      motherName: json['motherName']?.toString(),
      motherOccupation: json['motherOccupation']?.toString(),
      guardianContact: json['guardianContact']?.toString(),
      siblings: json['siblings']?.toString(),
      address: json['address']?.toString(),
      pincode: json['pincode']?.toString(),
      candidateName: json['candidateName']?.toString(),
      candidateGender: json['candidateGender']?.toString(),
      candidateAge: json['candidateAge'] is int ? json['candidateAge'] as int : int.tryParse(json['candidateAge']?.toString() ?? ''),
      candidateEducation: json['candidateEducation']?.toString(),
      candidateOccupation: json['candidateOccupation']?.toString(),
      candidateId: json['candidateId']?.toString() ?? json['id']?.toString(),
      photoUrl: AppConfig.resolveMediaUrl(json['photoUrl']?.toString()),
      isVerified: json['isVerified'] == true,
      isLiveMember: true,
      icon: _iconForSurname(rawSurname),
    );
  }

  factory FamilyModel.fromProfile(ProfileModel p) {
    String rawLast = p.lastName.trim();
    String rawFirst = p.firstName.trim();
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

    final surnameGuj = translateSurnameToGuj(surnameEng);
    final headNameGuj = headNameEng.isNotEmpty ? translateGivenNameToGuj(headNameEng) : '';

    final nameGuj = '$surnameGuj પરિવાર';
    final nameEng = headNameEng.isNotEmpty ? '$headNameEng $surnameEng Family' : '$surnameEng Family';

    final cityEng = p.city != null && p.city!.isNotEmpty ? p.city! : (p.district.isNotEmpty ? p.district : 'Gujarat');
    final cityGuj = translateCityToGuj(cityEng);
    final mosalVal = (p.mamasVillage != null && p.mamasVillage!.isNotEmpty)
        ? p.mamasVillage!
        : (p.nativePlace != null && p.nativePlace!.isNotEmpty ? p.nativePlace! : 'Gujarat');
    final detailsStr = 'મોસાળ: $mosalVal | Masal: $mosalVal';

    return FamilyModel(
      id: p.id,
      nameGuj: nameGuj,
      nameEng: nameEng,
      surname: surnameEng,
      headName: headNameEng,
      headNameGuj: headNameGuj,
      cityGuj: cityGuj,
      cityEng: cityEng,
      details: detailsStr,
      mosal: p.mamasVillage ?? p.nativePlace,
      nativePlace: p.nativePlace ?? cityEng,
      pargana: p.pargana.isNotEmpty ? p.pargana : null,
      district: p.district.isNotEmpty ? p.district : null,
      taluka: p.taluka.isNotEmpty ? p.taluka : null,
      fatherName: p.fatherName,
      fatherOccupation: p.fatherOccupation,
      fatherContact: p.fatherContact ?? p.altPhone,
      motherName: p.motherName,
      motherOccupation: p.motherOccupation,
      guardianContact: p.guardianContact,
      siblings: p.siblings,
      address: p.addressLine,
      pincode: p.pincode,
      candidateName: p.fullName,
      candidateGender: p.gender,
      candidateAge: p.age,
      candidateEducation: p.education,
      candidateOccupation: p.designation.isNotEmpty ? p.designation : p.employmentType,
      candidateId: p.id,
      photoUrl: AppConfig.resolveMediaUrl(p.photoUrl),
      isVerified: p.isVerified ?? false,
      isLiveMember: true,
      icon: _iconForSurname(surnameEng),
    );
  }

  static IconData _iconForSurname(String surname) {
    final s = surname.toLowerCase();
    if (s.contains('kapadiya')) return Icons.home;
    if (s.contains('vankar')) return Icons.location_city;
    if (s.contains('solanki')) return Icons.people;
    if (s.contains('chauhan')) return Icons.group;
    if (s.contains('patel')) return Icons.person;
    if (s.contains('parmar')) return Icons.family_restroom;
    if (s.contains('makwana')) return Icons.account_balance;
    if (s.contains('rathod')) return Icons.villa;
    return Icons.holiday_village;
  }

  static bool isGujaratiScript(String text) {
    return RegExp(r'[\u0A80-\u0AFF]').hasMatch(text);
  }

  static String translateSurnameToGuj(String surname) {
    if (surname.trim().isEmpty) return 'વણકર';
    final trimmed = surname.trim();
    if (isGujaratiScript(trimmed)) return trimmed;

    final map = {
      'kapadiya': 'કપડિયા',
      'kapadia': 'કપડિયા',
      'vankar': 'વણકર',
      'bunkar': 'વણકર',
      'banker': 'વણકર',
      'sutariya': 'સુતરિયા',
      'sutaria': 'સુતરિયા',
      'solanki': 'સોલંકી',
      'chauhan': 'ચૌહાણ',
      'patel': 'પટેલ',
      'parmar': 'પરમાર',
      'makwana': 'મકવાણા',
      'rathod': 'રાઠોડ',
      'jadav': 'જાદવ',
      'vaghela': 'વાઘેલા',
      'gohel': 'ગોહેલ',
      'chavda': 'ચાવડા',
      'maru': 'મારુ',
      'dabhi': 'ડાભી',
      'rohit': 'રોહિત',
      'shrimali': 'શ્રીમાળી',
      'baraiya': 'બારૈયા',
      'tank': 'ટાંક',
      'bhati': 'ભાટી',
      'vegda': 'વેગડા',
      'purani': 'પુરાણી',
      'maheria': 'મહેરિયા',
      'rentiya': 'રેંટિયા',
      'patil': 'પાટીલ',
      'prajapati': 'પ્રજાપતિ',
      'raval': 'રાવળ',
      'darji': 'દરજી',
      'shah': 'શાહ',
      'pandya': 'પંડ્યા',
      'dave': 'દવે',
      'chudasama': 'ચુડાસમા',
      'mori': 'મોરી',
      'zala': 'ઝાલા',
      'jhala': 'ઝાલા',
      'koli': 'કોળી',
      'nayak': 'નાયક',
      'someshwar': 'સોમેશ્વર',
      'maheshwari': 'મહેશ્વરી',
      'khant': 'ખાંટ',
      'pandav': 'પાંડવ',
      'desai': 'દેસાઈ',
      'mehta': 'મહેતા',
      'trivedi': 'ત્રિવેદી',
      'bhatt': 'ભટ્ટ',
      'borisagar': 'બોરીસાગર',
      'dudhrejia': 'દુધરેજીયા',
      'vadhel': 'વાઢેલ',
      'danidhariya': 'દાણીધારિયા',
      'motavaras': 'મોટાવારસ',
      'chaudhari': 'ચૌધરી',
      'choudhary': 'ચૌધરી',
      'tadvi': 'તડવી',
      'gamit': 'ગામીત',
      'vasava': 'વસાવા',
    };
    final s = trimmed.toLowerCase();
    for (final k in map.keys) {
      if (s.contains(k)) return map[k]!;
    }
    return trimmed;
  }

  static String translateGivenNameToGuj(String name) {
    if (name.trim().isEmpty) return '';
    final trimmed = name.trim();
    if (isGujaratiScript(trimmed)) return trimmed;

    final s = trimmed.toLowerCase();

    final map = {
      'karasanbhai': 'કરશનભાઈ',
      'karsanbhai': 'કરશનભાઈ',
      'karshanbhai': 'કરશનભાઈ',
      'keshavlal': 'કેશવલાલ',
      'vijaykumar': 'વિજયકુમાર',
      'vasantbhai': 'વસંતભાઈ',
      'parvindar': 'પરવિંદર',
      'parvinder': 'પરવિંદર',
      'rameshbhai': 'રમેશભાઈ',
      'sureshbhai': 'સુરેશભાઈ',
      'dineshbhai': 'દિનેશભાઈ',
      'maheshbhai': 'મહેશભાઈ',
      'nareshbhai': 'નરેશભાઈ',
      'bharatbhai': 'ભરતભાઈ',
      'pravinbhai': 'પ્રવીણભાઈ',
      'mukeshbhai': 'મુકેશભાઈ',
      'hiteshbhai': 'હિતેશભાઈ',
      'pankajbhai': 'પંકજભાઈ',
      'rajeshbhai': 'રાજેશભાઈ',
      'jagdishbhai': 'જગદીશભાઈ',
      'ashokbhai': 'અશોકભાઈ',
      'kantilal': 'કાંતિલાલ',
      'mohanlal': 'મોહનલાલ',
      'chhaganlal': 'છગનલાલ',
      'govindbhai': 'ગોવિંદભાઈ',
      'manishbhai': 'મનીષભાઈ',
      'sanjaybhai': 'સંજયભાઈ',
      'bipinbhai': 'બિપીનભાઈ',
      'kamleshbhai': 'કમલેશભાઈ',
      'jayantibhai': 'જયંતિભાઈ',
      'shantilal': 'શાંતિલાલ',
      'babubhai': 'બાબુભાઈ',
      'laljibhai': 'લાલજીભાઈ',
      'amrutbhai': 'અમૃતભાઈ',
      'naranbhai': 'નારણભાઈ',
      'bhikhabhai': 'ભીખાભાઈ',
    };

    for (final k in map.keys) {
      if (s.contains(k)) return map[k]!;
    }
    return trimmed;
  }

  static String translateCityToGuj(String city) {
    final map = {
      'ahmedabad': 'અમદાવાદ',
      'surat': 'સુરત',
      'vadodara': 'વડોદરા',
      'rajkot': 'રાજકોટ',
      'bhavnagar': 'ભાવનગર',
      'jamnagar': 'જામનગર',
      'junagadh': 'જૂનાગઢ',
      'gandhinagar': 'ગાંધીનગર',
      'himatnagar': 'હિંમતનગર',
      'himmatnagar': 'હિંમતનગર',
      'kaniyol': 'કાનિયોલ',
      'jadar': 'જાદર',
      'patan': 'પાટણ',
      'mehsana': 'મહેસાણા',
      'idar': 'ઈડર',
      'unjha': 'ઊંઝા',
      'navsari': 'નવસારી',
      'anand': 'આણંદ',
      'nadiad': 'નડિયાદ',
      'bharuch': 'ભરૂચ',
      'valsad': 'વલસાડ',
      'kutch': 'કચ્છ',
      'bhuj': 'ભુજ',
      'surendranagar': 'સુરેન્દ્રનગર',
      'morbi': 'મોરબી',
      'amreli': 'અમરેલી',
      'porbandar': 'પોરબંદર',
      'palanpur': 'પાલનપુર',
      'godhra': 'ગોધરા',
    };
    if (isGujaratiScript(city)) return city;
    final c = city.toLowerCase();
    for (final k in map.keys) {
      if (c.contains(k)) return map[k]!;
    }
    return city;
  }

  static const List<FamilyModel> curatedSampleFamilies = [
    FamilyModel(
      id: 'fam_101',
      nameGuj: 'કપડીયા પરિવાર',
      nameEng: 'Kapadiya Family',
      surname: 'Kapadiya',
      cityGuj: 'હિંમતનગર',
      cityEng: 'Himatnagar',
      details: 'મોસાળ: ઈડર | Masal: Idar',
      mosal: 'ઈડર (Idar)',
      nativePlace: 'હિંમતનગર (Himatnagar)',
      pargana: 'સાબરકાંઠા ચોવીસી',
      district: 'Sabarkantha (સાબરકાંઠા)',
      taluka: 'Himatnagar',
      fatherName: 'કાંતિલાલ એમ. કપડીયા',
      fatherOccupation: 'નિવૃત્ત શિક્ષક (Retd. Teacher)',
      fatherContact: '+91 94280 11223',
      motherName: 'હંસાબેન કે. કપડીયા',
      motherOccupation: 'ગૃહિણી (Home Maker)',
      guardianContact: '+91 94280 11223',
      siblings: '૧ ભાઈ (એન્જિનિયર), ૧ બહેન (પરિણિત)',
      address: '૧૨, શિવમ્ બંગલોઝ, મહાવીરનગર, હિંમતનગર - ૩૮૩૦૦૧',
      candidateName: 'ભાર્ગવ કે. કપડીયા',
      candidateEducation: 'B.E. Computer Engineering',
      candidateOccupation: 'સોફ્ટવેર ડેવલપર',
      isVerified: true,
      icon: Icons.home,
    ),
    FamilyModel(
      id: 'fam_102',
      nameGuj: 'વણકર પરિવાર',
      nameEng: 'Vankar Family',
      surname: 'Vankar',
      cityGuj: 'અમદાવાદ',
      cityEng: 'Ahmedabad',
      details: 'મોસાળ: મહેસાણા | Masal: Mehsana',
      mosal: 'મહેસાણા (Mehsana)',
      nativePlace: 'સાણંદ (Sanand)',
      pargana: 'અમદાવાદ ૩૫ પરગણા',
      district: 'Ahmedabad (અમદાવાદ)',
      taluka: 'Sanand',
      fatherName: 'રમેશભાઈ પી. વણકર',
      fatherOccupation: 'સિનિયર એકાઉન્ટન્ટ (Senior Accountant)',
      fatherContact: '+91 98251 33445',
      motherName: 'સવિતાબેન આર. વણકર',
      motherOccupation: 'ગૃહિણી (Home Maker)',
      guardianContact: '+91 98251 33445',
      siblings: '૧ ભાઈ (TCS સોફ્ટવેર એન્જિનિયર)',
      address: '૪૫, વંદેમાતરમ્ સિટી, ચાંદલોડિયા, અમદાવાદ - ૩૮૨૪૮૧',
      candidateName: 'જિજ્ઞેશ આર. વણકર',
      candidateEducation: 'M.Sc. IT & Cloud Architect',
      candidateOccupation: 'ટેક્નિકલ લીડ',
      isVerified: true,
      icon: Icons.location_city,
    ),
    FamilyModel(
      id: 'fam_103',
      nameGuj: 'સોલંકી પરિવાર',
      nameEng: 'Solanki Family',
      surname: 'Solanki',
      cityGuj: 'પાટણ',
      cityEng: 'Patan',
      details: 'મોસાળ: ઊંઝા | Masal: Unjha',
      mosal: 'ઊંઝા (Unjha)',
      nativePlace: 'સિદ્ધપુર (Sidhpur)',
      pargana: 'પાટણ ચોવીસી',
      district: 'Patan (પાટણ)',
      taluka: 'Sidhpur',
      fatherName: 'દિનેશભાઈ બી. સોલંકી',
      fatherOccupation: 'વેપારી (Textile Business)',
      fatherContact: '+91 98790 55667',
      motherName: 'ગીતાબેન ડી. સોલંકી',
      motherOccupation: 'ગૃહિણી (Home Maker)',
      guardianContact: '+91 98790 55667',
      siblings: '૨ ભાઈઓ (સ્વરોજગાર)',
      address: '૭૮, આનંદનગર સોસાયટી, રેલવે સ્ટેશન પાસે, પાટણ - ૩૮૪૨૬૫',
      candidateName: 'પ્રતિક ડી. સોલંકી',
      candidateEducation: 'M.B.A. Finance',
      candidateOccupation: 'બેંક મેનેજર',
      isVerified: true,
      icon: Icons.people,
    ),
    FamilyModel(
      id: 'fam_104',
      nameGuj: 'ચૌહાણ પરિવાર',
      nameEng: 'Chauhan Family',
      surname: 'Chauhan',
      cityGuj: 'સુરત',
      cityEng: 'Surat',
      details: 'મોસાળ: નવસારી | Masal: Navsari',
      mosal: 'નવસારી (Navsari)',
      nativePlace: 'ઓલપાડ (Olpad)',
      pargana: 'સુરત ચોવીસી',
      district: 'Surat (સુરત)',
      taluka: 'Choryasi',
      fatherName: 'નરેશભાઈ જે. ચૌહાણ',
      fatherOccupation: 'કન્સ્ટ્રક્શન કોન્ટ્રાક્ટર',
      fatherContact: '+91 99099 77889',
      motherName: 'રેખાબેન એન. ચૌહાણ',
      motherOccupation: 'ગૃહિણી (Home Maker)',
      guardianContact: '+91 99099 77889',
      siblings: '૧ બહેન (પરિણિત - બારડોલી)',
      address: 'બી-૩૦૨, સનશાઇન રેસિડેન્સી, અડાજણ, સુરત - ૩૯૫૦૦૯',
      candidateName: 'અંકિત એન. ચૌહાણ',
      candidateEducation: 'B.Tech Civil Engineering',
      candidateOccupation: 'પ્રોજેક્ટ મેનેજર',
      isVerified: true,
      icon: Icons.group,
    ),
    FamilyModel(
      id: 'fam_105',
      nameGuj: 'પટેલ પરિવાર',
      nameEng: 'Patel Family',
      surname: 'Patel',
      cityGuj: 'રાજકોટ',
      cityEng: 'Rajkot',
      details: 'મોસાળ: ભાવનગર | Masal: Bhavnagar',
      mosal: 'ભાવનગર (Bhavnagar)',
      nativePlace: 'ગોંડલ (Gondal)',
      pargana: 'સૌરાષ્ટ્ર ૧૨ ગામ',
      district: 'Rajkot (રાજકોટ)',
      taluka: 'Gondal',
      fatherName: 'મહેન્દ્રભાઈ ડી. પટેલ',
      fatherOccupation: 'ઓટોમોબાઇલ પાર્ટ્સ ડીલર',
      fatherContact: '+91 98242 88990',
      motherName: 'મીનાબેન એમ. પટેલ',
      motherOccupation: 'ગૃહિણી (Home Maker)',
      guardianContact: '+91 98242 88990',
      siblings: '૧ ભાઈ, ૧ બહેન',
      address: 'પ્લોટ નં. ૧૫, સરદારનગર, રૈયા રોડ, રાજકોટ - ૩૬૦૦૦૭',
      candidateName: 'ચિરાગ એમ. પટેલ',
      candidateEducation: 'M.Com, C.A. Inter',
      candidateOccupation: 'ચીફ એકાઉન્ટન્ટ',
      isVerified: true,
      icon: Icons.person,
    ),
    FamilyModel(
      id: 'fam_106',
      nameGuj: 'પરમાર પરિવાર',
      nameEng: 'Parmar Family',
      surname: 'Parmar',
      cityGuj: 'વડોદરા',
      cityEng: 'Vadodara',
      details: 'મોસાળ: આણંદ | Masal: Anand',
      mosal: 'આણંદ (Anand)',
      nativePlace: 'કરજણ (Karjan)',
      pargana: 'વડોદરા ચોવીસી',
      district: 'Vadodara (વડોદરા)',
      taluka: 'Karjan',
      fatherName: 'ભીખાભાઈ એસ. પરમાર',
      fatherOccupation: 'સરકારી અધિકારી (GEB Retd.)',
      fatherContact: '+91 98799 44332',
      motherName: 'મંજુલાબેન બી. પરમાર',
      motherOccupation: 'ગૃહિણી',
      guardianContact: '+91 98799 44332',
      siblings: '૨ બહેનો (પરિણિત)',
      address: '૧૫, યોગીનગર સોસાયટી, કારેલીબાગ, વડોદરા - ૩૯૦૦૧૮',
      candidateName: 'ડો. પ્રિયંકા બી. પરમાર',
      candidateEducation: 'M.B.B.S., M.D.',
      candidateOccupation: 'તબીબ / ફિઝિશિયન',
      isVerified: true,
      icon: Icons.family_restroom,
    ),
  ];
}
