import '../entities/profile_entities.dart';
import '../repositories/profile_repository.dart';
class CheckProfileStatus { final ProfileRepository repository; const CheckProfileStatus(this.repository); Future<ProfileStatus> call(String id, ProfileRole role) => repository.status(id, role); }
class SaveCustomerProfile { final ProfileRepository repository; const SaveCustomerProfile(this.repository); Future<CustomerProfile> call(String id, CustomerProfileDraft draft) => repository.saveCustomer(id, draft); }
class SaveProviderProfile { final ProfileRepository repository; const SaveProviderProfile(this.repository); Future<ProviderProfile> call(String id, ProviderProfileDraft draft) => repository.saveProvider(id, draft); }
