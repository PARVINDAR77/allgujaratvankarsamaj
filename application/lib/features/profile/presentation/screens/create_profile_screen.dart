import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../../../shared/models/profile_model.dart';
import '../../../../shared/constants/gov_departments.dart';
import '../../../../shared/constants/app_data.dart';
import '../../providers/master_data_provider.dart';
import '../../../community/providers/samaj_services_provider.dart';

class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  ConsumerState<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  Uint8List? _profileImageBytes;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  String _firstName = '';
  String _lastName = '';
  String _education = 'Select Degree';
  String _customEducation = '';
  String _employmentType = 'Government Sector (સરકારી નોકરી / સેકટર)';
  String _department = 'State Government (રાજ્ય સરકાર)';
  String _govCategory = 'Select Category';
  String _customGovCategory = '';
  String _businessIndustry = 'Select Industry';
  String _businessService = 'Select Service';
  String _designation = '';
  String _yearlyIncome = 'Select Income';
  String _district = '';
  String _taluka = '';
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

  Future<void> _submitProfile() async {
    setState(() => _isSubmitting = true);

    String? uploadedPhotoUrl;
    if (_profileImageBytes != null) {
      final dio = ref.read(apiClientProvider);
      String? rawUrl;

      // Strategy 1: Base64 JSON upload
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
          rawUrl = uploadRes.data['url'] as String;
        }
      } catch (base64Err) {
        debugPrint('Base64 upload attempt error: $base64Err');
      }

      // Strategy 2: Multipart fallback
      if (rawUrl == null) {
        try {
          final formData = FormData.fromMap({
            'file': MultipartFile.fromBytes(
              _profileImageBytes!,
              filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
            ),
          });
          final uploadRes = await dio.post('/storage/upload', data: formData);
          if (uploadRes.data != null && uploadRes.data['url'] != null) {
            rawUrl = uploadRes.data['url'] as String;
          }
        } catch (multipartErr) {
          debugPrint('Multipart upload fallback error: $multipartErr');
        }
      }

      if (rawUrl != null) {
        uploadedPhotoUrl = rawUrl.startsWith('http')
            ? rawUrl
            : 'https://allgujaratvankarsamaj.com$rawUrl';
      }
    }

    final uniqueId = 'VNK${math.Random().nextInt(90000) + 10000}';
    final password = '${math.Random().nextInt(900000) + 100000}'; // 6 digit random pass

    final newProfile = ProfileModel(
      id: uniqueId,
      firstName: _firstName.isNotEmpty ? _firstName : 'New',
      lastName: _lastName.isNotEmpty ? _lastName : 'User',
      photoUrl: uploadedPhotoUrl,
      gender: ProfileModel.normalizeGenderToDisplay(_gender),
      maritalStatus: _maritalStatus ?? 'Never Married (અપરિણીત)',
      dateOfBirth: _dob ?? '2000-01-01',
      education: _education == 'Other Qualification (અન્ય)' ? _customEducation : (_education != 'Select Degree' ? _education : 'Not Specified'),
      employmentType: _employmentType,
      department: _employmentType.contains('Government')
          ? (_govCategory == 'Other (અન્ય)' ? _customGovCategory : (_govCategory != 'Select Category' ? _govCategory : _department))
          : _department,
      designation: _designation.isNotEmpty ? _designation : 'Employee',
      district: _district.isNotEmpty ? _district : 'Ahmedabad',
      taluka: _taluka.isNotEmpty ? _taluka : 'Ahmedabad City',
      pargana: _pargana != 'Select Pargana' ? _pargana : 'Not Specified',
      isPhysicallyDisabled: _isPhysicallyDisabled,
      pwbdCategory: _pwbdCategory,
      isAbroad: _isAbroad,
      abroadCountry: _abroadCountry,
      businessIndustry: _employmentType.contains('Business') ? (_businessIndustry == 'Select Industry' ? null : _businessIndustry) : null,
      businessService: _employmentType.contains('Business') ? (_businessService == 'Select Service' ? null : _businessService) : null,
    );

    try {
      final repository = ref.read(profileRepositoryProvider);
      await repository.createProfile(newProfile);
      ref.invalidate(myProfileProvider);
      await ref.read(authNotifierProvider.notifier).checkVerificationStatus();
      ref.read(profileNotifierProvider.notifier).fetchFirstPage();
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $e')),
        );
      }
      return;
    }
    
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    // Show Success Dialog with ID, Password and Mandatory Verification Next Step
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        title: const Column(
          children: [
            Icon(Icons.verified_user_rounded, color: Color(0xFFD4AF37), size: 48),
            SizedBox(height: 12),
            Text(
              'પ્રોફાઇલ સબમિટ થઈ ગઈ છે!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Profile Submitted for Review',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'તમારી પ્રોફાઇલ અને ફોટો એડમિન ચકાસણી માટે મોકલી દેવાયા છે. એડમિન દ્વારા મંજૂરી મળ્યા પછી જ તમારું એકાઉન્ટ સંપૂર્ણ સક્રિય થશે.\n\nYour profile has been submitted for Admin Verification. Access will be granted once approved.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Unique ID:', style: TextStyle(color: Colors.black54, fontSize: 13)),
                      Text(uniqueId, style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ],
                  ),
                  Divider(color: Colors.grey.shade300, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Password:', style: TextStyle(color: Colors.black54, fontSize: 13)),
                      Text(password, style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.go('/profile-under-review');
              },
              icon: const Icon(Icons.hourglass_top_rounded, color: Colors.black, size: 20),
              label: const Text(
                'ચકાસણી સ્થિતિ જુઓ (View Review Status)',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final masterData = ref.watch(masterDataProvider);
    final samajServicesAsync = ref.watch(samajServicesProvider);
    List<String> dynamicBusinessCategories = [];
    List<String> dynamicBusinessServices = [];

    samajServicesAsync.whenData((services) {
      dynamicBusinessCategories = services.map((e) => e.category).toSet().toList();
      if (_businessIndustry != 'Select Industry') {
        dynamicBusinessServices = services
            .where((e) => e.category == _businessIndustry)
            .map((e) => e.title)
            .toSet()
            .toList();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Soft Light Grey Background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Create Profile',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                        border: Border.all(color: Colors.grey.shade300),
                        image: _profileImageBytes != null
                            ? DecorationImage(
                                image: MemoryImage(_profileImageBytes!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _profileImageBytes == null
                          ? const Icon(Icons.add_a_photo, color: Colors.black54, size: 36)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Upload Profile Photo (ફોટો અપલોડ કરો)',
                            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'તમારો પાસપોર્ટ સાઈઝ અથવા સુંદર પ્રોફાઈલ ફોટો અહીં અપલોડ કરો.',
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
                            label: const Text('Choose Photo (ફોટો પસંદ કરો)', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold)),
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
              _buildTextField('First Name (પ્રથમ નામ) *', 'Enter First Name (પ્રથમ નામ)', Icons.badge_outlined, onChanged: (v) => setState(() => _firstName = v)),
              _buildTextField('Last Name (અટક / ઉપનામ) *', 'Enter Last Name (અટક / ઉપનામ)', Icons.badge_outlined, onChanged: (v) => setState(() => _lastName = v)),
              _buildTextField('Date of Birth *', _dob ?? 'Tap to select date of birth', Icons.cake_outlined, isDropdown: true, readOnly: true, onTap: () => _selectDate(context)),
              _buildDropdownField('Gender (જાતિ) *', 'Male (પુરુષ)', Icons.people_alt_outlined, ['Male (પુરુષ)', 'Female (સ્ત્રી)'], value: _gender, onChanged: (v) => setState(() => _gender = v)),
              _buildDropdownField('Marital Status (વૈવાહિક સ્થિતિ) *', 'Never Married (અપરિણીત)', Icons.favorite_border, ['Never Married (અપરિણીત)', 'Divorced (છૂટાછેડા લીધેલ)', 'Widowed (વિધવા / વિધુર)', 'Awaiting Divorce (છૂટાછેડાની રાહમાં)'], value: _maritalStatus, onChanged: (v) => setState(() => _maritalStatus = v)),
              _buildDropdownField('Blood Group (બ્લડ ગ્રુપ)', 'Select Blood Group', Icons.water_drop_outlined, ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Don\'t Know (ખબર નથી)'], value: _bloodGroup, onChanged: (v) => setState(() => _bloodGroup = v)),
              _buildDropdownField('Are you Vankar? (તમે વણકર છો?) *', 'Yes (હા)', Icons.verified_user_outlined, ['Yes (હા)', 'No (ના)'], value: _isVankar, onChanged: (v) => setState(() => _isVankar = v)),
              
              _buildDropdownField('Physically Disabled? (શું તમે શારીરિક રીતે દિવ્યાંગ છો?) *', 'No (ના)', Icons.accessible_outlined, ['Yes (હા)', 'No (ના)'], value: _isPhysicallyDisabled ? 'Yes (હા)' : 'No (ના)', onChanged: (v) => setState(() {
                _isPhysicallyDisabled = v == 'Yes (હા)';
                if (!_isPhysicallyDisabled) _pwbdCategory = null;
              })),
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
                  value: _pwbdCategory,
                  onChanged: (v) => setState(() => _pwbdCategory = v),
                ),
              _buildDropdownField(
                'Religion (ધર્મ) *',
                'Select Religion (ધર્મ પસંદ કરો)',
                Icons.settings_brightness,
                masterData.religionOptions,
                value: masterData.religionOptions.contains(_religion) ? _religion : 'Select Religion',
                onChanged: (v) => setState(() => _religion = v ?? 'Select Religion'),
              ),
              _buildDropdownField('Caste Category (જ્ઞાતિ પસંદ કરો) *', 'Hindu-vankar (હિન્દુ-વણકર)', Icons.groups_outlined, ['Hindu-Vankar (હિન્દુ-વણકર)', 'Buddhist-Vankar (બૌદ્ધ-વણકર)', 'Christian-Vankar (ખ્રિસ્તી-વણકર)', 'Muslim-Vankar (મુસ્લિમ-વણકર)', 'Other (અન્ય)'], value: _casteCategory, onChanged: (v) => setState(() => _casteCategory = v)),

              const SizedBox(height: 24),
              // Contact Details Section
              _buildSectionHeader(Icons.phone_android, 'Contact Details (સંપર્ક માહિતી)'),
              const SizedBox(height: 16),
              _buildTextField('Mobile Number (મોબાઈલ નંબર - 10 અંક) *', 'Enter Mobile Number (મોબાઈલ નંબર - 10 અંક)', Icons.phone_android),
              _buildTextField('Email Address (ઈમેઈલ સરનામું) *', 'Enter Email Address (ઈમેઈલ સરનામું)', Icons.email_outlined),
              _buildTextField('WhatsApp / Alt Phone (વોટ્સએપ નંબર - 10 અંક)', 'Enter WhatsApp / Alt Phone...', Icons.chat_bubble_outline),

              const SizedBox(height: 24),
              // Location & Address Section
              _buildSectionHeader(Icons.location_on_outlined, 'Location & Address (રહેઠાણનું સરનામું)'),
              const SizedBox(height: 16),
              _buildTextField('Flat / House / Building Name & No. (મકાન / બિલ્ડિંગ નંબર)', 'Enter Flat / House / Building Name & No...', Icons.domain),
              _buildTextField('Area / Society / Landmark (સોસાયટી / વિસ્તાર / લેન્ડમાર્ક)', 'Enter Area / Society / Landmark...', Icons.explore_outlined),
              _buildTextField('City / Taluka (શહેર / તાલુકો) *', 'Enter City / Taluka (શહેર / તાલુકો)', Icons.location_city, onChanged: (v) => setState(() => _taluka = v)),
              _buildTextField('District & State (જિલ્લો અને રાજ્ય) *', 'Enter District & State (જિલ્લો અને રાજ્ય)', Icons.map_outlined, onChanged: (v) => setState(() => _district = v)),
              _buildDropdownField(
                'Which Pargana you have? (તમારું પરગણું કયું છે?) *', 
                'Select Pargana', 
                Icons.account_tree_outlined, 
                ['Select Pargana', '7 Pargana (૭ પરગણા)', '22 Pargana (૨૨ પરગણા)', '24 Pargana / Chovisey (ચોવીસી)', '42 Pargana (૪૨ પરગણા)', 'Other (અન્ય)'],
                value: _pargana,
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
              _buildTextField('Country (દેશ) *', 'Enter Country (દેશ)', Icons.public),
              _buildTextField('Pincode / Zip Code (પીનકોડ)', 'Enter Pincode / Zip Code (પીનકોડ)', Icons.markunread_mailbox_outlined),

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
                  onChanged: (v) => setState(() => _department = v),
                ),
              ],
              if (_employmentType.contains('Business')) ...[
                _buildDropdownField(
                  'Business Industry / Category (વ્યવસાયનો પ્રકાર)',
                  'Select Industry',
                  Icons.storefront_outlined,
                  ['Select Industry', ...dynamicBusinessCategories],
                  value: dynamicBusinessCategories.contains(_businessIndustry) ? _businessIndustry : 'Select Industry',
                  onChanged: (v) => setState(() {
                    _businessIndustry = v ?? 'Select Industry';
                    _businessService = 'Select Service';
                  }),
                ),
                if (_businessIndustry != 'Select Industry' && dynamicBusinessServices.isNotEmpty)
                  _buildDropdownField(
                    'Business Service / Title',
                    'Select Service',
                    Icons.store_outlined,
                    ['Select Service', ...dynamicBusinessServices],
                    value: dynamicBusinessServices.contains(_businessService) ? _businessService : 'Select Service',
                    onChanged: (v) => setState(() => _businessService = v ?? 'Select Service'),
                  ),
                if (_businessIndustry == 'Select Industry')
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Text('Please wait while loading categories...'),
                  ),
              ],
              _buildTextField('Designation / Detailed Occupation (હોદ્દો / વ્યવસાય વિગત) *', 'Enter Designation / Detailed Occupation...', Icons.badge_outlined, onChanged: (v) => setState(() => _designation = v)),
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
              _buildTextField('Father\'s Name (પિતાનું નામ) *', 'Enter Father\'s Name (પિતાનું નામ)', Icons.person_outline),
              _buildTextField('Father\'s Occupation (પિતાનો વ્યવસાય)', 'Enter Father\'s Occupation (પિતાનો વ્યવસાય)', Icons.work_outline),
              _buildTextField('Father\'s Contact Number (પિતાનો ફોન નંબર - 10 અંક)', 'Enter Father\'s Contact Number...', Icons.phone),
              _buildTextField('Mother\'s Name (માતાનું નામ) *', 'Enter Mother\'s Name (માતાનું નામ)', Icons.face_3_outlined),
              _buildTextField('Mother\'s Occupation (માતાનો વ્યવસાય)', 'Enter Mother\'s Occupation (માતાનો વ્યવસાય)', Icons.work_outline),
              _buildTextField('Guardian Contact Number (વાલીનો સંપર્ક નંબર - 10 અંક)', 'Enter Guardian Contact Number...', Icons.contact_phone_outlined),
              _buildTextField('Brothers & Sisters (ભાઈ-બહેનની વિગત)', 'Enter Brothers & Sisters (ભાઈ-બહેનની વિગત)', Icons.groups_outlined),
              _buildTextField('Mama\'s Village / Mosal (મોસાળ / મોસાળનું ગામ)', 'Enter Mama\'s Village / Mosal...', Icons.holiday_village_outlined),
              _buildTextField('Native Place (મૂળ વતન / પરગણું)', 'Enter Native Place (મૂળ વતન / પરગણું)', Icons.home_work_outlined),

              const SizedBox(height: 24),
              // About Me Section
              _buildSectionHeader(Icons.info_outline, 'About Me (પોતાના વિશે વિશેષ માહિતી)'),
              const SizedBox(height: 16),
              _buildTextField('Tell us about yourself (વધારાની વિગતો)', 'Enter Tell us about yourself (વધારાની વિગતો)', Icons.notes, isMultiline: true),

              const SizedBox(height: 32),
              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                child: _isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'સેવ થઈ રહ્યું છે... (Saving Profile...)',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ],
                      )
                    : const Text(
                        'પ્રોફાઇલ સાચવો (Create Profile)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 40),
            ],
          ),
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

  Widget _buildTextField(String label, String hint, IconData prefixIcon, {bool isDropdown = false, bool isMultiline = false, Function(String)? onChanged, bool readOnly = false, VoidCallback? onTap}) {
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
            child: TextField(
              maxLines: isMultiline ? 4 : 1,
              style: const TextStyle(color: Colors.black87),
              onChanged: onChanged,
              readOnly: readOnly,
              onTap: onTap,
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

  Widget _buildDropdownField(String label, String hint, IconData prefixIcon, List<String> items, {String? value, Function(String?)? onChanged}) {
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
            child: DropdownButtonFormField<String>(
              value: value,
              decoration: InputDecoration(
                prefixIcon: Icon(prefixIcon, color: const Color(0xFFD4AF37), size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              hint: Text(hint, style: const TextStyle(color: Colors.black38, fontSize: 14)),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
              isExpanded: true,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 8,
              menuMaxHeight: 300,
              iconEnabledColor: const Color(0xFFD4AF37),
              style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),
              items: items.map((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val, style: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
