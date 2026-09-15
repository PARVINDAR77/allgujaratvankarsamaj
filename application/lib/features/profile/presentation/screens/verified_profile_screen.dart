import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/vankar_header.dart';
import '../../providers/profile_provider.dart';

class VerifiedProfileScreen extends ConsumerWidget {
  const VerifiedProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileNotifierProvider);
    final profile = profileState.profile;

    final name = profile?.fullName ?? 'વણકર સમાજ પ્રોફાઈલ';
    final profileId = profile != null
        ? 'VNK${profile.id.replaceAll('-', '').substring(0, 8).toUpperCase()}'
        : 'VNK1267890';
    final city = profile?.city ?? '';
    final occupation = profile?.occupation ?? 'વ્યવસાય';
    final education = profile?.education ?? 'અભ્યાસ';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Standard Vankar Header
            VankarHeader(
              showBackButton: true,
              onBackPressed: () => Navigator.of(context).maybePop(),
              subtitle: '“એક સમાજ, એક વિચાર, એક પરિવાર”',
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: Column(
                  children: [
                    // Header Badge: 🛡 Verified Profile / સત્યાપિત પ્રોફાઈલ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.verified, color: AppColors.secondary, size: 26),
                        SizedBox(width: 8),
                        Text(
                          'Verified Profile',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 24, height: 1, color: AppColors.secondary),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'સત્યાપિત પ્રોફાઈલ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(width: 24, height: 1, color: AppColors.secondary),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Target Gender Notice Badge
                    Consumer(
                      builder: (context, ref, _) {
                        final targetGender = ref.watch(targetGenderProvider);
                        final isTargetBoy = targetGender == 'MALE';
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isTargetBoy ? Colors.blue.withValues(alpha: 0.15) : Colors.pink.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isTargetBoy ? Colors.blueAccent : Colors.pinkAccent),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isTargetBoy ? Icons.male : Icons.female,
                                color: isTargetBoy ? Colors.blueAccent : Colors.pinkAccent,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isTargetBoy ? 'દર્શાવી રહ્યા છીએ: સન્માનિત છોકરાઓ ની પ્રોફાઈલ' : 'દર્શાવી રહ્યા છીએ: સન્માનિત છોકરીઓ ની પ્રોફાઈલ',
                                style: TextStyle(
                                  color: isTargetBoy ? Colors.blueAccent : Colors.pinkAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Top Profile Summary Card with Photo & ID
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF041026),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Circular Avatar with Green Checkmark
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: AppColors.goldGradient,
                                      border: Border.all(color: AppColors.secondary, width: 2.5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        name.isNotEmpty ? name[0].toUpperCase() : 'V',
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF2EB85C),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check, color: Colors.white, size: 14),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),

                              // Name, ID & Badges
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              height: 1.2,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const Icon(Icons.verified, color: Color(0xFF1E88E5), size: 20),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'ID : $profileId',
                                      style: const TextStyle(color: AppColors.goldLight, fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      '$education • $occupation ${city.isNotEmpty ? "• $city" : ""}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),

                                    // 3 Badges: Verified | Active | Premium
                                    Row(
                                      children: [
                                        _buildBadge('Verified', const Color(0xFF2EB85C), icon: Icons.check),
                                        const SizedBox(width: 4),
                                        _buildBadge('Active', const Color(0xFF1976D2)),
                                        const SizedBox(width: 4),
                                        _buildBadge('Premium', const Color(0xFFD4AF37), icon: Icons.workspace_premium),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white12, height: 16),

                          // 3 Verification Status Rows
                          _buildVerificationRow(
                            icon: Icons.phone_android,
                            title: 'Mobile Verified',
                            subtitle: 'Mobile number verified via SMS OTP',
                            iconColor: const Color(0xFF2EB85C),
                          ),
                          const SizedBox(height: 6),
                          _buildVerificationRow(
                            icon: Icons.badge,
                            title: 'Profile Verified',
                            subtitle: 'Profile photo & details verified',
                            iconColor: const Color(0xFF1976D2),
                          ),
                          const SizedBox(height: 6),
                          _buildVerificationRow(
                            icon: Icons.groups,
                            title: 'Samaj Verified',
                            subtitle: 'Vankar Samaj Verified',
                            iconColor: const Color(0xFF7B1FA2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 3 Distinct Verification Cards (Mobile | Profile | Samaj)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card 1: Mobile Verified (Green)
                        Expanded(
                          child: _buildTypeCard(
                            title: 'Mobile Verified',
                            gujaratiDesc: 'તમારો મોબાઈલ નંબર સફળતાપૂર્વક વેરિફાઈ થયો છે.',
                            extraInfo: 'OTP Verified',
                            footer: 'Mobile is Verified',
                            color: const Color(0xFF1B4D2E),
                            icon: Icons.phone_iphone,
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Card 2: Profile Verified (Blue)
                        Expanded(
                          child: _buildTypeCard(
                            title: 'Profile Verified',
                            gujaratiDesc: 'તમારી પ્રોફાઈલ અને ફોટો ચકાસણી બાદ સત્યાપિત થયેલ છે.',
                            extraInfo: null,
                            footer: 'Profile is Verified',
                            color: const Color(0xFF0D284B),
                            icon: Icons.assignment_turned_in,
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Card 3: Samaj Verified (Purple)
                        Expanded(
                          child: _buildTypeCard(
                            title: 'Samaj Verified',
                            gujaratiDesc: 'વણકર સમાજ દ્વારા તમારી વિગતો સત્યાપિત થયેલ છે.',
                            extraInfo: null,
                            footer: 'Samaj is Verified',
                            color: const Color(0xFF3B1E5C),
                            icon: Icons.verified_user,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Why Verified? Section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF041026),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder, width: 1.2),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.star, color: AppColors.secondary, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Why Verified?',
                                style: TextStyle(
                                  color: AppColors.goldLight,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.star, color: AppColors.secondary, size: 16),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // 5 Trust Icons Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildTrustIcon(Icons.security, 'Safe & Secure\nCommunication'),
                              _buildTrustIcon(Icons.handshake, 'Trusted\nProfiles Only'),
                              _buildTrustIcon(Icons.lock, 'No Fake\nProfiles'),
                              _buildTrustIcon(Icons.verified, 'Verified by\nSystem'),
                              _buildTrustIcon(Icons.groups, 'Samaj\nApproved'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Seeded Candidate Profiles Section
                    Consumer(
                      builder: (context, ref, _) {
                        final targetGender = ref.watch(targetGenderProvider);
                        final searchFilter = ref.watch(searchFilterProvider);
                        final isTargetBoy = targetGender == 'MALE' || searchFilter.lookingFor == 'Groom';

                        final liveCandidatesAsync = ref.watch(liveCandidateProfilesProvider);

                        final fallbackCandidates = isTargetBoy
                            ? [
                                {'name': 'અલ્પેશ પરમાર', 'id': 'VNK1001', 'age': '26', 'city': 'અમદાવાદ', 'pargana': 'ચોરાસી', 'status': 'Never Married', 'edu': 'B.Tech IT', 'occ': 'Software Engineer'},
                                {'name': 'જીગ્નેશ ચૌહાણ', 'id': 'VNK1002', 'age': '28', 'city': 'સુરત', 'pargana': 'બેતાલીસી', 'status': 'Never Married', 'edu': 'M.Com', 'occ': 'Bank Officer'},
                                {'name': 'રોહિત સોલંકી', 'id': 'VNK1003', 'age': '27', 'city': 'વડોદરા', 'pargana': 'છગાંવ', 'status': 'Divorced', 'edu': 'MBBS', 'occ': 'Doctor'},
                                {'name': 'હર્ષદ રાઠોડ', 'id': 'VNK1004', 'age': '29', 'city': 'રાજકોટ', 'pargana': 'સત્તાવીસી', 'status': 'Never Married', 'edu': 'B.E. Civil', 'occ': 'Govt Engineer'},
                                {'name': 'પ્રકાશ વાઘેલા', 'id': 'VNK1005', 'age': '25', 'city': 'ગાંધીનગર', 'pargana': 'ચોરાસી', 'status': 'Never Married', 'edu': 'MCA', 'occ': 'Web Developer'},
                              ]
                            : [
                                {'name': 'પૂજા પરમાર', 'id': 'VNK2001', 'age': '24', 'city': 'અમદાવાદ', 'pargana': 'ચોરાસી', 'status': 'Never Married', 'edu': 'B.Sc Nursing', 'occ': 'Staff Nurse'},
                                {'name': 'નેહા ચૌહાણ', 'id': 'VNK2002', 'age': '23', 'city': 'સુરત', 'pargana': 'બેતાલીસી', 'status': 'Never Married', 'edu': 'M.Ed', 'occ': 'Teacher'},
                                {'name': 'પ્રિયા સોલંકી', 'id': 'VNK2003', 'age': '25', 'city': 'વડોદરા', 'pargana': 'છગાંવ', 'status': 'Divorced', 'edu': 'B.Pharm', 'occ': 'Pharmacist'},
                                {'name': 'અંજલી રાઠોડ', 'id': 'VNK2004', 'age': '24', 'city': 'રાજકોટ', 'pargana': 'સત્તાવીસી', 'status': 'Never Married', 'edu': 'M.Sc Data Science', 'occ': 'Analyst'},
                                {'name': 'રીયા વાઘેલા', 'id': 'VNK2005', 'age': '22', 'city': 'ગાંધીનગર', 'pargana': 'ચોરાસી', 'status': 'Never Married', 'edu': 'BBA', 'occ': 'HR Executive'},
                              ];

                        final activeCandidateList = liveCandidatesAsync.maybeWhen(
                          data: (liveData) {
                            if (liveData.isNotEmpty) {
                              return liveData.map((item) {
                                final fn = item['firstName'] ?? '';
                                final ln = item['lastName'] ?? '';
                                final fullName = '$fn $ln'.trim();
                                return {
                                  'name': fullName.isNotEmpty ? fullName : (item['name'] ?? 'ઉમેદવાર'),
                                  'id': item['id']?.toString() ?? 'VNK-00',
                                  'age': item['age']?.toString() ?? '25',
                                  'city': item['city']?.toString() ?? 'ગુજરાત',
                                  'pargana': item['pargana']?.toString() ?? 'સમાજ પર્ગના',
                                  'status': item['maritalStatus']?.toString() ?? 'Never Married',
                                  'edu': item['education']?.toString() ?? 'ગ્રેજ્યુએટ',
                                  'occ': item['occupation']?.toString() ?? 'પ્રાઇવેટ જોબ',
                                };
                              }).toList();
                            }
                            return fallbackCandidates;
                          },
                          orElse: () => fallbackCandidates,
                        );

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      isTargetBoy ? 'મળતા આવતા છોકરાઓ (Matching Boys Seed Profiles)' : 'મળતા આવતા છોકરીઓ (Matching Girls Seed Profiles)',
                                      style: const TextStyle(color: AppColors.secondary, fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.cardNavy,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.goldLight.withValues(alpha: 0.4)),
                                    ),
                                    child: Text(
                                      'પરિણામ: ${activeCandidateList.length}',
                                      style: const TextStyle(color: AppColors.goldLight, fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...activeCandidateList.map((c) => Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF041026),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: isTargetBoy ? Colors.blue.withValues(alpha: 0.5) : Colors.pink.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundColor: isTargetBoy ? Colors.blueAccent : Colors.pinkAccent,
                                    child: Icon(isTargetBoy ? Icons.person : Icons.person_3, color: Colors.white, size: 28),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              c['name']!,
                                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 6),
                                            const Icon(Icons.verified, color: Colors.blueAccent, size: 16),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'ID: ${c['id']} • ${c['age']} વર્ષ • ${c['city']} (${c['pargana']})',
                                          style: const TextStyle(color: AppColors.goldLight, fontSize: 11),
                                        ),
                                        Text(
                                          '${c['status']} • ${c['edu']} • ${c['occ']}',
                                          style: const TextStyle(color: Colors.white70, fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.secondary,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: AppColors.primary,
                                          content: Text('${c['name']} ની પ્રોફાઈલ વિગતવાર ખુલી રહી છે...'),
                                        ),
                                      );
                                    },
                                    child: const Text('પ્રોફાઈલ જુઓ'),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Bottom Verified Banner
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF021329),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        children: const [
                          Text(
                            'Verified & Trusted Profile',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Safe  •  Secure  •  Trusted  •  Genuine',
                            style: TextStyle(color: Colors.white70, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 10),
            const SizedBox(width: 2),
          ],
          Text(
            text,
            style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white60, fontSize: 9),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF2EB85C).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check, color: Color(0xFF2EB85C), size: 12),
              SizedBox(width: 2),
              Text(
                'Verified',
                style: TextStyle(color: Color(0xFF2EB85C), fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeCard({
    required String title,
    required String gujaratiDesc,
    String? extraInfo,
    required String footer,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary, width: 1),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(color: AppColors.goldLight, fontSize: 10, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 6),
          Text(
            gujaratiDesc,
            style: const TextStyle(color: Colors.white, fontSize: 8, height: 1.3),
            textAlign: TextAlign.center,
          ),
          if (extraInfo != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                extraInfo,
                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  footer,
                  style: const TextStyle(color: Colors.white70, fontSize: 7, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.check_circle, color: Color(0xFF2EB85C), size: 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustIcon(IconData icon, String text) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF061633),
            border: Border.all(color: AppColors.secondary.withValues(alpha: 0.6)),
          ),
          child: Icon(icon, color: AppColors.secondary, size: 16),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 8, height: 1.2),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
