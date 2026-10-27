import 'package:flutter/foundation.dart';
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
import '../../../home/presentation/widgets/web_home_header.dart';
import '../../../home/presentation/widgets/web_home_footer.dart';

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
          if (kIsWeb) {
            return _buildWebLoadingScaffold();
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
          if (kIsWeb) {
            return _buildWebErrorScaffold(context, id);
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

    if (kIsWeb) {
      return _buildWebNotFoundScaffold(context);
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
    if (kIsWeb) {
      return _buildWebContent(context, profile);
    }
    return _buildMobileContent(context, profile);
  }

  Widget _buildMobileContent(BuildContext context, ProfileModel profile) {
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
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
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
                      _buildDetailRow('ભાઈ-બહેનની વિગત (Brothers & Sisters)', profile.displaySiblings),
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

                  // 💼 સમાજ વ્યવસાય પ્રોફાઇલ (Samaj Business Profile)
                  if ((profile.businessIndustry != null && profile.businessIndustry!.isNotEmpty) ||
                      (profile.businessService != null && profile.businessService!.isNotEmpty) ||
                      profile.employmentType.toLowerCase().contains('business') ||
                      profile.employmentType.toLowerCase().contains('સ્વરોજગાર') ||
                      profile.employmentType.toLowerCase().contains('વેપાર')) ...[
                    const SizedBox(height: 12),
                    _buildBusinessCard(profile),
                  ],

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
                  ? (e, s) {}
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

          // ID Tag (Only for unmarried candidate, else Married badge)
          if (!profile.isMarried)
            InkWell(
              onTap: () {
                if (profile.cleanDisplayId.isNotEmpty) {
                  Clipboard.setData(ClipboardData(text: profile.cleanDisplayId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('ID કોપી થયો: ${profile.cleanDisplayId} (Copied Matrimonial ID)'),
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
                      'ID: ${profile.cleanDisplayId.isNotEmpty ? profile.cleanDisplayId : "CANDIDATE"}',
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
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade300, width: 1),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.family_restroom, size: 14, color: Color(0xFFFFD700)),
                  SizedBox(width: 6),
                  Text(
                    'પરિણીત સભ્ય (Married Member)',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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

  Widget _buildBusinessCard(ProfileModel profile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF041126), Color(0xFF0F2B5C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF041126).withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Color(0xFFD4AF37),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'સમાજ વ્યવસાય પ્રોફાઇલ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Samaj Business Directory Registered',
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 12, color: Color(0xFF10B981)),
                    SizedBox(width: 4),
                    Text(
                      'સર્વિસ લિંક્ડ',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                if (profile.department.isNotEmpty && profile.department != 'Not specified')
                  _buildBusinessRow('પેઢી / દુકાનનું નામ (Business)', profile.department, Icons.business),
                if (profile.designation.isNotEmpty && profile.designation != 'Not specified')
                  _buildBusinessRow('હોદ્દો (Designation / Role)', profile.designation, Icons.badge_outlined),
                if (profile.businessIndustry != null && profile.businessIndustry!.isNotEmpty)
                  _buildBusinessRow('ઉદ્યોગ / ક્ષેત્ર (Industry)', profile.businessIndustry!, Icons.category_outlined),
                if (profile.businessService != null && profile.businessService!.isNotEmpty)
                  _buildBusinessRow('સમાજ સેવા (Service Title)', profile.businessService!, Icons.handshake_outlined),
                if (profile.city != null && profile.city!.isNotEmpty)
                  _buildBusinessRow('સ્થળ (City / Place)', profile.city!, Icons.location_on_outlined),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.white70),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'આ વ્યવસાય આપમેળે "સમાજ સર્વિસીસ" ડિરેક્ટરીમાં લિંક થયેલ છે.',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFD4AF37)),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.bold,
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
    final isMarried = profile.isMarried;
    if (isMarried) {
      final phone = profile.fatherContact ?? profile.altPhone;
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle, size: 14, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 4),
                        Text(
                          'પરિણીત સભ્ય (Married Member)',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                        ),
                      ],
                    ),
                    Text(
                      'સમાજ ડિરેક્ટરી સભ્ય - વૈવાહિક પ્રસ્તાવ અક્ષમ છે',
                      style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _shareProfile(profile),
                icon: const Icon(Icons.share, size: 15),
                label: const Text('Share (શેર)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0056D2),
                  side: const BorderSide(color: Color(0xFF0056D2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              if (phone != null && phone.trim().isNotEmpty) ...[
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final uri = Uri.parse('tel:${phone.replaceAll(' ', '')}');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                  icon: const Icon(Icons.call, size: 15),
                  label: const Text('Call', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    final authState = ref.watch(authNotifierProvider);
    final myProfile = ref.watch(myProfileProvider).valueOrNull;
    final isOwner = (authState.user?.id != null && authState.user!.id == profile.id) ||
                    (myProfile != null && myProfile.id == profile.id);

    final isLiked = ref.watch(isProfileLikedProvider(profile.id));
    final connStatusAsync = ref.watch(connectionStatusProvider(profile.id));

    return Container(
      color: Colors.white,
      child: Center(
        heightFactor: 1.0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Container(
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
                  // Shortlist / Like Icon Button
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isLiked ? Colors.redAccent : Colors.grey.shade300,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => ref.read(likedProfilesProvider.notifier).toggleLike(profile, context: context),
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey<bool>(isLiked),
                          color: isLiked ? Colors.redAccent : Colors.grey.shade700,
                        ),
                      ),
                      tooltip: isLiked ? 'પસંદ કરેલ લિસ્ટમાંથી દૂર કરો' : 'Shortlist (પસંદ કરો)',
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
                            error: (e, s) => _buildConnectButton(context, profile),
                            data: (status) => _buildConnectionButton(context, profile, status),
                          ),
                  ),
                ],
              ),
            ),
          ),
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
    if (context.mounted) {
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
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('વિનંતી નકારવામાં આવી છે.')),
      );
    }
  }

  void _shareProfile(ProfileModel profile) {
    final isMarried = profile.isMarried;
    final text = isMarried
        ? 'સમસ્ત ગુજરાત વણકર સમાજ ડિરેક્ટરી:\n'
          'નામ: ${profile.fullName}\n'
          'શિક્ષણ: ${profile.education}\n'
          'વ્યવસાય: ${profile.displayProfession}\n'
          'સ્થળ: ${profile.displayLocation}'
        : 'સમસ્ત ગુજરાત વણકર સમાજ મેટ્રિમોનિયલ પ્રોફાઇલ:\n'
          'નામ: ${profile.fullName}\n'
          'જાતિ: ${profile.displayGender}\n'
          'ઉંમર: ${profile.displayDob}\n'
          'શિક્ષણ: ${profile.education}\n'
          'વ્યવસાય: ${profile.displayProfession}\n'
          'સ્થળ: ${profile.displayLocation}\n'
          'આઈડી: ${profile.cleanDisplayId}';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('પ્રોફાઈલ વિગત કોપી થઈ ગઈ છે! (Profile details copied to clipboard!)'),
        backgroundColor: Color(0xFF0056D2),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ==========================================
  // WEB PORTAL ADAPTATION (kIsWeb == true)
  // ==========================================

  Widget _buildWebContent(BuildContext context, ProfileModel profile) {
    final isLiked = ref.watch(isProfileLikedProvider(profile.id));
    final authState = ref.watch(authNotifierProvider);
    final myProfile = ref.watch(myProfileProvider).valueOrNull;
    final isOwner = (authState.user?.id != null && authState.user!.id == profile.id) ||
                    (myProfile != null && myProfile.id == profile.id);
    final isMobileBlocked = profile.isMobileBlockedForViewer(isOwner: isOwner);
    final isEmailBlocked = profile.isEmailBlockedForViewer(isOwner: isOwner);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: const WebHomeHeader(activeRoute: '/search'),
      body: SelectionArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              // Top Breadcrumbs & Quick Action Bar
              _buildWebBreadcrumbBar(context, profile, isLiked),

              // Main Responsive Layout (Desktop 2-Column or Stacked)
              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 960;
                      if (isDesktop) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 360,
                              child: _buildWebSidebar(context, profile, isLiked, isOwner),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildWebDetailsColumn(
                                context,
                                profile,
                                isOwner,
                                isMobileBlocked,
                                isEmailBlocked,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildWebSidebar(context, profile, isLiked, isOwner),
                            const SizedBox(height: 24),
                            _buildWebDetailsColumn(
                              context,
                              profile,
                              isOwner,
                              isMobileBlocked,
                              isEmailBlocked,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),

              // Web Portal Footer
              const WebHomeFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebBreadcrumbBar(BuildContext context, ProfileModel profile, bool isLiked) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/search');
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF1E293B)),
                      SizedBox(width: 6),
                      Text(
                        'પાછા જાઓ (Back)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => context.go('/home'),
                        child: const Text(
                          'હોમ (Home)',
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text('›', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                      ),
                      InkWell(
                        onTap: () => context.go('/search'),
                        child: const Text(
                          'લગ્ન સાથી (Matrimony)',
                          style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text('›', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                      ),
                      Text(
                        profile.fullName,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Shortlist Button
              OutlinedButton.icon(
                onPressed: () => ref.read(likedProfilesProvider.notifier).toggleLike(profile, context: context),
                icon: Icon(
                  isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 16,
                  color: isLiked ? Colors.redAccent : const Color(0xFF475569),
                ),
                label: Text(
                  isLiked ? 'પસંદ કરેલ (Shortlisted)' : 'શોર્ટલિસ્ટ (Shortlist)',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isLiked ? Colors.redAccent : const Color(0xFF475569),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isLiked ? Colors.redAccent : const Color(0xFFCBD5E1)),
                  backgroundColor: isLiked ? const Color(0xFFFFF1F2) : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 8),
              // Share Button
              OutlinedButton.icon(
                onPressed: () => _shareProfile(profile),
                icon: const Icon(Icons.share_rounded, size: 16, color: Color(0xFF475569)),
                label: const Text(
                  'શેર (Share)',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebSidebar(BuildContext context, ProfileModel profile, bool isLiked, bool isOwner) {
    final themePrimary = profile.isFemale ? const Color(0xFFC2185B) : const Color(0xFF0056D2);
    final themeLight = profile.isFemale ? const Color(0xFFFCE4EC) : const Color(0xFFE3F2FD);
    final themeText = profile.isFemale ? const Color(0xFF880E4F) : const Color(0xFF0D47A1);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Medallion Hero Card
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF051329), Color(0xFF0E2850)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                // Circular Medallion Avatar with gold ring
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFD700), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 54,
                    backgroundColor: const Color(0xFF0D1B3E),
                    backgroundImage: profile.fullPhotoUrl != null
                        ? NetworkImage(profile.fullPhotoUrl!)
                        : null,
                    onBackgroundImageError: profile.fullPhotoUrl != null
                        ? (e, s) {}
                        : null,
                    child: profile.fullPhotoUrl == null
                        ? const Icon(Icons.person, size: 56, color: Color(0xFFFFD700))
                        : null,
                  ),
                ),
                const SizedBox(height: 14),

                // Candidate Name
                Text(
                  profile.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Clean Matrimonial ID Tag with tap-to-copy (Only for unmarried candidates)
                if (!profile.isMarried)
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: profile.cleanDisplayId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('ID કોપી થયો: ${profile.cleanDisplayId} (Copied Matrimonial ID)'),
                          backgroundColor: const Color(0xFF0056D2),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.badge_outlined, size: 14, color: Color(0xFFFFD700)),
                          const SizedBox(width: 6),
                          Text(
                            'ID: ${profile.cleanDisplayId.isNotEmpty ? profile.cleanDisplayId : "CANDIDATE"}',
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.copy_rounded, size: 13, color: Color(0xFFFFD700)),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.family_restroom, size: 14, color: Color(0xFFFFD700)),
                        SizedBox(width: 6),
                        Text(
                          'પરિણીત સભ્ય (Married Member)',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),

                // Status Badges
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
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
          ),

          // Sidebar Details & Actions
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 4 Highlight Quick Stats (2x2 Grid)
                Row(
                  children: [
                    Expanded(
                      child: _buildWebStatBox(
                        icon: Icons.cake_outlined,
                        label: 'ઉંમર (Age)',
                        value: profile.age != null ? '${profile.age} Yrs' : 'Specified',
                        color: const Color(0xFFE91E63),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildWebStatBox(
                        icon: Icons.favorite_border_rounded,
                        label: 'વૈવાહિક (Status)',
                        value: profile.maritalStatus.split(' ').first,
                        color: const Color(0xFF9C27B0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildWebStatBox(
                        icon: Icons.school_outlined,
                        label: 'શિક્ષણ (Edu)',
                        value: profile.education.isNotEmpty ? profile.education.split(' ').first : 'N/A',
                        color: const Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildWebStatBox(
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

                const Divider(height: 28, thickness: 1, color: Color(0xFFF1F5F9)),

                // Connection Action Block (Integrated directly on sidebar, NO floating bottom sheet!)
                _buildWebConnectionBlock(context, profile, isOwner),

                const SizedBox(height: 16),

                // Trust & Security Note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.shield_outlined, size: 18, color: Color(0xFFD97706)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'સમાજ સુરક્ષા: ગોપનીયતા જાળવવા બંને પક્ષોની કનેક્શન સ્વીકૃતિ બાદ જ અંગત ચેટ સક્રિય થશે.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF92400E),
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebStatBox({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildWebConnectionBlock(BuildContext context, ProfileModel profile, bool isOwner) {
    final isMarried = profile.isMarried;
    if (isMarried) {
      final phone = profile.contactPhone ?? profile.altPhone;
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF59E0B)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF2E7D32)),
                SizedBox(width: 6),
                Text(
                  'પરિણીત સભ્ય (Married Member)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF92400E)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'સમાજ ડિરેક્ટરી સભ્ય - વૈવાહિક પ્રસ્તાવ અક્ષમ છે\n(Directory Member - Proposals Disabled)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: Color(0xFF78350F), height: 1.3),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareProfile(profile),
                    icon: const Icon(Icons.share_rounded, size: 15),
                    label: const Text('શેર (Share)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0056D2),
                      side: const BorderSide(color: Color(0xFF0056D2)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                if (phone != null && phone.trim().isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse('tel:${phone.replaceAll(' ', '')}');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      icon: const Icon(Icons.call, size: 15),
                      label: const Text('Call', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    }

    if (isOwner) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Text(
          'આ તમારી પોતાની પ્રોફાઇલ છે (Your Own Profile)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF64748B)),
        ),
      );
    }

    final connStatusAsync = ref.watch(connectionStatusProvider(profile.id));

    return connStatusAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0056D2)),
          ),
        ),
      ),
      error: (e, s) => _buildWebConnectButton(context, profile),
      data: (status) => _buildWebConnectionButton(context, profile, status),
    );
  }

  Widget _buildWebConnectionButton(BuildContext context, ProfileModel profile, ConnectionStatusResponse status) {
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
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _acceptConnectionRequest(context, profile, status.interestId!),
              icon: const Icon(Icons.check_circle_rounded, size: 17),
              label: const Text('સ્વીકારો (Accept Request)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _declineConnectionRequest(context, profile, status.interestId!),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('નકારો (Decline)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
            ),
          ),
        ],
      );
    }

    return _buildWebConnectButton(context, profile);
  }

  Widget _buildWebConnectButton(BuildContext context, ProfileModel profile) {
    return ElevatedButton.icon(
      onPressed: () => _expressInterest(context, profile),
      icon: const Icon(Icons.person_add_rounded, size: 18),
      label: const Text(
        '+ કનેક્શન વિનંતી મોકલો (Connect)',
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

  Widget _buildWebDetailsColumn(
    BuildContext context,
    ProfileModel profile,
    bool isOwner,
    bool isMobileBlocked,
    bool isEmailBlocked,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Personal Details
        _buildWebCard(
          titleGuj: 'વ્યક્તિગત વિગતો',
          titleEng: 'Personal Details & Biodata',
          icon: Icons.person_outline_rounded,
          iconColor: const Color(0xFF0056D2),
          children: [
            _buildWebGrid([
              _WebGridItem('પૂરું નામ (Full Name)', profile.fullName),
              _WebGridItem('જાતિ (Gender)', profile.displayGender),
              _WebGridItem('જન્મ તારીખ (Date of Birth)', profile.displayDob),
              if (profile.age != null) _WebGridItem('ઉંમર (Age)', '${profile.age} Years (વર્ષ)'),
              _WebGridItem('લગ્ન સ્થિતિ (Marital Status)', profile.maritalStatus),
              _WebGridItem('ધર્મ (Religion)', (profile.religion != null && profile.religion!.isNotEmpty) ? profile.religion! : 'Hindu (હિન્દુ)'),
              _WebGridItem('જ્ઞાતિ (Caste Category)', profile.caste ?? 'Hindu-Vankar (હિન્દુ-વણકર)'),
              _WebGridItem('રક્ત જૂથ (Blood Group)', profile.bloodGroup != null && profile.bloodGroup!.isNotEmpty ? profile.bloodGroup! : 'Not specified'),
              _WebGridItem('વણકર સમાજ (Vankar Community)', profile.isVankar == true ? 'Yes (હા - વણકર સમાજ)' : 'No (ના)'),
              _WebGridItem('માતૃભાષા (Mother Tongue)', profile.motherTongue != null && profile.motherTongue!.isNotEmpty ? profile.motherTongue! : 'ગુજરાતી (Gujarati)'),
            ]),
          ],
        ),

        const SizedBox(height: 16),

        // 2. Family Details & Native Roots
        _buildWebCard(
          titleGuj: 'પરિવારની વિગતો અને મોસાળ',
          titleEng: 'Family Details & Native Roots',
          icon: Icons.family_restroom_rounded,
          iconColor: const Color(0xFFE91E63),
          children: [
            _buildWebGrid([
              _WebGridItem('પિતાનું નામ (Father\'s Name)', profile.fatherName ?? 'Not specified'),
              _WebGridItem('પિતાનો વ્યવસાય (Father\'s Occupation)', profile.fatherOccupation ?? 'Not specified'),
              _WebGridItem('માતાનું નામ (Mother\'s Name)', profile.motherName ?? 'Not specified'),
              _WebGridItem('માતાનો વ્યવસાય (Mother\'s Occupation)', profile.motherOccupation ?? 'Not specified'),
              _WebGridItem('ભાઈ-બહેનની વિગત (Brothers & Sisters)', profile.displaySiblings),
              _WebGridItem('મોસાળ / મોસાળનું ગામ (Mama\'s Village / Mosal)', profile.mamasVillage ?? 'Not specified'),
              _WebGridItem('મૂળ વતન / પરગણું (Native Place / Pargana)', profile.nativePlace ?? (profile.pargana.isNotEmpty ? profile.pargana : 'Not specified')),
            ]),
            if (profile.fatherContact != null && profile.fatherContact!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildContactRowWithAction(
                'પિતાનો ફોન (Father\'s Contact)',
                profile.fatherContact!,
                Icons.phone,
                Colors.green,
              ),
            ],
            if (profile.guardianContact != null && profile.guardianContact!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildContactRowWithAction(
                'વાલીનો સંપર્ક (Guardian Contact)',
                profile.guardianContact!,
                Icons.phone,
                Colors.teal,
              ),
            ],
          ],
        ),

        const SizedBox(height: 16),

        // 3. Education & Career
        _buildWebCard(
          titleGuj: 'શિક્ષણ અને વ્યવસાય',
          titleEng: 'Education & Professional Career',
          icon: Icons.school_outlined,
          iconColor: const Color(0xFF2E7D32),
          children: [
            _buildWebGrid([
              _WebGridItem('શિક્ષણ / ડિગ્રી (Education)', profile.education.isNotEmpty ? profile.education : 'Not specified'),
              _WebGridItem('રોજગારી પ્રકાર (Employment Type)', profile.employmentType.isNotEmpty ? profile.employmentType : 'Not specified'),
              _WebGridItem('હોદ્દો / પદ (Designation / Role)', profile.designation.isNotEmpty ? profile.designation : 'Not specified'),
              _WebGridItem('ખાતું / સંસ્થા / કંપની (Organization / Dept)', profile.department.isNotEmpty ? profile.department : 'Not specified'),
              _WebGridItem('વાર્ષિક આવક (Annual Income)', profile.annualIncome != null && profile.annualIncome!.isNotEmpty ? profile.annualIncome! : 'Not specified'),
              if (profile.businessIndustry != null && profile.businessIndustry!.isNotEmpty)
                _WebGridItem('ઉદ્યોગ ક્ષેત્ર (Business Industry)', profile.businessIndustry!),
              if (profile.businessService != null && profile.businessService!.isNotEmpty)
                _WebGridItem('સેવા વિગત (Business Service)', profile.businessService!),
            ]),
          ],
        ),

        // Samaj Business Profile if available
        if ((profile.businessIndustry != null && profile.businessIndustry!.isNotEmpty) ||
            (profile.businessService != null && profile.businessService!.isNotEmpty) ||
            profile.employmentType.toLowerCase().contains('business') ||
            profile.employmentType.toLowerCase().contains('સ્વરોજગાર') ||
            profile.employmentType.toLowerCase().contains('વેપાર')) ...[
          const SizedBox(height: 16),
          _buildBusinessCard(profile),
        ],

        const SizedBox(height: 16),

        // 4. Location & Address
        _buildWebCard(
          titleGuj: 'સ્થળ અને સરનામું',
          titleEng: 'Location & Native Address',
          icon: Icons.location_on_outlined,
          iconColor: const Color(0xFFD84315),
          children: [
            _buildWebGrid([
              if (profile.addressLine != null && profile.addressLine!.isNotEmpty)
                _WebGridItem('સરનામું (Address)', profile.addressLine!),
              _WebGridItem('તાલુકો / શહેર (Taluka / City)', profile.taluka.isNotEmpty ? profile.taluka : (profile.city ?? 'Not specified')),
              _WebGridItem('જિલ્લો / રાજ્ય (District / State)', profile.district.isNotEmpty ? profile.district : (profile.state ?? 'Not specified')),
              if (profile.pincode != null && profile.pincode!.isNotEmpty)
                _WebGridItem('પીનકોડ (Pincode)', profile.pincode!),
              _WebGridItem('પરગણું (Pargana)', profile.pargana.isNotEmpty ? profile.pargana : 'Not specified'),
              _WebGridItem('દેશ (Country)', profile.country ?? 'India (ભારત)'),
            ]),
          ],
        ),

        const SizedBox(height: 16),

        // 5. Contact Information
        _buildWebCard(
          titleGuj: 'સંપર્ક માહિતી',
          titleEng: 'Contact Information',
          icon: Icons.phone_android_rounded,
          iconColor: const Color(0xFF00897B),
          children: [
            if (isMobileBlocked) ...[
              _buildDetailRow(
                'મોબાઈલ નંબર (Mobile Number)',
                '🔒 ગોપનીય (માત્ર મને - સુરક્ષા માટે ગુપ્ત)',
                valueColor: const Color(0xFFC2185B),
                isBold: true,
              ),
              Container(
                margin: const EdgeInsets.only(top: 4, bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              _buildWebGrid([
                _WebGridItem(
                  'મોબાઈલ નંબર (Mobile Number)',
                  (profile.contactPhone != null && profile.contactPhone!.isNotEmpty)
                      ? (isOwner && profile.effectiveMobilePrivacy == 'માત્ર મને'
                          ? '${profile.contactPhone!} (🔒 માત્ર મને - અન્ય લોકો માટે ગુપ્ત)'
                          : profile.contactPhone!)
                      : 'Available upon Express Interest',
                ),
                if (profile.altPhone != null && profile.altPhone!.isNotEmpty)
                  _WebGridItem('વોટ્સએપ / અન્ય ફોન (WhatsApp / Alt)', profile.altPhone!),
              ]),
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

        const SizedBox(height: 16),

        // 6. Special Information
        _buildWebCard(
          titleGuj: 'અન્ય વિશેષ વિગતો',
          titleEng: 'Special Information',
          icon: Icons.info_outline_rounded,
          iconColor: const Color(0xFF6A1B9A),
          children: [
            _buildWebGrid([
              _WebGridItem(
                'દિવ્યાંગતા (Physically Disabled)',
                profile.isPhysicallyDisabled == true
                    ? 'હા / Yes (${profile.pwbdCategory ?? "Not specified"})'
                    : 'ના / No',
              ),
              _WebGridItem(
                'વિદેશ નિવાસ (Residing Abroad)',
                profile.isAbroad == true
                    ? 'હા / Yes (${profile.abroadCountry ?? "Not specified"})'
                    : 'ના / No',
              ),
              _WebGridItem(
                'પ્રોફાઇલ પ્રમાણિત (Verified Profile)',
                profile.isVerified == true ? 'હા / Verified ✓' : 'અપ્રમાણિત / Under Review',
              ),
            ]),
          ],
        ),

        // 7. About Candidate
        if (profile.about != null && profile.about!.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildWebCard(
            titleGuj: 'પોતાના વિશે',
            titleEng: 'About Candidate',
            icon: Icons.notes_rounded,
            iconColor: const Color(0xFF00838F),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  profile.about!.trim(),
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: Color(0xFF1E293B),
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildWebCard({
    required String titleGuj,
    required String titleEng,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      titleEng,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF1F5F9)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildWebGrid(List<_WebGridItem> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTwoCol = constraints.maxWidth >= 550;
        if (!isTwoCol) {
          return Column(
            children: items.map((item) => _buildDetailRow(item.label, item.value)).toList(),
          );
        }

        final rows = <Widget>[];
        for (int i = 0; i < items.length; i += 2) {
          final item1 = items[i];
          final item2 = (i + 1 < items.length) ? items[i + 1] : null;

          rows.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildWebGridCell(item1.label, item1.value)),
                  const SizedBox(width: 20),
                  Expanded(
                    child: item2 != null
                        ? _buildWebGridCell(item2.label, item2.value)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(children: rows);
      },
    );
  }

  Widget _buildWebGridCell(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13.5,
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildWebLoadingScaffold() {
    return const Scaffold(
      backgroundColor: Color(0xFFFAF8F5),
      appBar: WebHomeHeader(activeRoute: '/search'),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF0056D2)),
                  SizedBox(height: 16),
                  Text(
                    'ઉમેદવાર પ્રોફાઇલ વિગતો લોડ થઈ રહી છે...\nLoading candidate profile details...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          WebHomeFooter(),
        ],
      ),
    );
  }

  Widget _buildWebErrorScaffold(BuildContext context, String id) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: const WebHomeHeader(activeRoute: '/search'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              constraints: const BoxConstraints(minHeight: 400),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEE2E2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFDC2626)),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'પ્રોફાઇલ લોડ થઈ શકી નથી',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'ઉમેદવારની માહિતી મેળવવામાં સમસ્યા આવી છે. કૃપા કરીને ફરી પ્રયાસ કરો અથવા ઉમેદવાર યાદી પર પાછા જાઓ.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go('/search');
                                }
                              },
                              icon: const Icon(Icons.arrow_back_rounded, size: 16),
                              label: const Text('પાછા જાઓ'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => ref.refresh(candidateProfileByIdProvider(id)),
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text('ફરી પ્રયાસ કરો'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0056D2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const WebHomeFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildWebNotFoundScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: const WebHomeHeader(activeRoute: '/search'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              constraints: const BoxConstraints(minHeight: 400),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_search_rounded, size: 56, color: Color(0xFF64748B)),
                      const SizedBox(height: 16),
                      const Text(
                        'ઉમેદવાર મળ્યા નથી',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'વિનંતી કરેલ ઉમેદવારની પ્રોફાઇલ ઉપલબ્ધ નથી અથવા કાઢી નાખવામાં આવી છે.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/search'),
                        icon: const Icon(Icons.search_rounded),
                        label: const Text('ઉમેદવારો શોધો (Search Candidates)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0056D2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const WebHomeFooter(),
          ],
        ),
      ),
    );
  }
}

class _WebGridItem {
  final String label;
  final String value;
  const _WebGridItem(this.label, this.value);
}
