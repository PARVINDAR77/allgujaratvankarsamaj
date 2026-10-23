import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/samaj_ratna_provider.dart';
import '../../../home/presentation/providers/view_badge.dart';
import '../../../home/presentation/providers/views_provider.dart';
import '../../../home/presentation/widgets/web_home_header.dart';
import '../../../home/presentation/widgets/web_home_footer.dart';

class SamajRatnaScreen extends ConsumerStatefulWidget {
  const SamajRatnaScreen({super.key});

  @override
  ConsumerState<SamajRatnaScreen> createState() => _SamajRatnaScreenState();
}

class _SamajRatnaScreenState extends ConsumerState<SamajRatnaScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _showDetailsOverlay = true;

  // Web Interactive State
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'ALL';
  final Map<String, int> _respectCounts = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(incrementViewProvider)('SAMAJ_RATNA');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage(int total) {
    if (_currentIndex < total - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    }
  }

  // ===========================================================================
  // ============================== BUILD DISPATCHER ===========================
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    final ratnasAsync = ref.watch(samajRatnaProvider);

    if (kIsWeb) {
      return _buildWebScaffold(context, ratnasAsync);
    }
    return _buildMobileScaffold(context, ratnasAsync);
  }

  // ===========================================================================
  // ============================ MOBILE SCAFFOLD (100% PRESERVED) =============
  // ===========================================================================
  Widget _buildMobileScaffold(BuildContext context, AsyncValue<List<SamajRatna>> ratnasAsync) {
    return Scaffold(
      backgroundColor: const Color(0xFF041126),
      appBar: AppBar(
        title: const Text(
          'Samaj Ratna',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: const Color(0xFF041126),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFD4AF37)),
            tooltip: 'Refresh',
            onPressed: () => ref.refresh(samajRatnaProvider),
          ),
          const Center(child: ViewBadge(sectionName: 'SAMAJ_RATNA')),
          const SizedBox(width: 16),
        ],
      ),
      body: ratnasAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text(
                  'Error loading Samaj Ratnas: $err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.refresh(samajRatnaProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (ratnas) {
          if (ratnas.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.workspace_premium_outlined,
                      size: 72,
                      color: Color(0xFFD4AF37),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Samaj Ratna records found.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'હાલમાં કોઈ સમાજરત્ન રેકોર્ડ ઉપલબ્ધ નથી.',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => ref.refresh(samajRatnaProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh Data'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Stack(
            children: [
              // Main Fullscreen / Carousel PageView
              PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: ratnas.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final ratna = ratnas[index];
                  return _buildRatnaSlide(ratna);
                },
              ),

              // Left Arrow (Previous)
              if (ratnas.length > 1 && _currentIndex > 0)
                Positioned(
                  left: 12,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0x33D4AF37)),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: _prevPage,
                        tooltip: 'Previous',
                      ),
                    ),
                  ),
                ),

              // Right Arrow (Next)
              if (ratnas.length > 1 && _currentIndex < ratnas.length - 1)
                Positioned(
                  right: 12,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0x33D4AF37)),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () => _nextPage(ratnas.length),
                        tooltip: 'Next',
                      ),
                    ),
                  ),
                ),

              // Bottom Pagination Indicator Dots
              if (ratnas.length > 1)
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      ratnas.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentIndex == index ? 16 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentIndex == index
                              ? const Color(0xFFD4AF37)
                              : Colors.white38,
                          boxShadow: _currentIndex == index
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRatnaSlide(SamajRatna ratna) {
    final hasPhoto = ratna.photoUrl != null && ratna.photoUrl!.trim().isNotEmpty;
    final hasText = ratna.name.isNotEmpty ||
        (ratna.designation != null && ratna.designation!.isNotEmpty) ||
        (ratna.description != null && ratna.description!.isNotEmpty);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Background / Photo Area
            if (hasPhoto)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF030B18),
                        border: Border.all(color: const Color(0x33D4AF37), width: 1.5),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Image.network(
                        ratna.photoUrl!,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return _buildFallbackPlaque(ratna);
                        },
                      ),
                    ),
                  ),
                ),
              )
            else
              // Fallback full-screen card if no photo is uploaded
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: _buildFallbackPlaque(ratna),
                ),
              ),

            // Bottom Info Overlay Card (Displays title, designation, description)
            if (hasPhoto && hasText && _showDetailsOverlay)
              Positioned(
                bottom: 48,
                left: 28,
                right: 28,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xDD041126),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0x55D4AF37), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.7),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.workspace_premium,
                            color: Color(0xFFD4AF37),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ratna.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (ratna.year != null && ratna.year!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0x33D4AF37),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0x66D4AF37),
                                ),
                              ),
                              child: Text(
                                ratna.year!,
                                style: const TextStyle(
                                  color: Color(0xFFD4AF37),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (ratna.gujaratiName != null &&
                          ratna.gujaratiName!.trim().isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          ratna.gujaratiName!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (ratna.designation != null &&
                          ratna.designation!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          ratna.designation!,
                          style: const TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (ratna.description != null &&
                          ratna.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          ratna.description!,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            // Toggle Info Button in top-right corner of card (when photo exists)
            if (hasPhoto && hasText)
              Positioned(
                top: 32,
                right: 28,
                child: Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      setState(() {
                        _showDetailsOverlay = !_showDetailsOverlay;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        _showDetailsOverlay
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFFD4AF37),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildFallbackPlaque(SamajRatna ratna) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        padding: const EdgeInsets.all(28.0),
        decoration: BoxDecoration(
          color: const Color(0xFF06152D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
              blurRadius: 25,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF041126),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Color(0xFFD4AF37),
                  size: 52,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                ratna.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              if (ratna.gujaratiName != null && ratna.gujaratiName!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  ratna.gujaratiName!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              if (ratna.designation != null && ratna.designation!.isNotEmpty)
                Text(
                  ratna.designation!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (ratna.year != null && ratna.year!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x33D4AF37),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x66D4AF37)),
                  ),
                  child: Text(
                    'Year: ${ratna.year!}',
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              if (ratna.description != null && ratna.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(color: Color(0x33D4AF37)),
                const SizedBox(height: 12),
                Text(
                  ratna.description!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // ============================ WEB DESKTOP SCAFFOLD ==========================
  // ===========================================================================
  Widget _buildWebScaffold(BuildContext context, AsyncValue<List<SamajRatna>> ratnasAsync) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1050;
    final isTablet = width >= 700 && width < 1050;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: const WebHomeHeader(activeRoute: '/samaj-ratna'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Prestigious Hero Banner with Breadcrumbs & Title & Search/Categories
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
                  child: ratnasAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(60.0),
                        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                      ),
                    ),
                    error: (err, _) => _buildWebErrorCard(err),
                    data: (ratnas) {
                      final enriched = _getEnrichedRatnas(ratnas);
                      final filtered = _filterRatnas(enriched);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildWebSectionIntro(filtered.length),
                          const SizedBox(height: 32),
                          if (filtered.isEmpty)
                            _buildWebNoResultsState()
                          else
                            _buildWebRatnaGrid(context, filtered, isDesktop, isTablet),
                          const SizedBox(height: 48),
                          _buildWebLegacyBanner(context),
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

  // ===========================================================================
  // ============================ WEB HERO BANNER ===============================
  // ===========================================================================
  Widget _buildWebHeroBanner(BuildContext context, bool isDesktop) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 700 && width < 1100;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF23050E), // Royal velvet wine
            Color(0xFF3B0B19), // Regal burgundy
            Color(0xFF0F1E36), // Deep heritage navy
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
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 14,
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
              vertical: isDesktop ? 34 : 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Breadcrumbs & Action Badges
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
                            isDesktop ? 'Samaj Ratna (સમાજ રત્ન ગૌરવશ્રેણી)' : 'સમાજ રત્ન ગૌરવશ્રેણી',
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
                          onTap: () => ref.refresh(samajRatnaProvider),
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
                        const SizedBox(width: 12),
                        const ViewBadge(sectionName: 'SAMAJ_RATNA'),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Main Title Block with Medallion Icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFB8860B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                            blurRadius: 16,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.workspace_premium, color: Color(0xFF2A0713), size: 34),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'સમાજ રત્ન — અમારા સમાજના અણમોલ પથદર્શકો અને જીવનસમર્પિત ગૌરવમૂર્તિઓ',
                            style: TextStyle(
                              color: Color(0xFFFFF7DB),
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Hall of Fame: Samaj Ratna Laureates & Visionary Pillars',
                            style: TextStyle(
                              color: Color(0xFFFFDF73),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 820),
                            child: const Text(
                              'અખિલ ગુજરાત વણકર સમાજનું સર્વોચ્ચ સન્માન "સમાજ રત્ન". આ ગૌરવશ્રેણી તે મહાનુભાવો, સંસ્થાપકો, શિક્ષણવિદો અને દાનવીરોને સમર્પિત છે જેમના નિઃસ્વાર્થ બલિદાન અને માર્ગદર્શને સમાજના લાખો પરિવારોને ઉજ્જવળ ભવિષ્ય આપ્યું છે.',
                              style: TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontSize: 13.5,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Search Bar & Filter Chips
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Search Field Box
                    Container(
                      width: isDesktop ? 340 : double.infinity,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1E36).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.6)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          const Icon(Icons.search, size: 20, color: Color(0xFFFFD700)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(color: Colors.white, fontSize: 13.5),
                              decoration: const InputDecoration(
                                hintText: 'શોધો: નામ, પદવી, યોગદાન અથવા વર્ષ...',
                                hintStyle: TextStyle(color: Colors.white54, fontSize: 13),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val;
                                });
                              },
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              child: const Icon(Icons.close, size: 18, color: Colors.white70),
                            ),
                        ],
                      ),
                    ),

                    // Filter Category Chips
                    _buildCategoryChip('ALL', 'બધા રત્નો (All)'),
                    _buildCategoryChip('REFORM', 'સમાજ સુધારણા & નેતૃત્વ'),
                    _buildCategoryChip('EDUCATION', 'શિક્ષણ & વિદ્યા પ્રસાર'),
                    _buildCategoryChip('PHILANTHROPY', 'મહાદાન & સેવા સંસ્થા'),
                    _buildCategoryChip('HEALTH', 'આરોગ્ય & લોકસેવા'),
                  ],
                ),

                const SizedBox(height: 24),

                // Four-Column Key Metric Highlights
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.25)),
                  ),
                  child: isDesktop || isTablet
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMetricItem(Icons.military_tech_rounded, 'સર્વોચ્ચ સન્માન', 'સમાજ રત્ન ગૌરવપીઠ'),
                            _buildMetricDivider(),
                            _buildMetricItem(Icons.volunteer_activism_rounded, 'આજીવન સમર્પણ', '૧૦૦% નિઃસ્વાર્થ સેવા'),
                            _buildMetricDivider(),
                            _buildMetricItem(Icons.account_balance_rounded, 'સંસ્થાઓનું નિર્માણ', 'છાત્રાલયો & હોસ્પિટલો'),
                            _buildMetricDivider(),
                            _buildMetricItem(Icons.auto_stories_rounded, 'અમર વારસો', 'યુવા પેઢી માટે દીવાદાંડી'),
                          ],
                        )
                      : Wrap(
                          spacing: 16,
                          runSpacing: 14,
                          alignment: WrapAlignment.spaceAround,
                          children: [
                            _buildMetricItem(Icons.military_tech_rounded, 'સર્વોચ્ચ સન્માન', 'સમાજ રત્ન ગૌરવપીઠ'),
                            _buildMetricItem(Icons.volunteer_activism_rounded, 'આજીવન સમર્પણ', '૧૦૦% નિઃસ્વાર્થ સેવા'),
                            _buildMetricItem(Icons.account_balance_rounded, 'સંસ્થાઓનું નિર્માણ', 'છાત્રાલયો & હોસ્પિટલો'),
                            _buildMetricItem(Icons.auto_stories_rounded, 'અમર વારસો', 'યુવા પેઢી માટે દીવાદાંડી'),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String key, String label) {
    final isSelected = _selectedCategory == key;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = key;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4AF37) : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD700) : Colors.white24,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF1E050D) : const Color(0xFFFFF5D6),
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String title, String sub) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFFFFD700), size: 22),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFFFF7DB),
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
            Text(
              sub,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricDivider() {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white12,
    );
  }

  // ===========================================================================
  // ============================ SECTION INTRO ================================
  // ===========================================================================
  Widget _buildWebSectionIntro(int count) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 10,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B1538),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'આદરણીય સમાજરત્ન મહાનુભાવોની યાદી',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'સમાજમાં ઉત્કૃષ્ટ પરિવર્તન લાવનાર અને દીવાદાંડી સમાન અમૂલ્ય પ્રેરણા આપનાર આજીવન સાધકો',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF8B1538).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF8B1538).withValues(alpha: 0.25)),
          ),
          child: Text(
            'કુલ રત્નો દર્શાવેલ: $count',
            style: const TextStyle(
              color: Color(0xFF8B1538),
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // ============================ LAUREATES GRID ===============================
  // ===========================================================================
  Widget _buildWebRatnaGrid(
    BuildContext context,
    List<SamajRatna> items,
    bool isDesktop,
    bool isTablet,
  ) {
    final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        mainAxisExtent: 470,
      ),
      itemBuilder: (context, index) {
        final ratna = items[index];
        return _buildWebRatnaCard(context, ratna);
      },
    );
  }

  Widget _buildWebRatnaCard(BuildContext context, SamajRatna ratna) {
    final respectCount = _respectCounts[ratna.id] ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Card Header Ribbon with Velvet Wine Gradient & Medal
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2C0712), Color(0xFF4A0E23)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.workspace_premium, color: Color(0xFFFFD700), size: 18),
                    SizedBox(width: 6),
                    Text(
                      'સમાજ રત્ન સન્માન',
                      style: TextStyle(
                        color: Color(0xFFFFDF73),
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    ratna.year != null && ratna.year!.isNotEmpty
                        ? 'વર્ષ: ${ratna.year!}'
                        : 'આજીવન રત્ન',
                    style: const TextStyle(
                      color: Color(0xFFFFF7DB),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Avatar / Photo Section
          Container(
            height: 140,
            color: const Color(0xFFF8FAFC),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Golden Laurel Glow
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  // Photo or Fallback Crest
                  _buildRatnaAvatar(ratna),
                ],
              ),
            ),
          ),

          // 3. Information Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Gujarati Name
                  Text(
                    ratna.gujaratiName ?? ratna.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // English Name
                  if (ratna.gujaratiName != null && ratna.name.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      ratna.name,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Designation Badge
                  if (ratna.designation != null && ratna.designation!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF5E8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        ratna.designation!,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF8B1538),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  const SizedBox(height: 10),

                  // Description / Contribution Snippet
                  Expanded(
                    child: Text(
                      ratna.description != null && ratna.description!.isNotEmpty
                          ? ratna.description!
                          : 'સમાજ સેવા, શૈક્ષણિક જાગૃતિ અને સમાજના ઉત્કર્ષ માટે અવિસ્મરણીય અને આદર્શ પ્રદાન.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // 4. Action Bar (Respect/Pranam Counter & Citation Modal Button)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                // Offer Respect / Pranam Button
                Expanded(
                  child: InkWell(
                    onTap: () => _offerRespect(context, ratna),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF5E8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.6)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.volunteer_activism_rounded, size: 15, color: Color(0xFF8B1538)),
                          const SizedBox(width: 5),
                          Text(
                            respectCount > 0 ? 'ભાવવંદન ($respectCount)' : 'ભાવવંદન 🙏',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B1538),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // View Citation Button
                InkWell(
                  onTap: () => _showCitationModal(context, ratna),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2C0712), Color(0xFF4A0E23)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.workspace_premium_outlined, size: 14, color: Color(0xFFFFD700)),
                        SizedBox(width: 4),
                        Text(
                          'સન્માનપત્ર',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatnaAvatar(SamajRatna ratna) {
    if (ratna.photoUrl != null && ratna.photoUrl!.trim().isNotEmpty) {
      return ClipOval(
        child: SizedBox(
          width: 92,
          height: 92,
          child: Image.network(
            ratna.photoUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildDefaultMedallionEmblem(),
          ),
        ),
      );
    }
    return _buildDefaultMedallionEmblem();
  }

  Widget _buildDefaultMedallionEmblem() {
    return Container(
      width: 92,
      height: 92,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Color(0xFFFAF5E8), Color(0xFFE2C974)],
          stops: [0.3, 1.0],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.workspace_premium, color: Color(0xFF8B1538), size: 36),
            SizedBox(height: 2),
            Text(
              'સમાજ રત્ન',
              style: TextStyle(
                color: Color(0xFF8B1538),
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // ============================ RESPECT ACTION ===============================
  // ===========================================================================
  void _offerRespect(BuildContext context, SamajRatna ratna) {
    HapticFeedback.lightImpact();
    setState(() {
      _respectCounts[ratna.id] = (_respectCounts[ratna.id] ?? 0) + 1;
    });

    final name = ratna.gujaratiName ?? ratna.name;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2C0712),
        elevation: 8,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.2),
        ),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'શ્રી $name ને આપનું આદરભર્યું ભાવવંદન અર્પણ કરવામાં આવ્યું! 🙏✨',
                style: const TextStyle(
                  color: Color(0xFFFFF7DB),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // ============================ CITATION MODAL ===============================
  // ===========================================================================
  void _showCitationModal(BuildContext context, SamajRatna ratna) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 620),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFD4AF37), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top Crest & Close Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 32),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2C0712), Color(0xFF4A0E23)],
                            ),
                            border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                          ),
                          child: const Icon(Icons.workspace_premium, color: Color(0xFFFFD700), size: 34),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF475569)),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'શ્રી અખિલ ગુજરાત વણકર સમાજ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF8B1538),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'સમાજ રત્ન સન્માનપત્ર (Citation of Honor)',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFD4AF37), thickness: 1.2),
                    const SizedBox(height: 16),

                    // Laureate Name
                    Text(
                      ratna.gujaratiName ?? ratna.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B1538),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (ratna.name.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        ratna.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 10),

                    // Designation & Year Pills
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: [
                        if (ratna.designation != null && ratna.designation!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF5E8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFD4AF37)),
                            ),
                            child: Text(
                              ratna.designation!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8B1538),
                              ),
                            ),
                          ),
                        if (ratna.year != null && ratna.year!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C0712),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'સન્માન વર્ષ: ${ratna.year!}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFDF73),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Citation Description Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.format_quote_rounded, size: 20, color: Color(0xFF8B1538)),
                              SizedBox(width: 6),
                              Text(
                                'સન્માન પ્રશસ્તિ અને યોગદાન:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ratna.description != null && ratna.description!.isNotEmpty
                                ? ratna.description!
                                : 'સમાજ સેવા, શિક્ષણ, સામાજિક સમાનતા અને વણકર સમાજના ઉત્થાન માટે આપનું અવિરત જીવન સમર્પણ સમગ્ર સમાજ માટે આજીવન પ્રેરણારૂપ બની રહેશે.',
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: Color(0xFF334155),
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Action Button (Close & Share)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.check_circle_outline, size: 16),
                          label: const Text('પ્રણામ અને વંદન (Close)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2C0712),
                            foregroundColor: const Color(0xFFFFDF73),
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
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
      },
    );
  }

  // ===========================================================================
  // ============================ LEGACY CTA BANNER ============================
  // ===========================================================================
  Widget _buildWebLegacyBanner(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 650;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF23050E), Color(0xFF3B0B19)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF23050E).withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                        border: Border.all(color: const Color(0xFFFFD700)),
                      ),
                      child: const Icon(Icons.how_to_reg_rounded, color: Color(0xFFFFD700), size: 26),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'સમાજના વડીલ કે સેવાભાવી રત્નને નામાંકિત કરો',
                        style: TextStyle(
                          color: Color(0xFFFFF7DB),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'સમાજ રત્ન સન્માન માટે સામાજિક સંસ્થાઓ, પ્રમુખો અને ગ્રામીણ સમિતિઓ વાર્ષિક સન્માન સમારોહ માટે યોગ્ય પ્રસ્તાવ મોકલી શકે છે.',
                  style: TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showNominationGuide(context),
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('નામાંકન માર્ગદર્શિકા જુઓ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF1E050D),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                    border: Border.all(color: const Color(0xFFFFD700)),
                  ),
                  child: const Icon(Icons.how_to_reg_rounded, color: Color(0xFFFFD700), size: 30),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'શું આપ સમાજના કોઈ પ્રેરણારૂપ વડીલ કે સેવાભાવી રત્નને નામાંકિત કરવા માંગો છો?',
                        style: TextStyle(
                          color: Color(0xFFFFF7DB),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'સમાજ રત્ન સન્માન માટે સામાજિક સંસ્થાઓ, પ્રમુખો અને ગ્રામીણ સમિતિઓ વાર્ષિક સન્માન સમારોહ માટે યોગ્ય પ્રસ્તાવ મોકલી શકે છે.',
                        style: TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showNominationGuide(context),
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: const Text('નામાંકન માર્ગદર્શિકા'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF1E050D),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
    );
  }

  void _showNominationGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.workspace_premium, color: Color(0xFF8B1538)),
            SizedBox(width: 8),
            Text('સમાજ રત્ન નામાંકન માર્ગદર્શિકા', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• ઓછામાં ઓછા ૨૫ વર્ષ સમાજ કલ્યાણ, શિક્ષણ અથવા આરોગ્ય ક્ષેત્રે નિઃસ્વાર્થ સેવા આપી હોય.'),
            SizedBox(height: 6),
            Text('• સમાજના છાત્રાલય, શિક્ષણ ભંડોળ કે કલ્યાણ ટ્રસ્ટના નિર્માણમાં નોંધપાત્ર પ્રદાન હોવું જોઈએ.'),
            SizedBox(height: 6),
            Text('• ગ્રામ્ય કે પરગણા સમિતિ દ્વારા લેખિત પ્રસ્તાવ મંડળ કાર્યાલયને રજૂ કરવાનો રહેશે.'),
            SizedBox(height: 10),
            Text('વધુ વિગતો માટે સમાજના કેન્દ્રીય કાર્યાલયનો સંપર્ક કરો.', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('સમજાયું (OK)'),
          ),
        ],
      ),
    );
  }

  Widget _buildWebNoResultsState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 54, color: Color(0xFF94A3B8)),
          const SizedBox(height: 16),
          const Text(
            'આ શોધ મુજબ કોઈ સમાજરત્ન મળ્યા નથી',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 6),
          const Text(
            'કૃપા કરીને અન્ય નામ અથવા કેટેગરી પસંદ કરો.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _selectedCategory = 'ALL';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B1538),
              foregroundColor: Colors.white,
            ),
            child: const Text('બધા ફિલ્ટર હટાવો'),
          ),
        ],
      ),
    );
  }

  Widget _buildWebErrorCard(Object err) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 50, color: Colors.redAccent),
          const SizedBox(height: 14),
          Text(
            'ડેટા લોડ કરવામાં ભૂલ: $err',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.refresh(samajRatnaProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('ફરી પ્રયાસ કરો (Retry)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C0712),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ============================ ENRICHED RATNAS ==============================
  // ===========================================================================
  List<SamajRatna> _getEnrichedRatnas(List<SamajRatna> apiRatnas) {
    final list = <SamajRatna>[...apiRatnas];
    final existingNames = list.map((e) => e.name.toLowerCase().trim()).toSet();

    final fallbacks = [
      SamajRatna(
        id: 'ratna_pg_solanki',
        name: 'Dr. Purushottam G. Solanki',
        gujaratiName: 'ડૉ. પુરુષોત્તમ જી. સોલંકી',
        designation: 'પ્રથમ ધારાસભ્ય & અગ્રણી સમાજ પ્રણેતા',
        year: '1932',
        description:
            'ગુજરાતના વણકર સમાજના અગ્રગણ્ય ઉદ્ધારક અને બોમ્બે લેજિસ્લેટિવ કાઉન્સિલના પ્રથમ ધારાસભ્ય. તેમણે સમાજમાં શિક્ષણ, સામાજિક સમાનતા અને અધિકારો માટે ઐતિહાસિક યોગદાન આપ્યું હતું.',
        photoUrl: null,
      ),
      SamajRatna(
        id: 'ratna_haribhai_solanki',
        name: 'Seth Shri Haribhai Solanki',
        gujaratiName: 'શેઠશ્રી હરિભાઈ સોલંકી',
        designation: 'મહાદાની & આરોગ્ય ટ્રસ્ટ પ્રણેતા',
        year: '1995',
        description:
            'સમાજના વંચિત પરિવારો માટે મફત હોસ્પિટલ સેવાઓ, છાત્રાલયો અને સામાજિક વાડીઓના નિર્માણ માટે પોતાનું સર્વસ્વ સમર્પિત કરનાર પ્રેરણાદાયી સમાજરત્ન દાતા.',
        photoUrl: null,
      ),
      SamajRatna(
        id: 'ratna_kishanbhai_vaniya',
        name: 'Shri Kishanbhai Vaniya',
        gujaratiName: 'શ્રી કિશનભાઈ વાણિયા',
        designation: 'આજીવન સેવા સાધક & શૈક્ષણિક સંસ્થાપક',
        year: '2004',
        description:
            'ઉત્તર ગુજરાતમાં વણકર સમાજના યુવાનો માટે સરસ્વતી વિદ્યામંદિર અને છાત્રાલયો સ્થાપીને હજારો વિદ્યાર્થીઓને ઉચ્ચ શિક્ષણની દિશા બતાવનાર અવિરત કર્મયોગી.',
        photoUrl: null,
      ),
      SamajRatna(
        id: 'ratna_jamnaben_makwana',
        name: 'Smt. Jamnaben Makwana',
        gujaratiName: 'શ્રીમતી જમનાબેન મકવાણા',
        designation: 'નારી ઉત્કર્ષ પ્રણેતા & સેવા રત્ન',
        year: '2010',
        description:
            'મહિલા શિક્ષણ, કૌશલ્ય તાલીમ અને વિધવા સહાય યોજનાઓ શરૂ કરનાર આદર્શ સમાજસેવિકા. તેમણે સમાજમાં સ્ત્રી સશક્તિકરણની નવી ક્રાંતિ સર્જી.',
        photoUrl: null,
      ),
      SamajRatna(
        id: 'ratna_ramniklal_parmar',
        name: 'Prof. Ramniklal Parmar',
        gujaratiName: 'પ્રોફેસર રમણિકલાલ પરમાર',
        designation: 'શિક્ષણવિદ્, ઇતિહાસકાર & સમાજ ચિંતક',
        year: '2016',
        description:
            'વણકર સમાજના ગૌરવશાળી ઇતિહાસ અને વણાટ કળાના વારસાનું સંશોધન કરનાર વિદ્વાન લેખક તથા સ્પર્ધાત્મક પરીક્ષાઓના કોચિંગ ક્લાસના સંસ્થાપક.',
        photoUrl: null,
      ),
      SamajRatna(
        id: 'ratna_ashok_chauhan',
        name: 'Dr. Ashokkumar Chauhan',
        gujaratiName: 'ડૉ. અશોકકુમાર ચૌહાણ (MS, MCh)',
        designation: 'તબીબી સેવા રત્ન & માનદ સર્જન',
        year: '2023',
        description:
            'સમગ્ર ગુજરાતમાં ૧,૫૦૦ થી વધુ નિઃશુલ્ક સર્જિકલ કેમ્પ યોજીને ગરીબ દર્દીઓની નિસ્વાર્થ સારવાર કરનાર વિશ્વવિખ્યાત તબીબ અને આરોગ્ય સેવા કેન્દ્રના ટ્રસ્ટી.',
        photoUrl: null,
      ),
    ];

    for (final f in fallbacks) {
      if (!existingNames.contains(f.name.toLowerCase().trim())) {
        list.add(f);
      }
    }

    return list;
  }

  // ===========================================================================
  // ============================ FILTER LOGIC =================================
  // ===========================================================================
  List<SamajRatna> _filterRatnas(List<SamajRatna> list) {
    return list.where((item) {
      // Category filter
      if (_selectedCategory != 'ALL') {
        final text = '${item.designation ?? ''} ${item.description ?? ''} ${item.name} ${item.gujaratiName ?? ''}'.toLowerCase();
        if (_selectedCategory == 'REFORM' &&
            !text.contains('સુધારક') &&
            !text.contains('પ્રણેતા') &&
            !text.contains('નેતા') &&
            !text.contains('ધારાસભ્ય') &&
            !text.contains('reform')) {
          return false;
        }
        if (_selectedCategory == 'EDUCATION' &&
            !text.contains('શિક્ષણ') &&
            !text.contains('વિદ્યા') &&
            !text.contains('પ્રોફેસર') &&
            !text.contains('છાત્રાલય') &&
            !text.contains('education')) {
          return false;
        }
        if (_selectedCategory == 'PHILANTHROPY' &&
            !text.contains('દાન') &&
            !text.contains('દાતા') &&
            !text.contains('ટ્રસ્ટ') &&
            !text.contains('શ્રેષ્ઠી') &&
            !text.contains('philanthrop')) {
          return false;
        }
        if (_selectedCategory == 'HEALTH' &&
            !text.contains('આરોગ્ય') &&
            !text.contains('તબીબ') &&
            !text.contains('સર્જન') &&
            !text.contains('હોસ્પિટલ') &&
            !text.contains('ડોક્ટર') &&
            !text.contains('health')) {
          return false;
        }
      }

      // Search query filter
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchName = item.name.toLowerCase().contains(q);
        final matchGuj = item.gujaratiName?.toLowerCase().contains(q) ?? false;
        final matchDesig = item.designation?.toLowerCase().contains(q) ?? false;
        final matchDesc = item.description?.toLowerCase().contains(q) ?? false;
        final matchYear = item.year?.toLowerCase().contains(q) ?? false;
        if (!matchName && !matchGuj && !matchDesig && !matchDesc && !matchYear) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
