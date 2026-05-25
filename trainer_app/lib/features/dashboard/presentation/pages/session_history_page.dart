import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared/shared.dart';
import 'package:trainer_app/features/chat/application/trainer_chat_controller.dart';

enum TrainerSessionSort { newest, duration, rating }

class SessionHistoryPage extends ConsumerStatefulWidget {
  const SessionHistoryPage({super.key});

  @override
  ConsumerState<SessionHistoryPage> createState() => _SessionHistoryPageState();
}

class _SessionHistoryPageState extends ConsumerState<SessionHistoryPage> {
  TrainerSessionSort _sort = TrainerSessionSort.newest;

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(
      trainerAppointmentRequestsProvider(trainerUserId),
    );
    final sessionsAsync = ref.watch(trainerSessionLogsProvider(trainerUserId));

    return Scaffold(
      appBar: AppBar(title: const Text('Sessions')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            _Header(sort: _sort, onChanged: (value) => setState(() => _sort = value)),
            const SizedBox(height: 18),
            _Shell(
              title: 'Upcoming',
              subtitle: 'Approved member bookings that have not happened yet.',
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
                    return const _EmptyState(message: 'No upcoming member sessions.');
                  }

                  return Column(
                    children: upcoming
                        .map(
                          (request) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _UpcomingSessionCard(request: request),
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
            _Shell(
              title: 'Completed',
              subtitle: 'Latest completed sessions with rating and notes.',
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
                            child: _CompletedSessionCard(session: session),
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
      case TrainerSessionSort.newest:
        sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      case TrainerSessionSort.duration:
        sessions.sort((a, b) => (b.durationSeconds ?? 0).compareTo(a.durationSeconds ?? 0));
      case TrainerSessionSort.rating:
        sessions.sort(
          (a, b) => (b.memberRating ?? 0).compareTo(a.memberRating ?? 0),
        );
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.sort, required this.onChanged});

  final TrainerSessionSort sort;
  final ValueChanged<TrainerSessionSort> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7F1D1D), Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Member session history',
            style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Track upcoming bookings and review completed member sessions in one place.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
          const SizedBox(height: 18),
          DropdownButtonFormField<TrainerSessionSort>(
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
                onChanged(value);
              }
            },
            items: const [
              DropdownMenuItem(
                value: TrainerSessionSort.newest,
                child: Text('Latest first'),
              ),
              DropdownMenuItem(
                value: TrainerSessionSort.duration,
                child: Text('Longest duration'),
              ),
              DropdownMenuItem(
                value: TrainerSessionSort.rating,
                child: Text('Highest rating'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Shell extends StatelessWidget {
  const _Shell({
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

class _UpcomingSessionCard extends StatelessWidget {
  const _UpcomingSessionCard({required this.request});

  final AppointmentRequestModel request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = DateFormat('dd MMM, h:mm a');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(request.focus, style: theme.textTheme.titleMedium)),
              _Badge(
                label: '${request.durationMinutes} min',
                color: const Color(0xFFB91C1C),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(request.memberName, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          _MetaRow(
            icon: Icons.calendar_today_rounded,
            text: formatter.format(request.scheduledAt),
          ),
          if (request.note.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(request.note, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _CompletedSessionCard extends StatelessWidget {
  const _CompletedSessionCard({required this.session});

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
                    Text(session.memberName, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(session.focus, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              _Badge(
                label: session.memberRating == null
                    ? 'No rating'
                    : '${session.memberRating!.toStringAsFixed(1)} ★',
                color: const Color(0xFFF59E0B),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MetaRow(icon: Icons.event_available_rounded, text: formatter.format(session.startedAt)),
              _MetaRow(icon: Icons.timer_outlined, text: '${session.duration.inMinutes} min'),
            ],
          ),
          if (session.trainerNotes.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            _NotesBox(title: 'Trainer notes', body: session.trainerNotes),
          ],
          if (session.memberNotes.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _NotesBox(title: 'Member notes', body: session.memberNotes),
          ],
        ],
      ),
    );
  }
}

class _NotesBox extends StatelessWidget {
  const _NotesBox({required this.title, required this.body});

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

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 2),
        Icon(icon, size: 16, color: const Color(0xFFB91C1C)),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

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
