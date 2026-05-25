enum MessageReceipt { sent, read }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isMine,
    this.receipt,
  });

  final String id;
  final String text;
  final String timestamp;
  final bool isMine;
  final MessageReceipt? receipt;
}
