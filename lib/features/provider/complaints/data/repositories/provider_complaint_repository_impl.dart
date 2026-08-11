import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../customer/complaints/data/stores/complaint_runtime_store.dart';
import '../../../../customer/complaints/domain/entities/complaint_entities.dart';
import '../../domain/repositories/provider_complaint_repository.dart';
import '../datasources/provider_complaint_datasource.dart';
final providerComplaintRepositoryProvider=Provider<ProviderComplaintRepository>((ref)=>ProviderComplaintRepositoryImpl(ProviderComplaintLocalDataSource(ComplaintRuntimeStore.instance)));
class ProviderComplaintRepositoryImpl implements ProviderComplaintRepository { final ProviderComplaintDataSource _source; const ProviderComplaintRepositoryImpl(this._source); @override Future<Complaint?> get({required String requestId,required String providerId})=>_source.get(requestId:requestId,providerId:providerId); }
