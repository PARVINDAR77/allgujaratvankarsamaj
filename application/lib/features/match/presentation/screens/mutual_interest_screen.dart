import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/pargana_footer_bar.dart';
import '../../../../shared/widgets/vankar_header.dart';

class MutualInterestScreen extends ConsumerWidget {
  const MutualInterestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Standard Vankar Header
            const VankarHeader(subtitle: '“એક સમાજ, એક વિચાર, એક પરિવાર”'),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                child: Column(
                  children: [
                    // Header: 🤝 ❤ Mutual Interest ❤ 🤝 / પરસ્પર પસંદગી
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.handshake, color: AppColors.secondary, size: 22),
                        SizedBox(width: 6),
                        Icon(Icons.favorite, color: AppColors.secondary, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Mutual Interest',
                          style: TextStyle(
                            color: AppColors.secondary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.favorite, color: AppColors.secondary, size: 18),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 24, height: 1, color: AppColors.secondary),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'પરસ્પર પસંદગી',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(width: 24, height: 1, color: AppColors.secondary),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Main 3-Part Card: Groom (Left) | Couple Photo (Center) | Bride (Right)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF041026),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Groom Card (Left)
                              Expanded(
                                flex: 4,
                                child: _buildCandidateCard(
                                  name: 'HEMANTKUMAR\nKAPADIYA',
                                  education: 'Er',
                                  location: 'Himatnagar',
                                  occupation: 'Engineer',
                                  income: '7:00 Lakh',
                                  ageHeight: 'Age: 27 Years, 5\'7"',
                                  isMale: true,
                                ),
                              ),

                              const SizedBox(width: 4),

                              // Center Wedding Couple Photo Frame
                              Expanded(
                                flex: 5,
                                child: Container(
                                  height: 270,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.secondary, width: 2),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      'assets/images/mutual_couple.jpg',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/images/WhatsApp Image 2026-09-08 at 10.08.42 PM (2).jpeg',
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 4),

                              // Bride Card (Right)
                              Expanded(
                                flex: 4,
                                child: _buildCandidateCard(
                                  name: 'HIRALBEN\nKAPADIYA',
                                  education: null,
                                  location: 'Idar',
                                  occupation: 'Teacher',
                                  income: '7:00 Lakh',
                                  ageHeight: 'Age: 24 Years, 5\'3"',
                                  isMale: false,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Status Confirmation Banner with Center Handshake
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF031633),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6), width: 1),
                            ),
                            child: Row(
                              children: [
                                // Left Status Message
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: const [
                                      Text(
                                        'બંનેને પસંદ કર્યું છે',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        'પરસ્પર પસંદગી પુષ્ટિ થઈ',
                                        style: TextStyle(
                                          color: AppColors.goldLight,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        'Mutual Interest Confirmed',
                                        style: TextStyle(
                                          color: Color(0xFF81C784),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),

                                // Center Handshake Medallion
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppColors.goldGradient,
                                    border: Border.all(color: Colors.white, width: 1.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.secondary.withValues(alpha: 0.4),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.handshake,
                                    color: Colors.black87,
                                    size: 24,
                                  ),
                                ),

                                // Right Status Message
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: const [
                                      Text(
                                        'બંને ખૂબ ખુશ છે',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        'આગળ વધવા તૈયાર છે',
                                        style: TextStyle(
                                          color: AppColors.goldLight,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        'Both are happy to take next step',
                                        style: TextStyle(
                                          color: Color(0xFF81C784),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 3 Distinct Action Buttons (Send Message | Call Now | View Families)
                    Row(
                      children: [
                        // 1. Send Message (Green)
                        Expanded(
                          child: _buildActionPill(
                            icon: Icons.chat_bubble,
                            title: 'Send Message',
                            subtitle: 'સંદેશ મોકલો',
                            color: AppColors.buttonGreen,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Opening Chat thread with Hemantkumar & Hiralben...')),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 6),

                        // 2. Call Now (Blue)
                        Expanded(
                          child: _buildActionPill(
                            icon: Icons.call,
                            title: 'Call Now',
                            subtitle: 'હવે કોલ કરો',
                            color: AppColors.buttonBlue,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Calling +91 98765 43210...')),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 6),

                        // 3. View Families (Purple) -> Navigates to Family Details!
                        Expanded(
                          child: _buildActionPill(
                            icon: Icons.groups,
                            title: 'View Families',
                            subtitle: 'પરિવાર જુઓ',
                            color: AppColors.buttonPurple,
                            onTap: () => context.push('/family-details'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Quick Pargana Bar
                    ParganaFooterBar(
                      onParganaTap: (pargana) => context.push('/pargana-overview'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateCard({
    required String name,
    String? education,
    required String location,
    required String occupation,
    required String income,
    required String ageHeight,
    required bool isMale,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF031633),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
      ),
      child: Column(
        children: [
          // Top Verified Shield Checkmark
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2E7D32),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 14),
          ),
          const SizedBox(height: 6),

          // Name
          Text(
            name,
            style: const TextStyle(
              color: AppColors.goldLight,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          Container(width: 24, height: 1, color: AppColors.secondary),
          const SizedBox(height: 6),

          // Education
          if (education != null) ...[
            _buildDetailRow(Icons.school, education),
            const SizedBox(height: 4),
          ],

          // Location
          _buildDetailRow(Icons.location_on, location),
          const SizedBox(height: 4),

          // Occupation
          _buildDetailRow(Icons.work, occupation),
          const SizedBox(height: 4),

          // Income
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('₹', style: TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(width: 3),
              Flexible(
                child: Column(
                  children: [
                    const Text('Year Income', style: TextStyle(color: Colors.white70, fontSize: 8)),
                    Text(income, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Age & Height Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white24, width: 0.8),
            ),
            child: Text(
              ageHeight,
              style: const TextStyle(color: Colors.white70, fontSize: 8),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.secondary, size: 12),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionPill({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 3),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
