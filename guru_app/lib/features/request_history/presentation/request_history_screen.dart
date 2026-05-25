import 'package:flutter/material.dart';

import '../domain/appointment_request.dart';
import 'widgets/request_history_card.dart';

class RequestHistoryScreen extends StatelessWidget {
  const RequestHistoryScreen({super.key});

  static const List<AppointmentRequest> _requests = [
    AppointmentRequest(
      trainerName: 'Maya Iyer',
      focus: 'Strength check-in',
      dateLabel: 'Today',
      timeLabel: '9:00 AM',
      status: AppointmentRequestStatus.pending,
      note: 'Review squat form and weekly load.',
    ),
    AppointmentRequest(
      trainerName: 'Aarav Sharma',
      focus: 'Nutrition planning',
      dateLabel: 'Tomorrow',
      timeLabel: '10:30 AM',
      status: AppointmentRequestStatus.approved,
      note: 'Adjust breakfast around morning workouts.',
    ),
    AppointmentRequest(
      trainerName: 'Nisha Rao',
      focus: 'Mobility session',
      dateLabel: 'Fri, 29 May',
      timeLabel: '5:30 PM',
      status: AppointmentRequestStatus.declined,
      note: 'Trainer unavailable. Please choose another slot.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Request History')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          itemCount: _requests.length + 1,
          separatorBuilder: (_, index) => index == 0
              ? const SizedBox(height: 22)
              : const SizedBox(height: 14),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _HistoryHeader(theme: theme);
            }

            return RequestHistoryCard(request: _requests[index - 1]);
          },
        ),
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Appointment requests', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Track pending, approved, and declined trainer call requests.',
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}
