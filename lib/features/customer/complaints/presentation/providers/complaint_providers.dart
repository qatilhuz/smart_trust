import 'package:flutter_riverpod/flutter_riverpod.dart';import '../../data/repositories/complaint_repository_impl.dart';import '../../domain/entities/complaint_entities.dart';import '../../domain/usecases/complaint_usecases.dart';
final submitComplaintProvider=Provider<SubmitComplaint>((ref)=>SubmitComplaint(ref.watch(complaintRepositoryProvider)));
final pickComplaintImagesProvider=Provider<PickComplaintImages>((ref)=>PickComplaintImages(ref.watch(complaintRepositoryProvider)));
final complaintProvider=FutureProvider.autoDispose.family<Complaint?,({String requestId,String customerId,String providerId})>((ref,q)=>GetComplaint(ref.watch(complaintRepositoryProvider)).call(requestId:q.requestId,customerId:q.customerId,providerId:q.providerId));
