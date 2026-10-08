import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pavan_prernadata_provider.dart';
import '../../../home/presentation/providers/view_badge.dart';
import '../../../home/presentation/providers/views_provider.dart';

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
                                                  _buildPlaceholderAvatar(),
                                            ),
                                          )
                                        : _buildPlaceholderAvatar(),
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

  Widget _buildPlaceholderAvatar() {
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
