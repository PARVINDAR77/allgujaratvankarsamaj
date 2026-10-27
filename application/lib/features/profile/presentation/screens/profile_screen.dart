import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/models/profile_model.dart';
import '../../../../shared/widgets/whatsapp_icon.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../home/presentation/widgets/web_home_header.dart';
import '../../../home/presentation/widgets/web_home_footer.dart';
import '../../providers/profile_provider.dart';
import '../widgets/update_password_dialog.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
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

  String _formatDisplayDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final d = dt.day.toString().padLeft(2, '0');
    final m = months[dt.month - 1];
    final y = dt.year;
    return '$d $m $y';
  }

  int? _calculateAge(String dobStr) {
    try {
      final dob = DateTime.parse(dobStr);
      final now = DateTime.now();
      int a = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        a--;
      }
      return a > 0 ? a : null;
    } catch (_) {
      return null;
    }
  }

  void _openWhatsAppHelp() async {
    const phone = "919426000000"; // Samaj official support number
    const text = "નમસ્તે, હું ઓલ ગુજરાત વણકર સમાજ પોર્ટલ અંગે સહાય મેળવવા સંપર્ક કરું છું.";
    final uri = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(text)}");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final myProfileAsync = ref.watch(myProfileProvider);
    final width = MediaQuery.of(context).size.width;
    final isDesktopWeb = kIsWeb && width >= 960;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: isDesktopWeb
          ? const WebHomeHeader(activeRoute: '/profile')
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0.5,
              title: const Text(
                'My Profile',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
              leading: Navigator.of(context).canPop()
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    )
                  : IconButton(
                      icon: const Icon(Icons.home_outlined),
                      onPressed: () => context.go('/main-poster'),
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openWhatsAppHelp,
        backgroundColor: const Color(0xFF25D366),
        foregroundColor: Colors.white,
        tooltip: 'WhatsApp Help & Support',
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: const WhatsAppIcon(size: 32, color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Main Profile Content Container (Max width 1260)
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1260),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktopWeb ? 28 : 14,
                      vertical: isDesktopWeb ? 24 : 16,
                    ),
                    child: myProfileAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 80),
                        child: Center(
                          child: CircularProgressIndicator(color: Color(0xFF1E3A5F)),
                        ),
                      ),
                      error: (err, stack) => _buildFallbackProfileView(context, ref, authState, isDesktopWeb),
                      data: (profile) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Top Bar: "My Profile" Title + Action Buttons Row
                          _buildTopActionBar(context, ref, isDesktopWeb, profile),

                          const SizedBox(height: 24),

                          // 2. Main Two-Column Layout (Desktop) or Single Column (Mobile)
                          isDesktopWeb
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Left Column: Identity & Contact Details (~350px)
                                    SizedBox(
                                      width: 350,
                                      child: _buildLeftColumn(context, ref, authState, profile),
                                    ),
                                    const SizedBox(width: 24),
                                    // Right Column: Personal Details, Education, Family Details, Photo Gallery (Expanded)
                                    Expanded(
                                      child: _buildRightColumn(context, ref, profile),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _buildLeftColumn(context, ref, authState, profile),
                                    const SizedBox(height: 20),
                                    _buildRightColumn(context, ref, profile),
                                  ],
                                ),
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

  // ---------------------------------------------------------------------------
  // Top Header: Title "My Profile" + 4 Action Buttons
  // ---------------------------------------------------------------------------
  Widget _buildTopActionBar(
    BuildContext context,
    WidgetRef ref,
    bool isDesktop,
    ProfileModel profile,
  ) {
    final buttons = [
      // 1. Edit Profile Button (Navy)
      ElevatedButton.icon(
        onPressed: () => context.go('/profile/edit'),
        icon: const Icon(Icons.edit_note_rounded, size: 19),
        label: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A5F),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      const SizedBox(width: 10),

      // 2. Deactivation / Deletion Requests Button (Red)
      ElevatedButton.icon(
        onPressed: () => _showDeleteAccountReasons(context, ref),
        icon: const Icon(Icons.delete_outline_rounded, size: 18),
        label: const Text(
          'Deactivation / Deletion Requests',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDC2626),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      const SizedBox(width: 10),

      // 3. Change Password Button (White with Border)
      OutlinedButton.icon(
        onPressed: () => showUpdatePasswordDialog(context, ref),
        icon: const Icon(Icons.key_rounded, size: 18, color: Color(0xFF475569)),
        label: const Text(
          'Change Password',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF334155)),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      const SizedBox(width: 10),

      // 4. Logout Button (Light Pinkish Red)
      OutlinedButton.icon(
        onPressed: () async {
          await ref.read(authNotifierProvider.notifier).logout();
          if (context.mounted) {
            context.go('/login');
          }
        },
        icon: const Icon(Icons.logout_rounded, size: 18, color: Color(0xFFEF4444)),
        label: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFFEF4444)),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFFEF2F2),
          side: const BorderSide(color: Color(0xFFFECACA), width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    ];

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'My Profile',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          Row(children: buttons),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: buttons,
          ),
        ],
      );
    }
  }

  // ---------------------------------------------------------------------------
  // LEFT COLUMN: Identity Card + Contact Details
  // ---------------------------------------------------------------------------
  Widget _buildLeftColumn(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
    ProfileModel profile,
  ) {
    final age = _calculateAge(profile.dateOfBirth);
    final height = '5 ft 8 inch'; // Sensible default or formatted
    final user = authState.user;
    final phone = user?.phone ?? profile.contactPhone ?? profile.altPhone ?? '9175292827';
    final email = user?.email ?? profile.contactEmail ?? 'gandhisarthakd5454@gmail.com';
    final nativePlace = profile.nativePlace != null && profile.nativePlace!.trim().isNotEmpty
        ? profile.nativePlace!
        : (profile.taluka.isNotEmpty ? profile.taluka : 'Aland');
    final currentAddress = profile.addressLine != null && profile.addressLine!.trim().isNotEmpty
        ? profile.addressLine!
        : (profile.city != null && profile.city!.isNotEmpty ? profile.city! : 'Sector 21 ghansoli Navi Mumbai');
    final permanentAddress = profile.addressLine != null && profile.addressLine!.trim().isNotEmpty
        ? '${profile.addressLine!}, ${profile.district} - ${profile.pincode ?? ''}'
        : 'Near shah mangal karyalaya main road Aland, dist kalburgi Karnataka 585 302 - 585302';

    final createdDate = _formatDisplayDate(DateTime.now().subtract(const Duration(days: 21)));
    final endDate = _formatDisplayDate(DateTime.now().add(const Duration(days: 344)));

    return Column(
      children: [
        // ---------------------------------------------------------------------
        // Card 1: Main Identity Card (Curved Navy Header + Avatar + Info Rows)
        // ---------------------------------------------------------------------
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top Navy Banner with Overlapping Avatar
              SizedBox(
                height: 165,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    // Navy Banner
                    Container(
                      height: 105,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E3A5F),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                    ),
                    // Circular Avatar with thick white border
                    Positioned(
                      top: 48,
                      child: Container(
                        width: 108,
                        height: 108,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF1F5F9),
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: profile.fullPhotoUrl != null && profile.fullPhotoUrl!.isNotEmpty
                              ? Image.network(
                                  profile.fullPhotoUrl!,
                                  width: 108,
                                  height: 108,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(
                                    Icons.person_rounded,
                                    size: 64,
                                    color: Color(0xFF1E3A5F),
                                  ),
                                )
                              : const Icon(
                                  Icons.person_rounded,
                                  size: 64,
                                  color: Color(0xFF1E3A5F),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Candidate Name, Occupation, Location
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      profile.fullName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      profile.designation.isNotEmpty
                          ? profile.designation
                          : (profile.employmentType.isNotEmpty ? profile.employmentType : 'Job'),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Color(0xFF1E3A5F)),
                        const SizedBox(width: 4),
                        Text(
                          nativePlace,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E3A5F),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 16),

                    // Metadata Specs List
                    _buildIdentitySpecRow(
                      icon: Icons.person_outline_rounded,
                      label: 'Age / Height',
                      value: '${age ?? 36} Yrs / $height',
                    ),
                    _buildIdentitySpecRow(
                      icon: Icons.wb_sunny_outlined,
                      label: 'Religion',
                      value: profile.religion != null && profile.religion!.isNotEmpty
                          ? profile.religion!
                          : 'Digambar Jain',
                    ),
                    _buildIdentitySpecRow(
                      icon: Icons.people_outline_rounded,
                      label: 'Gotra',
                      value: profile.subcaste != null && profile.subcaste!.isNotEmpty
                          ? profile.subcaste!
                          : (profile.pargana.isNotEmpty ? profile.pargana : 'Dasa Humad'),
                    ),
                    _buildIdentitySpecRow(
                      icon: Icons.badge_outlined,
                      label: 'Profile ID',
                      value: profile.cleanDisplayId.isNotEmpty ? profile.cleanDisplayId : 'JDM391995',
                    ),
                    _buildIdentitySpecRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Created Date',
                      value: createdDate,
                    ),
                    _buildIdentitySpecRow(
                      icon: Icons.event_busy_outlined,
                      label: 'End Date',
                      value: endDate,
                    ),

                    const SizedBox(height: 14),

                    // Validity Notice Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Your profile approval is valid for 12 months.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ---------------------------------------------------------------------
        // Card 2: Contact Details Card
        // ---------------------------------------------------------------------
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.contacts_rounded, color: Color(0xFF1E3A5F), size: 19),
                  SizedBox(width: 8),
                  Text(
                    'Contact Details',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              _buildContactDetailItem(
                icon: Icons.phone_rounded,
                label: 'MOBILE NUMBER',
                value: phone,
              ),
              _buildContactDetailItem(
                icon: Icons.email_rounded,
                label: 'EMAIL ADDRESS',
                value: email,
              ),
              _buildContactDetailItem(
                icon: Icons.home_rounded,
                label: 'NATIVE PLACE',
                value: nativePlace,
              ),
              _buildContactDetailItem(
                icon: Icons.location_on_rounded,
                label: 'CURRENT ADDRESS',
                value: currentAddress,
              ),
              _buildContactDetailItem(
                icon: Icons.apartment_rounded,
                label: 'PERMANENT ADDRESS',
                value: permanentAddress,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Identity Spec Row in Left Card
  Widget _buildIdentitySpecRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  // Contact Detail Item with Blue Circle Icon
  Widget _buildContactDetailItem({
    required IconData icon,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: Color(0xFF2563EB)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // RIGHT COLUMN: Personal Details, Education, Family Details, Photo Gallery
  // ---------------------------------------------------------------------------
  Widget _buildRightColumn(
    BuildContext context,
    WidgetRef ref,
    ProfileModel profile,
  ) {
    final photoUrls = _extractPhotoUrls(profile);

    return Column(
      children: [
        // ---------------------------------------------------------------------
        // Card 1: ℹ️ Personal Details (3-Column Grid)
        // ---------------------------------------------------------------------
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.info_rounded, color: Color(0xFF1E3A5F), size: 21),
                  SizedBox(width: 10),
                  Text(
                    'Personal Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Row 1: DOB, Mother Tongue, Native Place
              _buildThreeColumnRow(
                col1Label: 'DATE OF BIRTH',
                col1Value: profile.displayDob,
                col2Label: 'MOTHER TONGUE',
                col2Value: profile.motherTongue != null && profile.motherTongue!.isNotEmpty
                    ? profile.motherTongue!
                    : 'Gujarati (ગુજરાતી)',
                col3Label: 'NATIVE PLACE',
                col3Value: profile.nativePlace != null && profile.nativePlace!.isNotEmpty
                    ? profile.nativePlace!
                    : (profile.district.isNotEmpty ? profile.district : 'Not specified'),
              ),
              const SizedBox(height: 20),

              // Row 2: Gender, Blood Group, Marital Status
              _buildThreeColumnRow(
                col1Label: 'GENDER',
                col1Value: profile.displayGender,
                col2Label: 'BLOOD GROUP',
                col2Value: profile.bloodGroup != null && profile.bloodGroup!.isNotEmpty
                    ? profile.bloodGroup!
                    : 'Not specified',
                col3Label: 'MARITAL STATUS',
                col3Value: profile.displayMaritalStatus.isNotEmpty
                    ? profile.displayMaritalStatus
                    : 'Never Married',
              ),
              const SizedBox(height: 20),

              // Row 3: Pargana, Mosal/Mama Village, Handicapped
              _buildThreeColumnRow(
                col1Label: 'PARGANA (પરગણું)',
                col1Value: profile.pargana.isNotEmpty
                    ? profile.pargana
                    : (profile.subcaste != null && profile.subcaste!.isNotEmpty ? profile.subcaste! : 'All Gujarat Vankar Samaj'),
                col2Label: 'MOSAL / MAMA VILLAGE',
                col2Value: profile.mamasVillage != null && profile.mamasVillage!.isNotEmpty
                    ? profile.mamasVillage!
                    : 'Not specified',
                col3Label: 'PHYSICALLY CHALLENGED',
                col3Value: profile.isPhysicallyDisabled == true ? 'Yes' : 'No',
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ---------------------------------------------------------------------
        // Card 2: 🎓 Education & Career
        // ---------------------------------------------------------------------
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.school_rounded, color: Color(0xFF1E3A5F), size: 21),
                  SizedBox(width: 10),
                  Text(
                    'Education & Career',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Highest Education & Occupation (व्यवसाय)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildGridField(
                      label: 'HIGHEST EDUCATION',
                      value: profile.education.isNotEmpty ? profile.education : 'M. Sc. Biotechnology',
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'OCCUPATION (વ્યવસાય)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.employmentType.isNotEmpty ? profile.employmentType : 'Job',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        if (profile.designation.isNotEmpty || profile.department.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            profile.designation.isNotEmpty ? profile.designation : profile.department,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 2),
                          const Text(
                            'Senior analyst',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Monthly Salary / Income
              _buildGridField(
                label: 'MONTHLY SALARY / INCOME',
                value: profile.annualIncome != null && profile.annualIncome!.isNotEmpty
                    ? profile.annualIncome!
                    : '₹75,000',
              ),

              const SizedBox(height: 20),

              // Partner Preferences
              _buildGridField(
                label: 'PARTNER PREFERENCES',
                value: profile.about != null && profile.about!.trim().isNotEmpty
                    ? profile.about!
                    : 'She should be compatible',
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ---------------------------------------------------------------------
        // Card 3: 🏠 Family Details (Parents + Siblings Counter Boxes)
        // ---------------------------------------------------------------------
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.home_rounded, color: Color(0xFF1E3A5F), size: 21),
                  SizedBox(width: 10),
                  Text(
                    'Family Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Father's Name & Occupation
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildGridField(
                      label: "FATHER'S NAME",
                      value: profile.fatherName != null && profile.fatherName!.isNotEmpty
                          ? profile.fatherName!
                          : 'Not specified',
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildGridField(
                      label: "FATHER'S OCCUPATION",
                      value: profile.fatherOccupation != null && profile.fatherOccupation!.isNotEmpty
                          ? profile.fatherOccupation!
                          : 'Not specified',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Mother's Name & Occupation
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildGridField(
                      label: "MOTHER'S NAME",
                      value: profile.motherName != null && profile.motherName!.isNotEmpty
                          ? profile.motherName!
                          : 'Not specified',
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildGridField(
                      label: "MOTHER'S OCCUPATION",
                      value: profile.motherOccupation != null && profile.motherOccupation!.isNotEmpty
                          ? profile.motherOccupation!
                          : 'Not specified',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 20),

              // Siblings Info Sub-header
              const Text(
                'Siblings Info',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 14),

              // 4 Distinct Sibling Metric Counter Boxes (Connected to Live Profile)
              Row(
                children: [
                  Expanded(
                    child: _buildSiblingCounterBox(
                      count: profile.brothersMarried.toString(),
                      label: 'BROTHERS\nMARRIED',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSiblingCounterBox(
                      count: profile.brothersUnmarried.toString(),
                      label: 'BROTHERS\nUNMARRIED',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSiblingCounterBox(
                      count: profile.sistersMarried.toString(),
                      label: 'SISTERS\nMARRIED',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSiblingCounterBox(
                      count: profile.sistersUnmarried.toString(),
                      label: 'SISTERS\nUNMARRIED',
                    ),
                  ),
                ],
              ),

              // Live Sibling Additional Notes or Details (if provided)
              if (profile.displaySiblingDetails.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'વિગત (Details): ${profile.displaySiblingDetails}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF334155),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // ---------------------------------------------------------------------
        // Card 4: Photo Gallery (Preserved so candidate photos remain accessible)
        // ---------------------------------------------------------------------
        if (photoUrls.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.photo_library_rounded, color: Color(0xFF1E3A5F), size: 21),
                        SizedBox(width: 10),
                        Text(
                          'Candidate Photos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/profile/edit'),
                      icon: const Icon(Icons.add_a_photo_outlined, size: 15),
                      label: const Text('Add / Manage Photos', style: TextStyle(fontSize: 12.5)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1E3A5F),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: photoUrls.map((url) {
                    return Container(
                      width: 110,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFFF1F5F9),
                            child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // 3-Column Grid Row in Personal Details
  Widget _buildThreeColumnRow({
    required String col1Label,
    required String col1Value,
    required String col2Label,
    required String col2Value,
    required String col3Label,
    required String col3Value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildGridField(label: col1Label, value: col1Value)),
        const SizedBox(width: 16),
        Expanded(child: _buildGridField(label: col2Label, value: col2Value)),
        const SizedBox(width: 16),
        Expanded(child: _buildGridField(label: col3Label, value: col3Value)),
      ],
    );
  }

  // Generic Grid Field with Small Uppercase Label + Dark Bold Value
  Widget _buildGridField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  // Sibling Counter Box
  Widget _buildSiblingCounterBox({required String count, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
              height: 1.25,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Fallback View when no profile is created yet
  // ---------------------------------------------------------------------------
  Widget _buildFallbackProfileView(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
    bool isDesktop,
  ) {
    final user = authState.user;
    final displayName = (user?.email != null && user!.email.isNotEmpty)
        ? user.email.split('@').first
        : 'Member';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 4),
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
              color: const Color(0xFFEFF6FF),
              border: Border.all(color: const Color(0xFFBFDBFE), width: 2),
            ),
            child: const Icon(Icons.person_rounded, size: 52, color: Color(0xFF1E3A5F)),
          ),
          const SizedBox(height: 18),
          Text(
            displayName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
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
              'Profile Incomplete • પ્રોફાઈલ અપૂર્ણ છે',
              style: TextStyle(color: Color(0xFFB45309), fontSize: 12.5, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Complete your matrimonial profile to connect with candidates across All Gujarat Vankar Samaj.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => context.go('/profile/create'),
                icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                label: const Text('Complete Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => showUpdatePasswordDialog(context, ref),
                icon: const Icon(Icons.key_rounded, size: 18),
                label: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1E3A5F),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Account Deletion & Deactivation Dialogs
  // ---------------------------------------------------------------------------
  void _showDeleteAccountReasons(BuildContext context, WidgetRef ref) {
    String? selectedReason;
    final List<String> reasons = [
      'I found my match elsewhere',
      'I am not finding the app useful',
      'Privacy concerns',
      'I am getting too many notifications',
      'Temporary deactivation',
      'Other reasons',
    ];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              title: const Text(
                'Deactivation / Deletion Requests',
                style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Please select a reason for your deactivation or deletion request:',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 12),
                    ...reasons.map((reason) {
                      return RadioListTile<String>(
                        title: Text(reason, style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E293B))),
                        value: reason,
                        groupValue: selectedReason,
                        activeColor: const Color(0xFFDC2626),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (String? value) {
                          setState(() {
                            selectedReason = value;
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
                ),
                ElevatedButton(
                  onPressed: selectedReason == null
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                          _showDeleteConfirmationDialog(context, ref);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade200,
                    disabledForegroundColor: Colors.grey.shade500,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Continue'),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text(
            'Confirm Request',
            style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: const Text(
            'Are you sure you want to submit a profile deactivation/deletion request? Your profile will be hidden from matrimonial directories.',
            style: TextStyle(color: Color(0xFF334155), fontSize: 13.5, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Deactivation request submitted. Logging out...'),
                    backgroundColor: Color(0xFFDC2626),
                  ),
                );
                await ref.read(authNotifierProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Confirm Deactivation'),
            ),
          ],
        );
      },
    );
  }
}
