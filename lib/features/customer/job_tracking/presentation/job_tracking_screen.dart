import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/authentication_prompt.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../domain/entities/job_tracking_entities.dart';
import '../../../quotation/domain/entities/quotation_entities.dart';
import 'providers/job_tracking_providers.dart';

class JobTrackingScreen extends ConsumerWidget {
  final String requestId;
  final String providerId;
  final String? service;
  final String? location;

  const JobTrackingScreen({
    super.key,
    required this.requestId,
    required this.providerId,
    this.service,
    this.location,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authStateProvider);
    if (auth.isLoading) return const _TrackingLoadingScaffold();
    if (auth.valueOrNull?.role.toLowerCase() != 'customer') {
      return AuthenticationPrompt(message: l10n.customerOnlyMessage);
    }
    if (requestId.trim().isEmpty || providerId.trim().isEmpty) {
      return _TrackingError(message: l10n.trackingUnavailable, onRetry: null);
    }

    final query = TrackingQuery(
      requestId: requestId,
      providerId: providerId,
      service: service,
      location: location,
    );
    final state = ref.watch(jobTrackingProvider(query));
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(l10n.jobTracking),
        leading: IconButton(
          onPressed: () => context.pop(),
          tooltip: l10n.back,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(jobTrackingProvider(query)),
            tooltip: l10n.refreshStatus,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: state.when(
        loading: () => const _TrackingLoadingView(),
        error: (error, _) => _TrackingError(
          message: _failureMessage(l10n, error),
          onRetry: () => ref.invalidate(jobTrackingProvider(query)),
        ),
        data: (data) => _TrackingContent(
          data: data,
          onProvider: () => context.push(Uri(path: RouteNames.customerProviderDetails, queryParameters: {'requestId': data.requestId, 'providerId': data.provider.id, 'service': data.service, 'location': data.location}).toString()),
          onChat: () => context.push(Uri(path: RouteNames.customerChat, queryParameters: {'requestId': data.requestId, 'providerId': data.provider.id}).toString()),
          onReview: data.currentStatus == JobTrackingStatus.serviceCompleted ? () => context.push(Uri(path: RouteNames.customerReviews, queryParameters: {'requestId': data.requestId, 'providerId': data.provider.id, 'providerName': data.provider.name, 'service': data.service}).toString()) : null,
          onComplaint: data.currentStatus == JobTrackingStatus.serviceCompleted ? () => context.push(Uri(path: RouteNames.customerComplaints, queryParameters: {'requestId': data.requestId, 'providerId': data.provider.id, 'providerName': data.provider.name, 'service': data.service}).toString()) : null,
        ),
      ),
    );
  }

  String _failureMessage(AppLocalizations l10n, Object error) {
    if (error is TrackingException) {
      switch (error.code) {
        case TrackingFailureCode.invalidRequest:
          return l10n.trackingUnavailable;
        case TrackingFailureCode.requestNotFound:
          return l10n.requestNotFound;
        case TrackingFailureCode.providerUnavailable:
          return l10n.providerNoLongerAvailable;
        case TrackingFailureCode.unknown:
          return l10n.trackingError;
      }
    }
    return l10n.trackingError;
  }
}

class _TrackingContent extends StatelessWidget {
  final JobTrackingData data;
  final VoidCallback onProvider;
  final VoidCallback onChat;
  final VoidCallback? onReview;
  final VoidCallback? onComplaint;

