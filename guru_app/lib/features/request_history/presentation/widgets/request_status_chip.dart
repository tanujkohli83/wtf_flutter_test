import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class RequestStatusChip extends StatelessWidget {
  const RequestStatusChip({super.key, required this.status});

  final AppointmentRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _StatusColors.fromStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: colors.foreground,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String get _label {
    return switch (status) {
      AppointmentRequestStatus.pending => 'Pending',
      AppointmentRequestStatus.approved => 'Approved',
      AppointmentRequestStatus.declined => 'Declined',
    };
  }
}

class _StatusColors {
  const _StatusColors({required this.background, required this.foreground});

  final Color background;
  final Color foreground;

  factory _StatusColors.fromStatus(AppointmentRequestStatus status) {
    return switch (status) {
      AppointmentRequestStatus.pending => const _StatusColors(
        background: Color(0xFFFFF7E6),
        foreground: Color(0xFFB7791F),
      ),
      AppointmentRequestStatus.approved => const _StatusColors(
        background: Color(0xFFE8F7EF),
        foreground: Color(0xFF1F7A4D),
      ),
      AppointmentRequestStatus.declined => const _StatusColors(
        background: Color(0xFFFFECEC),
        foreground: Color(0xFFC53030),
      ),
    };
  }
}
