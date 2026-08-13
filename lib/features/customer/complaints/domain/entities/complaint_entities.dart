import 'dart:typed_data';
import '../../../job_request/domain/entities/job_request_entities.dart';

class ComplaintCategory {
  final String id;
  final String labelKey;
  final int iconCodePoint;
  const ComplaintCategory({required this.id, required this.labelKey, required this.iconCodePoint});
}

class ComplaintAttachment { final String path; final String name; final Uint8List? bytes; const ComplaintAttachment({required this.path, required this.name, this.bytes}); }

enum ComplaintStatus { submitted, underReview, resolved, rejected }

class Complaint {
  final String complaintId, requestId, providerId, customerId, categoryId, description;
  final List<ComplaintAttachment> attachments;
  final ComplaintStatus status;
  final DateTime createdAt;
  const Complaint({required this.complaintId, required this.requestId, required this.providerId, required this.customerId, required this.categoryId, required this.description, required this.attachments, required this.status, required this.createdAt});
}
class ComplaintDraft { final String requestId, providerId, customerId, categoryId, description; final List<ComplaintAttachment> attachments; const ComplaintDraft({required this.requestId,required this.providerId,required this.customerId,required this.categoryId,required this.description,required this.attachments}); }
enum ComplaintFailureCode { invalidRequest, unauthorized, notCompleted, quotationNotAccepted, alreadyExists, invalidCategory, invalidDescription, notFound, unknown }
class ComplaintException implements Exception { final ComplaintFailureCode code; const ComplaintException(this.code); }
