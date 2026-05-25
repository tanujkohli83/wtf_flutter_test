import 'package:flutter/material.dart';

class CallPrejoinCard extends StatelessWidget {
  const CallPrejoinCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.roomId,
    required this.audioMuted,
    required this.videoMuted,
    required this.onAudioMutedChanged,
    required this.onVideoMutedChanged,
    required this.onJoinPressed,
    this.participantSummary,
    this.isJoining = false,
    this.canJoin = true,
  });

  final String title;
  final String subtitle;
  final String roomId;
  final bool audioMuted;
  final bool videoMuted;
  final ValueChanged<bool> onAudioMutedChanged;
  final ValueChanged<bool> onVideoMutedChanged;
  final VoidCallback onJoinPressed;
  final String? participantSummary;
  final bool isJoining;
  final bool canJoin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.sizeOf(context).width >= 760;
    final preview = _CallPreview(
      roomId: roomId,
      participantSummary: participantSummary,
      audioMuted: audioMuted,
      videoMuted: videoMuted,
    );
    final controls = _CallControls(
      title: title,
      subtitle: subtitle,
      audioMuted: audioMuted,
      videoMuted: videoMuted,
      onAudioMutedChanged: onAudioMutedChanged,
      onVideoMutedChanged: onVideoMutedChanged,
      onJoinPressed: onJoinPressed,
      isJoining: isJoining,
      canJoin: canJoin,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceContainerLow,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: preview),
                  const SizedBox(width: 24),
                  Expanded(child: controls),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [preview, const SizedBox(height: 24), controls],
              ),
      ),
    );
  }
}

class _CallPreview extends StatelessWidget {
  const _CallPreview({
    required this.roomId,
    required this.participantSummary,
    required this.audioMuted,
    required this.videoMuted,
  });

  final String roomId;
  final String? participantSummary;
  final bool audioMuted;
  final bool videoMuted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 280),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF07111F), Color(0xFF163556), Color(0xFF0A7EA4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Ready to join',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Center(
            child: Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
              ),
              child: const Icon(
                Icons.videocam_rounded,
                size: 42,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatusPill(
                icon: audioMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                label: audioMuted ? 'Mic off' : 'Mic on',
              ),
              _StatusPill(
                icon: videoMuted
                    ? Icons.videocam_off_rounded
                    : Icons.videocam_rounded,
                label: videoMuted ? 'Camera off' : 'Camera on',
              ),
            ],
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
          if (participantSummary != null) ...[
            const SizedBox(height: 12),
            Text(
              participantSummary!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.86),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CallControls extends StatelessWidget {
  const _CallControls({
    required this.title,
    required this.subtitle,
    required this.audioMuted,
    required this.videoMuted,
    required this.onAudioMutedChanged,
    required this.onVideoMutedChanged,
    required this.onJoinPressed,
    required this.isJoining,
    required this.canJoin,
  });

  final String title;
  final String subtitle;
  final bool audioMuted;
  final bool videoMuted;
  final ValueChanged<bool> onAudioMutedChanged;
  final ValueChanged<bool> onVideoMutedChanged;
  final VoidCallback onJoinPressed;
  final bool isJoining;
  final bool canJoin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(subtitle, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 24),
        _ControlTile(
          icon: audioMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
          title: 'Microphone',
          subtitle: audioMuted ? 'Join muted' : 'Join unmuted',
          value: !audioMuted,
          onChanged: (value) => onAudioMutedChanged(!value),
        ),
        const SizedBox(height: 14),
        _ControlTile(
          icon: videoMuted
              ? Icons.videocam_off_rounded
              : Icons.videocam_rounded,
          title: 'Camera',
          subtitle: videoMuted ? 'Join with video off' : 'Join with video on',
          value: !videoMuted,
          onChanged: (value) => onVideoMutedChanged(!value),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: isJoining || !canJoin ? null : onJoinPressed,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            icon: isJoining
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.video_call_rounded),
            label: Text(isJoining ? 'Joining...' : 'Join Meeting'),
          ),
        ),
      ],
    );
  }
}

class _ControlTile extends StatelessWidget {
  const _ControlTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
