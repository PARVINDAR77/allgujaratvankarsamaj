class ChatMessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? json['conversation_id']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? json['sender_id']?.toString() ?? '',
      receiverId: json['receiverId']?.toString() ?? json['receiver_id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      isRead: json['isRead'] == true || json['is_read'] == 1 || json['is_read'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now()),
    );
  }

  bool isMe(String myProfileId) => senderId == myProfileId;

  /// Parsed media attachment (null for plain text messages).
  ChatMedia? get media => ChatMedia.tryParse(content);
}

enum ChatMediaType { image, video, pdf }

/// Media attachments are stored inside the existing TEXT `content` column
/// using the format: `[IMAGE]url|filename`, `[VIDEO]url|filename`, `[PDF]url|filename`.
/// This keeps the database schema and API contract unchanged.
class ChatMedia {
  final ChatMediaType type;
  final String url;
  final String fileName;

  const ChatMedia({required this.type, required this.url, required this.fileName});

  static const Map<ChatMediaType, String> _tags = {
    ChatMediaType.image: '[IMAGE]',
    ChatMediaType.video: '[VIDEO]',
    ChatMediaType.pdf: '[PDF]',
  };

  /// Encodes a media attachment into a message content string.
  static String encode(ChatMediaType type, String url, String fileName) {
    final safeName = fileName.replaceAll('|', '_').replaceAll('\n', ' ');
    return '${_tags[type]}$url|$safeName';
  }

  static ChatMedia? tryParse(String? content) {
    if (content == null) return null;
    final text = content.trim();
    for (final entry in _tags.entries) {
      if (text.startsWith(entry.value)) {
        final body = text.substring(entry.value.length);
        final sep = body.indexOf('|');
        final url = (sep >= 0 ? body.substring(0, sep) : body).trim();
        final name = sep >= 0 ? body.substring(sep + 1).trim() : '';
        if (url.isEmpty) return null;
        final lower = url.toLowerCase();
        // Only allow http(s) or relative upload paths to be rendered.
        if (!(lower.startsWith('https://') || lower.startsWith('http://') || lower.startsWith('/uploads/'))) {
          return null;
        }
        return ChatMedia(
          type: entry.key,
          url: url,
          fileName: name.isNotEmpty ? name : url.split('/').last,
        );
      }
    }
    return null;
  }

  /// Short human readable preview for conversation lists and notifications.
  static String previewText(String? content) {
    final media = tryParse(content);
    if (media == null) return content ?? '';
    switch (media.type) {
      case ChatMediaType.image:
        return '📷 ફોટો (Photo)';
      case ChatMediaType.video:
        return '🎥 વિડિયો (Video)';
      case ChatMediaType.pdf:
        return '📄 ${media.fileName}';
    }
  }
}

class ChatConversationModel {
  final String id;
  final String partnerProfileId;
  final String partnerName;
  final String? partnerPhotoUrl;
  final String partnerGender;
  final String partnerLocation;
  final String? partnerDesignation;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  ChatConversationModel({
    required this.id,
    required this.partnerProfileId,
    required this.partnerName,
    this.partnerPhotoUrl,
    required this.partnerGender,
    required this.partnerLocation,
    this.partnerDesignation,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
  });

  bool get isFemale {
    final g = partnerGender.toUpperCase();
    if (g.contains('FEMALE') || g.contains('WOMAN') || g.contains('GIRL') || g.contains('BRIDE') || g.contains('સ્ત્રી')) {
      return true;
    }
    final n = partnerName.toUpperCase();
    return n.contains('BEN') || n.contains('BAHEN') || n.contains('બેન') || n.contains('બહેન');
  }

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    final p = json['partnerProfile'] as Map<String, dynamic>?;
    String name = 'Candidate';
    String? photo;
    String gender = 'OTHER';
    String location = 'Gujarat';
    String? designation;

    if (p != null) {
      final f = p['firstName']?.toString() ?? '';
      final l = p['lastName']?.toString() ?? '';
      name = '$f $l'.trim().isEmpty ? 'Candidate' : '$f $l'.trim();
      photo = p['photoUrl']?.toString();
      gender = p['gender']?.toString() ?? 'OTHER';
      final city = p['city']?.toString() ?? '';
      final dist = p['district'] is Map ? (p['district']['name']?.toString() ?? '') : '';
      location = [if (city.isNotEmpty) city, if (dist.isNotEmpty) dist].join(', ');
      if (location.isEmpty) location = 'Gujarat';
      designation = p['designation']?.toString() ?? p['occupation']?.toString();
    }

    return ChatConversationModel(
      id: json['id']?.toString() ?? '',
      partnerProfileId: json['partnerProfileId']?.toString() ?? '',
      partnerName: name,
      partnerPhotoUrl: photo,
      partnerGender: gender,
      partnerLocation: location,
      partnerDesignation: designation,
      lastMessage: json['lastMessage']?.toString(),
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'].toString())
          : null,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }
}

class ConnectionStatusResponse {
  final String status; // NONE, PENDING_SENT, PENDING_RECEIVED, ACCEPTED, DECLINED, SELF
  final String? interestId;
  final String? conversationId;

  ConnectionStatusResponse({
    required this.status,
    this.interestId,
    this.conversationId,
  });

  factory ConnectionStatusResponse.fromJson(Map<String, dynamic> json) {
    return ConnectionStatusResponse(
      status: json['status']?.toString() ?? 'NONE',
      interestId: json['interestId']?.toString(),
      conversationId: json['conversationId']?.toString(),
    );
  }
}
