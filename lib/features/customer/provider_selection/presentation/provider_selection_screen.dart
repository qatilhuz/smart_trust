import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';

class ProviderSelectionScreen extends ConsumerWidget {
  const ProviderSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Provider')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProviderCard(name: 'Ali Hussain', score: '9.2', distance: '2 km', category: 'HVAC'),
          _ProviderCard(name: 'Sara Ahmed', score: '9.0', distance: '3 km', category: 'Plumbing'),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: () => context.push(RouteNames.customerJobTracking),
          child: const Text('Confirm Provider'),
        ),
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final String name, score, distance, category;
  const _ProviderCard({required this.name, required this.score, required this.distance, required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.engineering)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$category • $distance'),
        trailing: Chip(label: Text('$score ★'), backgroundColor: AppColors.primary.withOpacity(0.1)),
      ),
    );
  }
}
