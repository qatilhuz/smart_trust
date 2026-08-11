import '../../../job_request/data/stores/customer_request_runtime_store.dart';
import '../../../job_request/domain/entities/job_request_entities.dart';
import '../../../../quotation/data/stores/quotation_runtime_store.dart';
import '../../../../quotation/domain/entities/quotation_entities.dart';
import '../../domain/entities/complaint_entities.dart';

class ComplaintRuntimeStore {
  ComplaintRuntimeStore._(this._requests,this._quotations);
  static final instance=ComplaintRuntimeStore._(CustomerRequestRuntimeStore.instance,QuotationRuntimeStore.instance);
  final CustomerRequestRuntimeStore _requests; final QuotationRuntimeStore _quotations; final Map<String,Complaint> _items={};
  Complaint submit(ComplaintDraft draft){
    final r=_requests.get(draft.requestId); if(r==null)throw const ComplaintException(ComplaintFailureCode.invalidRequest);
    if(r.customerId!=draft.customerId||r.providerId!=draft.providerId)throw const ComplaintException(ComplaintFailureCode.unauthorized);
    if(r.status!=RequestLifecycleStatus.serviceCompleted)throw const ComplaintException(ComplaintFailureCode.notCompleted);
    try{if(_quotations.get(requestId:draft.requestId,providerId:draft.providerId).status!=QuotationStatus.accepted)throw const ComplaintException(ComplaintFailureCode.quotationNotAccepted);}on QuotationException{throw const ComplaintException(ComplaintFailureCode.quotationNotAccepted);}
    if(draft.description.trim().isEmpty)throw const ComplaintException(ComplaintFailureCode.invalidDescription);
    final key='${draft.requestId}::${draft.customerId}::${draft.providerId}';if(_items.containsKey(key))throw const ComplaintException(ComplaintFailureCode.alreadyExists);
    final c=Complaint(complaintId:'local-complaint-${DateTime.now().microsecondsSinceEpoch}',requestId:draft.requestId,providerId:draft.providerId,customerId:draft.customerId,categoryId:draft.categoryId,description:draft.description.trim(),attachments:List.unmodifiable(draft.attachments),status:ComplaintStatus.submitted,createdAt:DateTime.now());_items[key]=c;return c;
  }
  Complaint? get({required String requestId,required String customerId,required String providerId}){final r=_requests.get(requestId);if(r==null||r.customerId!=customerId||r.providerId!=providerId)throw const ComplaintException(ComplaintFailureCode.unauthorized);return _items['$requestId::$customerId::$providerId'];}
  Complaint? getForProvider({required String requestId, required String providerId}) { final r=_requests.get(requestId); if (r == null || r.providerId != providerId) throw const ComplaintException(ComplaintFailureCode.unauthorized); for (final item in _items.values) { if (item.requestId == requestId && item.providerId == providerId) return item; } return null; }
}
