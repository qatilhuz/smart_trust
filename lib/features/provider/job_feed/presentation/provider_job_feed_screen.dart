import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';

class ProviderJobFeedScreen extends ConsumerWidget {
  const ProviderJobFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incoming Requests')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _JobRequestCard(index: i),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: AppColors.primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
        ],
      ),
    );
  }
}

class _JobRequestCard extends StatelessWidget {
  final int index;
  const _JobRequestCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person, color: AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(child: Text('Customer Request #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                Chip(label: Text('HVAC'), backgroundColor: AppColors.primary.withOpacity(0.1)),
              ],
            ),
            const SizedBox(height: 8),
            Text('AC not cooling. Water leaking from indoor unit.', style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Row(children: [const Icon(Icons.location_on, size: 14, color: AppColors.textLight), const SizedBox(width: 4), Text('2.4 km • Gulberg', style: const TextStyle(fontSize: 12, color: AppColors.textLight))]),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Visiting Charge (PKR)', prefixText: '₨ ', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {},
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request accepted'))),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
