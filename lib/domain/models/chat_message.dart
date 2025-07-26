class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isUserMessage,
  });

  final String text;
  final bool isUserMessage;
}