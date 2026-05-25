import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../chat/application/trainer_chat_controller.dart';

class TrainerCallScreen extends ConsumerStatefulWidget {
  const TrainerCallScreen({super.key});

  @override
  ConsumerState<TrainerCallScreen> createState() => _TrainerCallScreenState();
}

class _TrainerCallScreenState extends ConsumerState<TrainerCallScreen> {
  bool _handlingCallEnd = false;

  String get _roomId =>
      CallService.roomIdFor(trainerId: trainerUserId, memberId: guruUserId);

  Future<void> _completeSession(CallSessionState session) async {
    if (_handlingCallEnd) {
      return;
    }
    _handlingCallEnd = true;

    final sessionLogId = session.sessionLogId;
    if (sessionLogId != null && mounted) {
      final feedback = await showModalBottomSheet<SessionFeedbackResult>(
        context: context,
        isScrollControlled: true,
        builder: (_) => SessionFeedbackSheet(
          isTrainerView: true,
          otherPartyName: session.memberName,
        ),
      );

      await ref.read(sessionLogServiceProvider).completeSession(
        sessionId: sessionLogId,
        endedAt: DateTime.now(),
        trainerNotes: feedback?.trainerNotes,
      );
    }

    if (mounted) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<CallSessionState?>>(callSessionProvider, (previous, next) {
      final previousSession = previous?.asData?.value;
      final session = next.asData?.value;
      if (mounted && session == null && previousSession != null) {
        _completeSession(previousSession);
      }
    });

    final session = ref.watch(callSessionProvider).asData?.value;
    final room = ref.watch(callRoomProvider(_roomId)).asData?.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Video Call')),
      body: CallMeetingView(
        title: 'Member Call',
        subtitle: 'Live Jitsi meeting with DK.',
        roomId: _roomId,
        participants: room?.participants.values.toList() ?? const [],
        localParticipantId: trainerUserId,
        audioMuted: session?.audioMuted ?? false,
        videoMuted: session?.videoMuted ?? false,
        isJoining: session?.isJoining ?? true,
        isInMeeting: session?.isInMeeting ?? false,
        onAudioToggle: () => ref
            .read(callServiceProvider)
            .setAudioMuted(!(session?.audioMuted ?? false)),
        onVideoToggle: () => ref
            .read(callServiceProvider)
            .setVideoMuted(!(session?.videoMuted ?? false)),
        onLeavePressed: () async {
          await ref.read(callServiceProvider).leaveMeeting();
        },
      ),
    );
  }
}
