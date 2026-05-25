import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';

const String trainerUserId = 'trainer_aarav_1';
const String guruUserId = 'guru_member_1';

const List<String> trainerQuickReplies = <String>[
  'Nice work',
  'Add one more set',
  'Share form video',
];

final trainerChatParticipantsProvider = Provider<ChatParticipants>((ref) {
  return const ChatParticipants(
    currentUserId: trainerUserId,
    otherUserId: guruUserId,
  );
});

final trainerMessagesProvider = Provider<AsyncValue<List<Message>>>((ref) {
  final participants = ref.watch(trainerChatParticipantsProvider);
  return ref.watch(chatMessagesProvider(participants));
});

final trainerTypingProvider = Provider<AsyncValue<TypingState>>((ref) {
  final participants = ref.watch(trainerChatParticipantsProvider);
  return ref.watch(typingIndicatorProvider(participants));
});

final trainerUnreadCountProvider = Provider<AsyncValue<int>>((ref) {
  final participants = ref.watch(trainerChatParticipantsProvider);
  return ref.watch(unreadMessageCountProvider(participants));
});

final trainerQuickRepliesProvider = Provider<List<String>>((ref) {
  return trainerQuickReplies;
});
