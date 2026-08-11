import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_entities.dart';
import '../../domain/usecases/chat_usecases.dart';

final getOrCreateConversationProvider = Provider<GetOrCreateConversation>((ref) {
  return GetOrCreateConversation(ref.watch(chatRepositoryProvider));
});

final getChatMessagesProvider = Provider<GetChatMessages>((ref) {
  return GetChatMessages(ref.watch(chatRepositoryProvider));
});

final sendChatMessageProvider = Provider<SendChatMessage>((ref) {
  return SendChatMessage(ref.watch(chatRepositoryProvider));
});

final chatControllerProvider = StateNotifierProvider.autoDispose.family<ChatController, ChatState, ChatQuery>((ref, query) {
  return ChatController(ref, query)..load();
});

class ChatQuery {
  final ChatContext context;
  final String userId;
  final ChatParticipantRole role;

  const ChatQuery({required this.context, required this.userId, required this.role});

  @override
  bool operator ==(Object other) => other is ChatQuery && other.context.requestId == context.requestId && other.context.providerId == context.providerId && other.context.conversationId == context.conversationId && other.userId == userId && other.role == role;

  @override
  int get hashCode => Object.hash(context.requestId, context.providerId, context.conversationId, userId, role);
}

class ChatState {
  final Conversation? conversation;
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isSending;
  final Object? error;

  const ChatState({this.conversation, this.messages = const [], this.isLoading = true, this.isSending = false, this.error});

  ChatState copyWith({Conversation? conversation, List<ChatMessage>? messages, bool? isLoading, bool? isSending, Object? error, bool clearError = false}) => ChatState(
        conversation: conversation ?? this.conversation,
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        isSending: isSending ?? this.isSending,
        error: clearError ? null : error ?? this.error,
      );
}

class ChatController extends StateNotifier<ChatState> {
  final Ref _ref;
  final ChatQuery query;
  ChatController(this._ref, this.query) : super(const ChatState());

  Future<void> load() async {
    try {
      final conversation = await _ref.read(getOrCreateConversationProvider).call(context: query.context, userId: query.userId, role: query.role);
      final messages = await _ref.read(getChatMessagesProvider).call(context: query.context.copyWith(conversationId: conversation.conversationId), userId: query.userId, role: query.role);
      state = state.copyWith(conversation: conversation, messages: messages, isLoading: false, clearError: true);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error);
    }
  }

  Future<bool> send(String text) async {
    if (text.trim().isEmpty || state.isSending || state.conversation == null) return false;
    state = state.copyWith(isSending: true, clearError: true);
    try {
      final message = await _ref.read(sendChatMessageProvider).call(context: query.context.copyWith(conversationId: state.conversation!.conversationId), userId: query.userId, role: query.role, text: text);
      state = state.copyWith(messages: [...state.messages, message], isSending: false);
      return true;
    } catch (error) {
      state = state.copyWith(isSending: false, error: error);
      return false;
    }
  }
}
