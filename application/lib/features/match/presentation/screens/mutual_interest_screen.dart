import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../profile/providers/profile_provider.dart';
import '../../../../shared/models/profile_model.dart';

class MutualInterestScreen extends ConsumerWidget {
  const MutualInterestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profileNotifierProvider);
    final bride = profiles.where((p) => p.gender.contains('Female')).toList().firstOrNull;
    final groom = profiles.where((p) => p.gender.contains('Male')).toList().firstOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFF040A18),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double imageWidth = constraints.maxWidth;
            final double imageHeight = imageWidth * (2322 / 1080);

            return Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: imageWidth,
                  height: imageHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/mutual_interest_bg.jpg',
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFF040A18),
                          child: const Center(
                            child: Text(
                              'Background Image Missing',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),

                      // Bride Name Ribbon Cover-Up (Left)
                      Positioned(
                        top: imageHeight * 0.575,
                        left: imageWidth * 0.042,
                        width: imageWidth * 0.448,
                        height: imageHeight * 0.027,
                        child: _buildNameCover(
                          color: const Color(0xFFD81B60),
                          name: bride != null ? bride.fullName : 'Hiral Kapadiya',
                        ),
                      ),
                      
                      // Bride Details Cover-Up
                      Positioned(
                        top: imageHeight * 0.608,
                        left: imageWidth * 0.055,
                        width: imageWidth * 0.422,
                        height: imageHeight * 0.075,
                        child: _buildDetailsCover(
                          profession: bride != null ? bride.designation : 'Teacher',
                          age: bride != null ? _calculateAge(bride.dateOfBirth) : '24 Years',
                          income: 'Not Disclosed',
                          city: bride != null ? bride.district : 'Idar',
                        ),
                      ),

                      // Groom Name Ribbon Cover-Up (Right)
                      Positioned(
                        top: imageHeight * 0.575,
                        right: imageWidth * 0.042,
                        width: imageWidth * 0.448,
                        height: imageHeight * 0.027,
                        child: _buildNameCover(
                          color: const Color(0xFF0D47A1),
                          name: groom != null ? groom.fullName : 'Hemant Kapadiya',
                        ),
                      ),
                      
                      // Groom Details Cover-Up
                      Positioned(
                        top: imageHeight * 0.608,
                        right: imageWidth * 0.055,
                        width: imageWidth * 0.422,
                        height: imageHeight * 0.075,
                        child: _buildDetailsCover(
                          profession: groom != null ? groom.designation : 'Engineer (Ele)',
                          age: groom != null ? _calculateAge(groom.dateOfBirth) : '25 Years',
                          income: 'Not Disclosed',
                          city: groom != null ? groom.district : 'Himatnagar',
                        ),
                      ),

                      // Back Button
                      Positioned(
                        top: 16,
                        left: 16,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                          onPressed: () {
                            if (context.canPop()) context.pop();
                            else context.go('/home');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNameCover({required Color color, required String name}) {
    return Container(
      color: color,
      alignment: Alignment.center,
      child: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDetailsCover({required String profession, required String age, required String income, required String city}) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(child: _buildDetailRow(Icons.work, 'Profession', profession)),
          Expanded(child: _buildDetailRow(Icons.person, 'Age', age)),
          Expanded(child: _buildDetailRow(Icons.account_balance_wallet, 'Income', income)),
          Expanded(child: _buildDetailRow(Icons.location_on, 'City', city)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF040A18)),
        const SizedBox(width: 4),
        Expanded(
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label  :  ',
                  style: const TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _calculateAge(String dob) {
    if (dob.isEmpty) return '25 Years';
    try {
      final birthDate = DateTime.parse(dob);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return '$age Years';
    } catch (e) {
      return '25 Years';
    }
  }
}
