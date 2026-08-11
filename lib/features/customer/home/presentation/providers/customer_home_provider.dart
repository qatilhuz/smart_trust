import 'package:flutter_riverpod/flutter_riverpod.dart';

final customerHomeProvider = FutureProvider<List<dynamic>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 800));
  return [
    {'name': 'Ali Hussain', 'category': 'HVAC', 'rating': 4.9, 'distance': 2},
    {'name': 'Sara Ahmed', 'category': 'Plumbing', 'rating': 4.8, 'distance': 3},
  ];
});
