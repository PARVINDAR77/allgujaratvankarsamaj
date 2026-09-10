import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/vankar_header.dart';
import '../../../profile/providers/profile_provider.dart';

class FamilyDetailsScreen extends ConsumerWidget {
  const FamilyDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileNotifierProvider);
    final profile = profileState.profile;

    final name = profile?.fullName ?? 'વણકર પરિવાર પ્રોફાઈલ';
    final lastName = profile?.lastName ?? 'વણકર';
    final city = profile?.city ?? '';
    final state = profile?.state ?? '';
    final occupation = profile?.occupation ?? 'વ્યવસાય / નોકરી';
    final education = profile?.education ?? 'ડિગ્રી / અભ્યાસ';

    String? parsedFather;
    String? parsedMother;
    String? parsedSiblings;
    String? parsedNativeMosal;
    String? parsedBuilding;
    String? parsedArea;
    String? parsedPincode;

    if (profile?.about != null) {
      final lines = profile!.about!.split('\n');
      for (final line in lines) {
        final l = line.toLowerCase().trim();
        if (l.contains('father:')) {
          parsedFather = line.substring(line.indexOf(':') + 1).trim();
        } else if (l.contains('mother:')) {
          parsedMother = line.substring(line.indexOf(':') + 1).trim();
        } else if (l.contains('siblings:')) {
          parsedSiblings = line.substring(line.indexOf(':') + 1).trim();
        } else if (l.contains('native/mosal:')) {
          parsedNativeMosal = line.substring(line.indexOf(':') + 1).trim();
        } else if (l.contains('building/flat:')) {
          parsedBuilding = line.substring(line.indexOf(':') + 1).trim();
        } else if (l.contains('area/society:')) {
          parsedArea = line.substring(line.indexOf(':') + 1).trim();
        } else if (l.contains('pincode:')) {
          parsedPincode = line.substring(line.indexOf(':') + 1).trim();
        }
      }
    }

    final fatherName = parsedFather?.isNotEmpty == true ? parsedFather! : '$lastName પરિવારના પિતા';
    final motherName = parsedMother?.isNotEmpty == true ? parsedMother! : '$lastName પરિવારની માતા';
    final siblings = parsedSiblings?.isNotEmpty == true ? parsedSiblings! : 'માહિતી દર્શાવેલ નથી';
    final nativeMosal = parsedNativeMosal?.isNotEmpty == true ? parsedNativeMosal! : (city.isNotEmpty ? city : 'માહિતી દર્શાવેલ નથી');

    final addrParts = <String>[];
    if (parsedBuilding?.isNotEmpty == true) addrParts.add(parsedBuilding!);
    if (parsedArea?.isNotEmpty == true) addrParts.add(parsedArea!);
    if (city.isNotEmpty) addrParts.add(city);
    if (state.isNotEmpty) addrParts.add(state);
    if (parsedPincode?.isNotEmpty == true) addrParts.add('PIN: $parsedPincode');
    final fullAddress = addrParts.isNotEmpty ? addrParts.join(', ') : 'સરનામું દર્શાવેલ નથી';

    final rows = [
      {'icon': Icons.person, 'relation': 'પિતા', 'name': fatherName, 'age': '---', 'edu': 'Graduate', 'job': 'વ્યવસાયી', 'place': city.isNotEmpty ? city : '---'},
      {'icon': Icons.face_3, 'relation': 'માતા', 'name': motherName, 'age': '---', 'edu': 'H.S.C', 'job': 'ઘર ગૃહિણી', 'place': city.isNotEmpty ? city : '---'},
      {'icon': Icons.groups_2, 'relation': 'ભાઈ-બહેન', 'name': siblings, 'age': '---', 'edu': education, 'job': occupation, 'place': city.isNotEmpty ? city : '---'},
      {'icon': Icons.home_work, 'relation': 'મૂળ વતન / મોસાળ', 'name': nativeMosal, 'age': '---', 'edu': '---', 'job': '---', 'place': nativeMosal},
      {'icon': Icons.house, 'relation': 'કુટુંબનો પ્રકાર', 'name': 'ન્યુક્લિયર / સંયુક્ત પરિવાર', 'age': '---', 'edu': '---', 'job': '---', 'place': state.isNotEmpty ? state : '---'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Standard Vankar Header with Back Button
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
                    // Header: 👥 Family Details / પરિવારની સંપૂર્ણ માહિતી
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.groups, color: AppColors.secondary, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Family Details',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 24, height: 1, color: AppColors.secondary),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'પરિવારની સંપૂર્ણ માહિતી',
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
                    const SizedBox(height: 12),

                    // Top Profile Owner Header Card
                    _buildProfileHeaderCard(name, education, occupation, '$city, $state'),
                    const SizedBox(height: 14),

                    // Family Members Table Header Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF041026),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder, width: 1.2),
                      ),
                      child: const Text(
                        'પરિવારના સભ્યોની વિગત (Family Members Matrix)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.goldLight,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Family Members Matrix Table
                    _buildFamilyTable(rows),
                    const SizedBox(height: 14),

                    // Bottom Dual Cards: Address (Left) & Specialty Bio (Right)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Address Card
                        Expanded(child: _buildAddressCard(fullAddress, city)),
                        const SizedBox(width: 8),
                        // Right: Specialty Card
                        Expanded(child: _buildSpecialtyCard(profile?.about)),
                      ],
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

  Widget _buildProfileHeaderCard(String name, String education, String occupation, String location) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF041026),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.cardBorder, width: 2),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'V',
                style: const TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(color: AppColors.secondary, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  '$education • $occupation',
                  style: const TextStyle(color: AppColors.goldLight, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.secondary, size: 12),
                    const SizedBox(width: 2),
                    Text(location, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF061A3A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.secondary, width: 1),
            ),
            child: Row(
              children: const [
                Icon(Icons.verified, color: AppColors.secondary, size: 14),
                SizedBox(width: 4),
                Text('પરિવાર વિગત', style: TextStyle(color: AppColors.goldLight, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyTable(List<Map<String, dynamic>> rows) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF041026),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Table(
          border: TableBorder(
            horizontalInside: BorderSide(color: AppColors.secondary.withValues(alpha: 0.3), width: 0.8),
            verticalInside: BorderSide(color: AppColors.secondary.withValues(alpha: 0.3), width: 0.8),
          ),
          columnWidths: const {
            0: FlexColumnWidth(2.6),
            1: FlexColumnWidth(3.2),
            2: FlexColumnWidth(1.2),
            3: FlexColumnWidth(2.2),
            4: FlexColumnWidth(2.8),
            5: FlexColumnWidth(2.4),
          },
          children: [
            // Header
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFF0A1F3D)),
              children: const [
                _HeaderCell('સંબંધ'),
                _HeaderCell('નામ'),
                _HeaderCell('ઉંમર'),
                _HeaderCell('શિક્ષણ'),
                _HeaderCell('વ્યવસાય'),
                _HeaderCell('સ્થાન'),
              ],
            ),
            // Data Rows
            ...rows.map((r) {
              return TableRow(
                decoration: BoxDecoration(
                  color: rows.indexOf(r).isEven ? const Color(0xFF041026) : const Color(0xFF061633),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(r['icon'] as IconData, color: AppColors.secondary, size: 11),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            r['relation'] as String,
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _DataCell(r['name'] as String, isGold: true),
                  _DataCell(r['age'] as String),
                  _DataCell(r['edu'] as String),
                  _DataCell(r['job'] as String),
                  _DataCell(r['place'] as String),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(String address, String city) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF041026),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF061633),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5), width: 1),
            ),
            child: const Text(
              'પરિવારનું સરનામું',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.goldLight, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.home, color: AppColors.secondary, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(color: Colors.white, fontSize: 9, height: 1.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: const [
              Icon(Icons.call, color: AppColors.secondary, size: 12),
              SizedBox(width: 4),
              Text('98765 43210', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyCard(String? about) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF041026),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF061633),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5), width: 1),
            ),
            child: const Text(
              'અમારી વિશેષતા',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.goldLight, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            about != null && about.trim().isNotEmpty
                ? about
                : 'અમારો પરિવાર શિક્ષણ, સંસ્કાર અને એકતામાં વિશ્વાસ રાખે છે. અમે સારા સંસ્કારી અને સમજદાર જીવનસાથીની શોધમાં છીએ.',
            style: const TextStyle(color: Colors.white, fontSize: 9, height: 1.4),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.secondary,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String text;
  final bool isGold;
  const _DataCell(this.text, {this.isGold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isGold ? AppColors.goldLight : Colors.white,
          fontSize: 9,
          fontWeight: isGold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
