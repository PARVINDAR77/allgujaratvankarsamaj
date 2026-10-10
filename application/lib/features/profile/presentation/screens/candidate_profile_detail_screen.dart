import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/profile_model.dart';
import '../../../../shared/models/chat_models.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/liked_profiles_provider.dart';
import '../../../chat/providers/chat_provider.dart';

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
    final id = (widget.profileId != null && widget.profileId!.trim().isNotEmpty)
        ? widget.profileId!.trim()
        : widget.profile?.id.trim();

    if (id != null && id.isNotEmpty) {
      final profileAsync = ref.watch(candidateProfileByIdProvider(id));

      return profileAsync.when(
        data: (loadedProfile) => _buildContent(context, loadedProfile),
        loading: () {
          // If a preview profile was passed in extra, display it immediately
          if (widget.profile != null) {
            return _buildContent(context, widget.profile!);
          }
          return Scaffold(
            backgroundColor: const Color(0xFF070C18),
            appBar: AppBar(
              title: const Text('Loading Profile...', style: TextStyle(color: Color(0xFFFFD700))),
              backgroundColor: const Color(0xFF070C18),
              iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
            ),
            body: const Center(
              child: CircularProgressIndicator(color: Color(0xFF0056D2)),
            ),
          );
        },
        error: (err, stack) {
          // If network fetch fails but we have the preview profile, display it gracefully
          if (widget.profile != null) {
            return _buildContent(context, widget.profile!);
          }
          return Scaffold(
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
          );
        },
      );
    }

    if (widget.profile != null) {
      return _buildContent(context, widget.profile!);
    }

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

  Widget _buildContent(BuildContext context, ProfileModel profile) {
    final themePrimary = profile.isFemale ? const Color(0xFFC2185B) : const Color(0xFF0056D2);
    final themeLight = profile.isFemale ? const Color(0xFFFCE4EC) : const Color(0xFFE3F2FD);
    final themeText = profile.isFemale ? const Color(0xFF880E4F) : const Color(0xFF0D47A1);
    final isLiked = ref.watch(isProfileLikedProvider(profile.id));

    final authState = ref.watch(authNotifierProvider);
    final myProfile = ref.watch(myProfileProvider).valueOrNull;
    final isOwner = (authState.user?.id != null && authState.user!.id == profile.id) ||
                    (myProfile != null && myProfile.id == profile.id);
    final isMobileBlocked = profile.isMobileBlockedForViewer(isOwner: isOwner);
    final isEmailBlocked = profile.isEmailBlockedForViewer(isOwner: isOwner);

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
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.redAccent : const Color(0xFFFFD700),
            ),
            tooltip: isLiked ? 'પસંદ કરેલ લિસ્ટમાંથી દૂર કરો' : 'પસંદ કરો (Like Profile)',
            onPressed: () => ref.read(likedProfilesProvider.notifier).toggleLike(profile, context: context),
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
                        _buildContactRowWithAction(
                          'પિતાનો ફોન (Father\'s Contact)',
                          profile.fatherContact!,
                          Icons.phone,
                          Colors.green,
                        ),
                      _buildDetailRow('માતાનું નામ (Mother\'s Name)', profile.motherName ?? 'Not specified'),
                      _buildDetailRow('માતાનો વ્યવસાય (Mother\'s Occupation)', profile.motherOccupation ?? 'Not specified'),
                      if (profile.guardianContact != null && profile.guardianContact!.isNotEmpty)
                        _buildContactRowWithAction(
                          'વાલીનો સંપર્ક (Guardian Contact)',
                          profile.guardianContact!,
                          Icons.phone,
                          Colors.teal,
                        ),
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
                      if (isMobileBlocked) ...[
                        _buildDetailRow(
                          'મોબાઈલ નંબર (Mobile Number)',
                          '🔒 ગોપનીય (માત્ર મને - સુરક્ષા માટે ગુપ્ત)',
                          valueColor: const Color(0xFFC2185B),
                          isBold: true,
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 4, bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFDBA74)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.shield_outlined, color: Color(0xFFE65100), size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'આ ઉમેદવારનો અંગત સંપર્ક નંબર સુરક્ષા માટે ગુપ્ત છે. લગ્ન સંબંધ માટે ઉપર આપેલ પિતા અથવા વાલીના નંબર પર સંપર્ક કરવો.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9A3412),
                                    fontWeight: FontWeight.w600,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        _buildDetailRow(
                          'મોબાઈલ નંબર (Mobile Number)',
                          (profile.contactPhone != null && profile.contactPhone!.isNotEmpty)
                              ? (isOwner && profile.effectiveMobilePrivacy == 'માત્ર મને'
                                  ? '${profile.contactPhone!} (🔒 માત્ર મને - અન્ય લોકો માટે ગુપ્ત)'
                                  : profile.contactPhone!)
                              : 'Available upon Express Interest',
                        ),
                        if (profile.altPhone != null && profile.altPhone!.isNotEmpty)
                          _buildDetailRow('વોટ્સએપ / અન્ય ફોન (WhatsApp / Alt)', profile.altPhone!),
                      ],
                      if (isEmailBlocked)
                        _buildDetailRow(
                          'ઈમેઈલ (Email)',
                          '🔒 ગોપનીય (Privacy Protected - માત્ર મને)',
                          valueColor: const Color(0xFFC2185B),
                          isBold: true,
                        )
                      else if (profile.contactEmail != null && profile.contactEmail!.isNotEmpty)
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

  Widget _buildDetailRow(String label, String value, {Color? valueColor, bool isBold = false}) {
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
              style: TextStyle(
                fontSize: 13,
                color: valueColor ?? Colors.black87,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRowWithAction(String label, String phone, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    phone,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
                    final uri = Uri.parse('tel:$cleanPhone');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.call, size: 14, color: Colors.green),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () async {
                    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
                    final uri = Uri.parse('https://wa.me/91$cleanPhone');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chat, size: 14, color: Colors.teal),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, ProfileModel profile) {
    final authState = ref.watch(authNotifierProvider);
    final myProfile = ref.watch(myProfileProvider).valueOrNull;
    final isOwner = (authState.user?.id != null && authState.user!.id == profile.id) ||
                    (myProfile != null && myProfile.id == profile.id);

    final connStatusAsync = ref.watch(connectionStatusProvider(profile.id));

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

            // Dynamic Action Button based on connection status
            Expanded(
              child: isOwner
                  ? Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'આ તમારી પોતાની પ્રોફાઇલ છે (Your Own Profile)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                      ),
                    )
                  : connStatusAsync.when(
                      loading: () => const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      error: (_, __) => _buildConnectButton(context, profile),
                      data: (status) => _buildConnectionButton(context, profile, status),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionButton(BuildContext context, ProfileModel profile, ConnectionStatusResponse status) {
    if (status.status == 'ACCEPTED') {
      return ElevatedButton.icon(
        onPressed: () => _openChat(context, profile, status.conversationId),
        icon: const Icon(Icons.chat_bubble_rounded, size: 18),
        label: const Text(
          '💬 ચેટ શરૂ કરો (Chat Now)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      );
    }

    if (status.status == 'PENDING_SENT') {
      return OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('તમારી કનેક્શન વિનંતી મોકલાઈ ગઈ છે. ઉમેદવારના સ્વીકારની રાહ જોવાઈ રહી છે.'),
              backgroundColor: Colors.amber,
              duration: Duration(seconds: 2),
            ),
          );
        },
        icon: const Icon(Icons.hourglass_top_rounded, size: 18, color: Color(0xFFD97706)),
        label: const Text(
          'વિનંતી મોકલાઈ ગઈ છે (Pending)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFD97706)),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: const Color(0xFFFFFBEB),
        ),
      );
    }

    if (status.status == 'PENDING_RECEIVED' && status.interestId != null) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _acceptConnectionRequest(context, profile, status.interestId!),
              icon: const Icon(Icons.check_circle_rounded, size: 17),
              label: const Text('સ્વીકારો (Accept)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => _declineConnectionRequest(context, profile, status.interestId!),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('નકારો', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Colors.grey)),
          ),
        ],
      );
    }

    return _buildConnectButton(context, profile);
  }

  Widget _buildConnectButton(BuildContext context, ProfileModel profile) {
    return ElevatedButton.icon(
      onPressed: () => _expressInterest(context, profile),
      icon: const Icon(Icons.person_add_rounded, size: 18),
      label: const Text(
        'કનેક્શન વિનંતી મોકલો (Connect)',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0056D2),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    );
  }

  Future<void> _openChat(BuildContext context, ProfileModel profile, String? conversationId) async {
    if (conversationId != null && conversationId.isNotEmpty) {
      context.push(
        '/chat/$conversationId',
        extra: {
          'partnerName': profile.fullName,
          'partnerPhotoUrl': profile.fullPhotoUrl,
          'partnerGender': profile.gender,
        },
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      final res = await ref.read(chatRepositoryProvider).getOrCreateConversation(profile.id);
      if (context.mounted) {
        Navigator.pop(context);
        if (res != null && res['conversationId'] != null) {
          context.push(
            '/chat/${res['conversationId']}',
            extra: {
              'partnerName': profile.fullName,
              'partnerPhotoUrl': profile.fullPhotoUrl,
              'partnerGender': profile.gender,
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ચેટ રૂમ ખોલવામાં સમસ્યા આવી')),
          );
        }
      }
    }
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
        } catch (_) {}
      } else {
        try {
          await dio.delete('/shortlists/${profile.id}');
        } catch (_) {}
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
              const Icon(Icons.person_add_rounded, size: 50, color: Color(0xFF0056D2)),
              const SizedBox(height: 12),
              const Text(
                'કનેક્શન વિનંતી મોકલો (Send Connection Request)',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'શું તમે ${profile.fullName} ને કનેક્શન વિનંતી મોકલવા માંગો છો?\nતેઓ વિનંતી સ્વીકાર્યા પછી તમે બંને એકબીજા સાથે સુરક્ષિત રીતે ચેટ કરી શકશો.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13.5, color: Colors.black87, height: 1.4),
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
                      child: const Text('હા, વિનંતી મોકલો (Send)'),
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
    final repo = ref.read(chatRepositoryProvider);
    final res = await repo.sendConnectionRequest(profile.id);

    try {
      final dio = ref.read(apiClientProvider);
      await dio.post('/shortlists', data: {'targetProfileId': profile.id});
    } catch (_) {}

    ref.invalidate(connectionStatusProvider(profile.id));

    if (mounted) {
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${profile.fullName} ને કનેક્શન વિનંતી સફળતાપૂર્વક મોકલી દેવાઈ છે! (Connection Request Sent!)',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message']?.toString() ?? 'વિનંતી મોકલી શકાઈ નથી'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _acceptConnectionRequest(BuildContext context, ProfileModel profile, String interestId) async {
    final repo = ref.read(chatRepositoryProvider);
    final res = await repo.acceptConnectionRequest(interestId);
    ref.invalidate(connectionStatusProvider(profile.id));
    if (mounted) {
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${profile.fullName} ની કનેક્શન વિનંતી સ્વીકારી લીધી છે! ચેટ અનલૉક થઈ ગઈ છે.'),
            backgroundColor: Colors.green,
          ),
        );
        _openChat(context, profile, res['conversationId']?.toString());
      }
    }
  }

  Future<void> _declineConnectionRequest(BuildContext context, ProfileModel profile, String interestId) async {
    final repo = ref.read(chatRepositoryProvider);
    await repo.declineConnectionRequest(interestId);
    ref.invalidate(connectionStatusProvider(profile.id));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('વિનંતી નકારવામાં આવી છે.')),
      );
    }
  }

  void _shareProfile(ProfileModel profile) {
    final text = 'સમસ્ત ગુજરાત વણકર સમાજ મેટ્રિમોનિયલ પ્રોફાઇલ:\n'
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
