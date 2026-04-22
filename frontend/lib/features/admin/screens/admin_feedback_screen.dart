import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../settings/providers/feedback_provider.dart';

class AdminFeedbackScreen extends ConsumerWidget {
  const AdminFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Feedback')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ref.read(feedbackControllerProvider).getAllFeedback(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final list = snapshot.data!;
          if (list.isEmpty) return const Center(child: Text('No feedback yet.'));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final feed = list[index];
              final user = feed['userId'] as Map<String, dynamic>?;
              return ListTile(
                title: Row(
                  children: [
                    Text(user?['fullName'] ?? 'Anonymous', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    ...List.generate(5, (i) => Icon(
                      i < (feed['rating'] ?? 0) ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 14,
                      color: Colors.orange,
                    )),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?['email'] ?? '', style: const TextStyle(fontSize: 11)),
                    const SizedBox(height: 8),
                    Text(feed['message'] ?? '', style: const TextStyle(color: Colors.black87)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
