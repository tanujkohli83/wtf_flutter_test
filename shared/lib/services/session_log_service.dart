import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/session_log_model.dart';

class SessionLogService {
  SessionLogService.disabled()
    : _firestore = null,
      _isConfigured = false;

  SessionLogService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _isConfigured = true;

  static const String boxName = 'session_logs_box';

  final FirebaseFirestore? _firestore;
  final bool _isConfigured;

  static Future<void> initializeLocalCache() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<String>(boxName);
    }
  }

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore!.collection('session_logs');

  Box<String> get _box => Hive.box<String>(boxName);

  Future<SessionLogModel> startSession({
    required String sessionId,
    required String roomId,
    required String trainerId,
    required String trainerName,
    required String memberId,
    required String memberName,
    required String focus,
    required DateTime startedAt,
    required String createdByUserId,
  }) async {
    final existing = getCachedSession(sessionId);
    if (existing != null) {
      return existing;
    }

    final session = SessionLogModel(
      id: sessionId,
      roomId: roomId,
      trainerId: trainerId,
      trainerName: trainerName,
      memberId: memberId,
      memberName: memberName,
      focus: focus,
      startedAt: startedAt,
      createdByUserId: createdByUserId,
    );

    await _saveLocal(session);
    await _saveRemote(session);
    return session;
  }

  Future<SessionLogModel?> completeSession({
    required String sessionId,
    DateTime? endedAt,
    double? memberRating,
    String? trainerNotes,
    String? memberNotes,
  }) async {
    final existing = getCachedSession(sessionId);
    if (existing == null) {
      return null;
    }

    final resolvedEndedAt = endedAt ?? DateTime.now();
    final durationSeconds = resolvedEndedAt
        .difference(existing.startedAt)
        .inSeconds;
    final updated = existing.copyWith(
      endedAt: resolvedEndedAt,
      durationSeconds: durationSeconds < 0 ? 0 : durationSeconds,
      memberRating: memberRating,
      trainerNotes: trainerNotes ?? existing.trainerNotes,
      memberNotes: memberNotes ?? existing.memberNotes,
    );

    await _saveLocal(updated);
    await _saveRemote(updated);
    return updated;
  }

  SessionLogModel? getCachedSession(String sessionId) {
    final raw = _box.get(sessionId);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return SessionLogModel.fromJson(_decodeCacheJson(raw));
  }

  List<SessionLogModel> getCachedSessionsForMember(String memberId) {
    return _sortedSessions(
      _box.values
          .map((raw) => SessionLogModel.fromJson(_decodeCacheJson(raw)))
          .where((session) => session.memberId == memberId)
          .toList(),
    );
  }

  List<SessionLogModel> getCachedSessionsForTrainer(String trainerId) {
    return _sortedSessions(
      _box.values
          .map((raw) => SessionLogModel.fromJson(_decodeCacheJson(raw)))
          .where((session) => session.trainerId == trainerId)
          .toList(),
    );
  }

  Stream<List<SessionLogModel>> watchMemberSessions(String memberId) async* {
    yield getCachedSessionsForMember(memberId);

    if (!_isConfigured) {
      return;
    }

    yield* _collection.where('memberId', isEqualTo: memberId).snapshots().asyncMap(
      (snapshot) async {
        final sessions = snapshot.docs
            .map((doc) => SessionLogModel.fromJson(doc.data()))
            .toList();
        await _cacheSessions(sessions);
        return _sortedSessions(sessions);
      },
    );
  }

  Stream<List<SessionLogModel>> watchTrainerSessions(String trainerId) async* {
    yield getCachedSessionsForTrainer(trainerId);

    if (!_isConfigured) {
      return;
    }

    yield* _collection
        .where('trainerId', isEqualTo: trainerId)
        .snapshots()
        .asyncMap((snapshot) async {
          final sessions = snapshot.docs
              .map((doc) => SessionLogModel.fromJson(doc.data()))
              .toList();
          await _cacheSessions(sessions);
          return _sortedSessions(sessions);
        });
  }

  Future<void> _cacheSessions(List<SessionLogModel> sessions) async {
    for (final session in sessions) {
      await _saveLocal(session);
    }
  }

  Future<void> _saveLocal(SessionLogModel session) {
    return _box.put(session.id, jsonEncode(_encodeCacheJson(session)));
  }

  Future<void> _saveRemote(SessionLogModel session) async {
    if (!_isConfigured) {
      return;
    }
    await _collection.doc(session.id).set(session.toJson(), SetOptions(merge: true));
  }

  List<SessionLogModel> _sortedSessions(List<SessionLogModel> sessions) {
    sessions.sort((first, second) => second.startedAt.compareTo(first.startedAt));
    return sessions;
  }

  Map<String, dynamic> _encodeCacheJson(SessionLogModel session) {
    return <String, dynamic>{
      'id': session.id,
      'roomId': session.roomId,
      'trainerId': session.trainerId,
      'trainerName': session.trainerName,
      'memberId': session.memberId,
      'memberName': session.memberName,
      'focus': session.focus,
      'startedAt': session.startedAt.toIso8601String(),
      'endedAt': session.endedAt?.toIso8601String(),
      'durationSeconds': session.durationSeconds,
      'memberRating': session.memberRating,
      'trainerNotes': session.trainerNotes,
      'memberNotes': session.memberNotes,
      'createdByUserId': session.createdByUserId,
    };
  }

  Map<String, dynamic> _decodeCacheJson(String raw) {
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }
}

final sessionLogServiceProvider = Provider<SessionLogService>((ref) {
  return Firebase.apps.isEmpty
      ? SessionLogService.disabled()
      : SessionLogService();
});

final memberSessionLogsProvider =
    StreamProvider.family<List<SessionLogModel>, String>((ref, memberId) {
      final service = ref.watch(sessionLogServiceProvider);
      return service.watchMemberSessions(memberId);
    });

final trainerSessionLogsProvider =
    StreamProvider.family<List<SessionLogModel>, String>((ref, trainerId) {
      final service = ref.watch(sessionLogServiceProvider);
      return service.watchTrainerSessions(trainerId);
    });
