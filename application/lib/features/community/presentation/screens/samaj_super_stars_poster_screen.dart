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
  final PageController _pageController = PageController();
  int _currentIndex = 0;
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
    _stopAutoSlide();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final starsAsync = ref.watch(samajSuperStarsProvider);

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
}
