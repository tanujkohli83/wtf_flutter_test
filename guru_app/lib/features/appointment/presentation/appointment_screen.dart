import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

import '../../chat/application/chat_controller.dart';
import '../application/appointment_controller.dart';
import 'widgets/appointment_day_picker.dart';
import 'widgets/appointment_note_field.dart';
import 'widgets/appointment_slot_picker.dart';

class AppointmentScreen extends ConsumerWidget {
  const AppointmentScreen({super.key});

  Future<void> _requestAppointment(
    BuildContext context,
    WidgetRef ref,
    AppointmentState appointment,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final scheduledAt = AppointmentController.scheduledAtFor(appointment);
    final request = AppointmentRequestModel(
      id: 'req_${scheduledAt.microsecondsSinceEpoch}_$guruUserId',
      memberId: guruUserId,
      memberName: 'DK',
      trainerId: trainerUserId,
      trainerName: 'Aarav',
      focus: appointment.note.trim().isEmpty
          ? 'Trainer video call'
          : appointment.note.trim(),
      note: appointment.note.trim(),
      scheduledAt: scheduledAt,
      durationMinutes: AppointmentController.appointmentDurationMinutes,
      status: AppointmentRequestStatus.pending,
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(appointmentRequestServiceProvider).createRequest(request);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Requested appointment for ${appointment.selectedSlot}.',
          ),
        ),
      );
      ref.invalidate(appointmentControllerProvider);
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Unable to send request: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointment = ref.watch(appointmentControllerProvider);
    final controller = ref.read(appointmentControllerProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Call')),
      body: SafeArea(
        child: ListView(
          key: const Key('appointment-scroll'),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 120),
          children: [
            Text('Pick a time', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Choose one of the next 3 days and reserve a 30 minute trainer call.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),
            AppointmentDayPicker(
              selectedIndex: appointment.selectedDayIndex,
              onSelected: controller.selectDay,
            ),
            const SizedBox(height: 28),
            Text(
              'Available 30 minute slots',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 14),
            AppointmentSlotPicker(
              slots: AppointmentController.slots,
              selectedSlot: appointment.selectedSlot,
              onSelected: controller.selectSlot,
            ),
            const SizedBox(height: 28),
            AppointmentNoteField(onChanged: controller.updateNote),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: FilledButton.icon(
            onPressed: appointment.canRequest
                ? () => _requestAppointment(context, ref, appointment)
                : null,
            icon: const Icon(Icons.calendar_month_rounded),
            label: const Text('Request Appointment'),
          ),
        ),
      ),
    );
  }
}
