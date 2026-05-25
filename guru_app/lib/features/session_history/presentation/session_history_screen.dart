import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';

import '../../chat/application/chat_controller.dart';

enum SessionHistorySort { newest, duration, rating }

class SessionHistoryScreen extends ConsumerStatefulWidget {
  const SessionHistoryScreen({super.key});

  @override
  ConsumerState<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends ConsumerState<SessionHistoryScreen> {
  SessionHistorySort _sort = SessionHistorySort.newest;

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(memberAppointmentRequestsProvider(guruUserId));
    final sessionsAsync = ref.watch(memberSessionLogsProvider(guruUserId));

    return Scaffold(
      appBar: AppBar(title: const Text('My Sessions')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            _HistoryHero(
              sort: _sort,
              onSortChanged: (value) => setState(() => _sort = value),
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Upcoming',
              subtitle: 'Approved sessions waiting with your trainer.',
              child: requestsAsync.when(
                data: (requests) {
                  final upcoming = requests
                      .where(
                        (request) =>
                            request.status == AppointmentRequestStatus.approved &&
                            request.scheduledAt.isAfter(DateTime.now()),
                      )
                      .toList()
                    ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

                  if (upcoming.isEmpty) {
                    return const _EmptyState(message: 'No upcoming trainer sessions.');
                  }

                  return Column(
                    children: upcoming
                        .map(
                          (request) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _UpcomingCard(
                              title: request.focus,
                              counterpart: request.trainerName,
                              scheduledAt: request.scheduledAt,
                              durationMinutes: request.durationMinutes,
                              note: request.note,
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => const _EmptyState(message: 'Unable to load upcoming sessions.'),
              ),
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Completed',
              subtitle: 'Latest sessions, duration, ratings, and feedback.',
              child: sessionsAsync.when(
                data: (sessions) {
                  final completed = sessions.where((session) => session.isCompleted).toList();
                  _sortSessions(completed);

                  if (completed.isEmpty) {
                    return const _EmptyState(message: 'Completed sessions will appear here.');
                  }

                  return Column(
                    children: completed
                        .map(
                          (session) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _CompletedCard(session: session),
                          ),
                        )
                        .toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => const _EmptyState(message: 'Unable to load session history.'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sortSessions(List<SessionLogModel> sessions) {
    switch (_sort) {
      case SessionHistorySort.newest:
        sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      case SessionHistorySort.duration:
        sessions.sort((a, b) => (b.durationSeconds ?? 0).compareTo(a.durationSeconds ?? 0));
      case SessionHistorySort.rating:
        sessions.sort((a, b) => (b.memberRating ?? 0).compareTo(a.memberRating ?? 0));
    }
  }
}

class _HistoryHero extends StatelessWidget {
  const _HistoryHero({required this.sort, required this.onSortChanged});

  final SessionHistorySort sort;
  final ValueChanged<SessionHistorySort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trainer session history',
            style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'See what is coming up next and review the sessions already completed with your trainer.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: 18),
          DropdownButtonFormField<SessionHistorySort>(
            initialValue: sort,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.sort_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              if (value != null) {
                onSortChanged(value);
              }
            },
            items: const [
              DropdownMenuItem(
                value: SessionHistorySort.newest,
                child: Text('Latest first'),
              ),
              DropdownMenuItem(
                value: SessionHistorySort.duration,
                child: Text('Longest duration'),
              ),
              DropdownMenuItem(
                value: SessionHistorySort.rating,
                child: Text('Highest rating'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(subtitle, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({
    required this.title,
    required this.counterpart,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.note,
  });

  final String title;
  final String counterpart;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = DateFormat('dd MMM, h:mm a');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
              _Pill(label: '$durationMinutes min', color: const Color(0xFF0F766E)),
            ],
          ),
          const SizedBox(height: 6),
          Text(counterpart, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Meta(icon: Icons.calendar_today_rounded, text: formatter.format(scheduledAt)),
              const _Meta(icon: Icons.login_rounded, text: 'Join during scheduled slot'),
            ],
          ),
          if (note.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(note, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _CompletedCard extends StatelessWidget {
  const _CompletedCard({required this.session});

  final SessionLogModel session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = DateFormat('dd MMM yyyy, h:mm a');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
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
                    Text(session.focus, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(session.trainerName, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              _Pill(
                label: session.memberRating == null
                    ? 'No rating'
                    : '${session.memberRating!.toStringAsFixed(1)} star',
                color: const Color(0xFFB45309),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _Meta(icon: Icons.play_circle_outline_rounded, text: formatter.format(session.startedAt)),
              _Meta(icon: Icons.timer_outlined, text: '${session.duration.inMinutes} min'),
            ],
          ),
          if (session.trainerNotes.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            _NotesBlock(title: 'Trainer notes', body: session.trainerNotes),
          ],
          if (session.memberNotes.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _NotesBlock(title: 'Your notes', body: session.memberNotes),
          ],
        ],
      ),
    );
  }
}

class _NotesBlock extends StatelessWidget {
  const _NotesBlock({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(body, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF0F766E)),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(child: Text(message)),
    );
  }
}
