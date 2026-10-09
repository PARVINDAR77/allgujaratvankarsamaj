import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/samaj_ratna_provider.dart';
import '../../../home/presentation/providers/view_badge.dart';
import '../../../home/presentation/providers/views_provider.dart';

class SamajRatnaScreen extends ConsumerStatefulWidget {
  const SamajRatnaScreen({super.key});

  @override
  ConsumerState<SamajRatnaScreen> createState() => _SamajRatnaScreenState();
}

class _SamajRatnaScreenState extends ConsumerState<SamajRatnaScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _showDetailsOverlay = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(incrementViewProvider)('SAMAJ_RATNA');
    });
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final ratnasAsync = ref.watch(samajRatnaProvider);

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
}

