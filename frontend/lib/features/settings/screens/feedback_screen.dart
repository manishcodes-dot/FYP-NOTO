import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/feedback_provider.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key});
  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _controller = TextEditingController();
  int rating = 5;
  bool isSending = false;

  Future<void> _submit() async {
    if (_controller.text.isEmpty) return;
    setState(() => isSending = true);
    final success = await ref.read(feedbackControllerProvider).submitFeedback(_controller.text, rating);
    setState(() => isSending = false);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you! Feedback received.')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Feedback')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your thoughts help us improve NOTO.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('How would you rate your experience?', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Row(
              children: List.generate(5, (i) => IconButton(
                icon: Icon(i < rating ? Icons.star_rounded : Icons.star_outline_rounded, color: Colors.orange, size: 32),
                onPressed: () => setState(() => rating = i + 1),
              )),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'What can we improve? Any bugs or suggestions?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                onPressed: isSending ? null : _submit,
                child: isSending ? const CircularProgressIndicator(color: Colors.white) : const Text('Send Feedback'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
