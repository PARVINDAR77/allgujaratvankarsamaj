import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF020B18);
  static const Color background = Color(0xFF041126);
  static const Color cardDark = Color(0xFF07182E);
  static const Color secondary = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFFFD700);
  static const Color accentBlue = Color(0xFF1565C0);
  static const Color accentGreen = Color(0xFF2E7D32);
  static const Color accentRed = Color(0xFFC62828);

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFFFD700), Color(0xFFB8860B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF07182E), Color(0xFF041126)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
