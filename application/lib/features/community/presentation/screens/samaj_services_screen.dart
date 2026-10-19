import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/models/samaj_service.dart';
import '../../../../shared/models/samaj_service_person.dart';

import '../../providers/samaj_services_provider.dart';
import '../../../profile/providers/master_data_provider.dart';

class SamajServicesScreen extends ConsumerStatefulWidget {
  const SamajServicesScreen({super.key});

  @override
  ConsumerState<SamajServicesScreen> createState() => _SamajServicesScreenState();
}

class _SamajServicesScreenState extends ConsumerState<SamajServicesScreen> {
  String? selectedDistrict;
  String? selectedTaluka;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  String _searchQuery = '';
  int _selectedTabIndex = 0; // 0 = Professionals Directory, 1 = Categories

  // Colors for dynamic categories
  final List<Color> _categoryColors = [
    Colors.orange, Colors.blue, Colors.purple, Colors.green,
    Colors.teal, Colors.indigo, Colors.red, Colors.brown,
    Colors.blueGrey, Colors.pink, const Color(0xFF388E3C)
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (clean.isEmpty) return;
    final uri = Uri.parse('tel:$clean');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  Future<void> _openWhatsApp(String phone, String name, String serviceName) async {
    var clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length == 10) clean = '91$clean';
    final text = Uri.encodeComponent('નમસ્તે $name, મેં વણકર સમાજ ડિરેક્ટરીમાંથી તમારી સેવા ($serviceName) જોઈ સંપર્ક કર્યો છે.');
    final uri = Uri.parse('https://wa.me/$clean?text=$text');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _performSearch() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _villageController.clear();
      selectedDistrict = null;
      selectedTaluka = null;
      _searchQuery = '';
    });
  }

  void _showServiceProviders(BuildContext context, String serviceId, String serviceName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _buildProvidersBottomSheet(ctx, serviceId, serviceName),
    );
  }

  Widget _buildProvidersBottomSheet(BuildContext context, String serviceId, String serviceName) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.people, color: Color(0xFFD4AF37), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$serviceName Professionals',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF041126),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(samajServicePersonsProvider(serviceId));
              },
              child: ref.watch(samajServicePersonsProvider(serviceId)).when(
                data: (persons) {
                  List<dynamic> effectivePersons = List<dynamic>.from(persons);
                  if (effectivePersons.isEmpty) {
                    final isEdu = serviceName.toLowerCase().contains('edu') ||
                        serviceName.toLowerCase().contains('tuition') ||
                        serviceName.toLowerCase().contains('coaching') ||
                        serviceName.contains('શિક્ષણ') ||
                        serviceName.contains('નર્સિંગ') ||
                        serviceName.toLowerCase().contains('nursing') ||
                        serviceName.toLowerCase().contains('vamika');
                    if (isEdu) {
                      effectivePersons = [
                        SamajServicePerson(
                          id: 'sp-vamika-01',
                          serviceId: serviceId,
                          name: 'VAMIKA NURSING ACADEMY (IDAR)',
                          gujaratiName: 'વામિકા નર્સિંગ એકેડેમી - ઇડર',
                          phone: '9265476537',
                          city: 'ઇડર (Idar)',
                          address: 'ઇડર, ૩૫ ગામ પરગણા, સાબરકાંઠા',
                          description:
                              'વામિકા નર્સિંગ એકેડેમી - ઇડર. નર્સિંગ એકેડેમી, સ્ટાફ નર્સ કોચિંગ, સ્પર્ધાત્મક પરીક્ષા માર્ગદર્શન અને ઉચ્ચ શિક્ષણ સેવાઓ.',
                          experience:
                              'અધિકૃત શૈક્ષણિક એકેડેમી (Education Services)',
                        ),
                      ];
                    }
                  }

                  if (effectivePersons.isEmpty) {
                    return ListView(
                      children: [
                        const SizedBox(height: 60),
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.person_off, size: 60, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              const Text(
                                'No professionals found',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: effectivePersons.length,
                    itemBuilder: (context, index) {
                      return _buildProviderGridCard(context, effectivePersons[index], serviceName);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
                error: (err, stack) => Center(child: Text('Error loading providers: $err')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderGridCard(BuildContext context, dynamic provider, String serviceName) {
    return GestureDetector(
      onTap: () => _showProviderDetail(context, provider, serviceName),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.35), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Photo Box at the top
            Container(
              width: double.infinity,
              height: 115,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF041126), Color(0xFF0A2A5E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: provider.photoUrl != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Image.network(
                        provider.photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.person, size: 52, color: Colors.white38),
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.person, size: 52, color: Colors.white38),
                    ),
            ),
            // Name and Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          provider.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF041126),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (provider.gujaratiName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            provider.gujaratiName,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (provider.city != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on, size: 11, color: Color(0xFFD4AF37)),
                              const SizedBox(width: 2),
                              Flexible(
                                child: Text(
                                  provider.city,
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    // Call Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _makePhoneCall(provider.phone),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: const Color(0xFF041126),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.call, size: 14),
                        label: const Text(
                          'Call Now',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
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

  Widget _buildProfessionalDirectoryCard(BuildContext context, SamajServicePerson person) {
    final effectiveServiceName = person.serviceTitle ?? 'સમાજ સેવા';
    final effectiveIcon = person.serviceIcon ?? '💼';

    return InkWell(
      onTap: () => _showProviderDetail(context, person, effectiveServiceName),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Photo
                Stack(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF041126),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFD4AF37),
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: person.photoUrl != null && person.photoUrl!.isNotEmpty
                            ? Image.network(
                                person.photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.person, color: Color(0xFFD4AF37), size: 28),
                                ),
                              )
                            : const Center(
                                child: Icon(Icons.person, color: Color(0xFFD4AF37), size: 28),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, size: 10, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Name & Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        person.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF041126),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (person.gujaratiName != null && person.gujaratiName != person.name) ...[
                        const SizedBox(height: 2),
                        Text(
                          person.gujaratiName!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      // Service Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(effectiveIcon, style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                effectiveServiceName,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1D4ED8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
            if (person.city != null && person.city!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Color(0xFFD4AF37)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      person.address != null && person.address!.isNotEmpty
                          ? '${person.city}, ${person.address}'
                          : person.city!,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (person.description != null && person.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                person.description!,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 10),
            // Action Buttons Row (Call & WhatsApp)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _makePhoneCall(person.phone),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF041126),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.call, size: 14),
                    label: const Text(
                      'Call Now',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openWhatsApp(person.phone, person.name, effectiveServiceName),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.chat, size: 14),
                    label: const Text(
                      'WhatsApp',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllProfessionalsView(BuildContext context, bool isDesktop) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(allSamajServicePersonsProvider(_searchQuery));
      },
      child: ref.watch(allSamajServicePersonsProvider(_searchQuery)).when(
        data: (allPersons) {
          final filtered = allPersons.where((p) {
            if (selectedDistrict != null && selectedDistrict!.isNotEmpty) {
              final d = selectedDistrict!.toLowerCase();
              final matchesCity = (p.city ?? '').toLowerCase().contains(d);
              final matchesAddress = (p.address ?? '').toLowerCase().contains(d);
              if (!matchesCity && !matchesAddress) return false;
            }
            if (selectedTaluka != null && selectedTaluka!.isNotEmpty) {
              final t = selectedTaluka!.toLowerCase();
              final matchesCity = (p.city ?? '').toLowerCase().contains(t);
              final matchesAddress = (p.address ?? '').toLowerCase().contains(t);
              if (!matchesCity && !matchesAddress) return false;
            }
            if (_villageController.text.trim().isNotEmpty) {
              final v = _villageController.text.trim().toLowerCase();
              final matchesAddress = (p.address ?? '').toLowerCase().contains(v);
              if (!matchesAddress) return false;
            }
            return true;
          }).toList();

          if (filtered.isEmpty) {
            return ListView(
              children: [
                const SizedBox(height: 60),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off_rounded,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'કોઈ વ્યવસાયી મળ્યા નથી (No Professionals Found)',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'તમારો વ્યવસાય ઉમેરવા માટે ઉપર "+ ઉમેરો" બટન દબાવો',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          if (isDesktop) {
            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.8,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) => _buildProfessionalDirectoryCard(context, filtered[index]),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildProfessionalDirectoryCard(context, filtered[index]),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text('ડેટા લોડ કરવામાં ક્ષતિ: $err'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(allSamajServicePersonsProvider(_searchQuery)),
                child: const Text('ફરી પ્રયાસ કરો (Retry)'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProviderDetail(BuildContext context, dynamic provider, String serviceName) {
    int currentRating = 0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4, bottom: 16),
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF041126), Color(0xFF0A2A5E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: provider.photoUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  provider.photoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person,
                                    size: 36,
                                    color: Colors.white38,
                                  ),
                                ),
                              )
                            : const Center(
                                child: Icon(Icons.person, size: 36, color: Colors.white38),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF041126),
                              ),
                            ),
                            if (provider.gujaratiName != null)
                              Text(
                                provider.gujaratiName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            if (provider.city != null)
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 13, color: Color(0xFFD4AF37)),
                                  const SizedBox(width: 4),
                                  Text(
                                    provider.city,
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            if (provider.experience != null)
                              Text(
                                provider.experience,
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (provider.description != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        provider.description,
                        style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _makePhoneCall(provider.phone),
                          icon: const Icon(Icons.call, size: 18),
                          label: const Text('Call Now'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF041126),
                            side: const BorderSide(color: Color(0xFFD4AF37)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openWhatsApp(provider.phone, provider.name, serviceName),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.chat, size: 18),
                          label: const Text('WhatsApp'),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(),
                  ),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Rate this Professional:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(5, (starIndex) {
                          return IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              starIndex < currentRating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 30,
                            ),
                            onPressed: () => setLocalState(() => currentRating = starIndex + 1),
                          );
                        }),
                      ),
                      if (currentRating > 0)
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Review submitted!')),
                            );
                            setLocalState(() => currentRating = 0);
                          },
                          child: const Text(
                            'Submit',
                            style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final masterData = ref.watch(masterDataProvider);

    final districtsList = masterData.gujaratDistricts.keys
        .where((d) => d != 'Select District')
        .toList();
    final talukasList = selectedDistrict != null &&
            masterData.gujaratDistricts.containsKey(selectedDistrict)
        ? masterData.gujaratDistricts[selectedDistrict]!
            .where((t) => t != 'Select Taluka')
            .toList()
        : <String>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 850;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  children: [
                    // Custom Header
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 32 : 16, vertical: 24),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF041126), Color(0xFF0A2A5E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  if (context.canPop()) context.pop();
                                  else context.go('/home');
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.arrow_back,
                                      color: Color(0xFFD4AF37), size: 24),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Vankar Samaj Services',
                                      style: TextStyle(
                                        color: const Color(0xFFD4AF37),
                                        fontSize: isDesktop ? 28 : 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'સમાજ માટે - સમાજ દ્વારા',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.handshake,
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.8),
                                size: isDesktop ? 48 : 36,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Add Business Callout Banner
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF070C18), Color(0xFF132238)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFD4AF37),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.storefront, color: Color(0xFFD4AF37), size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'તમારો વ્યવસાય અહીં દર્શાવો',
                                  style: TextStyle(
                                    color: Color(0xFFD4AF37),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'પ્રોફાઇલમાં બિઝનેસ ઉમેરી સમાજ સાથે જોડાઓ',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context.push('/profile/edit');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: const Color(0xFF041126),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: const Text(
                              '+ ઉમેરો',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- SEARCH & FILTER SECTION ---
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Search Bar
                          TextField(
                            controller: _searchController,
                            style: const TextStyle(
                                color: Colors.black, fontWeight: FontWeight.bold),
                            textInputAction: TextInputAction.search,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val.trim();
                              });
                            },
                            onSubmitted: (_) => _performSearch(),
                            decoration: InputDecoration(
                              hintText: 'Search services, professions (e.g. Grain Trading)...',
                              hintStyle: const TextStyle(color: Colors.black54),
                              prefixIcon:
                                  const Icon(Icons.search, color: Color(0xFFD4AF37)),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFFD4AF37)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Color(0xFFD4AF37)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFD4AF37), width: 1.5),
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 0),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Location Dropdowns Row
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  dropdownColor: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  elevation: 8,
                                  menuMaxHeight: 300,
                                  iconEnabledColor: const Color(0xFFD4AF37),
                                  iconDisabledColor: Colors.grey,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                  hint: const Text('District',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold)),
                                  disabledHint: const Text('District',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold)),
                                  decoration: InputDecoration(
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 0),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Color(0xFFD4AF37))),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Color(0xFFD4AF37))),
                                    disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.grey)),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                  ),
                                  value: selectedDistrict,
                                  items: districtsList
                                      .map((d) => DropdownMenuItem(
                                          value: d,
                                          child: Text(d,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                              overflow:
                                                  TextOverflow.ellipsis)))
                                      .toList(),
                                  onChanged: (val) => setState(() {
                                    selectedDistrict = val;
                                    selectedTaluka = null;
                                  }),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  dropdownColor: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  elevation: 8,
                                  menuMaxHeight: 300,
                                  iconEnabledColor: const Color(0xFFD4AF37),
                                  iconDisabledColor: Colors.grey,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                  hint: const Text('Taluka',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold)),
                                  disabledHint: const Text('Taluka',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.bold)),
                                  decoration: InputDecoration(
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 0),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Color(0xFFD4AF37))),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Color(0xFFD4AF37))),
                                    disabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.grey)),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                  ),
                                  value: selectedTaluka,
                                  items: talukasList.isEmpty
                                      ? null
                                      : talukasList
                                          .map((t) => DropdownMenuItem(
                                              value: t,
                                              child: Text(t,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  overflow:
                                                      TextOverflow.ellipsis)))
                                          .toList(),
                                  onChanged: talukasList.isEmpty
                                      ? null
                                      : (val) => setState(
                                          () => selectedTaluka = val),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _villageController,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                  decoration: InputDecoration(
                                    hintText: 'Village Name',
                                    hintStyle: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 0),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Color(0xFFD4AF37))),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Color(0xFFD4AF37))),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _performSearch,
                                  icon: const Icon(Icons.search, size: 18),
                                  label: const Text('Search | શોધો',
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4AF37),
                                    foregroundColor: const Color(0xFF041126),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                              if (_searchQuery.isNotEmpty ||
                                  selectedDistrict != null ||
                                  selectedTaluka != null ||
                                  _villageController.text.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: _clearSearch,
                                  icon: const Icon(Icons.close, size: 16),
                                  label: const Text('Clear'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF041126),
                                    side: const BorderSide(color: Color(0xFFD4AF37)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    // --- END SEARCH & FILTER SECTION ---

                    // Tab Selector: Professionals vs Categories
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _selectedTabIndex = 0),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _selectedTabIndex == 0
                                      ? const Color(0xFF041126)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.badge_rounded,
                                      size: 18,
                                      color: _selectedTabIndex == 0
                                          ? const Color(0xFFD4AF37)
                                          : Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'વ્યવસાયકારો (Professionals)',
                                      style: TextStyle(
                                        color: _selectedTabIndex == 0
                                            ? Colors.white
                                            : Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _selectedTabIndex = 1),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _selectedTabIndex == 1
                                      ? const Color(0xFF041126)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.grid_view_rounded,
                                      size: 18,
                                      color: _selectedTabIndex == 1
                                          ? const Color(0xFFD4AF37)
                                          : Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'સેવા કેટેગરી (Categories)',
                                      style: TextStyle(
                                        color: _selectedTabIndex == 1
                                            ? Colors.white
                                            : Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
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
                    const SizedBox(height: 8),

                    // Content View
                    Expanded(
                      child: _selectedTabIndex == 0
                          ? _buildAllProfessionalsView(context, isDesktop)
                          : RefreshIndicator(
                              onRefresh: () async {
                                ref.invalidate(samajServicesProvider);
                              },
                              child: ref.watch(samajServicesProvider).when(
                          data: (services) {
                            final query = _searchQuery.toLowerCase();
                            final filteredServices = services.where((service) {
                              if (query.isEmpty) return true;
                              final t = service.title.toLowerCase();
                              final c = service.category.toLowerCase();
                              final d = service.description.toLowerCase();
                              final s = service.slug.toLowerCase();
                              final isEducationKeyword = (query.contains('vamika') ||
                                      query.contains('nursing') ||
                                      query.contains('9265476537') ||
                                      query.contains('idar') ||
                                      query.contains('વામિકા') ||
                                      query.contains('નર્સિંગ')) &&
                                  (c.contains('edu') ||
                                      t.contains('શિક્ષણ') ||
                                      t.contains('coaching') ||
                                      t.contains('tuition') ||
                                      d.contains('નર્સિંગ') ||
                                      t.contains('nursing'));
                              return t.contains(query) ||
                                  c.contains(query) ||
                                  d.contains(query) ||
                                  s.contains(query) ||
                                  isEducationKeyword;
                            }).toList();

                            if (filteredServices.isEmpty) {
                              return ListView(
                                children: [
                                  const SizedBox(height: 60),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.search_off_rounded,
                                            size: 64, color: Colors.grey.shade400),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'કોઈ સેવા મળી નથી (No Services Found)',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF041126),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '"$_searchQuery" માટે કોઈ મેળ ખાતી સેવા નથી',
                                          style: const TextStyle(
                                              fontSize: 13, color: Colors.black54),
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton.icon(
                                          onPressed: _clearSearch,
                                          icon: const Icon(Icons.refresh_rounded,
                                              size: 18),
                                          label: const Text(
                                              'તમામ સેવાઓ જુઓ (Show All)'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFD4AF37),
                                            foregroundColor: const Color(0xFF041126),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }

                            // Group filtered services by category
                            final Map<String, List<SamajService>>
                                groupedServices = {};
                            for (final service in filteredServices) {
                              groupedServices
                                  .putIfAbsent(service.category, () => [])
                                  .add(service);
                            }

                            final categories =
                                groupedServices.keys.toList()..sort();

                            return Column(
                              children: [
                                if (_searchQuery.isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFFFDE68A)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'મળેલ પરિણામ: ${filteredServices.length} સેવાઓ',
                                          style: const TextStyle(
                                            color: Color(0xFF92400E),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: _clearSearch,
                                          child: const Text(
                                            'સાફ કરો (Clear)',
                                            style: TextStyle(
                                              color: Color(0xFF1D4ED8),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Expanded(
                                  child: ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 8),
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: categories.length,
                                    itemBuilder: (context, index) {
                                final categoryName = categories[index];
                                final List<SamajService> items =
                                    groupedServices[categoryName]!;
                                final bool isWedding = categoryName.toLowerCase().contains('wedding');
                                final Color color = isWedding
                                    ? const Color(0xFFE65100)
                                    : _categoryColors[index % _categoryColors.length];
                                final IconData iconData = isWedding
                                    ? Icons.celebration
                                    : Icons.category;
                                final String displayCategoryTitle = isWedding
                                    ? (categoryName == 'Wedding' ? 'Wedding Services (લગ્ન પ્રસંગ સેવાઓ)' : categoryName)
                                    : categoryName;

                                return Container(
                                  margin: const EdgeInsets.only(
                                      bottom: 24, left: 8, right: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Category Header
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: isWedding
                                              ? const Color(0xFFFFF7ED)
                                              : color.withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: isWedding
                                                  ? const Color(0xFFFDBA74)
                                                  : color.withValues(alpha: 0.3)),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(iconData,
                                                color: color, size: 22),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                displayCategoryTitle,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: color.withValues(
                                                      alpha: 0.95),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: color.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                '${items.length} સેવાઓ',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: color,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Items Grid
                                      GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 280,
                                          mainAxisExtent: 68,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                        ),
                                        itemCount: items.length,
                                        itemBuilder: (context, itemIndex) {
                                          final SamajService service =
                                              items[itemIndex];
                                          final String emoji = service.icon;
                                          final String text = service.title;

                                          return InkWell(
                                            onTap: () {
                                              _showServiceProviders(context,
                                                  service.id, text);
                                            },
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                    color: isWedding
                                                        ? const Color(0xFFFFEDD5)
                                                        : Colors.grey.shade200),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: (isWedding ? const Color(0xFFEA580C) : Colors.black)
                                                        .withValues(alpha: isWedding ? 0.05 : 0.03),
                                                    blurRadius: 4,
                                                    offset:
                                                        const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  if (emoji.isNotEmpty) ...[
                                                    Text(
                                                      emoji,
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontFamily: 'Roboto',
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                  ],
                                                  Expanded(
                                                    child: Text(
                                                      text,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Color(0xFF041126),
                                                        height: 1.2,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Icon(Icons.chevron_right,
                                                      color:
                                                          Colors.grey.shade400,
                                                      size: 14),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                          },
                          loading: () => const Center(
                              child: CircularProgressIndicator()),
                          error: (err, stack) =>
                              Center(child: Text('Error loading services: $err')),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
