import '../entities/complaint_entities.dart';
abstract interface class ComplaintRepository { Future<Complaint> submit(ComplaintDraft draft); Future<Complaint?> get({required String requestId,required String customerId,required String providerId}); Future<List<ComplaintAttachment>> pickImages({required int remaining}); }
