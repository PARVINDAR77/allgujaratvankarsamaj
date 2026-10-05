import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/profile_model.dart';
import '../../providers/profile_provider.dart';

class CandidateProfileDetailScreen extends ConsumerStatefulWidget {
  final ProfileModel? profile;
  final String? profileId;

  const CandidateProfileDetailScreen({
    super.key,
    this.profile,
    this.profileId,
  });

  @override
  ConsumerState<CandidateProfileDetailScreen> createState() =>
      _CandidateProfileDetailScreenState();
}

class _CandidateProfileDetailScreenState
    extends ConsumerState<CandidateProfileDetailScreen> {
  bool _isShortlisted = false;
  bool _isProcessingShortlist = false;

  @override
  Widget build(BuildContext context) {
    if (widget.profile != null) {
      return _buildContent(context, widget.profile!);
    }

    final id = widget.profileId;
    if (id == null || id.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile Details (પ્રોફાઈલ વિગત)'),
          backgroundColor: const Color(0xFF070C18),
          foregroundColor: const Color(0xFFFFD700),
        ),
        body: const Center(
          child: Text('Profile not specified (પ્રોફાઈલ મળેલ નથી)'),
        ),
      );
    }

    final profileAsync = ref.watch(candidateProfileByIdProvider(id));

    return profileAsync.when(
      loading: () => Scaffold(
        backgroundColor: const Color(0xFF070C18),
        appBar: AppBar(
          title: const Text('Loading Profile...', style: TextStyle(color: Color(0xFFFFD700))),
          backgroundColor: const Color(0xFF070C18),
          iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF0056D2)),
        ),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: const Color(0xFF070C18),
        appBar: AppBar(
          title: const Text('Profile Details', style: TextStyle(color: Color(0xFFFFD700))),
          backgroundColor: const Color(0xFF070C18),
          iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load candidate profile.\nઆ ઉમેદવારની પ્રોફાઇલ લોડ થઈ શકી નથી.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => ref.refresh(candidateProfileByIdProvider(id)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry (ફરી પ્રયાસ કરો)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0056D2),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (loadedProfile) => _buildContent(context, loadedProfile),
    );
  }

  Widget _buildContent(BuildContext context, ProfileModel profile) {
    final themePrimary = profile.isFemale ? const Color(0xFFC2185B) : const Color(0xFF0056D2);
    final themeLight = profile.isFemale ? const Color(0xFFFCE4EC) : const Color(0xFFE3F2FD);
    final themeText = profile.isFemale ? const Color(0xFF880E4F) : const Color(0xFF0D47A1);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF070C18),
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
        title: Text(
          profile.fullName,
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFFFFD700)),
            tooltip: 'Share Profile (પ્રોફાઈલ શેર કરો)',
            onPressed: () => _shareProfile(profile),
          ),
          IconButton(
            icon: Icon(
              _isShortlisted ? Icons.favorite : Icons.favorite_border,
              color: _isShortlisted ? Colors.redAccent : const Color(0xFFFFD700),
            ),
            tooltip: 'Shortlist (પસંદ કરો)',
            onPressed: () => _toggleShortlist(profile),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            // Top Hero Header
            _buildHeroHeader(profile, themePrimary, themeLight, themeText),

            const SizedBox(height: 12),

            // 4 Highlights Cards (Age, Marital Status, Education, Location)
            _buildHighlightsRow(profile),

            const SizedBox(height: 12),

            // Detailed Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildSectionCard(
                    titleGuj: 'વ્યક્તિગત વિગતો',
                    titleEng: 'Personal Details',
                    icon: Icons.person_outline,
                    iconColor: const Color(0xFF0056D2),
                    items: [
                      _buildDetailRow('પૂરું નામ (Full Name)', profile.fullName),
                      _buildDetailRow('જાતિ (Gender)', profile.displayGender),
                      _buildDetailRow('જન્મ તારીખ (Date of Birth)', profile.displayDob),
                      if (profile.age != null) _buildDetailRow('ઉંમર (Age)', '${profile.age} Years (વર્ષ)'),
                      _buildDetailRow('લગ્ન સ્થિતિ (Marital Status)', profile.maritalStatus),
                      _buildDetailRow('ધર્મ (Religion)', (profile.religion != null && profile.religion!.isNotEmpty) ? profile.religion! : 'Hindu (હિન્દુ)'),
                      _buildDetailRow('જ્ઞાતિ (Caste Category)', profile.caste ?? 'Hindu-Vankar (હિન્દુ-વણકર)'),
                      _buildDetailRow('રક્ત જૂથ (Blood Group)', profile.bloodGroup != null && profile.bloodGroup!.isNotEmpty ? profile.bloodGroup! : 'Not specified'),
                      _buildDetailRow('વણકર સમાજ (Vankar Community)', profile.isVankar == true ? 'Yes (હા - વણકર સમાજ)' : 'No (ના)'),
                      _buildDetailRow('માતૃભાષા (Mother Tongue)', profile.motherTongue != null && profile.motherTongue!.isNotEmpty ? profile.motherTongue! : 'ગુજરાતી (Gujarati)'),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _buildSectionCard(
                    titleGuj: 'પરિવારની વિગતો અને મોસાળ',
                    titleEng: 'Family Details & Native Roots',
                    icon: Icons.family_restroom,
                    iconColor: const Color(0xFFE91E63),
                    items: [
                      _buildDetailRow('પિતાનું નામ (Father\'s Name)', profile.fatherName ?? 'Not specified'),
                      _buildDetailRow('પિતાનો વ્યવસાય (Father\'s Occupation)', profile.fatherOccupation ?? 'Not specified'),
                      if (profile.fatherContact != null && profile.fatherContact!.isNotEmpty)
                        _buildDetailRow('પિતાનો ફોન (Father\'s Contact)', profile.fatherContact!),
                      _buildDetailRow('માતાનું નામ (Mother\'s Name)', profile.motherName ?? 'Not specified'),
                      _buildDetailRow('માતાનો વ્યવસાય (Mother\'s Occupation)', profile.motherOccupation ?? 'Not specified'),
                      if (profile.guardianContact != null && profile.guardianContact!.isNotEmpty)
                        _buildDetailRow('વાલીનો સંપર્ક (Guardian Contact)', profile.guardianContact!),
                      _buildDetailRow('ભાઈ-બહેનની વિગત (Brothers & Sisters)', profile.siblings ?? 'Not specified'),
                      _buildDetailRow('મોસાળ / મોસાળનું ગામ (Mama\'s Village / Mosal)', profile.mamasVillage ?? 'Not specified'),
                      _buildDetailRow('મૂળ વતન / પરગણું (Native Place / Pargana)', profile.nativePlace ?? (profile.pargana.isNotEmpty ? profile.pargana : 'Not specified')),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _buildSectionCard(
                    titleGuj: 'શિક્ષણ અને વ્યવસાય',
                    titleEng: 'Education & Career',
                    icon: Icons.school_outlined,
                    iconColor: const Color(0xFF2E7D32),
                    items: [
                      _buildDetailRow(
                        'શિક્ષણ / ડિગ્રી (Education)',
                        profile.education.isNotEmpty ? profile.education : 'Not specified',
                      ),
                      _buildDetailRow(
                        'રોજગારી પ્રકાર (Employment Type)',
                        profile.employmentType.isNotEmpty ? profile.employmentType : 'Not specified',
                      ),
                      _buildDetailRow(
                        'હોદ્દો / પદ (Designation / Role)',
                        profile.designation.isNotEmpty ? profile.designation : 'Not specified',
                      ),
                      _buildDetailRow(
                        'ખાતું / સંસ્થા / કંપની (Organization / Dept)',
                        profile.department.isNotEmpty ? profile.department : 'Not specified',
                      ),
                      _buildDetailRow(
                        'વાર્ષિક આવક (Annual Income)',
                        profile.annualIncome != null && profile.annualIncome!.isNotEmpty ? profile.annualIncome! : 'Not specified',
                      ),
                      if (profile.businessIndustry != null && profile.businessIndustry!.isNotEmpty)
                        _buildDetailRow('ઉદ્યોગ ક્ષેત્ર (Business Industry)', profile.businessIndustry!),
                      if (profile.businessService != null && profile.businessService!.isNotEmpty)
                        _buildDetailRow('સેવા વિગત (Business Service)', profile.businessService!),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _buildSectionCard(
                    titleGuj: 'સ્થળ અને સરનામું',
                    titleEng: 'Location & Address',
                    icon: Icons.location_on_outlined,
                    iconColor: const Color(0xFFD84315),
                    items: [
                      if (profile.addressLine != null && profile.addressLine!.isNotEmpty)
                        _buildDetailRow('સરનામું (Address)', profile.addressLine!),
                      _buildDetailRow(
                        'તાલુકો / શહેર (Taluka / City)',
                        profile.taluka.isNotEmpty ? profile.taluka : (profile.city ?? 'Not specified'),
                      ),
                      _buildDetailRow(
                        'જિલ્લો / રાજ્ય (District / State)',
                        profile.district.isNotEmpty ? profile.district : (profile.state ?? 'Not specified'),
                      ),
                      if (profile.pincode != null && profile.pincode!.isNotEmpty)
                        _buildDetailRow('પીનકોડ (Pincode)', profile.pincode!),
                      _buildDetailRow('પરગણું (Pargana)', profile.pargana.isNotEmpty ? profile.pargana : 'Not specified'),
                      _buildDetailRow('દેશ (Country)', profile.country ?? 'India (ભારત)'),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _buildSectionCard(
                    titleGuj: 'સંપર્ક માહિતી',
                    titleEng: 'Contact Details',
                    icon: Icons.phone_android,
                    iconColor: const Color(0xFF00897B),
                    items: [
                      _buildDetailRow(
                        'મોબાઈલ નંબર (Mobile Number)',
                        profile.contactPhone != null && profile.contactPhone!.isNotEmpty
                            ? profile.contactPhone!
                            : 'Available upon Express Interest',
                      ),
                      if (profile.altPhone != null && profile.altPhone!.isNotEmpty)
                        _buildDetailRow('વોટ્સએપ / અન્ય ફોન (WhatsApp / Alt)', profile.altPhone!),
                      if (profile.contactEmail != null && profile.contactEmail!.isNotEmpty)
                        _buildDetailRow('ઈમેઈલ (Email)', profile.contactEmail!),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _buildSectionCard(
                    titleGuj: 'અન્ય વિશેષ વિગતો',
                    titleEng: 'Special Information',
                    icon: Icons.info_outline,
                    iconColor: const Color(0xFF6A1B9A),
                    items: [
                      _buildDetailRow(
                        'દિવ્યાંગતા (Physically Disabled)',
                        profile.isPhysicallyDisabled == true
                            ? 'હા / Yes (${profile.pwbdCategory ?? "Not specified"})'
                            : 'ના / No',
                      ),
                      _buildDetailRow(
                        'વિદેશ નિવાસ (Residing Abroad)',
                        profile.isAbroad == true
                            ? 'હા / Yes (${profile.abroadCountry ?? "Not specified"})'
                            : 'ના / No',
                      ),
                      _buildDetailRow(
                        'પ્રોફાઇલ પ્રમાણિત (Verified Profile)',
                        profile.isVerified == true ? 'હા / Verified ✓' : 'અપ્રમાણિત / Under Review',
                      ),
                    ],
                  ),

                  if (profile.about != null && profile.about!.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildSectionCard(
                      titleGuj: 'પોતાના વિશે',
                      titleEng: 'About Candidate',
                      icon: Icons.notes,
                      iconColor: const Color(0xFF00838F),
                      items: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            profile.about!.trim(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomActionBar(context, profile),
    );
  }

  Widget _buildHeroHeader(
    ProfileModel profile,
    Color themePrimary,
    Color themeLight,
    Color themeText,
  ) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF070C18),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Column(
        children: [
          // Avatar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFD700), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF0D1B3E),
              backgroundImage: profile.fullPhotoUrl != null
                  ? NetworkImage(profile.fullPhotoUrl!)
                  : null,
              onBackgroundImageError: profile.fullPhotoUrl != null
                  ? (_, __) {}
                  : null,
              child: profile.fullPhotoUrl == null
                  ? const Icon(Icons.person, size: 55, color: Color(0xFFFFD700))
                  : null,
            ),
          ),
          const SizedBox(height: 14),

          // Full Name
          Text(
            profile.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),

          // Full ID Tag with Tap to Copy
          InkWell(
            onTap: () {
              if (profile.id.isNotEmpty) {
                Clipboard.setData(ClipboardData(text: profile.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('ID કોપી થયો: ${profile.id} (Copied Profile ID)'),
                    backgroundColor: const Color(0xFF0056D2),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ID: ${profile.id.isNotEmpty ? profile.id : "CANDIDATE"}',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.copy_rounded, size: 14, color: Color(0xFFFFD700)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Badges Row
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              // Bride / Groom Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: themeLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: themePrimary, width: 1.2),
                ),
                child: Text(
                  profile.isFemale ? '👰 કન્યા (Bride)' : '👨 વર (Groom)',
                  style: TextStyle(
                    color: themeText,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Verification Badge
              if (profile.isVerified == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF4CAF50), width: 1.2),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 14, color: Color(0xFF2E7D32)),
                      SizedBox(width: 4),
                      Text(
                        'પ્રમાણિત (Verified)',
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightsRow(ProfileModel profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildHighlightCard(
              icon: Icons.cake_outlined,
              label: 'ઉંમર (Age)',
              value: profile.age != null ? '${profile.age} Yrs' : 'Specified',
              color: const Color(0xFFE91E63),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildHighlightCard(
              icon: Icons.favorite_border,
              label: 'વૈવાહિક (Status)',
              value: profile.maritalStatus.split(' ').first,
              color: const Color(0xFF9C27B0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildHighlightCard(
              icon: Icons.school_outlined,
              label: 'શિક્ષણ (Edu)',
              value: profile.education.isNotEmpty ? profile.education.split(' ').first : 'N/A',
              color: const Color(0xFF1976D2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildHighlightCard(
              icon: Icons.location_city_outlined,
              label: 'સ્થળ (City)',
              value: profile.taluka.isNotEmpty
                  ? profile.taluka
                  : (profile.city != null && profile.city!.isNotEmpty ? profile.city! : 'N/A'),
              color: const Color(0xFFE65100),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String titleGuj,
    required String titleEng,
    required IconData icon,
    required Color iconColor,
    required List<Widget> items,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleGuj,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      titleEng,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20, thickness: 0.8),
          ...items,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, ProfileModel profile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Shortlist Icon Button
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isShortlisted ? Colors.redAccent : Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: _isProcessingShortlist ? null : () => _toggleShortlist(profile),
                icon: Icon(
                  _isShortlisted ? Icons.favorite : Icons.favorite_border,
                  color: _isShortlisted ? Colors.redAccent : Colors.grey.shade700,
                ),
                tooltip: 'Shortlist (પસંદ કરો)',
              ),
            ),
            const SizedBox(width: 12),

            // Express Interest / Contact Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _expressInterest(context, profile),
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text(
                  'સંપર્ક કરો (Express Interest)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0056D2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleShortlist(ProfileModel profile) async {
    if (_isProcessingShortlist) return;
    setState(() => _isProcessingShortlist = true);

    try {
      final dio = ref.read(apiClientProvider);
      final newShortlistState = !_isShortlisted;

      if (newShortlistState) {
        try {
          await dio.post('/shortlists', data: {'targetProfileId': profile.id});
        } catch (_) {
          // Fallback gracefully if already exists or memory mode
        }
      } else {
        try {
          await dio.delete('/shortlists/${profile.id}');
        } catch (_) {
          // Fallback gracefully
        }
      }

      if (mounted) {
        setState(() {
          _isShortlisted = newShortlistState;
          _isProcessingShortlist = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isShortlisted
                  ? 'પ્રોફાઇલ પસંદ કરી શોર્ટલિસ્ટમાં ઉમેરી! (Profile Shortlisted!)'
                  : 'શોર્ટલિસ્ટમાંથી દૂર કરી. (Removed from Shortlist)',
            ),
            backgroundColor: _isShortlisted ? Colors.green : Colors.grey.shade800,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isShortlisted = !_isShortlisted;
          _isProcessingShortlist = false;
        });
      }
    }
  }

  void _expressInterest(BuildContext context, ProfileModel profile) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Icon(Icons.favorite, size: 50, color: Color(0xFFC2185B)),
              const SizedBox(height: 12),
              Text(
                'રસ દર્શાવો (Express Interest)',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'શું તમે ${profile.fullName} ની પ્રોફાઇલમાં રસ દર્શાવવા માંગો છો?\nતમારી વિગતો ઉમેદવારને મોકલવામાં આવશે.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('રદ કરો (Cancel)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _sendInterestRequest(profile);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0056D2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('હા, રસ દર્શાવો (Send)'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendInterestRequest(ProfileModel profile) async {
    try {
      final dio = ref.read(apiClientProvider);
      try {
        await dio.post('/shortlists', data: {'targetProfileId': profile.id});
      } catch (_) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${profile.fullName} ને તમારી રુચિ મોકલી દેવાઈ છે! (Interest Sent Successfully!)',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (_) {}
  }

  void _shareProfile(ProfileModel profile) {
    final text = 'સમસ્ત ગુજરાત વાંકર સમાજ મેટ્રિમોનિયલ પ્રોફાઇલ:\n'
        'નામ: ${profile.fullName}\n'
        'જાતિ: ${profile.displayGender}\n'
        'ઉંમર: ${profile.displayDob}\n'
        'શિક્ષણ: ${profile.education}\n'
        'વ્યવસાય: ${profile.displayProfession}\n'
        'સ્થળ: ${profile.displayLocation}\n'
        'આઈડી: ${profile.id}';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('પ્રોફાઈલ વિગત કોપી થઈ ગઈ છે! (Profile details copied to clipboard!)'),
        backgroundColor: Color(0xFF0056D2),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
