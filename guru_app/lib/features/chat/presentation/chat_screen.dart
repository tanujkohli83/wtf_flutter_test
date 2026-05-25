import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../application/chat_controller.dart';
import '../domain/chat_thread.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/message_input_bar.dart';
import 'widgets/quick_reply_chips.dart';
import 'widgets/typing_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.thread});

  final ChatThread thread;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final ChatParticipants _participants;
  late final RealtimeChatService _chatService;

  @override
  void initState() {
    super.initState();
    _participants = ref.read(guruChatParticipantsProvider);
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
    try {
      await _chatService.sendMessage(
        senderId: _participants.currentUserId,
        receiverId: _participants.otherUserId,
        content: text,
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
    final messagesAsync = ref.watch(guruMessagesProvider);
    final typingAsync = ref.watch(guruTypingProvider);
    final quickReplies = ref.watch(guruQuickRepliesProvider);

    ref.listen<AsyncValue<List<Message>>>(guruMessagesProvider, (_, next) {
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

    final isTrainerTyping = typingAsync.asData?.value.isTyping ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.thread.name),
            Text(
              isTrainerTyping ? 'Typing...' : widget.thread.role,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) => _MessageList(
                messages: messages,
                isTyping: isTrainerTyping,
                scrollController: _scrollController,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Text('Unable to load chat: $error'),
                  ),
                  Expanded(
                    child: _MessageList(
                      messages: const <Message>[],
                      isTyping: false,
                      scrollController: _scrollController,
                    ),
                  ),
                ],
              ),
            ),
          ),
          QuickReplyChips(
            replies: quickReplies,
            onSelected: (value) => unawaited(_sendMessage(value)),
          ),
          MessageInputBar(
            controller: _messageController,
            onChanged: _handleDraftChanged,
            onSend: (value) => unawaited(_sendMessage(value)),
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({
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
          return const TypingIndicator();
        }
        return ChatBubble(message: messages[index]);
      },
    );
  }
}
