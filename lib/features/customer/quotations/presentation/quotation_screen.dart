import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class QuotationScreen extends StatelessWidget {
  const QuotationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quotation')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Problem Found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 8),
                    Text('Refrigerant leak, compressor fault'),
                    SizedBox(height: 16),
                    Text('Labour Charge', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('₨ 3,000'),
                    SizedBox(height: 8),
                    Text('Parts Cost', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('₨ 5,500'),
                    SizedBox(height: 8),
                    Text('Total Estimated', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                    Text('₨ 8,500'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quotation accepted'))), child: const Text('Accept'))),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Negotiate'))),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Decline'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
