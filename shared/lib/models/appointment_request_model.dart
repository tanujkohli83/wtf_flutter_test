import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum AppointmentRequestStatus { pending, approved, declined }

@immutable
class AppointmentRequestModel {
  const AppointmentRequestModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.trainerId,
    required this.trainerName,
    required this.focus,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.status,
    required this.createdAt,
    this.note = '',
    this.respondedAt,
  });

  final String id;
  final String memberId;
  final String memberName;
  final String trainerId;
  final String trainerName;
  final String focus;
  final String note;
  final DateTime scheduledAt;
  final int durationMinutes;
  final AppointmentRequestStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  DateTime get endsAt => scheduledAt.add(Duration(minutes: durationMinutes));

  bool canJoinAt(DateTime now) {
    if (status != AppointmentRequestStatus.approved) {
      return false;
    }
    return !now.isBefore(scheduledAt) && now.isBefore(endsAt);
  }

  AppointmentRequestModel copyWith({
    String? id,
    String? memberId,
    String? memberName,
    String? trainerId,
    String? trainerName,
    String? focus,
    String? note,
    DateTime? scheduledAt,
    int? durationMinutes,
    AppointmentRequestStatus? status,
    DateTime? createdAt,
    DateTime? respondedAt,
    bool clearRespondedAt = false,
  }) {
    return AppointmentRequestModel(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      trainerId: trainerId ?? this.trainerId,
      trainerName: trainerName ?? this.trainerName,
      focus: focus ?? this.focus,
      note: note ?? this.note,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: clearRespondedAt ? null : respondedAt ?? this.respondedAt,
    );
  }

  factory AppointmentRequestModel.fromJson(Map<String, dynamic> json) {
    return AppointmentRequestModel(
      id: json['id'] as String,
      memberId: json['memberId'] as String,
      memberName: json['memberName'] as String? ?? json['memberId'] as String,
      trainerId: json['trainerId'] as String,
      trainerName:
          json['trainerName'] as String? ?? json['trainerId'] as String,
      focus: json['focus'] as String? ?? 'Trainer call',
      note: json['note'] as String? ?? '',
      scheduledAt: _parseDateTime(json['scheduledAt']) ?? DateTime.now(),
      durationMinutes: json['durationMinutes'] as int? ?? 30,
      status: _parseStatus(json['status'] as String?),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      respondedAt: _parseDateTime(json['respondedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'memberId': memberId,
      'memberName': memberName,
      'trainerId': trainerId,
      'trainerName': trainerName,
      'focus': focus,
      'note': note,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'durationMinutes': durationMinutes,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'respondedAt': respondedAt == null
          ? null
          : Timestamp.fromDate(respondedAt!),
    };
  }

  static AppointmentRequestStatus _parseStatus(String? value) {
    return switch (value) {
      'approved' => AppointmentRequestStatus.approved,
      'declined' => AppointmentRequestStatus.declined,
      _ => AppointmentRequestStatus.pending,
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
