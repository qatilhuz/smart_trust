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
}
