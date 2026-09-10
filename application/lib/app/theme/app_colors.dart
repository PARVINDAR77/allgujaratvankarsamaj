import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF061121); // Deep dark blue background
  static const Color onPrimary = Color(0xFFFFD700); // Gold text/icons on primary
  static const Color primaryContainer = Color(0xFF0F2540); // Slightly lighter blue for cards
  static const Color onPrimaryContainer = Color(0xFFFFD700);

  // Secondary colors
  static const Color secondary = Color(0xFFD4AF37); // Metallic gold
  static const Color onSecondary = Color(0xFF000000); // Black text on gold
  static const Color secondaryContainer = Color(0xFF8C7326);
  static const Color onSecondaryContainer = Color(0xFFFFFFFF);

  // Background and surface
  static const Color background = Color(0xFF020B1A); // Midnight navy blue
  static const Color onBackground = Color(0xFFE0E0E0);
  static const Color surface = Color(0xFF061121);
  static const Color onSurface = Color(0xFFE0E0E0);
  static const Color textPrimary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textLight = Color(0xFF777777);
  static const Color cardBorder = Color(0xFFC8A14D); // Warm metallic gold border

  // Status & Utility Colors
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFED6C02);

  // Template Specific Action & Badge Colors
  static const Color goldAccent = Color(0xFFE5B942);
  static const Color goldLight = Color(0xFFFFF3A3);
  static const Color goldDark = Color(0xFF8C7326);
  static const Color cardBackground = Color(0xFF041026);
  static const Color cardNavy = Color(0xFF061633);
  static const Color buttonPurple = Color(0xFF4A154B);
  static const Color buttonGreen = Color(0xFF1E6B37);
  static const Color buttonBlue = Color(0xFF1565C0);
  
  // Pargana Badges
  static const Color pillPargana35 = Color(0xFF0D284B);
  static const Color pillPargana27 = Color(0xFF1B4D2E);
  static const Color pillPargana16 = Color(0xFF5C3B1E);
  static const Color pillPargana14 = Color(0xFF3B1E5C);
  static const Color pillParganaOther = Color(0xFF004D40);

  // Trust & Verification Badges
  static const Color badgeGreen = Color(0xFF2EB85C);
  static const Color badgeBlue = Color(0xFF1976D2);
  static const Color badgePurple = Color(0xFF7B1FA2);

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFE082), Color(0xFFD4AF37), Color(0xFFA67C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient navyCardGradient = LinearGradient(
    colors: [Color(0xFF071B38), Color(0xFF030E22)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
