import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class SessionLogModel {
  const SessionLogModel({
    required this.id,
    required this.roomId,
    required this.trainerId,
    required this.trainerName,
    required this.memberId,
    required this.memberName,
    required this.focus,
    required this.startedAt,
    this.endedAt,
    this.durationSeconds,
    this.memberRating,
    this.trainerNotes = '',
    this.memberNotes = '',
    this.createdByUserId,
  });

  final String id;
  final String roomId;
  final String trainerId;
  final String trainerName;
  final String memberId;
  final String memberName;
  final String focus;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? durationSeconds;
  final double? memberRating;
  final String trainerNotes;
  final String memberNotes;
  final String? createdByUserId;

  bool get isCompleted => endedAt != null;

  Duration get duration => Duration(seconds: durationSeconds ?? 0);

  SessionLogModel copyWith({
    String? id,
    String? roomId,
    String? trainerId,
    String? trainerName,
    String? memberId,
    String? memberName,
    String? focus,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSeconds,
    double? memberRating,
    String? trainerNotes,
    String? memberNotes,
    String? createdByUserId,
    bool clearEndedAt = false,
    bool clearDuration = false,
    bool clearMemberRating = false,
  }) {
    return SessionLogModel(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      trainerId: trainerId ?? this.trainerId,
      trainerName: trainerName ?? this.trainerName,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      focus: focus ?? this.focus,
      startedAt: startedAt ?? this.startedAt,
      endedAt: clearEndedAt ? null : endedAt ?? this.endedAt,
      durationSeconds: clearDuration
          ? null
          : durationSeconds ?? this.durationSeconds,
      memberRating: clearMemberRating
          ? null
          : memberRating ?? this.memberRating,
      trainerNotes: trainerNotes ?? this.trainerNotes,
      memberNotes: memberNotes ?? this.memberNotes,
      createdByUserId: createdByUserId ?? this.createdByUserId,
    );
  }

  factory SessionLogModel.fromJson(Map<String, dynamic> json) {
    return SessionLogModel(
      id: json['id'] as String,
      roomId: json['roomId'] as String,
      trainerId: json['trainerId'] as String,
      trainerName: json['trainerName'] as String? ?? 'Trainer',
      memberId: json['memberId'] as String,
      memberName: json['memberName'] as String? ?? 'Member',
      focus: json['focus'] as String? ?? 'Training session',
      startedAt: _parseDateTime(json['startedAt']) ?? DateTime.now(),
      endedAt: _parseDateTime(json['endedAt']),
      durationSeconds: json['durationSeconds'] as int?,
      memberRating: (json['memberRating'] as num?)?.toDouble(),
      trainerNotes: json['trainerNotes'] as String? ?? '',
      memberNotes: json['memberNotes'] as String? ?? '',
      createdByUserId: json['createdByUserId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'roomId': roomId,
      'trainerId': trainerId,
      'trainerName': trainerName,
      'memberId': memberId,
      'memberName': memberName,
      'focus': focus,
      'startedAt': Timestamp.fromDate(startedAt),
      'endedAt': endedAt == null ? null : Timestamp.fromDate(endedAt!),
      'durationSeconds': durationSeconds,
      'memberRating': memberRating,
      'trainerNotes': trainerNotes,
      'memberNotes': memberNotes,
      'createdByUserId': createdByUserId,
    };
  }
}

DateTime? _parseDateTime(dynamic value) {
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
