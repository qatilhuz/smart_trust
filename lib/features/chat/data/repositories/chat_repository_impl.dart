import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../customer/job_request/data/stores/customer_request_runtime_store.dart';
import '../../domain/entities/chat_entities.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_datasource.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ChatLocalDataSource(CustomerRequestRuntimeStore.instance));
});

class ChatRepositoryImpl implements ChatRepository {
  final ChatDataSource _dataSource;
  const ChatRepositoryImpl(this._dataSource);

  @override
  Future<Conversation> getOrCreateConversation({required ChatContext context, required String userId, required ChatParticipantRole role}) async => (await _dataSource.getOrCreateConversation(context: context, userId: userId, role: role)).toEntity();

  @override
  Future<List<ChatMessage>> getMessages({required ChatContext context, required String userId, required ChatParticipantRole role}) async => (await _dataSource.getMessages(context: context, userId: userId, role: role)).map((message) => message.toEntity()).toList(growable: false);

  @override
  Future<ChatMessage> sendMessage({required ChatContext context, required String userId, required ChatParticipantRole role, required String text}) async => (await _dataSource.sendMessage(context: context, userId: userId, role: role, text: text)).toEntity();

  @override
  Future<void> connect({required Conversation conversation}) => _dataSource.connect(conversation: conversation);

  @override
  Future<void> disconnect({required String conversationId}) => _dataSource.disconnect(conversationId: conversationId);

  @override
  Stream<ChatMessage> messageStream({required String conversationId}) => _dataSource.messageStream(conversationId: conversationId).map((message) => message.toEntity());

  @override
  Stream<ChatConnectionStatus> connectionStream({required String conversationId}) => _dataSource.connectionStream(conversationId: conversationId);

  @override
  Stream<ChatTypingEvent> typingStream({required String conversationId}) => _dataSource.typingStream(conversationId: conversationId);

  @override
  Future<void> setTyping({required Conversation conversation, required ChatParticipantRole role, required String userId, required bool isTyping}) => _dataSource.setTyping(conversation: conversation, role: role, userId: userId, isTyping: isTyping);
}
