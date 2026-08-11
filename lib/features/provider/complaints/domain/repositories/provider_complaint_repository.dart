import '../../../../customer/complaints/domain/entities/complaint_entities.dart';
abstract interface class ProviderComplaintRepository { Future<Complaint?> get({required String requestId, required String providerId}); }
