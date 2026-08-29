import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/authentication_prompt.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/chat_entities.dart';
import '../providers/chat_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String requestId;
  final String providerId;
  final String? conversationId;
  final ChatParticipantRole role;

  const ChatScreen({super.key, required this.requestId, required this.providerId, required this.role, this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authStateProvider);
    if (auth.isLoading) return const _ChatLoading();
    if (auth.valueOrNull == null) return AuthenticationPrompt(message: l10n.chatAccessDenied);
    final isCustomer = widget.role == ChatParticipantRole.customer;
    if ((isCustomer && auth.valueOrNull!.role.toLowerCase() != 'customer') || (!isCustomer && auth.valueOrNull!.role.toLowerCase() != 'provider')) {
      return AuthenticationPrompt(message: l10n.chatAccessDenied);
    }
    if (widget.requestId.isEmpty || widget.providerId.isEmpty) return _ChatError(message: l10n.conversationUnavailable, onRetry: null);

    final userId = isCustomer ? auth.valueOrNull!.id : 'provider-ali-hussain';
    final query = ChatQuery(context: ChatContext(requestId: widget.requestId, providerId: widget.providerId, conversationId: widget.conversationId), userId: userId, role: widget.role);
    final state = ref.watch(chatControllerProvider(query));
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(l10n.chat),
        leading: IconButton(onPressed: () => context.pop(), tooltip: l10n.back, icon: const Icon(Icons.arrow_back_rounded)),
        actions: [IconButton(onPressed: () => ref.invalidate(chatControllerProvider(query)), tooltip: l10n.retry, icon: const Icon(Icons.refresh_rounded))],
      ),
      body: state.isLoading
          ? const _ChatLoadingView()
          : state.error != null
              ? _ChatError(message: _errorMessage(l10n, state.error!), onRetry: () => ref.invalidate(chatControllerProvider(query)))
              : Column(children: [
                  _ChatContextHeader(conversation: state.conversation!, l10n: l10n),
                  _ConnectionStatus(status: state.connectionStatus, l10n: l10n, onRetry: () => ref.invalidate(chatControllerProvider(query))),
                  Expanded(child: state.messages.isEmpty ? _EmptyConversation(l10n: l10n) : _MessageList(messages: state.messages, role: widget.role, controller: _scrollController)),
                  if (state.otherIsTyping) _TypingIndicator(name: widget.role == ChatParticipantRole.customer ? state.conversation!.provider.name : state.conversation!.customer.name, l10n: l10n),
                  _Composer(controller: _messageController, isSending: state.isSending, l10n: l10n, onChanged: (value) => ref.read(chatControllerProvider(query).notifier).setTyping(value.isNotEmpty), onSend: () => _send(query)),
                ]),
    );
  }

  Future<void> _send(ChatQuery query) async {
    final text = _messageController.text;
    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.messageRequired)));
      return;
    }
    final sent = await ref.read(chatControllerProvider(query).notifier).send(text);
    if (!mounted) return;
    if (sent) {
      ref.read(chatControllerProvider(query).notifier).setTyping(false);
      _messageController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 240), curve: Curves.easeOutCubic);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.messageSendError)));
    }
  }

  String _errorMessage(AppLocalizations l10n, Object error) {
    if (error is ChatException) {
      switch (error.code) {
        case ChatFailureCode.invalidContext: return l10n.conversationUnavailable;
        case ChatFailureCode.accessDenied: return l10n.chatAccessDenied;
        case ChatFailureCode.conversationUnavailable: return l10n.conversationUnavailable;
        case ChatFailureCode.unknown: return l10n.chatError;
      }
    }
    return l10n.chatError;
  }
}

class _ChatContextHeader extends StatelessWidget {
  final Conversation? conversation;
  final AppLocalizations l10n;
  const _ChatContextHeader({required this.conversation, required this.l10n});
  @override
  Widget build(BuildContext context) {
    final provider = conversation!.provider;
    return Container(padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.md, AppSpacing.xxl, AppSpacing.lg), decoration: BoxDecoration(color: AppColors.card, border: Border(bottom: BorderSide(color: AppColors.border))), child: Row(children: [CircleAvatar(radius: AppSizes.avatarMedium / 2, backgroundColor: AppColors.primary.withOpacity(.12), child: Text(provider.name.characters.first.toUpperCase(), style: AppTextStyles.label.copyWith(color: AppColors.primaryDark))), const SizedBox(width: AppSpacing.md), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(provider.name, style: AppTextStyles.heading3), const SizedBox(height: AppSpacing.xs), Text(l10n.requestReference(conversation!.requestId), style: AppTextStyles.caption)])), const Icon(Icons.verified_rounded, color: AppColors.primary, size: AppSizes.iconSm)]));
  }
}

