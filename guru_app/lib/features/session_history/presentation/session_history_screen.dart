import 'package:flutter/material.dart';

import '../domain/training_session.dart';
import 'widgets/session_card.dart';
import 'widgets/session_sort_control.dart';

class SessionHistoryScreen extends StatefulWidget {
  const SessionHistoryScreen({super.key});

  @override
  State<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends State<SessionHistoryScreen> {
  SessionSort _sort = SessionSort.newest;

  static final List<TrainingSession> _sessions = [
    TrainingSession(
      trainerName: 'Maya Iyer',
      title: 'Upper Body Strength',
      date: DateTime(2026, 5, 24),
      dateLabel: '24 May 2026',
      durationMinutes: 45,
      rating: 4.8,
      trainerNotes: 'Strong pressing today. Keep shoulders packed on rows.',
    ),
    TrainingSession(
      trainerName: 'Nisha Rao',
      title: 'Mobility Reset',
      date: DateTime(2026, 5, 21),
      dateLabel: '21 May 2026',
      durationMinutes: 30,
      rating: 4.5,
      trainerNotes:
          'Hip flexor range improved. Repeat the evening stretch flow.',
    ),
    TrainingSession(
      trainerName: 'Kabir Mehta',
      title: 'Cardio Conditioning',
      date: DateTime(2026, 5, 18),
      dateLabel: '18 May 2026',
      durationMinutes: 60,
      rating: 4.9,
      trainerNotes: 'Excellent pacing. Zone 2 control was steady throughout.',
    ),
  ];

  List<TrainingSession> get _sortedSessions {
    final sessions = [..._sessions];

    switch (_sort) {
      case SessionSort.newest:
        sessions.sort((a, b) => b.date.compareTo(a.date));
      case SessionSort.duration:
        sessions.sort((a, b) => b.durationMinutes.compareTo(a.durationMinutes));
      case SessionSort.rating:
        sessions.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return sessions;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Session History')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          itemCount: _sortedSessions.length + 1,
          separatorBuilder: (_, index) => index == 0
              ? const SizedBox(height: 20)
              : const SizedBox(height: 14),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _SessionHeader(
                theme: theme,
                sort: _sort,
                onSortChanged: (sort) => setState(() => _sort = sort),
              );
            }

            return SessionCard(session: _sortedSessions[index - 1]);
          },
        ),
      ),
    );
  }
}

class _SessionHeader extends StatelessWidget {
  const _SessionHeader({
    required this.theme,
    required this.sort,
    required this.onSortChanged,
  });

  final ThemeData theme;
  final SessionSort sort;
  final ValueChanged<SessionSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Completed sessions', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          'Review your training history, ratings, and trainer feedback.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 22),
        SessionSortControl(value: sort, onChanged: onSortChanged),
      ],
    );
  }
}
