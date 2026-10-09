import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../shared/models/chat_models.dart';
import '../data/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return ChatRepository(dio);
});

// Provider to check connection status with a specific candidate
final connectionStatusProvider = FutureProvider.autoDispose.family<ConnectionStatusResponse, String>((ref, targetProfileId) async {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.getConnectionStatus(targetProfileId);
});

// Notifier for listing all user's conversations
class ConversationsNotifier extends StateNotifier<AsyncValue<List<ChatConversationModel>>> {
  final ChatRepository _repo;
  Timer? _pollingTimer;

  ConversationsNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadConversations();
    // Poll every 12 seconds for conversation updates
    _pollingTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      loadConversations(silent: true);
    });
  }

  Future<void> loadConversations({bool silent = false}) async {
    if (!silent && state is! AsyncData) {
      state = const AsyncValue.loading();
    }
    try {
      final list = await _repo.getConversations();
      state = AsyncValue.data(list);
    } catch (e, st) {
      if (!silent) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> refresh() => loadConversations();

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}

final conversationsProvider = StateNotifierProvider.autoDispose<ConversationsNotifier, AsyncValue<List<ChatConversationModel>>>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return ConversationsNotifier(repo);
});

// State for an active chat room
class ChatRoomState {
  final bool isLoading;
  final String conversationId;
  final String myProfileId;
  final Map<String, dynamic>? partnerProfile;
  final List<ChatMessageModel> messages;
  final String? error;

  ChatRoomState({
    this.isLoading = false,
    required this.conversationId,
    this.myProfileId = '',
    this.partnerProfile,
    this.messages = const [],
    this.error,
  });

  ChatRoomState copyWith({
    bool? isLoading,
    String? conversationId,
    String? myProfileId,
    Map<String, dynamic>? partnerProfile,
    List<ChatMessageModel>? messages,
    String? error,
  }) {
    return ChatRoomState(
      isLoading: isLoading ?? this.isLoading,
      conversationId: conversationId ?? this.conversationId,
      myProfileId: myProfileId ?? this.myProfileId,
      partnerProfile: partnerProfile ?? this.partnerProfile,
      messages: messages ?? this.messages,
      error: error,
    );
  }
}

class ChatRoomNotifier extends StateNotifier<ChatRoomState> {
  final ChatRepository _repo;
  final String _conversationId;
  Timer? _pollTimer;

  ChatRoomNotifier(this._repo, this._conversationId)
      : super(ChatRoomState(isLoading: true, conversationId: _conversationId)) {
    loadMessages();
    // Poll every 3.5 seconds while chat room is open
    _pollTimer = Timer.periodic(const Duration(milliseconds: 3500), (_) {
      loadMessages(silent: true);
    });
  }

  Future<void> loadMessages({bool silent = false}) async {
    if (!silent && state.messages.isEmpty) {
      state = state.copyWith(isLoading: true);
    }
    try {
      final res = await _repo.getConversationMessages(_conversationId);
      final rawMessages = res['messages'] as List<ChatMessageModel>? ?? [];
      state = state.copyWith(
        isLoading: false,
        myProfileId: res['myProfileId']?.toString() ?? state.myProfileId,
        partnerProfile: res['partnerProfile'] as Map<String, dynamic>? ?? state.partnerProfile,
        messages: rawMessages,
      );
    } catch (e) {
      if (!silent) {
        state = state.copyWith(isLoading: false, error: e.toString());
      }
    }
  }

  Future<bool> sendMessage(String text) async {
    if (text.trim().isEmpty) return false;
    final sent = await _repo.sendMessage(
      conversationId: _conversationId,
      content: text,
    );
    if (sent != null) {
      state = state.copyWith(
        messages: [...state.messages, sent],
      );
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

final chatRoomProvider = StateNotifierProvider.autoDispose.family<ChatRoomNotifier, ChatRoomState, String>((ref, conversationId) {
  final repo = ref.watch(chatRepositoryProvider);
  return ChatRoomNotifier(repo, conversationId);
});
