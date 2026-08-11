import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  bool _processing = false;
  bool _showSummary = false;
  final List<String> _messages = [
    'Hello! Upload a photo of your appliance for quick assessment.',
  ];

  void _upload() async {
    setState(() => _processing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _processing = false;
      _showSummary = true;
      _messages.addAll([
        'Possible issue detected from image.',
        'Is the AC cooling properly?',
        'Is there unusual noise?',
        'Based on your answers, a service request for HVAC repair is suggested.',
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isUrdu = locale.languageCode == 'ur';

    return Scaffold(
      appBar: AppBar(title: Text(isUrdu ? 'AI اسسٹنٹ' : 'AI Assistant')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) => Align(
                alignment: i == 0 ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: i == 0 ? AppColors.surface : AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _messages[i],
                    style: TextStyle(color: i == 0 ? AppColors.textPrimary : AppColors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
          ),
          if (_processing) const Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
          if (!_showSummary && !_processing)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.image),
                label: Text(isUrdu ? 'تصویر اپلوڈ کریں' : 'Upload Image'),
                onPressed: _upload,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          if (_showSummary)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => context.push(RouteNames.customerJobRequest),
                child: Text(isUrdu ? 'درخواست بنائیں' : 'Create Request'),
              ),
            ),
        ],
      ),
    );
  }
}
