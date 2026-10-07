import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../../providers/profile_provider.dart';
import '../../../../shared/models/profile_model.dart';
import '../../../../shared/constants/gov_departments.dart';
import '../../providers/master_data_provider.dart';
import '../../../community/providers/samaj_services_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  Uint8List? _profileImageBytes;
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _profileImageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
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

  @override
  Widget build(BuildContext context) {
    final myProfileAsync = ref.watch(myProfileProvider);
    final masterData = ref.watch(masterDataProvider);
    final samajServicesAsync = ref.watch(samajServicesProvider);
    List<String> dynamicBusinessCategories = [];
    List<String> dynamicBusinessServices = [];

    samajServicesAsync.whenData((services) {
      dynamicBusinessCategories = services.map((e) => e.category).toSet().toList();
      String currentIndustry = _businessIndustry != 'Select Industry' ? _businessIndustry : (myProfileAsync.valueOrNull?.businessIndustry ?? 'Select Industry');
      if (currentIndustry != 'Select Industry') {
        dynamicBusinessServices = services
            .where((e) => e.category == currentIndustry)
            .map((e) => e.title)
            .toSet()
            .toList();
      }
    });

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
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo Upload Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300, width: 1.5),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
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
                            border: Border.all(color: Colors.grey.shade300, width: 2),
                          ),
                          child: ClipOval(
                            child: _profileImageBytes != null
                                ? Image.memory(
                                    _profileImageBytes!,
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                  )
                                : (profile.fullPhotoUrl != null
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
                                'Update Profile Photo (ફોટો બદલો)',
                                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'તમારો નવો પાસપોર્ટ સાઈઝ અથવા સુંદર પ્રોફાઈલ ફોટો અહીં અપલોડ કરો.',
                                style: TextStyle(color: Colors.black54, fontSize: 12),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: _pickImage,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFD4AF37)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                                icon: const Icon(Icons.cloud_upload, color: Color(0xFFD4AF37), size: 18),
                                label: const Text('Change Photo (ફોટો બદલો)', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
              _buildTextField('Mobile Number (મોબાઈલ નંબર - 10 અંક) *', 'Enter Mobile Number (મોબાઈલ નંબર - 10 અંક)', Icons.phone_android, initialValue: _mobileNumber ?? profile.contactPhone, onChanged: (v) => _mobileNumber = v),
              _buildTextField('Email Address (ઈમેઈલ સરનામું) *', 'Enter Email Address (ઈમેઈલ સરનામું)', Icons.email_outlined, initialValue: _emailAddress ?? profile.contactEmail, onChanged: (v) => _emailAddress = v),
              _buildTextField('WhatsApp / Alt Phone (વોટ્સએપ નંબર - 10 અંક)', 'Enter WhatsApp / Alt Phone...', Icons.chat_bubble_outline, initialValue: _whatsappNumber ?? profile.altPhone, onChanged: (v) => _whatsappNumber = v),

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
                ['Select Pargana', '7 Pargana (૭ પરગણા)', '22 Pargana (૨૨ પરગણા)', '24 Pargana / Chovisey (ચોવીસી)', '42 Pargana (૪૨ પરગણા)', 'Other (અન્ય)'],
                value: ['Select Pargana', '7 Pargana (૭ પરગણા)', '22 Pargana (૨૨ પરગણા)', '24 Pargana / Chovisey (ચોવીસી)', '42 Pargana (૪૨ પરગણા)', 'Other (અન્ય)'].contains(_pargana) ? _pargana : 'Select Pargana',
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
              _buildTextField('Pincode / Zip Code (પીનકોડ)', 'Enter Pincode / Zip Code (પીનકોડ)', Icons.markunread_mailbox_outlined, initialValue: _pincode ?? profile.pincode, onChanged: (v) => _pincode = v),

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
                _buildDropdownField(
                  'Business Industry / Category (વ્યવસાયનો પ્રકાર)',
                  'Select Industry',
                  Icons.storefront_outlined,
                  ['Select Industry', ...dynamicBusinessCategories],
                  value: dynamicBusinessCategories.contains(_businessIndustry) ? _businessIndustry : (profile.businessIndustry != null && dynamicBusinessCategories.contains(profile.businessIndustry) ? profile.businessIndustry : 'Select Industry'),
                  onChanged: (v) => setState(() {
                    _businessIndustry = v ?? 'Select Industry';
                    _businessService = 'Select Service';
                  }),
                ),
                if ((_businessIndustry != 'Select Industry' || profile.businessIndustry != null) && dynamicBusinessServices.isNotEmpty)
                  _buildDropdownField(
                    'Business Service / Title',
                    'Select Service',
                    Icons.store_outlined,
                    ['Select Service', ...dynamicBusinessServices],
                    value: dynamicBusinessServices.contains(_businessService) ? _businessService : (profile.businessService != null && dynamicBusinessServices.contains(profile.businessService) ? profile.businessService : 'Select Service'),
                    onChanged: (v) => setState(() => _businessService = v ?? 'Select Service'),
                  ),
                if (_businessIndustry == 'Select Industry' && profile.businessIndustry == null)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Text('Please wait while loading categories...'),
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
              _buildTextField('Father\'s Contact Number (પિતાનો ફોન નંબર - 10 અંક)', 'Enter Father\'s Contact Number...', Icons.phone, initialValue: _fatherContact ?? profile.fatherContact, onChanged: (v) => _fatherContact = v),
              _buildTextField('Mother\'s Name (માતાનું નામ) *', 'Enter Mother\'s Name (માતાનું નામ)', Icons.face_3_outlined, initialValue: _motherName ?? profile.motherName, onChanged: (v) => _motherName = v),
              _buildTextField('Mother\'s Occupation (માતાનો વ્યવસાય)', 'Enter Mother\'s Occupation (માતાનો વ્યવસાય)', Icons.work_outline, initialValue: _motherOccupation ?? profile.motherOccupation, onChanged: (v) => _motherOccupation = v),
              _buildTextField('Guardian Contact Number (વાલીનો સંપર્ક નંબર - 10 અંક)', 'Enter Guardian Contact Number...', Icons.contact_phone_outlined, initialValue: _guardianContact ?? profile.guardianContact, onChanged: (v) => _guardianContact = v),
              _buildTextField('Brothers & Sisters (ભાઈ-બહેનની વિગત)', 'Enter Brothers & Sisters (ભાઈ-બહેનની વિગત)', Icons.groups_outlined, initialValue: _siblings ?? profile.siblings, onChanged: (v) => _siblings = v),
              _buildTextField('Mama\'s Village / Mosal (મોસાળ / મોસાળનું ગામ)', 'Enter Mama\'s Village / Mosal...', Icons.holiday_village_outlined, initialValue: _mamasVillage ?? profile.mamasVillage, onChanged: (v) => _mamasVillage = v),
              _buildTextField('Native Place (મૂળ વતન / પરગણું)', 'Enter Native Place (મૂળ વતન / પરગણું)', Icons.home_work_outlined, initialValue: _nativePlace ?? (profile.nativePlace ?? profile.pargana), onChanged: (v) => _nativePlace = v),

              const SizedBox(height: 24),
              // About Me Section
              _buildSectionHeader(Icons.info_outline, 'About Me (પોતાના વિશે વિશેષ માહિતી)'),
              const SizedBox(height: 16),
              _buildTextField('Tell us about yourself (વધારાની વિગતો)', 'Enter Tell us about yourself (વધારાની વિગતો)', Icons.notes, isMultiline: true, initialValue: _aboutMe ?? profile.about, onChanged: (v) => _aboutMe = v),

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
                    if (_education != 'Select Degree') updateData['education'] = _education;
                    if (_employmentType != 'Select Sector') updateData['occupation'] = _employmentType;
                    if (_department != 'Select Department') updateData['organizationName'] = _department;
                    if (_pargana != 'Select Pargana') updateData['nativePlace'] = _pargana;
                    if (_yearlyIncome != 'Select Income') updateData['annualIncome'] = _yearlyIncome;
                    if (_employmentType.contains('Business')) {
                      updateData['businessIndustry'] = _businessIndustry != 'Select Industry' ? _businessIndustry : profile.businessIndustry;
                      updateData['businessService'] = _businessService != 'Select Service' ? _businessService : profile.businessService;
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

                    if (_profileImageBytes != null) {
                      final dio = ref.read(apiClientProvider);
                      String? uploadedUrl;
                      
                      // Strategy 1: Base64 JSON upload (extremely reliable across all proxies/platforms)
                      try {
                        final base64String = base64Encode(_profileImageBytes!);
                        final uploadRes = await dio.post(
                          '/storage/upload',
                          data: {
                            'base64': base64String,
                            'filename': 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
                            'mimetype': 'image/jpeg',
                          },
                        );
                        if (uploadRes.data != null && uploadRes.data['url'] != null) {
                          uploadedUrl = uploadRes.data['url'] as String;
                        }
                      } catch (base64Err) {
                        debugPrint('Base64 upload attempt error: $base64Err');
                      }

                      // Strategy 2: Multipart fallback if Strategy 1 did not set uploadedUrl
                      if (uploadedUrl == null) {
                        try {
                          final formData = FormData.fromMap({
                            'file': MultipartFile.fromBytes(
                              _profileImageBytes!,
                              filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
                            ),
                          });
                          final uploadRes = await dio.post('/storage/upload', data: formData);
                          if (uploadRes.data != null && uploadRes.data['url'] != null) {
                            uploadedUrl = uploadRes.data['url'] as String;
                          }
                        } catch (multipartErr) {
                          debugPrint('Multipart upload fallback error: $multipartErr');
                        }
                      }

                      if (uploadedUrl != null) {
                        updateData['photoUrl'] = uploadedUrl.startsWith('http')
                            ? uploadedUrl
                            : 'https://allgujaratvankarsamaj.com$uploadedUrl';
                      }
                    }

                    // Fallback to profile values if creating a new profile and fields were untouched
                    if (profile.id == 'NEW') {
                       updateData['firstName'] ??= profile.firstName;
                       updateData['lastName'] ??= profile.lastName;
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
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
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

  Widget _buildTextField(String label, String hint, IconData prefixIcon, {bool isDropdown = false, bool isMultiline = false, void Function(String)? onChanged, bool readOnly = false, VoidCallback? onTap, String? initialValue}) {
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
}
