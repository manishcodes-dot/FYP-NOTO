class AIChatMessage {
  const AIChatMessage({required this.role, required this.content, required this.timestamp});
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;

  Map<String, String> toChatJson() => {'role': role, 'content': content};
}
