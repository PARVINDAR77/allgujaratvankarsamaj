import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../advertisements/providers/advertisements_provider.dart';
import '../providers/views_provider.dart';
import '../widgets/web_home_header.dart';
import '../widgets/web_matrimony_hero.dart';
import '../widgets/web_matrimony_actions.dart';
import '../widgets/web_home_footer.dart';

class WebMatrimonyHomeScreen extends ConsumerStatefulWidget {
  const WebMatrimonyHomeScreen({super.key});

  @override
  ConsumerState<WebMatrimonyHomeScreen> createState() => _WebMatrimonyHomeScreenState();
}

class _WebMatrimonyHomeScreenState extends ConsumerState<WebMatrimonyHomeScreen>
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
      appBar: const WebHomeHeader(activeRoute: '/home'),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            // Section 1: Dedicated Matrimony Hero with Quick Match Search & Royal Couple Poster
            const WebMatrimonyHero(),

            // Section 2: Core Matrimonial Action Cards (Groom, Bride, Matchmaking, Registration)
            const WebMatrimonyActions(),

            // Section 3: Matrimonial Trust & Security Pillars
            _buildMatrimonyTrustSection(context),

            // Section 4: Closing Banner & Deep Navy Footer
            const WebHomeFooter(),
          ],
        ),
      ),
    );
  }

  // Matrimonial Security & Trust Pillars
  Widget _buildMatrimonyTrustSection(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1050;

    final pillars = [
      _TrustPillar(
        icon: Icons.verified_user_rounded,
        title: '૧૦૦% વેરિફાઈડ પ્રોફાઈલ',
        subtitle: 'દરેક પ્રોફાઈલની ચકાસણી સમાજના વરિષ્ઠો અને એડમિન દ્વારા સંપૂર્ણ રીતે કરવામાં આવે છે.',
      ),
      _TrustPillar(
        icon: Icons.lock_outline_rounded,
        title: 'સંપૂર્ણ પારિવારિક પ્રાઈવસી',
        subtitle: 'ઉમેદવાર અને પરિવારની સંવેદનશીલ વિગતો અને ફોટોગ્રાફ્સ સંપૂર્ણ સુરક્ષિત રહે છે.',
      ),
      _TrustPillar(
        icon: Icons.favorite_outline_rounded,
        title: 'પરસ્પર પસંદગી & મેળ',
        subtitle: 'પરગણા, ઉંમર, શિક્ષણ અને વ્યવસાય મુજબ સચોટ અને અનુકૂળ વૈવાહિક મેળ.',
      ),
      _TrustPillar(
        icon: Icons.volunteer_activism_rounded,
        title: 'નિઃશુલ્ક સમાજ સેવા',
        subtitle: 'કોઈપણ વ્યાપારી હેતુ વગર સમગ્ર વણકર સમાજના ઉત્કર્ષ માટે ઉપલબ્ધ પ્લેટફોર્મ.',
      ),
    ];

    return Container(
      width: double.infinity,
      color: const Color(0xFFFAF8F5),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 36 : 16,
        vertical: 48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF101B36),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD6A34A), width: 1.2),
                ),
                child: const Text(
                  'WHY CHOOSE VANKAR SAMAJ MATRIMONY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFDF7A),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'વિશ્વસનીય • સુરક્ષિત • પવિત્ર સંબંધ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF101B36),
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: pillars.map((p) {
                  return Container(
                    width: isDesktop ? (1240 - 60) / 4 : (width > 600 ? (width - 60) / 2 : width - 32),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD6A34A).withValues(alpha: 0.4), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF101B36).withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFA4143D).withValues(alpha: 0.1),
                          ),
                          child: Icon(p.icon, color: const Color(0xFFA4143D), size: 24),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          p.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF101B36),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          p.subtitle,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrustPillar {
  final IconData icon;
  final String title;
  final String subtitle;

  _TrustPillar({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
