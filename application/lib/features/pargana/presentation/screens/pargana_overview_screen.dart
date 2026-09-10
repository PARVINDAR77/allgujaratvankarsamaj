import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/vankar_header.dart';

class ParganaOverviewScreen extends StatelessWidget {
  const ParganaOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Standard Vankar Header
            VankarHeader(
              subtitle: '“એક સમાજ. એક વિશ્વાસ. એક પરિવાર.”',
              showBackButton: true,
              onBackPressed: () => Navigator.of(context).maybePop(),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                child: Column(
                  children: [
                    // Main Serene Artwork Container (Buddha in Forest)
                    Container(
                      height: 330,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder, width: 2),
                        color: const Color(0xFF041026),
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
                          'assets/images/template_pargana.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Image.asset(
                            'assets/images/WhatsApp Image 2026-09-08 at 10.08.42 PM.jpeg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Top Row of 3 Medallions: 35 | 27 | 16
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTempleMedallion(
                          count: '35',
                          label: 'પરગણા',
                          color: AppColors.pillPargana35,
                          onTap: () => _showParganaDetails(context, '35'),
                        ),
                        _buildTempleMedallion(
                          count: '27',
                          label: 'પરગણા',
                          color: AppColors.pillPargana27,
                          onTap: () => _showParganaDetails(context, '27'),
                        ),
                        _buildTempleMedallion(
                          count: '16',
                          label: 'પરગણા',
                          color: AppColors.pillPargana16,
                          onTap: () => _showParganaDetails(context, '16'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Bottom Row of 2 Medallions: 14 | Other
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTempleMedallion(
                          count: '14',
                          label: 'પરગણા',
                          color: AppColors.pillPargana14,
                          onTap: () => _showParganaDetails(context, '14'),
                        ),
                        const SizedBox(width: 24),
                        _buildTempleMedallion(
                          count: 'Other',
                          label: 'પરગણા',
                          color: AppColors.pillParganaOther,
                          onTap: () => _showParganaDetails(context, 'Other'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTempleMedallion({
    required String count,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(46),
      child: Container(
        width: 92,
        height: 92,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.goldGradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  count,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.goldLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                const Icon(
                  Icons.temple_buddhist,
                  color: AppColors.secondary,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showParganaDetails(BuildContext context, String pargana) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.cardNavy,
        content: Text(
          'Viewing $pargana Pargana community directory & statistics...',
          style: const TextStyle(color: AppColors.goldLight),
        ),
      ),
    );
  }
}
