import '../entities/complaint_entities.dart';import '../repositories/complaint_repository.dart';
class SubmitComplaint{final ComplaintRepository _r;const SubmitComplaint(this._r);Future<Complaint> call(ComplaintDraft d)=>_r.submit(d);}
class PickComplaintImages{final ComplaintRepository _r;const PickComplaintImages(this._r);Future<List<ComplaintAttachment>> call({required int remaining})=>_r.pickImages(remaining:remaining);}
class GetComplaint{final ComplaintRepository _r;const GetComplaint(this._r);Future<Complaint?> call({required String requestId,required String customerId,required String providerId})=>_r.get(requestId:requestId,customerId:customerId,providerId:providerId);}
