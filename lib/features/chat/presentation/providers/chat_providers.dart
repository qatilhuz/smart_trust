import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/chat_entities.dart';
import '../../domain/usecases/chat_realtime_usecases.dart';
import '../../domain/usecases/chat_usecases.dart';

final getOrCreateConversationProvider = Provider<GetOrCreateConversation>((ref) => GetOrCreateConversation(ref.watch(chatRepositoryProvider)));
final getChatMessagesProvider = Provider<GetChatMessages>((ref) => GetChatMessages(ref.watch(chatRepositoryProvider)));
final sendChatMessageProvider = Provider<SendChatMessage>((ref) => SendChatMessage(ref.watch(chatRepositoryProvider)));
final connectChatProvider = Provider<ConnectChatConversation>((ref) => ConnectChatConversation(ref.watch(chatRepositoryProvider)));
final disconnectChatProvider = Provider<DisconnectChatConversation>((ref) => DisconnectChatConversation(ref.watch(chatRepositoryProvider)));
final watchChatMessagesProvider = Provider<WatchChatMessages>((ref) => WatchChatMessages(ref.watch(chatRepositoryProvider)));
final watchChatConnectionProvider = Provider<WatchChatConnection>((ref) => WatchChatConnection(ref.watch(chatRepositoryProvider)));
final watchChatTypingProvider = Provider<WatchChatTyping>((ref) => WatchChatTyping(ref.watch(chatRepositoryProvider)));
final setChatTypingProvider = Provider<SetChatTyping>((ref) => SetChatTyping(ref.watch(chatRepositoryProvider)));

final chatControllerProvider = StateNotifierProvider.autoDispose.family<ChatController, ChatState, ChatQuery>((ref, query) => ChatController(ref, query)..load());

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
  final ChatConnectionStatus connectionStatus;
  final bool otherIsTyping;

  const ChatState({this.conversation, this.messages = const [], this.isLoading = true, this.isSending = false, this.error, this.connectionStatus = ChatConnectionStatus.connecting, this.otherIsTyping = false});

  ChatState copyWith({Conversation? conversation, List<ChatMessage>? messages, bool? isLoading, bool? isSending, Object? error, ChatConnectionStatus? connectionStatus, bool? otherIsTyping, bool clearError = false}) => ChatState(conversation: conversation ?? this.conversation, messages: messages ?? this.messages, isLoading: isLoading ?? this.isLoading, isSending: isSending ?? this.isSending, error: clearError ? null : error ?? this.error, connectionStatus: connectionStatus ?? this.connectionStatus, otherIsTyping: otherIsTyping ?? this.otherIsTyping);
}

class ChatController extends StateNotifier<ChatState> {
  final Ref _ref;
  final ChatQuery query;
  StreamSubscription<ChatMessage>? _messageSubscription;
  StreamSubscription<ChatConnectionStatus>? _connectionSubscription;
  StreamSubscription<ChatTypingEvent>? _typingSubscription;
  Timer? _typingTimer;

  ChatController(this._ref, this.query) : super(const ChatState());

  Future<void> load() async {
    try {
      final conversation = await _ref.read(getOrCreateConversationProvider).call(context: query.context, userId: query.userId, role: query.role);
      final context = query.context.copyWith(conversationId: conversation.conversationId);
      final messages = await _ref.read(getChatMessagesProvider).call(context: context, userId: query.userId, role: query.role);
      state = state.copyWith(conversation: conversation, messages: messages, isLoading: false, clearError: true);
      _subscribe(conversation);
      await _ref.read(connectChatProvider).call(conversation: conversation);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error, connectionStatus: ChatConnectionStatus.failed);
    }
  }

  void _subscribe(Conversation conversation) {
    _messageSubscription = _ref.read(watchChatMessagesProvider).call(conversationId: conversation.conversationId).listen(_onMessage);
    _connectionSubscription = _ref.read(watchChatConnectionProvider).call(conversationId: conversation.conversationId).listen((status) => state = state.copyWith(connectionStatus: status));
    _typingSubscription = _ref.read(watchChatTypingProvider).call(conversationId: conversation.conversationId).listen((event) {
      if (event.senderRole != query.role) state = state.copyWith(otherIsTyping: event.isTyping);
    });
  }

  void _onMessage(ChatMessage message) {
    final conversation = state.conversation;
    if (conversation == null || message.conversationId != conversation.conversationId || message.requestId != query.context.requestId) return;
    final validSender = message.senderRole == ChatParticipantRole.provider
        ? message.senderId == query.context.providerId
        : message.senderId == conversation.customer.id;
    if (!validSender) return;
    if (state.messages.any((item) => item.messageId == message.messageId)) return;
    final updated = [...state.messages, message]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    state = state.copyWith(messages: updated);
  }

  Future<bool> send(String text) async {
    if (text.trim().isEmpty || state.isSending || state.conversation == null) return false;
    state = state.copyWith(isSending: true, clearError: true);
    try {
      final message = await _ref.read(sendChatMessageProvider).call(context: query.context.copyWith(conversationId: state.conversation!.conversationId), userId: query.userId, role: query.role, text: text);
      _onMessage(message);
      state = state.copyWith(isSending: false);
      return true;
    } catch (error) {
      state = state.copyWith(isSending: false, error: error);
      return false;
    }
  }

  void setTyping(bool isTyping) {
    _typingTimer?.cancel();
    final conversation = state.conversation;
    if (conversation == null) return;
    if (isTyping) {
      _ref.read(setChatTypingProvider).call(conversation: conversation, role: query.role, userId: query.userId, isTyping: true);
      _typingTimer = Timer(const Duration(milliseconds: 900), () => setTyping(false));
    } else {
      _ref.read(setChatTypingProvider).call(conversation: conversation, role: query.role, userId: query.userId, isTyping: false);
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _messageSubscription?.cancel();
    _connectionSubscription?.cancel();
    _typingSubscription?.cancel();
    final conversationId = state.conversation?.conversationId;
    if (conversationId != null) _ref.read(disconnectChatProvider).call(conversationId: conversationId);
    super.dispose();
  }
}
