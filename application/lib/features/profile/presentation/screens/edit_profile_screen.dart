import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/constants/gov_departments.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  Uint8List? _profileImageBytes;
  final ImagePicker _picker = ImagePicker();

  String _employmentType = 'Government Sector (સરકારી નોકરી / સેકટર)';
  String _department = 'State Government (રાજ્ય સરકાર)';
  String _govCategory = 'Select Category';
  String _pargana = 'Select Pargana';
  String? _gender;
  String? _maritalStatus;
  String? _bloodGroup;
  String? _isVankar;
  String? _casteCategory;
  String? _dob;

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
        _dob = "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              _buildTextField('First Name (પ્રથમ નામ) *', 'Enter First Name (પ્રથમ નામ)', Icons.badge_outlined),
              _buildTextField('Last Name (અટક / ઉપનામ) *', 'Enter Last Name (અટક / ઉપનામ)', Icons.badge_outlined),
              _buildTextField(
                'Date of Birth *',
                _dob ?? 'Tap to select date of birth',
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
                value: _gender,
                onChanged: (v) => setState(() => _gender = v),
              ),
              _buildDropdownField('Marital Status (વૈવાહિક સ્થિતિ) *', 'Never Married (અપરિણીત)', Icons.favorite_border, ['Never Married (અપરિણીત)', 'Divorced (છૂટાછેડા લીધેલ)', 'Widowed (વિધવા / વિધુર)', 'Awaiting Divorce (છૂટાછેડાની રાહમાં)']),
              _buildDropdownField('Blood Group (બ્લડ ગ્રુપ)', 'Select Blood Group', Icons.water_drop_outlined, ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Don\'t Know (ખબર નથી)']),
              _buildDropdownField('Are you Vankar? (તમે વણકર છો?) *', 'Yes (હા)', Icons.verified_user_outlined, ['Yes (હા)', 'No (ના)']),
              _buildTextField('Religion (ધર્મ) *', 'Enter Religion (ધર્મ)', Icons.settings_brightness),
              _buildDropdownField('Caste Category (જ્ઞાતિ પસંદ કરો) *', 'Hindu-vankar (હિન્દુ-વણકર)', Icons.groups_outlined, ['Hindu-Vankar (હિન્દુ-વણકર)', 'Buddhist-Vankar (બૌદ્ધ-વણકર)', 'Christian-Vankar (ખ્રિસ્તી-વણકર)', 'Muslim-Vankar (મુસ્લિમ-વણકર)', 'Other (અન્ય)']),

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
              _buildTextField('City / Taluka (શહેર / તાલુકો) *', 'Enter City / Taluka (શહેર / તાલુકો)', Icons.location_city),
              _buildTextField('District & State (જિલ્લો અને રાજ્ય) *', 'Enter District & State (જિલ્લો અને રાજ્ય)', Icons.map_outlined),
              _buildTextField('Country (દેશ) *', 'Enter Country (દેશ)', Icons.public),
              _buildTextField('Pincode / Zip Code (પીનકોડ)', 'Enter Pincode / Zip Code (પીનકોડ)', Icons.markunread_mailbox_outlined),

              const SizedBox(height: 24),
              // Career & Employment Details Section
              _buildSectionHeader(Icons.work_outline, 'Career & Employment Details (શિક્ષણ, વ્યવસાય અને નોકરીની વિગત)'),
              const SizedBox(height: 16),
              _buildTextField('Education / Degree (અભ્યાસ / ડિગ્રી) *', 'Enter Education / Degree (અભ્યાસ / ડિગ્રી)', Icons.school_outlined),
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
              ],
              if (_employmentType.contains('Private')) ...[
                _buildDropdownField(
                  'Private Sector Industry / Category (ખાનગી નોકરીનો પ્રકાર)',
                  'Select Industry',
                  Icons.business_center_outlined,
                  ['Select Category', 'IT / Software', 'Banking / Finance', 'Healthcare / Medical', 'Engineering / Manufacturing', 'Education / Teaching', 'Sales / Marketing', 'Admin / HR', 'Other (અન્ય)'],
                  value: ['Select Category', 'IT / Software', 'Banking / Finance', 'Healthcare / Medical', 'Engineering / Manufacturing', 'Education / Teaching', 'Sales / Marketing', 'Admin / HR', 'Other (અન્ય)'].contains(_govCategory) ? _govCategory : 'Select Category',
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
                  'Select Business Type',
                  Icons.storefront_outlined,
                  ['Select Category', 'Retail / Shop (દુકાન)', 'Wholesale / Trading (જથ્થાબંધ વેપાર)', 'Manufacturing (ઉત્પાદન)', 'Agriculture / Farming (ખેતી)', 'Real Estate / Construction', 'Consultancy / Services', 'Other (અન્ય)'],
                  value: ['Select Category', 'Retail / Shop (દુકાન)', 'Wholesale / Trading (જથ્થાબંધ વેપાર)', 'Manufacturing (ઉત્પાદન)', 'Agriculture / Farming (ખેતી)', 'Real Estate / Construction', 'Consultancy / Services', 'Other (અન્ય)'].contains(_govCategory) ? _govCategory : 'Select Category',
                  onChanged: (v) => setState(() => _govCategory = v ?? 'Select Category'),
                ),
                _buildTextField(
                  'Business / Shop Name (દુકાન / વ્યવસાયનું નામ)',
                  'Enter Business Name',
                  Icons.store_outlined,
                  onChanged: (v) => setState(() => _department = v),
                ),
              ],
              _buildTextField('Designation / Detailed Occupation (હોદ્દો / વ્યવસાય વિગત) *', 'Enter Designation / Detailed Occupation...', Icons.badge_outlined),
              _buildTextField('Yearly Income (વાર્ષિક આવક - રૂ.)', 'Enter Yearly Income (વાર્ષિક આવક - રૂ.)', Icons.payments_outlined),

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
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
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

  Widget _buildTextField(String label, String hint, IconData prefixIcon, {bool isDropdown = false, bool isMultiline = false, void Function(String)? onChanged, bool readOnly = false, VoidCallback? onTap}) {
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
                style: const TextStyle(color: Color(0xFFFFD700), fontSize: 13, fontWeight: FontWeight.bold),
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
                  items: items.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item, style: const TextStyle(color: Colors.black87)),
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
