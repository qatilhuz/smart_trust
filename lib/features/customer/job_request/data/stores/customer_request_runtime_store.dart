import '../../domain/entities/job_request_entities.dart';

class LocalCustomerRequestRecord {
  final String requestId;
  final String customerId;
  final String? providerId;
  final RequestCategory category;
  final String description;
  final RequestLocation location;
  final int attachmentCount;
  final RequestLifecycleStatus status;

  const LocalCustomerRequestRecord({
    required this.requestId,
    required this.customerId,
    required this.providerId,
    required this.category,
    required this.description,
    required this.location,
    required this.attachmentCount,
    required this.status,
  });

  LocalCustomerRequestRecord copyWith({
    String? providerId,
    RequestLifecycleStatus? status,
  }) {
    return LocalCustomerRequestRecord(
      requestId: requestId,
      customerId: customerId,
      providerId: providerId ?? this.providerId,
      category: category,
      description: description,
      location: location,
      attachmentCount: attachmentCount,
      status: status ?? this.status,
    );
  }
}

/// Small in-memory request store shared by the local customer/provider demo.
/// A remote datasource can replace this store later without changing UI.
class CustomerRequestRuntimeStore {
  CustomerRequestRuntimeStore._() {
    _records['local-request-demo'] = const LocalCustomerRequestRecord(
      requestId: 'local-request-demo',
      customerId: '1',
      providerId: 'provider-ali-hussain',
      category: RequestCategory(id: 'hvac', nameKey: 'serviceCategoryHvac', descriptionKey: 'categoryHvacDescription', iconCodePoint: 0xe1b0),
      description: 'Existing local demo request',
      location: RequestLocation(address: 'Lahore'),
      attachmentCount: 0,
      status: RequestLifecycleStatus.providerSelected,
    );
  }

  static final CustomerRequestRuntimeStore instance = CustomerRequestRuntimeStore._();
  final Map<String, LocalCustomerRequestRecord> _records = {};

  void create({
    required String requestId,
    required String customerId,
    required RequestCategory category,
    required String description,
    required RequestLocation location,
    required int attachmentCount,
  }) {
    _records[requestId] = LocalCustomerRequestRecord(
      requestId: requestId,
      customerId: customerId,
      providerId: null,
      category: category,
      description: description,
      location: location,
      attachmentCount: attachmentCount,
      status: RequestLifecycleStatus.created,
    );
  }

  LocalCustomerRequestRecord? get(String requestId) => _records[requestId];

  List<LocalCustomerRequestRecord> get all => List.unmodifiable(_records.values);

  bool assignProvider({required String requestId, required String providerId}) {
    final record = _records[requestId];
    if (record == null ||
        (record.status != RequestLifecycleStatus.created &&
            record.status != RequestLifecycleStatus.providerSelected)) {
      return false;
    }
    _records[requestId] = record.copyWith(
      providerId: providerId,
      status: RequestLifecycleStatus.providerSelected,
    );
    return true;
  }

  bool updateStatus({
    required String requestId,
    required String providerId,
    required RequestLifecycleStatus status,
  }) {
    final record = _records[requestId];
    if (record == null || record.providerId != providerId) return false;
    if (record.status != RequestLifecycleStatus.providerSelected) return false;
    _records[requestId] = record.copyWith(status: status);
    return true;
  }

  bool completeService({required String requestId, required String providerId}) {
    final record = _records[requestId];
    if (record == null || record.providerId != providerId) return false;
    if (record.status != RequestLifecycleStatus.accepted) return false;
    _records[requestId] = record.copyWith(status: RequestLifecycleStatus.serviceCompleted);
    return true;
  }
}
