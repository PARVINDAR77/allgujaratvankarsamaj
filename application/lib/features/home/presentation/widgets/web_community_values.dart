import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/view_badge.dart';
import '../providers/views_provider.dart';

class ValueItemData {
  final String title;
  final String subtitle;
  final IconData icon;
  final String sectionName;
  final VoidCallback Function(BuildContext context, WidgetRef ref) onAction;

  const ValueItemData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.sectionName,
    required this.onAction,
  });
}

class WebCommunityValues extends ConsumerWidget {
  const WebCommunityValues({super.key});

  static final List<ValueItemData> values = [
    ValueItemData(
      title: 'Education',
      subtitle: 'for Better Tomorrow',
      icon: Icons.menu_book_rounded,
      sectionName: 'HOME_EDUCATION',
      onAction: (context, ref) => () {
        ref.read(incrementViewProvider)('HOME_EDUCATION');
        context.push('/education');
      },
    ),
    ValueItemData(
      title: 'Unity',
      subtitle: 'in Diversity',
      icon: Icons.groups_rounded,
      sectionName: 'HOME_UNITY',
      onAction: (context, ref) => () {
        ref.read(incrementViewProvider)('HOME_UNITY');
        context.push('/advertisement?section=HOME_UNITY');
      },
    ),
    ValueItemData(
      title: 'Progress',
      subtitle: 'Through Support',
      icon: Icons.insights_rounded,
      sectionName: 'HOME_PROGRESS',
      onAction: (context, ref) => () {
        ref.read(incrementViewProvider)('HOME_PROGRESS');
        context.push('/statistics');
      },
    ),
    ValueItemData(
      title: 'Service',
      subtitle: 'to Society',
      icon: Icons.volunteer_activism_rounded,
      sectionName: 'HOME_SERVICE',
      onAction: (context, ref) => () {
        ref.read(incrementViewProvider)('HOME_SERVICE');
        context.push('/birthdays');
      },
    ),
    ValueItemData(
      title: 'Strong Roots',
      subtitle: 'Bright Future',
      icon: Icons.eco_rounded,
      sectionName: 'HOME_STRONG_ROOTS',
      onAction: (context, ref) => () {
        ref.read(incrementViewProvider)('HOME_STRONG_ROOTS');
        context.push('/advertisement?section=HOME_STRONG_ROOTS');
      },
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1050;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFAF8F5),
            Color(0xFFFFFFFF),
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 36 : 18,
        vertical: 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Golden Divider Banner: Join Our Community • Build A Better Tomorrow
              _buildGoldenDivider(),
              const SizedBox(height: 36),

              // 2. Five Community Values (Circle Badges with Live View Counter)
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: values.map((val) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: _ValueBadgeWidget(val: val),
                      ),
                    );
                  }).toList(),
                )
              else
                Wrap(
                  spacing: 16,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: values.map((val) {
                    return SizedBox(
                      width: width >= 600 ? 160 : (width - 60) / 2,
                      child: _ValueBadgeWidget(val: val),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoldenDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1.2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFFD6A34A).withOpacity(0.7),
                  const Color(0xFFFFD700),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wb_sunny_rounded, color: Color(0xFFD6A34A), size: 16),
              const SizedBox(width: 8),
              const Text(
                'Join Our Community  •  Build A Better Tomorrow',
                style: TextStyle(
                  color: Color(0xFF101B36),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.wb_sunny_rounded, color: Color(0xFFD6A34A), size: 16),
            ],
          ),
        ),
        Expanded(
          child: Container(
            height: 1.2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFD700),
                  const Color(0xFFD6A34A).withOpacity(0.7),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ValueBadgeWidget extends ConsumerStatefulWidget {
  final ValueItemData val;

  const _ValueBadgeWidget({required this.val});

  @override
  ConsumerState<_ValueBadgeWidget> createState() => _ValueBadgeWidgetState();
}

class _ValueBadgeWidgetState extends ConsumerState<_ValueBadgeWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final v = widget.val;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: v.onAction(context, ref),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0.0, _isHovered ? -5.0 : 0.0, 0.0),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFFF9F5EC) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? const Color(0xFFD6A34A) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Login Page Inspired Velvet Maroon & Gold Medallion
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFA4143D),
                      Color(0xFF6B0E27),
                    ],
                  ),
                  border: Border.all(
                    color: _isHovered
                        ? const Color(0xFFFFDF73)
                        : const Color(0xFFD6A34A),
                    width: 2.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFA4143D)
                          .withValues(alpha: _isHovered ? 0.55 : 0.3),
                      blurRadius: _isHovered ? 16 : 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    v.icon,
                    color: const Color(0xFFFFDF73),
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                v.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF101B36),
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),

              // Subtitle
              Text(
                v.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 11.5,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),

              // Live View Badge
              IgnorePointer(
                child: ViewBadge(sectionName: v.sectionName),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
