import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../chat/application/chat_controller.dart';
import 'guru_call_screen.dart';

class GuruCallPrejoinScreen extends ConsumerWidget {
  const GuruCallPrejoinScreen({super.key});

  String get _roomId =>
      CallService.roomIdFor(trainerId: trainerUserId, memberId: guruUserId);

  bool get _isSupportedPlatform =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> _joinMeeting(BuildContext context, WidgetRef ref) async {
    final prejoinState = ref.read(callPrejoinProvider(_roomId));
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await ref
          .read(callServiceProvider)
          .joinMeeting(
            trainerId: trainerUserId,
            trainerName: 'Aarav',
            memberId: guruUserId,
            memberName: 'DK',
            currentUserId: guruUserId,
            displayName: 'DK',
            focus: 'Trainer video check-in',
            audioMuted: prejoinState.audioMuted,
            videoMuted: prejoinState.videoMuted,
          );
      if (!context.mounted) {
        return;
      }
      await navigator.push(
        MaterialPageRoute<void>(builder: (_) => const GuruCallScreen()),
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Unable to join meeting: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prejoinState = ref.watch(callPrejoinProvider(_roomId));
    final sessionAsync = ref.watch(callSessionProvider);
    final roomAsync = ref.watch(callRoomProvider(_roomId));
    final requestsAsync = ref.watch(
      memberAppointmentRequestsProvider(guruUserId),
    );
    final session = sessionAsync.asData?.value;
    final participantCount = roomAsync.asData?.value?.participantCount ?? 0;
    final canJoinScheduledCall =
        requestsAsync.asData?.value.any(
          (request) =>
              request.trainerId == trainerUserId &&
              request.canJoinAt(DateTime.now()),
        ) ??
        false;
    final canJoin = _isSupportedPlatform && canJoinScheduledCall;

    return Scaffold(
      appBar: AppBar(title: const Text('Join Video Call')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (!_isSupportedPlatform) const _UnsupportedPlatformBanner(),
                if (!_isSupportedPlatform) const SizedBox(height: 16),
                CallPrejoinCard(
                  title: 'Trainer Video Call',
                  subtitle: canJoinScheduledCall
                      ? 'Join the approved trainer call with Aarav.'
                      : 'Approved calls become joinable only during the scheduled slot.',
                  roomId: _roomId,
                  audioMuted: prejoinState.audioMuted,
                  videoMuted: prejoinState.videoMuted,
                  onAudioMutedChanged: ref
                      .read(callPrejoinProvider(_roomId).notifier)
                      .setAudioMuted,
                  onVideoMutedChanged: ref
                      .read(callPrejoinProvider(_roomId).notifier)
                      .setVideoMuted,
                  onJoinPressed: canJoin
                      ? () => _joinMeeting(context, ref)
                      : () {},
                  participantSummary: participantCount == 0
                      ? 'Waiting for participants'
                      : '$participantCount participant(s) in room',
                  isJoining: session?.isJoining ?? false,
                  canJoin: canJoin,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UnsupportedPlatformBanner extends StatelessWidget {
  const _UnsupportedPlatformBanner();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Jitsi calling is enabled for Android, iOS, and web in this app.',
        ),
      ),
    );
  }
}
