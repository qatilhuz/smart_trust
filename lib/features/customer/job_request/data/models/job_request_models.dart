import '../../domain/entities/job_request_entities.dart';

class RequestCategoryModel {
  final String id;
  final String nameKey;
  final String descriptionKey;
  final int iconCodePoint;

  const RequestCategoryModel({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.iconCodePoint,
  });

  RequestCategory toEntity() => RequestCategory(
        id: id,
        nameKey: nameKey,
        descriptionKey: descriptionKey,
        iconCodePoint: iconCodePoint,
      );
}

class RequestSubmissionModel {
  final String id;

  const RequestSubmissionModel(this.id);

  CreatedJobRequest toEntity({
    required RequestCategory category,
    required String description,
    required List<RequestAttachment> attachments,
    required RequestLocation location,
  }) {
    return CreatedJobRequest(
      id: id,
      category: category,
      description: description,
      attachments: List.unmodifiable(attachments),
      location: location,
    );
  }
}
