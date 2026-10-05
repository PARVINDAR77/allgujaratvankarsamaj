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
                                  '${family.nameGuj} (${family.nameEng})',
                                  style: const TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              if (family.isVerified) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.verified, color: Color(0xFFF3C34D), size: 18),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${family.cityGuj} (${family.cityEng})',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF3C34D),
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(bottom: BorderSide(color: Color(0xFFD4AF37), width: 1.5)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.canPop() ? context.pop() : context.go('/home'),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                        color: Colors.white,
                      ),
                      child: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37), size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VANKAR SAMAJ',
                        style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      Text(
                        'Family Details (પરિવાર વિગત)',
                        style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFFD4AF37), size: 22),
                    tooltip: 'Refresh live data',
                    onPressed: () => ref.refresh(familyDirectoryProvider),
                  ),
                  const Icon(Icons.family_restroom, color: Color(0xFFD4AF37), size: 26),
                ],
              ),
            ),

            // Content
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFFD4AF37),
                onRefresh: () async {
                  ref.invalidate(familyDirectoryProvider);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'સમાજનાં પરિવારોની માહિતી',
                                style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Live Family Database | Vankar Samaj Gujarat',
                                style: TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          familiesAsync.when(
                            data: (list) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF10B981), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${list.length} પરિવારો',
                                    style: const TextStyle(color: Color(0xFF047857), fontWeight: FontWeight.bold, fontSize: 11.5),
                                  ),
                                ],
                              ),
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (error, stackTrace) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Search Bar
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFD4AF37)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Color(0xFFD4AF37), size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600),
                                decoration: const InputDecoration(
                                  hintText: 'પરિવાર, શહેર કે મોસાળ શોધો... (Search)',
                                  hintStyle: TextStyle(color: Colors.black38, fontSize: 13, fontWeight: FontWeight.normal),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                onChanged: (v) => setState(() => _searchQuery = v),
                              ),
                            ),
                            if (_searchQuery.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // City Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: _quickCities.map((city) {
                            final isSelected = _selectedCity == city;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6.0),
                              child: ChoiceChip(
                                label: Text(
                                  city == 'All' ? 'All (તમામ)' : city,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? Colors.white : const Color(0xFF041126),
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: const Color(0xFF0056D2),
                                backgroundColor: const Color(0xFFF1F5F9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: isSelected ? const Color(0xFF0056D2) : const Color(0xFFCBD5E1),
                                    width: 1,
                                  ),
                                ),
                                onSelected: (val) {
                                  if (val) {
                                    setState(() => _selectedCity = city);
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Data Display
                      familiesAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(color: Color(0xFFD4AF37)),
                                SizedBox(height: 12),
                                Text(
                                  'પરિવાર માહિતી લોડ થઈ રહી છે...\nLoading live family database...',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black54, fontSize: 13),
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
                                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                                const SizedBox(height: 10),
                                Text(
                                  'માહિતી લોડ કરવામાં સમસ્યા આવી.\nError: $err',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                                ),
                                const SizedBox(height: 14),
                                ElevatedButton.icon(
                                  onPressed: () => ref.refresh(familyDirectoryProvider),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('ફરી પ્રયાસ કરો (Retry)'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4AF37),
                                    foregroundColor: Colors.black,
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
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  children: [
                                    const Icon(Icons.search_off, size: 48, color: Colors.black26),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'કોઈ પરિવાર મળ્યો નથી\n(No family found matching your search)',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    const SizedBox(height: 10),
                                    TextButton(
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                          _selectedCity = 'All';
                                        });
                                      },
                                      child: const Text('બધા પરિવારો જુઓ (Reset Filters)'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: filtered.map((f) => _buildFamilyCard(f)).toList(),
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
    );
  }

  Widget _buildFamilyCard(FamilyModel f) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: f.isLiveMember
              ? const Color(0xFFD4AF37)
              : const Color(0xFFD4AF37).withValues(alpha: 0.5),
          width: f.isLiveMember ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showFamilyDetailsModal(f),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.6)),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
                    ],
                  ),
                  child: ClipOval(
                    child: (f.photoUrl != null && f.photoUrl!.isNotEmpty)
                        ? Image.network(
                            f.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(f.icon, color: const Color(0xFFD4AF37), size: 24),
                          )
                        : Icon(f.icon, color: const Color(0xFFD4AF37), size: 24),
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
                              '${f.nameGuj} (${f.nameEng})',
                              style: const TextStyle(
                                color: Color(0xFFD4AF37),
                                fontSize: 15.5,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (f.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, color: Color(0xFFD4AF37), size: 16),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            '${f.cityGuj} (${f.cityEng})',
                            style: const TextStyle(color: Colors.black87, fontSize: 13.5, fontWeight: FontWeight.w600),
                          ),
                          if (f.nativePlace != null && f.nativePlace!.isNotEmpty && f.nativePlace != f.cityEng) ...[
                            const Text(' • ', style: TextStyle(color: Colors.black38)),
                            Flexible(
                              child: Text(
                                f.nativePlace!,
                                style: const TextStyle(color: Colors.black54, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        f.details,
                        style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (f.isLiveMember) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF10B981), width: 0.6),
                              ),
                              child: const Text(
                                '● REGISTERED LIVE',
                                style: TextStyle(color: Color(0xFF047857), fontSize: 9.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (f.fatherName != null && f.fatherName!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'વડીલ: ${f.fatherName}',
                                  style: const TextStyle(color: Color(0xFF0056D2), fontSize: 11, fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFD4AF37)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
