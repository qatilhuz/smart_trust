import '../../../../customer/complaints/domain/entities/complaint_entities.dart';
import '../repositories/provider_complaint_repository.dart';
class GetProviderComplaint { final ProviderComplaintRepository _repository; const GetProviderComplaint(this._repository); Future<Complaint?> call({required String requestId,required String providerId}) => _repository.get(requestId:requestId,providerId:providerId); }
