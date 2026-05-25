import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppointmentState {
  const AppointmentState({
    required this.selectedDayIndex,
    required this.selectedSlot,
    required this.note,
  });

  final int selectedDayIndex;
  final String selectedSlot;
  final String note;

  bool get canRequest => selectedSlot.isNotEmpty;

  DateTime selectedDate() {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
    ).add(Duration(days: selectedDayIndex));
  }

  AppointmentState copyWith({
    int? selectedDayIndex,
    String? selectedSlot,
    String? note,
  }) {
    return AppointmentState(
      selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
      selectedSlot: selectedSlot ?? this.selectedSlot,
      note: note ?? this.note,
    );
  }
}

class AppointmentController extends Notifier<AppointmentState> {
  static const int appointmentDurationMinutes = 30;
  static const slots = [
    '8:00 AM',
    '8:30 AM',
    '9:00 AM',
    '9:30 AM',
    '10:00 AM',
    '10:30 AM',
    '5:00 PM',
    '5:30 PM',
    '6:00 PM',
    '6:30 PM',
  ];

  @override
  AppointmentState build() {
    return const AppointmentState(
      selectedDayIndex: 0,
      selectedSlot: '9:00 AM',
      note: '',
    );
  }

  void selectDay(int index) {
    state = state.copyWith(selectedDayIndex: index);
  }

  void selectSlot(String slot) {
    state = state.copyWith(selectedSlot: slot);
  }

  void updateNote(String note) {
    state = state.copyWith(note: note);
  }

  static DateTime scheduledAtFor(AppointmentState state) {
    final date = state.selectedDate();
    final parsed = _parseSlot(state.selectedSlot);
    return DateTime(
      date.year,
      date.month,
      date.day,
      parsed.hour,
      parsed.minute,
    );
  }

  static ({int hour, int minute}) _parseSlot(String slot) {
    final parts = slot.trim().split(' ');
    final timeParts = parts.first.split(':');
    var hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final meridiem = parts.last.toUpperCase();

    if (meridiem == 'PM' && hour != 12) {
      hour += 12;
    } else if (meridiem == 'AM' && hour == 12) {
      hour = 0;
    }

    return (hour: hour, minute: minute);
  }
}

final appointmentControllerProvider =
    NotifierProvider<AppointmentController, AppointmentState>(
      AppointmentController.new,
    );
