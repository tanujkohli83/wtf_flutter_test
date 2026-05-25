import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trainer_app/core/theme/app_theme.dart';

enum RequestStatus { pending, approved, declined }

class TrainingRequest {
  const TrainingRequest({
    required this.id,
    required this.memberName,
    required this.goal,
    required this.start,
    required this.end,
    this.status = RequestStatus.pending,
  });

  final String id;
  final String memberName;
  final String goal;
  final TimeOfDay start;
  final TimeOfDay end;
  final RequestStatus status;

  TrainingRequest copyWith({RequestStatus? status}) {
    return TrainingRequest(
      id: id,
      memberName: memberName,
      goal: goal,
      start: start,
      end: end,
      status: status ?? this.status,
    );
  }
}

class RequestManagementPage extends StatefulWidget {
  const RequestManagementPage({super.key});

  @override
  State<RequestManagementPage> createState() => _RequestManagementPageState();
}

class _RequestManagementPageState extends State<RequestManagementPage> {
  late List<TrainingRequest> _requests = const [
    TrainingRequest(
      id: 'req-1',
      memberName: 'Maya Rao',
      goal: 'Strength and mobility session',
      start: TimeOfDay(hour: 9, minute: 0),
      end: TimeOfDay(hour: 10, minute: 0),
      status: RequestStatus.approved,
    ),
    TrainingRequest(
      id: 'req-2',
      memberName: 'Kabir Shah',
      goal: 'Weight training assessment',
      start: TimeOfDay(hour: 9, minute: 30),
      end: TimeOfDay(hour: 10, minute: 30),
    ),
    TrainingRequest(
      id: 'req-3',
      memberName: 'Anika Sen',
      goal: 'Cardio endurance plan',
      start: TimeOfDay(hour: 11, minute: 0),
      end: TimeOfDay(hour: 12, minute: 0),
    ),
    TrainingRequest(
      id: 'req-4',
      memberName: 'Rohan Iyer',
      goal: 'Posture correction session',
      start: TimeOfDay(hour: 13, minute: 30),
      end: TimeOfDay(hour: 14, minute: 15),
    ),
  ];

  bool _hasConflict(TrainingRequest request) {
    return _requests.any(
      (other) =>
          other.id != request.id &&
          other.status == RequestStatus.approved &&
          _overlaps(request, other),
    );
  }

  bool _overlaps(TrainingRequest first, TrainingRequest second) {
    final firstStart = _minutes(first.start);
    final firstEnd = _minutes(first.end);
    final secondStart = _minutes(second.start);
    final secondEnd = _minutes(second.end);

    return firstStart < secondEnd && secondStart < firstEnd;
  }

  int _minutes(TimeOfDay time) => time.hour * 60 + time.minute;

  void _approve(TrainingRequest request) {
    if (_hasConflict(request)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Conflict found. Choose another time before approving.',
          ),
        ),
      );
      return;
    }

    _setStatus(request.id, RequestStatus.approved);
  }

  void _decline(String requestId) {
    _setStatus(requestId, RequestStatus.declined);
  }

  void _setStatus(String requestId, RequestStatus status) {
    setState(() {
      _requests = [
        for (final request in _requests)
          if (request.id == requestId)
            request.copyWith(status: status)
          else
            request,
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _requests
        .where((request) => request.status == RequestStatus.pending)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Requests')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          itemCount: _requests.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _RequestSummaryCard(
                pendingCount: pendingCount,
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0);
            }

            final request = _requests[index - 1];
            return _RequestCard(
                  request: request,
                  hasConflict: _hasConflict(request),
                  onApprove: () => _approve(request),
                  onDecline: () => _decline(request.id),
                )
                .animate(delay: (70 * index).ms)
                .fadeIn(duration: 280.ms)
                .slideY(begin: 0.08, end: 0);
          },
        ),
      ),
    );
  }
}

class _RequestSummaryCard extends StatelessWidget {
  const _RequestSummaryCard({required this.pendingCount});

  final int pendingCount;

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
                  Text('Trainer requests', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 6),
                  Text(
                    '$pendingCount pending approvals',
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
                Icons.rule_folder_rounded,
                color: AppTheme.primaryRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.hasConflict,
    required this.onApprove,
    required this.onDecline,
  });

  final TrainingRequest request;
  final bool hasConflict;
  final VoidCallback onApprove;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPending = request.status == RequestStatus.pending;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.memberName,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                _StatusChip(status: request.status, hasConflict: hasConflict),
              ],
            ),
            const SizedBox(height: 8),
            Text(request.goal, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 18,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(width: 8),
                Text(
                  '${request.start.format(context)} - ${request.end.format(context)}',
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
            if (hasConflict && isPending) ...[
              const SizedBox(height: 12),
              const _ConflictNotice(),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isPending ? onDecline : null,
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: isPending ? onApprove : null,
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConflictNotice extends StatelessWidget {
  const _ConflictNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFD8A8)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFB45309),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Overlaps with an approved session.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF92400E)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.hasConflict});

  final RequestStatus status;
  final bool hasConflict;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      RequestStatus.approved => 'Approved',
      RequestStatus.declined => 'Declined',
      RequestStatus.pending => hasConflict ? 'Conflict' : 'Pending',
    };

    final color = switch (status) {
      RequestStatus.approved => const Color(0xFF15803D),
      RequestStatus.declined => const Color(0xFF6B7280),
      RequestStatus.pending =>
        hasConflict ? const Color(0xFFB45309) : AppTheme.primaryRed,
    };

    return Chip(
      label: Text(label),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w700),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color.withValues(alpha: 0.2)),
    );
  }
}
