import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/job_request_repository_impl.dart';
import '../../domain/entities/job_request_entities.dart';
import '../../domain/entities/job_request_state.dart';
import '../../domain/usecases/job_request_usecases.dart';

final getRequestCategoriesProvider = Provider<GetRequestCategories>((ref) {
  return GetRequestCategories(ref.watch(jobRequestCategoryRepositoryProvider));
});

final pickRequestImagesProvider = Provider<PickRequestImages>((ref) {
  return PickRequestImages(ref.watch(jobRequestMediaRepositoryProvider));
});

final getCurrentRequestLocationProvider = Provider<GetCurrentRequestLocation>((ref) {
  return GetCurrentRequestLocation(ref.watch(jobRequestLocationRepositoryProvider));
});

final submitJobRequestProvider = Provider<SubmitJobRequest>((ref) {
  return SubmitJobRequest(ref.watch(jobRequestSubmissionRepositoryProvider));
});

final requestCategoriesProvider = FutureProvider.autoDispose<List<RequestCategory>>((ref) {
  return ref.watch(getRequestCategoriesProvider).call();
});

final jobRequestFlowProvider = StateNotifierProvider.autoDispose<JobRequestFlowNotifier, JobRequestState>((ref) {
  return JobRequestFlowNotifier(ref);
});

class JobRequestFlowNotifier extends StateNotifier<JobRequestState> {
  final Ref _ref;

  JobRequestFlowNotifier(this._ref) : super(const JobRequestState());

  void selectCategory(RequestCategory category) {
    state = state.copyWith(category: category);
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  Future<void> addImages() async {
    final remaining = AppConstants.maxRequestImages - state.attachments.length;
    if (remaining <= 0) return;
    try {
      final images = await _ref.read(pickRequestImagesProvider).call(remainingSlots: remaining);
      if (images.isEmpty) return;
      state = state.copyWith(
        attachments: [...state.attachments, ...images]
            .take(AppConstants.maxRequestImages)
            .toList(growable: false),
      );
    } catch (_) {
      // Media selection is optional; cancellation or platform failure should
      // leave the request draft intact.
    }
  }

  void removeImage(int index) {
    final updated = [...state.attachments]..removeAt(index);
    state = state.copyWith(attachments: updated);
  }

  Future<LocationResult> useCurrentLocation() async {
    try {
      return await _ref.read(getCurrentRequestLocationProvider).call();
    } catch (_) {
      return const LocationResult(status: LocationResultStatus.unavailable);
    }
  }

  void setLocation(RequestLocation location) {
    state = state.copyWith(location: location);
  }

  void resetSubmission() {
    state = state.copyWith(submissionStatus: JobRequestSubmissionStatus.idle);
  }

  Future<void> submit() async {
    final category = state.category;
    final location = state.location;
    if (category == null || location == null || state.description.trim().isEmpty) return;

    state = state.copyWith(submissionStatus: JobRequestSubmissionStatus.submitting);
    try {
      final created = await _ref.read(submitJobRequestProvider).call(
            category: category,
            description: state.description.trim(),
            attachments: state.attachments,
            location: location,
            customerId: _ref.read(authStateProvider).valueOrNull?.id ?? '1',
          );
      state = state.copyWith(
        submissionStatus: JobRequestSubmissionStatus.success,
        submittedRequestId: created.id,
      );
    } catch (_) {
      state = state.copyWith(submissionStatus: JobRequestSubmissionStatus.failure);
    }
  }
}
