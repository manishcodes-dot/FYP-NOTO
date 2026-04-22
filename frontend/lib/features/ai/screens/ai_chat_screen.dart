import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../journal/models/journal_entry.dart';
import '../providers/ai_provider.dart';

class AIChatScreen extends ConsumerStatefulWidget {
  const AIChatScreen({super.key});
  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NOTO AI Assistant'),
        actions: [
          IconButton(onPressed: () => ref.read(aiControllerProvider.notifier).clearChat(), icon: const Icon(Icons.delete_sweep_outlined)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: state.messages.length,
              itemBuilder: (context, i) {
                final m = state.messages[i];
                final isUser = m.role == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primary : Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.content,
                          style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                        ),
                        if (!isUser) ...[
                          const SizedBox(height: 8),
                          const Divider(height: 1),
                          TextButton.icon(
                            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 30)),
                            onPressed: () {
                              final titleSnippet = m.content.split('\n').first;
                              Navigator.pushNamed(context, AppRoutes.newEntry, arguments: {
                                'title': 'AI Note: ${titleSnippet.substring(0, titleSnippet.length > 20 ? 20 : null)}',
                                'content': m.content,
                              });
                            },
                            icon: const Icon(Icons.save_outlined, size: 16),
                            label: const Text('Save as Note', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    decoration: const InputDecoration(
                      hintText: 'Ask AI...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    maxLines: null,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (_input.text.trim().isEmpty) return;
                    final text = _input.text;
                    _input.clear();
                    await ref.read(aiControllerProvider.notifier).sendMessage(text);
                    _scrollToBottom();
                  },
                  icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