  const _TrackingContent({required this.data, required this.onProvider, required this.onChat, this.onReview, this.onComplaint});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentTitle = _title(l10n, data.currentStatus);
    final currentDescription = _description(l10n, data.currentStatus);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, AppSpacing.section),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _RequestSummary(data: data),
          const SizedBox(height: AppSpacing.lg),
          _CurrentStatusCard(title: currentTitle, description: currentDescription, eta: data.eta),
          const SizedBox(height: AppSpacing.lg),
          _ProviderTrackingCard(data: data, onTap: onProvider, onChat: onChat),
          if (data.quotationStatus != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _QuotationStatusCard(data: data),
          ],
          const SizedBox(height: AppSpacing.lg),
          _TrackingLocationCard(data: data),
          const SizedBox(height: AppSpacing.section),
          Text(l10n.currentStatus, style: AppTextStyles.heading3),
          const SizedBox(height: AppSpacing.md),
          _TrackingTimeline(events: data.timeline),
          if (onReview != null) ...[
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButton(label: l10n.leaveReview, onPressed: onReview!),
          ],
          if (onComplaint != null) ...[
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: onComplaint, child: Text(l10n.reportIssue)),
          ],
        ],
      ),
    );
  }

  String _title(AppLocalizations l10n, JobTrackingStatus status) {
    switch (status) {
      case JobTrackingStatus.requestCreated: return l10n.statusRequestCreated;
      case JobTrackingStatus.providerSelected: return l10n.statusProviderSelected;
      case JobTrackingStatus.providerAccepted: return l10n.statusProviderAccepted;
      case JobTrackingStatus.providerDeclined: return l10n.statusProviderDeclined;
      case JobTrackingStatus.providerOnTheWay: return l10n.statusOnTheWay;
      case JobTrackingStatus.providerArrived: return l10n.statusArrived;
      case JobTrackingStatus.serviceInProgress: return l10n.statusInProgress;
      case JobTrackingStatus.serviceCompleted: return l10n.statusCompleted;
    }
  }

  String _description(AppLocalizations l10n, JobTrackingStatus status) {
    switch (status) {
      case JobTrackingStatus.requestCreated: return l10n.statusRequestCreatedDescription;
      case JobTrackingStatus.providerSelected: return l10n.statusProviderSelectedDescription;
      case JobTrackingStatus.providerAccepted: return l10n.statusProviderAcceptedDescription;
      case JobTrackingStatus.providerDeclined: return l10n.statusProviderDeclinedDescription;
      case JobTrackingStatus.providerOnTheWay: return l10n.statusOnTheWayDescription;
      case JobTrackingStatus.providerArrived: return l10n.statusArrivedDescription;
      case JobTrackingStatus.serviceInProgress: return l10n.statusInProgressDescription;
      case JobTrackingStatus.serviceCompleted: return l10n.statusCompletedDescription;
    }
  }
}

class _RequestSummary extends StatelessWidget {
  final JobTrackingData data;
  const _RequestSummary({required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.secondary, AppColors.secondaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(.18), blurRadius: AppSpacing.xxl, offset: const Offset(0, AppSpacing.md))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.trackingForRequest, style: AppTextStyles.label.copyWith(color: AppColors.white70)),
        const SizedBox(height: AppSpacing.sm),
        Text(l10n.requestReference(data.requestId), style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
        const SizedBox(height: AppSpacing.lg),
        Row(children: [const Icon(Icons.home_repair_service_rounded, color: AppColors.primaryLight, size: AppSizes.iconSm), const SizedBox(width: AppSpacing.sm), Expanded(child: Text(data.service, style: AppTextStyles.bodySmall.copyWith(color: AppColors.white)))]),
        const SizedBox(height: AppSpacing.xs),
        Row(children: [const Icon(Icons.location_on_rounded, color: AppColors.primaryLight, size: AppSizes.iconSm), const SizedBox(width: AppSpacing.sm), Expanded(child: Text(data.location, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodySmall.copyWith(color: AppColors.white70)))]),
      ]),
    );
  }
}

class _CurrentStatusCard extends StatelessWidget {
  final String title;
  final String description;
  final String eta;
  const _CurrentStatusCard({required this.title, required this.description, required this.eta});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(.08), borderRadius: BorderRadius.circular(AppSizes.radiusXl), border: Border.all(color: AppColors.primary.withOpacity(.25))),
      child: Row(children: [
        TweenAnimationBuilder<double>(tween: Tween(begin: .9, end: 1), duration: const Duration(milliseconds: 700), curve: Curves.easeInOut, builder: (context, scale, child) => Transform.scale(scale: scale, child: child), child: const _StatusIcon()),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l10n.currentStatus, style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark)), const SizedBox(height: AppSpacing.xs), Text(title, style: AppTextStyles.heading3), const SizedBox(height: AppSpacing.xs), Text(description, style: AppTextStyles.bodySmall)])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(l10n.eta, style: AppTextStyles.caption), const SizedBox(height: AppSpacing.xs), Text(eta, style: AppTextStyles.heading3.copyWith(color: AppColors.primaryDark))]),
      ]),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(AppSpacing.md), decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])), child: const Icon(Icons.near_me_rounded, color: AppColors.white, size: AppSizes.iconLg));
}

