import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';

class VoiceAssistantScreen extends ConsumerStatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  ConsumerState<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends ConsumerState<VoiceAssistantScreen> {
  bool _listening = false;
  String _command = '';

  void _listen() async {
    setState(() => _listening = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _listening = false;
      _command = 'Open my profile';
    });
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) context.push(RouteNames.customerProfile);
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isUrdu = locale.languageCode == 'ur';

    return Scaffold(
      appBar: AppBar(title: Text(isUrdu ? 'وائس اسسٹنٹ' : 'Voice Assistant')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: _listening ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.primary,
                child: Icon(_listening ? Icons.mic_off : Icons.mic, size: 50, color: AppColors.white),
              ),
            ),
            const SizedBox(height: 24),
            Text(_listening ? (isUrdu ? 'سن رہا ہوں...' : 'Listening...') : (_command.isEmpty ? (isUrdu ? 'اسکرین کو چھونے سے بات کریں' : 'Tap to speak') : _command), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _listening ? null : _listen,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
              child: Text(isUrdu ? 'بات کریں' : 'Speak'),
            ),
          ],
        ),
      ),
    );
  }
}
