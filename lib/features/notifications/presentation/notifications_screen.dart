import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {'title': 'Job Accepted', 'body': 'Ali Hussain accepted your AC repair request.', 'time': '10 min ago'},
      {'title': 'Quotation Received', 'body': 'A quotation of ₨ 2,500 has been submitted.', 'time': '1 hr ago'},
      {'title': 'Provider Arrived', 'body': 'Your provider is at your location.', 'time': '2 hrs ago'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: CircleAvatar(child: Icon(Icons.notifications_active, color: AppColors.primary)),
            title: Text(notifications[i]['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(notifications[i]['body']!),
            trailing: Text(notifications[i]['time']!, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
          ),
        ),
      ),
    );
  }
}