class _ProviderTrackingCard extends StatelessWidget {
  final JobTrackingData data;
  final VoidCallback onTap;
  final VoidCallback onChat;
  const _ProviderTrackingCard({required this.data, required this.onTap, required this.onChat});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = data.provider;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppSizes.radiusXl), border: Border.all(color: AppColors.border), boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(.06), blurRadius: AppSpacing.lg, offset: const Offset(0, AppSpacing.sm))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [CircleAvatar(radius: AppSizes.avatarMedium / 2, backgroundColor: AppColors.primary.withOpacity(.12), child: Text(provider.name.characters.first.toUpperCase(), style: AppTextStyles.label.copyWith(color: AppColors.primaryDark))), const SizedBox(width: AppSpacing.md), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Flexible(child: Text(provider.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.heading3)), if (provider.isVerified) const Padding(padding: EdgeInsets.only(left: AppSpacing.xs), child: Icon(Icons.verified_rounded, color: AppColors.primary, size: AppSizes.iconSm))]), const SizedBox(height: AppSpacing.xs), Text(provider.profession, style: AppTextStyles.bodySmall)])), const Icon(Icons.chevron_right_rounded, color: AppColors.textLight)]),
          const SizedBox(height: AppSpacing.lg),
          Row(children: [Expanded(child: _ProviderMetric(icon: Icons.star_rounded, value: provider.rating.toStringAsFixed(1), color: AppColors.warning)), Expanded(child: _ProviderMetric(icon: Icons.near_me_rounded, value: data.distance, color: AppColors.primaryDark)), Expanded(child: _ProviderMetric(icon: Icons.timer_outlined, value: data.eta, color: AppColors.secondary))]),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.providerArea, style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.xs),
          Text(data.providerArea, style: AppTextStyles.bodySmall),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(onPressed: onChat, icon: const Icon(Icons.chat_bubble_outline_rounded), label: Text(l10n.chat), style: OutlinedButton.styleFrom(foregroundColor: AppColors.secondary, minimumSize: const Size.fromHeight(AppSizes.buttonHeightSmall))),
        ]),
      ),
    );
  }
}

class _ProviderMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  const _ProviderMetric({required this.icon, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Row(children: [Icon(icon, size: AppSizes.iconSm, color: color), const SizedBox(width: AppSpacing.xs), Flexible(child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.label))]);
}

class _QuotationStatusCard extends StatelessWidget {
  final JobTrackingData data;
  const _QuotationStatusCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = data.quotationStatus!;
    final label = status == QuotationStatus.accepted
        ? l10n.statusAccepted
        : status == QuotationStatus.declined
            ? l10n.statusDeclined
            : status == QuotationStatus.negotiationRequested
                ? l10n.statusNegotiationRequested
                : status == QuotationStatus.counterOffered
                    ? l10n.statusCounterOffered
                    : l10n.statusSubmitted;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppSizes.radiusLg), border: Border.all(color: AppColors.primary.withOpacity(.24))),
      child: Row(children: [
        const Icon(Icons.receipt_long_rounded, color: AppColors.primaryDark),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l10n.quotationStatus, style: AppTextStyles.label.copyWith(color: AppColors.primaryDark)), const SizedBox(height: AppSpacing.xs), Text(label, style: AppTextStyles.bodySmall)])),
        TextButton(onPressed: () => context.push(Uri(path: RouteNames.customerQuotations, queryParameters: {'requestId': data.requestId, 'providerId': data.provider.id}).toString()), child: Text(l10n.viewQuotation)),
      ]),
    );
  }
}

