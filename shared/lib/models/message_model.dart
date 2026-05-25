import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Message extends Equatable {
  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    this.type = 'text',
    this.status = 'sent',
    this.conversationId,
    this.replyToMessageId,
    this.mediaUrl,
    this.readAt,
    this.updatedAt,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;
  final String type;
  final String status;
  final String? conversationId;
  final String? replyToMessageId;
  final String? mediaUrl;
  final DateTime? readAt;
  final DateTime? updatedAt;

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      content: (json['text'] ?? json['content']) as String,
      createdAt: parseDateTime(json['createdAt']) ?? DateTime.now(),
      type: json['type'] as String? ?? 'text',
      status: json['status'] as String? ?? 'sent',
      conversationId: (json['chatId'] ?? json['conversationId']) as String?,
      replyToMessageId: json['replyToMessageId'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      readAt: parseDateTime(json['readAt']),
      updatedAt: parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': conversationId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'type': type,
      'status': status,
      'replyToMessageId': replyToMessageId,
      'mediaUrl': mediaUrl,
      'readAt': readAt == null ? null : Timestamp.fromDate(readAt!),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
    };
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? createdAt,
    String? type,
    String? status,
    String? conversationId,
    String? replyToMessageId,
    String? mediaUrl,
    DateTime? readAt,
    DateTime? updatedAt,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      status: status ?? this.status,
      conversationId: conversationId ?? this.conversationId,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      readAt: readAt ?? this.readAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    senderId,
    receiverId,
    content,
    createdAt,
    type,
    status,
    conversationId,
    replyToMessageId,
    mediaUrl,
    readAt,
    updatedAt,
  ];

  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String && value.isNotEmpty) return DateTime.parse(value);
    return null;
  }
}
