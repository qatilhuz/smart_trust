import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../router/route_names.dart';

class AuthenticationPrompt extends StatelessWidget {
  final String? message;
  const AuthenticationPrompt({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(message ?? l10n.signInToContinue, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: () => context.push(RouteNames.login), child: Text(l10n.login)),
                const SizedBox(width: 12),
                OutlinedButton(onPressed: () => context.push(RouteNames.roleSelection), child: Text(l10n.createAccount)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
