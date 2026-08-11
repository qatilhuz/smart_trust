import '../entities/chat_entities.dart';

abstract interface class ChatRepository {
  Future<Conversation> getOrCreateConversation({
    required ChatContext context,
    required String userId,
    required ChatParticipantRole role,
  });

  Future<List<ChatMessage>> getMessages({required ChatContext context, required String userId, required ChatParticipantRole role});

  Future<ChatMessage> sendMessage({required ChatContext context, required String userId, required ChatParticipantRole role, required String text});
}
