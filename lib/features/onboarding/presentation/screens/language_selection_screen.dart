import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/router/route_names.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Select Language', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.secondary)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: () { ref.read(localeProvider.notifier).setLocale(const Locale('en')); context.pop(); }, child: const Text('English')),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: () { ref.read(localeProvider.notifier).setLocale(const Locale('ur')); context.pop(); }, child: const Text('Urdu')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
