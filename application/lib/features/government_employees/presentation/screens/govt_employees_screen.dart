import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/govt_employee_model.dart';
import '../providers/govt_employees_provider.dart';

class GovtEmployeesScreen extends StatelessWidget {
  const GovtEmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020B18),
      body: SafeArea(
        child: Stack(
          children: [
            // Full Screen Poster Graphic (5 (1).jpeg)
            Positioned.fill(
              child: SingleChildScrollView(
                child: Image.asset(
                  'assets/images/govt_employees_poster.jpeg',
                  fit: BoxFit.fitWidth,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/5.jpeg',
                    fit: BoxFit.fitWidth,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'layoutimages/5 (1).jpeg',
                      fit: BoxFit.fitWidth,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
            ),

            // Top-Left Floating Back Button
            Positioned(
              top: 16,
              left: 16,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/login');
                    }
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF041126), Color(0xFF0A2246)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFFD4AF37),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_rounded, color: Color(0xFFD4AF37), size: 20),
                        SizedBox(width: 8),
                        Text(
                          'પાછા જાઓ (Back)',
                          style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
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
