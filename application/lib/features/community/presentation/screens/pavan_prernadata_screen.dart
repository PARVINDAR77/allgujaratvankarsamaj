import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/pavan_prernadata_provider.dart';
import '../../../home/presentation/providers/view_badge.dart';
import '../../../home/presentation/providers/views_provider.dart';
import '../../../home/presentation/widgets/web_home_header.dart';
import '../../../home/presentation/widgets/web_home_footer.dart';

class PavanPrernadataScreen extends ConsumerStatefulWidget {
  const PavanPrernadataScreen({super.key});

  @override
  ConsumerState<PavanPrernadataScreen> createState() => _PavanPrernadataScreenState();
}

class _PavanPrernadataScreenState extends ConsumerState<PavanPrernadataScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;

  // Pushpanjali tribute tracking & animation
  final Map<String, int> _tributeCounts = {};
  late AnimationController _petalController;
  final List<_PetalParticle> _petals = [];
  final math.Random _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Petal cascade animation (runs for 2.8 seconds on tribute tap)
    _petalController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _initPetals();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(incrementViewProvider)('PAVAN_PRERNADATA');
    });
  }

  void _initPetals() {
    _petals.clear();
    final petalColors = [
      const Color(0xFFFF5252), // Rose red
      const Color(0xFFE91E63), // Pink rose
      const Color(0xFFFF9800), // Marigold orange
      const Color(0xFFFFD54F), // Marigold yellow
      const Color(0xFFF48FB1), // Lotus pink
      const Color(0xFFD4AF37), // Sacred gold
    ];

    for (int i = 0; i < 45; i++) {
      _petals.add(
        _PetalParticle(
          x: _rng.nextDouble(),
          speed: 0.8 + _rng.nextDouble() * 0.7,
          size: 14 + _rng.nextDouble() * 14,
          swingAmp: 25 + _rng.nextDouble() * 35,
          swingFreq: 3 + _rng.nextDouble() * 4,
          initialPhase: _rng.nextDouble() * math.pi * 2,
          color: petalColors[_rng.nextInt(petalColors.length)],
          rotationSpeed: (_rng.nextDouble() - 0.5) * 6,
        ),
      );
    }
  }

  void _sendSnehVandan(PavanPrernadata item) {
    HapticFeedback.mediumImpact();
    setState(() {
      _tributeCounts[item.id] = (_tributeCounts[item.id] ?? 0) + 1;
    });

    _initPetals();
    _petalController.forward(from: 0.0);

    final displayName = item.gujaratiName?.isNotEmpty == true
        ? item.gujaratiName!
        : item.name;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0C2448),
        elevation: 8,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
        ),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            const Text('✨', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'શ્રી $displayName ને આપનું ભાવભર્યું સ્નેહ વંદન પાઠવવામાં આવ્યું! 🙏',
                style: const TextStyle(
                  color: Color(0xFFFFF2C2),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPhotoLightbox(BuildContext context, PavanPrernadata item) {
    if (item.photoUrl == null || item.photoUrl!.isEmpty) return;

    final displayName = item.gujaratiName?.isNotEmpty == true
        ? item.gujaratiName!
        : item.name;

    showDialog(
      context: context,
      barrierColor: const Color(0xEB000000),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: Hero(
                  tag: 'prernadata-photo-${item.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      item.photoUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.broken_image, size: 64, color: Colors.white54),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
              Positioned(
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xE6041126),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 1),
                  ),
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _petalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(pavanPrernadataProvider);

    if (kIsWeb) {
      return _buildWebScaffold(context, asyncData);
    }
    return _buildMobileScaffold(context, asyncData);
  }

  Widget _buildMobileScaffold(BuildContext context, AsyncValue<List<PavanPrernadata>> asyncData) {
    return Scaffold(
      backgroundColor: const Color(0xFF020914),
      body: Stack(
        children: [
          // Background royal gradient decoration
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.3),
                  radius: 1.2,
                  colors: [
                    Color(0xFF092042),
                    Color(0xFF041126),
                    Color(0xFF020914),
                  ],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // Main Content
          asyncData.when(
            data: (items) {
              if (items.isEmpty) {
                return _buildEmptyState();
              }
              return _buildFullscreenPageView(items);
            },
            loading: () => const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFFD4AF37)),
                  SizedBox(height: 16),
                  Text(
                    'પાવન પ્રેરણાદાતા દર્શન લોડ થઈ રહ્યું છે...',
                    style: TextStyle(color: Color(0xFFFFF2C2), fontSize: 14),
                  ),
                ],
              ),
            ),
            error: (err, stack) => _buildErrorState(err),
          ),

          // Falling Petals Particle Overlay
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _petalController,
                builder: (context, _) {
                  if (!_petalController.isAnimating) {
                    return const SizedBox.shrink();
                  }
                  return CustomPaint(
                    painter: _FallingPetalsPainter(
                      progress: _petalController.value,
                      petals: _petals,
                    ),
                  );
                },
              ),
            ),
          ),

          // Top Floating Header Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopHeader(asyncData.valueOrNull?.length ?? 0),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ============================ WEB DESKTOP SCAFFOLD ==========================
  // ===========================================================================
  Widget _buildWebScaffold(BuildContext context, AsyncValue<List<PavanPrernadata>> asyncData) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1050;
    final isTablet = width >= 700 && width < 1050;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: const WebHomeHeader(activeRoute: '/pavan-prernadata'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Prestigious Hero Banner with Breadcrumbs & Title
            _buildWebHeroBanner(context, isDesktop),

            // 2. Centered Content Container
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : (isTablet ? 20 : 16),
                    vertical: 36,
                  ),
                  child: asyncData.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(60.0),
                        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                      ),
                    ),
                    error: (err, _) => _buildWebErrorCard(err),
                    data: (items) {
                      final enrichedItems = _getEnrichedMentors(items);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildWebSectionIntro(),
                          const SizedBox(height: 32),
                          _buildWebMentorGrid(context, enrichedItems, isDesktop, isTablet),
                          const SizedBox(height: 48),
                          _buildWebInspirationBanner(context),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 3. Official Web Home Footer
            const WebHomeFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildWebHeroBanner(BuildContext context, bool isDesktop) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF020F1F),
            Color(0xFF092042),
            Color(0xFF041126),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : 20,
              vertical: isDesktop ? 32 : 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Breadcrumbs & Badges
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => context.go('/main-poster'),
                          borderRadius: BorderRadius.circular(4),
                          child: const Text(
                            'Home',
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF94A3B8)),
                        ),
                        Flexible(
                          child: Text(
                            isDesktop ? 'Pavan Prernadata (પાવન પ્રેરણાદાતા)' : 'પાવન પ્રેરણાદાતા',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFE2E8F0),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => ref.refresh(pavanPrernadataProvider),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.refresh_rounded, size: 15, color: Color(0xFFFFD700)),
                                SizedBox(width: 5),
                                Text(
                                  'Refresh',
                                  style: TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const ViewBadge(sectionName: 'PAVAN_PRERNADATA', isLight: true),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Main Title & Subtitle with Sacred Emblem Icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
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
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(2.5),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF041126),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.flare_rounded,
                            color: Color(0xFFFFD700),
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'પાવન પ્રેરણાદાતા - સમાજ ગૌરવ અને પ્રેરણા',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Honoring the Visionary Mentors, Guides, and Spiritual Pioneers Who Illuminate Our Samaj',
                            style: TextStyle(
                              color: Color(0xFFE2C981),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }

  Widget _buildWebSectionIntro() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  height: 1.5,
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '✦ આદરણીય માર્ગદર્શકો અને પાવન મહાનુભાવો ✦',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF8C5D00),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1.5,
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'સમાજના પ્રત્યેક પરિવાર અને યુવા પેઢી માટે આદર્શ અને પ્રેરણારૂપ આધ્યાત્મિક જ્યોતિર્ધરો',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF475569),
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<PavanPrernadata> _getEnrichedMentors(List<PavanPrernadata> apiItems) {
    final List<PavanPrernadata> result = [];
    
    // Add official default spiritual icons if not already present from database
    final hasBuddha = apiItems.any((e) => e.name.toLowerCase().contains('buddha') || (e.gujaratiName ?? '').contains('બુદ્ધ'));
    if (!hasBuddha) {
      result.add(
        PavanPrernadata(
          id: 'mentor_buddha',
          name: 'Bhagwan Gautama Buddha',
          gujaratiName: 'ભગવાન ગૌતમ બુદ્ધ',
          designation: 'કરુણા અને પ્રજ્ઞાના શાશ્વત પ્રેરક',
          year: 'શાશ્વત માર્ગદર્શક',
          description: 'માનવતા, સમાનતા, કરુણા અને આત્મ દીપો ભવ (પોતાના દીપક પોતે બનો) નો શાશ્વત સંદેશ આપનાર પરમ પ્રેરણાદાતા. સમગ્ર વિશ્વને કરુણા, અહિંસા અને સદાચારનો પાવન માર્ગ દર્શાવ્યો.',
          photoUrl: '',
        ),
      );
    }

    final hasAmbedkar = apiItems.any((e) => e.name.toLowerCase().contains('ambedkar') || (e.gujaratiName ?? '').contains('આંબેડકર'));
    if (!hasAmbedkar) {
      result.add(
        PavanPrernadata(
          id: 'mentor_ambedkar',
          name: 'Dr. B. R. Ambedkar',
          gujaratiName: 'બોધિસત્વ ડૉ. બાબાસાહેબ આંબેડકર',
          designation: 'બંધારણના શિલ્પી અને સામાજિક ક્રાંતિના પ્રણેતા',
          year: 'ભારતરત્ન',
          description: 'શિક્ષિત બનો, સંગઠિત બનો, સંઘર્ષ કરો. સામાજિક સમાનતા, બંધારણીય અધિકારો અને માનવ ગૌરવના અમર પ્રણેતા જેમણે સમાજના પ્રત્યેક વર્ગના ઉત્થાન માટે આજીવન સેવા આપી.',
          photoUrl: '',
        ),
      );
    }

    // Add API items
    result.addAll(apiItems);

    // If still under 4 items, add Sant Kabir and Sant Ravidas
    if (result.length < 4) {
      result.add(
        PavanPrernadata(
          id: 'mentor_kabir',
          name: 'Sant Shiromani Kabir Saheb',
          gujaratiName: 'સંત શિરોમણી કબીર સાહેબ',
          designation: 'સામાજિક સમરસતા અને એકતાના પ્રેરક',
          year: 'અધ્યાત્મિક જ્યોતિર્ધર',
          description: 'કર્મ, સત્ય, સાદગી અને માનવ માત્ર એક સમાન - વણકર પરંપરાના ગૌરવશાળી સંત જેમણે દોહાઓ અને સાધના દ્વારા સમગ્ર માનવજાતને ભાઈચારો અને સમાનતાનો પાવન ઉપદેશ આપ્યો.',
          photoUrl: '',
        ),
      );
      result.add(
        PavanPrernadata(
          id: 'mentor_ravidas',
          name: 'Sant Shiromani Ravidas Maharaj',
          gujaratiName: 'સંત શિરોમણી રોહિદાસ મહારાજ',
          designation: 'સમતાવાદી સમાજના પરમ ચિંતક',
          year: 'શાશ્વત પ્રેરક',
          description: 'મન ચંગા તો કઠોતી મેં ગંગા. શ્રમ, સદાચાર અને માનવીય મૂલ્યોનું ગૌરવ પ્રસ્થાપિત કરનાર આધ્યાત્મિક ગુરુ જેમણે ભેદભાવ વિના સૌને સમાન પ્રેમ આપવાનો સંદેશ આપ્યો.',
          photoUrl: '',
        ),
      );
    }

    return result;
  }

  Widget _buildWebMentorGrid(
    BuildContext context,
    List<PavanPrernadata> items,
    bool isDesktop,
    bool isTablet,
  ) {
    final int crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSpacing = 24.0 * (crossAxisCount - 1);
        final itemWidth = (constraints.maxWidth - totalSpacing) / crossAxisCount;

        return Wrap(
          spacing: 24,
          runSpacing: 24,
          children: items.map((item) {
            return SizedBox(
              width: itemWidth,
              child: _buildWebMentorCard(context, item),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildWebMentorCard(BuildContext context, PavanPrernadata item) {
    final tributeCount = _tributeCounts[item.id] ?? 0;
    final displayName = item.gujaratiName?.isNotEmpty == true ? item.gujaratiName! : item.name;
    final subName = item.name.isNotEmpty && item.name != displayName ? item.name : '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card Header Band with floral aura
          Container(
            height: 10,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                colors: [
                  Color(0xFFD4AF37),
                  Color(0xFFFFF2C2),
                  Color(0xFFB8860B),
                  Color(0xFFD4AF37),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular Portrait Frame
                InkWell(
                  onTap: () {
                    if (item.photoUrl != null && item.photoUrl!.isNotEmpty) {
                      _openPhotoLightbox(context, item);
                    } else {
                      _showWebMentorDetailModal(context, item);
                    }
                  },
                  borderRadius: BorderRadius.circular(60),
                  child: Container(
                    width: 116,
                    height: 116,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
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
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(3.5),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFFFBEB),
                      ),
                      child: ClipOval(
                        child: _buildMentorPhoto(item),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Name (Gujarati in Bold, English in Subtitle)
                Text(
                  displayName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF041126),
                    fontSize: 18.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                if (subName.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    subName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFA4143D),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // Designation / Title Badge
                if (item.designation != null && item.designation!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFCD34D),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      item.designation!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF92400E),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                const SizedBox(height: 14),

                // Description Quote (3 lines max)
                if (item.description != null && item.description!.isNotEmpty)
                  Text(
                    item.description!,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                const SizedBox(height: 20),

                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 16),

                // Action Buttons: View Bio & Sneh Vandan
                Row(
                  children: [
                    // Read Bio Modal Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showWebMentorDetailModal(context, item),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text(
                          'પરિચય જુઓ',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Sneh Vandan Tribute Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _sendSnehVandan(item),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA4143D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 1,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🙏', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 5),
                            const Text(
                              'સ્નેહ વંદન',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                            ),
                            if (tributeCount > 0) ...[
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4AF37),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '+$tributeCount',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentorPhoto(PavanPrernadata item) {
    if (item.photoUrl != null && item.photoUrl!.isNotEmpty) {
      return Image.network(
        item.photoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildMentorAssetFallback(item),
      );
    }
    return _buildMentorAssetFallback(item);
  }

  Widget _buildMentorAssetFallback(PavanPrernadata item) {
    if (item.id == 'mentor_buddha' || item.name.toLowerCase().contains('buddha')) {
      return Image.asset(
        'assets/images/buddha_meditation_sacred.jpg',
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.self_improvement_rounded, size: 50, color: Color(0xFFFFD700)),
        ),
      );
    }
    if (item.id == 'mentor_ambedkar' || item.name.toLowerCase().contains('ambedkar')) {
      return Image.asset(
        'assets/images/babasaheb_ambedkar_poster.jpg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.school_rounded, size: 50, color: Color(0xFFFFD700)),
        ),
      );
    }
    return Container(
      color: const Color(0xFF041126),
      child: Center(
        child: Text(
          (item.gujaratiName?.isNotEmpty == true ? item.gujaratiName![0] : (item.name.isNotEmpty ? item.name[0] : 'પ')),
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 42,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showWebMentorDetailModal(BuildContext context, PavanPrernadata item) {
    final displayName = item.gujaratiName?.isNotEmpty == true ? item.gujaratiName! : item.name;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          width: 560,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Modal Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF020F1F), Color(0xFF092042)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_rounded, color: Color(0xFFFFD700), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),

              // Modal Content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFD4AF37), width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _buildMentorPhoto(item),
                        ),
                      ),
                    ),
                    if (item.designation != null && item.designation!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFCD34D)),
                        ),
                        child: Text(
                          item.designation!,
                          style: const TextStyle(color: Color(0xFF92400E), fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      item.description ?? 'સમાજના આદર્શ અને પ્રેરણાદાતા.',
                      style: const TextStyle(
                        color: Color(0xFF334155),
                        fontSize: 14.5,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _sendSnehVandan(item);
                        },
                        icon: const Text('🙏', style: TextStyle(fontSize: 18)),
                        label: const Text('આદરપૂર્વક સ્નેહ વંદન પાઠવો'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA4143D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebInspirationBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7E102F), Color(0xFFA4143D), Color(0xFF5D0B22)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.4),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: const [
          Text('✨ આત્મ દીપો ભવ • સમાનતા અને કરુણા ✨', style: TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text(
            'સમાજના પ્રત્યેક યુવાન અને દીકરી શિક્ષણ, સંસ્કાર અને સમરસતાના પંથે આગળ વધી સમાજનું ગૌરવ વધારે એ જ આપણા પાવન પ્રેરણાદાતાઓનો સાચો ઉપદેશ છે.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildWebErrorCard(Object err) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFD4AF37)),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            const Text('પાવન પ્રેરણાદાતા માહિતી લોડ થઈ શકી નથી', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(pavanPrernadataProvider),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF041126), foregroundColor: Colors.white),
              child: const Text('ફરી પ્રયાસ કરો (Retry)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(int totalCount) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xF2020914),
            Color(0xB3020914),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFD4AF37), size: 20),
                tooltip: 'પાછા જાઓ',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(width: 4),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'પાવન પ્રેરણાદાતા',
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Pavan Prernadata • સમાજ ગૌરવ',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (totalCount > 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: const Color(0x33D4AF37),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0x66D4AF37), width: 1),
                  ),
                  child: Text(
                    '${_currentPage + 1} / $totalCount',
                    style: const TextStyle(
                      color: Color(0xFFFFF2C2),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const ViewBadge(sectionName: 'PAVAN_PRERNADATA'),
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFFD4AF37), size: 22),
                tooltip: 'Refresh',
                onPressed: () => ref.refresh(pavanPrernadataProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullscreenPageView(List<PavanPrernadata> items) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          physics: const BouncingScrollPhysics(),
          itemCount: items.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildPrernadataTributeCard(item, index, items.length);
          },
        ),

        // Vertical Swipe Helper Badge (shows when multiple records exist)
        if (items.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: _buildSwipeIndicator(items.length),
            ),
          ),
      ],
    );
  }

  Widget _buildSwipeIndicator(int total) {
    final isLast = _currentPage == total - 1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xCC041126),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x44D4AF37), width: 1),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLast ? Icons.keyboard_double_arrow_down : Icons.keyboard_double_arrow_up,
            color: const Color(0xFFD4AF37),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            isLast ? 'પ્રથમ પ્રેરણાદાતા પર જવા નીચે સ્વાઇપ કરો' : 'આગળ જોવા માટે ઉપર સ્વાઇપ કરો 👆',
            style: const TextStyle(
              color: Color(0xFFFFF2C2),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrernadataTributeCard(PavanPrernadata item, int index, int total) {
    final tributeCount = _tributeCounts[item.id] ?? 0;
    final hasPhoto = item.photoUrl != null && item.photoUrl!.isNotEmpty;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SafeArea(
          top: true,
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.only(top: 60.0, bottom: 44.0, left: 20.0, right: 20.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Decorative header emblem
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 32, height: 1, color: const Color(0x80D4AF37)),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                '✦  પાવન પ્રેરણા  ✦',
                                style: TextStyle(
                                  color: Color(0xFFD4AF37),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2.0,
                                ),
                              ),
                            ),
                            Container(width: 32, height: 1, color: const Color(0x80D4AF37)),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Ornate Portrait Frame
                        GestureDetector(
                          onTap: hasPhoto ? () => _openPhotoLightbox(context, item) : null,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer golden halo glow
                              Container(
                                width: 200,
                                height: 200,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x52D4AF37),
                                      blurRadius: 36,
                                      spreadRadius: 6,
                                    ),
                                    BoxShadow(
                                      color: Color(0x800E387A),
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                              ),

                              // Outer floral/ornate ring
                              Container(
                                width: 196,
                                height: 196,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFD4AF37),
                                    width: 3.5,
                                  ),
                                  gradient: const SweepGradient(
                                    colors: [
                                      Color(0xFFD4AF37),
                                      Color(0xFFFFF2C2),
                                      Color(0xFFB8860B),
                                      Color(0xFFD4AF37),
                                    ],
                                  ),
                                ),
                                padding: const EdgeInsets.all(4.5),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF041126),
                                  ),
                                  child: ClipOval(
                                    child: hasPhoto
                                        ? Hero(
                                            tag: 'prernadata-photo-${item.id}',
                                            child: Image.network(
                                              item.photoUrl!,
                                              fit: BoxFit.cover,
                                              width: 180,
                                              height: 180,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  _buildPlaceholderAvatar(item),
                                            ),
                                          )
                                        : _buildPlaceholderAvatar(item),
                                  ),
                                ),
                              ),

                              // Magnifying zoom badge if photo exists
                              if (hasPhoto)
                                Positioned(
                                  bottom: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xE6041126),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFD4AF37), width: 1),
                                      boxShadow: const [
                                        BoxShadow(color: Colors.black54, blurRadius: 4),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.zoom_in, color: Color(0xFFD4AF37), size: 13),
                                        SizedBox(width: 4),
                                        Text(
                                          'મોટું જુઓ',
                                          style: TextStyle(
                                            color: Color(0xFFFFF2C2),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),

                        // Honoree Name (Gujarati + English)
                        if (item.gujaratiName != null && item.gujaratiName!.trim().isNotEmpty) ...[
                          Text(
                            item.gujaratiName!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFFFF2C2),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(color: Colors.black87, blurRadius: 8, offset: Offset(0, 2)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ] else ...[
                          Text(
                            item.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFFFF2C2),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              shadows: [
                                Shadow(color: Colors.black87, blurRadius: 8, offset: Offset(0, 2)),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),

                        // Designation & Year Badge
                        if ((item.designation != null && item.designation!.trim().isNotEmpty) ||
                            (item.year != null && item.year!.trim().isNotEmpty))
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0x33D4AF37), Color(0x1AD4AF37)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0x66D4AF37), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.workspace_premium, color: Color(0xFFD4AF37), size: 16),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    [
                                      if (item.designation != null && item.designation!.trim().isNotEmpty)
                                        item.designation!.trim(),
                                      if (item.year != null && item.year!.trim().isNotEmpty)
                                        '(${item.year!.trim()})',
                                    ].join(' '),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFFD4AF37),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 16),

                        // Biography / Tribute Text Box
                        if (item.description != null && item.description!.trim().isNotEmpty)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xBF071933),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0x33D4AF37), width: 1),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  '“',
                                  style: TextStyle(
                                    color: Color(0xFFD4AF37),
                                    fontSize: 28,
                                    height: 0.8,
                                    fontFamily: 'serif',
                                  ),
                                ),
                                Text(
                                  item.description!.trim(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xE6FFFFFF),
                                    fontSize: 14.5,
                                    height: 1.55,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const Text(
                                  '”',
                                  style: TextStyle(
                                    color: Color(0xFFD4AF37),
                                    fontSize: 28,
                                    height: 0.8,
                                    fontFamily: 'serif',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 24),

                        // Interactive Sneh Vandan (Happiness & Respect) Button
                        Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _sendSnehVandan(item),
                              icon: const Text('✨', style: TextStyle(fontSize: 18)),
                              label: const Text(
                                'સ્નેહ વંદન પાઠવો',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4AF37),
                                foregroundColor: const Color(0xFF020914),
                                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                                elevation: 6,
                                shadowColor: const Color(0x66D4AF37),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                            ),
                            if (tributeCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0x33D4AF37),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: const Color(0x66D4AF37), width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('✨', style: TextStyle(fontSize: 14)),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$tributeCount સ્નેહ વંદન',
                                      style: const TextStyle(
                                        color: Color(0xFFFFF2C2),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderAvatar([PavanPrernadata? item]) {
    if (item != null) {
      return _buildMentorAssetFallback(item);
    }
    return Container(
      color: const Color(0xFF061A36),
      child: const Center(
        child: Icon(
          Icons.person,
          size: 80,
          color: Color(0xFFD4AF37),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0x1AD4AF37),
                  border: Border.all(color: const Color(0x44D4AF37), width: 2),
                ),
                child: const Icon(Icons.lightbulb_outline, size: 48, color: Color(0xFFD4AF37)),
              ),
              const SizedBox(height: 20),
              const Text(
                'પાવન પ્રેરણાદાતા વિભાગ',
                style: TextStyle(
                  color: Color(0xFFFFF2C2),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'હાલમાં કોઈ પાવન પ્રેરણાદાતાની માહિતી ઉપલબ્ધ નથી. નવી માહિતી ઉમેરવામાં આવે ત્યારે અહીં સુંદર પૂર્ણસ્ક્રીન દર્શન થશે.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.5),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(pavanPrernadataProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('રીફ્રેશ કરો'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 54, color: Colors.redAccent),
            const SizedBox(height: 14),
            Text(
              'માહિતી લોડ કરવામાં સમસ્યા આવી: $err',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(pavanPrernadataProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('ફરી પ્રયાસ કરો'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Particle model representing an individual falling flower petal
class _PetalParticle {
  final double x; // 0.0 to 1.0 (relative screen width)
  final double speed;
  final double size;
  final double swingAmp;
  final double swingFreq;
  final double initialPhase;
  final Color color;
  final double rotationSpeed;

  _PetalParticle({
    required this.x,
    required this.speed,
    required this.size,
    required this.swingAmp,
    required this.swingFreq,
    required this.initialPhase,
    required this.color,
    required this.rotationSpeed,
  });
}

/// Custom painter rendering organic cascading flower petals
class _FallingPetalsPainter extends CustomPainter {
  final double progress;
  final List<_PetalParticle> petals;

  _FallingPetalsPainter({
    required this.progress,
    required this.petals,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in petals) {
      // Calculate vertical fall with slight stagger
      final yTravel = (progress * p.speed * 1.3) % 1.25;
      final y = (yTravel * (size.height + 60)) - 30;

      // Horizontal sway
      final xOffset = math.sin((progress * p.swingFreq * math.pi * 2) + p.initialPhase) * p.swingAmp;
      final x = (p.x * size.width) + xOffset;

      // Opacity fade at the beginning and end
      double opacity = 1.0;
      if (progress < 0.1) {
        opacity = progress / 0.1;
      } else if (progress > 0.8) {
        opacity = (1.0 - progress) / 0.2;
      }
      opacity = opacity.clamp(0.0, 1.0);

      paint.color = p.color.withValues(alpha: (0.85 * opacity).clamp(0.0, 1.0));

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate((progress * p.rotationSpeed * math.pi) + p.initialPhase);

      // Draw organic curved petal
      final petalPath = Path();
      final halfW = p.size * 0.45;
      final halfH = p.size * 0.75;

      petalPath.moveTo(0, -halfH);
      petalPath.cubicTo(halfW * 1.2, -halfH * 0.5, halfW, halfH * 0.7, 0, halfH);
      petalPath.cubicTo(-halfW, halfH * 0.7, -halfW * 1.2, -halfH * 0.5, 0, -halfH);
      petalPath.close();

      canvas.drawPath(petalPath, paint);

      // Subtle center vein line
      final veinPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = Colors.white.withValues(alpha: (0.35 * opacity).clamp(0.0, 1.0));
      canvas.drawLine(Offset(0, -halfH * 0.7), Offset(0, halfH * 0.5), veinPaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FallingPetalsPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
