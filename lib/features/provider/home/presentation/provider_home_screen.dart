import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../l10n/app_localizations.dart';

class ProviderHomeScreen extends ConsumerWidget {
  const ProviderHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      drawer: const AppDrawer(variant: AppDrawerVariant.provider),
      appBar: AppBar(
        title: const Text('Provider Status'),
        leading: HamburgerMenuButton(tooltip: l10n.menu),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Verification Status', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.secondary)),
            const SizedBox(height: 16),
            _StatusCard(title: 'Profile Submitted', done: true),
            _StatusCard(title: 'CNIC Uploaded', done: true),
            _StatusCard(title: 'Tasdeeq Verification', done: true),
            _StatusCard(title: 'Admin Review', done: false),
            _StatusCard(title: 'Profile Active', done: false),
            const Spacer(),
            ElevatedButton(onPressed: () => context.push(RouteNames.providerRegistration), child: const Text('Complete Registration')),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final bool done;
  const _StatusCard({required this.title, required this.done});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(done ? Icons.check_circle : Icons.pending, color: done ? AppColors.success : AppColors.warning),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: done ? AppColors.textPrimary : AppColors.textSecondary)),
        subtitle: Text(done ? 'Completed' : 'Pending', style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}
