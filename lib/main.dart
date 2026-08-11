import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'features/splash/presentation/providers/splash_providers.dart';
import 'core/storage/secure_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final overrides = <Override>[
    splashSharedPreferencesProvider.overrideWithValue(prefs),
    splashSecureStorageProvider.overrideWithValue(const FlutterSecureStorage()),
  ];

  // Initialize secure storage if needed (ProviderScope handles overrides)
  runApp(
    ProviderScope(
      overrides: overrides,
      child: const App(),
    ),
  );
}
