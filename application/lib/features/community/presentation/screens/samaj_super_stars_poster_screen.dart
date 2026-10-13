import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/presentation/providers/view_badge.dart';
import '../../../home/presentation/providers/views_provider.dart';

class SamajSuperStarsPosterScreen extends ConsumerStatefulWidget {
  const SamajSuperStarsPosterScreen({super.key});

  @override
  ConsumerState<SamajSuperStarsPosterScreen> createState() => _SamajSuperStarsPosterScreenState();
}

class _SamajSuperStarsPosterScreenState extends ConsumerState<SamajSuperStarsPosterScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(incrementViewProvider)('SAMAJ_SUPER_STARS');
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF030A14),
      body: Stack(
        children: [
          // 1. Smooth Full-Width Scrollable & Zoomable Poster
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 3.5,
              panEnabled: true,
              scaleEnabled: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: topPadding + 62,
                  bottom: bottomPadding + 95,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Image.asset(
                      'assets/images/samaj_super_stars_poster.jpeg',
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Gradient overlay at top for navigation clarity
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

          // 3. Top Navigation Bar: Back button & Title banner
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

                const SizedBox(width: 12),

                // Center Title Banner
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF061224)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.8), width: 1.2),
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

                // Balancing spacer for symmetry
                const SizedBox(width: 42),
              ],
            ),
          ),

          // 4. Bottom gradient overlay
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

          // 5. Bottom floating controls (View Badge + Centered Close Button, View List Removed)
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
}
