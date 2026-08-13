import '../entities/chat_entities.dart';

abstract interface class ChatRepository {
  Future<Conversation> getOrCreateConversation({
    required ChatContext context,
    required String userId,
    required ChatParticipantRole role,
  });

  Future<List<ChatMessage>> getMessages({required ChatContext context, required String userId, required ChatParticipantRole role});

  Future<ChatMessage> sendMessage({required ChatContext context, required String userId, required ChatParticipantRole role, required String text});

  Future<void> connect({required Conversation conversation});
  Future<void> disconnect({required String conversationId});
  Stream<ChatMessage> messageStream({required String conversationId});
  Stream<ChatConnectionStatus> connectionStream({required String conversationId});
  Stream<ChatTypingEvent> typingStream({required String conversationId});
  Future<void> setTyping({required Conversation conversation, required ChatParticipantRole role, required String userId, required bool isTyping});
}
