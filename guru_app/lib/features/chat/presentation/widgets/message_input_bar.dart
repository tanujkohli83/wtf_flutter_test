import 'package:flutter/material.dart';

class MessageInputBar extends StatelessWidget {
  const MessageInputBar({
    super.key,
    required this.controller,
    required this.onSend,
    this.onChanged,
    this.hintText = 'Message your trainer',
  });

  final TextEditingController controller;
  final ValueChanged<String> onSend;
  final ValueChanged<String>? onChanged;
  final String hintText;

  void _submit() {
    onSend(controller.text);
  }

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
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: hintText,
                  prefixIcon: Icon(Icons.add_circle_outline_rounded),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              onPressed: _submit,
              tooltip: 'Send message',
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
