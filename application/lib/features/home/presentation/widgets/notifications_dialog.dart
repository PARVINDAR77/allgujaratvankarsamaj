import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/notifications_provider.dart';

void showNotificationsDialog(BuildContext context, WidgetRef ref) {
  // Refresh notifications from server and mark all as read
  ref.read(notificationsProvider.notifier).refresh();
  ref.read(notificationsProvider.notifier).markAllAsRead();

  showDialog(
    context: context,
    builder: (ctx) => const _NotificationsDialogContent(),
  );
}

class _NotificationsDialogContent extends ConsumerWidget {
  const _NotificationsDialogContent();

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'હમણાં જ (Just now)';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} મિનિટ પહેલાં';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} કલાક પહેલાં';
    } else if (difference.inDays == 1) {
      return 'ગઈકાલે (Yesterday)';
    } else {
      return DateFormat('dd MMM, yyyy').format(time);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Dialog(
      backgroundColor: const Color(0xFF041126),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dialog Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0x33D4AF37), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active,
                      color: Color(0xFFD4AF37),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'સૂચનાઓ (Notifications)',
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    tooltip: 'બંધ કરો (Close)',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Dialog Content (List or Empty State)
            Flexible(
              child: notifications.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.notifications_none,
                              color: Color(0xFFD4AF37),
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'હાલમાં કોઈ નવી સૂચના નથી',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'જ્યારે તમારા માટે કોઈ નવી સૂચના, સંબંધ મેળ અથવા અપડેટ આવશે ત્યારે અહીં દર્શાવવામાં આવશે.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) => const Divider(
                        color: Color(0x1AD4AF37),
                        height: 12,
                      ),
                      itemBuilder: (context, index) {
                        final notif = notifications[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            if (notif.route != null && notif.route!.isNotEmpty) {
                              Navigator.pop(context);
                              context.push(notif.route!);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: notif.isRead
                                  ? Colors.transparent
                                  : const Color(0xFFD4AF37).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: notif.isRead
                                    ? Colors.white10
                                    : const Color(0xFFD4AF37).withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    notif.icon,
                                    color: const Color(0xFFD4AF37),
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        notif.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notif.message,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _formatTime(notif.time),
                                        style: TextStyle(
                                          color: const Color(0xFFD4AF37).withValues(alpha: 0.8),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Dialog Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0x33D4AF37), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (notifications.isNotEmpty)
                    TextButton.icon(
                      icon: const Icon(Icons.delete_sweep, size: 16, color: Colors.white60),
                      label: const Text(
                        'બધું સાફ કરો (Clear)',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                      onPressed: () {
                        ref.read(notificationsProvider.notifier).clearAll();
                      },
                    )
                  else
                    const SizedBox.shrink(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'બંધ કરો (Close)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
