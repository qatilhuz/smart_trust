import '../../../../customer/complaints/data/stores/complaint_runtime_store.dart';
import '../../../../customer/complaints/domain/entities/complaint_entities.dart';
abstract interface class ProviderComplaintDataSource { Future<Complaint?> get({required String requestId,required String providerId}); }
class ProviderComplaintLocalDataSource implements ProviderComplaintDataSource { final ComplaintRuntimeStore _store; const ProviderComplaintLocalDataSource(this._store); @override Future<Complaint?> get({required String requestId,required String providerId}) async => _store.getForProvider(requestId:requestId,providerId:providerId); }
