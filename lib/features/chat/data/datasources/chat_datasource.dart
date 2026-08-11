import '../../../customer/job_request/data/stores/customer_request_runtime_store.dart';
import '../../../customer/job_request/domain/entities/job_request_entities.dart';
import '../../domain/entities/chat_entities.dart';
import '../models/chat_models.dart';

abstract interface class ChatDataSource {
  Future<ConversationModel> getOrCreateConversation({required ChatContext context, required String userId, required ChatParticipantRole role});
  Future<List<ChatMessageModel>> getMessages({required ChatContext context, required String userId, required ChatParticipantRole role});
  Future<ChatMessageModel> sendMessage({required ChatContext context, required String userId, required ChatParticipantRole role, required String text});
}

class ChatLocalDataSource implements ChatDataSource {
  final CustomerRequestRuntimeStore _requestStore;
  final Map<String, Conversation> _conversations = {};
  final Map<String, List<ChatMessage>> _messages = {};

  ChatLocalDataSource(this._requestStore);

  @override
  Future<ConversationModel> getOrCreateConversation({required ChatContext context, required String userId, required ChatParticipantRole role}) async {
    final conversation = _validateAndGet(context: context, userId: userId, role: role);
    return ConversationModel(conversation);
  }

  @override
  Future<List<ChatMessageModel>> getMessages({required ChatContext context, required String userId, required ChatParticipantRole role}) async {
    final conversation = _validateAndGet(context: context, userId: userId, role: role);
    await Future<void>.delayed(const Duration(milliseconds: 220));
    return (_messages[conversation.conversationId] ?? const <ChatMessage>[])
        .map(ChatMessageModel.new)
        .toList(growable: false);
  }

  @override
  Future<ChatMessageModel> sendMessage({required ChatContext context, required String userId, required ChatParticipantRole role, required String text}) async {
    final conversation = _validateAndGet(context: context, userId: userId, role: role);
    final clean = text.trim();
    if (clean.isEmpty) throw const ChatException(ChatFailureCode.invalidContext);
    final message = ChatMessage(
      messageId: 'local-message-${DateTime.now().microsecondsSinceEpoch}',
      conversationId: conversation.conversationId,
      requestId: context.requestId,
      senderId: userId,
      senderRole: role,
      text: clean,
      timestamp: DateTime.now(),
      status: ChatMessageStatus.sent,
    );
    _messages.putIfAbsent(conversation.conversationId, () => <ChatMessage>[]).add(message);
    return ChatMessageModel(message);
  }

  Conversation _validateAndGet({required ChatContext context, required String userId, required ChatParticipantRole role}) {
    if (context.requestId.isEmpty || context.providerId.isEmpty || userId.isEmpty) throw const ChatException(ChatFailureCode.invalidContext);
    final request = _requestStore.get(context.requestId);
    if (request == null || request.providerId != context.providerId) throw const ChatException(ChatFailureCode.conversationUnavailable);
    if (request.status != RequestLifecycleStatus.accepted) throw const ChatException(ChatFailureCode.conversationUnavailable);
    if (role == ChatParticipantRole.customer && request.customerId != userId) throw const ChatException(ChatFailureCode.accessDenied);
    if (role == ChatParticipantRole.provider && request.providerId != userId) throw const ChatException(ChatFailureCode.accessDenied);

    final id = context.conversationId ?? '${context.requestId}::${context.providerId}';
    final existing = _conversations[id];
    if (existing != null) return existing;
    final now = DateTime.now();
    final conversation = Conversation(
      conversationId: id,
      requestId: context.requestId,
      providerId: context.providerId,
      customer: const ChatParticipant(id: '1', name: 'Customer', role: ChatParticipantRole.customer),
      provider: ChatParticipant(id: context.providerId, name: _providerName(context.providerId), role: ChatParticipantRole.provider),
      status: ConversationStatus.active,
      createdAt: now,
      updatedAt: now,
    );
    _conversations[id] = conversation;
    _messages[id] = <ChatMessage>[];
    return conversation;
  }

  String _providerName(String id) {
    switch (id) {
      case 'provider-sara-ahmed': return 'Sara Ahmed';
      case 'provider-usman-khan': return 'Usman Khan';
      default: return 'Ali Hussain';
    }
  }
}
