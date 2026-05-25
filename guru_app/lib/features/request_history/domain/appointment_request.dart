enum AppointmentRequestStatus { pending, approved, declined }

class AppointmentRequest {
  const AppointmentRequest({
    required this.trainerName,
    required this.focus,
    required this.dateLabel,
    required this.timeLabel,
    required this.status,
    required this.note,
  });

  final String trainerName;
  final String focus;
  final String dateLabel;
  final String timeLabel;
  final AppointmentRequestStatus status;
  final String note;
}
