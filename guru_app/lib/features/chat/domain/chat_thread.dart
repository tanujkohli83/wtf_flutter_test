class ChatThread {
  const ChatThread({
    required this.name,
    required this.role,
    required this.lastMessage,
    required this.timestamp,
    required this.initials,
    this.unreadCount = 0,
  });

  final String name;
  final String role;
  final String lastMessage;
  final String timestamp;
  final String initials;
  final int unreadCount;

  bool get hasUnread => unreadCount > 0;
}
