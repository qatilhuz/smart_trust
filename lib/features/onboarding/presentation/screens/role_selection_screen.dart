import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Select Role', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.secondary)),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: () async { final p = await SharedPreferences.getInstance(); await p.setString('user_role', 'customer'); context.go(RouteNames.login); }, child: const Text('Customer')),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () async { final p = await SharedPreferences.getInstance(); await p.setString('user_role', 'provider'); context.go(RouteNames.providerRegistration); }, child: const Text('Service Provider')),
            ],
          ),
        ),
      ),
    );
  }
}
