import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/profile_entities.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_datasource.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) => ProfileRepositoryImpl(ProfileLocalDataSource(ref.watch(profilePrefsProvider))));
final profilePrefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError('Profile preferences must be overridden at bootstrap'));

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDataSource _source;
  const ProfileRepositoryImpl(this._source);
  @override Future<ProfileStatus> status(String id, ProfileRole role) => _source.status(id, role);
  @override Future<CustomerProfile> saveCustomer(String id, CustomerProfileDraft d) async { await _source.saveCustomer(id, d); return CustomerProfile(userId: id, fullName: d.fullName, addressLine: d.addressLine, city: d.city, area: d.area, latitude: d.latitude, longitude: d.longitude, photoPath: d.photoPath); }
  @override Future<ProviderProfile> saveProvider(String id, ProviderProfileDraft d) async { await _source.saveProvider(id, d); return ProviderProfile(userId: id, fullName: d.fullName, cnicNumber: d.cnicNumber, area: d.area, city: d.city, latitude: d.latitude, longitude: d.longitude, yearsExperience: d.yearsExperience, shopLocation: d.shopLocation, photoPath: d.photoPath, cnicFrontPath: d.cnicFrontPath, cnicBackPath: d.cnicBackPath); }
}
