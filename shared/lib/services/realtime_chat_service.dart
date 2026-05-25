import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/message_model.dart';

const String messageStatusSent = 'sent';
const String messageStatusDelivered = 'delivered';
const String messageStatusRead = 'read';
const String messageStatusPending = 'pending';
const String messageStatusFailed = 'failed';

class ChatParticipants {
  const ChatParticipants({
    required this.currentUserId,
    required this.otherUserId,
  });

  final String currentUserId;
  final String otherUserId;

  String get conversationId =>
      RealtimeChatService.conversationIdFor(currentUserId, otherUserId);

  @override
  bool operator ==(Object other) {
    return other is ChatParticipants &&
        other.currentUserId == currentUserId &&
        other.otherUserId == otherUserId;
  }

  @override
  int get hashCode => Object.hash(currentUserId, otherUserId);
}

class TypingState {
  const TypingState({
    required this.conversationId,
    required this.userId,
    required this.isTyping,
    required this.updatedAt,
  });

  final String conversationId;
  final String userId;
  final bool isTyping;
  final DateTime updatedAt;

  static TypingState idle({
    required String conversationId,
    required String userId,
  }) {
    return TypingState(
      conversationId: conversationId,
      userId: userId,
      isTyping: false,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class RealtimeChatService {
  RealtimeChatService.disabled() : _firestore = null, _isConfigured = false;

  RealtimeChatService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _isConfigured = true;

  final FirebaseFirestore? _firestore;
  final bool _isConfigured;
  final Map<String, List<Message>> _messagesByConversation =
      <String, List<Message>>{};
  final Map<String, StreamController<List<Message>>> _messageControllers =
      <String, StreamController<List<Message>>>{};
  final Map<String, StreamController<TypingState>> _typingControllers =
      <String, StreamController<TypingState>>{};
  final Map<String, Timer> _typingTimers = <String, Timer>{};
  final Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
  _messageSubscriptions =
      <String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>{};
  final Map<String, StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>>
  _typingSubscriptions =
      <String, StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>>{};

  CollectionReference<Map<String, dynamic>> get _messagesCollection =>
      _firestore!.collection('messages');

  CollectionReference<Map<String, dynamic>> get _typingCollection =>
      _firestore!.collection('typing_states');

  static String conversationIdFor(String firstUserId, String secondUserId) {
    final sortedIds = <String>[
      firstUserId.trim().toLowerCase(),
      secondUserId.trim().toLowerCase(),
    ]..sort();
    return '${sortedIds.first}_${sortedIds.last}';
  }

  Stream<List<Message>> watchMessages({
    required String currentUserId,
    required String otherUserId,
  }) {
    final conversationId = conversationIdFor(currentUserId, otherUserId);
    final controller = _messageControllerFor(conversationId);
    _attachMessageListener(
      conversationId: conversationId,
      currentUserId: currentUserId,
    );

    Future<void>.microtask(() {
      if (!controller.isClosed) {
        controller.add(_messagesFor(conversationId));
      }
    });

    return controller.stream;
  }

  Stream<TypingState> watchTyping({
    required String currentUserId,
    required String otherUserId,
  }) {
    final conversationId = conversationIdFor(currentUserId, otherUserId);
    _attachTypingListener(conversationId: conversationId, userId: otherUserId);
    final controller = _typingControllerFor(
      conversationId: conversationId,
      userId: otherUserId,
    );

    Future<void>.microtask(() {
      if (!controller.isClosed) {
        controller.add(
          TypingState.idle(conversationId: conversationId, userId: otherUserId),
        );
      }
    });

    return controller.stream;
  }

  Future<Message> sendMessage({
    required String senderId,
    required String receiverId,
    required String content,
    String type = 'text',
    String? replyToMessageId,
    String? mediaUrl,
  }) async {
    if (!_isConfigured) {
      throw StateError('Firebase is not configured.');
    }
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      throw ArgumentError.value(content, 'content', 'Message cannot be empty.');
    }

    final now = DateTime.now();
    final conversationId = conversationIdFor(senderId, receiverId);
    final document = _messagesCollection.doc();
    final message = Message(
      id: document.id,
      senderId: senderId,
      receiverId: receiverId,
      content: trimmedContent,
      createdAt: now,
      type: type,
      status: messageStatusPending,
      conversationId: conversationId,
      replyToMessageId: replyToMessageId,
      mediaUrl: mediaUrl,
      updatedAt: now,
    );
    _upsertLocalMessage(conversationId: conversationId, message: message);
    _emitMessages(conversationId);

    try {
      await document.set(
        message
            .copyWith(status: messageStatusSent, updatedAt: DateTime.now())
            .toJson(),
      );
      _updateLocalMessage(
        conversationId: conversationId,
        messageId: message.id,
        transform: (current) => current.copyWith(
          status: messageStatusSent,
          updatedAt: DateTime.now(),
        ),
      );
      _emitMessages(conversationId);
    } catch (_) {
      _updateLocalMessage(
        conversationId: conversationId,
        messageId: message.id,
        transform: (current) => current.copyWith(
          status: messageStatusFailed,
          updatedAt: DateTime.now(),
        ),
      );
      _emitMessages(conversationId);
    }

    return message;
  }

  Future<void> markConversationRead({
    required String readerId,
    required String otherUserId,
  }) {
    if (!_isConfigured) {
      return Future<void>.value();
    }
    final conversationId = conversationIdFor(readerId, otherUserId);
    final messages = _messagesByConversation[conversationId];
    if (messages == null || messages.isEmpty) {
      return Future<void>.value();
    }

    final now = DateTime.now();
    final unreadMessages = messages.where((message) {
      return message.receiverId == readerId &&
          message.status != messageStatusPending &&
          message.status != messageStatusFailed &&
          message.status != messageStatusRead;
    }).toList();
    if (unreadMessages.isEmpty) {
      return Future<void>.value();
    }

    final batch = _firestore!.batch();
    for (final message in unreadMessages) {
      batch.update(_messagesCollection.doc(message.id), <String, dynamic>{
        'status': messageStatusRead,
        'readAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });
    }

    return batch.commit();
  }

  Future<void> setTyping({
    required String userId,
    required String otherUserId,
    required bool isTyping,
    Duration timeout = const Duration(seconds: 2),
  }) async {
    if (!_isConfigured) {
      return;
    }
    final conversationId = conversationIdFor(userId, otherUserId);
    final key = _typingKey(conversationId: conversationId, userId: userId);

    _typingTimers.remove(key)?.cancel();
    final now = DateTime.now();
    final document = _typingCollection.doc(key);
    await document.set(<String, dynamic>{
      'conversationId': conversationId,
      'userId': userId,
      'isTyping': isTyping,
      'updatedAt': Timestamp.fromDate(now),
    });

    if (isTyping) {
      _typingTimers[key] = Timer(timeout, () {
        unawaited(
          document.set(<String, dynamic>{
            'conversationId': conversationId,
            'userId': userId,
            'isTyping': false,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          }),
        );
        _typingTimers.remove(key);
      });
    }
  }

  List<Message> currentMessages({
    required String firstUserId,
    required String secondUserId,
  }) {
    return _messagesFor(conversationIdFor(firstUserId, secondUserId));
  }

  void clearConversation({
    required String firstUserId,
    required String secondUserId,
  }) {
    final conversationId = conversationIdFor(firstUserId, secondUserId);
    _messagesByConversation.remove(conversationId);
    _emitMessages(conversationId);
  }

  void dispose() {
    for (final timer in _typingTimers.values) {
      timer.cancel();
    }
    for (final subscription in _messageSubscriptions.values) {
      unawaited(subscription.cancel());
    }
    for (final subscription in _typingSubscriptions.values) {
      unawaited(subscription.cancel());
    }
    for (final controller in _messageControllers.values) {
      unawaited(controller.close());
    }
    for (final controller in _typingControllers.values) {
      unawaited(controller.close());
    }

    _typingTimers.clear();
    _messageSubscriptions.clear();
    _typingSubscriptions.clear();
    _messageControllers.clear();
    _typingControllers.clear();
    _messagesByConversation.clear();
  }

  StreamController<List<Message>> _messageControllerFor(String conversationId) {
    return _messageControllers.putIfAbsent(
      conversationId,
      () => StreamController<List<Message>>.broadcast(),
    );
  }

  StreamController<TypingState> _typingControllerFor({
    required String conversationId,
    required String userId,
  }) {
    final key = _typingKey(conversationId: conversationId, userId: userId);
    return _typingControllers.putIfAbsent(
      key,
      () => StreamController<TypingState>.broadcast(),
    );
  }

  List<Message> _messagesFor(String conversationId) {
    final messages =
        _messagesByConversation[conversationId] ?? const <Message>[];
    return List<Message>.unmodifiable(messages);
  }

  void _emitMessages(String conversationId) {
    final controller = _messageControllerFor(conversationId);
    if (!controller.isClosed) {
      controller.add(_messagesFor(conversationId));
    }
  }

  void _attachMessageListener({
    required String conversationId,
    required String currentUserId,
  }) {
    if (_messageSubscriptions.containsKey(conversationId)) {
      return;
    }

    _messageSubscriptions[conversationId] = _messagesCollection
        .where('chatId', isEqualTo: conversationId)
        .snapshots()
        .listen((snapshot) {
          final remoteMessages = snapshot.docs
              .map((document) => Message.fromJson(document.data()))
              .toList(growable: false);
          final messages = _mergeMessages(
            localMessages: _messagesByConversation[conversationId],
            remoteMessages: remoteMessages,
          );
          _messagesByConversation[conversationId] = messages;
          _emitMessages(conversationId);
          unawaited(
            _markMessagesDelivered(
              currentUserId: currentUserId,
              messages: messages,
            ),
          );
        });
  }

  void _attachTypingListener({
    required String conversationId,
    required String userId,
  }) {
    final key = _typingKey(conversationId: conversationId, userId: userId);
    if (_typingSubscriptions.containsKey(key)) {
      return;
    }

    _typingSubscriptions[key] = _typingCollection.doc(key).snapshots().listen((
      snapshot,
    ) {
      final data = snapshot.data();
      if (data == null) {
        _emitTyping(
          conversationId: conversationId,
          userId: userId,
          isTyping: false,
        );
        return;
      }

      final updatedAt =
          Message.parseDateTime(data['updatedAt']) ?? DateTime.now();
      final isTyping =
          data['isTyping'] == true &&
          DateTime.now().difference(updatedAt) < const Duration(seconds: 5);

      final controller = _typingControllerFor(
        conversationId: conversationId,
        userId: userId,
      );
      if (!controller.isClosed) {
        controller.add(
          TypingState(
            conversationId: conversationId,
            userId: userId,
            isTyping: isTyping,
            updatedAt: updatedAt,
          ),
        );
      }
    });
  }

  Future<void> _markMessagesDelivered({
    required String currentUserId,
    required List<Message> messages,
  }) async {
    final deliverableMessages = messages.where((message) {
      return message.receiverId == currentUserId &&
          message.status != messageStatusPending &&
          message.status != messageStatusFailed &&
          message.status == messageStatusSent;
    }).toList();
    if (deliverableMessages.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final batch = _firestore!.batch();
    for (final message in deliverableMessages) {
      batch.update(_messagesCollection.doc(message.id), <String, dynamic>{
        'status': messageStatusDelivered,
        'updatedAt': Timestamp.fromDate(now),
      });
    }
    await batch.commit();
  }

  void _emitTyping({
    required String conversationId,
    required String userId,
    required bool isTyping,
  }) {
    final controller = _typingControllerFor(
      conversationId: conversationId,
      userId: userId,
    );

    if (!controller.isClosed) {
      controller.add(
        TypingState(
          conversationId: conversationId,
          userId: userId,
          isTyping: isTyping,
          updatedAt: DateTime.now(),
        ),
      );
    }
  }

  String _typingKey({required String conversationId, required String userId}) {
    return '$conversationId::$userId';
  }

  void _upsertLocalMessage({
    required String conversationId,
    required Message message,
  }) {
    final messages = List<Message>.of(
      _messagesByConversation[conversationId] ?? const <Message>[],
    );
    final index = messages.indexWhere((current) => current.id == message.id);
    if (index >= 0) {
      messages[index] = message;
    } else {
      messages.add(message);
    }
    _messagesByConversation[conversationId] = _sortMessages(messages);
  }

  void _updateLocalMessage({
    required String conversationId,
    required String messageId,
    required Message Function(Message current) transform,
  }) {
    final messages = _messagesByConversation[conversationId];
    if (messages == null) {
      return;
    }
    final index = messages.indexWhere((current) => current.id == messageId);
    if (index < 0) {
      return;
    }
    final updatedMessages = List<Message>.of(messages);
    updatedMessages[index] = transform(updatedMessages[index]);
    _messagesByConversation[conversationId] = _sortMessages(updatedMessages);
  }

  List<Message> _mergeMessages({
    required List<Message>? localMessages,
    required List<Message> remoteMessages,
  }) {
    final mergedById = <String, Message>{
      for (final message in remoteMessages) message.id: message,
    };

    if (localMessages != null) {
      for (final message in localMessages) {
        final remoteMessage = mergedById[message.id];
        if (remoteMessage != null) {
          mergedById[message.id] = _preferRemoteMessage(
            localMessage: message,
            remoteMessage: remoteMessage,
          );
          continue;
        }

        if (message.status == messageStatusPending ||
            message.status == messageStatusFailed) {
          mergedById[message.id] = message;
        }
      }
    }

    return _sortMessages(mergedById.values);
  }

  Message _preferRemoteMessage({
    required Message localMessage,
    required Message remoteMessage,
  }) {
    if (localMessage.status == messageStatusFailed &&
        remoteMessage.status == messageStatusSent) {
      return remoteMessage.copyWith(updatedAt: remoteMessage.updatedAt);
    }

    return remoteMessage;
  }

  List<Message> _sortMessages(Iterable<Message> messages) {
    final sortedMessages = messages.toList(growable: false);
    sortedMessages.sort((first, second) {
      final createdAtComparison = first.createdAt.compareTo(second.createdAt);
      if (createdAtComparison != 0) {
        return createdAtComparison;
      }
      return first.id.compareTo(second.id);
    });
    return sortedMessages;
  }
}

final realtimeChatServiceProvider = Provider<RealtimeChatService>((ref) {
  final service = Firebase.apps.isEmpty
      ? RealtimeChatService.disabled()
      : RealtimeChatService();
  ref.onDispose(service.dispose);
  return service;
});

final chatMessagesProvider =
    StreamProvider.family<List<Message>, ChatParticipants>((ref, participants) {
      final service = ref.watch(realtimeChatServiceProvider);
      return service.watchMessages(
        currentUserId: participants.currentUserId,
        otherUserId: participants.otherUserId,
      );
    });

final typingIndicatorProvider =
    StreamProvider.family<TypingState, ChatParticipants>((ref, participants) {
      final service = ref.watch(realtimeChatServiceProvider);
      return service.watchTyping(
        currentUserId: participants.currentUserId,
        otherUserId: participants.otherUserId,
      );
    });

final unreadMessageCountProvider = StreamProvider.family<int, ChatParticipants>(
  (ref, participants) {
    final service = ref.watch(realtimeChatServiceProvider);
    return service
        .watchMessages(
          currentUserId: participants.currentUserId,
          otherUserId: participants.otherUserId,
        )
        .map(
          (messages) => messages
              .where(
                (message) =>
                    message.receiverId == participants.currentUserId &&
                    message.status != messageStatusRead,
              )
              .length,
        );
  },
);
