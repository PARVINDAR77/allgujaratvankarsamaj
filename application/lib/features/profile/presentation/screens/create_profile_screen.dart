import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../../../shared/models/profile_model.dart';
import '../../../../shared/constants/gov_departments.dart';
import '../../providers/master_data_provider.dart';
import '../../../community/providers/samaj_services_provider.dart';
import '../../../../shared/models/samaj_service.dart';
import '../../../../shared/widgets/samaj_service_picker_sheet.dart';
import '../../../../shared/constants/pargana_constants.dart';

class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  ConsumerState<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  Uint8List? _profileImageBytes;
  final List<Uint8List> _galleryPhotosBytes = [];
  String _idProofType = 'Aadhaar Card (આધાર કાર્ડ)';
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
  bool _isSubmitting = false;

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

  // Contact Details
  String _mobileNumber = '';
  String _emailAddress = '';
  String _whatsappNumber = '';

  // Location & Address
  String _houseNumber = '';
  String _area = '';
  String _country = 'India';
  String _pincode = '';

  // Family Details
  String _fatherName = '';
  String _fatherOccupation = '';
  String _fatherContact = '';
  String _motherName = '';
  String _motherOccupation = '';
  String _guardianContact = '';
  String _siblings = '';
  String _mamasVillage = '';
  String _nativePlace = '';

  // About Me
  String _aboutMe = '';

  Future<void> _pickGalleryPhotos() async {
    if (_galleryPhotosBytes.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('તમે વધુમાં વધુ ૫ ફોટા પસંદ કરી શકો છો (Maximum 5 candidate photos allowed)'),
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
          if (_galleryPhotosBytes.length >= 5) break;
          final bytes = await file.readAsBytes();
          if (bytes.length > 5 * 1024 * 1024) {
            skippedTooLarge++;
            continue;
          }
          _galleryPhotosBytes.add(bytes);
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
          if (_galleryPhotosBytes.length < 5) {
            setState(() {
              _galleryPhotosBytes.add(bytes);
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error picking gallery photos: $e');
    }
  }

  void _removeGalleryPhoto(int index) {
    if (index >= 0 && index < _galleryPhotosBytes.length) {
      setState(() {
        _galleryPhotosBytes.removeAt(index);
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

  Future<void> _submitProfile() async {
    final mobile = _mobileNumber.trim();
    final email = _emailAddress.trim();
    final altMobile = _whatsappNumber.trim();
    final fatherPhone = _fatherContact.trim();
    final guardianPhone = _guardianContact.trim();
    final pin = _pincode.trim();

    // 1. Mobile number validation (10 digits starting with 6-9)
    if (mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('કૃપા કરીને 10 અંકનો મોબાઇલ નંબર દાખલ કરો (Please enter mobile number)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('મોબાઇલ નંબર માન્ય 10 અંકનો હોવો જોઈએ (Mobile number must be a valid 10-digit number starting with 6-9)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. Email validation
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('કૃપા કરીને ઈમેઈલ સરનામું દાખલ કરો (Please enter email address)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('કૃપા કરીને માન્ય ઈમેઈલ સરનામું દાખલ કરો (Please enter a valid email address)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 3. Alt / WhatsApp phone validation
    if (altMobile.isNotEmpty && !RegExp(r'^[6-9]\d{9}$').hasMatch(altMobile)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('વોટ્સએપ / વૈકલ્પિક મોબાઇલ નંબર માન્ય 10 અંકનો હોવો જોઈએ (WhatsApp/Alt phone must be 10 digits starting with 6-9)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 4. Father contact validation
    if (fatherPhone.isNotEmpty && !RegExp(r'^[6-9]\d{9}$').hasMatch(fatherPhone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('પિતાનો ફોન નંબર માન્ય 10 અંકનો હોવો જોઈએ (Father contact must be 10 digits starting with 6-9)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 5. Guardian contact validation
    if (guardianPhone.isNotEmpty && !RegExp(r'^[6-9]\d{9}$').hasMatch(guardianPhone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('વાલીનો સંપર્ક નંબર માન્ય 10 અંકનો હોવો જોઈએ (Guardian contact must be 10 digits starting with 6-9)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 6. Pincode validation
    if (pin.isNotEmpty && !RegExp(r'^\d{6}$').hasMatch(pin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('પીનકોડ બરાબર 6 અંકનો હોવો જોઈએ (Pincode must be exactly 6 digits)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 7. Profile Photo validation (Main photo or gallery)
    if (_profileImageBytes == null && _galleryPhotosBytes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('કૃપા કરીને પ્રોફાઇલ ફોટો પસંદ કરો (Please upload profile photo)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 8. Candidate Photos validation (2 to 5 photos)
    if (_galleryPhotosBytes.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('કૃપા કરીને ઓછામાં ઓછા ૨ ઉમેદવારના ફોટા પસંદ કરો (Please upload at least 2 candidate photos, maximum 5 allowed)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_galleryPhotosBytes.length > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ઉમેદવારના વધુમાં વધુ ૫ ફોટા માન્ય છે (Maximum 5 candidate photos allowed)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 9. ID Proof validation (Front & Back both mandatory)
    if (_idFrontBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('સરકારી ઓળખપત્રનો આગળનો ફોટો (Front Side) ફરજિયાત છે (ID Proof Front photo is mandatory)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_idBackBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('સરકારી ઓળખપત્રનો પાછળનો ફોટો (Back Side) ફરજિયાત છે (ID Proof Back photo is mandatory)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

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

    // Upload Main Profile Photo (Top)
    String? uploadedMainPhoto;
    if (_profileImageBytes != null) {
      uploadedMainPhoto = await uploadBytes(_profileImageBytes!, 'profile_main');
    }

    // Upload Candidate Gallery Photos (Bottom, 2 to 5 images)
    final List<String> uploadedPhotoUrls = [];
    if (uploadedMainPhoto != null) {
      uploadedPhotoUrls.add(uploadedMainPhoto);
    }
    for (int i = 0; i < _galleryPhotosBytes.length; i++) {
      final u = await uploadBytes(_galleryPhotosBytes[i], 'profile_gallery_$i');
      if (u != null && !uploadedPhotoUrls.contains(u)) {
        uploadedPhotoUrls.add(u);
      }
    }

    // Upload ID Proof Front and Back (Bottom)
    final String? uploadedIdFront = await uploadBytes(_idFrontBytes!, 'id_proof_front');
    final String? uploadedIdBack = await uploadBytes(_idBackBytes!, 'id_proof_back');

    final String? primaryPhotoUrl = uploadedMainPhoto ?? (uploadedPhotoUrls.isNotEmpty
        ? uploadedPhotoUrls[0]
        : null);

    final uniqueId = 'VNK${math.Random().nextInt(90000) + 10000}';
    final password = '${math.Random().nextInt(900000) + 100000}'; // 6 digit random pass

    final fullAddress = [_houseNumber.trim(), _area.trim()].where((s) => s.isNotEmpty).join(', ');

    final newProfile = ProfileModel(
      id: uniqueId,
      firstName: _firstName.isNotEmpty ? _firstName : 'New',
      lastName: _lastName.isNotEmpty ? _lastName : 'User',
      photoUrl: primaryPhotoUrl,
      photos: uploadedPhotoUrls,
      idProofType: _idProofType,
      idProofFrontUrl: uploadedIdFront,
      idProofBackUrl: uploadedIdBack,
      gender: ProfileModel.normalizeGenderToDisplay(_gender),
      maritalStatus: _maritalStatus ?? 'Never Married (અપરિણીત)',
      dateOfBirth: _dob ?? '2000-01-01',
      bloodGroup: _bloodGroup != null && _bloodGroup != 'Select Blood Group' ? _bloodGroup : null,
      isVankar: _isVankar != 'No (ના)',
      religion: _religion != 'Select Religion' ? _religion : 'Hindu (હિન્દુ)',
      caste: _casteCategory ?? 'Hindu-Vankar (હિન્દુ-વણકર)',
      education: _education == 'Other Qualification (અન્ય)' ? _customEducation : (_education != 'Select Degree' ? _education : 'Not Specified'),
      employmentType: _employmentType,
      department: _employmentType.contains('Government')
          ? (_govCategory == 'Other (અન્ય)' ? _customGovCategory : (_govCategory != 'Select Category' ? _govCategory : _department))
          : _department,
      designation: _designation.isNotEmpty ? _designation : 'Employee',
      annualIncome: _yearlyIncome != 'Select Income' ? _yearlyIncome : null,
      district: _district.isNotEmpty ? _district : 'Ahmedabad',
      taluka: _taluka.isNotEmpty ? _taluka : 'Ahmedabad City',
      pargana: _pargana != 'Select Pargana' ? _pargana : (_nativePlace.isNotEmpty ? _nativePlace : 'Not Specified'),
      nativePlace: _nativePlace.isNotEmpty ? _nativePlace : (_pargana != 'Select Pargana' ? _pargana : null),
      addressLine: fullAddress.isNotEmpty ? fullAddress : null,
      country: _country.isNotEmpty ? _country : 'India',
      pincode: _pincode.isNotEmpty ? _pincode : null,
      isPhysicallyDisabled: _isPhysicallyDisabled,
      pwbdCategory: _pwbdCategory,
      isAbroad: _isAbroad,
      abroadCountry: _abroadCountry,
      businessIndustry: _employmentType.contains('Business') ? (_businessIndustry == 'Select Industry' ? null : _businessIndustry) : null,
      businessService: _employmentType.contains('Business') ? (_businessService == 'Select Service' ? null : _businessService) : null,
      fatherName: _fatherName.isNotEmpty ? _fatherName : null,
      fatherOccupation: _fatherOccupation.isNotEmpty ? _fatherOccupation : null,
      fatherContact: _fatherContact.isNotEmpty ? _fatherContact : null,
      motherName: _motherName.isNotEmpty ? _motherName : null,
      motherOccupation: _motherOccupation.isNotEmpty ? _motherOccupation : null,
      guardianContact: _guardianContact.isNotEmpty ? _guardianContact : null,
      siblings: _siblings.isNotEmpty ? _siblings : null,
      mamasVillage: _mamasVillage.isNotEmpty ? _mamasVillage : null,
      contactPhone: _mobileNumber.isNotEmpty ? _mobileNumber : null,
      altPhone: _whatsappNumber.isNotEmpty ? _whatsappNumber : null,
      contactEmail: _emailAddress.isNotEmpty ? _emailAddress : null,
      about: _aboutMe.isNotEmpty ? _aboutMe : null,
    );

    String finalProfileId = uniqueId;
    try {
      final repository = ref.read(profileRepositoryProvider);
      final created = await repository.createProfile(newProfile);
      finalProfileId = created.id.isNotEmpty ? created.id : uniqueId;
      ref.invalidate(myProfileProvider);
      await ref.read(authNotifierProvider.notifier).checkVerificationStatus();
      ref.read(profileNotifierProvider.notifier).fetchFirstPage();
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
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
                      Text(finalProfileId, style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
    final masterData = ref.watch(masterDataProvider);
    final samajServicesAsync = ref.watch(samajServicesProvider);
    final samajServicesList = samajServicesAsync.value ?? [];

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
              // Main Profile Photo Upload (Top)
              _buildMainPhotoUpload(),
              const SizedBox(height: 24),

              // Personal Details Section
              _buildSectionHeader(Icons.person_outline, 'Personal Details (અંગત માહિતી)'),
              const SizedBox(height: 16),
              _buildTextField('First Name (પ્રથમ નામ) *', 'Enter First Name (પ્રથમ નામ)', Icons.badge_outlined, onChanged: (v) => setState(() => _firstName = v)),
              _buildTextField('Last Name (અટક / ઉપનામ) *', 'Enter Last Name (અટક / ઉપનામ)', Icons.badge_outlined, onChanged: (v) => setState(() => _lastName = v)),
              _buildTextField('Date of Birth *', _dob ?? 'Tap to select date of birth', Icons.cake_outlined, isDropdown: true, readOnly: true, onTap: () => _selectDate(context)),
              _buildDropdownField('Gender (જાતિ) *', 'Male (પુરુષ)', Icons.people_alt_outlined, ['Male (પુરુષ)', 'Female (સ્ત્રી)'], value: _gender, onChanged: (v) => setState(() => _gender = v)),
              _buildDropdownField('Marital Status (વૈવાહિક સ્થિતિ) *', 'Never Married (અપરિણીત)', Icons.favorite_border, ['Never Married (અપરિણીત)', 'Married (પરિણીત)', 'Divorced (છૂટાછેડા લીધેલ)', 'Widowed (વિધવા / વિધુર)', 'Awaiting Divorce (છૂટાછેડાની રાહમાં)'], value: _maritalStatus, onChanged: (v) => setState(() => _maritalStatus = v)),
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
              _buildTextField(
                'Mobile Number (મોબાઈલ નંબર - 10 અંક) *',
                'Enter 10-digit Mobile Number',
                Icons.phone_android,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: (v) => setState(() => _mobileNumber = v),
              ),
              _buildTextField(
                'Email Address (ઈમેઈલ સરનામું) *',
                'Enter Email Address (ઈમેઈલ સરનામું)',
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                onChanged: (v) => setState(() => _emailAddress = v),
              ),
              _buildTextField(
                'WhatsApp / Alt Phone (વોટ્સએપ નંબર - 10 અંક)',
                'Enter 10-digit WhatsApp / Alt Phone...',
                Icons.chat_bubble_outline,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: (v) => setState(() => _whatsappNumber = v),
              ),

              const SizedBox(height: 24),
              // Location & Address Section
              _buildSectionHeader(Icons.location_on_outlined, 'Location & Address (રહેઠાણનું સરનામું)'),
              const SizedBox(height: 16),
              _buildTextField('Flat / House / Building Name & No. (મકાન / બિલ્ડિંગ નંબર)', 'Enter Flat / House / Building Name & No...', Icons.domain, onChanged: (v) => setState(() => _houseNumber = v)),
              _buildTextField('Area / Society / Landmark (સોસાયટી / વિસ્તાર / લેન્ડમાર્ક)', 'Enter Area / Society / Landmark...', Icons.explore_outlined, onChanged: (v) => setState(() => _area = v)),
              _buildTextField('City / Taluka (શહેર / તાલુકો) *', 'Enter City / Taluka (શહેર / તાલુકો)', Icons.location_city, onChanged: (v) => setState(() => _taluka = v)),
              _buildTextField('District & State (જિલ્લો અને રાજ્ય) *', 'Enter District & State (જિલ્લો અને રાજ્ય)', Icons.map_outlined, onChanged: (v) => setState(() => _district = v)),
              _buildDropdownField(
                'Which Pargana you have? (તમારું પરગણું કયું છે?) *', 
                'Select Pargana', 
                Icons.account_tree_outlined, 
                kParganaOptions,
                value: kParganaOptions.contains(_pargana) ? _pargana : 'Select Pargana',
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
              _buildTextField('Country (દેશ) *', 'Enter Country (દેશ)', Icons.public, onChanged: (v) => setState(() => _country = v)),
              _buildTextField(
                'Pincode / Zip Code (પીનકોડ - 6 અંક)',
                'Enter 6-digit Pincode',
                Icons.markunread_mailbox_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: (v) => setState(() => _pincode = v),
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
                  onChanged: (v) => setState(() => _department = v),
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
                  onChanged: (v) => setState(() => _department = v),
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
              _buildTextField('Father\'s Name (પિતાનું નામ) *', 'Enter Father\'s Name (પિતાનું નામ)', Icons.person_outline, onChanged: (v) => setState(() => _fatherName = v)),
              _buildTextField('Father\'s Occupation (પિતાનો વ્યવસાય)', 'Enter Father\'s Occupation (પિતાનો વ્યવસાય)', Icons.work_outline, onChanged: (v) => setState(() => _fatherOccupation = v)),
              _buildTextField(
                'Father\'s Contact Number (પિતાનો ફોન નંબર - 10 અંક)',
                'Enter 10-digit Father\'s Contact Number...',
                Icons.phone,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: (v) => setState(() => _fatherContact = v),
              ),
              _buildTextField('Mother\'s Name (માતાનું નામ) *', 'Enter Mother\'s Name (માતાનું નામ)', Icons.face_3_outlined, onChanged: (v) => setState(() => _motherName = v)),
              _buildTextField('Mother\'s Occupation (માતાનો વ્યવસાય)', 'Enter Mother\'s Occupation (માતાનો વ્યવસાય)', Icons.work_outline, onChanged: (v) => setState(() => _motherOccupation = v)),
              _buildTextField(
                'Guardian Contact Number (વાલીનો સંપર્ક નંબર - 10 અંક)',
                'Enter 10-digit Guardian Contact Number...',
                Icons.contact_phone_outlined,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: (v) => setState(() => _guardianContact = v),
              ),
              _buildTextField('Brothers & Sisters (ભાઈ-બહેનની વિગત)', 'Enter Brothers & Sisters (ભાઈ-બહેનની વિગત)', Icons.groups_outlined, onChanged: (v) => setState(() => _siblings = v)),
              _buildTextField('Mama\'s Village / Mosal (મોસાળ / મોસાળનું ગામ)', 'Enter Mama\'s Village / Mosal...', Icons.holiday_village_outlined, onChanged: (v) => setState(() => _mamasVillage = v)),
              _buildTextField('Native Place (મૂળ વતન / પરગણું)', 'Enter Native Place (મૂળ વતન / પરગણું)', Icons.home_work_outlined, onChanged: (v) => setState(() => _nativePlace = v)),

              const SizedBox(height: 24),
              // About Me Section
              _buildSectionHeader(Icons.info_outline, 'About Me (પોતાના વિશે વિશેષ માહિતી)'),
              const SizedBox(height: 16),
              _buildTextField('Tell us about yourself (વધારાની વિગતો)', 'Enter Tell us about yourself (વધારાની વિગતો)', Icons.notes, isMultiline: true, onChanged: (v) => setState(() => _aboutMe = v)),

              const SizedBox(height: 28),
              // Box 1: Multiple Candidate Photos (2 to 5 images) - Bottom
              _buildCandidatePhotosBox(),
              const SizedBox(height: 20),

              // Box 2: ID Proof Verification (Front & Back Mandatory) - Bottom
              _buildIdProofBox(),
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

  Widget _buildTextField(
    String label, 
    String hint, 
    IconData prefixIcon, {
    bool isDropdown = false, 
    bool isMultiline = false, 
    Function(String)? onChanged, 
    bool readOnly = false, 
    VoidCallback? onTap,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
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
              border: Border.all(color: errorText != null ? Colors.red : Colors.grey.shade300),
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
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
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
          if (errorText != null) ...[
            const SizedBox(height: 4),
            Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
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

  Widget _buildMainPhotoUpload() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _profileImageBytes != null ? const Color(0xFFD4AF37) : Colors.grey.shade300,
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
                color: _profileImageBytes != null ? const Color(0xFFD4AF37) : Colors.grey.shade300,
                width: 2,
              ),
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
                  'Upload Profile Photo (પ્રોફાઇલ ફોટો અપલોડ કરો)',
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
                    _profileImageBytes != null
                        ? 'Change Photo (ફોટો બદલો)'
                        : 'Choose Photo (ફોટો પસંદ કરો)',
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
    final photoCount = _galleryPhotosBytes.length;
    final isCountValid = photoCount >= 2 && photoCount <= 5;

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
                  '$photoCount / 5',
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

          // Photos preview
          if (_galleryPhotosBytes.isNotEmpty) ...[
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (int i = 0; i < _galleryPhotosBytes.length; i++)
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
                            image: MemoryImage(_galleryPhotosBytes[i]),
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
                          onTap: () => _removeGalleryPhoto(i),
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
                if (_galleryPhotosBytes.length < 5)
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
              photoCount < 2
                  ? '⚠️ હજી ઓછામાં ઓછો ${2 - photoCount} ફોટો ઉમેરવો જરૂરી છે. (Please add ${2 - photoCount} more photo)'
                  : '✓ ફોટો બરાબર છે ($photoCount પસંદ કર્યા). તમે ઈચ્છો તો વધુ ${5 - photoCount} ઉમેરી શકો છો.',
              style: TextStyle(
                color: photoCount < 2 ? Colors.amber.shade900 : Colors.green.shade800,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else ...[
            GestureDetector(
              onTap: _pickGalleryPhotos,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.6),
                    width: 1.5,
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.add_a_photo_outlined, color: Color(0xFFD4AF37), size: 40),
                    SizedBox(height: 10),
                    Text(
                      'Click here to choose 2 to 5 photos (૨ થી ૫ ફોટા પસંદ કરો)',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'કેમેરા અથવા ગેલેરીમાંથી ઉમેદવારના સુંદર ફોટા પસંદ કરો (Max 5 MB per image)',
                      style: TextStyle(color: Colors.black54, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIdProofBox() {
    final hasFront = _idFrontBytes != null;
    final hasBack = _idBackBytes != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (hasFront && hasBack) ? Colors.green.shade400 : const Color(0xFF1E3A8A).withOpacity(0.4),
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
                  color: const Color(0xFF1E3A8A).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.badge_outlined, color: Color(0xFF1E3A8A), size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
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
                        color: Colors.redAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (hasFront && hasBack) ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (hasFront && hasBack) ? Colors.green.shade400 : Colors.red.shade300,
                  ),
                ),
                child: Text(
                  (hasFront && hasBack) ? '✓ Completed' : 'Required *',
                  style: TextStyle(
                    color: (hasFront && hasBack) ? Colors.green.shade800 : Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ID Type Dropdown
          const Text(
            'Select Document Type (ઓળખપત્રનો પ્રકાર) *',
            style: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _idProofType,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
                items: _idProofOptions.map((opt) {
                  return DropdownMenuItem<String>(
                    value: opt,
                    child: Text(opt, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _idProofType = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Two separate upload cards: Front & Back
          Row(
            children: [
              // Front side card
              Expanded(
                child: _buildIdCardSide(
                  title: 'Front Side (આગળનો ભાગ) *',
                  imageBytes: _idFrontBytes,
                  onPick: _pickIdFront,
                  onRemove: () => setState(() => _idFrontBytes = null),
                ),
              ),
              const SizedBox(width: 12),
              // Back side card
              Expanded(
                child: _buildIdCardSide(
                  title: 'Back Side (પાછળનો ભાગ) *',
                  imageBytes: _idBackBytes,
                  onPick: _pickIdBack,
                  onRemove: () => setState(() => _idBackBytes = null),
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
    required Uint8List? imageBytes,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    final hasImg = imageBytes != null;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasImg ? Colors.green.shade400 : Colors.grey.shade300,
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
              if (hasImg)
                GestureDetector(
                  onTap: onRemove,
                  child: const Icon(Icons.cancel, color: Colors.red, size: 16),
                ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onPick,
            child: Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
                image: hasImg
                    ? DecorationImage(
                        image: MemoryImage(imageBytes),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: hasImg
                  ? Container(
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Tap to change',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined, color: Color(0xFFD4AF37), size: 28),
                        SizedBox(height: 4),
                        Text(
                          'Upload Image',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
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
