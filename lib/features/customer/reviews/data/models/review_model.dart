import '../../domain/entities/review_entities.dart';

class ReviewModel {
  final Review value;
  const ReviewModel(this.value);
  Review toEntity() => value;
}
