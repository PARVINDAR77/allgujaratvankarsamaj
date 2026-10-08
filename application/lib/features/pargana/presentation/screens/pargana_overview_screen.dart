import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/models/profile_model.dart';
import '../../providers/pargana_provider.dart';

class ParganaOverviewScreen extends ConsumerStatefulWidget {
  const ParganaOverviewScreen({super.key});

  @override
  ConsumerState<ParganaOverviewScreen> createState() => _ParganaOverviewScreenState();
}

class _ParganaOverviewScreenState extends ConsumerState<ParganaOverviewScreen> {
  String _selectedPargana = 'All';
  String _selectedDistrict = 'All';
  String _selectedTaluka = 'All';
  String _selectedVillage = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final Color _bgColor = Colors.white;
  final Color _cardColor = const Color(0xFFF8FAFC);
  final Color _goldColor = const Color(0xFFD4AF37);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (clean.isEmpty) return;
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    var clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) return;
    if (!clean.startsWith('91') && clean.length == 10) {
      clean = '91$clean';
    }
    final uri = Uri.parse('https://wa.me/$clean');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showParganaDetailsModal(BuildContext context, ParganaModel pargana) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Header bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _goldColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _goldColor.withValues(alpha: 0.4)),
                          ),
                          child: Icon(Icons.account_balance, color: _goldColor, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pargana.displayName,
                                style: const TextStyle(
                                  color: Color(0xFF1E293B),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  height: 1.25,
                                ),
                              ),
                              if (pargana.name.isNotEmpty && pargana.name != pargana.gujaratiName) ...[
                                const SizedBox(height: 2),
                                Text(
                                  pargana.name,
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2E8F0),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '📍 ${pargana.districtRegion}',
                                  style: const TextStyle(
                                    color: Color(0xFF334155),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black54),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Body Content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Stats Overview Grid
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.holiday_village, color: _goldColor, size: 18),
                                        const SizedBox(width: 6),
                                        const Text('ગામોની સંખ્યા', style: TextStyle(color: Colors.black54, fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      pargana.villageCount ?? 'વિસ્તાર આધારિત',
                                      style: const TextStyle(color: Color(0xFF0F172A), fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: _goldColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _goldColor.withValues(alpha: 0.3)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.family_restroom, color: _goldColor, size: 18),
                                        const SizedBox(width: 6),
                                        const Text('નોંધાયેલા પરિવારો', style: TextStyle(color: Colors.black54, fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${pargana.profiles.length} પરિવારો',
                                      style: TextStyle(color: _goldColor, fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Covered Area & Villages
                        if (pargana.areaDescription != null && pargana.areaDescription!.trim().isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
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
                                    Icon(Icons.map_outlined, color: _goldColor, size: 20),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'સમાવિષ્ટ ગામો / વિસ્તાર (Covered Area):',
                                      style: TextStyle(color: Color(0xFF1E293B), fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  pargana.areaDescription!,
                                  style: const TextStyle(color: Color(0xFF334155), fontSize: 13, height: 1.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Pargana Leadership / Pramukh Details (if available)
                        if (pargana.leaderName != null && pargana.leaderName!.trim().isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEFCE8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _goldColor.withValues(alpha: 0.4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.shield_outlined, color: _goldColor, size: 20),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'પરગણા હોદ્દેદાર / સંપર્ક (Leadership):',
                                      style: TextStyle(color: Color(0xFF713F12), fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Color(0xFFEAB308),
                                      child: Icon(Icons.person, color: Colors.white, size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pargana.leaderName!,
                                            style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                          if (pargana.contactPhone != null && pargana.contactPhone!.trim().isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              pargana.contactPhone!,
                                              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (pargana.contactPhone != null && pargana.contactPhone!.trim().isNotEmpty) ...[
                                      IconButton.filled(
                                        style: IconButton.styleFrom(backgroundColor: const Color(0xFF16A34A)),
                                        icon: const Icon(Icons.call, size: 18, color: Colors.white),
                                        onPressed: () => _makePhoneCall(pargana.contactPhone!),
                                      ),
                                      const SizedBox(width: 6),
                                      IconButton.filled(
                                        style: IconButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                                        icon: const Icon(Icons.chat, size: 18, color: Colors.white),
                                        onPressed: () => _openWhatsApp(pargana.contactPhone!),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Registered Families / Members Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.people_alt, color: _goldColor, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'નોંધાયેલા પરિવારો (${pargana.profiles.length})',
                                  style: const TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            if (pargana.profiles.isNotEmpty)
                              Text(
                                'પરિવારોની યાદી',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (pargana.profiles.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.group_add_outlined, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                const Text(
                                  'આ પરગણામાં હજુ સુધી કોઈ પરિવારે ઓનલાઇન નોંધણી કરાવી નથી.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Color(0xFF334155), fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'જો આપ આ પરગણાના સભ્ય હો તો આપની પ્રોફાઇલ અપડેટ કરી પરગણું ઉમેરી સમાજ સાથે જોડાઈ શકો છો.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: pargana.profiles.length,
                            separatorBuilder: (c, i) => const SizedBox(height: 10),
                            itemBuilder: (c, i) {
                              final profile = pargana.profiles[i];
                              return _buildProfileItem(context, profile);
                            },
                          ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileItem(BuildContext context, ProfileModel profile) {
    final fullName = profile.fullName.trim().isNotEmpty
        ? profile.fullName
        : '${profile.firstName} ${profile.lastName}'.trim();
    final village = profile.nativePlace?.trim() ?? (profile.city?.trim() ?? '');
    final taluka = profile.taluka.trim();
    final district = profile.district.trim();

    final locationParts = [
      if (village.isNotEmpty) village,
      if (taluka.isNotEmpty && taluka != village) taluka,
      if (district.isNotEmpty && district != taluka) district,
    ];
    final locationText = locationParts.join(', ');

    final occupationText = profile.designation.trim().isNotEmpty
        ? profile.designation.trim()
        : profile.employmentType.trim();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: _goldColor.withValues(alpha: 0.2),
            backgroundImage: (profile.photoUrl != null && profile.photoUrl!.isNotEmpty)
                ? NetworkImage(profile.photoUrl!)
                : null,
            child: (profile.photoUrl == null || profile.photoUrl!.isEmpty)
                ? Text(
                    profile.firstName.isNotEmpty ? profile.firstName[0].toUpperCase() : 'V',
                    style: TextStyle(color: _goldColor, fontWeight: FontWeight.bold, fontSize: 18),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName.isNotEmpty ? fullName : 'વણકર સભ્ય',
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (locationText.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          locationText,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (occupationText.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.work_outline, size: 12, color: _goldColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          occupationText,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // View Profile Button
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
              context.push('/candidate-profile-details', extra: profile);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _goldColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _goldColor.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'પ્રોફાઇલ',
                    style: TextStyle(color: _goldColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.chevron_right, size: 14, color: _goldColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parganaAsync = ref.watch(allParganasProvider);

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: parganaAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 12),
                        const Text('પરગણાં લોડ કરવામાં સમસ્યા આવી છે.'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(allParganasProvider),
                          child: const Text('ફરી પ્રયાસ કરો'),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (allParganas) {
                  // Compute available districts, talukas, villages
                  final districtSet = <String>{'All'};
                  final talukaSet = <String>{'All'};
                  final villageSet = <String>{'All'};

                  for (final p in allParganas) {
                    if (p.districtRegion.isNotEmpty) {
                      districtSet.add(p.districtRegion);
                    }
                    for (final pr in p.profiles) {
                      if (_selectedDistrict != 'All' && pr.district != _selectedDistrict && p.districtRegion != _selectedDistrict) continue;
                      if (pr.taluka.isNotEmpty) talukaSet.add(pr.taluka);
                      if (pr.nativePlace != null && pr.nativePlace!.isNotEmpty) villageSet.add(pr.nativePlace!);
                      if (pr.city != null && pr.city!.isNotEmpty) villageSet.add(pr.city!);
                    }
                  }

                  final availableDistricts = districtSet.toList()..sort((a, b) => a == 'All' ? -1 : (b == 'All' ? 1 : a.compareTo(b)));
                  final availableTalukas = talukaSet.toList()..sort((a, b) => a == 'All' ? -1 : (b == 'All' ? 1 : a.compareTo(b)));
                  final availableVillages = villageSet.toList()..sort((a, b) => a == 'All' ? -1 : (b == 'All' ? 1 : a.compareTo(b)));

                  // Compute available parganas based on district
                  final parganaListForFilter = <String>{'All'};
                  for (final p in allParganas) {
                    if (_selectedDistrict != 'All' && p.districtRegion != _selectedDistrict) continue;
                    parganaListForFilter.add(p.displayName);
                  }
                  final availableParganas = parganaListForFilter.toList()..sort((a, b) => a == 'All' ? -1 : (b == 'All' ? 1 : a.compareTo(b)));

                  if (!availableDistricts.contains(_selectedDistrict)) _selectedDistrict = 'All';
                  if (!availableTalukas.contains(_selectedTaluka)) _selectedTaluka = 'All';
                  if (!availableVillages.contains(_selectedVillage)) _selectedVillage = 'All';
                  if (!availableParganas.contains(_selectedPargana)) _selectedPargana = 'All';

                  // Filter the parganas list
                  final filteredParganas = allParganas.where((p) {
                    if (_selectedDistrict != 'All' && p.districtRegion != _selectedDistrict) return false;
                    if (_selectedPargana != 'All' && p.displayName != _selectedPargana) return false;

                    bool hasMatchingProfileForTalukaVillage = false;
                    if (_selectedTaluka != 'All' || _selectedVillage != 'All') {
                      hasMatchingProfileForTalukaVillage = p.profiles.any((pr) {
                        bool tMatch = _selectedTaluka == 'All' || pr.taluka == _selectedTaluka;
                        bool vMatch = _selectedVillage == 'All' || pr.nativePlace == _selectedVillage || pr.city == _selectedVillage;
                        return tMatch && vMatch;
                      });
                      if (!hasMatchingProfileForTalukaVillage) return false;
                    }

                    if (_searchQuery.isNotEmpty) {
                      final query = _searchQuery.toLowerCase().trim();
                      final matchName = p.name.toLowerCase().contains(query);
                      final matchGuj = p.gujaratiName.toLowerCase().contains(query);
                      final matchDist = p.districtRegion.toLowerCase().contains(query);
                      final matchDesc = (p.areaDescription ?? '').toLowerCase().contains(query);
                      final matchVillage = (p.villageCount ?? '').toLowerCase().contains(query);
                      final matchLeader = (p.leaderName ?? '').toLowerCase().contains(query);

                      // Also match profiles
                      final matchProfile = p.profiles.any((pr) =>
                          pr.fullName.toLowerCase().contains(query) ||
                          (pr.nativePlace ?? '').toLowerCase().contains(query) ||
                          (pr.city ?? '').toLowerCase().contains(query));

                      if (!matchName && !matchGuj && !matchDist && !matchDesc && !matchVillage && !matchLeader && !matchProfile) {
                        return false;
                      }
                    }

                    return true;
                  }).toList();

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTitleCard(),
                              const SizedBox(height: 16),
                              Text(
                                'ફિલ્ટર કરો (Filter By):',
                                style: TextStyle(color: _goldColor, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              _buildFilterGrid(availableParganas, availableDistricts, availableTalukas, availableVillages),
                              const SizedBox(height: 16),
                              _buildSearchBar(),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${filteredParganas.length} પરગણા મળ્યા (Parganas found)',
                                    style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  if (_selectedDistrict != 'All' || _selectedPargana != 'All' || _selectedTaluka != 'All' || _selectedVillage != 'All' || _searchQuery.isNotEmpty)
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedDistrict = 'All';
                                          _selectedPargana = 'All';
                                          _selectedTaluka = 'All';
                                          _selectedVillage = 'All';
                                          _searchQuery = '';
                                          _searchController.clear();
                                        });
                                      },
                                      child: Text(
                                        'ફિલ્ટર હટાવો (Reset)',
                                        style: TextStyle(color: Colors.red.shade600, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildParganaList(filteredParganas),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/vankar_header_banner.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              color: Colors.black.withValues(alpha: 0.3),
              colorBlendMode: BlendMode.darken,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF041126),
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Text(
                  'પરગણા (વિશેષ) (Pargana Overview)',
                  style: TextStyle(
                    color: _goldColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'All Gujarat Vankar Samaj Directory',
                  style: TextStyle(color: Colors.white, fontSize: 14, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                ),
              ],
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: GestureDetector(
              onTap: () => context.canPop() ? context.pop() : context.go('/home'),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _cardColor.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                  border: Border.all(color: _goldColor, width: 1.5),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _goldColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _goldColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.domain, color: _goldColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pargana Overview & Directory',
                  style: TextStyle(color: Colors.black87, fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'સમગ્ર ગુજરાત વણકર સમાજના પરગણાં, ગામો અને પરિવારો',
                  style: TextStyle(color: _goldColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterGrid(List<String> parganas, List<String> districts, List<String> talukas, List<String> villages) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDropdown('પરગણા (Pargana)', _selectedPargana, parganas, (v) {
                setState(() {
                  _selectedPargana = v ?? 'All';
                  _selectedDistrict = 'All';
                  _selectedTaluka = 'All';
                  _selectedVillage = 'All';
                });
              }),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown('જિલ્લો (District)', _selectedDistrict, districts, (v) {
                setState(() {
                  _selectedDistrict = v ?? 'All';
                  _selectedTaluka = 'All';
                  _selectedVillage = 'All';
                });
              }),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDropdown('તાલુકો (Taluka)', _selectedTaluka, talukas, (v) {
                setState(() {
                  _selectedTaluka = v ?? 'All';
                  _selectedVillage = 'All';
                });
              }),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown('ગામ (Village)', _selectedVillage, villages, (v) {
                setState(() {
                  _selectedVillage = v ?? 'All';
                });
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options, void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _goldColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(value) ? value : (options.isNotEmpty ? options.first : null),
              isExpanded: true,
              dropdownColor: Colors.white,
              icon: Icon(Icons.keyboard_arrow_down, color: _goldColor),
              style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold),
              onChanged: onChanged,
              items: options.map((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(
                    val,
                    style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _goldColor),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: _goldColor),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'પરગણું, ગામ, કે જિલ્લો શોધો... (Search)',
                hintStyle: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.normal),
                border: InputBorder.none,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, size: 18, color: Colors.black54),
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),
        ],
      ),
    );
  }

  Widget _buildParganaList(List<ParganaModel> parganasList) {
    if (parganasList.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Column(
          children: [
            Icon(Icons.search_off, color: Colors.black38, size: 48),
            SizedBox(height: 16),
            Text(
              'કોઈ પરગણાં મળ્યાં નથી',
              style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'શોધ શબ્દ અથવા ફિલ્ટર બદલીને ફરી તપાસો.',
              style: TextStyle(color: Colors.black38, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: parganasList.length,
      itemBuilder: (context, index) {
        final pargana = parganasList[index];
        final familyCount = pargana.profiles.length;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1.5,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: familyCount > 0 ? _goldColor : _goldColor.withValues(alpha: 0.35),
              width: familyCount > 0 ? 1.5 : 1.0,
            ),
          ),
          color: familyCount > 0 ? const Color(0xFFFFFFFD) : _cardColor,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showParganaDetailsModal(context, pargana),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Sequence Number Badge
                  Container(
                    width: 44,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: familyCount > 0 ? _goldColor.withValues(alpha: 0.15) : _bgColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _goldColor),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: _goldColor,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title & Meta Information
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pargana.displayName,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Tags row: District & Village count & Families
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '📍 ${pargana.districtRegion}',
                                style: const TextStyle(color: Color(0xFF475569), fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                            if (pargana.villageCount != null && pargana.villageCount!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '🏘️ ${pargana.villageCount}',
                                  style: const TextStyle(color: Color(0xFF1D4ED8), fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: familyCount > 0
                                    ? _goldColor.withValues(alpha: 0.2)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '👨‍👩‍👧‍👦 $familyCount પરિવારો',
                                style: TextStyle(
                                  color: familyCount > 0 ? const Color(0xFF854D0E) : Colors.grey.shade600,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // "વિગત જુઓ" Action Indicator
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _goldColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_forward_ios, size: 14, color: _goldColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'વિગતો',
                        style: TextStyle(color: _goldColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: _bgColor,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomIcon(Icons.school, 'શિક્ષણ', const Color(0xFF673AB7)),
          _buildBottomIcon(Icons.people, 'સંપર્ક', const Color(0xFF1976D2)),
          _buildBottomIcon(Icons.bar_chart, 'વિકાસ', const Color(0xFF388E3C)),
          _buildBottomIcon(Icons.favorite, 'સહયોગ', const Color(0xFFE91E63)),
          _buildBottomIcon(Icons.eco, 'ઉજ્જવળ ભવ.', const Color(0xFF009688)),
        ],
      ),
    );
  }

  Widget _buildBottomIcon(IconData icon, String label, Color bgColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: bgColor, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
