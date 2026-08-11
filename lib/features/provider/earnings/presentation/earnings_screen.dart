import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _EarningsCard(title: "Today's Earnings", amount: '₨ 4,200'),
            const SizedBox(height: 16),
            _EarningsCard(title: 'Total Earnings', amount: '₨ 128,000'),
            const SizedBox(height: 16),
            const Text('Recent Jobs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            ListTile(title: Text('AC Repair'), subtitle: Text('Completed'), trailing: Text('₨ 1,200')),
            ListTile(title: Text('Plumbing Fix'), subtitle: Text('Completed'), trailing: Text('₨ 900')),
          ],
        ),
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  final String title;
  final String amount;
  const _EarningsCard({required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.secondaryDark, AppColors.secondary]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(amount, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
