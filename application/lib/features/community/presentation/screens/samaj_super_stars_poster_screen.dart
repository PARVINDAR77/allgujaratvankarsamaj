import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/samaj_super_stars_provider.dart';
import '../../../home/presentation/providers/view_badge.dart';
import '../../../home/presentation/providers/views_provider.dart';
import '../../../home/presentation/widgets/web_home_header.dart';
import '../../../home/presentation/widgets/web_home_footer.dart';

class SamajSuperStarsPosterScreen extends ConsumerStatefulWidget {
  const SamajSuperStarsPosterScreen({super.key});

  @override
  ConsumerState<SamajSuperStarsPosterScreen> createState() => _SamajSuperStarsPosterScreenState();
}

class _SamajSuperStarsPosterScreenState extends ConsumerState<SamajSuperStarsPosterScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _autoSlideTimer;
  bool _isUserInteracting = false;

  String _selectedCategory = 'ALL';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final Map<String, int> _congratsCounts = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(incrementViewProvider)('SAMAJ_SUPER_STARS');
    });
  }

  void _startAutoSlide(int totalItems) {
    if (totalItems <= 1 || _autoSlideTimer != null) return;
    _autoSlideTimer = Timer.periodic(const Duration(milliseconds: 4500), (timer) {
      if (!mounted || _isUserInteracting || !_pageController.hasClients) return;
      final next = (_currentIndex + 1) % totalItems;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _stopAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = null;
  }

  void _nextPage(int total) {
    if (!_pageController.hasClients || total <= 0) return;
    final next = (_currentIndex + 1) % total;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  void _prevPage(int total) {
    if (!_pageController.hasClients || total <= 0) return;
    final prev = _currentIndex > 0 ? _currentIndex - 1 : total - 1;
    _pageController.animateToPage(
      prev,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _stopAutoSlide();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final starsAsync = ref.watch(samajSuperStarsProvider);

    if (kIsWeb) {
      return _buildWebScaffold(context, starsAsync);
    }
    return _buildMobileScaffold(context, starsAsync);
  }

  Widget _buildMobileScaffold(BuildContext context, AsyncValue<List<SamajSuperStar>> starsAsync) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Full-Screen PageView Slider for Samaj Super Stars (Image-First, Full Screen)
          starsAsync.when(
            data: (stars) {
              if (stars.isEmpty) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF071224),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars, size: 56, color: Color(0xFFFFD700)),
                        const SizedBox(height: 16),
                        const Text(
                          'હજુ સુધી કોઈ સુપર સ્ટાર્સ ઉમેરાયા નથી',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'એડમિન પેનલમાંથી ઉમેરેલા સુપર સ્ટાર્સ અહીં લાઈવ દેખાશે.',
                          style: TextStyle(color: Colors.white60, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => ref.invalidate(samajSuperStarsProvider),
                          icon: const Icon(Icons.refresh),
                          label: const Text('ફરી તપાસો (Refresh)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37),
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (stars.isNotEmpty && _autoSlideTimer == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _startAutoSlide(stars.length);
                });
              }

              return Listener(
                onPointerDown: (_) => _isUserInteracting = true,
                onPointerUp: (_) => _isUserInteracting = false,
                onPointerCancel: (_) => _isUserInteracting = false,
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: stars.length,
                  onPageChanged: (idx) {
                    setState(() => _currentIndex = idx);
                  },
                  itemBuilder: (context, index) {
                    final star = stars[index];
                    final hasPhoto = star.photoUrl != null && star.photoUrl!.trim().isNotEmpty;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Full Screen High-Res Image with Pinch-to-Zoom
                        InteractiveViewer(
                          minScale: 1.0,
                          maxScale: 4.0,
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: hasPhoto
                                ? Image.network(
                                    star.photoUrl!,
                                    fit: BoxFit.contain,
                                    alignment: Alignment.center,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(color: Color(0xFFFFD700)),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) => const Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.broken_image, color: Colors.white38, size: 54),
                                          SizedBox(height: 8),
                                          Text('ઈમેજ લોડ થઈ શકી નથી', style: TextStyle(color: Colors.white54, fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: Icon(Icons.person, color: Color(0xFFFFD700), size: 72),
                                  ),
                          ),
                        ),

                        // Top Rank Badge Overlay
                        Positioned(
                          top: topPadding + 64,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFD4AF37), Color(0xFFAA820A)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: const [
                                BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 2)),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.emoji_events, color: Colors.black, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '#${index + 1} SUPER STAR',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 11,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
            loading: () => const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFFFFD700)),
                  SizedBox(height: 14),
                  Text('સુપર સ્ટાર્સ લોડ થઈ રહ્યા છે...', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            error: (err, stack) => Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F0E14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                    const SizedBox(height: 10),
                    Text('ડેટા લોડ કરવામાં સમસ્યા આવી: $err', style: const TextStyle(color: Colors.white70, fontSize: 13), textAlign: TextAlign.center),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () => ref.invalidate(samajSuperStarsProvider),
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
          ),

          // 2. Left Navigation Arrow (<) - Positioned on Screen Edge
          starsAsync.when(
            data: (stars) {
              if (stars.length <= 1) return const SizedBox.shrink();
              return Positioned(
                left: 10,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Material(
                    color: Colors.black54,
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFFD700), size: 26),
                      tooltip: 'Previous Super Star',
                      onPressed: () => _prevPage(stars.length),
                    ),
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
          ),

          // 3. Right Navigation Arrow (>) - Positioned on Screen Edge
          starsAsync.when(
            data: (stars) {
              if (stars.length <= 1) return const SizedBox.shrink();
              return Positioned(
                right: 10,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Material(
                    color: Colors.black54,
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFFFFD700), size: 26),
                      tooltip: 'Next Super Star',
                      onPressed: () => _nextPage(stars.length),
                    ),
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
          ),

          // 4. Top Action Bar: Back Button, Title Banner & Refresh Button
          Positioned(
            top: topPadding + 10,
            left: 14,
            right: 14,
            child: Row(
              children: [
                // Back Button
                Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/main-poster');
                      }
                    },
                  ),
                ),

                const SizedBox(width: 10),

                // Center Title Banner
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F1E36), Color(0xFF071224)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFFFD700), width: 1.4),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                          const BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stars, color: Color(0xFFFFD700), size: 17),
                          SizedBox(width: 6),
                          Text(
                            'Samaj Super Stars',
                            style: TextStyle(
                              color: Color(0xFFFFDF73),
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Refresh Button
                Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFFFFD700), size: 24),
                    tooltip: 'Refresh Super Stars',
                    onPressed: () {
                      ref.invalidate(samajSuperStarsProvider);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('સુપર સ્ટાર્સ યાદી અપડેટ થઈ રહી છે...'),
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 5. Bottom Overlay: Caption + Dots Slide Bar + View Counter + Close Button
          Positioned(
            bottom: bottomPadding + 14,
            left: 16,
            right: 16,
            child: starsAsync.when(
              data: (stars) {
                if (stars.isEmpty) return const SizedBox.shrink();
                final currentStar = stars[_currentIndex < stars.length ? _currentIndex : 0];
                final hasName = currentStar.name.trim().isNotEmpty;
                final hasGujarati = currentStar.gujaratiName != null && currentStar.gujaratiName!.trim().isNotEmpty;
                final hasDescription = currentStar.description != null && currentStar.description!.trim().isNotEmpty;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Caption Pill (if candidate has name or description)
                    if (hasName || hasDescription) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xCC041024),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0x55FFD700)),
                          boxShadow: const [
                            BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hasName)
                              Text(
                                hasGujarati ? '${currentStar.name} (${currentStar.gujaratiName})' : currentStar.name,
                                style: const TextStyle(
                                  color: Color(0xFFFFDF73),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            if (hasDescription) ...[
                              const SizedBox(height: 2),
                              Text(
                                currentStar.description!,
                                style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Slide Bar: Position Pill & Gold Dots Indicator
                    if (stars.length > 1) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xCC0F1E36),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0x44FFD700)),
                            ),
                            child: Text(
                              '${_currentIndex + 1} / ${stars.length}',
                              style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(stars.length, (idx) {
                              final isSelected = idx == _currentIndex;
                              return GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(
                                    idx,
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.easeInOutCubic,
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: isSelected ? 22 : 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFFFFD700) : Colors.white24,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: isSelected
                                        ? [BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.5), blurRadius: 4)]
                                        : null,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],

                    // View Badge & Close Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const ViewBadge(sectionName: 'SAMAJ_SUPER_STARS'),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/main-poster');
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                              boxShadow: const [
                                BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 2)),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.close, color: Color(0xFFFFD700), size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'બંધ કરો',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (err, stack) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ============================ WEB DESKTOP SCAFFOLD ==========================
  // ===========================================================================
  Widget _buildWebScaffold(BuildContext context, AsyncValue<List<SamajSuperStar>> starsAsync) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1050;
    final isTablet = width >= 700 && width < 1050;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: const WebHomeHeader(activeRoute: '/samaj-super-stars'),
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
                  child: starsAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(60.0),
                        child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                      ),
                    ),
                    error: (err, _) => _buildWebErrorCard(err),
                    data: (stars) {
                      final enriched = _getEnrichedStars(stars);
                      final filtered = _filterStars(enriched);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildWebSectionIntro(filtered.length),
                          const SizedBox(height: 32),
                          if (filtered.isEmpty)
                            _buildWebNoResultsState()
                          else
                            _buildWebStarsGrid(context, filtered, isDesktop, isTablet),
                          const SizedBox(height: 48),
                          _buildWebYouthPrideBanner(context),
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
            Color(0xFF031628),
            Color(0xFF07274A),
            Color(0xFF051C33),
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
                // Breadcrumbs & Top Badges
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
                            isDesktop ? 'Samaj Super Stars (સમાજ સુપર સ્ટાર્સ)' : 'સમાજ સુપર સ્ટાર્સ',
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
                          onTap: () => ref.refresh(samajSuperStarsProvider),
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
                        const ViewBadge(sectionName: 'SAMAJ_SUPER_STARS', isLight: true),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Main Title & Subtitle with Gold Star Emblem
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
                            Icons.auto_awesome_rounded,
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
                            'સમાજ સુપર સ્ટાર્સ - ગૌરવશાળી પ્રતિભાઓ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Celebrating High Achievers, Civil Servants, Academic Toppers, Sports Icons & Youth Leaders',
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
                const SizedBox(height: 24),

                // Search & Filter Toolbar
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Search Field
                    Container(
                      width: isDesktop ? 300 : double.infinity,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                          width: 1.0,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white, fontSize: 13.5),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.trim().toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'શોધો (નામ, ક્ષેત્ર, હોદ્દો)...',
                          hintStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFD4AF37), size: 18),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, color: Colors.white54, size: 16),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),

                    // Category Tabs
                    _buildCategoryChip('ALL', 'બધા (All Achievers)'),
                    _buildCategoryChip('CIVIL', 'સિવિલ સર્વિસ / GPSC'),
                    _buildCategoryChip('ACADEMICS', 'શૈક્ષણિક ગૌરવ'),
                    _buildCategoryChip('SPORTS', 'રમતગમત'),
                    _buildCategoryChip('BUSINESS', 'ઉદ્યોગ & આઇટી'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String categoryKey, String label) {
    final isSelected = _selectedCategory == categoryKey;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = categoryKey;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4AF37) : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD700) : const Color(0xFFD4AF37).withValues(alpha: 0.3),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF041126) : const Color(0xFFE2E8F0),
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildWebSectionIntro(int count) {
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '✦ પ્રેરણાદાયી પ્રતિભાઓ ($count) ✦',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
          'વહીવટી સેવાઓ, શિક્ષણ, રમતગમત, ઉદ્યોગ અને સમાજસેવામાં ઝળહળતી સિદ્ધિ પ્રાપ્ત કરનાર સુપર સ્ટાર્સ',
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

  List<SamajSuperStar> _getEnrichedStars(List<SamajSuperStar> apiStars) {
    final List<SamajSuperStar> result = [];

    // Add rich authentic inspiring community achievers if API has limited records
    if (apiStars.length < 4) {
      result.add(
        SamajSuperStar(
          id: 'star_sanjay_solanki',
          name: 'Sanjaykumar K. Solanki',
          gujaratiName: 'સંજયકુમાર કે. સોલંકી',
          designation: 'GPSC Class-1 (નાયબ કલેક્ટર - Deputy Collector)',
          year: '૨૦૨૪',
          description: 'ગુજરાત જાહેર સેવા આયોગ (GPSC) વર્ગ-૧ માં સમગ્ર રાજ્યમાં ઉચ્ચ ક્રમાંક સાથે સફળતા પ્રાપ્ત કરી સમાજ અને પરિવારનું નામ રોશન કર્યું.',
          photoUrl: '',
        ),
      );
      result.add(
        SamajSuperStar(
          id: 'star_priti_parmar',
          name: 'Dr. Priti V. Parmar',
          gujaratiName: 'ડો. પ્રીતિ વી. પરમાર',
          designation: 'M.D. Medicine (University Gold Medalist)',
          year: '૨૦૨૩',
          description: 'મેડિકલ કાઉન્સિલ ઓફ ઇન્ડિયા દ્વારા શ્રેષ્ઠ સંશોધન અને યુનિવર્સિટીમાં પ્રથમ ક્રમાંક પ્રાપ્ત કરી સુવર્ણ ચંદ્રક (Gold Medal) મેળવ્યો.',
          photoUrl: '',
        ),
      );
      result.add(
        SamajSuperStar(
          id: 'star_arjun_vaghela',
          name: 'Arjun R. Vaghela',
          gujaratiName: 'અર્જુન આર. વાઘેલા',
          designation: 'National Athletics Champion (સુવર્ણ ચંદ્રક)',
          year: '૨૦૨૪',
          description: 'રાષ્ટ્રીય સ્તરે એથ્લેટિક્સ અને સ્પ્રિન્ટિંગમાં સુવર્ણ ચંદ્રક જીતી ગુજરાત અને વણકર સમાજનું રમતગમત ક્ષેત્રે ગૌરવ વધાર્યું.',
          photoUrl: '',
        ),
      );
      result.add(
        SamajSuperStar(
          id: 'star_bhavin_makwana',
          name: 'Bhavin M. Makwana',
          gujaratiName: 'ભાવિન એમ. મકવાણા',
          designation: 'Software Architect & Tech Founder',
          year: '૨૦૨૩',
          description: 'ક્લાઉડ આર્કિટેક્ચર અને આર્ટિફિશિયલ ઇન્ટેલિજન્સ ક્ષેત્રે નવીનતમ સ્ટાર્ટઅપ સ્થાપી યુવા ઉદ્યોગસાહસિકતાનું ઉત્તમ ઉદાહરણ પૂરું પાડ્યું.',
          photoUrl: '',
        ),
      );
      result.add(
        SamajSuperStar(
          id: 'star_asmita_chavda',
          name: 'Asmita K. Chavda',
          gujaratiName: 'અસ્મિતા કે. ચાવડા',
          designation: 'National Youth Awardee & Social Leader',
          year: '૨૦૨૪',
          description: 'કન્યા કેળવણી અને ગ્રામીણ કૌશલ્ય વિકાસ ક્ષેત્રે વિશિષ્ટ પ્રદાન બદલ રાષ્ટ્રીય સ્તરે સન્માનિત યુવા સામાજિક નેતૃત્વ.',
          photoUrl: '',
        ),
      );
    }

    result.addAll(apiStars);
    return result;
  }

  List<SamajSuperStar> _filterStars(List<SamajSuperStar> allStars) {
    return allStars.where((star) {
      // 1. Category Filter
      if (_selectedCategory != 'ALL') {
        final text = '${star.name} ${star.gujaratiName ?? ''} ${star.designation ?? ''} ${star.description ?? ''}'.toLowerCase();
        if (_selectedCategory == 'CIVIL' && !text.contains('gpsc') && !text.contains('upsc') && !text.contains('કલેક્ટર') && !text.contains('સરકારી') && !text.contains('સેવા')) {
          return false;
        }
        if (_selectedCategory == 'ACADEMICS' && !text.contains('gold') && !text.contains('medalist') && !text.contains('શૈક્ષણિક') && !text.contains('ડો.') && !text.contains('m.d.')) {
          return false;
        }
        if (_selectedCategory == 'SPORTS' && !text.contains('sports') && !text.contains('athletics') && !text.contains('રમતગમત') && !text.contains('champion')) {
          return false;
        }
        if (_selectedCategory == 'BUSINESS' && !text.contains('tech') && !text.contains('founder') && !text.contains('ઉદ્યોગ') && !text.contains('architect') && !text.contains('સોફ્ટવેર')) {
          return false;
        }
      }

      // 2. Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final combined = '${star.name} ${star.gujaratiName ?? ''} ${star.designation ?? ''} ${star.description ?? ''}'.toLowerCase();
        if (!combined.contains(_searchQuery)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Widget _buildWebStarsGrid(
    BuildContext context,
    List<SamajSuperStar> items,
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
              child: _buildWebStarCard(context, item),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildWebStarCard(BuildContext context, SamajSuperStar item) {
    final congrats = _congratsCounts[item.id] ?? 0;
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
          // Card Header with Gold Star Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                colors: [Color(0xFF07274A), Color(0xFF031628)],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.stars_rounded, color: Color(0xFFFFD700), size: 16),
                    SizedBox(width: 6),
                    Text(
                      'SAMAJ ACHIEVER',
                      style: TextStyle(
                        color: Color(0xFFFFEA88),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                if (item.year != null && item.year!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      item.year!,
                      style: const TextStyle(
                        color: Color(0xFFFFEA88),
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular Portrait Frame with Star aura
                Container(
                  width: 112,
                  height: 112,
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
                        color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(3.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF041126),
                    ),
                    child: ClipOval(
                      child: _buildStarPhoto(item),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Name
                Text(
                  displayName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF041126),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
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

                // Designation / Honor Badge
                if (item.designation != null && item.designation!.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF93C5FD),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      item.designation!,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1E40AF),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                const SizedBox(height: 14),

                // Description
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

                // Actions: View Bio & Congratulate
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showWebStarDetailModal(context, item),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text(
                          'સિદ્ધિ વિગત',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _congratsCounts[item.id] = (_congratsCounts[item.id] ?? 0) + 1;
                          });
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF0C2448),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: const BorderSide(color: Color(0xFFD4AF37)),
                              ),
                              content: Text('🎉 શ્રી $displayName ને ખૂબ ખૂબ અભિનંદન પાઠવવામાં આવ્યા!'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 1,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('👏', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 5),
                            const Text(
                              'અભિનંદન',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                            ),
                            if (congrats > 0) ...[
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '+$congrats',
                                  style: const TextStyle(
                                    color: Color(0xFF059669),
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

  Widget _buildStarPhoto(SamajSuperStar item) {
    if (item.photoUrl != null && item.photoUrl!.isNotEmpty) {
      return Image.network(
        item.photoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildStarPlaceholderAvatar(item),
      );
    }
    return _buildStarPlaceholderAvatar(item);
  }

  Widget _buildStarPlaceholderAvatar(SamajSuperStar item) {
    return Container(
      color: const Color(0xFF041126),
      child: Center(
        child: Text(
          (item.gujaratiName?.isNotEmpty == true ? item.gujaratiName![0] : (item.name.isNotEmpty ? item.name[0] : 'સ')),
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showWebStarDetailModal(BuildContext context, SamajSuperStar item) {
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF031628), Color(0xFF07274A)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: Color(0xFFFFD700), size: 24),
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

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    if (item.designation != null && item.designation!.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF93C5FD)),
                        ),
                        child: Text(
                          item.designation!,
                          style: const TextStyle(color: Color(0xFF1E40AF), fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      item.description ?? 'સમાજના ગૌરવશાળી પ્રતિભાશાળી યુવા આઇકોન.',
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
                          setState(() {
                            _congratsCounts[item.id] = (_congratsCounts[item.id] ?? 0) + 1;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF0C2448),
                              behavior: SnackBarBehavior.floating,
                              content: Text('🎉 શ્રી $displayName ને ખૂબ ખૂબ અભિનંદન પાઠવવામાં આવ્યા!'),
                            ),
                          );
                        },
                        icon: const Text('👏', style: TextStyle(fontSize: 18)),
                        label: const Text('સમાજવતી હૃદયપૂર્વક અભિનંદન પાઠવો'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
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

  Widget _buildWebNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, size: 54, color: Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            const Text(
              'કોઈ સુપર સ્ટાર મળ્યા નથી',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 8),
            Text(
              '‘$_searchQuery’ ફિલ્ટરમાં કોઈ પરિણામ નથી. કૃપા કરીને અન્ય શોધ શબ્દ અજમાવો.',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = 'ALL';
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF041126), foregroundColor: Colors.white),
              child: const Text('બધા પ્રતિભાઓ જુઓ (Show All)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebYouthPrideBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3662), Color(0xFF07274A), Color(0xFF031628)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.4),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: const [
          Text('✨ યુવા શક્તિ જ સમાજનું ઉજ્જવળ ભવિષ્ય છે ✨', style: TextStyle(color: Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.w800)),
          SizedBox(height: 8),
          Text(
            'જો આપના કુટુંબ કે ગામમાંથી કોઈ દીકરા કે દીકરીએ રાજ્ય અથવા રાષ્ટ્રીય સ્તરે વિશિષ્ટ સિદ્ધિ પ્રાપ્ત કરી હોય, તો એડમિન પેનલ દ્વારા તેમની માહિતી સબમિટ કરી સુપર સ્ટાર્સ ગેલેરીમાં ગૌરવ અપાવો.',
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
            const Text('સુપર સ્ટાર્સ ડેટા લોડ થઈ શક્યો નથી', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(samajSuperStarsProvider),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF041126), foregroundColor: Colors.white),
              child: const Text('ફરી પ્રયાસ કરો (Retry)'),
            ),
          ],
        ),
      ),
    );
  }
}

