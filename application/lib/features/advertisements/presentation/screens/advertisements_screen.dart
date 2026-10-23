import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/models/advertisement_model.dart';
import '../../../home/presentation/providers/view_badge.dart';
import '../../../home/presentation/providers/views_provider.dart';
import '../../../home/presentation/widgets/web_home_header.dart';
import '../../../home/presentation/widgets/web_home_footer.dart';
import '../../providers/advertisements_provider.dart';

class AdvertisementsScreen extends ConsumerStatefulWidget {
  final String? placement;
  final String? section;
  const AdvertisementsScreen({super.key, this.placement, this.section});

  @override
  ConsumerState<AdvertisementsScreen> createState() => _AdvertisementsScreenState();
}

class _AdvertisementsScreenState extends ConsumerState<AdvertisementsScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.section != null && widget.section!.isNotEmpty) {
        ref.read(incrementViewProvider)(widget.section!);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _nextPage(int total) {
    if (_currentIndex < total - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _prevPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  // ===========================================================================
  // ============================== BUILD DISPATCHER ===========================
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    final adsAsync = ref.watch(advertisementsProvider);

    if (kIsWeb) {
      return _buildWebScaffold(context, adsAsync);
    }
    return _buildMobileScaffold(context, adsAsync);
  }

  // ===========================================================================
  // ============================ MOBILE SCAFFOLD (100% PRESERVED) =============
  // ===========================================================================
  Widget _buildMobileScaffold(BuildContext context, AsyncValue<List<AdvertisementModel>> adsAsync) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          adsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
            error: (e, _) => Center(
              child: Text('Error loading ads: $e', style: const TextStyle(color: Colors.red)),
            ),
            data: (ads) {
              List<AdvertisementModel> sectionAds;
              if (widget.placement != null && widget.placement!.isNotEmpty) {
                sectionAds = ads.where((a) => a.placement.toLowerCase() == widget.placement!.toLowerCase()).toList();
                if (sectionAds.isEmpty) {
                  // Fallback to all active ads so user never sees blank screen if placement differs
                  sectionAds = ads;
                }
              } else {
                sectionAds = ads;
              }
              
              if (sectionAds.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.campaign_outlined, size: 64, color: Color(0xFFD4AF37)),
                      const SizedBox(height: 16),
                      const Text(
                        'હાલમાં કોઈ જાહેરાત ઉપલબ્ધ નથી.\n(No advertisements available)',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 18),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => ref.refresh(advertisementsProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('રીફ્રેશ કરો (Refresh)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: sectionAds.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final ad = sectionAds[index];
                      return GestureDetector(
                        onTap: () => _openUrl(ad.targetUrl),
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: Image.network(
                            ad.imageUrl,
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Icon(Icons.broken_image, color: Colors.white54, size: 60),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Left Arrow
                  if (sectionAds.length > 1 && _currentIndex > 0)
                    Positioned(
                      left: 10,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 40),
                          onPressed: _prevPage,
                        ),
                      ),
                    ),

                  // Right Arrow
                  if (sectionAds.length > 1 && _currentIndex < sectionAds.length - 1)
                    Positioned(
                      right: 10,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 40),
                          onPressed: () => _nextPage(sectionAds.length),
                        ),
                      ),
                    ),

