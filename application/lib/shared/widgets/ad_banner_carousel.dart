import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/models/advertisement_model.dart';
import '../../../features/advertisements/providers/advertisements_provider.dart';

/// Ad banner carousel shown on the home screen.
/// Handles: Loading | Empty (hidden) | Error (silent) | Data (carousel).
/// All active/date filtering is done by the backend.
class AdBannerCarousel extends ConsumerStatefulWidget {
  const AdBannerCarousel({super.key});

  @override
  ConsumerState<AdBannerCarousel> createState() => _AdBannerCarouselState();
}

class _AdBannerCarouselState extends ConsumerState<AdBannerCarousel> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final adsAsync = ref.watch(advertisementsProvider);

    return adsAsync.when(
      // Loading — compact shimmer height so layout doesn't jump
      loading: () => const SizedBox(
        height: 140,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD4AF37))),
      ),
      // Error — silent: don't block the home screen for a banner fetch failure
      error: (_, __) => const SizedBox.shrink(),
      data: (ads) {
        // Filter to HOME_BANNER placement only
        final banners = ads.where((a) => a.placement == 'HOME_BANNER').toList();
        if (banners.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            SizedBox(
              height: 150,
              child: PageView.builder(
                controller: _controller,
                itemCount: banners.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) =>
                    _AdCard(ad: banners[index], onTap: () => _openUrl(banners[index].targetUrl)),
              ),
            ),
            if (banners.length > 1) ...[
              const SizedBox(height: 8),
              _DotsIndicator(count: banners.length, current: _currentPage),
            ],
          ],
        );
      },
    );
  }
}

class _AdCard extends StatelessWidget {
  final AdvertisementModel ad;
  final VoidCallback onTap;
  const _AdCard({required this.ad, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                ad.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF111111),
                  child: const Center(
                    child: Icon(Icons.image_not_supported,
                        color: Colors.white24, size: 36),
                  ),
                ),
              ),
              // Title overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    ad.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int current;
  const _DotsIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == current ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: i == current
                ? const Color(0xFFD4AF37)
                : Colors.white24,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
