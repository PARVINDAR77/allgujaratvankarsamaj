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
  bool _isListViewMode = false;

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
      if (!mounted || _isListViewMode || _isUserInteracting || !_carouselController.hasClients) return;
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
        insetPadding: const EdgeInsets.all(16),
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
                  errorBuilder: (_, __, ___) => Container(
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
          // 1. Smooth Scrollable Container with Poster and Dynamic Super Stars Cards
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

                        const SizedBox(height: 20),

                        // --- Section Header: Samaj Super Stars List ---
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
                              // View Mode Toggle & Live Count Pill
                              starsAsync.when(
                                data: (stars) {
                                  if (stars.isEmpty) return const SizedBox.shrink();
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF041126),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: const Color(0x55FFD700)),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Slider View Button
                                            GestureDetector(
                                              onTap: () {
                                                if (_isListViewMode) {
                                                  setState(() => _isListViewMode = false);
                                                  _startAutoSlide(stars.length);
                                                }
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: !_isListViewMode ? const Color(0xFFFFD700) : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.view_carousel_rounded,
                                                      size: 14,
                                                      color: !_isListViewMode ? Colors.black : Colors.white70,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'સ્લાઇડર',
                                                      style: TextStyle(
                                                        color: !_isListViewMode ? Colors.black : Colors.white70,
                                                        fontSize: 10.5,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // List View Button
                                            GestureDetector(
                                              onTap: () {
                                                if (!_isListViewMode) {
                                                  setState(() => _isListViewMode = true);
                                                  _stopAutoSlide();
                                                }
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: _isListViewMode ? const Color(0xFFFFD700) : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.view_agenda_rounded,
                                                      size: 14,
                                                      color: _isListViewMode ? Colors.black : Colors.white70,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'યાદી',
                                                      style: TextStyle(
                                                        color: _isListViewMode ? Colors.black : Colors.white70,
                                                        fontSize: 10.5,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Live Count Pill
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                                      ),
                                    ],
                                  );
                                },
                                loading: () => const SizedBox.shrink(),
                                error: (_, __) => const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // --- Dynamic Candidate Posts from Admin ---
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

                            if (stars.isNotEmpty && !_isListViewMode && _autoSlideTimer == null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _startAutoSlide(stars.length);
                              });
                            }

                            if (_isListViewMode) {
                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: stars.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 14),
                                itemBuilder: (context, index) {
                                  final star = stars[index];
                                  return _buildSuperStarCard(context, star, index + 1);
                                },
                              );
                            }

                            return _buildCarouselSlider(stars);
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
                          colors: [Color(0xFF0F172A), Color(0xFF061224)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                          width: 1.2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stars, color: Color(0xFFFFD700), size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Samaj Super Stars',
                            style: TextStyle(
                              color: Color(0xFFFFDF73),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
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
                    ref.refresh(samajSuperStarsProvider);
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

  // --- Right-to-Left (RTL) Horizontal Carousel Slider Widget ---
  Widget _buildCarouselSlider(List<SamajSuperStar> stars) {
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
            clipBehavior: Clip.none,
            children: [
              // Horizontal Right-to-Left PageView
              SizedBox(
                height: 290,
                child: PageView.builder(
                  controller: _carouselController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: stars.length,
                  onPageChanged: (idx) {
                    setState(() => _currentCardIndex = idx);
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: _buildSuperStarCard(context, stars[index], index + 1),
                      ),
                    );
                  },
                ),
              ),

              // Left Navigation Arrow Button (<)
              if (stars.length > 1)
                Positioned(
                  left: -6,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _prevSlide(stars.length),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: const Color(0xE6041126),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                          boxShadow: const [
                            BoxShadow(color: Colors.black87, blurRadius: 8, offset: Offset(0, 3)),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFFFD700), size: 18),
                      ),
                    ),
                  ),
                ),

              // Right Navigation Arrow Button (>)
              if (stars.length > 1)
                Positioned(
                  right: -6,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _nextSlide(stars.length),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: const Color(0xE6041126),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                          boxShadow: const [
                            BoxShadow(color: Colors.black87, blurRadius: 8, offset: Offset(0, 3)),
                          ],
                        ),
                        child: const Icon(Icons.arrow_forward_ios, color: Color(0xFFFFD700), size: 18),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Dots & Position Indicator Row
          if (stars.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pill indicator
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
                // Dots
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
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
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // --- Beautiful Candidate Card Widget ---
  Widget _buildSuperStarCard(BuildContext context, SamajSuperStar star, int rank) {
    final hasPhoto = star.photoUrl != null && star.photoUrl!.trim().isNotEmpty;
    final hasGujarati = star.gujaratiName != null && star.gujaratiName!.trim().isNotEmpty;
    final hasDesignation = star.designation != null && star.designation!.trim().isNotEmpty;
    final hasYear = star.year != null && star.year!.trim().isNotEmpty;
    final hasDescription = star.description != null && star.description!.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0C1B33), Color(0xFF061122)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Rank Badge & Samaj Star Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Rank Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFAA820A)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.black, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '#$rank SUPER STAR',
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

              // Samaj Pride Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B2545),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.6)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, color: Color(0xFFFFD700), size: 13),
                    SizedBox(width: 4),
                    Text(
                      'સમાજ ગૌરવ',
                      style: TextStyle(
                        color: Color(0xFFFFDF73),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Main Candidate Details Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Avatar with Glowing Gold Ring
              GestureDetector(
                onTap: hasPhoto ? () => _showFullImageDialog(context, star.photoUrl!, star.name) : null,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFFD700), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.35),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: hasPhoto
                        ? Image.network(
                            star.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFF041126),
                              child: const Icon(Icons.person, color: Color(0xFFFFD700), size: 36),
                            ),
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: const Color(0xFF041126),
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFFFFD700),
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: const Color(0xFF041126),
                            child: const Icon(Icons.person, color: Color(0xFFFFD700), size: 36),
                          ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Name, Gujarati Name, Designation & Year
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Primary Name
                    Text(
                      star.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                    ),

                    // Gujarati Name / Secondary Title
                    if (hasGujarati) ...[
                      const SizedBox(height: 2),
                      Text(
                        star.gujaratiName!,
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],

                    // Designation & Year Tag
                    if (hasDesignation || hasYear) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.school, size: 13, color: Color(0xFFFFD700)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                [
                                  if (hasDesignation) star.designation!,
                                  if (hasYear) '(${star.year!})',
                                ].join(' '),
                                style: const TextStyle(
                                  color: Color(0xFFFFDF73),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Description / Achievement Notes
          if (hasDescription) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: Text(
                star.description!,
                style: const TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
