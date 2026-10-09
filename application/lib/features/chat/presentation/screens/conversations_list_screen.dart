import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/chat_provider.dart';

class ConversationsListScreen extends ConsumerWidget {
  const ConversationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text(
          'વાતચીત અને સંદેશા (Messages)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'રિફ્રેશ કરો (Refresh)',
            onPressed: () => ref.read(conversationsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: conversationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text('ચેટ લોડ થઈ શકી નથી: $err', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(conversationsProvider.notifier).refresh(),
                child: const Text('ફરી પ્રયાસ કરો (Retry)'),
              ),
            ],
          ),
        ),
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0056D2).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.forum_outlined,
                        size: 56,
                        color: Color(0xFF0056D2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'હજુ સુધી કોઈ સક્રિય ચેટ નથી',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'જ્યારે તમે કોઈ ઉમેદવારને કનેક્શન વિનંતી મોકલો અને તેઓ સ્વીકારે, અથવા કોઈની વિનંતી તમે સ્વીકારો, ત્યારે તમે અહીં તેમની સાથે સીધી વાતચીત કરી શકશો.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13.5, color: Colors.grey.shade600, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/search-results'),
                      icon: const Icon(Icons.search_rounded),
                      label: const Text('ઉમેદવારો શોધો (Browse Candidates)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0056D2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(conversationsProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: conversations.length,
              separatorBuilder: (_, __) => Divider(height: 1, indent: 80, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                final conv = conversations[index];
                final isGirl = conv.isFemale;
                final primaryColor = isGirl ? const Color(0xFFC2185B) : const Color(0xFF0056D2);
                final lightColor = isGirl ? const Color(0xFFFCE4EC) : const Color(0xFFE3F2FD);

                final timeStr = conv.lastMessageAt != null
                    ? DateFormat('dd MMM, hh:mm a').format(conv.lastMessageAt!)
                    : '';

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  tileColor: conv.unreadCount > 0 ? primaryColor.withValues(alpha: 0.04) : Colors.white,
                  onTap: () {
                    context.push(
                      '/chat/${conv.id}',
                      extra: {
                        'partnerName': conv.partnerName,
                        'partnerPhotoUrl': conv.partnerPhotoUrl,
                        'partnerGender': conv.partnerGender,
                      },
                    );
                  },
                  leading: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isGirl ? const Color(0xFFF48FB1) : const Color(0xFF90CAF9),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: lightColor,
                          backgroundImage: conv.partnerPhotoUrl != null ? NetworkImage(conv.partnerPhotoUrl!) : null,
                          child: conv.partnerPhotoUrl == null
                              ? Icon(isGirl ? Icons.face_3_rounded : Icons.face_rounded, size: 28, color: primaryColor)
                              : null,
                        ),
                      ),
                      if (conv.unreadCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${conv.unreadCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          conv.partnerName,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: conv.unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (timeStr.isNotEmpty)
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 11,
                            color: conv.unreadCount > 0 ? primaryColor : Colors.grey.shade500,
                            fontWeight: conv.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            conv.lastMessage ?? 'નવો કનેક્શન સ્વીકારાયો! વાતચીત શરૂ કરો.',
                            style: TextStyle(
                              fontSize: 13,
                              color: conv.unreadCount > 0 ? Colors.black87 : Colors.grey.shade600,
                              fontWeight: conv.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
