import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import 'package:trainer_app/core/theme/app_theme.dart';
import 'package:trainer_app/features/call/presentation/trainer_call_prejoin_screen.dart';
import 'package:trainer_app/features/chat/application/trainer_chat_controller.dart';

class RequestManagementPage extends ConsumerWidget {
  const RequestManagementPage({super.key});

  bool _hasConflict(
    AppointmentRequestModel request,
    List<AppointmentRequestModel> requests,
  ) {
    return requests.any(
      (other) =>
          other.id != request.id &&
          other.status == AppointmentRequestStatus.approved &&
          _overlaps(request, other),
    );
  }

  bool _overlaps(
    AppointmentRequestModel first,
    AppointmentRequestModel second,
  ) {
    return first.scheduledAt.isBefore(second.endsAt) &&
        second.scheduledAt.isBefore(first.endsAt);
  }

  Future<void> _approve(
    BuildContext context,
    WidgetRef ref,
    AppointmentRequestModel request,
    List<AppointmentRequestModel> requests,
  ) async {
    if (_hasConflict(request, requests)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Conflict found. Choose another time before approving.',
          ),
        ),
      );
      return;
    }

    await ref
        .read(appointmentRequestServiceProvider)
        .setStatus(
          requestId: request.id,
          status: AppointmentRequestStatus.approved,
        );
  }

  Future<void> _decline(WidgetRef ref, AppointmentRequestModel request) async {
    await ref
        .read(appointmentRequestServiceProvider)
        .setStatus(
          requestId: request.id,
          status: AppointmentRequestStatus.declined,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(
      trainerAppointmentRequestsProvider(trainerUserId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Requests')),
      body: SafeArea(
        child: requestsAsync.when(
          data: (requests) {
            final pendingCount = requests
                .where(
                  (request) =>
                      request.status == AppointmentRequestStatus.pending,
                )
                .length;

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: requests.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _RequestSummaryCard(pendingCount: pendingCount)
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.08, end: 0);
                }

                final request = requests[index - 1];
                final hasConflict = _hasConflict(request, requests);
                return _RequestCard(
                      request: request,
                      hasConflict: hasConflict,
                      onApprove: () =>
                          _approve(context, ref, request, requests),
                      onDecline: () => _decline(ref, request),
                      onJoinCall: request.canJoinAt(DateTime.now())
                          ? () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    const TrainerCallPrejoinScreen(),
                              ),
                            )
                          : null,
                    )
                    .animate(delay: (70 * index).ms)
                    .fadeIn(duration: 280.ms)
                    .slideY(begin: 0.08, end: 0);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Unable to load requests: $error'),
            ),
          ),
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
    required this.onJoinCall,
  });

  final AppointmentRequestModel request;
  final bool hasConflict;
  final Future<void> Function() onApprove;
  final Future<void> Function() onDecline;
  final VoidCallback? onJoinCall;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPending = request.status == AppointmentRequestStatus.pending;

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
            Text(request.focus, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(
              request.note.isEmpty ? 'No note provided.' : request.note,
              style: theme.textTheme.bodySmall,
            ),
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
                  _timeRangeLabel(request.scheduledAt, request.endsAt),
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(width: 8),
                Text(
                  _dateLabel(request.scheduledAt),
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
            if (hasConflict && isPending) ...[
              const SizedBox(height: 12),
              const _ConflictNotice(),
            ],
            if (request.status == AppointmentRequestStatus.approved) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onJoinCall,
                  icon: const Icon(Icons.video_call_rounded),
                  label: Text(
                    onJoinCall == null
                        ? 'Available At Scheduled Time'
                        : 'Join Video Call',
                  ),
                ),
              ),
            ] else ...[
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
          ],
        ),
      ),
    );
  }

  String _dateLabel(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  String _timeRangeLabel(DateTime start, DateTime end) {
    return '${_formatTime(start)} - ${_formatTime(end)}';
  }

  String _formatTime(DateTime value) {
    final period = value.hour >= 12 ? 'PM' : 'AM';
    final hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
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

  final AppointmentRequestStatus status;
  final bool hasConflict;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      AppointmentRequestStatus.approved => 'Approved',
      AppointmentRequestStatus.declined => 'Declined',
      AppointmentRequestStatus.pending => hasConflict ? 'Conflict' : 'Pending',
    };

    final color = switch (status) {
      AppointmentRequestStatus.approved => const Color(0xFF15803D),
      AppointmentRequestStatus.declined => const Color(0xFF6B7280),
      AppointmentRequestStatus.pending =>
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
