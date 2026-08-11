import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final user = auth.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(radius: 50, backgroundColor: AppColors.primary, child: Text(user?.name ?? 'U', style: const TextStyle(fontSize: 36, color: AppColors.white, fontWeight: FontWeight.bold))),
            const SizedBox(height: 16),
            Text(user?.name ?? 'Guest', style: Theme.of(context).textTheme.headlineSmall),
            Text(user?.email ?? 'No email', style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            const Card(child: ListTile(title: Text('Trust Score'), trailing: Text('9.2', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)))),
          ],
        ),
      ),
    );
  }
}
