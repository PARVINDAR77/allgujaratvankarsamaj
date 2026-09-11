import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';

class CommunityLandingScreen extends StatelessWidget {
  const CommunityLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top Grand Header: All Gujarat VANKAR SAMAJ
              _buildGrandHeader(),
              const SizedBox(height: 16),

              // Central Spiritual Buddha Artwork & Quotes Section
              _buildCentralArtSection(),
              const SizedBox(height: 24),

              // 5 Major Community Pillars (Govt Employees, Matrimony, Private Job, Services, Students)
              _buildPillarsGrid(context),
              const SizedBox(height: 24),

              // 5 Core Values Icon Row
              _buildCoreValuesRow(),
              const SizedBox(height: 24),

              // Auth Action Buttons: Login > & Registration >
              _buildAuthButtons(context),
              const SizedBox(height: 24),

              // Grand Footer Tagline & Peacock Feathers
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrandHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          // All Gujarat Text
          const Text(
            'All Gujarat',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),

          // 3D Gold Title: VANKAR SAMAJ
          const Text(
            'VANKAR',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              shadows: [
                Shadow(color: Colors.black, offset: Offset(2, 3), blurRadius: 4),
              ],
            ),
          ),
          const Text(
            'SAMAJ',
            style: TextStyle(
              color: AppColors.goldAccent,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 6,
            ),
          ),
          const SizedBox(height: 8),

          // Gujarati Motto Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.secondary, width: 1),
            ),
            child: const Text(
              'એક સમાજ  •  એક વિશ્વાસ  •  એક પરિવાર',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),

          // English Sub-motto
          const Text(
            'UNITY  •  SERVICE  •  PROGRESS',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCentralArtSection() {
    return Container(
      height: 380,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.3),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(
          'assets/images/buddha_welcome_poster.jpg',
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            'assets/images/buddha_pargana_poster.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.primary,
              child: const Center(
                child: Icon(Icons.self_improvement, size: 70, color: AppColors.goldAccent),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPillarsGrid(BuildContext context) {
    final pillars = [
      {
        'title': 'Government\nEmployees',
        'sub': 'IAS | IPS | IFS | Officer | Teacher\nPolice | Army | Defence | Health',
        'icon': Icons.account_balance,
        'color': AppColors.error,
        'onTap': () {},
      },
      {
        'title': 'Matrimony',
        'sub': 'Find Your Life Partner\nWithin Our Samaj',
        'icon': Icons.favorite,
        'color': const Color(0xFFC2185B),
        'onTap': () => context.go('/home'), // Enters Matrimony App
      },
      {
        'title': 'Private Job',
        'sub': 'Business | Professional\nSelf Employed | Opportunities',
        'icon': Icons.business_center,
        'color': const Color(0xFF1976D2),
        'onTap': () {},
      },
      {
        'title': 'VANKAR SAMAJ\nServices',
        'sub': 'Photography | Real Estate\nOthers',
        'icon': Icons.handshake,
        'color': AppColors.pillPargana27,
        'onTap': () => context.push('/samaj-services'),
      },
      {
        'title': 'Students (12+)',
        'sub': 'Study Guidance | Career Support\nScholarship | Bright Future',
        'icon': Icons.school,
        'color': AppColors.pillPargana14,
        'onTap': () {},
      },
    ];

    return Column(
      children: [
        const Text(
          'વણકર સમાજ સેવા અને વિકાસ સેન્ટર',
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Our Community Support Pillars',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 16),

        // Grid layout of 5 Pillars
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 600;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: pillars.map((p) {
                final double width = isCompact
                    ? (constraints.maxWidth - 24) / 2
                    : (constraints.maxWidth - 48) / 3;
                return SizedBox(
                  width: width < 150 ? 150 : width,
                  child: _buildPillarCard(
                    title: p['title'] as String,
                    sub: p['sub'] as String,
                    icon: p['icon'] as IconData,
                    color: p['color'] as Color,
                    onTap: p['onTap'] as VoidCallback,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPillarCard({
    required String title,
    required String sub,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.secondary, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoreValuesRow() {
    final values = [
      {'icon': Icons.menu_book, 'title': 'Education', 'sub': 'for Better Tomorrow'},
      {'icon': Icons.groups, 'title': 'Unity', 'sub': 'in Diversity'},
      {'icon': Icons.trending_up, 'title': 'Progress', 'sub': 'Through Support'},
      {'icon': Icons.favorite, 'title': 'Service', 'sub': 'to Society'},
      {'icon': Icons.eco, 'title': 'Strong Roots', 'sub': 'Bright Future'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: values.map((v) {
          return Expanded(
            child: Column(
              children: [
                Icon(v['icon'] as IconData, color: AppColors.secondary, size: 20),
                const SizedBox(height: 4),
                Text(
                  v['title'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  v['sub'] as String,
                  style: const TextStyle(color: Colors.white60, fontSize: 8),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAuthButtons(BuildContext context) {
    return Row(
      children: [
        // Shiny Blue Login > Button
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => context.go('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              icon: const Icon(Icons.person, color: Colors.white, size: 20),
              label: const Text(
                'Login  >',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Shiny Green Registration > Button
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () => context.go('/register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              icon: const Icon(Icons.person_add, color: Colors.white, size: 20),
              label: const Text(
                'Registration  >',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.brightness_5, color: AppColors.secondary, size: 16),
            SizedBox(width: 8),
            Text(
              'એક સમાજ  |  એક વિશ્વાસ  |  એક પરિવાર',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.brightness_5, color: AppColors.secondary, size: 16),
          ],
        ),
        const SizedBox(height: 2),
        const Text(
          '— All Gujarat Vankar Samaj —',
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Our Heritage\nOur Values',
              style: TextStyle(color: AppColors.goldAccent, fontSize: 10),
            ),
            Text(
              'Our Future\nOur Responsibility',
              style: TextStyle(color: AppColors.goldAccent, fontSize: 10),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ],
    );
  }
}
