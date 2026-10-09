import 'package:dio/dio.dart';
import '../../../shared/models/chat_models.dart';

class ChatRepository {
  final Dio _dio;

  ChatRepository(this._dio);

  Future<List<ChatConversationModel>> getConversations() async {
    try {
      final res = await _dio.get('/chat/conversations');
      if (res.data is List) {
        return (res.data as List)
            .map((item) => ChatConversationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getConversationMessages(String conversationId) async {
    try {
      final res = await _dio.get('/chat/conversations/$conversationId/messages');
      if (res.data is Map<String, dynamic>) {
        final data = res.data as Map<String, dynamic>;
        final rawMessages = data['messages'] as List? ?? [];
        final messages = rawMessages
            .map((m) => ChatMessageModel.fromJson(m as Map<String, dynamic>))
            .toList();
        return {
          'conversationId': data['conversationId']?.toString() ?? conversationId,
          'myProfileId': data['myProfileId']?.toString() ?? '',
          'partnerProfile': data['partnerProfile'],
          'messages': messages,
        };
      }
      return {'messages': <ChatMessageModel>[]};
    } catch (_) {
      return {'messages': <ChatMessageModel>[]};
    }
  }

  Future<Map<String, dynamic>?> getOrCreateConversation(String partnerProfileId) async {
    try {
      final res = await _dio.get('/chat/conversation-with/$partnerProfileId');
      if (res.data is Map<String, dynamic>) {
        final data = res.data as Map<String, dynamic>;
        final rawMessages = data['messages'] as List? ?? [];
        final messages = rawMessages
            .map((m) => ChatMessageModel.fromJson(m as Map<String, dynamic>))
            .toList();
        return {
          'conversationId': data['conversationId']?.toString() ?? '',
          'myProfileId': data['myProfileId']?.toString() ?? '',
          'partnerProfile': data['partnerProfile'],
          'messages': messages,
        };
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<ChatMessageModel?> sendMessage({
    String? conversationId,
    String? receiverProfileId,
    required String content,
  }) async {
    try {
      final res = await _dio.post('/chat/messages', data: {
        if (conversationId != null) 'conversationId': conversationId,
        if (receiverProfileId != null) 'receiverProfileId': receiverProfileId,
        'content': content.trim(),
      });
      if (res.data is Map<String, dynamic>) {
        return ChatMessageModel.fromJson(res.data as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> markAsRead(String conversationId) async {
    try {
      await _dio.patch('/chat/conversations/$conversationId/read');
    } catch (_) {}
  }

  Future<ConnectionStatusResponse> getConnectionStatus(String targetProfileId) async {
    try {
      final res = await _dio.get('/interests/status/$targetProfileId');
      if (res.data is Map<String, dynamic>) {
        return ConnectionStatusResponse.fromJson(res.data as Map<String, dynamic>);
      }
      return ConnectionStatusResponse(status: 'NONE');
    } catch (_) {
      return ConnectionStatusResponse(status: 'NONE');
    }
  }

  Future<Map<String, dynamic>> sendConnectionRequest(String targetProfileId) async {
    try {
      final res = await _dio.post('/interests', data: {
        'targetProfileId': targetProfileId,
      });
      return {
        'success': true,
        'status': res.data?['status'] ?? 'PENDING_SENT',
        'message': res.data?['message'] ?? 'Connection request sent successfully',
      };
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Could not send request';
      return {'success': false, 'message': msg.toString()};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> acceptConnectionRequest(String interestId) async {
    try {
      final res = await _dio.patch('/interests/$interestId/accept');
      return {
        'success': true,
        'status': 'ACCEPTED',
        'conversationId': res.data?['conversationId'],
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> declineConnectionRequest(String interestId) async {
    try {
      await _dio.patch('/interests/$interestId/decline');
      return {'success': true, 'status': 'DECLINED'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
