import 'package:equatable/equatable.dart';

class CallRequest extends Equatable {
  const CallRequest({
    required this.id,
    required this.callerId,
    required this.receiverId,
    required this.createdAt,
    this.channelName,
    this.callType = 'video',
    this.status = 'pending',
    this.token,
    this.expiresAt,
    this.respondedAt,
  });

  final String id;
  final String callerId;
  final String receiverId;
  final DateTime createdAt;
  final String? channelName;
  final String callType;
  final String status;
  final String? token;
  final DateTime? expiresAt;
  final DateTime? respondedAt;

  factory CallRequest.fromJson(Map<String, dynamic> json) {
    return CallRequest(
      id: json['id'] as String,
      callerId: json['callerId'] as String,
      receiverId: json['receiverId'] as String,
      createdAt: _dateTimeFromJson(json['createdAt']) ?? DateTime.now(),
      channelName: json['channelName'] as String?,
      callType: json['callType'] as String? ?? 'video',
      status: json['status'] as String? ?? 'pending',
      token: json['token'] as String?,
      expiresAt: _dateTimeFromJson(json['expiresAt']),
      respondedAt: _dateTimeFromJson(json['respondedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'callerId': callerId,
      'receiverId': receiverId,
      'createdAt': createdAt.toIso8601String(),
      'channelName': channelName,
      'callType': callType,
      'status': status,
      'token': token,
      'expiresAt': expiresAt?.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  CallRequest copyWith({
    String? id,
    String? callerId,
    String? receiverId,
    DateTime? createdAt,
    String? channelName,
    String? callType,
    String? status,
    String? token,
    DateTime? expiresAt,
    DateTime? respondedAt,
  }) {
    return CallRequest(
      id: id ?? this.id,
      callerId: callerId ?? this.callerId,
      receiverId: receiverId ?? this.receiverId,
      createdAt: createdAt ?? this.createdAt,
      channelName: channelName ?? this.channelName,
      callType: callType ?? this.callType,
      status: status ?? this.status,
      token: token ?? this.token,
      expiresAt: expiresAt ?? this.expiresAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    callerId,
    receiverId,
    createdAt,
    channelName,
    callType,
    status,
    token,
    expiresAt,
    respondedAt,
  ];

  static DateTime? _dateTimeFromJson(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.parse(value);
    return null;
  }
}
