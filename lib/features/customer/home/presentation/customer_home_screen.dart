import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../presentation/providers/customer_home_provider.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void initState() {
    super.initState();
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerHomeProvider);
    final locale = Localizations.localeOf(context);
    final isUrdu = locale.languageCode == 'ur';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isUrdu ? 'سلام' : 'Hello', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                          Text(isUrdu ? 'آج کیا ضرورت ہے؟' : 'What do you need today?', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                        ],
                      ),
                      IconButton(icon: const Icon(Icons.notifications_none, color: AppColors.secondary), onPressed: () => context.push(RouteNames.customerNotifications)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _ActiveJobCard(),
                  const SizedBox(height: 24),
                  Text('Categories', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) => _CategoryChip(index: i),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Nearby Providers', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  state.when(
                    loading: () => const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
                    error: (e, _) => const SizedBox(height: 180, child: Center(child: Text('Error loading providers'))),
                    data: (providers) => ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: providers.length > 3 ? 3 : providers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _ProviderCard(provider: providers[i]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _QuickAction(icon: Icons.chat, label: isUrdu ? 'AI اسسٹنٹ' : 'AI Assistant', onTap: () => context.push(RouteNames.aiAssistant))),
                      const SizedBox(width: 12),
                      Expanded(child: _QuickAction(icon: Icons.mic, label: isUrdu ? 'وائس' : 'Voice', onTap: () => context.push(RouteNames.voiceAssistant))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.customerJobRequest),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: Text(isUrdu ? 'درخواست' : 'New Request'),
      ),
      bottomNavigationBar: _CustomerNavBar(),
    );
  }
}

class _ActiveJobCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.engineering, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Active Job', style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text('AC Repair - Lahore', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text('Provider on the way • 18 min', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.chevron_right, color: Colors.white), onPressed: () => context.push(RouteNames.customerJobTracking)),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final int index;
  const _CategoryChip({required this.index});

  static const categories = ['HVAC', 'Electrical', 'Plumbing', 'Painting', 'Cleaning'];

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.category, color: AppColors.primary, size: 22),
          const SizedBox(height: 6),
          Text(categories[index % categories.length], textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final dynamic provider;
  const _ProviderCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(child: Icon(Icons.person, color: AppColors.primary)),
        title: Text('Ali Hussain', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('HVAC • 4.9 ★ • 2 km'),
        trailing: Chip(label: Text('Recommended'), backgroundColor: AppColors.primary.withOpacity(0.1), side: BorderSide(color: AppColors.primary)),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onTap,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.border)),
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _CustomerNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textLight,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Jobs'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
