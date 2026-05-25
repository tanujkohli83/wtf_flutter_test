import 'package:flutter/material.dart';

import '../../domain/training_session.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({super.key, required this.session});

  final TrainingSession session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SessionIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      session.trainerName,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              _RatingBadge(rating: session.rating),
            ],
          ),
          const SizedBox(height: 16),
          _SessionMeta(session: session),
          const SizedBox(height: 14),
          Text('Trainer notes', style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          Text(session.trainerNotes, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _SessionIcon extends StatelessWidget {
  const _SessionIcon();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.fitness_center_rounded,
        color: theme.colorScheme.primary,
        size: 22,
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFB7791F), size: 16),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: theme.textTheme.labelMedium?.copyWith(
              color: const Color(0xFFB7791F),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionMeta extends StatelessWidget {
  const _SessionMeta({required this.session});

  final TrainingSession session;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _MetaItem(icon: Icons.calendar_today_rounded, label: session.dateLabel),
        _MetaItem(
          icon: Icons.timer_rounded,
          label: '${session.durationMinutes} min',
        ),
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.labelLarge),
      ],
    );
  }
}
