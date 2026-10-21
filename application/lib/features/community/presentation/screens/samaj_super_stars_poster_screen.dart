import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/samaj_super_stars_provider.dart';
import '../../../home/presentation/providers/view_badge.dart';
import '../../../home/presentation/providers/views_provider.dart';

class SamajSuperStarsPosterScreen extends ConsumerStatefulWidget {
  const SamajSuperStarsPosterScreen({super.key});

  @override
  ConsumerState<SamajSuperStarsPosterScreen> createState() => _SamajSuperStarsPosterScreenState();
}

class _SamajSuperStarsPosterScreenState extends ConsumerState<SamajSuperStarsPosterScreen> {
  final ScrollController _scrollController = ScrollController();
  final PageController _carouselController = PageController();
  int _currentCardIndex = 0;
  Timer? _autoSlideTimer;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(incrementViewProvider)('SAMAJ_SUPER_STARS');
    });
  }

  void _startAutoSlide(int totalItems) {
    if (totalItems <= 1 || _autoSlideTimer != null) return;
    _autoSlideTimer = Timer.periodic(const Duration(milliseconds: 4000), (timer) {
      if (!mounted || _isUserInteracting || !_carouselController.hasClients) return;
      final next = (_currentCardIndex + 1) % totalItems;
      _carouselController.animateToPage(
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

  void _nextSlide(int total) {
    if (!_carouselController.hasClients || total <= 0) return;
    final next = (_currentCardIndex + 1) % total;
    _carouselController.animateToPage(
      next,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  void _prevSlide(int total) {
    if (!_carouselController.hasClients || total <= 0) return;
    final prev = _currentCardIndex > 0 ? _currentCardIndex - 1 : total - 1;
    _carouselController.animateToPage(
      prev,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _stopAutoSlide();
    _carouselController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showFullImageDialog(BuildContext context, String imageUrl, String name) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    padding: const EdgeInsets.all(32),
                    color: const Color(0xFF0F172A),
                    child: const Icon(Icons.broken_image, color: Colors.white54, size: 64),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final starsAsync = ref.watch(samajSuperStarsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF030A14),
      body: Stack(
        children: [
          // 1. Main Scrollable Container with Poster and Dynamic Super Stars Image Slider
          Positioned.fill(
            child: RefreshIndicator(
              color: const Color(0xFFFFD700),
              backgroundColor: const Color(0xFF081426),
              onRefresh: () async {
                ref.invalidate(samajSuperStarsProvider);
                await ref.read(samajSuperStarsProvider.future);
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: EdgeInsets.only(
                  top: topPadding + 64,
                  bottom: bottomPadding + 115,
                  left: 14,
                  right: 14,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- Main Poster Graphic ---
                        InteractiveViewer(
                          minScale: 1.0,
                          maxScale: 3.5,
                          panEnabled: true,
                          scaleEnabled: true,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black87,
                                  blurRadius: 16,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/images/samaj_super_stars_poster.jpeg',
                                width: double.infinity,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // --- Section Header: Samaj Super Stars ---
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F1E36), Color(0xFF06101E)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                              const BoxShadow(
                                color: Colors.black45,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                                ),
                                child: const Icon(Icons.stars, color: Color(0xFFFFD700), size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'સમાજ સુપર સ્ટાર્સ યાદી',
                                      style: TextStyle(
                                        color: Color(0xFFFFDF73),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Community Super Stars & Achievers',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.7),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Live Count Pill
                              starsAsync.when(
                                data: (stars) {
                                  if (stars.isEmpty) return const SizedBox.shrink();
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFD700).withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: const Color(0xFFFFD700), width: 1),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.people_alt, color: Color(0xFFFFD700), size: 14),
                                        const SizedBox(width: 5),
                                        Text(
                                          '${stars.length} સ્ટાર્સ',
                                          style: const TextStyle(
                                            color: Color(0xFFFFD700),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                loading: () => const SizedBox.shrink(),
                                error: (err, stack) => const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // --- Dynamic Image Slider from Admin Data ---
                        starsAsync.when(
                          data: (stars) {
                            if (stars.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF071224),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.star_outline, size: 52, color: Color(0xFFFFD700)),
                                    const SizedBox(height: 14),
                                    const Text(
                                      'હજુ સુધી કોઈ સુપર સ્ટાર્સ ઉમેરાયા નથી',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'એડમિન પેનલમાંથી ઉમેરેલા સુપર સ્ટાર્સ અહીં લાઈવ દેખાશે.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white60, fontSize: 13),
                                    ),
                                    const SizedBox(height: 16),
                                    OutlinedButton.icon(
                                      onPressed: () => ref.refresh(samajSuperStarsProvider),
                                      icon: const Icon(Icons.refresh, size: 16, color: Color(0xFFFFD700)),
                                      label: const Text(
                                        'ફરી તપાસો (Refresh)',
                                        style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Color(0xFFFFD700)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            if (stars.isNotEmpty && _autoSlideTimer == null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _startAutoSlide(stars.length);
                              });
                            }

                            return _buildNormalImageSlider(stars);
                          },
                          loading: () => Container(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            alignment: Alignment.center,
                            child: const Column(
                              children: [
                                CircularProgressIndicator(color: Color(0xFFFFD700)),
                                SizedBox(height: 12),
                                Text(
                                  'સુપર સ્ટાર્સ લોડ થઈ રહ્યા છે...',
                                  style: TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          error: (err, stack) => Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F0E14),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.redAccent, size: 36),
                                const SizedBox(height: 8),
                                Text(
                                  'ડેટા લોડ કરવામાં સમસ્યા આવી: $err',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () => ref.refresh(samajSuperStarsProvider),
                                  icon: const Icon(Icons.refresh, size: 16),
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Top Gradient for Navigation Clarity
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topPadding + 68,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xEE030A14),
                      Color(0x99030A14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Top Navigation Bar: Back button, Title & Refresh Button
          Positioned(
            top: topPadding + 10,
            left: 14,
            right: 14,
            child: Row(
              children: [
                // Back Button
                GestureDetector(
                  onTap: () => context.canPop() ? context.pop() : context.go('/main-poster'),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFD700), width: 1.6),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 21),
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
                          const BoxShadow(
                            color: Colors.black54,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
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
                GestureDetector(
                  onTap: () {
                    ref.invalidate(samajSuperStarsProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('સુપર સ્ટાર્સ યાદી અપડેટ થઈ રહી છે...'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFD700), width: 1.6),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.refresh, color: Color(0xFFFFD700), size: 21),
                  ),
                ),
              ],
            ),
          ),

          // 4. Bottom Gradient Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: bottomPadding + 110,
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xF0030A14),
                      Color(0x99030A14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 5. Bottom Floating Controls (View Badge + Centered Close Button)
          Positioned(
            bottom: bottomPadding + 14,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Live View Count Badge
                const ViewBadge(sectionName: 'SAMAJ_SUPER_STARS'),
                const SizedBox(height: 10),

                // Centered Close Button
                GestureDetector(
                  onTap: () => context.canPop() ? context.pop() : context.go('/main-poster'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                        const BoxShadow(
                          color: Colors.black87,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close, color: Color(0xFFFFD700), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'બંધ કરો (Close)',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 13.5,
                            letterSpacing: 0.3,
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

  // --- Normal Image Slider Widget (Matching Advertisements Screen Behavior) ---
  Widget _buildNormalImageSlider(List<SamajSuperStar> stars) {
    if (stars.isEmpty) return const SizedBox.shrink();

    return Listener(
      onPointerDown: (_) => _isUserInteracting = true,
      onPointerUp: (_) => _isUserInteracting = false,
      onPointerCancel: (_) => _isUserInteracting = false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Clean Horizontal Image PageView (Moves smoothly left to right)
              SizedBox(
                height: 380,
                child: PageView.builder(
                  controller: _carouselController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: stars.length,
                  onPageChanged: (idx) {
                    setState(() => _currentCardIndex = idx);
                  },
                  itemBuilder: (context, index) {
                    return _buildNormalImageSlide(context, stars[index], index, stars.length);
                  },
                ),
              ),

              // Left Navigation Arrow Button (<) positioned cleanly on the margin
              if (stars.length > 1)
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _prevSlide(stars.length),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                            boxShadow: const [
                              BoxShadow(color: Colors.black87, blurRadius: 6, offset: Offset(0, 2)),
                            ],
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFFD700), size: 18),
                        ),
                      ),
                    ),
                  ),
                ),

              // Right Navigation Arrow Button (>) positioned cleanly on the margin
              if (stars.length > 1)
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _nextSlide(stars.length),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                            boxShadow: const [
                              BoxShadow(color: Colors.black87, blurRadius: 6, offset: Offset(0, 2)),
                            ],
                          ),
                          child: const Icon(Icons.arrow_forward_ios, color: Color(0xFFFFD700), size: 18),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Dots & Position Indicator Row
          if (stars.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Position Counter Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1E36),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x44FFD700)),
                  ),
                  child: Text(
                    '${_currentCardIndex + 1} / ${stars.length}',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Gold Dots Indicator (Tap to jump to slide)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(stars.length, (idx) {
                    final isSelected = idx == _currentCardIndex;
                    return GestureDetector(
                      onTap: () {
                        _carouselController.animateToPage(
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
        ],
      ),
    );
  }

  // --- Normal Image Slide: High-Res Poster Frame with Caption Overlay ---
  Widget _buildNormalImageSlide(BuildContext context, SamajSuperStar star, int index, int total) {
    final hasPhoto = star.photoUrl != null && star.photoUrl!.trim().isNotEmpty;
    final hasName = star.name.trim().isNotEmpty;
    final hasGujarati = star.gujaratiName != null && star.gujaratiName!.trim().isNotEmpty;
    final hasDesignation = star.designation != null && star.designation!.trim().isNotEmpty;
    final hasDescription = star.description != null && star.description!.trim().isNotEmpty;

    return GestureDetector(
      onTap: hasPhoto ? () => _showFullImageDialog(context, star.photoUrl!, star.name) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF041126),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFFD700).withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: const Color(0xFFFFD700).withValues(alpha: 0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Full High-Resolution Poster Graphic
              if (hasPhoto)
                Image.network(
                  star.photoUrl!,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: const Color(0xFF071426),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFFD700),
                          strokeWidth: 2.5,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF071426),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.broken_image, color: Colors.white38, size: 48),
                          SizedBox(height: 8),
                          Text('ઈમેજ લોડ થઈ શકી નથી', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Container(
                  color: const Color(0xFF071426),
                  child: const Center(
                    child: Icon(Icons.person, color: Color(0xFFFFD700), size: 64),
                  ),
                ),

              // Top Badges: Rank Pill & Tap-to-Zoom Hint
              Positioned(
                top: 10,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Rank Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFAA820A)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.emoji_events, color: Colors.black, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            '#${index + 1} SUPER STAR',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 10.5,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Tap to zoom hint badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0x66FFD700)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_in, color: Color(0xFFFFD700), size: 14),
                          SizedBox(width: 4),
                          Text(
                            'ઝૂમ કરો',
                            style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Gradient Caption Overlay (Matching Advertisements Section)
              if (hasName || hasDescription)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.88),
                          Colors.black.withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                hasGujarati ? '${star.name} (${star.gujaratiName})' : star.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (hasDesignation)
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFFFD700), width: 0.8),
                                ),
                                child: Text(
                                  star.designation!,
                                  style: const TextStyle(color: Color(0xFFFFDF73), fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        if (hasDescription) ...[
                          const SizedBox(height: 2),
                          Text(
                            star.description!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 11.5,
                              shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
