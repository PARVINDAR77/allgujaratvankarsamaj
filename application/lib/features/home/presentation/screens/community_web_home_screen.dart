import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../advertisements/providers/advertisements_provider.dart';
import '../providers/views_provider.dart';
import '../widgets/web_home_header.dart';
import '../widgets/web_home_hero.dart';
import '../widgets/web_service_cards.dart';
import '../widgets/web_development_section.dart';
import '../widgets/web_featured_content.dart';
import '../widgets/web_community_values.dart';
import '../widgets/web_home_footer.dart';

class CommunityWebHomeScreen extends ConsumerStatefulWidget {
  const CommunityWebHomeScreen({super.key});

  @override
  ConsumerState<CommunityWebHomeScreen> createState() => _CommunityWebHomeScreenState();
}

class _CommunityWebHomeScreenState extends ConsumerState<CommunityWebHomeScreen>
    with WidgetsBindingObserver {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(advertisementsProvider);
      ref.invalidate(viewsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const WebHomeHeader(activeRoute: '/main-poster'),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        child: const Column(
          children: [
            // Section B: Hero Section with Sacred Lord Buddha and Dr. Babasaheb Ambedkar
            WebHomeHero(),

            // Section F: Three Featured Community Portals (Pavan Prernadata, Super Stars, Samaj Ratna)
            WebFeaturedContent(),

            // Section C: Five Main Community Services (Medallions: Govt, Matrimony, Jobs, Services, Ratna)
            WebServiceCards(),

            // Section E: Gujarat and Community Development Section
            WebDevelopmentSection(),

            // Section G: Five Community Values with Live Counters
            WebCommunityValues(),

            // Section H: Closing Banner & Deep Navy Footer
            WebHomeFooter(),
          ],
        ),
      ),
    );
  }
}
