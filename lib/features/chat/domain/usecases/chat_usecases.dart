import '../entities/chat_entities.dart';
import '../repositories/chat_repository.dart';

class GetOrCreateConversation {
  final ChatRepository _repository;
  const GetOrCreateConversation(this._repository);
  Future<Conversation> call({required ChatContext context, required String userId, required ChatParticipantRole role}) {
    return _repository.getOrCreateConversation(context: context, userId: userId, role: role);
  }
}

class GetChatMessages {
  final ChatRepository _repository;
  const GetChatMessages(this._repository);
  Future<List<ChatMessage>> call({required ChatContext context, required String userId, required ChatParticipantRole role}) {
    return _repository.getMessages(context: context, userId: userId, role: role);
  }
}

class SendChatMessage {
  final ChatRepository _repository;
  const SendChatMessage(this._repository);
  Future<ChatMessage> call({required ChatContext context, required String userId, required ChatParticipantRole role, required String text}) {
    return _repository.sendMessage(context: context, userId: userId, role: role, text: text);
  }
}
