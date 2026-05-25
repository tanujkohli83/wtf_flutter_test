import 'package:flutter/material.dart';

import '../services/call_service.dart';

class CallMeetingView extends StatelessWidget {
  const CallMeetingView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.roomId,
    required this.participants,
    required this.localParticipantId,
    required this.audioMuted,
    required this.videoMuted,
    required this.isJoining,
    required this.isInMeeting,
    required this.onAudioToggle,
    required this.onVideoToggle,
    required this.onLeavePressed,
  });

  final String title;
  final String subtitle;
  final String roomId;
  final List<CallParticipantState> participants;
  final String localParticipantId;
  final bool audioMuted;
  final bool videoMuted;
  final bool isJoining;
  final bool isInMeeting;
  final Future<void> Function() onAudioToggle;
  final Future<void> Function() onVideoToggle;
  final Future<void> Function() onLeavePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remoteParticipants = participants
        .where((participant) => participant.userId != localParticipantId)
        .toList();
    final localParticipant = participants
        .cast<CallParticipantState?>()
        .firstWhere(
          (participant) => participant?.userId == localParticipantId,
          orElse: () => null,
        );

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 920;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _CallHero(
                title: title,
                subtitle: subtitle,
                roomId: roomId,
                participantCount: participants.length,
                isJoining: isJoining,
                isInMeeting: isInMeeting,
              ),
              const SizedBox(height: 20),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _ParticipantStage(
                        participants: remoteParticipants,
                        emptyLabel: 'Waiting for the other participant to join',
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          _ParticipantTile(
                            participant: localParticipant,
                            isLocal: true,
                          ),
                          const SizedBox(height: 20),
                          _ControlsCard(
                            audioMuted: audioMuted,
                            videoMuted: videoMuted,
                            onAudioToggle: onAudioToggle,
                            onVideoToggle: onVideoToggle,
                            onLeavePressed: onLeavePressed,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                _ParticipantStage(
                  participants: remoteParticipants,
                  emptyLabel: 'Waiting for the other participant to join',
                ),
                const SizedBox(height: 20),
                _ParticipantTile(participant: localParticipant, isLocal: true),
                const SizedBox(height: 20),
                _ControlsCard(
                  audioMuted: audioMuted,
                  videoMuted: videoMuted,
                  onAudioToggle: onAudioToggle,
                  onVideoToggle: onVideoToggle,
                  onLeavePressed: onLeavePressed,
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'Jitsi renders the live conference view while this screen manages meeting state and controls.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CallHero extends StatelessWidget {
  const _CallHero({
    required this.title,
    required this.subtitle,
    required this.roomId,
    required this.participantCount,
    required this.isJoining,
    required this.isInMeeting,
  });

  final String title;
  final String subtitle;
  final String roomId;
  final int participantCount;
  final bool isJoining;
  final bool isInMeeting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusLabel = isJoining
        ? 'Connecting'
        : isInMeeting
        ? 'Live'
        : 'Ready';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF08111E), Color(0xFF123A62), Color(0xFF0F8E89)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _HeroBadge(label: statusLabel),
              const SizedBox(width: 10),
              _HeroBadge(label: '$participantCount participant(s)'),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Room ID',
            style: theme.textTheme.labelMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          SelectableText(
            roomId,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ParticipantStage extends StatelessWidget {
  const _ParticipantStage({
    required this.participants,
    required this.emptyLabel,
  });

  final List<CallParticipantState> participants;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (participants.isEmpty) {
      return Container(
        height: 360,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_search_rounded,
                size: 44,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 14),
              Text(emptyLabel, style: theme.textTheme.titleMedium),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: participants.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: participants.length == 1 ? 1 : 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.12,
      ),
      itemBuilder: (context, index) {
        return _ParticipantTile(participant: participants[index]);
      },
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({required this.participant, this.isLocal = false});

  final CallParticipantState? participant;
  final bool isLocal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName =
        participant?.displayName ?? (isLocal ? 'You' : 'Waiting');
    final videoMuted = participant?.videoMuted ?? true;
    final audioMuted = participant?.audioMuted ?? true;

    return Container(
      constraints: const BoxConstraints(minHeight: 170),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: videoMuted
              ? [const Color(0xFF1B2433), const Color(0xFF324056)]
              : [const Color(0xFF0D342E), const Color(0xFF157061)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _HeroBadge(label: isLocal ? 'You' : 'Participant'),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox.shrink()),
              if (audioMuted)
                const Icon(Icons.mic_off_rounded, color: Colors.white70),
              if (!audioMuted)
                const Icon(Icons.mic_rounded, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white.withValues(alpha: 0.14),
              child: Icon(
                videoMuted
                    ? Icons.videocam_off_rounded
                    : Icons.videocam_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            displayName,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            videoMuted ? 'Video off' : 'Video on',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlsCard extends StatelessWidget {
  const _ControlsCard({
    required this.audioMuted,
    required this.videoMuted,
    required this.onAudioToggle,
    required this.onVideoToggle,
    required this.onLeavePressed,
  });

  final bool audioMuted;
  final bool videoMuted;
  final Future<void> Function() onAudioToggle;
  final Future<void> Function() onVideoToggle;
  final Future<void> Function() onLeavePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Controls', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: audioMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                  label: audioMuted ? 'Unmute' : 'Mute',
                  onPressed: onAudioToggle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: videoMuted
                      ? Icons.videocam_off_rounded
                      : Icons.videocam_rounded,
                  label: videoMuted ? 'Turn On Video' : 'Turn Off Video',
                  onPressed: onVideoToggle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onLeavePressed,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB3261E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              icon: const Icon(Icons.call_end_rounded),
              label: const Text('Leave Meeting'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      icon: Icon(icon),
      label: Text(label, textAlign: TextAlign.center),
    );
  }
}
