import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class ComplaintsScreen extends StatelessWidget {
  const ComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complaints')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.report_problem, size: 60, color: AppColors.error),
            const SizedBox(height: 16),
            const Text('No complaints filed.', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complaint submitted'))), child: const Text('File Complaint')),
          ],
        ),
      ),
    );
  }
}
