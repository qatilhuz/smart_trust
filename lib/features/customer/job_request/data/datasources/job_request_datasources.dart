import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../models/job_request_models.dart';
import '../../domain/entities/job_request_entities.dart';
import '../stores/customer_request_runtime_store.dart';

abstract interface class JobRequestCategoryDataSource {
  Future<List<RequestCategoryModel>> fetchCategories();
}

abstract interface class JobRequestMediaDataSource {
  Future<List<RequestAttachment>> pickImages({required int remainingSlots});
}

abstract interface class JobRequestLocationDataSource {
  Future<LocationResult> getCurrentLocation();
}

abstract interface class JobRequestSubmissionDataSource {
  Future<RequestSubmissionModel> submit({
    required RequestCategory category,
    required String description,
    required List<RequestAttachment> attachments,
    required RequestLocation location,
    required String customerId,
  });
}

class JobRequestLocalCategoryDataSource implements JobRequestCategoryDataSource {
  @override
  Future<List<RequestCategoryModel>> fetchCategories() async {
    return const [
      RequestCategoryModel(
        id: 'hvac',
        nameKey: 'serviceCategoryHvac',
        descriptionKey: 'categoryHvacDescription',
        iconCodePoint: 0xe1b0,
      ),
      RequestCategoryModel(
        id: 'electrical',
        nameKey: 'categoryElectrical',
        descriptionKey: 'categoryElectricalDescription',
        iconCodePoint: 0xe30d,
      ),
      RequestCategoryModel(
        id: 'plumbing',
        nameKey: 'categoryPlumbing',
        descriptionKey: 'categoryPlumbingDescription',
        iconCodePoint: 0xe80e,
      ),
      RequestCategoryModel(
        id: 'painting',
        nameKey: 'categoryPainting',
        descriptionKey: 'categoryPaintingDescription',
        iconCodePoint: 0xe3b6,
      ),
      RequestCategoryModel(
        id: 'cleaning',
        nameKey: 'categoryCleaning',
        descriptionKey: 'categoryCleaningDescription',
        iconCodePoint: 0xe14f,
      ),
    ];
  }
}

class JobRequestImagePickerDataSource implements JobRequestMediaDataSource {
  final ImagePicker _picker;

  JobRequestImagePickerDataSource([ImagePicker? picker]) 
      : _picker = picker ?? ImagePicker(); 

  @override
  Future<List<RequestAttachment>> pickImages({required int remainingSlots}) async {
    if (remainingSlots <= 0) return const [];
    final files = await _picker.pickMultiImage(imageQuality: 85);
    final selected = files.take(remainingSlots).toList(growable: false);
    return Future.wait(
      selected.map(
        (file) async => RequestAttachment(
          path: file.path,
          name: file.name,
          bytes: await file.readAsBytes(),
        ),
      ),
    );
  }
}

class JobRequestLocationDataSourceImpl implements JobRequestLocationDataSource {
  @override
  Future<LocationResult> getCurrentLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      return const LocationResult(status: LocationResultStatus.unavailable);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      return const LocationResult(status: LocationResultStatus.denied);
    }
    if (permission == LocationPermission.deniedForever) {
      return const LocationResult(status: LocationResultStatus.permanentlyDenied);
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    final place = placemarks.isEmpty ? null : placemarks.first;
    final address = [
      place?.street,
      place?.subLocality,
      place?.locality,
      place?.country,
    ].whereType<String>().where((part) => part.trim().isNotEmpty).join(', ');

    return LocationResult(
      status: LocationResultStatus.granted,
      location: RequestLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      ),
    );
  }
}

class JobRequestLocalSubmissionDataSource implements JobRequestSubmissionDataSource {
  @override
  Future<RequestSubmissionModel> submit({
    required RequestCategory category,
    required String description,
    required List<RequestAttachment> attachments,
    required RequestLocation location,
    required String customerId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final requestId = 'local-request-${DateTime.now().millisecondsSinceEpoch}';
    CustomerRequestRuntimeStore.instance.create(
      requestId: requestId,
      customerId: customerId,
      category: category,
      description: description,
      location: location,
      attachmentCount: attachments.length,
    );
    return RequestSubmissionModel(requestId);
  }
}
