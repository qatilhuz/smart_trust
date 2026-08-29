import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/entities/profile_entities.dart';
import '../../features/profile/domain/usecases/profile_usecases.dart';
final profileStatusProvider=FutureProvider<ProfileStatus?>((ref)async{final user=await ref.watch(authStateProvider.future);if(user==null)return null;final role=user.role.toLowerCase()=='provider'?ProfileRole.provider:ProfileRole.customer;return CheckProfileStatus(ref.watch(profileRepositoryProvider)).call(user.id,role);});
