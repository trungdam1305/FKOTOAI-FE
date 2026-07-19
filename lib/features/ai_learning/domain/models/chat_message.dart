class ChatMessage {
  final String text;
  final bool isUser; // true = tin nhắn của học sinh, false = của AI
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}