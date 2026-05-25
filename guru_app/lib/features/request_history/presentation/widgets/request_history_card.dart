import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'request_status_chip.dart';

class RequestHistoryCard extends StatelessWidget {
  const RequestHistoryCard({super.key, required this.request, this.action});

  final AppointmentRequestModel request;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RequestIcon(status: request.status),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.focus, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      request.trainerName,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              RequestStatusChip(status: request.status),
            ],
          ),
          const SizedBox(height: 16),
          _RequestMeta(
            scheduledAt: request.scheduledAt,
            durationMinutes: request.durationMinutes,
          ),
          const SizedBox(height: 14),
          Text(
            request.note.isEmpty
                ? 'No additional note provided.'
                : request.note,
            style: theme.textTheme.bodyMedium,
          ),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

class _RequestIcon extends StatelessWidget {
  const _RequestIcon({required this.status});

  final AppointmentRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(_icon, color: theme.colorScheme.primary, size: 22),
    );
  }

  IconData get _icon {
    return switch (status) {
      AppointmentRequestStatus.pending => Icons.hourglass_top_rounded,
      AppointmentRequestStatus.approved => Icons.check_circle_rounded,
      AppointmentRequestStatus.declined => Icons.cancel_rounded,
    };
  }
}

class _RequestMeta extends StatelessWidget {
  const _RequestMeta({
    required this.scheduledAt,
    required this.durationMinutes,
  });

  final DateTime scheduledAt;
  final int durationMinutes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.calendar_today_rounded,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 6),
        Text(_dateLabel, style: theme.textTheme.labelLarge),
        const SizedBox(width: 16),
        Icon(
          Icons.schedule_rounded,
          size: 17,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 6),
        Text(_timeLabel, style: theme.textTheme.labelLarge),
      ],
    );
  }

  String get _dateLabel {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[scheduledAt.weekday - 1]}, ${scheduledAt.day} ${months[scheduledAt.month - 1]}';
  }

  String get _timeLabel {
    final end = scheduledAt.add(Duration(minutes: durationMinutes));
    return '${_formatTime(scheduledAt)} - ${_formatTime(end)}';
  }

  String _formatTime(DateTime value) {
    final period = value.hour >= 12 ? 'PM' : 'AM';
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
