import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SamajSuperStarsPosterScreen extends StatelessWidget {
  const SamajSuperStarsPosterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full-screen responsive image
          Positioned.fill(
            child: Image.asset(
              'assets/images/samaj_super_stars_poster.jpeg',
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
          ),

          // Gradient overlay at top for back button visibility
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
          ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 12,
            child: GestureDetector(
              onTap: () => context.canPop() ? context.pop() : context.go('/main-poster'),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
              ),
            ),
          ),

          // Title banner at top center
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 60,
            right: 60,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.6), width: 1),
                ),
                child: const Text(
                  '⭐ Samaj Super Stars',
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // Bottom gradient overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),
          ),

          // Bottom close button
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => context.canPop() ? context.pop() : context.go('/main-poster'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.close, color: Colors.black, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'બંધ કરો',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
    );
  }
}
