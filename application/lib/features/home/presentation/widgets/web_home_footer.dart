import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/widgets/whatsapp_icon.dart';

class WebHomeFooter extends StatelessWidget {
  const WebHomeFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1000;
    final isTablet = width >= 650 && width < 1000;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFBF9F5),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFD6A34A).withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        children: [
          // 1. Proud to be Vankar Slogan Banner
          _buildSloganBanner(context),

          // 2. Main Footer Content
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 36 : (isTablet ? 24 : 16),
                  vertical: 40,
                ),
                child: isDesktop
                    ? _buildDesktopColumns(context)
                    : _buildMobileTabletColumns(context),
              ),
            ),
          ),

          // 3. Bottom Bar with Dynamic Year Copyright
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildSloganBanner(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final isTablet = width >= 600 && width < 900;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFAF8F5),
            Color(0xFFF7F4ED),
            Color(0xFFFFFFFF),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: Color(0xFFD6A34A),
            width: 1.5,
          ),
          bottom: BorderSide(
            color: Color(0xFFD6A34A),
            width: 1.2,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 48 : 34,
        horizontal: isDesktop ? 36 : 18,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Filigree Ornamental Divider
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color(0xFFD6A34A),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.diamond_rounded,
                            color: Color(0xFFFFD54F), size: 14),
                        SizedBox(width: 6),
                        Icon(Icons.auto_awesome_rounded,
                            color: Color(0xFFFFDF73), size: 20),
                        SizedBox(width: 6),
                        Icon(Icons.diamond_rounded,
                            color: Color(0xFFFFD54F), size: 14),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFD6A34A),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Royal Community Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 6.5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B1538), Color(0xFF5A0B22)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border:
                      Border.all(color: const Color(0xFFFFD54F), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B1538).withValues(alpha: 0.5),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_rounded,
                        color: Color(0xFFFFD54F), size: 15),
                    SizedBox(width: 8),
                    Text(
                      'SAMAJ PRIDE & UNITY • એક સમાજ, એક પરિવાર',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Masterpiece Main Headline (Proud to be Vankar)
              Text(
                'PROUD TO BE VANKAR',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isDesktop ? 44 : (isTablet ? 34 : 27),
                  fontWeight: FontWeight.w900,
                  letterSpacing: isDesktop ? 3.0 : 1.8,
                  color: const Color(0xFF101B36),
                  height: 1.15,
                  shadows: [
                    Shadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Gujarati Companion Statement
              const Text(
                'વણકર સમાજ અમારું ગૌરવ  •  ગુજરાતનું સન્માન',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFA4143D),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 12),

              // Professional Subtitle
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: const Text(
                  'Uniting our heritage across 33 districts, uplifting every family through education and opportunity, and building an empowered tomorrow.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Three Glassmorphic Trust Badges
              Wrap(
                spacing: 16,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _buildTrustBadge(
                    icon: Icons.account_balance_rounded,
                    label: '33 Districts Connected',
                    color: const Color(0xFFFFA000),
                  ),
                  _buildTrustBadge(
                    icon: Icons.verified_user_rounded,
                    label: '100% Verified Community',
                    color: const Color(0xFF00ACC1),
                  ),
                  _buildTrustBadge(
                    icon: Icons.diversity_1_rounded,
                    label: 'One Unified Samaj Network',
                    color: const Color(0xFF43A047),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Two Action CTAs
              Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  // Primary Golden CTA
                  ElevatedButton(
                    onPressed: () => context.push('/register'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFA4143D), Color(0xFF7E102F)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD6A34A), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFA4143D).withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 13),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_add_alt_1_rounded,
                                color: Color(0xFFFFD54F), size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Join Our Samaj Registry',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward_rounded,
                                color: Color(0xFFFFD54F), size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Secondary Glass CTA
                  OutlinedButton(
                    onPressed: () => context.push('/samaj-services'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                          color: Color(0xFFA4143D), width: 1.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 13),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.explore_rounded,
                            color: Color(0xFFA4143D), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Explore Community Services',
                          style: TextStyle(
                            color: Color(0xFFA4143D),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Bottom Filigree Rule
              Container(
                height: 1,
                width: 320,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Color(0xFFD6A34A),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF101B36),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopColumns(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Column 1: Organization & Identity
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD4AF37),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Container(
                        color: Colors.white,
                        child: Image.asset(
                          'assets/images/vankar_samaj_official_emblem.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.temple_hindu,
                            color: Color(0xFFA4143D),
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All Gujarat Vankar Samaj',
                        style: TextStyle(
                          color: Color(0xFF101B36),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'એક સમાજ, એક વિચાર, એક પરિવાર',
                        style: TextStyle(
                          color: Color(0xFFA4143D),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'The unified digital portal of All Gujarat Vankar Samaj connecting families, professionals, government employees, and youth across Gujarat for cultural unity and matrimonial excellence.',
                style: TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 12.5,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 36),

        // Column 2: Quick Links
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildColumnHeading('Core Portals'),
              _buildFooterLink(context, 'Home', '/main-poster'),
              _buildFooterLink(context, 'Matrimony Dashboard', '/home'),
              _buildFooterLink(context, 'Government Employees', '/government-employees'),
              _buildFooterLink(context, 'Private Job Portal', '/private-employees'),
              _buildFooterLink(context, 'Samaj Services', '/samaj-services'),
              _buildFooterLink(context, 'Samaj Ratna', '/samaj-ratna'),
            ],
          ),
        ),

        // Column 3: Featured Initiatives
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildColumnHeading('Community Initiatives'),
              _buildFooterLink(context, 'Pavan Prernadata', '/pavan-prernadata'),
              _buildFooterLink(context, 'Samaj Super Stars', '/samaj-super-stars-poster'),
              _buildFooterLink(context, 'Family Directory', '/family-details'),
              _buildFooterLink(context, 'Education Corner', '/education'),
              _buildFooterLink(context, 'Live Community Statistics', '/statistics'),
              _buildFooterLink(context, 'Today’s Birthdays', '/birthdays'),
            ],
          ),
        ),

        // Column 4: Access & Legal
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildColumnHeading('Account & Legal'),
              _buildFooterLink(context, 'Member Login', '/login'),
              _buildFooterLink(context, 'New Registration', '/register'),
              _buildFooterLink(context, 'Privacy Policy', '/privacy-policy'),
              _buildFooterLink(context, 'Contact & Support', '/privacy-contact'),
              _buildWhatsAppFooterLink(context),
              _buildFooterLink(context, 'Delete Account Request', '/delete-account'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileTabletColumns(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFD4AF37),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipOval(
                child: Container(
                  color: Colors.white,
                  child: Image.asset(
                    'assets/images/vankar_samaj_official_emblem.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.temple_hindu,
                      color: Color(0xFFA4143D),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Gujarat Vankar Samaj',
                  style: TextStyle(
                    color: Color(0xFF101B36),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'એક સમાજ, એક વિચાર, એક પરિવાર',
                  style: TextStyle(
                    color: Color(0xFFA4143D),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'The unified digital portal of All Gujarat Vankar Samaj connecting families, professionals, government employees, and youth.',
          style: TextStyle(
            color: Color(0xFF4B5563),
            fontSize: 12,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 24),

        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            SizedBox(
              width: 160,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildColumnHeading('Core Portals'),
                  _buildFooterLink(context, 'Home', '/main-poster'),
                  _buildFooterLink(context, 'Matrimony', '/home'),
                  _buildFooterLink(context, 'Govt. Employees', '/government-employees'),
                  _buildFooterLink(context, 'Private Job', '/private-employees'),
                  _buildFooterLink(context, 'Samaj Services', '/samaj-services'),
                ],
              ),
            ),
            SizedBox(
              width: 160,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildColumnHeading('Initiatives'),
                  _buildFooterLink(context, 'Pavan Prernadata', '/pavan-prernadata'),
                  _buildFooterLink(context, 'Super Stars', '/samaj-super-stars-poster'),
                  _buildFooterLink(context, 'Directory', '/family-details'),
                  _buildFooterLink(context, 'Statistics', '/statistics'),
                ],
              ),
            ),
            SizedBox(
              width: 160,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildColumnHeading('Account & Legal'),
                  _buildFooterLink(context, 'Login', '/login'),
                  _buildFooterLink(context, 'Register', '/register'),
                  _buildFooterLink(context, 'Privacy Policy', '/privacy-policy'),
                  _buildFooterLink(context, 'Contact & Support', '/privacy-contact'),
                  _buildWhatsAppFooterLink(context),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColumnHeading(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFA4143D),
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildFooterLink(BuildContext context, String text, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: InkWell(
        onTap: () {
          if (route == '/main-poster') {
            context.go('/main-poster');
          } else {
            context.push(route);
          }
        },
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }

  void _openWhatsAppHelp() async {
    const phone = '919426543166';
    const text = 'નમસ્તે, મને અખિલ ગુજરાત વણકર સમાજ પોર્ટલ વિશે સહાયની જરૂર છે.';
    final url = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(text)}');
    try {
      if (kIsWeb) {
        await launchUrl(url, webOnlyWindowName: '_blank');
        return;
      }
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Widget _buildWhatsAppFooterLink(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: InkWell(
        onTap: _openWhatsAppHelp,
        borderRadius: BorderRadius.circular(4),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            WhatsAppIcon(size: 15, color: Color(0xFF25D366)),
            SizedBox(width: 6),
            Text(
              'WhatsApp Support',
              style: TextStyle(
                color: Color(0xFF16A34A),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final year = DateTime.now().year;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EDE6),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFD6A34A).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: Text(
          '© $year All Gujarat Vankar Samaj. All rights reserved. • Unity • Identity • Progress',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 11.5,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