                  // Dot Indicators
                  if (sectionAds.length > 1)
                    Positioned(
                      bottom: 40,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          sectionAds.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentIndex == index ? 12 : 8,
                            height: _currentIndex == index ? 12 : 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentIndex == index ? const Color(0xFFD4AF37) : Colors.white54,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Top Action Bar with Back & Refresh buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            right: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.section != null && widget.section!.isNotEmpty) ...[
                      ViewBadge(sectionName: widget.section!, isLight: false),
                      const SizedBox(width: 8),
                    ],
                    Material(
                      color: Colors.black54,
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: const Icon(Icons.refresh, color: Color(0xFFD4AF37), size: 28),
                        tooltip: 'Refresh Advertisements',
                        onPressed: () => ref.refresh(advertisementsProvider),
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

  // ===========================================================================
  // ============================ WEB DESKTOP SCAFFOLD ==========================
  // ===========================================================================
  Widget _buildWebScaffold(BuildContext context, AsyncValue<List<AdvertisementModel>> adsAsync) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1050;
    final isTablet = width >= 700 && width < 1050;

    final isUnity = widget.section == 'HOME_UNITY';
    final isRoots = widget.section == 'HOME_STRONG_ROOTS';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5),
      appBar: const WebHomeHeader(activeRoute: '/advertisement'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Context-Aware Web Hero Banner
            _buildWebHeroBanner(context, isDesktop, isUnity, isRoots),

            // 2. Main Centered Content
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : (isTablet ? 20 : 16),
                    vertical: 36,
                  ),
                  child: Builder(
                    builder: (context) {
                      final ads = adsAsync.valueOrNull ?? [];
                      List<AdvertisementModel> sectionAds;
                      if (widget.placement != null && widget.placement!.isNotEmpty) {
                        sectionAds = ads.where((a) => a.placement.toLowerCase() == widget.placement!.toLowerCase()).toList();
                        if (sectionAds.isEmpty) sectionAds = ads;
                      } else {
                        sectionAds = ads;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Thematic Pillars according to Section
                          if (isUnity) _buildWebUnityPillars(isDesktop),
                          if (isRoots) _buildWebRootsPillars(isDesktop),

                          const SizedBox(height: 36),

                          // Live Advertisements / Announcements Section
                          _buildWebAdsSectionHeader(sectionAds.length, isUnity, isRoots),
                          const SizedBox(height: 20),

                          if (adsAsync.isLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.0),
                                child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                              ),
                            )
                          else if (sectionAds.isEmpty)
                            _buildWebFallbackShowcase(context, isUnity, isRoots, isDesktop)
                          else
                            _buildWebAdsGrid(context, sectionAds, isDesktop, isTablet),

                          const SizedBox(height: 48),

                          // Ad Submission & Contact Card
                          _buildWebAdSubmissionCta(context),
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

  Widget _buildWebHeroBanner(BuildContext context, bool isDesktop, bool isUnity, bool isRoots) {
    String titleGuj;
    String titleEng;
    String subtitle;
    String breadcrumbLabel;
    IconData heroIcon;
    List<Color> gradientColors;

    if (isUnity) {
      titleGuj = 'સમાજ એકતા અને સંગઠન પરિષદ — એક વિચાર, એક પરિવાર';
      titleEng = 'Unity in Diversity • 33 District Committees, Samaj Sammelan & Social Harmony';
      subtitle = 'ગુજરાતના ૩૩ જિલ્લાઓમાં વણકર સમાજની સામાજિક એકતા, સ્નેહ મિલન સમારોહ, સંગઠન અને સામાજિક વિકાસ માટે એકતાનો સત્તાવાર મંચ.';
      breadcrumbLabel = 'Unity in Diversity (સમાજ એકતા)';
      heroIcon = Icons.groups_rounded;
      gradientColors = const [Color(0xFF0F1E36), Color(0xFF1E3A8A), Color(0xFF0F172A)];
    } else if (isRoots) {
      titleGuj = 'આપણો ગૌરવશાળી વારસો, કળા અને મજબૂત મૂળિયાં';
      titleEng = 'Strong Roots • Bright Future • Preserving Handloom Heritage, Arts & Generations of Pride';
      subtitle = 'પાટણના પટોળા, સાદળી, પરંપરાગત વણાટ કળા અને સદીઓ જૂના સંસ્કારોનો ગૌરવશાળી વારસો જે આપણી આવતીકાલને ઉજ્જવળ બનાવે છે.';
      breadcrumbLabel = 'Strong Roots & Heritage (આપણો વારસો)';
      heroIcon = Icons.eco_rounded;
      gradientColors = const [Color(0xFF14532D), Color(0xFF166534), Color(0xFF0F172A)];
    } else {
      titleGuj = 'સમાજ જાહેરાત, પરિપત્રો અને વ્યાપાર સંગઠન';
      titleEng = 'Community Notices, Sponsored Announcements & Business Showcase';
      subtitle = 'અખિલ ગુજરાત વણકર સમાજના ઉદ્યોગ સાહસિકો, સામાજિક સંસ્થાઓ અને સત્તાવાર સૂચનાઓ માટેનું જાહેર મંચ.';
      breadcrumbLabel = 'Announcements (સમાજ જાહેરાતો)';
      heroIcon = Icons.campaign_rounded;
      gradientColors = const [Color(0xFF3B0716), Color(0xFF500724), Color(0xFF0F172A)];
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
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
              vertical: isDesktop ? 32 : 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumbs & View Badge
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
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
                        Text(
                          breadcrumbLabel,
                          style: const TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => ref.refresh(advertisementsProvider),
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
                        if (widget.section != null && widget.section!.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          ViewBadge(sectionName: widget.section!),
                        ],
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Main Title Block
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
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
                            blurRadius: 14,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(heroIcon, color: const Color(0xFF0F172A), size: 32),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titleGuj,
                            style: const TextStyle(
                              color: Color(0xFFFFF7DB),
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            titleEng,
                            style: const TextStyle(
                              color: Color(0xFFFFDF73),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 820),
                            child: Text(
                              subtitle,
                              style: const TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontSize: 13,
                                height: 1.45,
                              ),
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

  // Four Pillars for Unity
  Widget _buildWebUnityPillars(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'સમાજ એકતાના ૪ મુખ્ય આધારસ્તંભો:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          const Text(
            'એકતા એ જ સમાજની સર્વોચ્ચ શક્તિ છે. પરસ્પર સ્નેહ, સંગઠન અને સહકારથી જ સમાજનો સર્વાંગી વિકાસ શક્ય બને છે.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),
          if (isDesktop)
            Row(
              children: [
                Expanded(child: _buildPillarCard(Icons.handshake_rounded, 'સામાજિક સમરસતા', '૩૩ જિલ્લાઓમાં પારસ્પરિક બંધુત્વ', const Color(0xFF1E3A8A))),
                const SizedBox(width: 16),
                Expanded(child: _buildPillarCard(Icons.account_tree_rounded, 'સંગઠન પરિષદો', 'તાલુકા અને ગ્રામીણ સમિતિ સંકલન', const Color(0xFF0D9488))),
                const SizedBox(width: 16),
                Expanded(child: _buildPillarCard(Icons.celebration_rounded, 'સ્નેહ મિલન સમારોહ', 'વાર્ષિક મેળાવડા & વિચાર સંવાદ', const Color(0xFFD97706))),
                const SizedBox(width: 16),
                Expanded(child: _buildPillarCard(Icons.favorite_rounded, 'સમૂહ લગ્નોત્સવ', 'ખર્ચ બચત અને સંસ્કારી સંસ્કાર', const Color(0xFFDC2626))),
              ],
            )
          else
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width >= 650 ? (MediaQuery.of(context).size.width - 120) / 2 : double.infinity,
                  child: _buildPillarCard(Icons.handshake_rounded, 'સામાજિક સમરસતા', '૩૩ જિલ્લાઓમાં પારસ્પરિક બંધુત્વ', const Color(0xFF1E3A8A)),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width >= 650 ? (MediaQuery.of(context).size.width - 120) / 2 : double.infinity,
                  child: _buildPillarCard(Icons.account_tree_rounded, 'સંગઠન પરિષદો', 'તાલુકા અને ગ્રામીણ સમિતિ સંકલન', const Color(0xFF0D9488)),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width >= 650 ? (MediaQuery.of(context).size.width - 120) / 2 : double.infinity,
                  child: _buildPillarCard(Icons.celebration_rounded, 'સ્નેહ મિલન સમારોહ', 'વાર્ષિક મેળાવડા & વિચાર સંવાદ', const Color(0xFFD97706)),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width >= 650 ? (MediaQuery.of(context).size.width - 120) / 2 : double.infinity,
                  child: _buildPillarCard(Icons.favorite_rounded, 'સમૂહ લગ્નોત્સવ', 'ખર્ચ બચત અને સંસ્કારી સંસ્કાર', const Color(0xFFDC2626)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Four Pillars for Strong Roots
  Widget _buildWebRootsPillars(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'આપણા ગૌરવશાળી વારસાના ૪ મૂલ્યવાન સ્તંભો:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 6),
          const Text(
            'જે વૃક્ષના મૂળિયાં ઊંડા હોય તે જ મહાવૃક્ષ બને છે. આપણી વણાટ કળા અને સામાજિક મૂલ્યો આપણા ગૌરવનો પાયો છે.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),
          if (isDesktop)
            Row(
              children: [
                Expanded(child: _buildPillarCard(Icons.texture_rounded, 'પાટણના પટોળા', 'વિશ્વ પ્રસિદ્ધ વણાટ કળાનો વારસો', const Color(0xFF059669))),
                const SizedBox(width: 16),
                Expanded(child: _buildPillarCard(Icons.self_improvement_rounded, 'સંત પરંપરા', 'કબીર-રવિદાસની અમર વાણી', const Color(0xFF7C3AED))),
                const SizedBox(width: 16),
                Expanded(child: _buildPillarCard(Icons.family_restroom_rounded, 'વડીલોના સંસ્કાર', 'નૈતિકતા અને સદાચારનો પાયો', const Color(0xFFD97706))),
                const SizedBox(width: 16),
                Expanded(child: _buildPillarCard(Icons.auto_stories_rounded, 'આધુનિક પ્રગતિ', 'પરંપરા સાથે નવીન ટેક્નોલોજી', const Color(0xFF2563EB))),
              ],
            )
          else
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width >= 650 ? (MediaQuery.of(context).size.width - 120) / 2 : double.infinity,
                  child: _buildPillarCard(Icons.texture_rounded, 'પાટણના પટોળા', 'વિશ્વ પ્રસિદ્ધ વણાટ કળાનો વારસો', const Color(0xFF059669)),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width >= 650 ? (MediaQuery.of(context).size.width - 120) / 2 : double.infinity,
                  child: _buildPillarCard(Icons.self_improvement_rounded, 'સંત પરંપરા', 'કબીર-રવિદાસની અમર વાણી', const Color(0xFF7C3AED)),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width >= 650 ? (MediaQuery.of(context).size.width - 120) / 2 : double.infinity,
                  child: _buildPillarCard(Icons.family_restroom_rounded, 'વડીલોના સંસ્કાર', 'નૈતિકતા અને સદાચારનો પાયો', const Color(0xFFD97706)),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width >= 650 ? (MediaQuery.of(context).size.width - 120) / 2 : double.infinity,
                  child: _buildPillarCard(Icons.auto_stories_rounded, 'આધુનિક પ્રગતિ', 'પરંપરા સાથે નવીન ટેક્નોલોજી', const Color(0xFF2563EB)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPillarCard(IconData icon, String title, String sub, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), height: 1.3)),
        ],
      ),
    );
  }

  Widget _buildWebAdsSectionHeader(int count, bool isUnity, bool isRoots) {
    String title = 'સત્તાવાર જાહેરાતો અને સંગઠન પરિપત્રો';
    if (isUnity) title = 'એકતા સંગઠન પરિપત્રો અને સૂચનાઓ';
    if (isRoots) title = 'સાંસ્કૃતિક વારસો અને પરિપત્ર ગેલેરી';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 4, height: 18, color: const Color(0xFFD4AF37)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Text(
            'કુલ પોસ્ટર્સ: $count',
            style: const TextStyle(color: Color(0xFF92400E), fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildWebAdsGrid(
    BuildContext context,
    List<AdvertisementModel> ads,
    bool isDesktop,
    bool isTablet,
  ) {
    final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: ads.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        mainAxisExtent: 380,
      ),
      itemBuilder: (context, index) {
        final ad = ads[index];
        return _buildWebAdCard(context, ad);
      },
    );
  }

  Widget _buildWebAdCard(BuildContext context, AdvertisementModel ad) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ad Image with Lightbox Viewer
          Expanded(
            child: InkWell(
              onTap: () => _openAdLightbox(context, ad),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    ad.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF0F172A),
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_in_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('ઝૂમ કરો', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Card Bottom Action
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    ad.title.isNotEmpty ? ad.title : 'સમાજ સત્તાવાર જાહેરાત',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (ad.targetUrl != null && ad.targetUrl!.isNotEmpty)
                  ElevatedButton(
                    onPressed: () => _openUrl(ad.targetUrl),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('લિંક ખોલો'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openAdLightbox(BuildContext context, AdvertisementModel ad) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
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
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  ad.imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fallback Showcase when backend has 0 active ads
  Widget _buildWebFallbackShowcase(BuildContext context, bool isUnity, bool isRoots, bool isDesktop) {
    if (isUnity) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            const Icon(Icons.groups_rounded, size: 48, color: Color(0xFF1E3A8A)),
            const SizedBox(height: 12),
            const Text(
              'અખિલ ગુજરાત વણકર સમાજ એકતા અભિયાન',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            const Text(
              'હાલમાં નવી જાહેરાતો પ્રક્રિયા હેઠળ છે. આપ જિલ્લા સમિતિઓની બેઠક અને આગામી સ્નેહ મિલનની વિગતો માટે સંપર્ક કરી શકો છો.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/main-poster'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white),
              child: const Text('હોમ પેજ પર પાછા જાઓ'),
            ),
          ],
        ),
      );
    }

    if (isRoots) {
      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            const Icon(Icons.eco_rounded, size: 48, color: Color(0xFF166534)),
            const SizedBox(height: 12),
            const Text(
              'આપણી ધરોહર: પાટણના પટોળા & પરંપરાગત વણાટ કળા',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            const Text(
              'સદીઓ જૂની હેન્ડલૂમ કળા અને સમાજના કારીગરોનું રાષ્ટ્રીય સ્તરે ગૌરવ. આપણી સંસ્કૃતિનું જતન એ જ આપણી ખરી ઓળખ છે.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/main-poster'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF166534), foregroundColor: Colors.white),
              child: const Text('હોમ પેજ પર પાછા જાઓ'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Center(
        child: Text(
          'હાલમાં કોઈ જાહેરાત ઉપલબ્ધ નથી.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
      ),
    );
  }

  // CTA Card: Ad Submission & Contact
  Widget _buildWebAdSubmissionCta(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 650;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F1E36), Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.6)),
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_business_rounded, color: Color(0xFFFFD700), size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'સમાજના મંચ પર જાહેરાત કે પરિપત્ર પ્રકાશિત કરો',
                        style: TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'સમાજના વ્યવસાયિકો અને સામાજિક મંડળો માટે ઓછા ખર્ચે સમગ્ર ગુજરાતમાં પ્રચારની સુવિધા.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('જાહેરાત માટે એડમિન કાર્યાલયનો સંપર્ક કરો: 98795 XXXXX')),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('સંપર્ક કરો (Contact Admin)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_business_rounded, color: Color(0xFFFFD700), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'શું આપ સમાજના મંચ પર જાહેરાત કે પરિપત્ર પ્રકાશિત કરવા માંગો છો?',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'સમાજના વ્યવસાયિકો અને સામાજિક મંડળો માટે ઓછા ખર્ચે સમગ્ર ગુજરાતમાં પ્રચારની સુવિધા.',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('જાહેરાત માટે એડમિન કાર્યાલયનો સંપર્ક કરો: 98795 XXXXX')),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('સંપર્ક કરો (Contact)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
    );
  }
}
