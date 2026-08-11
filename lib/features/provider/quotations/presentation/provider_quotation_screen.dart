import 'package:flutter/material.dart';

class ProviderQuotationScreen extends StatelessWidget {
  const ProviderQuotationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Quotation')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TextField(decoration: InputDecoration(labelText: 'Diagnosis / Problem Found')),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(labelText: 'Labour Charge')),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(labelText: 'Parts Cost')),
            const SizedBox(height: 12),
            const TextField(decoration: InputDecoration(labelText: 'Total Estimated Cost')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quotation sent'))), child: const Text('Send Quotation')),
          ],
        ),
      ),
    );
  }
}
