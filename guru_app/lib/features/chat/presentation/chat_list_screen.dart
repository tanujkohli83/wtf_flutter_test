import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';

import '../application/chat_controller.dart';
import '../domain/chat_thread.dart';
import 'chat_screen.dart';
import 'widgets/chat_thread_tile.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  void _openThread(BuildContext context, ChatThread thread) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ChatScreen(thread: thread)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final unreadAsync = ref.watch(guruUnreadCountProvider);
    final messagesAsync = ref.watch(guruMessagesProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 96),
          children: [
            _ChatHeader(theme: theme),
            const SizedBox(height: 20),
            messagesAsync.when(
              data: (messages) {
                final thread = _buildThread(
                  messages: messages,
                  unreadCount: unreadAsync.asData?.value ?? 0,
                );
                return ChatThreadTile(
                  thread: thread,
                  onTap: () => _openThread(context, thread),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) {
                final thread = _buildThread(messages: const [], unreadCount: 0);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unable to sync chats right now.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    ChatThreadTile(
                      thread: thread,
                      onTap: () => _openThread(context, thread),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  ChatThread _buildThread({
    required List<Message> messages,
    required int unreadCount,
  }) {
    final lastMessage = messages.isNotEmpty ? messages.last : null;

    return ChatThread(
      name: 'Aarav Sharma',
      role: 'Strength Trainer',
      lastMessage: lastMessage?.content ?? 'Start your first message.',
      timestamp: lastMessage == null
          ? 'Now'
          : DateFormat('h:mm a').format(lastMessage.createdAt),
      initials: 'AS',
      unreadCount: unreadCount,
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Messages', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Chat with your trainer and keep your plan on track.',
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}
