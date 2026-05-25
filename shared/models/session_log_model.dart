import 'package:equatable/equatable.dart';

class SessionLog extends Equatable {
  const SessionLog({
    required this.id,
    required this.userId,
    required this.startedAt,
    this.endedAt,
    this.durationSeconds,
    this.deviceInfo,
    this.ipAddress,
    this.status = 'active',
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String userId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? durationSeconds;
  final String? deviceInfo;
  final String? ipAddress;
  final String status;
  final Map<String, dynamic> metadata;

  factory SessionLog.fromJson(Map<String, dynamic> json) {
    return SessionLog(
      id: json['id'] as String,
      userId: json['userId'] as String,
      startedAt: _dateTimeFromJson(json['startedAt']) ?? DateTime.now(),
      endedAt: _dateTimeFromJson(json['endedAt']),
      durationSeconds: json['durationSeconds'] as int?,
      deviceInfo: json['deviceInfo'] as String?,
      ipAddress: json['ipAddress'] as String?,
      status: json['status'] as String? ?? 'active',
      metadata: Map<String, dynamic>.from(
        json['metadata'] as Map? ?? const <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'durationSeconds': durationSeconds,
      'deviceInfo': deviceInfo,
      'ipAddress': ipAddress,
      'status': status,
      'metadata': metadata,
    };
  }

  SessionLog copyWith({
    String? id,
    String? userId,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSeconds,
    String? deviceInfo,
    String? ipAddress,
    String? status,
    Map<String, dynamic>? metadata,
  }) {
    return SessionLog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      ipAddress: ipAddress ?? this.ipAddress,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    startedAt,
    endedAt,
    durationSeconds,
    deviceInfo,
    ipAddress,
    status,
    metadata,
  ];

  static DateTime? _dateTimeFromJson(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.parse(value);
    return null;
  }
}
