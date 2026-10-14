import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../shared/models/chat_models.dart';
import '../../providers/chat_provider.dart';
import '../widgets/chat_media_bubble.dart';

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
  bool _isUploading = false;
  final ImagePicker _imagePicker = ImagePicker();

  static const int _maxImageBytes = 10 * 1024 * 1024; // 10 MB
  static const int _maxVideoBytes = 25 * 1024 * 1024; // 25 MB
  static const int _maxPdfBytes = 10 * 1024 * 1024; // 10 MB

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

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : null,
      ),
    );
  }

  String _mimeFor(String fileName, ChatMediaType type) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'mp4':
      case 'm4v':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'webm':
        return 'video/webm';
      case 'pdf':
        return 'application/pdf';
    }
    switch (type) {
      case ChatMediaType.image:
        return 'image/jpeg';
      case ChatMediaType.video:
        return 'video/mp4';
      case ChatMediaType.pdf:
        return 'application/pdf';
    }
  }

  /// Ensures the uploaded file name carries an extension the server accepts.
  String _normalizeFileName(String name, ChatMediaType type) {
    final allowed = {
      ChatMediaType.image: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
      ChatMediaType.video: ['mp4', 'm4v', 'mov', 'webm'],
      ChatMediaType.pdf: ['pdf'],
    }[type]!;
    final hasExt = name.contains('.');
    final ext = hasExt ? name.split('.').last.toLowerCase() : '';
    if (allowed.contains(ext)) return name;
    final fallback = {
      ChatMediaType.image: 'jpg',
      ChatMediaType.video: 'mp4',
      ChatMediaType.pdf: 'pdf',
    }[type]!;
    return '${hasExt ? name.substring(0, name.lastIndexOf('.')) : name}.$fallback';
  }

  Future<void> _uploadAndSend({
    required Uint8List bytes,
    required String fileName,
    required ChatMediaType type,
  }) async {
    final maxBytes = type == ChatMediaType.video
        ? _maxVideoBytes
        : (type == ChatMediaType.pdf ? _maxPdfBytes : _maxImageBytes);
    if (bytes.isEmpty) {
      _showSnack('ફાઈલ ખાલી છે (File is empty)', isError: true);
      return;
    }
    if (bytes.length > maxBytes) {
      _showSnack(
        'ફાઈલ ખૂબ મોટી છે. મહત્તમ ${maxBytes ~/ (1024 * 1024)} MB (File too large, max ${maxBytes ~/ (1024 * 1024)} MB)',
        isError: true,
      );
      return;
    }

    setState(() => _isUploading = true);
    try {
      final safeName = _normalizeFileName(fileName, type);
      final url = await ref.read(chatRepositoryProvider).uploadChatMedia(
            bytes: bytes,
            fileName: safeName,
            mimeType: _mimeFor(safeName, type),
          );
      final success = await ref
          .read(chatRoomProvider(widget.conversationId).notifier)
          .sendMessage(ChatMedia.encode(type, url, safeName));
      if (success) {
        _scrollToBottom();
      } else {
        _showSnack('સંદેશો મોકલી શકાયો નથી (Could not send message)', isError: true);
      }
    } catch (e) {
      _showSnack(e.toString().replaceFirst('Exception: ', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1920,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      await _uploadAndSend(bytes: bytes, fileName: file.name, type: ChatMediaType.image);
    } catch (e) {
      _showSnack('ફોટો પસંદ કરી શકાયો નથી (Could not pick photo)', isError: true);
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? file = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 3),
      );
      if (file == null) return;
      final size = await file.length();
      if (size > _maxVideoBytes) {
        _showSnack('વિડિયો ખૂબ મોટો છે. મહત્તમ 25 MB (Video too large, max 25 MB)', isError: true);
        return;
      }
      final bytes = await file.readAsBytes();
      await _uploadAndSend(bytes: bytes, fileName: file.name, type: ChatMediaType.video);
    } catch (e) {
      _showSnack('વિડિયો પસંદ કરી શકાયો નથી (Could not pick video)', isError: true);
    }
  }

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        withData: true,
      );
      final picked = result?.files.single;
      if (picked == null) return;
      final bytes = picked.bytes;
      if (bytes == null) {
        _showSnack('PDF વાંચી શકાઈ નથી (Could not read PDF)', isError: true);
        return;
      }
      await _uploadAndSend(bytes: bytes, fileName: picked.name, type: ChatMediaType.pdf);
    } catch (e) {
      _showSnack('PDF પસંદ કરી શકાઈ નથી (Could not pick PDF)', isError: true);
    }
  }

  void _showAttachmentSheet(Color primaryColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        Widget option(IconData icon, Color color, String label, VoidCallback onTap) {
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.of(sheetContext).pop();
              onTap();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: color.withValues(alpha: 0.12),
                    child: Icon(icon, color: color, size: 26),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'ફાઈલ મોકલો (Send Attachment)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: option(Icons.photo_library_rounded, const Color(0xFF7C3AED), 'ફોટો\nPhoto',
                          () => _pickImage(ImageSource.gallery)),
                    ),
                    Expanded(
                      child: option(Icons.photo_camera_rounded, primaryColor, 'કેમેરા\nCamera',
                          () => _pickImage(ImageSource.camera)),
                    ),
                    Expanded(
                      child: option(Icons.videocam_rounded, const Color(0xFFEA580C), 'વિડિયો\nVideo', _pickVideo),
                    ),
                    Expanded(
                      child: option(Icons.picture_as_pdf_rounded, const Color(0xFFD32F2F), 'PDF\nDocument', _pickPdf),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Photo/PDF max 10 MB • Video max 25 MB',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                            final media = msg.media;

                            return Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.78,
                                ),
                                padding: media != null
                                    ? const EdgeInsets.fromLTRB(6, 6, 6, 6)
                                    : const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
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
                                    if (media != null)
                                      ChatMediaBubble(
                                        media: media,
                                        isMe: isMe,
                                        primaryColor: primaryColor,
                                      )
                                    else
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

            // Upload progress indicator
            if (_isUploading)
              Container(
                width: double.infinity,
                color: lightColor,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'ફાઈલ અપલોડ થઈ રહી છે... (Uploading attachment)',
                      style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

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
                      padding: const EdgeInsets.only(left: 14, right: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F2F5),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              textCapitalization: TextCapitalization.sentences,
                              minLines: 1,
                              maxLines: 4,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15.0,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                              cursorColor: primaryColor,
                              decoration: const InputDecoration(
                                hintText: 'સંદેશો લખો... (Type a message)',
                                hintStyle: TextStyle(fontSize: 13.5, color: Color(0xFF64748B)),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                filled: false,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                              ),
                              onSubmitted: (_) => _handleSend(),
                            ),
                          ),
                          // Attachment Icon: Paperclip for PDF, Photo, Video
                          IconButton(
                            tooltip: 'ફાઈલ અથવા PDF જોડો (Attach PDF or File)',
                            icon: Icon(
                              Icons.attach_file_rounded,
                              color: _isUploading ? Colors.grey : const Color(0xFF475569),
                              size: 22,
                            ),
                            onPressed: _isUploading ? null : () => _showAttachmentSheet(primaryColor),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                          // Quick Camera/Photo Icon
                          IconButton(
                            tooltip: 'ફોટો મોકલો (Send Photo)',
                            icon: Icon(
                              Icons.camera_alt_rounded,
                              color: _isUploading ? Colors.grey : const Color(0xFF475569),
                              size: 22,
                            ),
                            onPressed: _isUploading ? null : () => _pickImage(ImageSource.gallery),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                        ],
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
