import 'package:flutter/material.dart';
import 'package:trainer_app/core/theme/app_theme.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({
    required this.time,
    required this.client,
    required this.focus,
    required this.status,
    super.key,
  });

  final String time;
  final String client;
  final String focus;
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                time,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.primaryRed,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(client, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 3),
                  Text(focus, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Chip(label: Text(status)),
          ],
        ),
      ),
    );
  }
}
