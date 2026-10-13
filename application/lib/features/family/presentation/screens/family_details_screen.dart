import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/family_model.dart';
import '../../providers/family_provider.dart';

class FamilyDetailsScreen extends ConsumerStatefulWidget {
  const FamilyDetailsScreen({super.key});

  @override
  ConsumerState<FamilyDetailsScreen> createState() => _FamilyDetailsScreenState();
}

class _FamilyDetailsScreenState extends ConsumerState<FamilyDetailsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCity = 'All';

  final List<String> _quickCities = [
    'All',
    'Ahmedabad',
    'Surat',
    'Vadodara',
    'Rajkot',
    'Patan',
    'Himatnagar',
    'Mehsana',
    'Bhavnagar',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFamilyDetailsModal(FamilyModel family) {
    final hasFather = family.fatherName != null && family.fatherName!.trim().isNotEmpty;
    final hasMother = family.motherName != null && family.motherName!.trim().isNotEmpty;
    final hasFatherContact = family.fatherContact != null && family.fatherContact!.trim().isNotEmpty;
    final hasGuardian = family.guardianContact != null && family.guardianContact!.trim().isNotEmpty;
    final hasMosal = family.mosal != null && family.mosal!.trim().isNotEmpty;
    final hasNative = family.nativePlace != null && family.nativePlace!.trim().isNotEmpty;
    final hasPargana = family.pargana != null && family.pargana!.trim().isNotEmpty;
    final hasAddress = family.address != null && family.address!.trim().isNotEmpty;
    final hasSiblings = family.siblings != null && family.siblings!.trim().isNotEmpty;
    final hasCandidate = family.candidateName != null && family.candidateName!.trim().isNotEmpty;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 20,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 760),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Header Banner
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF041126), Color(0xFF0D2854)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFF3C34D), width: 2),
                        boxShadow: const [
                          BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 2)),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: const Color(0xFF0F326A),
                        backgroundImage: (family.photoUrl != null && family.photoUrl!.isNotEmpty)
                            ? NetworkImage(family.photoUrl!)
                            : null,
                        child: (family.photoUrl == null || family.photoUrl!.isEmpty)
                            ? Icon(family.icon, color: const Color(0xFFF3C34D), size: 28)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  family.nameGuj.isNotEmpty ? family.nameGuj : 'વણકર પરિવાર',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              if (family.isVerified) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.verified, color: Color(0xFFF3C34D), size: 18),
                              ],
                            ],
                          ),
                          if ((family.headName != null && family.headName!.isNotEmpty) ||
                              (family.candidateName != null && family.candidateName!.isNotEmpty && family.candidateName != family.surname)) ...[
                            const SizedBox(height: 2),
                            Text(
                              (family.headNameGuj != null && family.headNameGuj!.isNotEmpty && family.headName != null && family.headName!.isNotEmpty)
                                  ? '${family.headNameGuj} (${family.headName})'
                                  : (family.candidateName ?? family.nameEng),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFF3C34D),
                              ),
                            ),
                          ],
                          const SizedBox(height: 3),
                          Text(
                            '${family.cityGuj} (${family.cityEng})',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              if (family.isLiveMember)
                                Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFF10B981), width: 0.8),
                                  ),
                                  child: const Text(
                                    '● LIVE MEMBER',
                                    style: TextStyle(fontSize: 9.5, color: Color(0xFF34D399), fontWeight: FontWeight.bold),
                                  ),
                                ),
                              Flexible(
                                child: Text(
                                  family.nativePlace ?? 'Vankar Samaj',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFFBFDBFE), overflow: TextOverflow.ellipsis),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Close (બંધ કરો)',
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),

              // 2. Scrollable Body
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section A: Parents & Elders
                      _buildSectionHeader('પરિવારના વડીલો (Family Elders & Parents)', Icons.family_restroom, const Color(0xFF0056D2)),
                      _buildCard(
                        children: [
                          if (hasFather) ...[
                            _buildDetailTile(
                              icon: Icons.person_outline,
                              iconColor: const Color(0xFF0056D2),
                              label: 'પિતાશ્રીનું નામ (Father\'s Name)',
                              value: family.fatherName!,
                            ),
                            if (family.fatherOccupation != null && family.fatherOccupation!.isNotEmpty) ...[
                              _buildDivider(),
                              _buildDetailTile(
                                icon: Icons.work_outline,
                                iconColor: const Color(0xFF4CAF50),
                                label: 'પિતાનો વ્યવસાય (Father\'s Occupation)',
                                value: family.fatherOccupation!,
                              ),
                            ],
                          ],
                          if (hasMother) ...[
                            _buildDivider(),
                            _buildDetailTile(
                              icon: Icons.female_outlined,
                              iconColor: const Color(0xFFE91E63),
                              label: 'માતાશ્રીનું નામ (Mother\'s Name)',
                              value: family.motherName!,
                            ),
                            if (family.motherOccupation != null && family.motherOccupation!.isNotEmpty) ...[
                              _buildDivider(),
                              _buildDetailTile(
                                icon: Icons.work_outline,
                                iconColor: const Color(0xFF4CAF50),
                                label: 'માતાનો વ્યવસાય (Mother\'s Occupation)',
                                value: family.motherOccupation!,
                              ),
                            ],
                          ],
                          if (!hasFather && !hasMother)
                            _buildDetailTile(
                              icon: Icons.info_outline,
                              iconColor: Colors.grey,
                              label: 'પરિવાર વડીલ (Family Head)',
                              value: '${family.surname} કુટુંબ (Vankar Samaj Family)',
                            ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Section B: Roots & Heritage
                      _buildSectionHeader('મૂળ વતન અને મોસાળ (Roots & Heritage)', Icons.home_work_outlined, const Color(0xFFD4AF37)),
                      _buildCard(
                        children: [
                          if (hasNative)
                            _buildDetailTile(
                              icon: Icons.home_outlined,
                              iconColor: const Color(0xFFD4AF37),
                              label: 'મૂળ વતન (Native Place)',
                              value: family.nativePlace!,
                            ),
                          if (hasMosal) ...[
                            if (hasNative) _buildDivider(),
                            _buildDetailTile(
                              icon: Icons.holiday_village_outlined,
                              iconColor: const Color(0xFF9C27B0),
                              label: 'મોસાળનું ગામ (Mama\'s Village / Mosal)',
                              value: family.mosal!,
                            ),
                          ],
                          if (hasPargana) ...[
                            _buildDivider(),
                            _buildDetailTile(
                              icon: Icons.diversity_3_outlined,
                              iconColor: const Color(0xFF009688),
                              label: 'પરગણાં (Pargana / Samaj Circle)',
                              value: family.pargana!,
                            ),
                          ],
                          _buildDivider(),
                          _buildDetailTile(
                            icon: Icons.location_on_outlined,
                            iconColor: const Color(0xFFE65100),
                            label: 'હાલનું શહેર / જિલ્લો (Current City & District)',
                            value: '${family.cityGuj} (${family.cityEng})${family.district != null ? " • ${family.district}" : ""}',
                          ),
                          if (hasAddress) ...[
                            _buildDivider(),
                            _buildDetailTile(
                              icon: Icons.map_outlined,
                              iconColor: const Color(0xFF64748B),
                              label: 'સરનામું (Address)',
                              value: family.address!,
                            ),
                          ],
                        ],
                      ),

                      if (hasCandidate || hasSiblings) ...[
                        const SizedBox(height: 14),
                        _buildSectionHeader('સંતતિ અને ભાઈ-બહેન (Children & Candidate)', Icons.people_outline, const Color(0xFF009688)),
                        _buildCard(
                          children: [
                            if (hasCandidate) ...[
                              _buildDetailTile(
                                icon: Icons.badge_outlined,
                                iconColor: const Color(0xFF009688),
                                label: 'ઉમેદવાર (Candidate Member)',
                                value: family.candidateName!,
                              ),
                              if (family.candidateEducation != null && family.candidateEducation!.isNotEmpty) ...[
                                _buildDivider(),
                                _buildDetailTile(
                                  icon: Icons.school_outlined,
                                  iconColor: const Color(0xFF3F51B5),
                                  label: 'શિક્ષણ (Education)',
                                  value: family.candidateEducation!,
                                ),
                              ],
                              if (family.candidateOccupation != null && family.candidateOccupation!.isNotEmpty) ...[
                                _buildDivider(),
                                _buildDetailTile(
                                  icon: Icons.business_center_outlined,
                                  iconColor: const Color(0xFFFF9800),
                                  label: 'વ્યવસાય (Occupation)',
                                  value: family.candidateOccupation!,
                                ),
                              ],
                            ],
                            if (hasSiblings) ...[
                              if (hasCandidate) _buildDivider(),
                              _buildDetailTile(
                                icon: Icons.group_outlined,
                                iconColor: const Color(0xFF673AB7),
                                label: 'ભાઈ-બહેનની વિગત (Siblings)',
                                value: family.siblings!,
                              ),
                            ],
                          ],
                        ),
                      ],

                      if (hasFatherContact || hasGuardian) ...[
                        const SizedBox(height: 14),
                        _buildSectionHeader('સંપર્ક વિગત (Family Contact)', Icons.phone_in_talk_outlined, const Color(0xFF2E7D32)),
                        _buildCard(
                          children: [
                            if (hasFatherContact)
                              _buildDetailTile(
                                icon: Icons.phone_outlined,
                                iconColor: const Color(0xFF2E7D32),
                                label: 'સંપર્ક નંબર (Phone / Mobile)',
                                value: family.fatherContact!,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.copy, size: 18, color: Color(0xFF0056D2)),
                                      tooltip: 'Copy Number',
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: family.fatherContact!));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Contact number copied to clipboard'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () async {
                                        final uri = Uri.parse('tel:${family.fatherContact!.replaceAll(' ', '')}');
                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(uri);
                                        }
                                      },
                                      icon: const Icon(Icons.call, size: 14),
                                      label: const Text('Call', style: TextStyle(fontSize: 12)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2E7D32),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                        minimumSize: const Size(60, 30),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (hasGuardian && family.guardianContact != family.fatherContact) ...[
                              if (hasFatherContact) _buildDivider(),
                              _buildDetailTile(
                                icon: Icons.contact_phone_outlined,
                                iconColor: const Color(0xFFE65100),
                                label: 'વાલીનો સંપર્ક (Guardian Contact)',
                                value: family.guardianContact!,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // 3. Footer Actions
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
                ),
                child: Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF475569),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      child: const Text('બંધ કરો (Close)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                    const Spacer(),
                    if (family.candidateId != null && family.candidateId!.isNotEmpty && !family.candidateId!.startsWith('fam_')) ...[
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.push('/candidate-profile-details?id=${family.candidateId}');
                        },
                        icon: const Icon(Icons.person_search, size: 16),
                        label: const Text('સંપૂર્ણ પ્રોફાઇલ (View Profile)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0056D2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                    ] else if (hasFatherContact) ...[
                      ElevatedButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse('tel:${family.fatherContact!.replaceAll(' ', '')}');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        icon: const Icon(Icons.call, size: 16),
                        label: const Text('કોલ કરો (Call)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 17, color: iconColor),
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
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 12, thickness: 0.7, color: Color(0xFFF1F5F9));
  }

  @override
  Widget build(BuildContext context) {
    final familiesAsync = ref.watch(familyDirectoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF001F18),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF001F18), // Deep emerald
              Color(0xFF013B2E), // Rich peacock green
              Color(0xFF001812), // Midnight green
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Royal Peacock Header
              _buildRoyalHeader(context),

              // 2. Scrollable Body Content
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFFFFD700),
                  backgroundColor: const Color(0xFF002E26),
                  onRefresh: () async {
                    ref.invalidate(familyDirectoryProvider);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // A. Baroque Framed Plaque Banner
                        familiesAsync.when(
                          data: (list) => _buildBaroqueBanner(list.length),
                          loading: () => _buildBaroqueBanner(0),
                          error: (e, st) => _buildBaroqueBanner(0),
                        ),
                        const SizedBox(height: 12),

                        // B. Gold-Rimmed Search Bar
                        _buildGoldSearchBar(),
                        const SizedBox(height: 12),

                        // C. Horizontal City Filter Chips
                        _buildCityChips(),
                        const SizedBox(height: 14),

                        // D. Live Family Cards List
                        familiesAsync.when(
                          loading: () => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 50.0),
                            child: Center(
                              child: Column(
                                children: [
                                  CircularProgressIndicator(color: Color(0xFFFFD700)),
                                  SizedBox(height: 14),
                                  Text(
                                    'પરિવાર માહિતી લોડ થઈ રહી છે...\nLoading live family database...',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFFFFDF73),
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          error: (err, _) => Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  const Icon(Icons.error_outline, color: Color(0xFFFF6B6B), size: 40),
                                  const SizedBox(height: 10),
                                  Text(
                                    'માહિતી લોડ કરવામાં સમસ્યા આવી.\nError: $err',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                  ),
                                  const SizedBox(height: 14),
                                  ElevatedButton.icon(
                                    onPressed: () => ref.refresh(familyDirectoryProvider),
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('ફરી પ્રયાસ કરો (Retry)'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFFD700),
                                      foregroundColor: const Color(0xFF002E26),
                                      textStyle: const TextStyle(fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          data: (families) {
                            final filtered = families.where((f) {
                              // City filter
                              if (_selectedCity != 'All') {
                                final cEng = f.cityEng.toLowerCase();
                                final dEng = (f.district ?? '').toLowerCase();
                                final target = _selectedCity.toLowerCase();
                                if (!cEng.contains(target) && !dEng.contains(target)) {
                                  return false;
                                }
                              }

                              // Query search
                              if (_searchQuery.trim().isEmpty) return true;
                              final q = _searchQuery.toLowerCase().trim();
                              return f.nameGuj.toLowerCase().contains(q) ||
                                  f.nameEng.toLowerCase().contains(q) ||
                                  f.surname.toLowerCase().contains(q) ||
                                  (f.headName != null && f.headName!.toLowerCase().contains(q)) ||
                                  (f.headNameGuj != null && f.headNameGuj!.toLowerCase().contains(q)) ||
                                  f.cityGuj.toLowerCase().contains(q) ||
                                  f.cityEng.toLowerCase().contains(q) ||
                                  (f.mosal != null && f.mosal!.toLowerCase().contains(q)) ||
                                  (f.nativePlace != null && f.nativePlace!.toLowerCase().contains(q)) ||
                                  (f.fatherName != null && f.fatherName!.toLowerCase().contains(q)) ||
                                  (f.district != null && f.district!.toLowerCase().contains(q));
                            }).toList();

                            if (filtered.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.search_off, size: 50, color: Color(0xFFFFDF73)),
                                      const SizedBox(height: 14),
                                      const Text(
                                        'કોઈ પરિવાર મળ્યો નથી\n(No family found matching your search)',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xFFF1F8E9),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      OutlinedButton(
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            _searchQuery = '';
                                            _selectedCity = 'All';
                                          });
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: Color(0xFFFFD700), width: 1.5),
                                          foregroundColor: const Color(0xFFFFDF73),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        ),
                                        child: const Text('બધા પરિવારો જુઓ (Reset Filters)', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return Column(
                              children: [
                                ...filtered.asMap().entries.map((entry) => _buildFamilyCard(entry.value, entry.key)),
                                const SizedBox(height: 10),
                                // E. Royal Bottom Lotus & Peacock Plume Trim
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 24),
                                  child: Image.asset(
                                    'assets/images/royal_bottom_lotus_feathered.png',
                                    width: double.infinity,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 1. ROYAL HEADER WITH ORNATE GOLD BUTTONS & PEACOCK BANNER ---
  Widget _buildRoyalHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF001F18),
            Color(0xFF013B2E),
            Color(0xFF00221A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Peacock Feather motif behind title & right side
          Positioned(
            right: 70,
            top: -6,
            bottom: -6,
            width: 75,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.9,
                child: Image.asset(
                  'assets/images/real_peacock_feather.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Ornate Golden Back Button
                GestureDetector(
                  onTap: () => context.canPop() ? context.pop() : context.go('/home'),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFF00382E), Color(0xFF001A14)],
                      ),
                      border: Border.all(color: const Color(0xFFFFDF73), width: 2.2),
                      boxShadow: const [
                        BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 2)),
                        BoxShadow(color: Color(0x66FFD700), blurRadius: 8),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back, color: Color(0xFFFFD700), size: 22),
                  ),
                ),
                const SizedBox(width: 12),

                // Title with Rich 3D Gold Typography
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'VANKAR SAMAJ',
                        style: TextStyle(
                          color: Color(0xFFFFDF73),
                          fontSize: 17.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(color: Colors.black87, blurRadius: 6, offset: Offset(0, 2)),
                            Shadow(color: Color(0x99FFD700), blurRadius: 8),
                          ],
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Family Details (પરિવાર વિગત)',
                        style: TextStyle(
                          color: Color(0xFFE8F5E9),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Refresh Button (Ornate Gold Circle)
                GestureDetector(
                  onTap: () => ref.refresh(familyDirectoryProvider),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFF00382E), Color(0xFF001A14)],
                      ),
                      border: Border.all(color: const Color(0xFFFFDF73), width: 1.8),
                      boxShadow: const [
                        BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: const Icon(Icons.refresh, color: Color(0xFFFFD700), size: 21),
                  ),
                ),
                const SizedBox(width: 8),

                // Family Directory Icon (Ornate Gold Circle)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFF00382E), Color(0xFF001A14)],
                    ),
                    border: Border.all(color: const Color(0xFFFFDF73), width: 1.8),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                  ),
                  child: const Icon(Icons.people, color: Color(0xFFFFD700), size: 22),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. BAROQUE GOLD FRAMED BANNER WITH LIVE BADGE & PEACOCK FLOURISH ---
  Widget _buildBaroqueBanner(int count) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      child: AspectRatio(
        aspectRatio: 460 / 100,
        child: Stack(
          children: [
            // Authentic Baroque Banner with Ornate Golden Filigree Frame & Sprouting Peacock Plumes
            Positioned.fill(
              child: Image.asset(
                'assets/images/royal_banner_exact.png',
                fit: BoxFit.fill,
              ),
            ),

            // Live Pill Badge with dynamic count, perfectly overlaid
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF005A43), Color(0xFF00382B)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFD700), width: 1.8),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66FFD700),
                        blurRadius: 6,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.people, color: Color(0xFFFFD700), size: 16),
                      const SizedBox(width: 5),
                      Text(
                        '$count પરિવારો',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12.5,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. GOLD-RIMMED SEARCH BAR WITH FILTER SLIDERS ---
  Widget _buildGoldSearchBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.6),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF2C2416), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                hintText: 'પરિવાર, શહેર કે મોસાળ શોધો... (Search)',
                hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.normal),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(Icons.clear, size: 18, color: Colors.grey),
              ),
            ),
          const Icon(Icons.tune, color: Color(0xFFC59B27), size: 21),
        ],
      ),
    );
  }

  // --- 4. HORIZONTAL CITY FILTER CHIPS ---
  Widget _buildCityChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _quickCities.map((city) {
          final isSelected = _selectedCity == city;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCity = city),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF004D40), Color(0xFF002E26)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  color: isSelected ? null : const Color(0xFFFFFDF8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFFD700) : const Color(0xFFD4AF37),
                    width: isSelected ? 1.8 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? const Color(0x66FFD700) : Colors.black12,
                      blurRadius: isSelected ? 6 : 3,
                      offset: const Offset(0, 1.5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(Icons.check, color: Color(0xFFFFD700), size: 15),
                      const SizedBox(width: 5),
                    ] else ...[
                      const Icon(Icons.location_city, color: Color(0xFFC59B27), size: 16),
                      const SizedBox(width: 5),
                    ],
                    Text(
                      city == 'All' ? 'All (તમામ)' : city,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? const Color(0xFFFFDF73) : const Color(0xFF0B2545),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- 5. ROYAL PEACOCK FAMILY CARD (MATCHING TARGET IMAGE EXACTLY) ---
  Widget _buildFamilyCard(FamilyModel f, int index) {
    final isPurple = index.isOdd;
    final hasPhoto = f.photoUrl != null && f.photoUrl!.trim().isNotEmpty;

    // Select authentic wing asset from target design
    final String wingAsset;
    if (hasPhoto) {
      wingAsset = isPurple
          ? 'assets/images/wing_purple_aperture.png'
          : 'assets/images/wing_teal_aperture.png';
    } else {
      final isBuilding = (index == 0) ||
          f.icon == Icons.location_city ||
          f.icon == Icons.apartment ||
          f.icon == Icons.account_balance;
      if (isPurple) {
        wingAsset = isBuilding
            ? 'assets/images/wing_card_purple_building.png'
            : 'assets/images/wing_card_purple_house.png';
      } else {
        wingAsset = isBuilding
            ? 'assets/images/wing_card_teal_perfect.png'
            : 'assets/images/wing_card_teal_house.png';
      }
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFEA88),
            Color(0xFFD4AF37),
            Color(0xFF8B5A10),
            Color(0xFFFFD700),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2.4),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.6),
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFDF9), Color(0xFFFAF5E8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.6),
          child: CustomPaint(
            painter: RoyalCardWholeBoxPainter(isPurple: isPurple),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(15.6),
                onTap: () => _showFamilyDetailsModal(f),
                child: SizedBox(
                  height: 122,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 1. Full-Height Authentic Royal Baroque Peacock Wing Image
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: 115,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15.6),
                            bottomLeft: Radius.circular(15.6),
                          ),
                          child: Image.asset(
                            wingAsset,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),

                      // 2. Medallion Avatar Centered in the Golden Aperture (Photo only)
                      if (hasPhoto)
                        Positioned(
                          left: 33.8,
                          top: 22.9,
                          width: 58,
                          height: 58,
                          child: ClipOval(
                            child: Image.network(
                              f.photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, st) => Image.asset(
                                isPurple
                                    ? 'assets/images/wing_card_purple_building.png'
                                    : 'assets/images/wing_card_teal_perfect.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                      // 3. Family Content Column
                      Positioned(
                        left: 116,
                        top: 8,
                        right: 48,
                        bottom: 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Line 1: Title + Verified Badge
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    (f.nameGuj.isNotEmpty ? f.nameGuj : 'વણકર પરિવાર') +
                                        ((f.headName != null && f.headName!.isNotEmpty)
                                            ? ' (${f.headName})'
                                            : (f.candidateName != null && f.candidateName!.isNotEmpty)
                                                ? ' (${f.candidateName})'
                                                : ''),
                                    style: const TextStyle(
                                      color: Color(0xFF00382E),
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w900,
                                      height: 1.25,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (f.isVerified) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified, color: Color(0xFFD4AF37), size: 17),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),

                            // Line 2: Location
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Color(0xFF0D3B66), size: 15),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${f.cityGuj} (${f.cityEng}) • ${f.nativePlace ?? f.pargana ?? "Other (અન્ય)"}',
                                    style: const TextStyle(
                                      color: Color(0xFF1E293B),
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w700,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),

                            // Line 3: Mosal / Masal
                            Row(
                              children: [
                                const Icon(Icons.home, color: Color(0xFF0D3B66), size: 15),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    'મોસાળ: ${f.mosal ?? "Other (અન્ય)"} | Masal: ${f.mosal ?? "Other (અન્ય)"}',
                                    style: const TextStyle(
                                      color: Color(0xFF475569),
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Line 4: Live Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF2E7D32), width: 0.8),
                              ),
                              child: const Text(
                                '● REGISTERED LIVE',
                                style: TextStyle(
                                  color: Color(0xFF1B5E20),
                                  fontSize: 9.0,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 4. Right Chevron Button
                      Positioned(
                        right: 12,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const RadialGradient(
                                colors: [Color(0xFFFFF9E6), Color(0xFFF3E2B3)],
                              ),
                              border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1)),
                              ],
                            ),
                            child: const Icon(Icons.chevron_right, color: Color(0xFF2C2416), size: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- ROYAL WHOLE BOX PAINTER (DELICATE GOLD FILIGREE & INNER HAIRLINE) ---
class RoyalCardWholeBoxPainter extends CustomPainter {
  final bool isPurple;
  const RoyalCardWholeBoxPainter({this.isPurple = false});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Subtle inner hairline border inset by 3.5px
    final innerHairline = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(3.5, 3.5, size.width - 7, size.height - 7),
      const Radius.circular(14),
    );
    canvas.drawRRect(rrect, innerHairline);

    // 2. Top-Right Corner Baroque Gold Filigree Flourish
    _drawTopRightFiligree(canvas, size.width, 0);

    // 3. Bottom-Right Corner Soft Gold Filigree Accent
    _drawBottomRightFiligree(canvas, size.width, size.height);

    // 4. Soft satin ambient light arc across middle
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.4, -0.6),
        radius: 1.2,
        colors: [
          (isPurple ? const Color(0xFFE1BEE7) : const Color(0xFFFFF9C4)).withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);
  }

  void _drawTopRightFiligree(Canvas canvas, double w, double y) {
    final goldPen = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFDF73), Color(0xFFD4AF37), Color(0xFF996515)],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ).createShader(Rect.fromLTWH(w - 70, y, 70, 50))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    final p1 = Path();
    p1.moveTo(w - 60, y + 5);
    p1.cubicTo(w - 30, y + 6, w - 8, y + 16, w - 6, y + 42);
    canvas.drawPath(p1, goldPen);

    final p2 = Path();
    p2.moveTo(w - 42, y + 8);
    p2.cubicTo(w - 24, y + 10, w - 12, y + 22, w - 10, y + 34);
    canvas.drawPath(p2, goldPen..strokeWidth = 1.0);

    final dotPaint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w - 48, y + 7), 1.5, dotPaint);
    canvas.drawCircle(Offset(w - 28, y + 12), 1.6, dotPaint);
    canvas.drawCircle(Offset(w - 12, y + 26), 1.6, dotPaint);
    canvas.drawCircle(Offset(w - 8, y + 46), 1.4, dotPaint);
  }

  void _drawBottomRightFiligree(Canvas canvas, double w, double h) {
    final goldPen = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;

    final p = Path();
    p.moveTo(w - 45, h - 5);
    p.cubicTo(w - 25, h - 6, w - 6, h - 14, w - 5, h - 30);
    canvas.drawPath(p, goldPen);

    final dotPaint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w - 32, h - 7), 1.3, dotPaint);
    canvas.drawCircle(Offset(w - 14, h - 16), 1.3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- PEACOCK FAMILY CARD WING PAINTER ---
class PeacockFamilyCardWingPainter extends CustomPainter {
  const PeacockFamilyCardWingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Curved Wing Boundary Path
    final wingPath = Path();
    wingPath.moveTo(0, 0);
    wingPath.lineTo(60, 0);
    wingPath.cubicTo(88, 0, 102, 38, 92, 72);
    wingPath.cubicTo(82, 98, 94, size.height - 20, 68, size.height);
    wingPath.lineTo(0, size.height);
    wingPath.close();

    // Fill wing with rich peacock gradient (teal & emerald)
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFF00897B),
          Color(0xFF00695C),
          Color(0xFF00382E),
          Color(0xFF001E18),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, 105, size.height));
    canvas.drawPath(wingPath, fillPaint);

    // 2. Layered peacock feather plume eye at lower-left
    final eyeCenter = Offset(24, size.height - 26);
    // Outer emerald aura
    final outerAura = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00BFA5).withValues(alpha: 0.6),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: eyeCenter, radius: 24));
    canvas.drawCircle(eyeCenter, 24, outerAura);

    // Peacock outer blue ellipse
    final outerEyePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(eyeCenter.dx - 14, eyeCenter.dy - 17, 28, 34));
    canvas.drawOval(
      Rect.fromCenter(center: eyeCenter, width: 22, height: 28),
      outerEyePaint,
    );

    // Inner bright turquoise ring
    final turquoisePaint = Paint()..color = const Color(0xFF00E5FF);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(eyeCenter.dx, eyeCenter.dy + 1), width: 14, height: 18),
      turquoisePaint,
    );

    // Deep midnight pupil
    final pupilPaint = Paint()..color = const Color(0xFF001026);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(eyeCenter.dx, eyeCenter.dy + 2), width: 9, height: 12),
      pupilPaint,
    );

    // Top peacock plume eye (smaller accent)
    final topEyeCenter = const Offset(16, 22);
    final topEyePaint = Paint()
      ..color = const Color(0xFF00897B).withValues(alpha: 0.45);
    canvas.drawCircle(topEyeCenter, 12, topEyePaint);

    // 3. Gleaming golden ribbon along the curved boundary
    final goldBorderPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFFEA88),
          Color(0xFFD4AF37),
          Color(0xFF8B5A10),
          Color(0xFFFFD700),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, 105, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    final ribbonPath = Path();
    ribbonPath.moveTo(60, 0);
    ribbonPath.cubicTo(88, 0, 102, 38, 92, 72);
    ribbonPath.cubicTo(82, 98, 94, size.height - 20, 68, size.height);
    canvas.drawPath(ribbonPath, goldBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- ROYAL BOTTOM PEACOCK LOTUS FOOTER PAINTER ---
class RoyalBottomPeacockLotusPainter extends CustomPainter {
  const RoyalBottomPeacockLotusPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height - 22;

    // 1. Sweeping left & right royal wings (purple and teal gradients)
    // Left Wing Plume
    final leftWing = Path();
    leftWing.moveTo(cx, cy);
    leftWing.cubicTo(cx - 50, cy + 18, cx - 110, cy - 10, cx - 160, cy + 6);
    leftWing.cubicTo(cx - 130, cy + 28, cx - 70, cy + 30, cx, cy + 14);
    leftWing.close();

    final leftWingPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF6A1B9A), Color(0xFF00695C), Color(0xFF00382E)],
      ).createShader(Rect.fromLTWH(cx - 160, cy - 10, 160, 45));
    canvas.drawPath(leftWing, leftWingPaint);

    // Right Wing Plume
    final rightWing = Path();
    rightWing.moveTo(cx, cy);
    rightWing.cubicTo(cx + 50, cy + 18, cx + 110, cy - 10, cx + 160, cy + 6);
    rightWing.cubicTo(cx + 130, cy + 28, cx + 70, cy + 30, cx, cy + 14);
    rightWing.close();

    final rightWingPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF6A1B9A), Color(0xFF00695C), Color(0xFF00382E)],
      ).createShader(Rect.fromLTWH(cx, cy - 10, 160, 45));
    canvas.drawPath(rightWing, rightWingPaint);

    // Golden boundary ribbons for wings
    final goldRibbonPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFEA88), Color(0xFFD4AF37), Color(0xFF8B5A10)],
      ).createShader(Rect.fromLTWH(cx - 160, cy - 10, 320, 45))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    final leftRibbon = Path();
    leftRibbon.moveTo(cx, cy);
    leftRibbon.cubicTo(cx - 50, cy + 18, cx - 110, cy - 10, cx - 160, cy + 6);
    canvas.drawPath(leftRibbon, goldRibbonPaint);

    final rightRibbon = Path();
    rightRibbon.moveTo(cx, cy);
    rightRibbon.cubicTo(cx + 50, cy + 18, cx + 110, cy - 10, cx + 160, cy + 6);
    canvas.drawPath(rightRibbon, goldRibbonPaint);

    // Corner peacock feather eyes
    _drawPeacockEye(canvas, Offset(cx - 142, cy + 8));
    _drawPeacockEye(canvas, Offset(cx + 142, cy + 8));

    // 2. Central Golden Lotus
    final goldFill = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFEA88), Color(0xFFD4AF37), Color(0xFF8B5A10)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCenter(center: Offset(cx, cy), width: 60, height: 40))
      ..style = PaintingStyle.fill;

    // Center tall petal
    final centerPetal = Path();
    centerPetal.moveTo(cx, cy - 18);
    centerPetal.cubicTo(cx + 8, cy - 10, cx + 6, cy + 6, cx, cy + 10);
    centerPetal.cubicTo(cx - 6, cy + 6, cx - 8, cy - 10, cx, cy - 18);
    canvas.drawPath(centerPetal, goldFill);

    // Left inner petal
    final leftInner = Path();
    leftInner.moveTo(cx - 3, cy + 4);
    leftInner.cubicTo(cx - 12, cy - 4, cx - 18, cy - 12, cx - 18, cy - 6);
    leftInner.cubicTo(cx - 16, cy + 2, cx - 10, cy + 8, cx - 3, cy + 8);
    canvas.drawPath(leftInner, goldFill);

    // Right inner petal
    final rightInner = Path();
    rightInner.moveTo(cx + 3, cy + 4);
    rightInner.cubicTo(cx + 12, cy - 4, cx + 18, cy - 12, cx + 18, cy - 6);
    rightInner.cubicTo(cx + 16, cy + 2, cx + 10, cy + 8, cx + 3, cy + 8);
    canvas.drawPath(rightInner, goldFill);

    // Outermost petals
    final leftOuter = Path();
    leftOuter.moveTo(cx - 5, cy + 6);
    leftOuter.cubicTo(cx - 18, cy + 2, cx - 28, cy - 4, cx - 26, cy + 4);
    leftOuter.cubicTo(cx - 22, cy + 10, cx - 12, cy + 12, cx - 5, cy + 10);
    canvas.drawPath(leftOuter, goldFill);

    final rightOuter = Path();
    rightOuter.moveTo(cx + 5, cy + 6);
    rightOuter.cubicTo(cx + 18, cy + 2, cx + 28, cy - 4, cx + 26, cy + 4);
    rightOuter.cubicTo(cx + 22, cy + 10, cx + 12, cy + 12, cx + 5, cy + 10);
    canvas.drawPath(rightOuter, goldFill);
  }

  void _drawPeacockEye(Canvas canvas, Offset center) {
    final bluePaint = Paint()..color = const Color(0xFF0D47A1);
    canvas.drawOval(Rect.fromCenter(center: center, width: 18, height: 22), bluePaint);

    final cyanPaint = Paint()..color = const Color(0xFF00E5FF);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy + 1), width: 11, height: 14), cyanPaint);

    final pupilPaint = Paint()..color = const Color(0xFF001026);
    canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy + 2), width: 7, height: 9), pupilPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

