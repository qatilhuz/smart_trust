import '../../domain/entities/chat_entities.dart';

class ConversationModel {
  final Conversation value;
  const ConversationModel(this.value);
  Conversation toEntity() => value;
}

class ChatMessageModel {
  final ChatMessage value;
  const ChatMessageModel(this.value);
  ChatMessage toEntity() => value;
}
