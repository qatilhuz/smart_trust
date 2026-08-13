import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/job_request_entities.dart';
import '../../domain/repositories/job_request_repositories.dart';
import '../datasources/job_request_datasources.dart';

final jobRequestCategoryRepositoryProvider = Provider<JobRequestCategoryRepository>((ref) {
  return JobRequestCategoryRepositoryImpl(JobRequestLocalCategoryDataSource());
});

final jobRequestMediaRepositoryProvider = Provider<JobRequestMediaRepository>((ref) {
  return JobRequestMediaRepositoryImpl(JobRequestImagePickerDataSource());
});

final jobRequestLocationRepositoryProvider = Provider<JobRequestLocationRepository>((ref) {
  return JobRequestLocationRepositoryImpl(JobRequestLocationDataSourceImpl());
});

final jobRequestSubmissionRepositoryProvider = Provider<JobRequestSubmissionRepository>((ref) {
  return JobRequestSubmissionRepositoryImpl(JobRequestLocalSubmissionDataSource());
});

class JobRequestCategoryRepositoryImpl implements JobRequestCategoryRepository {
  final JobRequestCategoryDataSource _dataSource;

  const JobRequestCategoryRepositoryImpl(this._dataSource);

  @override
  Future<List<RequestCategory>> fetchCategories() async {
    final models = await _dataSource.fetchCategories();
    return models.map((model) => model.toEntity()).toList(growable: false);
  }
}

class JobRequestMediaRepositoryImpl implements JobRequestMediaRepository {
  final JobRequestMediaDataSource _dataSource;

  const JobRequestMediaRepositoryImpl(this._dataSource);

  @override
  Future<List<RequestAttachment>> pickImages({required int remainingSlots}) {
    return _dataSource.pickImages(remainingSlots: remainingSlots);
  }
}

class JobRequestLocationRepositoryImpl implements JobRequestLocationRepository {
  final JobRequestLocationDataSource _dataSource;

  const JobRequestLocationRepositoryImpl(this._dataSource);

  @override
  Future<LocationResult> getCurrentLocation() => _dataSource.getCurrentLocation();
}

class JobRequestSubmissionRepositoryImpl implements JobRequestSubmissionRepository {
  final JobRequestSubmissionDataSource _dataSource;

  const JobRequestSubmissionRepositoryImpl(this._dataSource);

  @override
  Future<CreatedJobRequest> submit({
    required RequestCategory category,
    required String description,
    required List<RequestAttachment> attachments,
    required RequestLocation location,
    required String customerId,
  }) async {
    final model = await _dataSource.submit(
      category: category,
      description: description,
      attachments: attachments,
      location: location,
      customerId: customerId,
    );
    return model.toEntity(
      category: category,
      description: description,
      attachments: attachments,
      location: location,
    );
  }
}
