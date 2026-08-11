import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/route_names.dart';

class ProviderRegistrationScreen extends ConsumerStatefulWidget {
  const ProviderRegistrationScreen({super.key});

  @override
  ConsumerState<ProviderRegistrationScreen> createState() => _ProviderRegistrationScreenState();
}

class _ProviderRegistrationScreenState extends ConsumerState<ProviderRegistrationScreen> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Provider Registration')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(value: (_step + 1) / 5, backgroundColor: AppColors.border, color: AppColors.primary),
            const SizedBox(height: 24),
            Expanded(
              child: _StepContent(step: _step),
            ),
            ElevatedButton(
              onPressed: () {
                if (_step < 4) {
                  setState(() => _step++);
                } else {
                  context.push(RouteNames.providerVerification);
                }
              },
              child: Text(_step == 4 ? 'Submit for Review' : 'Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  final int step;
  const _StepContent({required this.step});

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case 0:
        return const _FormStep(title: 'Basic Info', child: TextField(decoration: InputDecoration(labelText: 'Full Name')));
      case 1:
        return const _FormStep(title: 'Personal Info', child: TextField(decoration: InputDecoration(labelText: 'Phone / CNIC')));
      case 2:
        return const _FormStep(title: 'CNIC Front', child: Text('Upload CNIC Front Image'));
      case 3:
        return const _FormStep(title: 'CNIC Back', child: Text('Upload CNIC Back Image'));
      case 4:
        return const _FormStep(title: 'Skills & Areas', child: TextField(decoration: InputDecoration(labelText: 'Primary Skill')));
      default:
        return const SizedBox();
    }
  }
}

class _FormStep extends StatelessWidget {
  final String title;
  final Widget child;
  const _FormStep({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}
