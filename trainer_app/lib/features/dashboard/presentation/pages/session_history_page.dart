import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trainer_app/core/theme/app_theme.dart';

class CompletedSession {
  const CompletedSession({
    required this.memberName,
    required this.focus,
    required this.durationMinutes,
    required this.rating,
    required this.notes,
    required this.completedAt,
  });

  final String memberName;
  final String focus;
  final int durationMinutes;
  final double rating;
  final String notes;
  final String completedAt;
}

class SessionHistoryPage extends StatelessWidget {
  const SessionHistoryPage({super.key});

  static const List<CompletedSession> _sessions = [
    CompletedSession(
      memberName: 'Maya Rao',
      focus: 'Strength conditioning',
      durationMinutes: 60,
      rating: 4.8,
      completedAt: 'Today, 8:30 AM',
      notes: 'Strong form on squats. Increase deadlift load next session.',
    ),
    CompletedSession(
      memberName: 'Kabir Shah',
      focus: 'Mobility and recovery',
      durationMinutes: 45,
      rating: 4.5,
      completedAt: 'Yesterday, 6:00 PM',
      notes: 'Hip mobility improved. Keep hamstring stretches in warm-up.',
    ),
    CompletedSession(
      memberName: 'Anika Sen',
      focus: 'Cardio endurance',
      durationMinutes: 50,
      rating: 5.0,
      completedAt: 'Mon, 10:00 AM',
      notes: 'Completed intervals cleanly with stable breathing control.',
    ),
    CompletedSession(
      memberName: 'Rohan Iyer',
      focus: 'Posture correction',
      durationMinutes: 40,
      rating: 4.2,
      completedAt: 'Fri, 4:15 PM',
      notes: 'Needs more scapular control work before overhead lifts.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          itemCount: _sessions.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return const _SessionSummaryCard()
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.08, end: 0);
            }

            final session = _sessions[index - 1];
            return _CompletedSessionCard(session: session)
                .animate(delay: (70 * index).ms)
                .fadeIn(duration: 280.ms)
                .slideY(begin: 0.08, end: 0);
          },
        ),
      ),
    );
  }
}

class _SessionSummaryCard extends StatelessWidget {
  const _SessionSummaryCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Completed sessions', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Track outcomes and feedback',
                    style: theme.textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.history_rounded,
                color: AppTheme.primaryRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedSessionCard extends StatelessWidget {
  const _CompletedSessionCard({required this.session});

  final CompletedSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.memberName,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(session.focus, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _DurationChip(minutes: session.durationMinutes),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _RatingStars(rating: session.rating),
                const SizedBox(width: 8),
                Text(
                  session.rating.toStringAsFixed(1),
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F7F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border),
              ),
              child: Text(session.notes, style: theme.textTheme.bodyMedium),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: Color(0xFF15803D),
                ),
                const SizedBox(width: 8),
                Text(session.completedAt, style: theme.textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.primaryRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${minutes}m',
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: AppTheme.primaryRed),
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final fullStars = rating.floor().clamp(0, 5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < fullStars ? Icons.star_rounded : Icons.star_border_rounded,
          color: const Color(0xFFF59E0B),
          size: 20,
        );
      }),
    );
  }
}