class _MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ChatParticipantRole role;
  final ScrollController controller;
  const _MessageList({required this.messages, required this.role, required this.controller});
  @override
  Widget build(BuildContext context) => ListView.builder(controller: controller, padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, AppSpacing.lg), itemCount: messages.length, itemBuilder: (context, index) => _MessageBubble(message: messages[index], isMine: messages[index].senderRole == role));
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMine;
  const _MessageBubble({required this.message, required this.isMine});
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: TweenAnimationBuilder<double>(tween: Tween(begin: .94, end: 1), duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic, builder: (context, scale, child) => Transform.scale(scale: scale, alignment: isMine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart, child: child), child: Container(margin: const EdgeInsets.only(bottom: AppSpacing.md), constraints: const BoxConstraints(maxWidth: 300), padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md), decoration: BoxDecoration(color: isMine ? AppColors.primary : AppColors.card, borderRadius: BorderRadiusDirectional.only(topStart: const Radius.circular(AppSizes.radiusLg), topEnd: const Radius.circular(AppSizes.radiusLg), bottomStart: Radius.circular(isMine ? AppSizes.radiusLg : AppSizes.radiusSm), bottomEnd: Radius.circular(isMine ? AppSizes.radiusSm : AppSizes.radiusLg)), border: isMine ? null : Border.all(color: AppColors.border), boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(.05), blurRadius: AppSpacing.sm, offset: const Offset(0, AppSpacing.xs))]), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(message.text, style: AppTextStyles.bodyRegular.copyWith(color: isMine ? AppColors.white : AppColors.textPrimary)), const SizedBox(height: AppSpacing.xs), Text(_time(message.timestamp), style: AppTextStyles.caption.copyWith(color: isMine ? AppColors.white70 : AppColors.textLight))]))),
    );
  }
  String _time(DateTime time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

class _ConnectionStatus extends StatelessWidget {
  final ChatConnectionStatus status;
  final AppLocalizations l10n;
  final VoidCallback onRetry;
  const _ConnectionStatus({required this.status, required this.l10n, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final connected = status == ChatConnectionStatus.connected;
    final text = switch (status) {
      ChatConnectionStatus.connected => l10n.chatConnected,
      ChatConnectionStatus.connecting => l10n.chatConnecting,
      ChatConnectionStatus.reconnecting => l10n.chatReconnecting,
      ChatConnectionStatus.disconnected => l10n.chatDisconnected,
      ChatConnectionStatus.failed => l10n.chatError,
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.xs),
      color: connected ? AppColors.success.withOpacity(.08) : AppColors.warning.withOpacity(.10),
      child: Row(children: [
        Container(width: AppSpacing.sm, height: AppSpacing.sm, decoration: BoxDecoration(shape: BoxShape.circle, color: connected ? AppColors.success : AppColors.warning)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text, style: AppTextStyles.caption)),
        if (status == ChatConnectionStatus.failed || status == ChatConnectionStatus.disconnected) TextButton(onPressed: onRetry, child: Text(l10n.chatReconnect)),
      ]),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final String name;
  final AppLocalizations l10n;
  const _TypingIndicator({required this.name, required this.l10n});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xs), child: Align(alignment: AlignmentDirectional.centerStart, child: Text(l10n.typingIndicator(name), style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark))));
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final AppLocalizations l10n;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;
  const _Composer({required this.controller, required this.isSending, required this.l10n, required this.onChanged, required this.onSend});
  @override
  Widget build(BuildContext context) => SafeArea(top: false, child: Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.sm, AppSpacing.xxl, AppSpacing.lg), child: Row(children: [Expanded(child: AppTextField(controller: controller, label: l10n.messageHint, enabled: !isSending, onChanged: onChanged)), const SizedBox(width: AppSpacing.sm), Semantics(button: true, label: l10n.sendMessage, child: IconButton(onPressed: isSending ? null : onSend, tooltip: l10n.sendMessage, style: IconButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white), icon: isSending ? const SizedBox(width: AppSizes.iconSm, height: AppSizes.iconSm, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white)) : const Icon(Icons.send_rounded)))])));
}

class _EmptyConversation extends StatelessWidget {
  final AppLocalizations l10n;
  const _EmptyConversation({required this.l10n});
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(AppSpacing.xxl), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.forum_outlined, color: AppColors.primaryDark, size: AppSizes.iconXl), const SizedBox(height: AppSpacing.lg), Text(l10n.emptyConversation, style: AppTextStyles.heading3), const SizedBox(height: AppSpacing.sm), Text(l10n.startConversation, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium)])));
}

class _ChatLoading extends StatelessWidget { const _ChatLoading(); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary))); }
class _ChatLoadingView extends StatelessWidget { const _ChatLoadingView(); @override Widget build(BuildContext context) => Column(children: [Container(height: 78, color: AppColors.card), const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))]); }
class _ChatError extends StatelessWidget { final String message; final VoidCallback? onRetry; const _ChatError({required this.message, required this.onRetry}); @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(AppSpacing.xxl), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primaryDark, size: AppSizes.iconXl), const SizedBox(height: AppSpacing.lg), Text(message, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium), if (onRetry != null) TextButton(onPressed: onRetry, child: Text(AppLocalizations.of(context)!.retry))]))); }
