import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/profile_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../home/presentation/widgets/web_home_header.dart';
import '../../../home/presentation/widgets/web_home_footer.dart';
import '../../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  List<String> _extractPhotoUrls(ProfileModel profile) {
    final urls = <String>[];
    if (profile.fullPhotoUrl != null && profile.fullPhotoUrl!.trim().isNotEmpty) {
      urls.add(profile.fullPhotoUrl!.trim());
    }
    if (profile.photos != null) {
      for (final p in profile.photos!) {
        final clean = p.trim();
        if (clean.isNotEmpty) {
          final full = (clean.startsWith('http://') || clean.startsWith('https://'))
              ? clean
              : 'https://allgujaratvankarsamaj.com${clean.startsWith('/') ? clean : '/$clean'}';
          if (!urls.contains(full)) {
            urls.add(full);
          }
        }
      }
    }
    return urls;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final myProfileAsync = ref.watch(myProfileProvider);
    final width = MediaQuery.of(context).size.width;
    final isDesktopWeb = kIsWeb && width >= 960;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      appBar: isDesktopWeb
          ? const WebHomeHeader(activeRoute: '/profile')
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                'My Profile (મારી પ્રોફાઈલ)',
                style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
              ),
              iconTheme: const IconThemeData(color: AppColors.secondary),
              leading: Navigator.of(context).canPop()
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    )
                  : IconButton(
                      icon: const Icon(Icons.home),
                      onPressed: () => context.go('/main-poster'),
                    ),
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 1. Prestigious Hero Banner (Web & Mobile)
              _buildPageHeader(context, isDesktopWeb, myProfileAsync.value != null),

              // 2. Main Content Container (Max width 1240 for Desktop)
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktopWeb ? 24 : 14,
                      vertical: 24,
                    ),
                    child: myProfileAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 80),
                        child: Center(
                          child: CircularProgressIndicator(color: Color(0xFFA4143D)),
                        ),
                      ),
                      error: (err, stack) => _buildFallbackProfileView(context, ref, authState, isDesktopWeb),
                      data: (profile) => isDesktopWeb
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Sidebar Column (~360px)
                                SizedBox(
                                  width: 360,
                                  child: _buildSidebar(context, ref, authState, profile),
                                ),
                                const SizedBox(width: 24),
                                // Right Main Details Hub Column (Expanded flex: 1)
                                Expanded(
                                  child: _buildMainDashboard(context, ref, profile),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _buildSidebar(context, ref, authState, profile),
                                const SizedBox(height: 20),
                                _buildMainDashboard(context, ref, profile),
                              ],
                            ),
                    ),
                  ),
                ),
              ),

              if (isDesktopWeb) ...[
                const SizedBox(height: 40),
                const WebHomeFooter(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Top Page Hero Banner
  Widget _buildPageHeader(BuildContext context, bool isDesktop, bool hasExistingProfile) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF101B36),
            Color(0xFF1E2D52),
          ],
        ),
        border: Border(
          bottom: BorderSide(color: Color(0xFFD6A34A), width: 1.5),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 36 : 16,
        vertical: isDesktop ? 28 : 20,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFD6A34A), width: 1.0),
                      ),
                      child: const Text(
                        'ઓલ ગુજરાત વણકર સમાજ • સભ્ય પોર્ટલ & વૈવાહિક ડેશબોર્ડ',
                        style: TextStyle(
                          color: Color(0xFFFFDF7A),
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'મારી પ્રોફાઈલ & એકાઉન્ટ હબ (My Profile Dashboard)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'તમારી વ્યક્તિગત, શૈક્ષણિક, પારિવારિક વિગતો અને સુરક્ષા સેટિંગ્સનું સંચાલન કરો.',
                      style: TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (isDesktop) ...[
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () => context.go(hasExistingProfile ? '/profile/edit' : '/profile/create'),
                  icon: Icon(hasExistingProfile ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded, size: 20),
                  label: Text(
                    hasExistingProfile ? 'પ્રોફાઈલ સુધારો (Edit Profile)' : 'સંપૂર્ણ પ્રોફાઈલ બનાવો (Complete Profile)',
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA4143D),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFD6A34A), width: 1.2),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Left Sidebar: Identity Card + Settings Menu
  Widget _buildSidebar(BuildContext context, WidgetRef ref, AuthState authState, ProfileModel profile) {
    return Column(
      children: [
        // 1. Identity & Avatar Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2D6C0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF101B36).withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Avatar with gold border
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFAF8F5),
                  border: Border.all(color: const Color(0xFFD6A34A), width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD6A34A).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: profile.fullPhotoUrl != null && profile.fullPhotoUrl!.isNotEmpty
                      ? Image.network(
                          profile.fullPhotoUrl!,
                          width: 104,
                          height: 104,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.person_rounded,
                            size: 60,
                            color: Color(0xFF101B36),
                          ),
                        )
                      : const Icon(
                          Icons.person_rounded,
                          size: 60,
                          color: Color(0xFF101B36),
                        ),
                ),
              ),
              const SizedBox(height: 14),

              // Name
              Text(
                profile.fullName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF101B36),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),

              // Samaj ID
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Text(
                  profile.cleanDisplayId,
                  style: const TextStyle(
                    color: Color(0xFF92400E),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Email
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.email_outlined, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      authState.user?.email ?? profile.contactEmail ?? 'ईમેઈલ નોંધાયેલ નથી',
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              if (profile.contactPhone != null && profile.contactPhone!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      profile.contactPhone!,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 14),

              // Verification Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: profile.isVerified == true
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: profile.isVerified == true
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      profile.isVerified == true ? Icons.verified_rounded : Icons.pending_actions_rounded,
                      color: profile.isVerified == true ? const Color(0xFF047857) : const Color(0xFFB45309),
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      profile.isVerified == true
                          ? '૧૦૦% વેરિફાઈડ સભ્ય (Verified Member)'
                          : 'વેરિફિકેશન પ્રક્રિયા હેઠળ (Pending)',
                      style: TextStyle(
                        color: profile.isVerified == true ? const Color(0xFF047857) : const Color(0xFFB45309),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Primary Action: Edit Profile
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/profile/edit'),
                  icon: const Icon(Icons.edit_note_rounded, size: 18),
                  label: const Text(
                    'પ્રોફાઈલ સુધારો (Edit Profile)',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA4143D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Secondary Action: Verified Profile Details
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/verified-profile'),
                  icon: const Icon(Icons.workspace_premium_rounded, size: 16),
                  label: const Text(
                    'વેરિફિકેશન પ્રમાણપત્ર (Details)',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF101B36),
                    side: const BorderSide(color: Color(0xFFD6A34A), width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // 2. Account & Privacy Settings Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2D6C0), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF101B36).withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Text(
                  'એકાઉન્ટ સુરક્ષા & સેટિંગ્સ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101B36),
                  ),
                ),
              ),
              const Divider(height: 18, color: Color(0xFFE2E8F0)),
              _buildModernListTile(
                icon: Icons.lock_reset_rounded,
                title: 'પાસવર્ડ બદલો (Update Password)',
                onTap: () => _showUpdatePasswordDialog(context, ref),
              ),
              _buildModernListTile(
                icon: Icons.shield_outlined,
                title: 'ગોપનીયતા & સંપર્ક (Privacy Settings)',
                onTap: () => context.push('/privacy-contact'),
              ),
              _buildModernListTile(
                icon: Icons.policy_outlined,
                title: 'ગોપનીયતા નીતિ (Privacy Policy)',
                onTap: () => context.push('/privacy-policy'),
              ),
              const SizedBox(height: 8),
              // Logout Button
              ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(authNotifierProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF1F2),
                  foregroundColor: const Color(0xFFE11D48),
                  minimumSize: const Size(double.infinity, 44),
                  elevation: 0,
                  side: const BorderSide(color: Color(0xFFFECDD3), width: 1.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.logout_rounded, size: 17),
                label: const Text(
                  'લોગઆઉટ (Logout)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
              // Subtle Delete Account link
              Center(
                child: TextButton.icon(
                  onPressed: () => _showDeleteAccountReasons(context, ref),
                  icon: const Icon(Icons.delete_outline, size: 14, color: Color(0xFF94A3B8)),
                  label: const Text(
                    'એકાઉન્ટ કાઢી નાખો (Delete Account)',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Right Side: Comprehensive Matrimonial Dashboard
  Widget _buildMainDashboard(BuildContext context, WidgetRef ref, ProfileModel profile) {
    final photoUrls = _extractPhotoUrls(profile);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Metric / Stat Medallions
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 650;
            final cardWidth = isNarrow ? (constraints.maxWidth - 12) / 2 : (constraints.maxWidth - 36) / 4;

            final metrics = [
              _DashboardMetric(
                icon: Icons.favorite_rounded,
                iconColor: const Color(0xFFA4143D),
                title: 'વૈવાહિક સ્થિતિ',
                value: profile.displayMaritalStatus,
                subtitle: 'સક્રિય વૈવાહિક પ્રોફાઈલ',
              ),
              _DashboardMetric(
                icon: Icons.location_on_rounded,
                iconColor: const Color(0xFF101B36),
                title: 'પરગણું & જિલ્લો',
                value: profile.pargana.isNotEmpty ? profile.pargana : (profile.district.isNotEmpty ? profile.district : 'ગુજરાત'),
                subtitle: profile.nativePlace != null && profile.nativePlace!.isNotEmpty
                    ? 'મૂળ: ${profile.nativePlace}'
                    : 'વણકર સમાજ',
              ),
              _DashboardMetric(
                icon: Icons.school_rounded,
                iconColor: const Color(0xFFD97706),
                title: 'શિક્ષણ & વ્યવસાય',
                value: profile.education.isNotEmpty ? profile.education : 'શિક્ષિત સભ્ય',
                subtitle: profile.employmentType.isNotEmpty ? profile.employmentType : 'વ્યવસાયિક',
              ),
              _DashboardMetric(
                icon: Icons.photo_library_rounded,
                iconColor: const Color(0xFF0F766E),
                title: 'ફોટો ગેલેરી',
                value: '${photoUrls.length} ફોટા અપલોડ',
                subtitle: 'પ્રમાણિત ફોટોગ્રાફ્સ',
              ),
            ];

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: metrics.map((m) => SizedBox(width: cardWidth, child: _buildMetricCard(m))).toList(),
            );
          },
        ),

        const SizedBox(height: 20),

        // 2. Section Card: Education & Professional Details
        _buildSectionCard(
          title: 'શિક્ષણ અને કારકિર્દી વિગતો (Education & Profession)',
          icon: Icons.work_rounded,
          onEdit: () => context.push('/profile/edit'),
          child: Column(
            children: [
              _buildDetailRow([
                _DetailItem('અભ્યાસ (Education)', profile.education.isNotEmpty ? profile.education : 'નોંધાયેલ નથી'),
                _DetailItem('નોકરીનો પ્રકાર (Employment)', profile.employmentType.isNotEmpty ? profile.employmentType : 'નોંધાયેલ નથી'),
              ]),
              const SizedBox(height: 14),
              _buildDetailRow([
                _DetailItem('હોદ્દો / પદ (Designation)', profile.designation.isNotEmpty ? profile.designation : 'નોંધાયેલ નથી'),
                _DetailItem('સંસ્થા / કંપની (Department)', profile.department.isNotEmpty ? profile.department : 'નોંધાયેલ નથી'),
              ]),
              const SizedBox(height: 14),
              _buildDetailRow([
                _DetailItem('વાર્ષિક આવક (Annual Income)', profile.annualIncome != null && profile.annualIncome!.isNotEmpty ? profile.annualIncome! : 'ખાનગી (Confidential)'),
                _DetailItem('વ્યવસાય શ્રેણી (Industry)', profile.businessIndustry != null && profile.businessIndustry!.isNotEmpty ? profile.businessIndustry! : 'સામાન્ય'),
              ]),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 3. Section Card: Personal & Physical Details
        _buildSectionCard(
          title: 'વ્યક્તિગત અને શારીરિક માહિતી (Personal Information)',
          icon: Icons.person_rounded,
          onEdit: () => context.push('/profile/edit'),
          child: Column(
            children: [
              _buildDetailRow([
                _DetailItem('જાતિ (Gender)', profile.displayGender),
                _DetailItem('જન્મ તારીખ & ઉંમર (DOB)', profile.displayDob),
              ]),
              const SizedBox(height: 14),
              _buildDetailRow([
                _DetailItem('વૈવાહિક સ્થિતિ (Status)', profile.displayMaritalStatus),
                _DetailItem('બ્લડ ગ્રૂપ (Blood Group)', profile.bloodGroup != null && profile.bloodGroup!.isNotEmpty ? profile.bloodGroup! : 'નોંધાયેલ નથી'),
              ]),
              const SizedBox(height: 14),
              _buildDetailRow([
                _DetailItem('માતૃભાષા (Mother Tongue)', profile.motherTongue != null ? profile.motherTongue! : 'ગુજરાતી (Gujarati)'),
                _DetailItem('દિવ્યાંગતા (Disabled)', profile.isPhysicallyDisabled == true ? 'હા (Yes)' : 'ના (No)'),
              ]),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 4. Section Card: Family & Native Heritage
        _buildSectionCard(
          title: 'પારિવારિક પૃષ્ઠભૂમિ & વતન (Family & Native Details)',
          icon: Icons.family_restroom_rounded,
          onEdit: () => context.push('/profile/edit'),
          child: Column(
            children: [
              _buildDetailRow([
                _DetailItem('પિતાનું નામ (Father\'s Name)', profile.fatherName != null && profile.fatherName!.isNotEmpty ? profile.fatherName! : 'ઉમેરેલ નથી'),
                _DetailItem('પિતાનો વ્યવસાય (Father\'s Job)', profile.fatherOccupation != null && profile.fatherOccupation!.isNotEmpty ? profile.fatherOccupation! : 'ઉમેરેલ નથી'),
              ]),
              const SizedBox(height: 14),
              _buildDetailRow([
                _DetailItem('માતાનું નામ (Mother\'s Name)', profile.motherName != null && profile.motherName!.isNotEmpty ? profile.motherName! : 'ઉમેરેલ નથી'),
                _DetailItem('માતાનો વ્યવસાય (Mother\'s Job)', profile.motherOccupation != null && profile.motherOccupation!.isNotEmpty ? profile.motherOccupation! : 'ગૃહિણી (Homemaker)'),
              ]),
              const SizedBox(height: 14),
              _buildDetailRow([
                _DetailItem('મૂળ વતન (Native Place)', profile.nativePlace != null && profile.nativePlace!.isNotEmpty ? profile.nativePlace! : (profile.taluka.isNotEmpty ? profile.taluka : 'ગુજરાત')),
                _DetailItem('પરગણું (Pargana Mandal)', profile.pargana.isNotEmpty ? profile.pargana : 'સમગ્ર વણકર સમાજ'),
              ]),
              const SizedBox(height: 14),
              _buildDetailRow([
                _DetailItem('મોસાળ ગામ (Mama\'s Village)', profile.mamasVillage != null && profile.mamasVillage!.isNotEmpty ? profile.mamasVillage! : 'ઉમેરેલ નથી'),
                _DetailItem('હાલનું સરનામું (Address)', profile.addressLine != null && profile.addressLine!.isNotEmpty ? profile.addressLine! : (profile.city != null ? profile.city! : profile.district)),
              ]),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 5. Section Card: Candidate Photo Gallery
        _buildSectionCard(
          title: 'ઉમેદવાર ફોટો ગેલેરી (Candidate Photos)',
          icon: Icons.photo_library_rounded,
          onEdit: () => context.push('/profile/edit'),
          child: photoUrls.isNotEmpty
              ? Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    ...photoUrls.map(
                      (url) => Container(
                        width: 130,
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD6A34A), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.5),
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFFFAF8F5),
                              child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => context.push('/profile/edit'),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 130,
                        height: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF8F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5, style: BorderStyle.solid),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_rounded, size: 32, color: Color(0xFFA4143D)),
                            SizedBox(height: 6),
                            Text(
                              '+ ફોટો ઉમેરો',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFA4143D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF8F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.add_a_photo_outlined, size: 40, color: Color(0xFF94A3B8)),
                      const SizedBox(height: 10),
                      const Text(
                        'હજુ સુધી કોઈ ફોટો અપલોડ થયેલ નથી',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'સારી ગુણવત્તાવાળા ૨ ફોટોગ્રાફ્સ અપલોડ કરવાથી સંબંધ ઝડપથી નક્કી થાય છે.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/profile/edit'),
                        icon: const Icon(Icons.upload_rounded, size: 16),
                        label: const Text('ફોટો અપલોડ કરો (Upload Photos)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA4143D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
        ),

        if (profile.about != null && profile.about!.trim().isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildSectionCard(
            title: 'મારા વિશે / પરિચય (About Candidate)',
            icon: Icons.format_quote_rounded,
            onEdit: () => context.push('/profile/edit'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF8F5),
                borderRadius: BorderRadius.circular(10),
                border: const Border(
                  left: BorderSide(color: Color(0xFFD6A34A), width: 3.5),
                ),
              ),
              child: Text(
                profile.about!,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Stat Medallion Widget
  Widget _buildMetricCard(_DashboardMetric m) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2D6C0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101B36).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: m.iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(m.icon, color: m.iconColor, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  m.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            m.value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF101B36),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            m.subtitle,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Section Card Wrapper
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required VoidCallback onEdit,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2D6C0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101B36).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                  color: const Color(0xFFA4143D).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFFA4143D), size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101B36),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, size: 14),
                label: const Text('સુધારો (Edit)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFA4143D),
                  side: const BorderSide(color: Color(0xFFA4143D), width: 1.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(List<_DetailItem> items) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.value,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF101B36),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModernListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF8F5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Icon(icon, color: const Color(0xFF101B36), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  // Fallback view when user has no profile record yet
  Widget _buildFallbackProfileView(BuildContext context, WidgetRef ref, AuthState authState, bool isDesktop) {
    final user = authState.user;
    final displayName = (user?.email != null && user!.email.isNotEmpty)
        ? user.email.split('@').first
        : 'સભ્ય (Member)';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2D6C0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101B36).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFEF3C7),
              border: Border.all(color: const Color(0xFFD6A34A), width: 2),
            ),
            child: const Icon(Icons.assignment_ind_rounded, size: 48, color: Color(0xFFB45309)),
          ),
          const SizedBox(height: 18),
          Text(
            displayName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF101B36)),
          ),
          const SizedBox(height: 6),
          Text(
            user?.email ?? '',
            style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'પ્રોફાઈલ અપૂર્ણ છે • Profile Incomplete',
              style: TextStyle(color: Color(0xFFB45309), fontSize: 12.5, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'ઓલ ગુજરાત વણકર સમાજ મેટ્રિમોનિયલ ડિરેક્ટરીમાં તમારી વિગતો નોંધાવો જેથી યોગ્ય મેળ ઝડપથી મળી શકે.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 14,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => context.go('/profile/create'),
                icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                label: const Text(
                  'સંપૂર્ણ પ્રોફાઈલ બનાવો (Complete Profile)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA4143D),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 3,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go('/profile/create'),
                icon: const Icon(Icons.edit_note_rounded, size: 18),
                label: const Text(
                  'પ્રોફાઈલ સુધારો (Edit Profile)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF101B36),
                  backgroundColor: const Color(0xFFFAF8F5),
                  side: const BorderSide(color: Color(0xFFD6A34A), width: 1.2),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  void _showDeleteAccountReasons(BuildContext context, WidgetRef ref) {
    String? selectedReason;
    final List<String> reasons = [
      'I found my match elsewhere',
      'I am not finding the app useful',
      'Privacy concerns',
      'I am getting too many notifications',
      'Other reasons'
    ];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                'Why are you leaving?',
                style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
              ),
              content: Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: Colors.black54,
                  radioTheme: RadioThemeData(
                    fillColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return AppColors.secondary;
                      }
                      return Colors.black54;
                    }),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: reasons.map((reason) {
                      return RadioListTile<String>(
                        title: Text(reason, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                        value: reason,
                        groupValue: selectedReason,
                        activeColor: AppColors.secondary,
                        onChanged: (String? value) {
                          setState(() {
                            selectedReason = value;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
                ),
                ElevatedButton(
                  onPressed: selectedReason == null
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                          _showDeleteConfirmationDialog(context, ref);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentRed,
                    disabledBackgroundColor: Colors.grey.shade300,
                    disabledForegroundColor: Colors.grey.shade600,
                  ),
                  child: Text('Continue', style: TextStyle(color: selectedReason == null ? Colors.grey.shade600 : Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Are you sure?',
            style: TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
            ),
            ElevatedButton(
              onPressed: () async {
                // Pop the dialog
                Navigator.of(dialogContext).pop();
                
                // Show a loading snackbar or message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Deleting account...'), backgroundColor: AppColors.accentRed),
                );

                // Simulate deletion API call / actually log out
                await ref.read(authNotifierProvider.notifier).logout();
                
                if (context.mounted) {
                  context.go('/login');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentRed),
              child: const Text('Delete Account', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showUpdatePasswordDialog(BuildContext context, WidgetRef ref) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isSubmitting = false;
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFFD4AF37),
                  secondary: Color(0xFFD4AF37),
                ),
              ),
              child: AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: const Icon(Icons.lock_reset, color: Color(0xFFB45309), size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Update Password\n(પાસવર્ડ બદલો)',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
                content: SizedBox(
                  width: 400,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage!,
                                    style: TextStyle(color: Colors.red.shade800, fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const Text(
                          'Current Password (હાલનો પાસવર્ડ) *',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: currentPasswordController,
                          obscureText: obscureCurrent,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          cursorColor: Colors.black87,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            hintText: 'Enter current password',
                            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.normal),
                            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFB45309), size: 20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureCurrent ? Icons.visibility_off : Icons.visibility,
                                size: 20,
                                color: Colors.grey.shade800,
                              ),
                              onPressed: () => setDialogState(() => obscureCurrent = !obscureCurrent),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'New Password (નવો પાસવર્ડ) *',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: newPasswordController,
                          obscureText: obscureNew,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          cursorColor: Colors.black87,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            hintText: 'Minimum 6 characters',
                            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.normal),
                            prefixIcon: const Icon(Icons.key_outlined, color: Color(0xFFB45309), size: 20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureNew ? Icons.visibility_off : Icons.visibility,
                                size: 20,
                                color: Colors.grey.shade800,
                              ),
                              onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Confirm New Password (નવો પાસવર્ડ ફરીથી લખો) *',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: obscureConfirm,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          cursorColor: Colors.black87,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            hintText: 'Re-enter new password',
                            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.normal),
                            prefixIcon: const Icon(Icons.check_circle_outline, color: Color(0xFFB45309), size: 20),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureConfirm ? Icons.visibility_off : Icons.visibility,
                                size: 20,
                                color: Colors.grey.shade800,
                              ),
                              onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  OutlinedButton(
                    onPressed: isSubmitting ? null : () => Navigator.of(dialogContext).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text('Cancel (રદ કરો)', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                  ),
                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final cur = currentPasswordController.text.trim();
                            final nP = newPasswordController.text.trim();
                            final cP = confirmPasswordController.text.trim();

                            if (cur.isEmpty) {
                              setDialogState(() => errorMessage = 'કૃપા કરીને હાલનો પાસવર્ડ દાખલ કરો (Please enter current password)');
                              return;
                            }
                            if (nP.length < 6) {
                              setDialogState(() => errorMessage = 'નવો પાસવર્ડ ઓછામાં ઓછા 6 અક્ષરોનો હોવો જોઈએ (New password must be at least 6 characters)');
                              return;
                            }
                            if (nP != cP) {
                              setDialogState(() => errorMessage = 'નવો પાસવર્ડ અને કન્ફર્મ પાસવર્ડ સરખા નથી (New and Confirm passwords do not match)');
                              return;
                            }

                            setDialogState(() {
                              isSubmitting = true;
                              errorMessage = null;
                            });

                            final res = await ref.read(authNotifierProvider.notifier).updatePassword(
                                  currentPassword: cur,
                                  newPassword: nP,
                                );

                            if (res['success'] == true) {
                              if (dialogContext.mounted) {
                                Navigator.of(dialogContext).pop();
                              }
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(res['message'] ?? 'પાસવર્ડ સફળતાપૂર્વક અપડેટ થયો છે'),
                                    backgroundColor: Colors.green.shade700,
                                  ),
                                );
                              }
                            } else {
                              setDialogState(() {
                                isSubmitting = false;
                                errorMessage = res['message'] ?? 'પાસવર્ડ અપડેટ કરવામાં નિષ્ફળ';
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87),
                          )
                        : const Text('Save (સેવ કરો)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DashboardMetric {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  const _DashboardMetric({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });
}

class _DetailItem {
  final String label;
  final String value;

  const _DetailItem(this.label, this.value);
}


