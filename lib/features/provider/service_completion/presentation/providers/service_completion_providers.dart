import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/service_completion_repository_impl.dart';
import '../../domain/entities/service_completion_entities.dart';
import '../../domain/usecases/complete_service.dart';

final completeServiceProvider = Provider<CompleteService>((ref) => CompleteService(ref.watch(serviceCompletionRepositoryProvider)));
