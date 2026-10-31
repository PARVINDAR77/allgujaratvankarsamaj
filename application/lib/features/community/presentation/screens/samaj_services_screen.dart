import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/models/samaj_service.dart';
import '../../../../shared/models/samaj_service_person.dart';
import '../../../../shared/widgets/whatsapp_icon.dart';

import '../../providers/samaj_services_provider.dart';
import '../../../../shared/repositories/samaj_services_repository.dart';
import '../../../profile/providers/master_data_provider.dart';
import '../../../home/presentation/widgets/web_home_header.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    _villageController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (clean.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ફોન નંબર ઉપલબ્ધ નથી.'),
            backgroundColor: Color(0xFFA4143D),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    final uri = Uri.parse('tel:$clean');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      try {
        await launchUrl(uri);
      } catch (_) {}
    }
  }

  Future<void> _openWhatsApp(String phone, String name, String serviceName) async {
    String clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('આ વ્યવસાયકારનો ફોન નંબર ઉપલબ્ધ નથી.'),
            backgroundColor: Color(0xFFA4143D),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // Strip leading zero(s) if any
    while (clean.startsWith('0')) {
      clean = clean.substring(1);
    }

    // Prepend India country code 91 if exactly 10 digits
    if (clean.length == 10) {
      clean = '91$clean';
    }

    final displayName = name.trim().isNotEmpty ? name.trim() : 'વ્યવસાયકાર';
    final displayService = serviceName.trim().isNotEmpty ? serviceName.trim() : 'સમાજ સેવા';
    final rawMessage = 'નમસ્તે $displayName, મેં ઓલ ગુજરાત વણકર સમાજ ડિરેક્ટરીમાંથી તમારી સેવા ($displayService) જોઈ સંપર્ક કર્યો છે.';
    final encodedMessage = Uri.encodeComponent(rawMessage);

    final nativeUri = Uri.parse('whatsapp://send?phone=$clean&text=$encodedMessage');
    final apiUri = Uri.parse('https://api.whatsapp.com/send?phone=$clean&text=$encodedMessage');
    final waMeUri = Uri.parse('https://wa.me/$clean?text=$encodedMessage');

    bool launched = false;

    // Strategy 1: Direct native WhatsApp app
    try {
      launched = await launchUrl(nativeUri, mode: LaunchMode.externalNonBrowserApplication);
    } catch (_) {
      launched = false;
    }

    // Strategy 2: Universal api.whatsapp.com
    if (!launched) {
      try {
        launched = await launchUrl(apiUri, mode: LaunchMode.externalApplication);
      } catch (_) {
        launched = false;
      }
    }

    // Strategy 3: Standard wa.me via external application
    if (!launched) {
      try {
        launched = await launchUrl(waMeUri, mode: LaunchMode.externalApplication);
      } catch (_) {
        launched = false;
      }
    }

    // Strategy 4: Platform default fallback (useful for mobile & web)
    if (!launched) {
      try {
        launched = await launchUrl(waMeUri, mode: LaunchMode.platformDefault);
      } catch (_) {
        launched = false;
      }
    }

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'WhatsApp ખોલવામાં અસમર્થ. કૃપા કરીને તપાસો કે WhatsApp ઇન્સ્ટોલ કરેલું છે ($clean).',
          ),
          backgroundColor: const Color(0xFFA4143D),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Call Now',
            textColor: const Color(0xFFFFDF7A),
            onPressed: () => _makePhoneCall(phone),
          ),
        ),
      );
    }
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

    void _showAddBusinessModal(BuildContext context, {SamajService? defaultService}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (modalCtx) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640, maxHeight: 780),
          child: _AddBusinessDialogContent(
            defaultService: defaultService,
            onSuccess: () {
              ref.invalidate(samajServicesProvider);
              ref.invalidate(allSamajServicePersonsProvider);
              if (defaultService != null) {
                ref.invalidate(samajServicePersonsProvider(defaultService.id));
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'તમારો વ્યવસાય સફળતાપૂર્વક નોંધાઈ ગયો છે! (Business Registered Successfully)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Color(0xFF108A44),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  void _showServiceProviders(BuildContext context, SamajService service) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680, maxHeight: 720),
          child: _buildServiceProvidersDialog(ctx, service),
        ),
      ),
    );
  }

  Widget _buildServiceProvidersDialog(BuildContext ctx, SamajService service) {
    final emoji = service.icon;
    final title = service.title;
    final category = service.category;
    final description = service.description;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Executive Midnight Navy Header
        Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF101B36), Color(0xFF1B2C52)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                  border: Border.all(
                    color: const Color(0xFFD6A34A),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: emoji.isNotEmpty
                    ? Text(
                        emoji,
                        style: const TextStyle(
                          fontSize: 22,
                          fontFamily: 'Roboto',
                        ),
                      )
                    : const Icon(
                        Icons.handshake_rounded,
                        color: Color(0xFFFFDF7A),
                        size: 22,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$category • વણકર સમાજ સેવાઓ',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFDF7A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                tooltip: 'બંધ કરો (Close)',
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),

        // 2. Service Description Overview Card (if available)
        if (description.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: const Color(0xFFFAF8F5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFFA4143D)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF334155),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // 3. Scrollable List of Registered Professionals or Welcoming Empty State
        Flexible(
          child: Consumer(
            builder: (dialogCtx, dialogRef, _) {
              final specificAsync = dialogRef.watch(samajServicePersonsProvider(service.id));
              final allAsync = dialogRef.watch(allSamajServicePersonsProvider(''));

              List<dynamic> effectivePersons = [];
              if (specificAsync.hasValue && specificAsync.value!.isNotEmpty) {
                effectivePersons = List<dynamic>.from(specificAsync.value!);
              } else if (allAsync.hasValue && allAsync.value!.isNotEmpty) {
                final allList = allAsync.value!;
                effectivePersons = allList.where((p) {
                  final pTitle = (p.serviceTitle ?? '').toLowerCase();
                  final pServiceId = p.serviceId;
                  final sTitle = service.title.toLowerCase();
                  final sCategory = service.category.toLowerCase();
                  return (pServiceId.isNotEmpty && pServiceId == service.id) ||
                      (pTitle.isNotEmpty &&
                          (pTitle.contains(sTitle) ||
                              sTitle.contains(pTitle) ||
                              pTitle.contains(sCategory)));
                }).toList();
              }

              if (effectivePersons.isEmpty) {
                final isEdu = title.toLowerCase().contains('edu') ||
                    title.toLowerCase().contains('tuition') ||
                    title.toLowerCase().contains('coaching') ||
                    title.contains('શિક્ષણ') ||
                    title.contains('નર્સિંગ') ||
                    title.toLowerCase().contains('nursing') ||
                    title.toLowerCase().contains('vamika');
                if (isEdu) {
                  effectivePersons = [
                    SamajServicePerson(
                      id: 'sp-vamika-01',
                      serviceId: service.id,
                      name: 'VAMIKA NURSING ACADEMY (IDAR)',
                      gujaratiName: 'વામિકા નર્સિંગ એકેડેમી - ઇડર',
                      phone: '9265476537',
                      city: 'ઇડર (Idar)',
                      address: 'ઇડર, ૩૫ ગામ પરગણા, સાબરકાંઠા',
                      description:
                          'વામિકા નર્સિંગ એકેડેમી - ઇડર. નર્સિંગ એકેડેમી, સ્ટાફ નર્સ કોચિંગ, સ્પર્ધાત્મક પરીક્ષા માર્ગદર્શન અને ઉચ્ચ શિક્ષણ સેવાઓ.',
                      experience: 'અધિકૃત શૈક્ષણિક એકેડેમી (Education Services)',
                    ),
                  ];
                }
              }

              // Only show centered spinner if specificAsync is actively loading AND we don't have any cached directory data
              final isHardLoading = specificAsync.isLoading && !allAsync.hasValue && effectivePersons.isEmpty;

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (specificAsync.isLoading)
                    const LinearProgressIndicator(
                      minHeight: 2.5,
                      color: Color(0xFFA4143D),
                      backgroundColor: Color(0xFFFAF8F5),
                    )
                  else
                    const Divider(height: 1, thickness: 1, color: Color(0xFFE5D5BA)),

                  Flexible(
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                        child: isHardLoading
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 48, horizontal: 20),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 36,
                                        height: 36,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          color: Color(0xFFA4143D),
                                        ),
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'સેવા વ્યવસાયકારો લોડ થઈ રહ્યા છે...',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF101B36),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Loading professionals, please wait...',
                                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : effectivePersons.isEmpty
                                ? Container(
                                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xFFFAF8F5),
                                            border: Border.all(color: const Color(0xFFD6A34A), width: 1.5),
                                          ),
                                          child: const Icon(
                                            Icons.storefront_outlined,
                                            size: 44,
                                            color: Color(0xFFA4143D),
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        const Text(
                                          'આ કેટેગરીમાં હાલ કોઈ વ્યવસાયકાર નોંધાયેલ નથી',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF101B36),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 6),
                                        const Text(
                                          'તમે અથવા તમારા પરિચિત આ સેવામાં કાર્યરત હોવ, તો તમારી સેવાઓ સમાજના હજારો પરિવારો સુધી પહોંચાડવા માટે આજે જ પ્રોફાઇલમાં વ્યવસાય ઉમેરો.',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            color: Color(0xFF64748B),
                                            height: 1.4,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 20),
                                        Wrap(
                                          alignment: WrapAlignment.center,
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.pop(ctx);
                                                _showAddBusinessModal(context, defaultService: service);
                                              },
                                              icon: const Icon(Icons.add_business_rounded, size: 16),
                                              label: const Text('+ તમારો વ્યવસાય ઉમેરો (+ Add Business)'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFFA4143D),
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                elevation: 2,
                                              ),
                                            ),
                                            OutlinedButton.icon(
                                              onPressed: () {
                                                Navigator.pop(ctx);
                                                setState(() => _selectedTabIndex = 0);
                                              },
                                              icon: const Icon(Icons.people_outline, size: 16),
                                              label: const Text('તમામ વ્યવસાયકારો જુઓ'),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: const Color(0xFF101B36),
                                                side: const BorderSide(color: Color(0xFFD6A34A)),
                                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 12, left: 4),
                                        child: Text(
                                          'નોંધાયેલ વ્યવસાયકારો (${effectivePersons.length}) • Registered Professionals',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFA4143D),
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ),
                                      ListView.separated(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: effectivePersons.length,
                                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                                        itemBuilder: (context, index) {
                                          final p = effectivePersons[index];
                                          return _buildModalProviderCard(context, p, title);
                                        },
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // 4. Dialog Footer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFFFAF8F5),
            border: Border(top: BorderSide(color: Color(0xFFE5D5BA), width: 1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF475569),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                child: const Text('બંધ કરો (Close)', style: TextStyle(fontSize: 12)),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _showAddBusinessModal(context, defaultService: service);
                },
                icon: const Icon(Icons.add_business_rounded, size: 15),
                label: const Text('+ વ્યવસાય ઉમેરો', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA4143D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModalProviderCard(BuildContext context, dynamic provider, String serviceTitle) {
    final photoUrl = provider.photoUrl?.toString();
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
    final name = provider.name?.toString() ?? '';
    final gujaratiName = provider.gujaratiName?.toString();
    final city = provider.city?.toString();
    final phone = provider.phone?.toString() ?? '';
    final experience = provider.experience?.toString();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5D5BA), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101B36).withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD6A34A), width: 1.6),
                ),
                child: ClipOval(
                  child: hasPhoto
                      ? Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.person, color: Color(0xFFA4143D), size: 26),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.person, color: Color(0xFFA4143D), size: 26),
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
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF101B36),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (gujaratiName != null && gujaratiName != name) ...[
                      const SizedBox(height: 2),
                      Text(
                        gujaratiName,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (city != null && city.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 12, color: Color(0xFFA4143D)),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              city,
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (experience != null && experience.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        experience,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: ElevatedButton.icon(
                    onPressed: () => _makePhoneCall(phone),
                    icon: const Icon(Icons.call, size: 13),
                    label: const Text('Call Now', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF101B36),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      side: const BorderSide(color: Color(0xFFD6A34A), width: 1),
                      elevation: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: ElevatedButton.icon(
                    onPressed: () => _openWhatsApp(phone, name, serviceTitle),
                    icon: const WhatsAppIcon(size: 14, color: Colors.white),
                    label: const Text('WhatsApp', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 34,
                child: OutlinedButton(
                  onPressed: () => _showProviderDetail(context, provider, serviceTitle),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFA4143D),
                    side: const BorderSide(color: Color(0xFFE5D5BA)),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('વિગત', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalDirectoryCard(BuildContext context, SamajServicePerson person) {
    final effectiveServiceName = person.serviceTitle ?? 'સમાજ સેવા';
    final effectiveIcon = person.serviceIcon ?? '💼';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _showProviderDetail(context, person, effectiveServiceName),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE5D5BA),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF101B36).withValues(alpha: 0.05),
                blurRadius: 10,
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
                  // Avatar Photo with gold border and verified check
                  Stack(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF8F5),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFD6A34A),
                            width: 1.6,
                          ),
                        ),
                        child: ClipOval(
                          child: person.photoUrl != null && person.photoUrl!.isNotEmpty
                              ? Image.network(
                                  person.photoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.person, color: Color(0xFFA4143D), size: 30),
                                  ),
                                )
                              : const Center(
                                  child: Icon(Icons.person, color: Color(0xFFA4143D), size: 30),
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, size: 9, color: Colors.white),
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
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF101B36),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (person.gujaratiName != null && person.gujaratiName != person.name) ...[
                          const SizedBox(height: 2),
                          Text(
                            person.gujaratiName!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 5),
                        // Service Badge in Velvet Maroon & Gold tint
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF8F5),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE5D5BA), width: 0.9),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(effectiveIcon, style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  effectiveServiceName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFA4143D),
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
                    const Icon(Icons.location_on, size: 13, color: Color(0xFFD6A34A)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        person.address != null && person.address!.isNotEmpty
                            ? '${person.city}, ${person.address}'
                            : person.city!,
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF4B5563), fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (person.description != null && person.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFF3F4F6)),
                  ),
                  child: Text(
                    person.description!,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563), fontStyle: FontStyle.italic),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const Spacer(),
              // Action Buttons Row (Call, WhatsApp, Details)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: ElevatedButton.icon(
                        onPressed: () => _makePhoneCall(person.phone),
                        icon: const Icon(Icons.call, size: 13, color: Color(0xFFFFDF7A)),
                        label: const Text(
                          'Call Now',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF101B36),
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFD6A34A), width: 0.9),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: ElevatedButton.icon(
                        onPressed: () => _openWhatsApp(person.phone, person.name, effectiveServiceName),
                        icon: const WhatsAppIcon(size: 14, color: Colors.white),
                        label: const Text(
                          'WhatsApp',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    height: 34,
                    child: OutlinedButton(
                      onPressed: () => _showProviderDetail(context, person, effectiveServiceName),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFA4143D),
                        side: const BorderSide(color: Color(0xFFE5D5BA)),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('વિગત', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllProfessionalsView(BuildContext context, bool isDesktop) {
    return ref.watch(allSamajServicePersonsProvider(_searchQuery)).when(
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
          return Container(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off_rounded, size: 54, color: Colors.grey.shade400),
                  const SizedBox(height: 14),
                  const Text(
                    'કોઈ વ્યવસાયી મળ્યા નથી (No Professionals Found)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF101B36)),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'તમારો વ્યવસાય ઉમેરવા માટે ઉપર "+ વ્યવસાય ઉમેરો" બટન દબાવો',
                    style: TextStyle(fontSize: 12.5, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        if (isDesktop) {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 215,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) => _buildProfessionalDirectoryCard(context, filtered[index]),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) => SizedBox(
            height: 215,
            child: _buildProfessionalDirectoryCard(context, filtered[index]),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFA4143D)),
        ),
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
    );
  }

  void _showProviderDetail(BuildContext context, dynamic provider, String serviceName) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580, maxHeight: 720),
          child: _buildProviderDetailDialog(ctx, provider, serviceName),
        ),
      ),
    );
  }

  Widget _buildProviderDetailDialog(BuildContext ctx, dynamic provider, String serviceName) {
    int currentRating = 0;
    final photoUrl = provider.photoUrl?.toString();
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;
    final phone = provider.phone?.toString() ?? '';
    final name = provider.name?.toString() ?? '';
    final gujaratiName = provider.gujaratiName?.toString();
    final city = provider.city?.toString();
    final address = provider.address?.toString();
    final description = provider.description?.toString();
    final experience = provider.experience?.toString();

    return StatefulBuilder(
      builder: (ctx, setLocalState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header Banner
            Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 12, 14),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF101B36), Color(0xFF1B2C52)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD6A34A), width: 1.8),
                    ),
                    child: ClipOval(
                      child: hasPhoto
                          ? Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.person, color: Color(0xFFFFDF7A), size: 28),
                              ),
                            )
                          : const Center(
                              child: Icon(Icons.person, color: Color(0xFFFFDF7A), size: 28),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (gujaratiName != null && gujaratiName != name) ...[
                          const SizedBox(height: 2),
                          Text(
                            gujaratiName,
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 3),
                        Text(
                          serviceName,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFDF7A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),

            // 2. Scrollable Details Body
            Flexible(
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location & Address Card
                      if ((city != null && city.isNotEmpty) || (address != null && address.isNotEmpty))
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF8F5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE5D5BA)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on, size: 18, color: Color(0xFFA4143D)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (city != null && city.isNotEmpty)
                                      Text(
                                        city,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: Color(0xFF101B36),
                                        ),
                                      ),
                                    if (address != null && address.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        address,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Description / Bio
                      if (description != null && description.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF8F5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE5D5BA)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'વિગત / પરિચય (About & Experience):',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFA4143D),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                description,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF101B36), height: 1.4),
                              ),
                              if (experience != null && experience.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  'અનુભવ: $experience',
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],

                      // Direct Action Buttons: Call & WhatsApp
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _makePhoneCall(phone),
                              icon: const Icon(Icons.call, size: 16),
                              label: const Text('Call Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF101B36),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                side: const BorderSide(color: Color(0xFFD6A34A), width: 1.2),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _openWhatsApp(phone, name, serviceName),
                              icon: const WhatsAppIcon(size: 16, color: Colors.white),
                              label: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Divider(color: Color(0xFFE5D5BA)),
                      ),

                      // Rating Section
                      const Text(
                        'સમાજ રિવ્યુ આપો (Rate this Professional):',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF101B36)),
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
                                  starIndex < currentRating ? Icons.star_rounded : Icons.star_outline_rounded,
                                  color: const Color(0xFFD6A34A),
                                  size: 32,
                                ),
                                onPressed: () => setLocalState(() => currentRating = starIndex + 1),
                              );
                            }),
                          ),
                          if (currentRating > 0)
                            ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('આભાર! તમારો રિવ્યુ સબમિટ થયો છે (Review submitted!)')),
                                );
                                setLocalState(() => currentRating = 0);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFA4143D),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                              child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFFAF8F5),
                border: Border(top: BorderSide(color: Color(0xFFE5D5BA), width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF475569),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    child: const Text('બંધ કરો (Close)', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
      appBar: kIsWeb ? const WebHomeHeader(activeRoute: '/samaj-services') : null,
      backgroundColor: const Color(0xFFFAF8F5),
      body: SafeArea(
        top: !kIsWeb,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 850;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isDesktop ? 1280 : 1000),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: isDesktop ? 40 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Header Banner with True Aspect Ratio (1600 x 592)
                      _buildHeaderBanner(isDesktop),

                      const SizedBox(height: 12),

                      // 2. Title Capsule Badge
                      _buildTitleBadge(isDesktop),

                      const SizedBox(height: 14),

                      // 3. Add Business Callout Banner
                      _buildAddBusinessBanner(isDesktop, context),

                      const SizedBox(height: 14),

                      // 4. Search & Filter Section
                      _buildSearchSection(isDesktop, districtsList, talukasList),

                      const SizedBox(height: 14),

                      // 5. Tab Selector: Professionals vs Categories
                      _buildTabSelector(isDesktop),

                      const SizedBox(height: 16),

                      // 6. Content Section
                      if (_selectedTabIndex == 0)
                        _buildAllProfessionalsView(context, isDesktop)
                      else
                        _buildCategoriesView(context, isDesktop),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderBanner(bool isDesktop) {
    return Padding(
      padding: EdgeInsets.only(
        top: isDesktop ? 12 : 8,
        left: isDesktop ? 8 : 4,
        right: isDesktop ? 8 : 4,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bannerWidth = constraints.maxWidth;
          // Native banner aspect ratio is 1600 x 592 (2.7027:1)
          final bannerHeight = bannerWidth * (592.0 / 1600.0);

          return Container(
            width: bannerWidth,
            height: bannerHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isDesktop ? 14 : 10),
              border: Border.all(
                color: const Color(0xFFD6A34A).withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF101B36).withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/govt_section_banner_clean.png',
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/govt_section_banner_new.png',
                fit: BoxFit.fill,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitleBadge(bool isDesktop) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 24 : 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFD6A34A), width: 1.6),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD6A34A).withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isDesktop ? 36 : 32,
              height: isDesktop ? 36 : 32,
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFDF7A), Color(0xFFD6A34A), Color(0xFF8C6D15)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD6A34A).withValues(alpha: 0.35),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => CircleAvatar(
                    backgroundColor: const Color(0xFFA4143D),
                    radius: isDesktop ? 18 : 16,
                    child: Icon(Icons.handshake_outlined,
                        color: Colors.white, size: isDesktop ? 20 : 18),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'વણકર સમાજ સેવાઓ અને વ્યવસાય ડિરેક્ટરી',
                  style: TextStyle(
                    fontSize: isDesktop ? 15.5 : 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFA4143D),
                    letterSpacing: 0.2,
                  ),
                ),
                Text(
                  'Vankar Samaj Services • સમાજ માટે, સમાજ દ્વારા',
                  style: TextStyle(
                    fontSize: isDesktop ? 11.5 : 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF101B36).withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddBusinessBanner(bool isDesktop, BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 8 : 6),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 20 : 14,
        vertical: isDesktop ? 14 : 12,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF101B36), Color(0xFF1B2C52)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD6A34A).withValues(alpha: 0.75),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101B36).withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFE082), Color(0xFFD6A34A)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD6A34A).withValues(alpha: 0.35),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: Color(0xFF101B36),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'તમારો વ્યવસાય અથવા સેવા અહીં દર્શાવો',
                  style: TextStyle(
                    color: const Color(0xFFFFE082),
                    fontWeight: FontWeight.bold,
                    fontSize: isDesktop ? 15 : 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'પ્રોફાઇલમાં બિઝનેસ ઉમેરી સમાજના હજારો પરિવારો સાથે જોડાઓ',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: isDesktop ? 12 : 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: () {
              _showAddBusinessModal(context);
            },
            icon: const Icon(Icons.add_business_rounded, size: 16),
            label: Text(
              isDesktop ? '+ વ્યવસાય ઉમેરો' : '+ ઉમેરો',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA4143D),
              foregroundColor: Colors.white,
              elevation: 3,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 16 : 12,
                vertical: isDesktop ? 12 : 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Color(0xFFD6A34A), width: 1.2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(
      bool isDesktop, List<String> districtsList, List<String> talukasList) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 8 : 6),
      padding: EdgeInsets.all(isDesktop ? 18 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5D5BA),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101B36).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search Input Field
          TextField(
            controller: _searchController,
            style: const TextStyle(
              color: Color(0xFF101B36),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textInputAction: TextInputAction.search,
            onChanged: (val) {
              setState(() {
                _searchQuery = val.trim();
              });
            },
            onSubmitted: (_) => _performSearch(),
            decoration: InputDecoration(
              hintText: 'Search services, professions (e.g. Grain Trading, IT, Printing)...',
              hintStyle: TextStyle(
                color: const Color(0xFF101B36).withValues(alpha: 0.45),
                fontSize: 13,
              ),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: Color(0xFFA4143D), size: 22),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded,
                          color: Colors.grey, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFFAF8F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5D5BA)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5D5BA)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFA4143D), width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),

          // Location Dropdowns & Village Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 650;
              if (isSmall) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildDistrictDropdown(districtsList)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildTalukaDropdown(talukasList)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildVillageInput(),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: _buildDistrictDropdown(districtsList)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTalukaDropdown(talukasList)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildVillageInput()),
                ],
              );
            },
          ),

          const SizedBox(height: 14),

          // Action Buttons: Search & Clear
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _performSearch,
                  icon: const Icon(Icons.search_rounded,
                      size: 18, color: Color(0xFFFFDF7A)),
                  label: const Text(
                    'Search | ફિલ્ટર લાગુ કરો',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      letterSpacing: 0.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA4143D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              if (_searchQuery.isNotEmpty ||
                  selectedDistrict != null ||
                  selectedTaluka != null ||
                  _villageController.text.isNotEmpty) ...[
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Clear Filter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFA4143D),
                    side: const BorderSide(color: Color(0xFFA4143D)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 13, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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

  Widget _buildDistrictDropdown(List<String> districtsList) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 6,
      menuMaxHeight: 300,
      iconEnabledColor: const Color(0xFFA4143D),
      iconDisabledColor: Colors.grey,
      style: const TextStyle(
        color: Color(0xFF101B36),
        fontWeight: FontWeight.w600,
        fontSize: 12.5,
      ),
      hint: const Text(
        'District (જિલ્લો)',
        style: TextStyle(
          fontSize: 12,
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w500,
        ),
      ),
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5D5BA))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5D5BA))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Color(0xFFA4143D), width: 1.4)),
        filled: true,
        fillColor: const Color(0xFFFAF8F5),
      ),
      value: selectedDistrict,
      items: districtsList
          .map((d) => DropdownMenuItem(
                value: d,
                child: Text(d, overflow: TextOverflow.ellipsis),
              ))
          .toList(),
      onChanged: (val) => setState(() {
        selectedDistrict = val;
        selectedTaluka = null;
      }),
    );
  }

  Widget _buildTalukaDropdown(List<String> talukasList) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 6,
      menuMaxHeight: 300,
      iconEnabledColor: const Color(0xFFA4143D),
      iconDisabledColor: Colors.grey,
      style: const TextStyle(
        color: Color(0xFF101B36),
        fontWeight: FontWeight.w600,
        fontSize: 12.5,
      ),
      hint: const Text(
        'Taluka (તાલુકો)',
        style: TextStyle(
          fontSize: 12,
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w500,
        ),
      ),
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5D5BA))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5D5BA))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Color(0xFFA4143D), width: 1.4)),
        filled: true,
        fillColor: const Color(0xFFFAF8F5),
      ),
      value: selectedTaluka,
      items: talukasList.isEmpty
          ? null
          : talukasList
              .map((t) => DropdownMenuItem(
                    value: t,
                    child: Text(t, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
      onChanged: talukasList.isEmpty
          ? null
          : (val) => setState(() => selectedTaluka = val),
    );
  }

  Widget _buildVillageInput() {
    return TextField(
      controller: _villageController,
      style: const TextStyle(
        color: Color(0xFF101B36),
        fontWeight: FontWeight.w600,
        fontSize: 12.5,
      ),
      decoration: InputDecoration(
        hintText: 'Village (ગામ)',
        hintStyle: const TextStyle(
          fontSize: 12,
          color: Color(0xFF64748B),
          fontWeight: FontWeight.w500,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5D5BA))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5D5BA))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                const BorderSide(color: Color(0xFFA4143D), width: 1.4)),
        filled: true,
        fillColor: const Color(0xFFFAF8F5),
      ),
    );
  }

  Widget _buildTabSelector(bool isDesktop) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 8 : 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD6A34A).withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF101B36).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _selectedTabIndex = 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: _selectedTabIndex == 0
                        ? const LinearGradient(
                            colors: [Color(0xFF101B36), Color(0xFF1E2E4F)],
                          )
                        : null,
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
                            ? const Color(0xFFFFDF7A)
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'વ્યવસાયકારો (Professionals)',
                        style: TextStyle(
                          color: _selectedTabIndex == 0
                              ? Colors.white
                              : const Color(0xFF334155),
                          fontWeight: FontWeight.bold,
                          fontSize: isDesktop ? 13.5 : 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _selectedTabIndex = 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: _selectedTabIndex == 1
                        ? const LinearGradient(
                            colors: [Color(0xFF101B36), Color(0xFF1E2E4F)],
                          )
                        : null,
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
                            ? const Color(0xFFFFDF7A)
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'સેવા કેટેગરી (Categories)',
                        style: TextStyle(
                          color: _selectedTabIndex == 1
                              ? Colors.white
                              : const Color(0xFF334155),
                          fontWeight: FontWeight.bold,
                          fontSize: isDesktop ? 13.5 : 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  static const List<String> _categorySortOrder = [
    'Wedding',
    'Home & Daily Life Services',
    'Vehicle & Transport',
    'Computer & Digital Services',
    'Education Services',
    'Job & Business Services',
    'Legal & Financial Services',
    'Health & Emergency',
    'Business & Local Shops',
    'Skilled Professionals',
    'Agriculture & Farming',
    'Trolley, Caster Wheel & Cane Products',
    'Government & Samaj Public Services',
    'Art, Culture & Entertainment',
  ];

  String _normalizeCategory(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower.contains('wedding') ||
        lower.contains('event') ||
        lower.contains('લગ્ન') ||
        lower.contains('safav') ||
        lower.contains('સાફા')) {
      return 'Wedding';
    }
    if (lower.contains('home') || lower.contains('daily life') || lower.contains('ઘર')) {
      return 'Home & Daily Life Services';
    }
    if (lower.contains('vehicle') || lower.contains('transport') || lower.contains('વાહન')) {
      return 'Vehicle & Transport';
    }
    if (lower.contains('computer') || lower.contains('digital') || lower.contains('કમ્પ્યુટર') || lower.contains('it')) {
      return 'Computer & Digital Services';
    }
    if (lower.contains('education') || lower.contains('coaching') || lower.contains('શિક્ષણ')) {
      return 'Education Services';
    }
    if (lower.contains('job') || lower.contains('career') || lower.contains('નોકરી')) {
      return 'Job & Business Services';
    }
    if (lower.contains('legal') || lower.contains('financial') || lower.contains('કાનૂની') || lower.contains('નાણાકીય')) {
      return 'Legal & Financial Services';
    }
    if (lower.contains('health') || lower.contains('emergency') || lower.contains('doctor') || lower.contains('આરોગ્ય') || lower.contains('physio')) {
      return 'Health & Emergency';
    }
    if (lower.contains('shop') || lower.contains('store') || lower.contains('દુકાન') || lower.contains('textile') || lower.contains('વેપાર')) {
      return 'Business & Local Shops';
    }
    if (lower.contains('skilled') || lower.contains('technician') || lower.contains('કારીગર')) {
      return 'Skilled Professionals';
    }
    if (lower.contains('agri') || lower.contains('farm') || lower.contains('ખેતી')) {
      return 'Agriculture & Farming';
    }
    if (lower.contains('trolley') || lower.contains('caster') || lower.contains('cane') || lower.contains('ટ્રોલી')) {
      return 'Trolley, Caster Wheel & Cane Products';
    }
    if (lower.contains('govt') || lower.contains('government') || lower.contains('સરકારી') || lower.contains('સમાજ')) {
      return 'Government & Samaj Public Services';
    }
    if (lower.contains('art') || lower.contains('culture') || lower.contains('media') || lower.contains('કલા')) {
      return 'Art, Culture & Entertainment';
    }
    return raw.trim();
  }

  String _getCategoryDisplayTitle(String cat) {
    switch (cat) {
      case 'Wedding':
        return 'Wedding Services (લગ્ન પ્રસંગ સેવાઓ)';
      case 'Home & Daily Life Services':
        return 'Home & Daily Life Services (ઘર અને દૈનિક જીવનની સેવાઓ)';
      case 'Vehicle & Transport':
        return 'Vehicle & Transport Services (વાહન અને પરિવહન સેવાઓ)';
      case 'Computer & Digital Services':
        return 'Computer & Digital Services (કમ્પ્યુટર અને ડિજિટલ સેવાઓ)';
      case 'Education Services':
        return 'Education Services (શિક્ષણ સેવાઓ)';
      case 'Job & Business Services':
        return 'Job & Business Services (નોકરી અને કારકિર્દી સેવાઓ)';
      case 'Legal & Financial Services':
        return 'Legal & Financial Services (કાનૂની અને નાણાકીય સેવાઓ)';
      case 'Health & Emergency':
        return 'Health & Emergency (આરોગ્ય અને કટોકટી સેવાઓ)';
      case 'Business & Local Shops':
        return 'Business & Local Shops (વેપાર અને સ્થાનિક દુકાનો)';
      case 'Skilled Professionals':
        return 'Skilled Professionals (કુશળ કારીગરો અને ટેકનિશિયન)';
      case 'Agriculture & Farming':
        return 'Agriculture & Farming (ખેતીવાડી અને પશુપાલન સેવાઓ)';
      case 'Trolley, Caster Wheel & Cane Products':
        return 'Trolley, Caster Wheel & Cane Products (ટ્રોલી અને વાંસ-કેન ઉદ્યોગ)';
      case 'Government & Samaj Public Services':
        return 'Government & Samaj Public Services (સરકારી અને સમાજ સહાયક સેવાઓ)';
      case 'Art, Culture & Entertainment':
        return 'Art, Culture & Entertainment (કલા, સંસ્કૃતિ અને મનોરંજન)';
      default:
        return cat;
    }
  }

  Widget _buildCategoriesView(BuildContext context, bool isDesktop) {
    return ref.watch(samajServicesProvider).when(
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
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5D5BA)),
            ),
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
                    color: Color(0xFF101B36),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '"$_searchQuery" માટે કોઈ મેળ ખાતી સેવા નથી',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('તમામ સેવાઓ જુઓ (Show All)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA4143D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Group filtered services by normalized category
        final Map<String, List<SamajService>> groupedServices = {};
        for (final service in filteredServices) {
          final catKey = _normalizeCategory(service.category);
          groupedServices
              .putIfAbsent(catKey, () => [])
              .add(service);
        }

        final categories = groupedServices.keys.toList()
          ..sort((a, b) {
            final idxA = _categorySortOrder.indexOf(a);
            final idxB = _categorySortOrder.indexOf(b);
            if (idxA != -1 && idxB != -1) return idxA.compareTo(idxB);
            if (idxA != -1) return -1;
            if (idxB != -1) return 1;
            return a.compareTo(b);
          });

        return Column(
          children: [
            if (_searchQuery.isNotEmpty)
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 8 : 6, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                          color: Color(0xFFA4143D),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                vertical: 8,
                horizontal: isDesktop ? 8 : 4,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final categoryName = categories[index];
                final List<SamajService> items =
                    groupedServices[categoryName]!;
                final bool isWedding = categoryName == 'Wedding';
                final Color themeColor = isWedding
                    ? const Color(0xFFA4143D)
                    : const Color(0xFF101B36);
                final IconData iconData =
                    isWedding ? Icons.celebration_rounded : Icons.category_rounded;
                final String displayCategoryTitle = _getCategoryDisplayTitle(categoryName);

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE5D5BA),
                      width: 1.2,
                    ),
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
                      // Category Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isWedding
                              ? const Color(0xFFFFF5F5)
                              : const Color(0xFFFAF8F5),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                          border: const Border(
                            bottom: BorderSide(
                              color: Color(0xFFE5D5BA),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: themeColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(iconData, color: themeColor, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                displayCategoryTitle,
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                  color: themeColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAF8F5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFFD6A34A)),
                              ),
                              child: Text(
                                '${items.length} સેવાઓ',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFA4143D),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Items Grid
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: LayoutBuilder(
                          builder: (context, gridConstraints) {
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: isDesktop ? 340 : 280,
                                mainAxisExtent: 64,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: items.length,
                              itemBuilder: (context, itemIndex) {
                                final SamajService service = items[itemIndex];
                                final String emoji = service.icon;
                                final String text = service.title;

                                return MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      _showServiceProviders(context, service);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFAF8F5),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFE5D5BA),
                                          width: 1,
                                        ),
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
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF101B36),
                                                height: 1.25,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.chevron_right_rounded,
                                            color: Color(0xFFA4143D),
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA4143D)),
          ),
        ),
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Error loading services: $err',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}


