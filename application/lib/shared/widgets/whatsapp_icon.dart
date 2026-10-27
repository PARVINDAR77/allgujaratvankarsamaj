import 'package:flutter/material.dart';

class WhatsAppIcon extends StatelessWidget {
  final double size;
  final Color color;

  const WhatsAppIcon({
    super.key,
    this.size = 28,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/whatsapp_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
    );
  }
}
