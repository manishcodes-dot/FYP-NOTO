import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';

final feedbackControllerProvider = Provider((ref) => FeedbackController(ref));

class FeedbackController {
  FeedbackController(this.ref);
  final Ref ref;

  Future<bool> submitFeedback(String message, int rating) async {
    try {
      await ref.read(dioProvider).post('/feedback', data: {
        'message': message,
        'rating': rating,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAllFeedback() async {
    try {
      final res = await ref.read(dioProvider).get('/feedback');
      return List<Map<String, dynamic>>.from(res.data['data']);
    } catch (_) {
      return [];
    }
  }
}
