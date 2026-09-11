import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';

class ParganaOverviewScreen extends StatelessWidget {
  const ParganaOverviewScreen({super.key});

  void _showParganaModal(BuildContext context, String title, String details) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF041126),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.temple_buddhist, color: Color(0xFFD4AF37)),
            const SizedBox(width: 8),
            Text(
              '$title પરગણાં',
              style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              details,
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
            const Text(
              '• કુલ ગામો: ૪૫+\n• વસતી: ૧૫,૦૦૦+\n• નોંધાયેલ સંબંધ પ્રોફાઈલ્સ: ૨૫૦+',
              style: TextStyle(color: Color(0xFFFFD700), fontSize: 12, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('બંધ કરો (Close)', style: TextStyle(color: Color(0xFFD4AF37))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/search');
            },
            child: const Text('પ્રોફાઈલ જુઓ (View Profiles)'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF01060E),
      body: SafeArea(
        child: Center(
          child: AspectRatio(
            aspectRatio: 1024 / 1535,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;

                return Stack(
                  children: [
                    // 1. Full Master Layout Image (Exact 1:1 match of WhatsApp Image 2026-09-08 at 10.08.42 PM.jpeg)
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/template_pargana.jpg',
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/images/WhatsApp Image 2026-09-08 at 10.08.42 PM.jpeg',
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),

                    // 2. Top Back Button (←)
                    Positioned(
                      left: w * 0.02,
                      top: h * 0.015,
                      width: w * 0.12,
                      height: h * 0.05,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              context.go('/home');
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.4),
                              border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFFD4AF37),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 3. Medallion 1: 35 પરગણાં (Blue - Top Left)
                    Positioned(
                      left: w * 0.05,
                      top: h * 0.67,
                      width: w * 0.28,
                      height: h * 0.16,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(60),
                          onTap: () => _showParganaModal(
                            context,
                            '35',
                            'ઉત્તર ગુજરાત 35 પરગણાં વણકર સમાજ સમિતિ અને સભ્ય માહિતી.',
                          ),
                        ),
                      ),
                    ),

                    // 4. Medallion 2: 27 પરગણાં (Green - Top Center)
                    Positioned(
                      left: w * 0.36,
                      top: h * 0.67,
                      width: w * 0.28,
                      height: h * 0.16,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(60),
                          onTap: () => _showParganaModal(
                            context,
                            '27',
                            'મધ્ય ગુજરાત 27 પરગણાં વણકર સમાજ મંડળ.',
                          ),
                        ),
                      ),
                    ),

                    // 5. Medallion 3: 16 પરગણાં (Brown - Top Right)
                    Positioned(
                      left: w * 0.67,
                      top: h * 0.67,
                      width: w * 0.28,
                      height: h * 0.16,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(60),
                          onTap: () => _showParganaModal(
                            context,
                            '16',
                            'ચરોતર 16 પરગણાં વણકર સમાજ વિકાસ ટ્રસ્ટ.',
                          ),
                        ),
                      ),
                    ),

                    // 6. Medallion 4: 14 પરગણાં (Purple - Bottom Left)
                    Positioned(
                      left: w * 0.20,
                      top: h * 0.83,
                      width: w * 0.28,
                      height: h * 0.15,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(60),
                          onTap: () => _showParganaModal(
                            context,
                            '14',
                            'દક્ષિણ ગુજરાત 14 પરગણાં વણકર સમાજ પરિષદ.',
                          ),
                        ),
                      ),
                    ),

                    // 7. Medallion 5: Other પરગણાં (Teal - Bottom Right)
                    Positioned(
                      left: w * 0.52,
                      top: h * 0.83,
                      width: w * 0.28,
                      height: h * 0.15,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(60),
                          onTap: () => _showParganaModal(
                            context,
                            'Other',
                            'અન્ય પરગણાં અને વિદેશમાં વસતા વણકર સમાજ બંધુઓ.',
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

