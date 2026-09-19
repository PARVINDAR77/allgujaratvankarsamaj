import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/vankar_header.dart';

class MatrimonialListingScreen extends StatelessWidget {
  final String categoryId;
  
  const MatrimonialListingScreen({
    super.key,
    this.categoryId = 'all',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      body: SafeArea(
        child: Column(
          children: [
            const VankarHeader(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.engineering, size: 64, color: Color(0xFF0056D2)),
                    const SizedBox(height: 16),
                    const Text(
                      'NEW UNIVERSAL MATRIMONIAL LISTING SYSTEM',
                      style: TextStyle(
                        color: Color(0xFF0056D2),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Currently building Clean Architecture layers...\n(No fake data is being displayed)',
                      style: TextStyle(color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                      child: const Text('Go Back'),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
