import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/profile_models.dart';

/// Result returned by ProfileFormWidget when the user submits.
class ProfileFormResult {
  final String firstName;
  final String lastName;
  final String dateOfBirth; // YYYY-MM-DD for the backend
  final String gender;
  final String maritalStatus;
  final String? religion;
  final String? caste;
  final String? city;
  final String? state;
  final String? country;
  final String? education;
  final String? occupation;
  final String? about;
  final Uint8List? imageBytes;
  final String? photoUrl;

  const ProfileFormResult({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.maritalStatus,
    this.religion,
    this.caste,
    this.city,
    this.state,
    this.country,
    this.education,
    this.occupation,
    this.about,
    this.imageBytes,
    this.photoUrl,
  });
}

/// Shared form used by both Create and Edit profile screens.
/// [initialProfile] may be null (create) or provided (edit).
class ProfileForm extends StatefulWidget {
  final MatrimonialProfileModel? initialProfile;
  final ReferenceDataModel referenceData;
  final bool isSaving;
  final String submitLabel;
  final Future<bool> Function(ProfileFormResult result) onSubmit;

  const ProfileForm({
    super.key,
    this.initialProfile,
    required this.referenceData,
    required this.isSaving,
    required this.submitLabel,
    required this.onSubmit,
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _dobCtrl = TextEditingController();
  final TextEditingController _mobileCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _whatsappCtrl = TextEditingController();
  final TextEditingController _religionCtrl = TextEditingController();
  final TextEditingController _casteCtrl = TextEditingController();
  final TextEditingController _buildingCtrl = TextEditingController();
  final TextEditingController _areaCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _stateCtrl = TextEditingController();
  final TextEditingController _countryCtrl = TextEditingController();
  final TextEditingController _pincodeCtrl = TextEditingController();
  final TextEditingController _educationCtrl = TextEditingController();
  final TextEditingController _occupationCtrl = TextEditingController();
  final TextEditingController _fatherNameCtrl = TextEditingController();
  final TextEditingController _fatherOccCtrl = TextEditingController();
  final TextEditingController _fatherPhoneCtrl = TextEditingController();
  final TextEditingController _motherNameCtrl = TextEditingController();
  final TextEditingController _motherOccCtrl = TextEditingController();
  final TextEditingController _guardianPhoneCtrl = TextEditingController();
  final TextEditingController _siblingsCtrl = TextEditingController();
  final TextEditingController _nativeMosalCtrl = TextEditingController();
  final TextEditingController _incomeCtrl = TextEditingController();
  final TextEditingController _mamasVillageCtrl = TextEditingController();
  final TextEditingController _customCasteCtrl = TextEditingController();
  final TextEditingController _aboutCtrl = TextEditingController();

  DateTime? _dateOfBirth;
  String? _selectedGender;
  String? _selectedMaritalStatus;
  String? _selectedCaste;
  String? _selectedBloodGroup;
  String _isVankar = 'Yes (હા)';
  String _selectedEmploymentSector = 'Government (સરકારી નોકરી)';
  String? _selectedGovtSubService;
  String? _selectedPrivateCategory;
  bool _hasPhoto = false;
  Uint8List? _imageBytes;
  String? _imageName;

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageName = pickedFile.name;
          _hasPhoto = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Photo selected: ${pickedFile.name}'),
              backgroundColor: AppColors.cardNavy,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final p = widget.initialProfile;
    _firstNameCtrl.text = p?.firstName ?? '';
    _lastNameCtrl.text = p?.lastName ?? '';
    _dateOfBirth = p?.dateOfBirth;
    _dobCtrl.text = _dateOfBirth != null
        ? '${_dateOfBirth!.day.toString().padLeft(2, '0')}/${_dateOfBirth!.month.toString().padLeft(2, '0')}/${_dateOfBirth!.year}'
        : '';
    _religionCtrl.text = p?.religion ?? '';
    _casteCtrl.text = p?.caste ?? '';
    if (p?.caste != null) {
      const presetOptions = [
        'Hindu-Vankar (હિન્દુ-વણકર)',
        'Muslim-Vankar (મુસ્લિમ-વણકર)',
        'Buddhist-Vankar (બૌદ્ધ-વણકર)',
        'Christianity-Vankar (ખ્રિસ્તી-વણકર)',
      ];
      if (presetOptions.contains(p!.caste)) {
        _selectedCaste = p.caste;
      } else {
        _selectedCaste = 'Other (અન્ય જ્ઞાતિ - Manually Add)';
        _customCasteCtrl.text = p.caste!;
      }
    } else {
      _selectedCaste = 'Hindu-Vankar (હિન્દુ-વણકર)';
      _casteCtrl.text = 'Hindu-Vankar (હિન્દુ-વણકર)';
    }
    _cityCtrl.text = p?.city ?? '';
    _stateCtrl.text = p?.state ?? '';
    _countryCtrl.text = p?.country ?? '';
    _educationCtrl.text = p?.education ?? '';
    _occupationCtrl.text = p?.occupation ?? '';
    _aboutCtrl.text = p?.about ?? '';
    if (p?.gender != null) {
      if (p!.gender.toUpperCase().contains('FEMALE')) {
        _selectedGender = 'Female (સ્ત્રી)';
      } else if (p.gender.toUpperCase().contains('OTHER')) {
        _selectedGender = 'Other (અન્ય)';
      } else {
        _selectedGender = 'Male (પુરુષ)';
      }
    } else {
      _selectedGender = 'Male (પુરુષ)';
    }

    if (p?.maritalStatus != null) {
      final ms = p!.maritalStatus.toUpperCase();
      if (ms.contains('DIVORCED')) {
        _selectedMaritalStatus = 'Divorced (છૂટાછેડા લીધેલ)';
      } else if (ms.contains('WIDOWED')) {
        _selectedMaritalStatus = 'Widowed (વિધવા / વિધુર)';
      } else if (ms.contains('SEPARATED')) {
        _selectedMaritalStatus = 'Separated (અલગ રહેતા)';
      } else {
        _selectedMaritalStatus = 'Never Married (અવિવાહિત)';
      }
    } else {
      _selectedMaritalStatus = 'Never Married (અવિવાહિત)';
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _dobCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _whatsappCtrl.dispose();
    _religionCtrl.dispose();
    _casteCtrl.dispose();
    _buildingCtrl.dispose();
    _areaCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _pincodeCtrl.dispose();
    _educationCtrl.dispose();
    _occupationCtrl.dispose();
    _fatherNameCtrl.dispose();
    _fatherOccCtrl.dispose();
    _fatherPhoneCtrl.dispose();
    _motherNameCtrl.dispose();
    _motherOccCtrl.dispose();
    _guardianPhoneCtrl.dispose();
    _siblingsCtrl.dispose();
    _nativeMosalCtrl.dispose();
    _incomeCtrl.dispose();
    _mamasVillageCtrl.dispose();
    _customCasteCtrl.dispose();
    _aboutCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ─── Profile Photo Section ──────────────────────────────────
          _sectionHeader(theme, 'Profile Photo (પ્રોફાઈલ ફોટો)', Icons.add_a_photo_outlined),
          const SizedBox(height: 12),
          _buildPhotoUploadCard(),
          const SizedBox(height: 20),

          // ─── Personal Details ───────────────────────────────────────
          _sectionHeader(theme, 'Personal Details (અંગત માહિતી)', Icons.person_outline_rounded),
          const SizedBox(height: 12),
          _buildTextField(
            id: 'profile_first_name',
            controller: _firstNameCtrl,
            label: 'First Name (પ્રથમ નામ) *',
            icon: Icons.badge_outlined,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'First name is required';
              if (v.trim().length > 100) return 'Max 100 characters';
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildTextField(
            id: 'profile_last_name',
            controller: _lastNameCtrl,
            label: 'Last Name (અટક / ઉપનામ) *',
            icon: Icons.badge_outlined,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Last name is required';
              if (v.trim().length > 100) return 'Max 100 characters';
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildDatePicker(context, theme),
          const SizedBox(height: 12),
          _buildDropdown(
            id: 'profile_gender',
            label: 'Gender (જાતિ) *',
            value: _selectedGender,
            icon: Icons.wc_outlined,
            items: const [
              'Male (પુરુષ)',
              'Female (સ્ત્રી)',
              'Other (અન્ય)',
            ],
            onChanged: (v) => setState(() => _selectedGender = v),
            validator: (v) => v == null ? 'Gender is required' : null,
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            id: 'profile_marital_status',
            label: 'Marital Status (વૈવાહિક સ્થિતિ) *',
            value: _selectedMaritalStatus,
            icon: Icons.favorite_border_rounded,
            items: const [
              'Never Married (અવિવાહિત)',
              'Divorced (છૂટાછેડા લીધેલ)',
              'Widowed (વિધવા / વિધુર)',
              'Separated (અલગ રહેતા)',
            ],
            onChanged: (v) => setState(() => _selectedMaritalStatus = v),
            validator: (v) => v == null ? 'Marital status is required' : null,
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            id: 'profile_blood_group',
            label: 'Blood Group (બ્લડ ગ્રુપ)',
            value: _selectedBloodGroup,
            icon: Icons.bloodtype_outlined,
            items: const ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Don\'t Know (ખબર નથી)'],
            onChanged: (v) => setState(() => _selectedBloodGroup = v),
            validator: (v) => null,
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            id: 'profile_is_vankar',
            label: 'Are you Vankar? (તમે વણકર છો?) *',
            value: _isVankar,
            icon: Icons.verified_user_outlined,
            items: const ['Yes (હા)', 'No (ના)'],
            onChanged: (v) => setState(() => _isVankar = v ?? 'Yes (હા)'),
            validator: (v) => v == null ? 'Selection required' : null,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            id: 'profile_religion',
            controller: _religionCtrl,
            label: 'Religion (ધર્મ) *',
            icon: Icons.brightness_high_outlined,
            maxLength: 100,
            required: true,
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            id: 'profile_caste_select',
            label: 'Caste Category (જ્ઞાતિ પસંદ કરો) *',
            value: _selectedCaste ?? 'Hindu-Vankar (હિન્દુ-વણકર)',
            icon: Icons.groups_outlined,
            items: const [
              'Hindu-Vankar (હિન્દુ-વણકર)',
              'Muslim-Vankar (મુસ્લિમ-વણકર)',
              'Buddhist-Vankar (બૌદ્ધ-વણકર)',
              'Christianity-Vankar (ખ્રિસ્તી-વણકર)',
              'Other (અન્ય જ્ઞાતિ - Manually Add)',
            ],
            onChanged: (v) {
              setState(() {
                _selectedCaste = v;
                if (v != 'Other (અન્ય જ્ઞાતિ - Manually Add)') {
                  _casteCtrl.text = v ?? '';
                } else {
                  _casteCtrl.text = _customCasteCtrl.text.trim();
                }
              });
            },
            validator: (v) => v == null ? 'Caste selection is required' : null,
          ),
          if (_selectedCaste == 'Other (અન્ય જ્ઞાતિ - Manually Add)') ...[
            const SizedBox(height: 12),
            _buildTextField(
              id: 'profile_custom_caste',
              controller: _customCasteCtrl,
              label: 'Manually Specify Caste (અન્ય જ્ઞાતિ અહિં લખો) *',
              icon: Icons.edit_note_outlined,
              maxLength: 100,
              required: true,
              onChanged: (val) {
                _casteCtrl.text = val.trim();
              },
              validator: (v) {
                if (_selectedCaste == 'Other (અન્ય જ્ઞાતિ - Manually Add)') {
                  if (v == null || v.trim().isEmpty) return 'Please enter your caste';
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 20),

          // ─── Contact Details Section ────────────────────────────────
          _sectionHeader(theme, 'Contact Details (સંપર્ક માહિતી)', Icons.phone_android_outlined),
          const SizedBox(height: 12),
          _buildTextField(
            id: 'profile_mobile',
            controller: _mobileCtrl,
            label: 'Mobile Number (મોબાઈલ નંબર - 10 અંક) *',
            icon: Icons.phone_iphone_outlined,
            maxLength: 10,
            required: true,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Mobile number is required';
              if (!RegExp(r'^\d{10}$').hasMatch(v.trim())) {
                return 'Mobile number must be exactly 10 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildTextField(
            id: 'profile_email',
            controller: _emailCtrl,
            label: 'Email Address (ઈમેઈલ સરનામું) *',
            icon: Icons.email_outlined,
            maxLength: 100,
            required: true,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email address is required';
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(v.trim())) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildTextField(
            id: 'profile_whatsapp',
            controller: _whatsappCtrl,
            label: 'WhatsApp / Alt Phone (વોટ્સએપ નંબર - 10 અંક)',
            icon: Icons.chat_bubble_outline_rounded,
            maxLength: 10,
            required: false,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (v) {
              if (v != null && v.trim().isNotEmpty && !RegExp(r'^\d{10}$').hasMatch(v.trim())) {
                return 'WhatsApp number must be 10 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // ─── Location & Address Section ─────────────────────────────
          _sectionHeader(theme, 'Location & Address (રહેઠાણનું સરનામું)', Icons.location_on_outlined),
          const SizedBox(height: 12),
          _buildTextField(
            id: 'profile_building',
            controller: _buildingCtrl,
            label: 'Flat / House / Building Name & No. (મકાન / બિલ્ડિંગ નંબર)',
            icon: Icons.apartment_outlined,
            maxLength: 120,
            required: false,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            id: 'profile_area',
            controller: _areaCtrl,
            label: 'Area / Society / Landmark (સોસાયટી / વિસ્તાર / લેન્ડમાર્ક)',
            icon: Icons.explore_outlined,
            maxLength: 150,
            required: false,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            id: 'profile_city',
            controller: _cityCtrl,
            label: 'City / Taluka (શહેર / તાલુકો) *',
            icon: Icons.location_city_outlined,
            maxLength: 100,
            required: true,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            id: 'profile_state',
            controller: _stateCtrl,
            label: 'District & State (જિલ્લો અને રાજ્ય) *',
            icon: Icons.map_outlined,
            maxLength: 100,
            required: true,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            id: 'profile_country',
            controller: _countryCtrl,
            label: 'Country (દેશ) *',
            icon: Icons.public_outlined,
            maxLength: 100,
            required: true,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            id: 'profile_pincode',
            controller: _pincodeCtrl,
            label: 'Pincode / Zip Code (પીનકોડ)',
            icon: Icons.markunread_mailbox_outlined,
            maxLength: 10,
            required: false,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 20),

          // ─── Career & Education Section ─────────────────────────────
          _sectionHeader(theme, 'Career & Employment Details (શિક્ષણ, વ્યવસાય અને નોકરીની વિગત)', Icons.work_history_outlined),
          const SizedBox(height: 12),
          _buildTextField(
            id: 'profile_education',
            controller: _educationCtrl,
            label: 'Education / Degree (અભ્યાસ / ડિગ્રી) *',
            icon: Icons.school_outlined,
            maxLength: 200,
            required: true,
          ),
          const SizedBox(height: 12),

          // 1. Employment Sector Selector
          DropdownButtonFormField<String>(
            initialValue: _selectedEmploymentSector,
            decoration: InputDecoration(
              labelText: 'Employment Type / Work Sector (નોકરી / વ્યવસાયનો પ્રકાર) *',
              prefixIcon: const Icon(Icons.work_outline_rounded, color: AppColors.secondary),
              filled: true,
              fillColor: const Color(0xFF020917),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorder)),
            ),
            dropdownColor: const Color(0xFF061633),
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            items: const [
              DropdownMenuItem(value: 'Government (સરકારી નોકરી)', child: Text('Government Sector (સરકારી નોકરી / સેકટર)')),
              DropdownMenuItem(value: 'Private (ખાનગી નોકરી)', child: Text('Private Sector (ખાનગી કંપની / નોકરી)')),
              DropdownMenuItem(value: 'Business (વેપાર / બિઝનેસ)', child: Text('Business / Self-Employed (ધંધો / વેપાર)')),
              DropdownMenuItem(value: 'Professional (પ્રોફેસનલ સેવા)', child: Text('Professional (ડૉક્ટર, વકીલ, CA, વગેરે)')),
              DropdownMenuItem(value: 'Other (અન્ય)', child: Text('Other Work (અન્ય)')),
            ],
            onChanged: (val) {
              setState(() {
                _selectedEmploymentSector = val ?? 'Government (સરકારી નોકરી)';
                _selectedGovtSubService = null;
              });
            },
          ),
          const SizedBox(height: 12),

          // 2. Conditional Sub-Service Selection for Govt Employees
          if (_selectedEmploymentSector.contains('Government')) ...[
            DropdownButtonFormField<String>(
              initialValue: _selectedGovtSubService,
              decoration: InputDecoration(
                labelText: 'Government Department / Service (સરકારી વિભાગ / સેવા) *',
                prefixIcon: const Icon(Icons.account_balance, color: AppColors.secondary),
                filled: true,
                fillColor: const Color(0xFF071936),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.secondary, width: 1.5)),
              ),
              dropdownColor: const Color(0xFF061633),
              style: const TextStyle(color: AppColors.goldLight, fontSize: 13, fontWeight: FontWeight.bold),
              items: const [
                DropdownMenuItem(value: 'Police & Defense (પોલીસ અને સંરક્ષણ દળ)', child: Text('Police & Defense (પોલીસ, બોર્ડર ગાર્ડ, PSI, કોન્સ્ટેબલ)')),
                DropdownMenuItem(value: 'Paramedical & Health (પેરામેડિકલ અને આરોગ્ય)', child: Text('Paramedical & Health (નર્સ, લેબ ટેકનિશિયન, ફાર્માસિસ્ટ)')),
                DropdownMenuItem(value: 'Government Teacher & Education (શિક્ષક / પ્રોફેસર)', child: Text('Government Teacher / Professor (સરકારી શિક્ષક / અબ્યાસ)')),
                DropdownMenuItem(value: 'Revenue & Panchayat (મહેસૂલ અને પંચાયત)', child: Text('Revenue & Panchayat (તલાટી, મામલતદાર, મહેસૂલી સેવા)')),
                DropdownMenuItem(value: 'Railways & Transport (રેલ્વે અને વાહનવ્યવહાર)', child: Text('Railways & Transport (ભારતીય રેલ્વે, GSRTC, વાહનવ્યવહાર)')),
                DropdownMenuItem(value: 'Electricity Board (GETCO / GUVNL / MGVCL)', child: Text('Electricity Board (GETCO, PGVCL, DGVCL, UGVCL)')),
                DropdownMenuItem(value: 'Public Sector Bank (સરકારી બેંક સેક્ટર)', child: Text('Public Sector Bank (SBI, BOB, સરકારી બેંક)')),
                DropdownMenuItem(value: 'Other Govt Service (અન્ય સરકારી સેવાઓ)', child: Text('Other Govt Service (અન્ય સરકારી ખાતું)')),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedGovtSubService = val;
                  if (val != null) {
                    _occupationCtrl.text = 'Government Job ($val)';
                  }
                });
              },
            ),
            const SizedBox(height: 12),
          ],

          // 3. Conditional Sub-Service Selection for Private / Business / Professional
          if (_selectedEmploymentSector.contains('Private')) ...[
            DropdownButtonFormField<String>(
              initialValue: _selectedPrivateCategory,
              decoration: InputDecoration(
                labelText: 'Private Sector Profession (ખાનગી નોકરીનો પ્રકાર)',
                prefixIcon: const Icon(Icons.corporate_fare, color: AppColors.secondary),
                filled: true,
                fillColor: const Color(0xFF020917),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.cardBorder)),
              ),
              dropdownColor: const Color(0xFF061633),
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              items: const [
                DropdownMenuItem(value: 'IT & Software Development (આઈટી સોફ્ટવેર)', child: Text('IT & Software (ડેવલપર, એન્જિનિયર, ડેટા સાયન્ટિસ્ટ)')),
                DropdownMenuItem(value: 'Private Banking & Finance (બેંક અને ફાયનાન્સ)', child: Text('Private Banking & Finance (એચડીએફસી, આઈસીઆઈસીઆઈ, લોન)')),
                DropdownMenuItem(value: 'Textile & Manufacturing (કાપડ ઉદ્યોગ અને ઉત્પાદન)', child: Text('Textile & Manufacturing (ટેક્સટાઈલ, ફેક્ટરી મૂલ્ય)')),
                DropdownMenuItem(value: 'Pharma & Biotech (દવા ઉદ્યોગ અને બાયોટેક)', child: Text('Pharma & Biotech (ફાર્મા કંપની, ક્યુસી, પ્રોડક્શન)')),
                DropdownMenuItem(value: 'Civil & Real Estate (બાંધકામ અને રિયલ એસ્ટેટ)', child: Text('Civil & Real Estate (આર્કિટેક્ટ, બિલ્ડર, એન્જિનિયર)')),
                DropdownMenuItem(value: 'Private Hospital & Health (ખાનગી હોસ્પિટલ સેવા)', child: Text('Private Hospital & Medical (ખાનગી નર્સ, ટેકનિશિયન)')),
              ],
              onChanged: (val) {
                setState(() {
                  _selectedPrivateCategory = val;
                  if (val != null) {
                    _occupationCtrl.text = 'Private Job ($val)';
                  }
                });
              },
            ),
            const SizedBox(height: 12),
          ],

          _buildTextField(
            id: 'profile_occupation',
            controller: _occupationCtrl,
            label: 'Designation / Detailed Occupation (હોદ્દો / વ્યવસાય વિગત) *',
            icon: Icons.work_outline_rounded,
            maxLength: 200,
            required: true,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            id: 'profile_income',
            controller: _incomeCtrl,
            label: 'Yearly Income (વાર્ષિક આવક - રૂ.)',
            icon: Icons.payments_outlined,
            maxLength: 100,
            required: false,
          ),
          const SizedBox(height: 20),

          // ─── Family Details & Contacts ───────────────────────────────
          _sectionHeader(theme, 'Family Details (પરિવારની વિગતો અને વાલીનો સંપર્ક)', Icons.family_restroom_outlined),
          const SizedBox(height: 12),
          _buildTextField(
            id: 'profile_father_name',
            controller: _fatherNameCtrl,
            label: "Father's Name (પિતાનું નામ) *",
            icon: Icons.person_pin_outlined,
            maxLength: 100,
            required: true,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            id: 'profile_father_occ',
            controller: _fatherOccCtrl,
            label: "Father's Occupation (પિતાનો વ્યવસાય)",
            icon: Icons.work_outline_rounded,
            maxLength: 100,
            required: false,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            id: 'profile_father_phone',
            controller: _fatherPhoneCtrl,
            label: "Father's Contact Number (પિતાનો ફોન નંબર - 10 અંક)",
            icon: Icons.phone_outlined,
            maxLength: 10,
            required: false,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (v) {
              if (v != null && v.trim().isNotEmpty && !RegExp(r'^\d{10}$').hasMatch(v.trim())) {
                return 'Father contact number must be 10 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildTextField(
            id: 'profile_mother_name',
            controller: _motherNameCtrl,
            label: "Mother's Name (માતાનું નામ) *",
            icon: Icons.face_3_outlined,
            maxLength: 100,
            required: true,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            id: 'profile_mother_occ',
            controller: _motherOccCtrl,
            label: "Mother's Occupation (માતાનો વ્યવસાય)",
            icon: Icons.work_history_outlined,
            maxLength: 100,
            required: false,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            id: 'profile_guardian_phone',
            controller: _guardianPhoneCtrl,
            label: "Guardian Contact Number (વાલીનો સંપર્ક નંબર - 10 અંક)",
            icon: Icons.contact_phone_outlined,
            maxLength: 10,
            required: false,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (v) {
              if (v != null && v.trim().isNotEmpty && !RegExp(r'^\d{10}$').hasMatch(v.trim())) {
                return 'Guardian contact number must be 10 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildTextField(
            id: 'profile_siblings',
            controller: _siblingsCtrl,
            label: 'Brothers & Sisters (ભાઈ-બહેનની વિગત)',
            icon: Icons.groups_2_outlined,
            maxLength: 150,
            required: false,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            id: 'profile_mamas_village',
            controller: _mamasVillageCtrl,
            label: "Mama's Village / Mosal (મોસાળ / મોસાળનું ગામ)",
            icon: Icons.holiday_village_outlined,
            maxLength: 150,
            required: false,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            id: 'profile_native_mosal',
            controller: _nativeMosalCtrl,
            label: 'Native Place (મૂળ વતન / પરગણું)',
            icon: Icons.home_work_outlined,
            maxLength: 150,
            required: false,
          ),
          const SizedBox(height: 20),

          // ─── About Me Section ───────────────────────────────────────
          _sectionHeader(theme, 'About Me (પોતાના વિશે વિશેષ માહિતી)', Icons.info_outline_rounded),
          const SizedBox(height: 12),
          _buildTextField(
            id: 'profile_about',
            controller: _aboutCtrl,
            label: 'Tell us about yourself (વધારાની વિગતો)',
            icon: Icons.notes_rounded,
            maxLength: 2000,
            maxLines: 4,
            required: false,
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: widget.isSaving ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              disabledBackgroundColor: AppColors.secondary.withValues(alpha: 0.5),
            ),
            child: widget.isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    widget.submitLabel,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPhotoUploadCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF041026),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondary, width: 2),
              ),
              child: ClipOval(
                child: _imageBytes != null
                    ? Image.memory(
                        _imageBytes!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: _hasPhoto
                            ? const Icon(Icons.check_circle, color: Colors.black87, size: 36)
                            : const Icon(Icons.add_a_photo_outlined, color: Colors.black87, size: 30),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _imageName != null
                      ? _imageName!
                      : _hasPhoto
                          ? 'Photo Uploaded (ફોટો સિલેક્ટ થયેલ છે)'
                          : 'Upload Profile Photo (ફોટો અપલોડ કરો)',
                  style: const TextStyle(
                    color: AppColors.goldLight,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                const Text(
                  'તમારો પાસપોર્ટ સાઈઝ અથવા સુંદર પ્રોફાઈલ ફોટો અહીં અપલોડ કરો.',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(
                        _imageBytes != null ? Icons.photo_library : Icons.cloud_upload_outlined,
                        color: AppColors.secondary,
                        size: 16,
                      ),
                      label: Text(
                        _imageBytes != null ? 'Change Photo' : 'Choose Photo (ફોટો પસંદ કરો)',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.secondary, width: 1),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                    ),
                    if (_imageBytes != null || _hasPhoto) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _imageBytes = null;
                            _imageName = null;
                            _hasPhoto = false;
                          });
                        },
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                        tooltip: 'Remove photo',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your date of birth.')),
      );
      return;
    }

    // Format date as YYYY-MM-DD for backend
    final dob =
        '${_dateOfBirth!.year.toString().padLeft(4, '0')}-'
        '${_dateOfBirth!.month.toString().padLeft(2, '0')}-'
        '${_dateOfBirth!.day.toString().padLeft(2, '0')}';

    final notes = <String>[];

    if (_selectedBloodGroup != null && _selectedBloodGroup!.isNotEmpty) {
      notes.add('--- Medical & Fitness ---\nBlood Group: $_selectedBloodGroup');
    }

    if (_imageBytes != null || _hasPhoto) {
      notes.add('--- Profile Photo ---\nPhoto uploaded (${_imageName ?? "Selected image"})');
    }

    // Format Contact Details
    final contactList = <String>[];
    if (_mobileCtrl.text.trim().isNotEmpty) contactList.add('Mobile: ${_mobileCtrl.text.trim()}');
    if (_emailCtrl.text.trim().isNotEmpty) contactList.add('Email: ${_emailCtrl.text.trim()}');
    if (_whatsappCtrl.text.trim().isNotEmpty) contactList.add('WhatsApp: ${_whatsappCtrl.text.trim()}');
    if (contactList.isNotEmpty) {
      notes.add('--- Contact Details ---\n${contactList.join('\n')}');
    }

    // Format Address Details into structured notes
    final addressList = <String>[];
    if (_buildingCtrl.text.trim().isNotEmpty) {
      addressList.add('Building/Flat: ${_buildingCtrl.text.trim()}');
    }
    if (_areaCtrl.text.trim().isNotEmpty) {
      addressList.add('Area/Society: ${_areaCtrl.text.trim()}');
    }
    if (_pincodeCtrl.text.trim().isNotEmpty) {
      addressList.add('Pincode: ${_pincodeCtrl.text.trim()}');
    }
    if (addressList.isNotEmpty) {
      notes.add('--- Address Details ---\n${addressList.join('\n')}');
    }

    // Vankar Samaj verification tag
    notes.add('--- Vankar Community Status ---\nVankar Member: $_isVankar');

    if (_incomeCtrl.text.trim().isNotEmpty) {
      notes.add('--- Income ---\nYearly Income: ${_incomeCtrl.text.trim()}');
    }

    // Format Family Details into structured notes
    final familyList = <String>[];
    if (_fatherNameCtrl.text.trim().isNotEmpty) {
      familyList.add('Father: ${_fatherNameCtrl.text.trim()}${_fatherOccCtrl.text.trim().isNotEmpty ? " (${_fatherOccCtrl.text.trim()})" : ""}');
    }
    if (_fatherPhoneCtrl.text.trim().isNotEmpty) {
      familyList.add('Father Contact: ${_fatherPhoneCtrl.text.trim()}');
    }
    if (_motherNameCtrl.text.trim().isNotEmpty) {
      familyList.add('Mother: ${_motherNameCtrl.text.trim()}${_motherOccCtrl.text.trim().isNotEmpty ? " (${_motherOccCtrl.text.trim()})" : ""}');
    }
    if (_guardianPhoneCtrl.text.trim().isNotEmpty) {
      familyList.add('Guardian Contact: ${_guardianPhoneCtrl.text.trim()}');
    }
    if (_siblingsCtrl.text.trim().isNotEmpty) {
      familyList.add('Siblings: ${_siblingsCtrl.text.trim()}');
    }
    if (_mamasVillageCtrl.text.trim().isNotEmpty) {
      familyList.add("Mama's Village / Mosal: ${_mamasVillageCtrl.text.trim()}");
    }
    if (_nativeMosalCtrl.text.trim().isNotEmpty) {
      familyList.add('Native Place: ${_nativeMosalCtrl.text.trim()}');
    }
    if (familyList.isNotEmpty) {
      notes.add('--- Family Details ---\n${familyList.join('\n')}');
    }

    if (_aboutCtrl.text.trim().isNotEmpty) {
      notes.add('--- About Me ---\n${_aboutCtrl.text.trim()}');
    }

    String? finalAbout = notes.isNotEmpty ? notes.join('\n\n') : null;
    if (finalAbout != null && finalAbout.length > 2000) {
      finalAbout = finalAbout.substring(0, 2000);
    }

    String? cityVal = _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim();
    if (cityVal != null && cityVal.length > 100) {
      cityVal = cityVal.substring(0, 100);
    }

    String? stateVal = _stateCtrl.text.trim().isEmpty ? null : _stateCtrl.text.trim();
    if (stateVal != null && stateVal.length > 100) {
      stateVal = stateVal.substring(0, 100);
    }

    String? countryVal = _countryCtrl.text.trim().isEmpty ? null : _countryCtrl.text.trim();
    if (countryVal != null && countryVal.length > 100) {
      countryVal = countryVal.substring(0, 100);
    }

    String resolvedCaste = _selectedCaste ?? 'Hindu-Vankar (હિન્દુ-વણકર)';
    if (resolvedCaste == 'Other (અન્ય જ્ઞાતિ - Manually Add)') {
      resolvedCaste = _customCasteCtrl.text.trim();
    }

    final result = ProfileFormResult(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      dateOfBirth: dob,
      gender: _selectedGender!,
      maritalStatus: _selectedMaritalStatus!,
      religion:
          _religionCtrl.text.trim().isEmpty ? null : _religionCtrl.text.trim(),
      caste: resolvedCaste.isEmpty ? null : resolvedCaste,
      city: cityVal,
      state: stateVal,
      country: countryVal,
      education: _educationCtrl.text.trim().isEmpty
          ? null
          : _educationCtrl.text.trim(),
      occupation: _occupationCtrl.text.trim().isEmpty
          ? null
          : _occupationCtrl.text.trim(),
      about: finalAbout,
      imageBytes: _imageBytes,
      photoUrl: _imageBytes != null
          ? 'data:image/jpeg;base64,${base64Encode(_imageBytes!)}'
          : null,
    );

    await widget.onSubmit(result);
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final firstAllowed = DateTime(1940, 1, 1);
    final lastAllowed = DateTime(now.year - 18, now.month, now.day);

    DateTime initial = _dateOfBirth ?? DateTime(now.year - 25, 1, 1);
    if (initial.isAfter(lastAllowed)) initial = lastAllowed;
    if (initial.isBefore(firstAllowed)) initial = firstAllowed;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstAllowed,
      lastDate: lastAllowed,
      helpText: 'Select Date of Birth (18+ required)',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
        _dobCtrl.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  Widget _buildDatePicker(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date of Birth (જન્મ તારીખ) *',
          style: TextStyle(
            color: AppColors.goldAccent,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _dobCtrl,
          readOnly: true,
          onTap: () => _pickDate(context),
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          decoration: _inputDecoration(
            id: 'profile_dob',
            hintText: 'Tap to select date of birth (તારીખ પસંદ કરો)',
            icon: Icons.cake_outlined,
          ),
          validator: (v) {
            if (_dateOfBirth == null || v == null || v.trim().isEmpty) {
              return 'Date of birth is required (જન્મ તારીખ જરૂરી છે)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String id,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int? maxLength,
    int maxLines = 1,
    bool required = true,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    final cleanLabel = label.replaceAll('*', '').trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.goldAccent,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          decoration: _inputDecoration(
            id: id,
            hintText: 'Enter $cleanLabel',
            icon: icon,
          ),
          validator: validator ??
              (required
                  ? (v) {
                      if (v == null || v.trim().isEmpty) return '$cleanLabel is required';
                      return null;
                    }
                  : null),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String id,
    required String label,
    required String? value,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
    required String? Function(String?)? validator,
  }) {
    final cleanLabel = label.replaceAll('*', '').trim();
    final validValue = items.contains(value) ? value : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.goldAccent,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: validValue,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          dropdownColor: Colors.white,
          decoration: _inputDecoration(
            id: id,
            hintText: 'Select $cleanLabel',
            icon: icon,
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                _formatEnum(item),
                style: const TextStyle(color: Colors.black87),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String id,
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _sectionHeader(ThemeData theme, String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF061A3A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.goldAccent.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.goldAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.goldAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatEnum(String raw) {
    return raw.replaceAll('_', ' ').split(' ').map((w) {
      if (w.isEmpty) return w;
      return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
    }).join(' ');
  }
}
