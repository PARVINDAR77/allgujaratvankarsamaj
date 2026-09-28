import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/advertisements_provider.dart';

class AdvertisementsScreen extends ConsumerStatefulWidget {
  final String? placement;
  const AdvertisementsScreen({super.key, this.placement});

  @override
  ConsumerState<AdvertisementsScreen> createState() => _AdvertisementsScreenState();
}

class _AdvertisementsScreenState extends ConsumerState<AdvertisementsScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    final adsAsync = ref.watch(advertisementsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          adsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
            error: (e, __) => Center(
              child: Text('Error loading ads: $e', style: const TextStyle(color: Colors.red)),
            ),
            data: (ads) {
              final placementFilter = widget.placement ?? 'HOME_BANNER';
              final sectionAds = ads.where((a) => a.placement == placementFilter).toList();
              
              if (sectionAds.isEmpty) {
                return const Center(
                  child: Text(
                    'હાલમાં કોઈ જાહેરાત ઉપલબ્ધ નથી.\n(No advertisements available)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 18),
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
                            errorBuilder: (_, __, ___) => const Center(
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
          // Custom Back button at the top
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