class _AddBusinessDialogContent extends ConsumerStatefulWidget {
  final SamajService? defaultService;
  final VoidCallback onSuccess;

  const _AddBusinessDialogContent({
    this.defaultService,
    required this.onSuccess,
  });

  @override
  ConsumerState<_AddBusinessDialogContent> createState() =>
      _AddBusinessDialogContentState();
}

class _AddBusinessDialogContentState
    extends ConsumerState<_AddBusinessDialogContent> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedServiceId;
  final _nameController = TextEditingController();
  final _gujaratiNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _descController = TextEditingController();
  final _expController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedServiceId = widget.defaultService?.id;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gujaratiNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _descController.dispose();
    _expController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final serviceId = _selectedServiceId ?? widget.defaultService?.id;
    if (serviceId == null || serviceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('કૃપા કરીને સેવાનો પ્રકાર પસંદ કરો (Please select service category).'),
          backgroundColor: Color(0xFFA4143D),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(samajServiceRepositoryProvider);
      final success = await repo.registerServicePerson(
        serviceId: serviceId,
        name: _nameController.text.trim(),
        gujaratiName: _gujaratiNameController.text.trim().isNotEmpty
            ? _gujaratiNameController.text.trim()
            : null,
        phone: _phoneController.text.trim(),
        city: _cityController.text.trim().isNotEmpty
            ? _cityController.text.trim()
            : null,
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        description: _descController.text.trim().isNotEmpty
            ? _descController.text.trim()
            : null,
        experience: _expController.text.trim().isNotEmpty
            ? _expController.text.trim()
            : null,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (success) {
        Navigator.pop(context);
        widget.onSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('નોંધણી દરમિયાન ખામી સર્જાઈ. કૃપા કરીને ફરી પ્રયાસ કરો.'),
            backgroundColor: Color(0xFFA4143D),
          ),
        );
      }
    } catch (err) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ખામી: $err'),
            backgroundColor: const Color(0xFFA4143D),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allServicesAsync = ref.watch(samajServicesProvider);

    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.white,
        canvasColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFA4143D),
          secondary: Color(0xFFD6A34A),
          surface: Colors.white,
          onSurface: Color(0xFF0F172A),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF0F172A)),
          bodyMedium: TextStyle(color: Color(0xFF0F172A)),
          titleMedium: TextStyle(color: Color(0xFF0F172A)),
        ),
      ),
      child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Executive Navy/Gold Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF041126), Color(0xFF0B2146)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(
              bottom: BorderSide(color: Color(0xFFD6A34A), width: 1.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6A34A).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD6A34A), width: 1),
                ),
                child: const Icon(
                  Icons.add_business_rounded,
                  color: Color(0xFFD6A34A),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'તમારો વ્યવસાય ઉમેરો (Add Business)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'સમાજના પરિવારો સુધી તમારી સેવાઓ પહોંચાડો',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Close',
              ),
            ],
          ),
        ),

        // 2. Scrollable Form Body
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Selection Card
                  if (widget.defaultService != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF5E8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5D5BA)),
                      ),
                      child: Row(
                        children: [
                          Text(
                            widget.defaultService!.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.defaultService!.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF101B36),
                                  ),
                                ),
                                Text(
                                  'કેટેગરી: ${widget.defaultService!.category}',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF108A44).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'પસંદિત સેવા',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF108A44),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    allServicesAsync.when(
                      data: (services) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'સેવાનો પ્રકાર / કેટેગરી પસંદ કરો *',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              value: _selectedServiceId,
                              dropdownColor: Colors.white,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                prefixIcon: const Icon(
                                  Icons.category_outlined,
                                  color: Color(0xFFA4143D),
                                  size: 20,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                              ),
                              hint: const Text(
                                'સેવા પસંદ કરો (Select Service)',
                                style: TextStyle(fontSize: 13),
                              ),
                              items: services.map((s) {
                                return DropdownMenuItem<String>(
                                  value: s.id,
                                  child: Text(
                                    '${s.icon} ${s.title}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF0F172A),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() => _selectedServiceId = val);
                              },
                              validator: (val) => val == null || val.isEmpty
                                  ? 'કૃપા કરીને સેવા પસંદ કરો'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],

                  // Business / Owner Name
                  const Text(
                    'વ્યવસાય અથવા માલિકનું નામ (Business / Owner Name) *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                    cursorColor: const Color(0xFFA4143D),
                    decoration: InputDecoration(
                      hintText: 'દા.ત. શ્રી ગણેશ પ્રિન્ટિંગ / રમેશભાઈ વણકર',
                      hintStyle:
                          TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.badge_outlined,
                          color: Color(0xFFA4143D), size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'કૃપા કરીને નામ દાખલ કરો'
                        : null,
                  ),
                  const SizedBox(height: 14),

                  // Contact / Mobile Number
                  const Text(
                    'સંપર્ક નંબર / મોબાઇલ (Phone Number) *',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                    cursorColor: const Color(0xFFA4143D),
                    decoration: InputDecoration(
                      hintText: 'દા.ત. 9876543210 (10 Digits)',
                      hintStyle:
                          TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.phone_outlined,
                          color: Color(0xFFA4143D), size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'કૃપા કરીને મોબાઇલ નંબર દાખલ કરો';
                      }
                      final digits = val.replaceAll(RegExp(r'[^0-9]'), '');
                      if (digits.length < 10) {
                        return 'કૃપા કરીને ૧૦ અંકનો સાચો મોબાઇલ નંબર દાખલ કરો';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // City / Village & Experience (Row)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'શહેર / ગામ (City / Village) *',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _cityController,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                              cursorColor: const Color(0xFFA4143D),
                              decoration: InputDecoration(
                                hintText: 'દા.ત. અમદાવાદ / મહેસાણા',
                                hintStyle: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade400),
                                prefixIcon: const Icon(
                                    Icons.location_city_outlined,
                                    color: Color(0xFFA4143D),
                                    size: 20),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFCBD5E1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFCBD5E1)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                              ),
                              validator: (val) => val == null || val.trim().isEmpty
                                  ? 'શહેર/ગામ દાખલ કરો'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'અનુભવ (Experience)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _expController,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                              cursorColor: const Color(0xFFA4143D),
                              decoration: InputDecoration(
                                hintText: 'દા.ત. ૫ વર્ષ (5 Years)',
                                hintStyle: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade400),
                                prefixIcon: const Icon(
                                    Icons.work_history_outlined,
                                    color: Color(0xFFA4143D),
                                    size: 20),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFCBD5E1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: Color(0xFFCBD5E1)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Office / Shop Address
                  const Text(
                    'દુકાન / ઓફિસનું સરનામું (Address)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _addressController,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                    cursorColor: const Color(0xFFA4143D),
                    decoration: InputDecoration(
                      hintText: 'દા.ત. ૨૦૪, શિવમ કોમ્પ્લેક્સ, સ્ટેશન રોડ',
                      hintStyle:
                          TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.place_outlined,
                          color: Color(0xFFA4143D), size: 20),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Description / Specialties
                  const Text(
                    'સેવા વિશે વિગતો (Description & Services Offered)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                    cursorColor: const Color(0xFFA4143D),
                    decoration: InputDecoration(
                      hintText:
                          'દા.ત. કંકોતરી, કાર્ડ પ્રિન્ટિંગ, ફ્લેક્સ બેનર, વિઝિટિંગ કાર્ડ વગેરેનું કામ કરી આપવામાં આવે છે.',
                      hintStyle:
                          TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: Icon(Icons.description_outlined,
                            color: Color(0xFFA4143D), size: 20),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // 3. Dialog Footer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            color: Color(0xFFFAF8F5),
            border: Border(
              top: BorderSide(color: Color(0xFFE5D5BA), width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF475569),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: const Text('રદ કરો (Cancel)'),
              ),
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline, size: 16),
                label: Text(
                  _isSubmitting ? 'નોંધણી થઈ રહી છે...' : '+ વ્યવસાય ઉમેરો (Submit)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA4143D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    );
  }
}
