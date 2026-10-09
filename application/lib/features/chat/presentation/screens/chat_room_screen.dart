import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/chat_provider.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String? partnerName;
  final String? partnerPhotoUrl;
  final String? partnerGender;

  const ChatRoomScreen({
    super.key,
    required this.conversationId,
    this.partnerName,
    this.partnerPhotoUrl,
    this.partnerGender,
  });

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  final List<String> _quickTemplates = [
    'નમસ્તે 🙏',
    'કેમ છો? 😊',
    'તમારી પ્રોફાઇલ ગમી 👍',
    'શું આપણે વાતચીત આગળ વધારી શકીએ?',
    'જય શ્રી કૃષ્ણ 🌸',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend([String? presetText]) async {
    final text = presetText ?? _textController.text;
    if (text.trim().isEmpty || _isSending) return;

    if (presetText == null) {
      _textController.clear();
    }
    setState(() => _isSending = true);

    final success = await ref
        .read(chatRoomProvider(widget.conversationId).notifier)
        .sendMessage(text);

    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatRoomProvider(widget.conversationId));

    // Partner info from state or route parameters
    final partnerProfile = chatState.partnerProfile;
    final displayName = partnerProfile?['firstName'] != null
        ? '${partnerProfile!['firstName']} ${partnerProfile['lastName'] ?? ''}'.trim()
        : (widget.partnerName ?? 'Candidate Chat');
    final displayPhoto = partnerProfile?['photoUrl']?.toString() ?? widget.partnerPhotoUrl;
    final isGirl = (partnerProfile?['gender']?.toString().toUpperCase().contains('FEMALE') ?? false) ||
        (widget.partnerGender?.toUpperCase().contains('FEMALE') ?? false) ||
        displayName.toUpperCase().contains('BEN');

    final primaryColor = isGirl ? const Color(0xFFC2185B) : const Color(0xFF0056D2);
    final lightColor = isGirl ? const Color(0xFFFCE4EC) : const Color(0xFFE3F2FD);

    // Scroll bottom whenever messages change
    ref.listen(chatRoomProvider(widget.conversationId), (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: lightColor,
              backgroundImage: displayPhoto != null ? NetworkImage(displayPhoto) : null,
              child: displayPhoto == null
                  ? Icon(isGirl ? Icons.face_3_rounded : Icons.face_rounded, size: 22, color: primaryColor)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isGirl ? '👰 કન્યા • સક્રિય' : '👨 વર • સક્રિય',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black54),
            tooltip: 'રિફ્રેશ કરો (Refresh Messages)',
            onPressed: () {
              ref.read(chatRoomProvider(widget.conversationId).notifier).loadMessages();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Safe Security Notice Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              color: Colors.amber.shade50,
              child: Row(
                children: [
                  Icon(Icons.lock_outline_rounded, size: 14, color: Colors.amber.shade900),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'સુરક્ષિત સંવાદ: આ ચેટ માત્ર તમે બંને જ જોઈ શકો છો. (End-to-End Private)',
                      style: TextStyle(fontSize: 11, color: Colors.amber.shade900, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            // Message List Area
            Expanded(
              child: chatState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : chatState.messages.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline_rounded, size: 54, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text(
                                  'હજુ સુધી કોઈ સંદેશો નથી',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'નીચે આપેલા શુભેચ્છા સંદેશ પર ક્લિક કરીને વાતચીત શરૂ કરો!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          itemCount: chatState.messages.length,
                          itemBuilder: (context, index) {
                            final msg = chatState.messages[index];
                            final isMe = msg.isMe(chatState.myProfileId);
                            final timeStr = DateFormat('hh:mm a').format(msg.createdAt);

                            return Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.78,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                decoration: BoxDecoration(
                                  color: isMe ? primaryColor : Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                                    bottomRight: Radius.circular(isMe ? 4 : 16),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      msg.content,
                                      style: TextStyle(
                                        color: isMe ? Colors.white : Colors.black87,
                                        fontSize: 14.5,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          timeStr,
                                          style: TextStyle(
                                            color: isMe ? Colors.white70 : Colors.black45,
                                            fontSize: 10,
                                          ),
                                        ),
                                        if (isMe) ...[
                                          const SizedBox(width: 4),
                                          Icon(
                                            msg.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                                            size: 13,
                                            color: msg.isRead ? Colors.lightBlueAccent : Colors.white70,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),

            // Quick Preset Greeting Chips
            Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _quickTemplates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final text = _quickTemplates[index];
                  return ActionChip(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade300),
                    label: Text(text, style: const TextStyle(fontSize: 11.5, color: Colors.black87)),
                    onPressed: () => _handleSend(text),
                  );
                },
              ),
            ),
            const SizedBox(height: 6),

            // Message Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F2F5),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _textController,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          hintText: 'સંદેશો લખો... (Type a message)',
                          hintStyle: TextStyle(fontSize: 13.5, color: Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _handleSend(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.35),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: _isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: _isSending ? null : () => _handleSend(),
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
