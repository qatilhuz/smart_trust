import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/authentication_prompt.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../customer/reviews/domain/entities/review_entities.dart';
import 'providers/provider_review_providers.dart';

class ProviderReviewsScreen extends ConsumerWidget {
  final String providerId;
  const ProviderReviewsScreen({super.key, required this.providerId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n=AppLocalizations.of(context)!; final auth=ref.watch(authStateProvider);
    if(auth.isLoading)return const _ReviewsLoading();
    if(auth.valueOrNull?.role.toLowerCase()!='provider')return AuthenticationPrompt(message:l10n.providerOnlyMessage);
    final state=ref.watch(providerReviewSummaryProvider(providerId));
    return Scaffold(backgroundColor:AppColors.scaffoldBackground,appBar:AppBar(title:Text(l10n.providerReviews),leading:IconButton(onPressed:()=>context.pop(),tooltip:l10n.back,icon:const Icon(Icons.arrow_back_rounded))),body:state.when(loading:()=>const _ReviewsLoading(),error:(_,__)=>Center(child:Text(l10n.reviewError)),data:(summary)=>SingleChildScrollView(padding:const EdgeInsets.all(AppSpacing.xxl),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[_Summary(summary:summary),const SizedBox(height:AppSpacing.xxl),Text(l10n.reviewHistory,style:AppTextStyles.heading3),const SizedBox(height:AppSpacing.md),if(summary.reviews.isEmpty)Text(l10n.noReviews,style:AppTextStyles.bodyMedium,textAlign:TextAlign.center) else ...summary.reviews.map((r)=>Container(margin:const EdgeInsets.only(bottom:AppSpacing.md),padding:const EdgeInsets.all(AppSpacing.lg),decoration:BoxDecoration(color:AppColors.card,borderRadius:BorderRadius.circular(AppSizes.radiusLg),border:Border.all(color:AppColors.border)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('${r.rating.toStringAsFixed(0)} / 5',style:AppTextStyles.heading3),if(r.comment.isNotEmpty)Padding(padding:const EdgeInsets.only(top:AppSpacing.sm),child:Text(r.comment,style:AppTextStyles.bodySmall))])))])));}
}
class _Summary extends StatelessWidget{final ReviewSummary summary;const _Summary({required this.summary});@override Widget build(BuildContext context){final l10n=AppLocalizations.of(context)!;return Container(padding:const EdgeInsets.all(AppSpacing.xl),decoration:BoxDecoration(gradient:const LinearGradient(colors:[AppColors.secondary,AppColors.secondaryLight]),borderRadius:BorderRadius.circular(AppSizes.radiusXl)),child:Row(children:[const Icon(Icons.star_rounded,color:AppColors.warning,size:AppSizes.iconXl),const SizedBox(width:AppSpacing.lg),Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(l10n.averageRating,style:AppTextStyles.label.copyWith(color:AppColors.white70)),Text(summary.averageRating.toStringAsFixed(1),style:AppTextStyles.heading1.copyWith(color:AppColors.white)),Text('${summary.totalReviews} ${l10n.totalReviews}',style:AppTextStyles.bodySmall.copyWith(color:AppColors.white70))])]);}}
class _ReviewsLoading extends StatelessWidget{const _ReviewsLoading();@override Widget build(BuildContext context)=>const Scaffold(body:Center(child:CircularProgressIndicator(color:AppColors.primary)));}
