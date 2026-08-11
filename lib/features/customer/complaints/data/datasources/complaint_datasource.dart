import 'package:image_picker/image_picker.dart';

import '../../domain/entities/complaint_entities.dart';
import '../models/complaint_model.dart';
import '../stores/complaint_runtime_store.dart';

abstract interface class ComplaintDataSource {
  Future<ComplaintModel> submit(ComplaintDraft draft);
  Future<ComplaintModel?> get({required String requestId, required String customerId, required String providerId});
  Future<List<ComplaintAttachment>> pickImages({required int remaining});
}

class ComplaintLocalDataSource implements ComplaintDataSource {
  final ComplaintRuntimeStore _store;
  const ComplaintLocalDataSource(this._store);
  @override
  Future<ComplaintModel> submit(ComplaintDraft draft) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return ComplaintModel(_store.submit(draft));
  }
  @override
  Future<ComplaintModel?> get({required String requestId, required String customerId, required String providerId}) async {
    final complaint = _store.get(requestId: requestId, customerId: customerId, providerId: providerId);
    return complaint == null ? null : ComplaintModel(complaint);
  }
  @override
  Future<List<ComplaintAttachment>> pickImages({required int remaining}) async {
    if (remaining <= 0) return const [];
    final files = await ImagePicker().pickMultiImage(imageQuality: 85);
    return Future.wait(files.take(remaining).map((file) async => ComplaintAttachment(path: file.path, name: file.name, bytes: await file.readAsBytes())));
  }
}
