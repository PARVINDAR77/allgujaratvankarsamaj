import 'package:flutter/material.dart';

class MutualInterestScreen extends StatelessWidget {
  const MutualInterestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040A18),
      appBar: AppBar(
        title: const Text('Mutual Interest (પરસ્પર રુચિ)', style: TextStyle(color: Color(0xFFFFD700))),
        backgroundColor: const Color(0xFF041126),
        iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.favorite_border,
                  size: 80,
                  color: Color(0xFFD81B60),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No Matches Yet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'હજી સુધી કોઈ પરસ્પર રુચિ મળી નથી.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  '* Note: The matchmaking algorithm is pending backend integration.',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
