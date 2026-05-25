import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../call/presentation/guru_call_prejoin_screen.dart';
import '../../chat/application/chat_controller.dart';
import 'widgets/request_history_card.dart';

class RequestHistoryScreen extends ConsumerWidget {
  const RequestHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final requestsAsync = ref.watch(
      memberAppointmentRequestsProvider(guruUserId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Request History')),
      body: SafeArea(
        child: requestsAsync.when(
          data: (requests) => ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            itemCount: requests.length + 1,
            separatorBuilder: (_, index) => index == 0
                ? const SizedBox(height: 22)
                : const SizedBox(height: 14),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _HistoryHeader(theme: theme);
              }

              final request = requests[index - 1];
              final canJoinNow = request.canJoinAt(DateTime.now());
              return RequestHistoryCard(
                request: request,
                action: request.status == AppointmentRequestStatus.approved
                    ? FilledButton.icon(
                        onPressed: canJoinNow
                            ? () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const GuruCallPrejoinScreen(),
                                ),
                              )
                            : null,
                        icon: const Icon(Icons.video_call_rounded),
                        label: Text(
                          canJoinNow
                              ? 'Join Video Call'
                              : 'Available At Scheduled Time',
                        ),
                      )
                    : null,
              );
            },
          ),
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
