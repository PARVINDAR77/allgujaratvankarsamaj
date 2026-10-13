import 'package:flutter/material.dart';

/// A lightweight, responsive container that centers its content and constrains
/// its maximum width on desktop and tablet screens, while remaining full-width
/// and zero-overhead on mobile devices.
class ResponsiveCenterBox extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry? padding;

  const ResponsiveCenterBox({
    super.key,
    required this.child,
    this.maxWidth = 1080.0,
    this.alignment = Alignment.topCenter,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null ? Padding(padding: padding!, child: child) : child,
      ),
    );
  }
}
