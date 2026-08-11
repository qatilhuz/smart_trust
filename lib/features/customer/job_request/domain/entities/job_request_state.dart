import 'job_request_entities.dart';

enum JobRequestSubmissionStatus { idle, submitting, success, failure }

class JobRequestState {
  final RequestCategory? category;
  final String description;
  final List<RequestAttachment> attachments;
  final RequestLocation? location;
  final JobRequestSubmissionStatus submissionStatus;
  final String? submittedRequestId;

  const JobRequestState({
    this.category,
    this.description = '',
    this.attachments = const [],
    this.location,
    this.submissionStatus = JobRequestSubmissionStatus.idle,
    this.submittedRequestId,
  });

  JobRequestState copyWith({
    RequestCategory? category,
    String? description,
    List<RequestAttachment>? attachments,
    RequestLocation? location,
    JobRequestSubmissionStatus? submissionStatus,
    String? submittedRequestId,
    bool clearLocation = false,
  }) {
    return JobRequestState(
      category: category ?? this.category,
      description: description ?? this.description,
      attachments: attachments ?? this.attachments,
      location: clearLocation ? null : location ?? this.location,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      submittedRequestId: submittedRequestId ?? this.submittedRequestId,
    );
  }
}
