import 'package:flutter/material.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _ReviewCard(name: 'Fatima', rating: 5, comment: 'Excellent service and very punctual.'),
          _ReviewCard(name: 'Ahmed', rating: 4, comment: 'Good work, clean area.'),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final int rating;
  final String comment;
  const _ReviewCard({required this.name, required this.rating, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Row(children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold)), const Spacer(), ...List.generate(5, (i) => Icon(i < rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 16))]),
        subtitle: Text(comment),
      ),
    );
  }
}
