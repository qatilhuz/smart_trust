import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class JobTrackingScreen extends StatelessWidget {
  const JobTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final steps = ['Request Sent', 'Provider Accepted', 'On The Way', 'Arrived', 'Inspection', 'Quotation', 'Work In Progress', 'Completed', 'Review'];
    return Scaffold(
      appBar: AppBar(title: const Text('Job Tracking')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.separated(
          itemCount: steps.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) => Row(
            children: [
              Column(
                children: [
                  Container(width: 24, height: 24, decoration: BoxDecoration(color: i <= 3 ? AppColors.primary : AppColors.border, shape: BoxShape.circle), child: i <= 3 ? const Icon(Icons.check, size: 14, color: Colors.white) : null),
                  if (i < steps.length - 1) Container(width: 2, height: 20, color: AppColors.border),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(steps[i], style: TextStyle(fontWeight: i <= 3 ? FontWeight.bold : FontWeight.normal, color: i <= 3 ? AppColors.primary : AppColors.textSecondary))),
            ],
          ),
        ),
      ),
    );
  }
}
