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
}

final appointmentControllerProvider =
    NotifierProvider<AppointmentController, AppointmentState>(
      AppointmentController.new,
    );
