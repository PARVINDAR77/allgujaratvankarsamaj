import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';

/// UI convenience widget — only renders [child] when the logged-in user
/// satisfies the given [condition].
///
/// ⚠️ This is a UI convenience only. Every protected API request is
/// independently authorized by NestJS. This widget does NOT replace server-side auth.
///
/// Usage:
/// ```dart
/// RoleGuardWidget(
///   condition: (user) => user.isAdmin,
///   child: AdminPanel(),
/// )
/// ```
class RoleGuardWidget extends ConsumerWidget {
  final bool Function(dynamic user) condition;
  final Widget child;
  final Widget? fallback;

  const RoleGuardWidget({
    super.key,
    required this.condition,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    if (user != null && condition(user)) {
      return child;
    }
    return fallback ?? const SizedBox.shrink();
  }
}
