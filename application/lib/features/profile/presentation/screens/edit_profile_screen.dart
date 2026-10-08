import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../../providers/profile_provider.dart';
import '../../../../shared/models/profile_model.dart';
import '../../../../shared/constants/gov_departments.dart';
import '../../providers/master_data_provider.dart';
import '../../../community/providers/samaj_services_provider.dart';
import '../../../../shared/models/samaj_service.dart';
import '../../../../shared/widgets/samaj_service_picker_sheet.dart';
import '../../../../shared/constants/pargana_constants.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  Uint8List? _profileImageBytes;
  List<String> _existingPhotoUrls = [];
  final List<Uint8List> _newGalleryPhotosBytes = [];
  String _idProofType = 'Aadhaar Card (આધાર કાર્ડ)';
  String? _existingIdFrontUrl;
  String? _existingIdBackUrl;
  Uint8List? _idFrontBytes;
  Uint8List? _idBackBytes;
  final List<String> _idProofOptions = [
    'Aadhaar Card (આધાર કાર્ડ)',
    'PAN Card (પાન કાર્ડ)',
    'Voter ID Card (ચૂંટણી કાર્ડ)',
    'Driving License (ડ્રાઇવિંગ લાઇસન્સ)',
    'Passport (પાસપોર્ટ)',
    'Other Govt ID (અન્ય સરકારી ઓળખપત્ર)',
  ];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        if (bytes.length > 5 * 1024 * 1024) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('પ્રોફાઇલ ફોટો સાઈઝ 5 MB કરતાં ઓછી હોવી જોઈએ (Profile photo must be under 5 MB)'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        setState(() {
          _profileImageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Error picking profile image: $e');
    }
  }

  String _education = 'Select Degree';
  String _customEducation = '';
  String _employmentType = 'Government Sector (સરકારી નોકરી / સેકટર)';
  String _department = 'State Government (રાજ્ય સરકાર)';
  String _govCategory = 'Select Category';
  String _customGovCategory = '';
  String _businessIndustry = 'Select Industry';
  String _businessService = 'Select Service';
  String _yearlyIncome = 'Select Income';
  String _pargana = 'Select Pargana';
  String? _gender;
  String? _maritalStatus;
  String? _bloodGroup;
  String? _isVankar;
  String? _casteCategory;
  String? _dob;
  String _religion = 'Select Religion';
  bool _isPhysicallyDisabled = false;
  String? _pwbdCategory;
  bool _isAbroad = false;
  String? _abroadCountry;
  bool _isInitialized = false;
  
  String? _firstName;
  String? _lastName;
  String? _mobileNumber;
  String? _emailAddress;
  String? _whatsappNumber;
  String? _houseNumber;
  String? _area;
  String? _city;
  String? _district;
  String? _country;
  String? _pincode;
  String? _companyName;
  String? _designation;
  String? _fatherName;
  String? _fatherOccupation;
  String? _fatherContact;
  String? _motherName;
  String? _motherOccupation;
  String? _guardianContact;
  String? _siblings;
  String? _mamasVillage;
  String? _nativePlace;
  String? _aboutMe;

  Future<void> _pickGalleryPhotos() async {
    final totalPhotos = _existingPhotoUrls.length + _newGalleryPhotosBytes.length;
    if (totalPhotos >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('તમે વધુમાં વધુ ૫ ફોટા ઉમેરી શકો છો (Maximum 5 candidate photos allowed)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        int skippedTooLarge = 0;
        for (final file in pickedFiles) {
          if (_existingPhotoUrls.length + _newGalleryPhotosBytes.length >= 5) break;
          final bytes = await file.readAsBytes();
          if (bytes.length > 5 * 1024 * 1024) {
            skippedTooLarge++;
            continue;
          }
          _newGalleryPhotosBytes.add(bytes);
        }
        setState(() {});
        if (skippedTooLarge > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$skippedTooLarge ફોટો 5 MB કરતાં મોટો હોવાથી રદ કરવામાં આવ્યો (Images > 5 MB were skipped)'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        final XFile? single = await _picker.pickImage(source: ImageSource.gallery);
        if (single != null) {
          final bytes = await single.readAsBytes();
          if (bytes.length > 5 * 1024 * 1024) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ફોટો સાઈઝ 5 MB કરતાં ઓછી હોવી જોઈએ (Image must be under 5 MB)'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          if (_existingPhotoUrls.length + _newGalleryPhotosBytes.length < 5) {
            setState(() {
              _newGalleryPhotosBytes.add(bytes);
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking gallery photos: $e');
    }
  }

  void _removeExistingPhoto(int index) {
    if (index >= 0 && index < _existingPhotoUrls.length) {
      setState(() {
        _existingPhotoUrls.removeAt(index);
      });
    }
  }

  void _removeNewPhoto(int index) {
    if (index >= 0 && index < _newGalleryPhotosBytes.length) {
      setState(() {
        _newGalleryPhotosBytes.removeAt(index);
      });
    }
  }

  Future<void> _pickIdFront() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        if (bytes.length > 5 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ઓળખપત્રના આગળના ફોટાની સાઈઝ 5 MB કરતાં ઓછી હોવી જોઈએ (ID Front photo must be under 5 MB)'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        setState(() {
          _idFrontBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Error picking ID front image: $e');
    }
  }

  Future<void> _pickIdBack() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        if (bytes.length > 5 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ઓળખપત્રના પાછળના ફોટાની સાઈઝ 5 MB કરતાં ઓછી હોવી જોઈએ (ID Back photo must be under 5 MB)'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        setState(() {
          _idBackBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Error picking ID back image: $e');
    }
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD4AF37),
              onPrimary: Colors.black,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dob = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _openSamajServicePicker(
      BuildContext context, List<SamajService> services) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SamajServicePickerSheet(
        allServices: services,
        initialCategory:
            _businessIndustry != 'Select Industry' ? _businessIndustry : null,
        initialService:
            _businessService != 'Select Service' ? _businessService : null,
        onSelected: (cat, srv) {
          setState(() {
            _businessIndustry = cat;
            _businessService = srv;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myProfileAsync = ref.watch(myProfileProvider);
    final masterData = ref.watch(masterDataProvider);
    final samajServicesAsync = ref.watch(samajServicesProvider);
    final samajServicesList = samajServicesAsync.value ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light Background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Edit Profile (પ્રોફાઈલ સુધારો)',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: SafeArea(
        child: myProfileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
          error: (err, stack) => Center(child: Text('Failed to load profile details: $err')),
          data: (profile) {
            if (!_isInitialized && profile.id != 'NEW') {
              _isInitialized = true;
              _gender = profile.displayGender;
              _maritalStatus = ProfileModel.normalizeMaritalStatusToDisplay(profile.maritalStatus);
              _bloodGroup = profile.bloodGroup;
              _isVankar = profile.isVankar == true ? 'Yes (હા)' : 'No (ના)';
              _religion = (profile.religion != null && profile.religion!.isNotEmpty) ? profile.religion! : 'Hindu (હિન્દુ)';
              _casteCategory = profile.caste;
              _dob = profile.dateOfBirth;
              _isPhysicallyDisabled = profile.isPhysicallyDisabled ?? false;
              _pwbdCategory = profile.pwbdCategory;
              _isAbroad = profile.isAbroad ?? false;
              _abroadCountry = profile.abroadCountry;
              _firstName = profile.firstName;
              _lastName = profile.lastName;
              _mobileNumber = profile.contactPhone;
              _emailAddress = profile.contactEmail;
              _whatsappNumber = profile.altPhone;
              _houseNumber = profile.addressLine;
              _city = profile.taluka;
              _district = profile.district;
              _country = profile.country ?? 'India';
              _pincode = profile.pincode;
              _pargana = profile.pargana.isNotEmpty ? profile.pargana : 'Select Pargana';
              _nativePlace = profile.nativePlace;
              _education = profile.education.isNotEmpty ? profile.education : 'Select Degree';
              _employmentType = profile.employmentType.isNotEmpty ? profile.employmentType : 'Government Sector (સરકારી નોકરી / સેકટર)';
              _department = profile.department;
              _companyName = profile.department;
              _businessIndustry = (profile.businessIndustry != null && profile.businessIndustry!.isNotEmpty) ? profile.businessIndustry! : 'Select Industry';
              _businessService = (profile.businessService != null && profile.businessService!.isNotEmpty) ? profile.businessService! : 'Select Service';
              _designation = profile.designation;
              _yearlyIncome = profile.annualIncome ?? 'Select Income';
              _fatherName = profile.fatherName;
              _fatherOccupation = profile.fatherOccupation;
              _fatherContact = profile.fatherContact;
              _motherName = profile.motherName;
              _motherOccupation = profile.motherOccupation;
              _guardianContact = profile.guardianContact;
              _siblings = profile.siblings;
              _mamasVillage = profile.mamasVillage;
              _aboutMe = profile.about;

              if (profile.photos != null && profile.photos!.isNotEmpty) {
                _existingPhotoUrls = List.from(profile.photos!);
              } else if (profile.fullPhotoUrl != null) {
                _existingPhotoUrls = [profile.fullPhotoUrl!];
              }
              _existingIdFrontUrl = profile.idProofFrontUrl;
              _existingIdBackUrl = profile.idProofBackUrl;
              if (profile.idProofType != null && profile.idProofType!.isNotEmpty) {
                _idProofType = profile.idProofType!;
              }
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Profile Photo Card (Top)
                  _buildMainPhotoUpload(profile),
                  const SizedBox(height: 24),

                  // Personal Details Section
                  _buildSectionHeader(Icons.person_outline, 'Personal Details (અંગત માહિતી)'),
                  const SizedBox(height: 16),
                  _buildTextField('First Name (પ્રથમ નામ) *', 'Enter First Name (પ્રથમ નામ)', Icons.badge_outlined, initialValue: _firstName ?? profile.firstName, onChanged: (v) => _firstName = v),
                  _buildTextField('Last Name (અટક / ઉપનામ) *', 'Enter Last Name (અટક / ઉપનામ)', Icons.badge_outlined, initialValue: _lastName ?? profile.lastName, onChanged: (v) => _lastName = v),
              _buildTextField(
                'Date of Birth *',
                _dob ?? (profile.dateOfBirth.isNotEmpty ? profile.dateOfBirth : 'Tap to select date of birth'),
                Icons.cake_outlined,
                isDropdown: true,
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              _buildDropdownField(
                'Gender (જાતિ) *',
                'Male (પુરુષ)',
                Icons.people_alt_outlined,
                ['Male (પુરુષ)', 'Female (સ્ત્રી)'],
                value: _gender ?? profile.displayGender,
                onChanged: (v) => setState(() => _gender = v),
              ),
              _buildDropdownField(
                'Marital Status (વૈવાહિક સ્થિતિ) *',
                'Never Married (અપરિણીત)',
                Icons.favorite_border,
                ['Never Married (અપરિણીત)', 'Married (પરિણીત)', 'Divorced (છૂટાછેડા લીધેલ)', 'Widowed (વિધવા / વિધુર)', 'Awaiting Divorce (છૂટાછેડાની રાહમાં)'],
                value: _maritalStatus ?? ProfileModel.normalizeMaritalStatusToDisplay(profile.maritalStatus),
                onChanged: (v) => setState(() => _maritalStatus = v),
              ),
              _buildDropdownField(
                'Blood Group (બ્લડ ગ્રુપ)',
                'Select Blood Group',
                Icons.water_drop_outlined,
                ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Don\'t Know (ખબર નથી)'],
                value: _bloodGroup ?? profile.bloodGroup,
                onChanged: (v) => setState(() => _bloodGroup = v),
              ),
              _buildDropdownField(
                'Are you Vankar? (તમે વણકર છો?) *',
                'Yes (હા)',
                Icons.verified_user_outlined,
                ['Yes (હા)', 'No (ના)'],
                value: _isVankar ?? (profile.isVankar == true ? 'Yes (હા)' : 'No (ના)'),
                onChanged: (v) => setState(() => _isVankar = v),
              ),
              _buildDropdownField(
                'Physically Disabled? (શું તમે શારીરિક રીતે દિવ્યાંગ છો?) *',
                'No (ના)',
                Icons.accessible_outlined,
                ['Yes (હા)', 'No (ના)'],
                value: _isPhysicallyDisabled ? 'Yes (હા)' : 'No (ના)',
                onChanged: (v) => setState(() {
                  _isPhysicallyDisabled = v == 'Yes (હા)';
                  if (!_isPhysicallyDisabled) _pwbdCategory = null;
                }),
              ),
              if (_isPhysicallyDisabled)
                _buildDropdownField(
                  'PwBD Category (દિવ્યાંગતાનો પ્રકાર) *',
                  'Select Category',
                  Icons.wheelchair_pickup_outlined,
                  [
                    'VI - Visual Impairment (દૃષ્ટિ દિવ્યાંગતા)',
                    'HI - Hearing Impairment (શ્રવણ દિવ્યાંગતા)',
                    'LD - Locomotor Disability (હલનચલન સંબંધિત દિવ્યાંગતા)',
                    'MD - Multiple Disabilities (બહુવિધ દિવ્યાંગતા)',
                    'B - Blindness (અંધત્વ)',
                    'LV - Low Vision (ઓછી દૃષ્ટિ)',
                    'D - Deaf (બહેરાશ)',
                    'HH - Hard of Hearing (સાંભળવામાં તકલીફ)',
                    'OA - One Arm Affected (એક હાથથી દિવ્યાંગતા)',
                    'OL - One Leg Affected (એક પગથી દિવ્યાંગતા)',
                    'BA - Both Arms Affected (બંને હાથથી દિવ્યાંગતા)',
                    'BL - Both Legs Affected (બંને પગથી દિવ્યાંગતા)',
                    'OAL - One Arm and One Leg Affected (એક હાથ અને એક પગથી દિવ્યાંગતા)',
                    'CP - Cerebral Palsy (સેરેબ્રલ પાલ્સી)',
                  ],
                  value: _pwbdCategory ?? profile.pwbdCategory,
                  onChanged: (v) => setState(() => _pwbdCategory = v),
                ),
              _buildDropdownField(
                'Religion (ધર્મ) *',
                'Select Religion (ધર્મ પસંદ કરો)',
                Icons.settings_brightness,
                masterData.religionOptions,
                value: masterData.religionOptions.contains(_religion) ? _religion : (masterData.religionOptions.contains(profile.religion) ? profile.religion : 'Select Religion'),
                onChanged: (v) => setState(() => _religion = v ?? 'Select Religion'),
              ),
              _buildDropdownField(
                'Caste Category (જ્ઞાતિ પસંદ કરો) *',
                'Hindu-vankar (હિન્દુ-વણકર)',
                Icons.groups_outlined,
                ['Hindu-Vankar (હિન્દુ-વણકર)', 'Buddhist-Vankar (બૌદ્ધ-વણકર)', 'Christian-Vankar (ખ્રિસ્તી-વણકર)', 'Muslim-Vankar (મુસ્લિમ-વણકર)', 'Other (અન્ય)'],
                value: _casteCategory ?? profile.caste,
                onChanged: (v) => setState(() => _casteCategory = v),
              ),

              const SizedBox(height: 24),
              // Contact Details Section
              _buildSectionHeader(Icons.phone_android, 'Contact Details (સંપર્ક માહિતી)'),
              const SizedBox(height: 16),
              _buildTextField(
                'Mobile Number (મોબાઈલ નંબર - 10 અંક) *',
                'Enter 10-digit Mobile Number',
                Icons.phone_android,
                initialValue: _mobileNumber ?? profile.contactPhone,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: (v) => _mobileNumber = v,
              ),
              _buildTextField(
                'Email Address (ઈમેઈલ સરનામું) *',
                'Enter Email Address (ઈમેઈલ સરનામું)',
                Icons.email_outlined,
                initialValue: _emailAddress ?? profile.contactEmail,
                keyboardType: TextInputType.emailAddress,
                onChanged: (v) => _emailAddress = v,
              ),
              _buildTextField(
                'WhatsApp / Alt Phone (વોટ્સએપ નંબર - 10 અંક)',
                'Enter 10-digit WhatsApp / Alt Phone...',
                Icons.chat_bubble_outline,
                initialValue: _whatsappNumber ?? profile.altPhone,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: (v) => _whatsappNumber = v,
              ),

              const SizedBox(height: 24),
              // Location & Address Section
              _buildSectionHeader(Icons.location_on_outlined, 'Location & Address (રહેઠાણનું સરનામું)'),
              const SizedBox(height: 16),
              _buildTextField('Flat / House / Building Name & No. (મકાન / બિલ્ડિંગ નંબર)', 'Enter Flat / House / Building Name & No...', Icons.domain, initialValue: _houseNumber ?? profile.addressLine, onChanged: (v) => _houseNumber = v),
              _buildTextField('Area / Society / Landmark (સોસાયટી / વિસ્તાર / લેન્ડમાર્ક)', 'Enter Area / Society / Landmark...', Icons.explore_outlined, initialValue: _area, onChanged: (v) => _area = v),
              _buildTextField('City / Taluka (શહેર / તાલુકો) *', 'Enter City / Taluka (શહેર / તાલુકો)', Icons.location_city, initialValue: _city ?? profile.taluka, onChanged: (v) => _city = v),
              _buildTextField('District & State (જિલ્લો અને રાજ્ય) *', 'Enter District & State (જિલ્લો અને રાજ્ય)', Icons.map_outlined, initialValue: _district ?? profile.district, onChanged: (v) => _district = v),
              _buildDropdownField(
                'Which Pargana you have? (તમારું પરગણું કયું છે?) *', 
                'Select Pargana', 
                Icons.account_tree_outlined, 
                kParganaOptions,
                value: kParganaOptions.contains(_pargana) 
                    ? _pargana 
                    : (kParganaOptions.any((e) => e.contains(_pargana)) 
                        ? kParganaOptions.firstWhere((e) => e.contains(_pargana)) 
                        : 'Select Pargana'),
                onChanged: (v) => setState(() => _pargana = v ?? _pargana),
              ),
              _buildDropdownField('Are you studying or living abroad? (શું તમે વિદેશમાં અભ્યાસ કરો છો કે રહો છો?) *', 'No (ના)', Icons.flight_takeoff, ['Yes (હા)', 'No (ના)'], value: _isAbroad ? 'Yes (હા)' : 'No (ના)', onChanged: (v) => setState(() {
                _isAbroad = v == 'Yes (હા)';
                if (!_isAbroad) _abroadCountry = null;
              })),
              if (_isAbroad)
                _buildDropdownField(
                  'In which country? (કયા દેશમાં?) *',
                  'Select Country (દેશ પસંદ કરો)',
                  Icons.public,
                  masterData.abroadCountries,
                  value: masterData.abroadCountries.contains(_abroadCountry) ? _abroadCountry : 'Select Country (દેશ પસંદ કરો)',
                  onChanged: (v) => setState(() => _abroadCountry = v),
                ),
              _buildTextField('Country (દેશ) *', 'Enter Country (દેશ)', Icons.public, initialValue: _country ?? profile.country, onChanged: (v) => _country = v),
              _buildTextField(
                'Pincode / Zip Code (પીનકોડ - 6 અંક)',
                'Enter 6-digit Pincode',
                Icons.markunread_mailbox_outlined,
                initialValue: _pincode ?? profile.pincode,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: (v) => _pincode = v,
              ),

              const SizedBox(height: 24),
              // Career & Employment Details Section
              _buildSectionHeader(Icons.work_outline, 'Career & Employment Details (શિક્ષણ, વ્યવસાય અને નોકરીની વિગત)'),
              const SizedBox(height: 16),
              _buildDropdownField(
                'Education / Degree (અભ્યાસ / ડિગ્રી) *',
                'Select Degree',
                Icons.school_outlined,
                masterData.educationDegrees,
                value: masterData.educationDegrees.contains(_education) ? _education : 'Select Degree',
                onChanged: (v) => setState(() => _education = v ?? 'Select Degree'),
              ),
              if (_education == 'Other Qualification (અન્ય)')
                _buildTextField(
                  'Custom Education / Degree (અન્ય અભ્યાસ / ડિગ્રી)',
                  'Enter your education/degree manually',
                  Icons.school,
                  onChanged: (v) => setState(() => _customEducation = v),
                ),
              _buildDropdownField(
                'Employment Type / Work Sector (નોકરી / વ્યવસાય...)', 
                'Government Sector (સરકારી નોકરી / સેકટર)', 
                Icons.work_outline, 
                ['Government Sector (સરકારી નોકરી / સેકટર)', 'Private Sector (ખાનગી નોકરી / સેકટર)', 'Business / Self-Employed (વ્યવસાય / સ્વરોજગાર)', 'Not Working (કોઈ નોકરી નથી)'],
                value: _employmentType,
                onChanged: (v) => setState(() => _employmentType = v ?? _employmentType),
              ),
              if (_employmentType.contains('Government')) ...[
                _buildDropdownField(
                  'Government Department / Service', 
                  'Select Department', 
                  Icons.account_balance_outlined, 
                  ['State Government (રાજ્ય સરકાર)', 'Central Government (કેન્દ્ર સરકાર)', 'Public Sector (જાહેર ક્ષેત્ર)', 'Other (અન્ય)'],
                  value: ['State Government (રાજ્ય સરકાર)', 'Central Government (કેન્દ્ર સરકાર)', 'Public Sector (જાહેર ક્ષેત્ર)', 'Other (અન્ય)'].contains(_department) ? _department : 'State Government (રાજ્ય સરકાર)',
                  onChanged: (v) => setState(() {
                    _department = v ?? 'State Government (રાજ્ય સરકાર)';
                    _govCategory = 'Select Category';
                  }),
                ),
                if (_department == 'State Government (રાજ્ય સરકાર)')
                  _buildDropdownField(
                    'Gujarat Government Category',
                    'Select Category',
                    Icons.account_balance,
                    GovDepartments.gujaratGov,
                    value: GovDepartments.gujaratGov.contains(_govCategory) ? _govCategory : 'Select Category',
                    onChanged: (v) => setState(() => _govCategory = v ?? 'Select Category'),
                  ),
                if (_department == 'Central Government (કેન્દ્ર સરકાર)')
                  _buildDropdownField(
                    'Central Government Category',
                    'Select Category',
                    Icons.account_balance,
                    GovDepartments.centralGov,
                    value: GovDepartments.centralGov.contains(_govCategory) ? _govCategory : 'Select Category',
                    onChanged: (v) => setState(() => _govCategory = v ?? 'Select Category'),
                  ),
                if ((_department == 'State Government (રાજ્ય સરકાર)' || _department == 'Central Government (કેન્દ્ર સરકાર)') && _govCategory == 'Other (અન્ય)')
                  _buildTextField(
                    'Other Government Category (અન્ય સરકારી નોકરીનો પ્રકાર)',
                    'Enter your category manually',
                    Icons.account_balance,
                    onChanged: (v) => setState(() => _customGovCategory = v),
                  ),
              ],
              if (_employmentType.contains('Private')) ...[
                _buildDropdownField(
                  'Private Sector Industry / Category (ખાનગી નોકરીનો પ્રકાર)',
                  'Select Industry',
                  Icons.business_center_outlined,
                  masterData.privateSectors,
                  value: masterData.privateSectors.contains(_govCategory) ? _govCategory : 'Select Category',
                  onChanged: (v) => setState(() => _govCategory = v ?? 'Select Category'),
                ),
                _buildTextField(
                  'Company Name (કંપનીનું નામ)',
                  'Enter Company Name',
                  Icons.business_outlined,
                  initialValue: profile.department,
                  onChanged: (v) => setState(() => _companyName = v),
                ),
              ],
              if (_employmentType.contains('Business')) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Business & Samaj Service (વ્યવસાય / સમાજ સેવા) *',
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _openSamajServicePicker(
                            context, samajServicesList),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _businessService != 'Select Service'
                                  ? const Color(0xFF1D4ED8)
                                  : Colors.grey.shade300,
                              width: _businessService != 'Select Service'
                                  ? 1.5
                                  : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: _businessService != 'Select Service'
                                      ? const Color(0xFFEFF6FF)
                                      : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  _businessService != 'Select Service'
                                      ? Icons.storefront_rounded
                                      : Icons.search_rounded,
                                  color: const Color(0xFFD4AF37),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _businessService != 'Select Service'
                                          ? _businessService
                                          : 'સમાજ સેવા પસંદ કરો (Select Service)',
                                      style: TextStyle(
                                        color: _businessService != 'Select Service'
                                            ? Colors.black87
                                            : Colors.black45,
                                        fontSize: 15,
                                        fontWeight:
                                            _businessService != 'Select Service'
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                      ),
                                    ),
                                    if (_businessIndustry !=
                                        'Select Industry') ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        _businessIndustry,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _businessService != 'Select Service'
                                      ? 'બદલો (Change)'
                                      : 'શોધો (Browse)',
                                  style: const TextStyle(
                                    color: Color(0xFF1D4ED8),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildTextField(
                  'Company / Shop Name (પેઢી / દુકાનનું નામ)',
                  'Enter Shop or Business Name (દા.ત. શ્રી ગણેશ ટ્રેડિંગ)',
                  Icons.store_outlined,
                  initialValue: _companyName ?? profile.department,
                  onChanged: (v) => setState(() => _companyName = v),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Color(0xFF92400E), size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'તમારો વ્યવસાય તમારા સંપર્ક નંબર સાથે આપમેળે "સમાજ સર્વિસીસ" ડિરેક્ટરીમાં ઉમેરાઈ જશે જેથી સમાજના લોકો તમારો સંપર્ક કરી શકે.',
                          style: TextStyle(
                            color: Color(0xFF92400E),
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              _buildTextField('Designation / Detailed Occupation (હોદ્દો / વ્યવસાય વિગત) *', 'Enter Designation / Detailed Occupation...', Icons.badge_outlined, initialValue: profile.designation, onChanged: (v) => _designation = v),
              _buildDropdownField(
                'Yearly Income (વાર્ષિક આવક - રૂ.)',
                'Select Income (વાર્ષિક આવક પસંદ કરો)',
                Icons.payments_outlined,
                masterData.incomeRanges,
                value: masterData.incomeRanges.contains(_yearlyIncome) ? _yearlyIncome : 'Select Income',
                onChanged: (v) => setState(() => _yearlyIncome = v ?? 'Select Income'),
              ),

              const SizedBox(height: 24),
              // Family Details Section
              _buildSectionHeader(Icons.family_restroom, 'Family Details (પરિવારની વિગતો અને વાલીનો સંપર્ક)'),
              const SizedBox(height: 16),
              _buildTextField('Father\'s Name (પિતાનું નામ) *', 'Enter Father\'s Name (પિતાનું નામ)', Icons.person_outline, initialValue: _fatherName ?? profile.fatherName, onChanged: (v) => _fatherName = v),
              _buildTextField('Father\'s Occupation (પિતાનો વ્યવસાય)', 'Enter Father\'s Occupation (પિતાનો વ્યવસાય)', Icons.work_outline, initialValue: _fatherOccupation ?? profile.fatherOccupation, onChanged: (v) => _fatherOccupation = v),
              _buildTextField(
                'Father\'s Contact Number (પિતાનો ફોન નંબર - 10 અંક)',
                'Enter 10-digit Father\'s Contact Number...',
                Icons.phone,
                initialValue: _fatherContact ?? profile.fatherContact,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: (v) => _fatherContact = v,
              ),
              _buildTextField('Mother\'s Name (માતાનું નામ) *', 'Enter Mother\'s Name (માતાનું નામ)', Icons.face_3_outlined, initialValue: _motherName ?? profile.motherName, onChanged: (v) => _motherName = v),
              _buildTextField('Mother\'s Occupation (માતાનો વ્યવસાય)', 'Enter Mother\'s Occupation (માતાનો વ્યવસાય)', Icons.work_outline, initialValue: _motherOccupation ?? profile.motherOccupation, onChanged: (v) => _motherOccupation = v),
              _buildTextField(
                'Guardian Contact Number (વાલીનો સંપર્ક નંબર - 10 અંક)',
                'Enter 10-digit Guardian Contact Number...',
                Icons.contact_phone_outlined,
                initialValue: _guardianContact ?? profile.guardianContact,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: (v) => _guardianContact = v,
              ),
              _buildTextField('Brothers & Sisters (ભાઈ-બહેનની વિગત)', 'Enter Brothers & Sisters (ભાઈ-બહેનની વિગત)', Icons.groups_outlined, initialValue: _siblings ?? profile.siblings, onChanged: (v) => _siblings = v),
              _buildTextField('Mama\'s Village / Mosal (મોસાળ / મોસાળનું ગામ)', 'Enter Mama\'s Village / Mosal...', Icons.holiday_village_outlined, initialValue: _mamasVillage ?? profile.mamasVillage, onChanged: (v) => _mamasVillage = v),
              _buildTextField('Native Place (મૂળ વતન / પરગણું)', 'Enter Native Place (મૂળ વતન / પરગણું)', Icons.home_work_outlined, initialValue: _nativePlace ?? (profile.nativePlace ?? profile.pargana), onChanged: (v) => _nativePlace = v),

              const SizedBox(height: 24),
              // About Me Section
              _buildSectionHeader(Icons.info_outline, 'About Me (પોતાના વિશે વિશેષ માહિતી)'),
              const SizedBox(height: 16),
              _buildTextField('Tell us about yourself (વધારાની વિગતો)', 'Enter Tell us about yourself (વધારાની વિગતો)', Icons.notes, isMultiline: true, initialValue: _aboutMe ?? profile.about, onChanged: (v) => _aboutMe = v),

              const SizedBox(height: 28),
              // Box 1: Multiple Candidate Photos (2 to 5 images) - Bottom
              _buildCandidatePhotosBox(),
              const SizedBox(height: 20),

              // Box 2: ID Proof Verification (Front & Back Mandatory) - Bottom
              _buildIdProofBox(),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: () async {
                  try {
                    final updateData = <String, dynamic>{};
                    final selectedGender = _gender ?? profile.displayGender;
                    updateData['gender'] = ProfileModel.normalizeGenderToApi(selectedGender);
                    if (_maritalStatus != null) updateData['maritalStatus'] = ProfileModel.normalizeMaritalStatusToApi(_maritalStatus);
                    if (_casteCategory != null) updateData['caste'] = _casteCategory;
                    if (_dob != null) updateData['dateOfBirth'] = _dob;
                    if (_religion != 'Select Religion') updateData['religion'] = _religion;
                    if (_bloodGroup != null && _bloodGroup != 'Select Blood Group') updateData['bloodGroup'] = _bloodGroup;
                    if (_isVankar != null) updateData['isVankar'] = _isVankar == 'Yes (હા)';
                    if (_education != 'Select Degree') {
                      updateData['education'] = (_education.contains('Other') && _customEducation.isNotEmpty) ? _customEducation : _education;
                    }
                    if (_employmentType != 'Select Sector') updateData['occupation'] = _employmentType;
                    if (_department != 'Select Department') {
                      updateData['organizationName'] = (_govCategory != 'Select Category' && _govCategory.contains('Other') && _customGovCategory.isNotEmpty)
                          ? _customGovCategory
                          : _department;
                    }
                    if (_pargana != 'Select Pargana') updateData['nativePlace'] = _pargana;
                    if (_yearlyIncome != 'Select Income') updateData['annualIncome'] = _yearlyIncome;
                    if (_employmentType.contains('Business')) {
                      updateData['businessIndustry'] = _businessIndustry != 'Select Industry' ? _businessIndustry : profile.businessIndustry;
                      updateData['businessService'] = _businessService != 'Select Service' ? _businessService : profile.businessService;
                      if (_companyName != null && _companyName!.isNotEmpty) {
                        updateData['organizationName'] = _companyName;
                      }
                    }
                    if (_employmentType.contains('Private')) {
                      updateData['organizationName'] = _companyName ?? profile.department;
                    }

                    if (_firstName != null) updateData['firstName'] = _firstName;
                    if (_lastName != null) updateData['lastName'] = _lastName;
                    if (_city != null) updateData['city'] = _city;
                    if (_district != null) updateData['state'] = _district;
                    if (_nativePlace != null) updateData['nativePlace'] = _nativePlace;
                    if (_designation != null) updateData['designation'] = _designation;
                    if (_country != null) updateData['country'] = _country;
                    if (_houseNumber != null) updateData['addressLine'] = _houseNumber;
                    if (_pincode != null) updateData['pincode'] = _pincode;
                    if (_mobileNumber != null) updateData['contactPhone'] = _mobileNumber;
                    if (_whatsappNumber != null) updateData['altPhone'] = _whatsappNumber;
                    if (_emailAddress != null) updateData['contactEmail'] = _emailAddress;
                    if (_fatherName != null) updateData['fatherName'] = _fatherName;
                    if (_fatherOccupation != null) updateData['fatherOccupation'] = _fatherOccupation;
                    if (_fatherContact != null) updateData['fatherContact'] = _fatherContact;
                    if (_motherName != null) updateData['motherName'] = _motherName;
                    if (_motherOccupation != null) updateData['motherOccupation'] = _motherOccupation;
                    if (_guardianContact != null) updateData['guardianContact'] = _guardianContact;
                    if (_siblings != null) updateData['siblings'] = _siblings;
                    if (_mamasVillage != null) updateData['mamasVillage'] = _mamasVillage;
                    updateData['isPhysicallyDisabled'] = _isPhysicallyDisabled;
                    if (_pwbdCategory != null) updateData['pwbdCategory'] = _pwbdCategory;
                    updateData['isAbroad'] = _isAbroad;
                    if (_abroadCountry != null) updateData['abroadCountry'] = _abroadCountry;
                    if (_aboutMe != null) updateData['about'] = _aboutMe;

                    final totalPhotos = _existingPhotoUrls.length + _newGalleryPhotosBytes.length;
                    if (totalPhotos < 2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('કૃપા કરીને ઓછામાં ઓછા ૨ ઉમેદવારના ફોટા રાખો (Please maintain at least 2 candidate photos, maximum 5)'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    if (totalPhotos > 5) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ઉમેદવારના વધુમાં વધુ ૫ ફોટા માન્ય છે (Maximum 5 candidate photos allowed)'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final hasFront = _idFrontBytes != null || (_existingIdFrontUrl != null && _existingIdFrontUrl!.isNotEmpty);
                    final hasBack = _idBackBytes != null || (_existingIdBackUrl != null && _existingIdBackUrl!.isNotEmpty);
                    if (!hasFront && !hasBack) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('કૃપા કરીને $_idProofType ના આગળ અને પાછળ બંને ફોટા અપલોડ કરો (Both Front and Back photos required)'),
                          backgroundColor: Colors.red.shade700,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                      return;
                    }
                    if (!hasFront) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('કૃપા કરીને $_idProofType નો આગળનો ફોટો (Front Side) અપલોડ કરો (Front photo of $_idProofType is required)'),
                          backgroundColor: Colors.red.shade700,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                      return;
                    }
                    if (!hasBack) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('કૃપા કરીને $_idProofType નો પાછળનો ફોટો (Back Side) અપલોડ કરો (Back photo of $_idProofType is required)'),
                          backgroundColor: Colors.red.shade700,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                      return;
                    }

                    Future<String?> uploadBytes(Uint8List bytes, String filenamePrefix) async {
                      final dio = ref.read(apiClientProvider);
                      String? rawUrl;

                      // Strategy 1: Base64 JSON upload
                      try {
                        final base64String = base64Encode(bytes);
                        final uploadRes = await dio.post(
                          '/storage/upload',
                          data: {
                            'base64': base64String,
                            'filename': '${filenamePrefix}_${DateTime.now().millisecondsSinceEpoch}.jpg',
                            'mimetype': 'image/jpeg',
                          },
                        );
                        if (uploadRes.data != null && uploadRes.data['url'] != null) {
                          rawUrl = uploadRes.data['url'] as String;
                        }
                      } catch (base64Err) {
                        debugPrint('Base64 upload attempt error for $filenamePrefix: $base64Err');
                      }

                      // Strategy 2: Multipart fallback
                      if (rawUrl == null) {
                        try {
                          final formData = FormData.fromMap({
                            'file': MultipartFile.fromBytes(
                              bytes,
                              filename: '${filenamePrefix}_${DateTime.now().millisecondsSinceEpoch}.jpg',
                            ),
                          });
                          final uploadRes = await dio.post('/storage/upload', data: formData);
                          if (uploadRes.data != null && uploadRes.data['url'] != null) {
                            rawUrl = uploadRes.data['url'] as String;
                          }
                        } catch (multipartErr) {
                          debugPrint('Multipart upload fallback error for $filenamePrefix: $multipartErr');
                        }
                      }

                      if (rawUrl != null) {
                        return rawUrl.startsWith('http')
                            ? rawUrl
                            : 'https://allgujaratvankarsamaj.com$rawUrl';
                      }
                      return null;
                    }

                    // Upload new gallery photos
                    final List<String> allFinalPhotos = List.from(_existingPhotoUrls);
                    for (int i = 0; i < _newGalleryPhotosBytes.length; i++) {
                      final u = await uploadBytes(_newGalleryPhotosBytes[i], 'profile_gallery_new_$i');
                      if (u != null) {
                        allFinalPhotos.add(u);
                      }
                    }

                    // Upload ID proof front & back
                    String? finalIdFront = _existingIdFrontUrl;
                    if (_idFrontBytes != null) {
                      final u = await uploadBytes(_idFrontBytes!, 'id_proof_front');
                      if (u != null) finalIdFront = u;
                    }

                    String? finalIdBack = _existingIdBackUrl;
                    if (_idBackBytes != null) {
                      final u = await uploadBytes(_idBackBytes!, 'id_proof_back');
                      if (u != null) finalIdBack = u;
                    }

                    // Upload main profile photo if changed
                    if (_profileImageBytes != null) {
                      final u = await uploadBytes(_profileImageBytes!, 'profile_main');
                      if (u != null) {
                        updateData['photoUrl'] = u;
                        if (!allFinalPhotos.contains(u)) {
                          allFinalPhotos.insert(0, u);
                        }
                      }
                    } else if (allFinalPhotos.isNotEmpty) {
                      updateData['photoUrl'] = allFinalPhotos[0];
                    }

                    updateData['photos'] = allFinalPhotos;
                    if (updateData['photoUrl'] == null && allFinalPhotos.isNotEmpty) {
                      updateData['photoUrl'] = allFinalPhotos[0];
                    }
                    updateData['idProofType'] = _idProofType;
                    if (finalIdFront != null) updateData['idProofFrontUrl'] = finalIdFront;
                    if (finalIdBack != null) updateData['idProofBackUrl'] = finalIdBack;

                    // Fallback to profile values if creating a new profile and fields were untouched
                    if (profile.id == 'NEW') {
                       updateData['firstName'] ??= profile.firstName;
                       updateData['lastName'] ??= profile.lastName;
                    }
                    if (!context.mounted) return;
                    
                    final effectiveMobile = (_mobileNumber ?? profile.contactPhone ?? '').trim();
                    final effectiveEmail = (_emailAddress ?? profile.contactEmail ?? '').trim();
                    final effectiveAltPhone = (_whatsappNumber ?? profile.altPhone ?? '').trim();
                    final effectiveFatherPhone = (_fatherContact ?? profile.fatherContact ?? '').trim();
                    final effectiveGuardianPhone = (_guardianContact ?? profile.guardianContact ?? '').trim();
                    final effectivePincode = (_pincode ?? profile.pincode ?? '').trim();

                    if (effectiveMobile.isNotEmpty && !RegExp(r'^[6-9]\d{9}$').hasMatch(effectiveMobile)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('મોબાઇલ નંબર માન્ય 10 અંકનો હોવો જોઈએ (Mobile number must be a valid 10-digit number starting with 6-9)'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (effectiveEmail.isNotEmpty && !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(effectiveEmail)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('કૃપા કરીને માન્ય ઈમેઈલ સરનામું દાખલ કરો (Please enter a valid email address)'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (effectiveAltPhone.isNotEmpty && !RegExp(r'^[6-9]\d{9}$').hasMatch(effectiveAltPhone)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('વોટ્સએપ / વૈકલ્પિક મોબાઇલ નંબર માન્ય 10 અંકનો હોવો જોઈએ (WhatsApp/Alt phone must be 10 digits starting with 6-9)'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (effectiveFatherPhone.isNotEmpty && !RegExp(r'^[6-9]\d{9}$').hasMatch(effectiveFatherPhone)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('પિતાનો ફોન નંબર માન્ય 10 અંકનો હોવો જોઈએ (Father contact must be 10 digits starting with 6-9)'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (effectiveGuardianPhone.isNotEmpty && !RegExp(r'^[6-9]\d{9}$').hasMatch(effectiveGuardianPhone)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('વાલીનો સંપર્ક નંબર માન્ય 10 અંકનો હોવો જોઈએ (Guardian contact must be 10 digits starting with 6-9)'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (effectivePincode.isNotEmpty && !RegExp(r'^\d{6}$').hasMatch(effectivePincode)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('પીનકોડ બરાબર 6 અંકનો હોવો જોઈએ (Pincode must be exactly 6 digits)'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (updateData.isNotEmpty) {
                      if (profile.id == 'NEW') {
                        // Create new profile
                        if (updateData['firstName'] == null || updateData['firstName'].toString().trim().isEmpty) updateData['firstName'] = 'Vankar';
                        if (updateData['lastName'] == null || updateData['lastName'].toString().trim().isEmpty) updateData['lastName'] = 'Samaj';
                        final newProfile = ProfileModel.fromJson({'id': '', ...updateData});
                        await ref.read(profileRepositoryProvider).createProfile(newProfile);
                      } else {
                        await ref.read(profileRepositoryProvider).updateMyProfile(updateData);
                      }
                      ref.invalidate(myProfileProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved successfully')));
                      }
                    }

                    if (context.mounted && context.canPop()) {
                      context.pop();
                    }
                  } catch (e) {
                    if (context.mounted) {
                      String msg = e.toString();
                      if (e is DioException && e.response?.data != null) {
                        final data = e.response!.data;
                        if (data is Map && data['message'] != null) {
                          msg = data['message'] is List
                              ? (data['message'] as List).join('\n')
                              : data['message'].toString();
                        }
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(msg),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                child: const Text(
                  'Save Changes (સુધારો સાચવો)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    ),
  ),
);
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label, 
    String hint, 
    IconData prefixIcon, {
    bool isDropdown = false, 
    bool isMultiline = false, 
    void Function(String)? onChanged, 
    bool readOnly = false, 
    VoidCallback? onTap, 
    String? initialValue,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: TextFormField(
              initialValue: initialValue,
              maxLines: isMultiline ? 4 : 1,
              readOnly: readOnly,
              onTap: onTap,
              onChanged: onChanged,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: readOnly && hint != 'Tap to select date of birth' ? Colors.black87 : Colors.black38, fontSize: 14),
                prefixIcon: Icon(prefixIcon, color: const Color(0xFFD4AF37), size: 20),
                suffixIcon: isDropdown ? const Icon(Icons.arrow_drop_down, color: Colors.black54) : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, String hint, IconData prefixIcon, List<String> items, {String? value, void Function(String?)? onChanged}) {
    String? internalValue;
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  value: value ?? internalValue,
                  onChanged: (val) {
                    if (onChanged != null) {
                      onChanged(val);
                    } else {
                      setState(() {
                        internalValue = val;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(prefixIcon, color: Colors.black87, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  hint: Text(hint, style: const TextStyle(color: Colors.black38, fontSize: 14)),
                  isExpanded: true,
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  elevation: 8,
                  menuMaxHeight: 300,
                  iconEnabledColor: const Color(0xFFD4AF37),
                  style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),
                  items: items.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item, style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildMainPhotoUpload(ProfileModel profile) {
    final hasImg = _profileImageBytes != null || (profile.fullPhotoUrl != null && profile.fullPhotoUrl!.isNotEmpty);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasImg ? const Color(0xFFD4AF37) : Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              shape: BoxShape.circle,
              border: Border.all(
                color: hasImg ? const Color(0xFFD4AF37) : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: _profileImageBytes != null
                  ? Image.memory(
                      _profileImageBytes!,
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                    )
                  : (profile.fullPhotoUrl != null && profile.fullPhotoUrl!.isNotEmpty
                      ? Image.network(
                          profile.fullPhotoUrl!,
                          fit: BoxFit.cover,
                          width: 80,
                          height: 80,
                          errorBuilder: (ctx, err, st) =>
                              const Icon(Icons.add_a_photo, color: Colors.black54, size: 36),
                        )
                      : const Icon(Icons.add_a_photo, color: Colors.black54, size: 36)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profile Photo (પ્રોફાઈલ ફોટો)',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'તમારો મુખ્ય પાસપોર્ટ સાઈઝ અથવા સુંદર પ્રોફાઈલ ફોટો અહીં અપલોડ કરો (Max 5 MB).',
                  style: TextStyle(color: Colors.black54, fontSize: 11),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  icon: const Icon(Icons.cloud_upload_outlined, color: Color(0xFFD4AF37), size: 18),
                  label: Text(
                    hasImg ? 'Change Photo (ફોટો બદલો)' : 'Choose Photo (ફોટો પસંદ કરો)',
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidatePhotosBox() {
    final totalCount = _existingPhotoUrls.length + _newGalleryPhotosBytes.length;
    final isCountValid = totalCount >= 2 && totalCount <= 5;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCountValid ? const Color(0xFFD4AF37) : Colors.amber.shade400,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library_rounded, color: Color(0xFFD4AF37), size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Candidate Photos / ઉમેદવારના ફોટા (૨ થી ૫ ફોટો)',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'ઓછામાં ઓછા ૨ અને વધુમાં વધુ ૫ ફોટો (Min 2, Max 5 • Max 5 MB each)',
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isCountValid ? Colors.green.shade50 : Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isCountValid ? Colors.green.shade400 : Colors.amber.shade600,
                  ),
                ),
                child: Text(
                  '$totalCount / 5',
                  style: TextStyle(
                    color: isCountValid ? Colors.green.shade800 : Colors.amber.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Grid of existing + new photos
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              // 1. Existing photos from server
              for (int i = 0; i < _existingPhotoUrls.length; i++)
                Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: i == 0 ? const Color(0xFFD4AF37) : Colors.grey.shade300,
                          width: i == 0 ? 2 : 1,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(
                            _existingPhotoUrls[i].startsWith('http')
                                ? _existingPhotoUrls[i]
                                : 'https://allgujaratvankarsamaj.com${_existingPhotoUrls[i]}',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (i == 0)
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Main',
                            style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => _removeExistingPhoto(i),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                ),

              // 2. Newly added photos
              for (int i = 0; i < _newGalleryPhotosBytes.length; i++)
                Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        image: DecorationImage(
                          image: MemoryImage(_newGalleryPhotosBytes[i]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => _removeNewPhoto(i),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                ),

              // 3. Add button if < 5
              if (totalCount < 5)
                GestureDetector(
                  onTap: _pickGalleryPhotos,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD4AF37),
                        style: BorderStyle.solid,
                        width: 1.5,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, color: Color(0xFFD4AF37), size: 28),
                        SizedBox(height: 4),
                        Text(
                          '+ Add Photo',
                          style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            totalCount < 2
                ? '⚠️ હજી ઓછામાં ઓછો ${2 - totalCount} ફોટો ઉમેરવો જરૂરી છે. (Please add ${2 - totalCount} more photo)'
                : '✓ ફોટો બરાબર છે ($totalCount પસંદ કર્યા). તમે ઈચ્છો તો વધુ ${5 - totalCount} ઉમેરી શકો છો.',
            style: TextStyle(
              color: totalCount < 2 ? Colors.amber.shade900 : Colors.green.shade800,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdProofBox() {
    final hasFront = _idFrontBytes != null || (_existingIdFrontUrl != null && _existingIdFrontUrl!.isNotEmpty);
    final hasBack = _idBackBytes != null || (_existingIdBackUrl != null && _existingIdBackUrl!.isNotEmpty);
    final isBothUploaded = hasFront && hasBack;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBothUploaded ? Colors.green.shade500 : const Color(0xFF1E3A8A).withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isBothUploaded ? Colors.green.shade50 : const Color(0xFF1E3A8A).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isBothUploaded ? Icons.verified_user : Icons.badge_outlined,
                  color: isBothUploaded ? Colors.green.shade700 : const Color(0xFF1E3A8A),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ID Proof Verification (ઓળખપત્ર વેરિફિકેશન)',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'સરકારી ઓળખપત્રના આગળ અને પાછળ બંને ફોટા ફરજિયાત છે *',
                      style: TextStyle(
                        color: isBothUploaded ? Colors.green.shade700 : Colors.red.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isBothUploaded ? Colors.green.shade50 : (hasFront || hasBack ? Colors.orange.shade50 : Colors.red.shade50),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isBothUploaded ? Colors.green.shade400 : (hasFront || hasBack ? Colors.orange.shade400 : Colors.red.shade300),
                  ),
                ),
                child: Text(
                  isBothUploaded ? '✓ Completed' : (hasFront || hasBack ? '⚠️ 1/2 Uploaded' : 'Required *'),
                  style: TextStyle(
                    color: isBothUploaded ? Colors.green.shade800 : (hasFront || hasBack ? Colors.orange.shade900 : Colors.red.shade800),
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ID Type Dropdown Label
          const Text(
            'Select Document Type (ઓળખપત્રનો પ્રકાર) *',
            style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Dropdown Container with White Menu Background
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _idProofType,
                isExpanded: true,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
                elevation: 8,
                menuMaxHeight: 320,
                focusColor: Colors.transparent,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF1E3A8A), size: 24),
                style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600),
                items: _idProofOptions.map((opt) {
                  final isSelected = opt == _idProofType;
                  return DropdownMenuItem<String>(
                    value: opt,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF1E3A8A).withOpacity(0.1) : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            opt.contains('Aadhaar')
                                ? Icons.badge_outlined
                                : opt.contains('PAN')
                                    ? Icons.credit_card
                                    : opt.contains('Voter')
                                        ? Icons.how_to_vote_outlined
                                        : opt.contains('License')
                                            ? Icons.directions_car_outlined
                                            : opt.contains('Passport')
                                                ? Icons.flight_takeoff_outlined
                                                : Icons.assignment_ind_outlined,
                            size: 18,
                            color: isSelected ? const Color(0xFF1E3A8A) : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            opt,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? const Color(0xFF1E3A8A) : Colors.black87,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle, size: 18, color: Color(0xFF1E3A8A)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _idProofType = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Real-time Front & Back Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isBothUploaded
                  ? const Color(0xFFECFDF5)
                  : (hasFront || hasBack)
                      ? const Color(0xFFFFFBEB)
                      : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isBothUploaded
                    ? const Color(0xFF10B981)
                    : (hasFront || hasBack)
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFFCA5A5),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isBothUploaded
                      ? Icons.check_circle_rounded
                      : (hasFront || hasBack)
                          ? Icons.warning_amber_rounded
                          : Icons.info_outline_rounded,
                  color: isBothUploaded
                      ? const Color(0xFF059669)
                      : (hasFront || hasBack)
                          ? const Color(0xFFD97706)
                          : const Color(0xFFDC2626),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBothUploaded
                            ? '✓ ઓળખપત્ર વેરિફિકેશન પૂર્ણ (ID Proof Complete)'
                            : (!hasFront && !hasBack)
                                ? '⚠️ આગળ અને પાછળ બંને બાજુના ફોટા અપલોડ કરવા જરૂરી છે'
                                : (!hasFront)
                                    ? '⚠️ આગળનો ફોટો (Front Side) અપલોડ કરવાનો બાકી છે'
                                    : '⚠️ પાછળનો ફોટો (Back Side) અપલોડ કરવાનો બાકી છે',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isBothUploaded
                              ? const Color(0xFF065F46)
                              : (hasFront || hasBack)
                                  ? const Color(0xFF92400E)
                                  : const Color(0xFF991B1B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isBothUploaded
                            ? '$_idProofType ના આગળ અને પાછળ બંને બાજુના ફોટા અપલોડ થઈ ગયા છે.'
                            : (!hasFront && !hasBack)
                                ? 'કૃપા કરીને $_idProofType ના બંને ફોટા સ્પષ્ટ દેખાય તે રીતે અપલોડ કરો.'
                                : (!hasFront)
                                    ? 'કૃપા કરીને $_idProofType નો આગળનો ભાગ (Front Side) અપલોડ કરો.'
                                    : 'કૃપા કરીને $_idProofType નો પાછળનો ભાગ (Back Side) અપલોડ કરો.',
                        style: TextStyle(
                          fontSize: 11,
                          color: isBothUploaded
                              ? const Color(0xFF047857)
                              : (hasFront || hasBack)
                                  ? const Color(0xFFB45309)
                                  : const Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Two separate upload cards: Front & Back
          Row(
            children: [
              // Front side card
              Expanded(
                child: _buildIdCardSide(
                  title: 'Front Side (આગળનો ભાગ)',
                  sideLabel: 'આગળનો ફોટો (Front)',
                  imageBytes: _idFrontBytes,
                  existingUrl: _existingIdFrontUrl,
                  onPick: _pickIdFront,
                  onRemove: () => setState(() {
                    _idFrontBytes = null;
                    _existingIdFrontUrl = null;
                  }),
                ),
              ),
              const SizedBox(width: 12),
              // Back side card
              Expanded(
                child: _buildIdCardSide(
                  title: 'Back Side (પાછળનો ભાગ)',
                  sideLabel: 'પાછળનો ફોટો (Back)',
                  imageBytes: _idBackBytes,
                  existingUrl: _existingIdBackUrl,
                  onPick: _pickIdBack,
                  onRemove: () => setState(() {
                    _idBackBytes = null;
                    _existingIdBackUrl = null;
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIdCardSide({
    required String title,
    required String sideLabel,
    required Uint8List? imageBytes,
    required String? existingUrl,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    final hasImg = imageBytes != null || (existingUrl != null && existingUrl.isNotEmpty);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: hasImg ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasImg ? Colors.green.shade400 : Colors.red.shade200,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: hasImg ? Colors.green.shade800 : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: hasImg ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  hasImg ? '✓ Uploaded' : '* Required',
                  style: TextStyle(
                    color: hasImg ? Colors.green.shade900 : Colors.red.shade900,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onPick,
            child: Container(
              height: 115,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasImg ? Colors.green.shade300 : Colors.grey.shade300,
                ),
                image: imageBytes != null
                    ? DecorationImage(
                        image: MemoryImage(imageBytes),
                        fit: BoxFit.cover,
                      )
                    : (existingUrl != null && existingUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(
                              existingUrl.startsWith('http')
                                  ? existingUrl
                                  : 'https://allgujaratvankarsamaj.com$existingUrl',
                            ),
                            fit: BoxFit.cover,
                          )
                        : null),
              ),
              child: hasImg
                  ? Stack(
                      children: [
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: onRemove,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(7),
                                bottomRight: Radius.circular(7),
                              ),
                            ),
                            child: const Text(
                              '✓ બદલવા માટે ટેપ કરો (Change)',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_a_photo_outlined, color: Color(0xFF1E3A8A), size: 26),
                        const SizedBox(height: 4),
                        Text(
                          sideLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Max 5 MB',
                          style: TextStyle(fontSize: 9, color: Colors.black45),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
