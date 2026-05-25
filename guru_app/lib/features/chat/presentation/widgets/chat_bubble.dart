import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../application/chat_controller.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final isMine = message.senderId == guruUserId;
    final theme = Theme.of(context);
    final alignment = isMine ? Alignment.centerRight : Alignment.centerLeft;
    final bubbleColor = isMine
        ? theme.colorScheme.primary
        : theme.colorScheme.surface;
    final textColor = isMine
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return Align(
      alignment: alignment,
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
                  _ReceiptIcon(receipt: message.status),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptIcon extends StatelessWidget {
  const _ReceiptIcon({required this.receipt});

  final String receipt;

  @override
  Widget build(BuildContext context) {
    final isRead = receipt == messageStatusRead;
    final isDelivered = receipt == messageStatusDelivered;
    final isPending = receipt == messageStatusPending;
    final isFailed = receipt == messageStatusFailed;

    if (isFailed) {
      return Icon(
        Icons.error_outline_rounded,
        color: Colors.white.withValues(alpha: 0.90),
        size: 16,
      );
    }

    if (isPending) {
      return Icon(
        Icons.schedule_rounded,
        color: Colors.white.withValues(alpha: 0.80),
        size: 16,
      );
    }

    return Icon(
      isRead || isDelivered ? Icons.done_all_rounded : Icons.done_rounded,
      color: Colors.white.withValues(alpha: isRead ? 0.95 : 0.72),
      size: 16,
    );
  }
}

String _formatTime(DateTime value) {
  final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final minute = value.minute.toString().padLeft(2, '0');
  final suffix = value.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $suffix';
}
