import '../entities/chat_entities.dart';
import '../repositories/chat_repository.dart';

class ConnectChatConversation {
  final ChatRepository _repository;
  const ConnectChatConversation(this._repository);
  Future<void> call({required Conversation conversation}) => _repository.connect(conversation: conversation);
}

class DisconnectChatConversation {
  final ChatRepository _repository;
  const DisconnectChatConversation(this._repository);
  Future<void> call({required String conversationId}) => _repository.disconnect(conversationId: conversationId);
}

class WatchChatMessages {
  final ChatRepository _repository;
  const WatchChatMessages(this._repository);
  Stream<ChatMessage> call({required String conversationId}) => _repository.messageStream(conversationId: conversationId);
}

class WatchChatConnection {
  final ChatRepository _repository;
  const WatchChatConnection(this._repository);
  Stream<ChatConnectionStatus> call({required String conversationId}) => _repository.connectionStream(conversationId: conversationId);
}

class WatchChatTyping {
  final ChatRepository _repository;
  const WatchChatTyping(this._repository);
  Stream<ChatTypingEvent> call({required String conversationId}) => _repository.typingStream(conversationId: conversationId);
}

class SetChatTyping {
  final ChatRepository _repository;
  const SetChatTyping(this._repository);
  Future<void> call({required Conversation conversation, required ChatParticipantRole role, required String userId, required bool isTyping}) => _repository.setTyping(conversation: conversation, role: role, userId: userId, isTyping: isTyping);
}
