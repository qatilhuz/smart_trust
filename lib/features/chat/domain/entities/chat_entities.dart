enum ChatParticipantRole { customer, provider }

enum ChatMessageStatus { sending, sent, delivered, read, failed }

enum ConversationStatus { active, closed }

enum ChatConnectionStatus { connecting, connected, reconnecting, disconnected, failed }

class ChatParticipant {
  final String id;
  final String name;
  final ChatParticipantRole role;

  const ChatParticipant({required this.id, required this.name, required this.role});
}

class ChatContext {
  final String requestId;
  final String providerId;
  final String? conversationId;

  const ChatContext({required this.requestId, required this.providerId, this.conversationId});

  ChatContext copyWith({String? conversationId}) => ChatContext(
        requestId: requestId,
        providerId: providerId,
        conversationId: conversationId ?? this.conversationId,
      );
}

class ChatTypingEvent {
  final String conversationId;
  final String senderId;
  final ChatParticipantRole senderRole;
  final bool isTyping;

  const ChatTypingEvent({required this.conversationId, required this.senderId, required this.senderRole, required this.isTyping});
}

class ChatMessage {
  final String messageId;
  final String conversationId;
  final String requestId;
  final String senderId;
  final ChatParticipantRole senderRole;
  final String text;
  final DateTime timestamp;
  final ChatMessageStatus status;

  const ChatMessage({
    required this.messageId,
    required this.conversationId,
    required this.requestId,
    required this.senderId,
    required this.senderRole,
    required this.text,
    required this.timestamp,
    required this.status,
  });
}

class Conversation {
  final String conversationId;
  final String requestId;
  final String providerId;
  final ChatParticipant customer;
  final ChatParticipant provider;
  final ConversationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Conversation({
    required this.conversationId,
    required this.requestId,
    required this.providerId,
    required this.customer,
    required this.provider,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}

enum ChatFailureCode { invalidContext, accessDenied, conversationUnavailable, unknown }

class ChatException implements Exception {
  final ChatFailureCode code;
  const ChatException(this.code);
}
