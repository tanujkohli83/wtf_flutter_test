class TrainingSession {
  const TrainingSession({
    required this.trainerName,
    required this.title,
    required this.date,
    required this.dateLabel,
    required this.durationMinutes,
    required this.rating,
    required this.trainerNotes,
  });

  final String trainerName;
  final String title;
  final DateTime date;
  final String dateLabel;
  final int durationMinutes;
  final double rating;
  final String trainerNotes;
}

enum SessionSort { newest, duration, rating }
