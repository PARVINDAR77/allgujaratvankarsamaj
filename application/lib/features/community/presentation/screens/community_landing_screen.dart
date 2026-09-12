import 'package:flutter/material.dart';
import '../../../home/presentation/screens/home_screen.dart';

/// Legacy community landing screen wrapper that renders HomeScreen directly to eliminate the poster page
class CommunityLandingScreen extends StatelessWidget {
  const CommunityLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
