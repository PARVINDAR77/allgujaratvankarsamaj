import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF000000); // Pure Black
  static const Color background = Color(0xFF000000); // Pure Black
  static const Color cardDark = Color(0xFF111111); // Very Dark Grey
  static const Color secondary = Color(0xFFD4AF37); // Gold
  static const Color goldLight = Color(0xFFFFD700); // Light Gold
  static const Color accentBlue = Color(0xFF1565C0);
  static const Color accentGreen = Color(0xFF2E7D32);
  static const Color accentRed = Color(0xFFC62828);

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFFFD700), Color(0xFFB8860B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF111111), Color(0xFF000000)], // Dark grey to black
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
