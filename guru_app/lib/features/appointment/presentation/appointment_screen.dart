import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/appointment_controller.dart';
import 'widgets/appointment_day_picker.dart';
import 'widgets/appointment_note_field.dart';
import 'widgets/appointment_slot_picker.dart';

class AppointmentScreen extends ConsumerWidget {
  const AppointmentScreen({super.key});

  void _requestAppointment(BuildContext context, AppointmentState appointment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Requested ${appointment.selectedSlot} appointment'),
      ),
    );
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
                ? () => _requestAppointment(context, appointment)
                : null,
            icon: const Icon(Icons.calendar_month_rounded),
            label: const Text('Request Appointment'),
          ),
        ),
      ),
    );
  }
}