class _TrackingLocationCard extends StatelessWidget {
  final JobTrackingData data;
  const _TrackingLocationCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 154,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: AppColors.secondaryDark, borderRadius: BorderRadius.circular(AppSizes.radiusXl)),
      child: Stack(children: [
        CustomPaint(size: Size.infinite, painter: _TrackingMapPainter()),
        Positioned.fill(child: Padding(padding: const EdgeInsets.all(AppSpacing.lg), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l10n.requestLocation, style: AppTextStyles.label.copyWith(color: AppColors.white70)), const Spacer(), Row(children: [const Icon(Icons.location_on_rounded, color: AppColors.primaryLight), const SizedBox(width: AppSpacing.sm), Expanded(child: Text(data.location, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodySmall.copyWith(color: AppColors.white))), const SizedBox(width: AppSpacing.md), Text(l10n.liveLocationNotAvailable, style: AppTextStyles.caption.copyWith(color: AppColors.white70))])]))),
      ]),
    );
  }
}

class _TrackingMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()..color = AppColors.secondaryLight.withOpacity(.32)..strokeWidth = 2;
    for (var i = -2; i < 8; i++) {
      canvas.drawLine(Offset(i * 68, 0), Offset(i * 68 + 110, size.height), road);
    }
    for (var i = 1; i < 5; i++) {
      canvas.drawLine(Offset(0, i * 38), Offset(size.width, i * 38 - 18), road);
    }
    final dot = Paint()..color = AppColors.primary.withOpacity(.20);
    canvas.drawCircle(Offset(size.width * .28, size.height * .42), 28, dot);
    canvas.drawCircle(Offset(size.width * .72, size.height * .28), 20, dot);
  }

  @override
  bool shouldRepaint(covariant _TrackingMapPainter oldDelegate) => false;
}

class _TrackingTimeline extends StatefulWidget {
  final List<TrackingEvent> events;
  const _TrackingTimeline({required this.events});

  @override
  State<_TrackingTimeline> createState() => _TrackingTimelineState();
}

class _TrackingTimelineState extends State<_TrackingTimeline> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 850))..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: List.generate(widget.events.length, (index) {
      final event = widget.events[index];
      final start = (index / widget.events.length).clamp(0.0, .82).toDouble();
      final end = (start + .28).clamp(0.0, 1.0).toDouble();
      final animation = CurvedAnimation(parent: _controller, curve: Interval(start, end, curve: Curves.easeOutCubic));
      return _TimelineEvent(event: event, isLast: index == widget.events.length - 1, animation: animation);
    }));
  }
}

