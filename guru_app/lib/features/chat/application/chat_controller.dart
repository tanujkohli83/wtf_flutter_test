import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

const String guruUserId = 'guru_member_1';
const String trainerUserId = 'trainer_aarav_1';

const List<String> guruQuickReplies = <String>[
  'On my way',
  'Need 10 min',
  'Share workout',
];

final guruChatParticipantsProvider = Provider<ChatParticipants>((ref) {
  return const ChatParticipants(
    currentUserId: guruUserId,
    otherUserId: trainerUserId,
  );
});

final guruMessagesProvider = Provider<AsyncValue<List<Message>>>((ref) {
  final participants = ref.watch(guruChatParticipantsProvider);
  return ref.watch(chatMessagesProvider(participants));
});

final guruTypingProvider = Provider<AsyncValue<TypingState>>((ref) {
  final participants = ref.watch(guruChatParticipantsProvider);
  return ref.watch(typingIndicatorProvider(participants));
});

final guruUnreadCountProvider = Provider<AsyncValue<int>>((ref) {
  final participants = ref.watch(guruChatParticipantsProvider);
  return ref.watch(unreadMessageCountProvider(participants));
});

final guruQuickRepliesProvider = Provider<List<String>>((ref) {
  return guruQuickReplies;
});
