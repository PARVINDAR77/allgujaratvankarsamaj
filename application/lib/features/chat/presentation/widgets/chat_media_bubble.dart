import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/app_config.dart';
import '../../../../shared/models/chat_models.dart';

/// Renders an image, video or PDF attachment inside a chat bubble.
class ChatMediaBubble extends StatelessWidget {
  final ChatMedia media;
  final bool isMe;
  final Color primaryColor;

  const ChatMediaBubble({
    super.key,
    required this.media,
    required this.isMe,
    required this.primaryColor,
  });

  String get _url => AppConfig.resolveMediaUrl(media.url);

  Future<void> _openExternally(BuildContext context) async {
    final uri = Uri.tryParse(_url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ફાઈલ ખોલી શકાઈ નથી (Could not open file)')),
      );
    }
  }

  void _openImageViewer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FullScreenImageViewer(url: _url, onDownload: () => _openExternally(context)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (media.type) {
      case ChatMediaType.image:
        return _buildImage(context);
      case ChatMediaType.video:
        return _buildFileCard(
          context,
          icon: Icons.play_circle_fill_rounded,
          iconColor: isMe ? Colors.white : primaryColor,
          title: 'વિડિયો (Video)',
          subtitle: media.fileName,
          actionLabel: 'Play',
        );
      case ChatMediaType.pdf:
        return _buildFileCard(
          context,
          icon: Icons.picture_as_pdf_rounded,
          iconColor: isMe ? Colors.white : const Color(0xFFD32F2F),
          title: media.fileName,
          subtitle: 'PDF દસ્તાવેજ (Document)',
          actionLabel: 'Open',
        );
    }
  }

  Widget _buildImage(BuildContext context) {
    return Semantics(
      label: 'Photo attachment. Tap to view full screen.',
      button: true,
      child: GestureDetector(
        onTap: () => _openImageViewer(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240, maxHeight: 280, minWidth: 140, minHeight: 120),
            child: Image.network(
              _url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  width: 220,
                  height: 180,
                  color: Colors.black12,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isMe ? Colors.white : primaryColor,
                  ),
                );
              },
              errorBuilder: (_, _, _) => Container(
                width: 220,
                height: 140,
                color: Colors.black12,
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.broken_image_outlined, color: isMe ? Colors.white70 : Colors.black45),
                    const SizedBox(height: 4),
                    Text(
                      'ફોટો લોડ થયો નથી',
                      style: TextStyle(fontSize: 11, color: isMe ? Colors.white70 : Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String actionLabel,
  }) {
    final textColor = isMe ? Colors.white : const Color(0xFF0F172A);
    final subColor = isMe ? Colors.white70 : const Color(0xFF64748B);
    return Material(
      color: isMe ? Colors.white.withValues(alpha: 0.14) : const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openExternally(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 34, color: iconColor),
                const SizedBox(width: 10),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: textColor),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: subColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  actionLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isMe ? Colors.white : primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FullScreenImageViewer extends StatelessWidget {
  final String url;
  final VoidCallback onDownload;

  const _FullScreenImageViewer({required this.url, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Open / Download',
            icon: const Icon(Icons.download_rounded),
            onPressed: onDownload,
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 5,
          child: Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
          ),
        ),
      ),
    );
  }
}
