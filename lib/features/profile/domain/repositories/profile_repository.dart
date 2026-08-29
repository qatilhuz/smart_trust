import '../entities/profile_entities.dart';
abstract interface class ProfileRepository { Future<ProfileStatus> status(String userId,ProfileRole role); Future<CustomerProfile> saveCustomer(String userId,CustomerProfileDraft draft); Future<ProviderProfile> saveProvider(String userId,ProviderProfileDraft draft); }
