import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';

class VerifiedProfileScreen extends StatelessWidget {
  const VerifiedProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.paddingOf(context);
    final availableHeight = size.height - padding.top - padding.bottom;
    final isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFF020B18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF041126),
        title: const Text('Verified Profile Details', style: TextStyle(color: Color(0xFFFFD700), fontSize: 16)),
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD4AF37), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.25),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/5 (6).jpeg',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) => Image.asset(
                              'assets/images/5 (6).jpeg',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          Container(
                            color: const Color(0xFF041126),
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      if (context.canPop()) {
                                        context.pop();
                                      } else {
                                        context.go('/profile');
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(25),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        gradient: AppColors.goldGradient,
                                        borderRadius: BorderRadius.circular(25),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.secondary.withValues(alpha: 0.5),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.arrow_back_rounded, color: Colors.black87, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'પાછા જાઓ (Back)',
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                StatefulBuilder(
                                  builder: (context, setState) {
                                    bool isLiked = false;
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          isLiked = !isLiked;
                                        });
                                        if (isLiked) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('You liked this profile! (તમે આ પ્રોફાઇલ પસંદ કરી છે!)'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(25),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white10,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.secondary, width: 1.5),
                                        ),
                                        child: Icon(
                                          isLiked ? Icons.favorite : Icons.favorite_border,
                                          color: isLiked ? Colors.red : AppColors.secondary,
                                          size: 24,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
