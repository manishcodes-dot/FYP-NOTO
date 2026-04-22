import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/chat_message.dart';

class AIState {
  const AIState({this.messages = const [], this.isLoading = false});
  final List<AIChatMessage> messages;
  final bool isLoading;

  AIState copyWith({List<AIChatMessage>? messages, bool? isLoading}) =>
      AIState(messages: messages ?? this.messages, isLoading: isLoading ?? this.isLoading);
}

final aiControllerProvider = StateNotifierProvider<AIController, AIState>((ref) => AIController(ref));

class AIController extends StateNotifier<AIState> {
  AIController(this.ref) : super(const AIState());
  final Ref ref;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = AIChatMessage(role: 'user', content: text, timestamp: DateTime.now());
    state = state.copyWith(messages: [...state.messages, userMsg], isLoading: true);

    try {
      final res = await ref.read(dioProvider).post('/ai/chat', data: {
        'messages': state.messages.map((m) => m.toChatJson()).toList(),
      });

      final aiContent = res.data['data']['content'] as String;
      final aiMsg = AIChatMessage(role: 'assistant', content: aiContent, timestamp: DateTime.now());
      state = state.copyWith(messages: [...state.messages, aiMsg], isLoading: false);
    } catch (e) {
      final errorMsg = AIChatMessage(
        role: 'assistant',
        content: 'Sorry, I encountered an error: ${e.toString()}',
        timestamp: DateTime.now(),
      );
      state = state.copyWith(messages: [...state.messages, errorMsg], isLoading: false);
    }
  }

  void clearChat() => state = const AIState();
}
