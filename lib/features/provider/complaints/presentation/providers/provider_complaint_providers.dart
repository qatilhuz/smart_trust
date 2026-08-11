import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../customer/complaints/domain/entities/complaint_entities.dart';
import '../../data/repositories/provider_complaint_repository_impl.dart';
import '../../domain/usecases/get_provider_complaint.dart';
final providerComplaintProvider=FutureProvider.autoDispose.family<Complaint?,({String requestId,String providerId})>((ref,q)=>GetProviderComplaint(ref.watch(providerComplaintRepositoryProvider)).call(requestId:q.requestId,providerId:q.providerId));
