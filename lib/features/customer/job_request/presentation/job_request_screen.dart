import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';

class JobRequestScreen extends ConsumerStatefulWidget {
  const JobRequestScreen({super.key});

  @override
  ConsumerState<JobRequestScreen> createState() => _JobRequestScreenState();
}

class _JobRequestScreenState extends ConsumerState<JobRequestScreen> {
  String _category = 'HVAC';
  final _desc = TextEditingController();
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Scaffold(
        body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.check_circle, size: 80, color: Colors.green), const SizedBox(height: 20), const Text('Request Submitted', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 12), Text('Matching providers will respond shortly.', style: TextStyle(color: AppColors.textSecondary))])),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('New Request')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Category', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['HVAC', 'Electrical', 'Plumbing', 'Painting', 'Cleaning'].map((c) => ChoiceChip(
                label: Text(c),
                selected: _category == c,
                onSelected: (_) => setState(() => _category = c),
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(color: _category == c ? Colors.white : AppColors.textPrimary),
              )).toList(),
            ),
            const SizedBox(height: 20),
            Text('Describe Issue', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(controller: _desc, maxLines: 4, decoration: const InputDecoration(hintText: 'What is the problem?', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            Row(children: [Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.photo_camera), label: const Text('Add Photos')))]),
            const SizedBox(height: 16),
            Row(children: [Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.location_on), label: const Text('Use Current Location')))]),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() => _submitted = true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
              child: const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }
}
