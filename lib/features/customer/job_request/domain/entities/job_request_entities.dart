import 'dart:typed_data';

enum RequestLifecycleStatus { created, providerSelected, accepted, declined, serviceCompleted }

class RequestCategory {
  final String id;
  final String nameKey;
  final String descriptionKey;
  final int iconCodePoint;

  const RequestCategory({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.iconCodePoint,
  });
}

class RequestAttachment {
  final String path;
  final String name;
  final Uint8List? bytes;

  const RequestAttachment({required this.path, required this.name, this.bytes});
}

class RequestLocation {
  final double? latitude;
  final double? longitude;
  final String address;

  const RequestLocation({
    this.latitude,
    this.longitude,
    required this.address,
  });
}

class CreatedJobRequest {
  final String id;
  final RequestCategory category;
  final String description;
  final List<RequestAttachment> attachments;
  final RequestLocation location;

  const CreatedJobRequest({
    required this.id,
    required this.category,
    required this.description,
    required this.attachments,
    required this.location,
  });
}

enum LocationResultStatus {
  granted,
  denied,
  permanentlyDenied,
  unavailable,
}

class LocationResult {
  final LocationResultStatus status;
  final RequestLocation? location;

  const LocationResult({required this.status, this.location});
}
