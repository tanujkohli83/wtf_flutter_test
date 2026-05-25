import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import 'package:trainer_app/features/chat/application/trainer_chat_controller.dart';

class TrainerChatScreen extends ConsumerStatefulWidget {
  const TrainerChatScreen({super.key});

  @override
  ConsumerState<TrainerChatScreen> createState() => _TrainerChatScreenState();
}

class _TrainerChatScreenState extends ConsumerState<TrainerChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final ChatParticipants _participants;
  late final RealtimeChatService _chatService;

  @override
  void initState() {
    super.initState();
    _participants = ref.read(trainerChatParticipantsProvider);
    _chatService = ref.read(realtimeChatServiceProvider);
  }

  @override
  void dispose() {
    unawaited(
      _chatService.setTyping(
        userId: _participants.currentUserId,
        otherUserId: _participants.otherUserId,
        isTyping: false,
      ),
    );
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }

    try {
      await _chatService.sendMessage(
        senderId: _participants.currentUserId,
        receiverId: _participants.otherUserId,
        content: trimmed,
      );
      await _chatService.setTyping(
        userId: _participants.currentUserId,
        otherUserId: _participants.otherUserId,
        isTyping: false,
      );
      _messageController.clear();
      _scrollToBottom();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to send message: $error')));
    }
  }

  void _handleDraftChanged(String value) {
    unawaited(
      _chatService.setTyping(
        userId: _participants.currentUserId,
        otherUserId: _participants.otherUserId,
        isTyping: value.trim().isNotEmpty,
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(trainerMessagesProvider);
    final typingAsync = ref.watch(trainerTypingProvider);
    final quickReplies = ref.watch(trainerQuickRepliesProvider);
    final isGuruTyping = typingAsync.asData?.value.isTyping ?? false;
    final theme = Theme.of(context);

    ref.listen<AsyncValue<List<Message>>>(trainerMessagesProvider, (_, next) {
      next.whenData((messages) {
        if (messages.isEmpty) {
          return;
        }
        _scrollToBottom();
        unawaited(
          _chatService.markConversationRead(
            readerId: _participants.currentUserId,
            otherUserId: _participants.otherUserId,
          ),
        );
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('DK'),
            Text(
              isGuruTyping ? 'Typing...' : 'Member',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) => _TrainerMessageList(
                messages: messages,
                isTyping: isGuruTyping,
                scrollController: _scrollController,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Unable to load chat: $error'),
                ),
              ),
            ),
          ),
          _QuickReplies(
            replies: quickReplies,
            onSelected: (value) => unawaited(_sendMessage(value)),
          ),
          _MessageInputBar(
            controller: _messageController,
            hintText: 'Message your member',
            onChanged: _handleDraftChanged,
            onSend: (value) => unawaited(_sendMessage(value)),
          ),
        ],
      ),
    );
  }
}

class _TrainerMessageList extends StatelessWidget {
  const _TrainerMessageList({
    required this.messages,
    required this.isTyping,
    required this.scrollController,
  });

  final List<Message> messages;
  final bool isTyping;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No messages yet. Start the conversation.'),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: messages.length + (isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (isTyping && index == messages.length) {
          return const _TypingIndicator();
        }
        final message = messages[index];
        return _ChatBubble(
          message: message,
          isMine: message.senderId == trainerUserId,
        );
      },
    );
  }
}

class _QuickReplies extends StatelessWidget {
  const _QuickReplies({required this.replies, required this.onSelected});

  final List<String> replies;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        scrollDirection: Axis.horizontal,
        itemCount: replies.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ActionChip(
            label: Text(replies[index]),
            onPressed: () => onSelected(replies[index]),
          );
        },
      ),
    );
  }
}

class _MessageInputBar extends StatelessWidget {
  const _MessageInputBar({
    required this.controller,
    required this.hintText,
    required this.onSend,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onSend;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(top: BorderSide(color: theme.colorScheme.outline)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onChanged: onChanged,
                onSubmitted: onSend,
                decoration: InputDecoration(
                  hintText: hintText,
                  prefixIcon: const Icon(Icons.add_circle_outline_rounded),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              onPressed: () => onSend(controller.text),
              tooltip: 'Send message',
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message, required this.isMine});

  final Message message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bubbleColor = isMine
        ? theme.colorScheme.primary
        : theme.colorScheme.surface;
    final textColor = isMine
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 8),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMine ? 18 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 18),
          ),
          border: isMine ? null : Border.all(color: theme.colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: textColor.withValues(alpha: 0.72),
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  _StatusIcon(status: message.status),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    if (status == messageStatusFailed) {
      return Icon(
        Icons.error_outline_rounded,
        color: Colors.white.withValues(alpha: 0.90),
        size: 16,
      );
    }

    if (status == messageStatusPending) {
      return Icon(
        Icons.schedule_rounded,
        color: Colors.white.withValues(alpha: 0.80),
        size: 16,
      );
    }

    final isRead = status == messageStatusRead;
    final isDelivered = status == messageStatusDelivered;
    return Icon(
      isRead || isDelivered ? Icons.done_all_rounded : Icons.done_rounded,
      color: Colors.white.withValues(alpha: isRead ? 0.95 : 0.72),
      size: 16,
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final phase = (_controller.value + index * 0.18) % 1;
                final opacity = phase < 0.5 ? 0.35 + phase : 1.35 - phase;

                return Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: opacity),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

String _formatTime(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  final suffix = value.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}