class _TimelineEvent extends StatelessWidget {
  final TrackingEvent event;
  final bool isLast;
  final Animation<double> animation;
  const _TimelineEvent({required this.event, required this.isLast, required this.animation});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FadeTransition(opacity: animation, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, .04), end: Offset.zero).animate(animation), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Column(children: [AnimatedContainer(duration: const Duration(milliseconds: 220), width: AppSizes.iconLg, height: AppSizes.iconLg, decoration: BoxDecoration(shape: BoxShape.circle, color: event.isCompleted || event.isCurrent ? AppColors.primary : AppColors.card, border: Border.all(color: event.isCompleted || event.isCurrent ? AppColors.primary : AppColors.border, width: event.isCurrent ? AppSizes.borderWidthFocused : AppSizes.borderWidth)), child: Icon(event.isCompleted ? Icons.check_rounded : _icon(event.status), size: AppSizes.iconSm, color: event.isCompleted || event.isCurrent ? AppColors.white : AppColors.textLight)), if (!isLast) Container(width: AppSizes.borderWidthFocused, height: 74, color: event.isCompleted ? AppColors.primary : AppColors.border)]), const SizedBox(width: AppSpacing.md), Expanded(child: Container(margin: const EdgeInsets.only(bottom: AppSpacing.md), padding: const EdgeInsets.all(AppSpacing.lg), decoration: BoxDecoration(color: event.isCurrent ? AppColors.primary.withOpacity(.09) : AppColors.card, borderRadius: BorderRadius.circular(AppSizes.radiusLg), border: Border.all(color: event.isCurrent ? AppColors.primary : AppColors.border, width: event.isCurrent ? AppSizes.borderWidthFocused : AppSizes.borderWidth)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(_title(l10n, event.titleKey), style: AppTextStyles.heading3)), Text(_time(l10n, event.timeKey), style: AppTextStyles.caption)]), const SizedBox(height: AppSpacing.xs), Text(_description(l10n, event.descriptionKey), style: AppTextStyles.bodySmall)])))])));
  }

  IconData _icon(JobTrackingStatus status) { switch (status) { case JobTrackingStatus.requestCreated: return Icons.receipt_long_rounded; case JobTrackingStatus.providerSelected: return Icons.person_pin_rounded; case JobTrackingStatus.providerAccepted: return Icons.check_circle_rounded; case JobTrackingStatus.providerDeclined: return Icons.cancel_rounded; case JobTrackingStatus.providerOnTheWay: return Icons.near_me_rounded; case JobTrackingStatus.providerArrived: return Icons.location_on_rounded; case JobTrackingStatus.serviceInProgress: return Icons.build_circle_rounded; case JobTrackingStatus.serviceCompleted: return Icons.task_alt_rounded; } }
  String _title(AppLocalizations l10n, String key) { switch (key) { case 'statusRequestCreated': return l10n.statusRequestCreated; case 'statusProviderSelected': return l10n.statusProviderSelected; case 'statusOnTheWay': return l10n.statusOnTheWay; case 'statusArrived': return l10n.statusArrived; case 'statusInProgress': return l10n.statusInProgress; case 'statusCompleted': return l10n.statusCompleted; default: return l10n.currentStatus; } }
  String _time(AppLocalizations l10n, String key) {
    switch (key) {
      case 'trackingEarlier': return l10n.trackingEarlier;
      case 'trackingMomentAgo': return l10n.trackingMomentAgo;
      case 'trackingNow': return l10n.trackingNow;
      case 'trackingUpcoming': return l10n.trackingUpcoming;
      default: return l10n.lastUpdated;
    }
  }

  String _description(AppLocalizations l10n, String key) { switch (key) { case 'statusRequestCreatedDescription': return l10n.statusRequestCreatedDescription; case 'statusProviderSelectedDescription': return l10n.statusProviderSelectedDescription; case 'statusOnTheWayDescription': return l10n.statusOnTheWayDescription; case 'statusArrivedDescription': return l10n.statusArrivedDescription; case 'statusInProgressDescription': return l10n.statusInProgressDescription; case 'statusCompletedDescription': return l10n.statusCompletedDescription; default: return l10n.trackingForRequest; } }
}

class _TrackingLoadingScaffold extends StatelessWidget {
  const _TrackingLoadingScaffold();
  @override
  Widget build(BuildContext context) => const Scaffold(backgroundColor: AppColors.scaffoldBackground, body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
}

class _TrackingLoadingView extends StatelessWidget {
  const _TrackingLoadingView();
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(AppSpacing.xxl), children: [Container(height: 160, decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(.18), borderRadius: BorderRadius.circular(AppSizes.radiusXl))), const SizedBox(height: AppSpacing.lg), Container(height: 118, decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(.14), borderRadius: BorderRadius.circular(AppSizes.radiusXl))), const SizedBox(height: AppSpacing.lg), ...List.generate(4, (index) => Container(margin: const EdgeInsets.only(bottom: AppSpacing.md), height: 72, decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(.10), borderRadius: BorderRadius.circular(AppSizes.radiusLg))))]);
}

class _TrackingError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const _TrackingError({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(AppSpacing.xxl), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.location_searching_rounded, color: AppColors.primaryDark, size: AppSizes.iconXl), const SizedBox(height: AppSpacing.lg), Text(message, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium), if (onRetry != null) TextButton(onPressed: onRetry, child: Text(AppLocalizations.of(context)!.retry))])));
}
