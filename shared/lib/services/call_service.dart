import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

import 'session_log_service.dart';

const String defaultJitsiServerUrl = 'https://meet.jit.si';

@immutable
class CallPrejoinState {
  const CallPrejoinState({this.audioMuted = false, this.videoMuted = false});

  final bool audioMuted;
  final bool videoMuted;

  CallPrejoinState copyWith({bool? audioMuted, bool? videoMuted}) {
    return CallPrejoinState(
      audioMuted: audioMuted ?? this.audioMuted,
      videoMuted: videoMuted ?? this.videoMuted,
    );
  }
}

class CallPrejoinController extends Notifier<CallPrejoinState> {
  CallPrejoinController(this.roomId);

  final String roomId;

  @override
  CallPrejoinState build() {
    return const CallPrejoinState();
  }

  void setAudioMuted(bool value) {
    state = state.copyWith(audioMuted: value);
  }

  void setVideoMuted(bool value) {
    state = state.copyWith(videoMuted: value);
  }
}

class CallParticipantState {
  const CallParticipantState({
    required this.userId,
    required this.displayName,
    required this.joinedAt,
    this.audioMuted = false,
    this.videoMuted = false,
    this.isTrainer = false,
  });

  final String userId;
  final String displayName;
  final DateTime joinedAt;
  final bool audioMuted;
  final bool videoMuted;
  final bool isTrainer;

  factory CallParticipantState.fromJson(Map<String, dynamic> json) {
    return CallParticipantState(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String? ?? json['userId'] as String,
      joinedAt: _parseDateTime(json['joinedAt']) ?? DateTime.now(),
      audioMuted: json['audioMuted'] as bool? ?? false,
      videoMuted: json['videoMuted'] as bool? ?? false,
      isTrainer: json['isTrainer'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'displayName': displayName,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'audioMuted': audioMuted,
      'videoMuted': videoMuted,
      'isTrainer': isTrainer,
    };
  }

  CallParticipantState copyWith({
    String? userId,
    String? displayName,
    DateTime? joinedAt,
    bool? audioMuted,
    bool? videoMuted,
    bool? isTrainer,
  }) {
    return CallParticipantState(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      joinedAt: joinedAt ?? this.joinedAt,
      audioMuted: audioMuted ?? this.audioMuted,
      videoMuted: videoMuted ?? this.videoMuted,
      isTrainer: isTrainer ?? this.isTrainer,
    );
  }
}

class CallRoomState {
  const CallRoomState({
    required this.id,
    required this.trainerId,
    required this.memberId,
    required this.createdBy,
    required this.createdAt,
    required this.participants,
    this.activeSessionLogId,
    this.activeSessionStartedAt,
  });

  final String id;
  final String trainerId;
  final String memberId;
  final String createdBy;
  final DateTime createdAt;
  final Map<String, CallParticipantState> participants;
  final String? activeSessionLogId;
  final DateTime? activeSessionStartedAt;

  int get participantCount => participants.length;

  factory CallRoomState.fromJson(Map<String, dynamic> json) {
    final rawParticipants =
        json['participants'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return CallRoomState(
      id: json['id'] as String,
      trainerId: json['trainerId'] as String,
      memberId: json['memberId'] as String,
      createdBy: json['createdBy'] as String,
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      participants: rawParticipants.map(
        (key, value) => MapEntry(
          key,
          CallParticipantState.fromJson(value as Map<String, dynamic>),
        ),
      ),
      activeSessionLogId: json['activeSessionLogId'] as String?,
      activeSessionStartedAt: _parseDateTime(json['activeSessionStartedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'trainerId': trainerId,
      'memberId': memberId,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'participants': participants.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'activeSessionLogId': activeSessionLogId,
      'activeSessionStartedAt': activeSessionStartedAt == null
          ? null
          : Timestamp.fromDate(activeSessionStartedAt!),
    };
  }

  CallRoomState copyWith({
    String? id,
    String? trainerId,
    String? memberId,
    String? createdBy,
    DateTime? createdAt,
    Map<String, CallParticipantState>? participants,
    String? activeSessionLogId,
    DateTime? activeSessionStartedAt,
    bool clearActiveSession = false,
  }) {
    return CallRoomState(
      id: id ?? this.id,
      trainerId: trainerId ?? this.trainerId,
      memberId: memberId ?? this.memberId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      participants: participants ?? this.participants,
      activeSessionLogId: clearActiveSession
          ? null
          : activeSessionLogId ?? this.activeSessionLogId,
      activeSessionStartedAt: clearActiveSession
          ? null
          : activeSessionStartedAt ?? this.activeSessionStartedAt,
    );
  }
}

class CallSessionState {
  const CallSessionState({
    required this.roomId,
    required this.trainerId,
    required this.trainerName,
    required this.memberId,
    required this.memberName,
    required this.currentUserId,
    required this.displayName,
    required this.focus,
    required this.audioMuted,
    required this.videoMuted,
    this.isJoining = false,
    this.isInMeeting = false,
    this.errorMessage,
    this.roomState,
    this.sessionLogId,
    this.sessionStartedAt,
  });

  final String roomId;
  final String trainerId;
  final String trainerName;
  final String memberId;
  final String memberName;
  final String currentUserId;
  final String displayName;
  final String focus;
  final bool audioMuted;
  final bool videoMuted;
  final bool isJoining;
  final bool isInMeeting;
  final String? errorMessage;
  final CallRoomState? roomState;
  final String? sessionLogId;
  final DateTime? sessionStartedAt;

  bool get isTrainer => currentUserId == trainerId;

  CallSessionState copyWith({
    String? roomId,
    String? trainerId,
    String? trainerName,
    String? memberId,
    String? memberName,
    String? currentUserId,
    String? displayName,
    String? focus,
    bool? audioMuted,
    bool? videoMuted,
    bool? isJoining,
    bool? isInMeeting,
    String? errorMessage,
    CallRoomState? roomState,
    String? sessionLogId,
    DateTime? sessionStartedAt,
    bool clearError = false,
    bool clearRoomState = false,
    bool clearSessionLog = false,
  }) {
    return CallSessionState(
      roomId: roomId ?? this.roomId,
      trainerId: trainerId ?? this.trainerId,
      trainerName: trainerName ?? this.trainerName,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      currentUserId: currentUserId ?? this.currentUserId,
      displayName: displayName ?? this.displayName,
      focus: focus ?? this.focus,
      audioMuted: audioMuted ?? this.audioMuted,
      videoMuted: videoMuted ?? this.videoMuted,
      isJoining: isJoining ?? this.isJoining,
      isInMeeting: isInMeeting ?? this.isInMeeting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      roomState: clearRoomState ? null : roomState ?? this.roomState,
      sessionLogId: clearSessionLog ? null : sessionLogId ?? this.sessionLogId,
      sessionStartedAt: clearSessionLog
          ? null
          : sessionStartedAt ?? this.sessionStartedAt,
    );
  }
}

class CallService {
  CallService.disabled()
    : _firestore = null,
      _isConfigured = false,
      _sessionLogService = SessionLogService.disabled(),
      _jitsiMeet = JitsiMeet();

  CallService({
    FirebaseFirestore? firestore,
    SessionLogService? sessionLogService,
    JitsiMeet? jitsiMeet,
  })
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _isConfigured = true,
      _sessionLogService = sessionLogService ?? SessionLogService(),
      _jitsiMeet = jitsiMeet ?? JitsiMeet();

  final FirebaseFirestore? _firestore;
  final bool _isConfigured;
  final SessionLogService _sessionLogService;
  final JitsiMeet _jitsiMeet;
  final StreamController<CallSessionState?> _sessionController =
      StreamController<CallSessionState?>.broadcast();

  CallSessionState? _activeSession;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _roomSubscription;
  bool _isLeaving = false;

  CollectionReference<Map<String, dynamic>> get _roomsCollection =>
      _firestore!.collection('call_rooms');

  static String roomIdFor({
    required String trainerId,
    required String memberId,
  }) {
    final normalizedTrainerId = _normalizeIdSegment(trainerId);
    final normalizedMemberId = _normalizeIdSegment(memberId);
    return 'room_${normalizedTrainerId}_$normalizedMemberId';
  }

  Stream<CallSessionState?> watchSession() {
    Future<void>.microtask(() {
      if (!_sessionController.isClosed) {
        _sessionController.add(_activeSession);
      }
    });
    return _sessionController.stream;
  }

  Stream<CallRoomState?> watchRoom(String roomId) {
    if (!_isConfigured) {
      return Stream<CallRoomState?>.value(null);
    }

    return _roomsCollection.doc(roomId).snapshots().map((snapshot) {
      final data = snapshot.data();
      if (data == null) {
        return null;
      }
      return CallRoomState.fromJson(data);
    });
  }

  Future<void> joinMeeting({
    required String trainerId,
    required String trainerName,
    required String memberId,
    required String memberName,
    required String currentUserId,
    required String displayName,
    String focus = 'Training session',
    bool audioMuted = false,
    bool videoMuted = false,
  }) async {
    _assertConfigured();
    final normalizedTrainerId = _normalizeIdSegment(trainerId);
    final normalizedMemberId = _normalizeIdSegment(memberId);
    final normalizedCurrentUserId = _normalizeIdSegment(currentUserId);
    final roomId = roomIdFor(
      trainerId: normalizedTrainerId,
      memberId: normalizedMemberId,
    );

    final session = CallSessionState(
      roomId: roomId,
      trainerId: normalizedTrainerId,
      trainerName: trainerName,
      memberId: normalizedMemberId,
      memberName: memberName,
      currentUserId: normalizedCurrentUserId,
      displayName: displayName.trim().isEmpty ? currentUserId : displayName,
      focus: focus,
      audioMuted: audioMuted,
      videoMuted: videoMuted,
      isJoining: true,
    );
    _emitSession(session);
    _bindRoom(roomId);

    await _upsertParticipantPresence(
      roomId: roomId,
      trainerId: normalizedTrainerId,
      memberId: normalizedMemberId,
      currentUserId: normalizedCurrentUserId,
      displayName: session.displayName,
      audioMuted: audioMuted,
      videoMuted: videoMuted,
    );

    final listener = JitsiMeetEventListener(
      conferenceWillJoin: (_) {
        _updateSession(
          (current) => current?.copyWith(isJoining: true, clearError: true),
        );
      },
      conferenceJoined: (_) {
        _updateSession(
          (current) => current?.copyWith(
            isJoining: false,
            isInMeeting: true,
            clearError: true,
          ),
        );
        unawaited(_startSessionLogForActiveRoom());
      },
      conferenceTerminated: (_, error) {
        unawaited(_handleMeetingClosed(error?.toString()));
      },
      readyToClose: () {
        unawaited(_handleMeetingClosed(null));
      },
      audioMutedChanged: (muted) {
        _updateSession((current) => current?.copyWith(audioMuted: muted));
        unawaited(
          _updateParticipantPresence(
            userId: normalizedCurrentUserId,
            transform: (participant) => participant.copyWith(audioMuted: muted),
          ),
        );
      },
      videoMutedChanged: (muted) {
        _updateSession((current) => current?.copyWith(videoMuted: muted));
        unawaited(
          _updateParticipantPresence(
            userId: normalizedCurrentUserId,
            transform: (participant) => participant.copyWith(videoMuted: muted),
          ),
        );
      },
    );

    final options = JitsiMeetConferenceOptions(
      serverURL: defaultJitsiServerUrl,
      room: roomId,
      configOverrides: <String, Object?>{
        'startWithAudioMuted': audioMuted,
        'startWithVideoMuted': videoMuted,
        'prejoinPageEnabled': false,
      },
      featureFlags: <String, Object?>{
        'prejoinpage.enabled': false,
        'welcomepage.enabled': false,
        'unsaferoomwarning.enabled': false,
      },
      userInfo: JitsiMeetUserInfo(displayName: session.displayName),
    );

    try {
      await _jitsiMeet.join(options, listener);
    } catch (error) {
      await _handleMeetingClosed(error.toString());
      rethrow;
    }
  }

  Future<void> setAudioMuted(bool muted) async {
    if (_activeSession == null) {
      return;
    }
    await _jitsiMeet.setAudioMuted(muted);
  }

  Future<void> setVideoMuted(bool muted) async {
    if (_activeSession == null) {
      return;
    }
    await _jitsiMeet.setVideoMuted(muted);
  }

  Future<void> leaveMeeting() async {
    if (_activeSession == null || _isLeaving) {
      return;
    }
    _isLeaving = true;
    try {
      await _jitsiMeet.hangUp();
      await _leaveRoomPresence(_activeSession!);
      _clearSession();
    } finally {
      _isLeaving = false;
    }
  }

  void dispose() {
    unawaited(_roomSubscription?.cancel());
    _roomSubscription = null;
    _activeSession = null;
    unawaited(_sessionController.close());
  }

  void _bindRoom(String roomId) {
    unawaited(_roomSubscription?.cancel());
    _roomSubscription = _roomsCollection.doc(roomId).snapshots().listen((
      snapshot,
    ) {
      final data = snapshot.data();
      final roomState = data == null ? null : CallRoomState.fromJson(data);
      _updateSession(
        (current) => current?.copyWith(
          roomState: roomState,
          clearRoomState: roomState == null,
        ),
      );
    });
  }

  Future<void> _upsertParticipantPresence({
    required String roomId,
    required String trainerId,
    required String memberId,
    required String currentUserId,
    required String displayName,
    required bool audioMuted,
    required bool videoMuted,
  }) async {
    final participant = CallParticipantState(
      userId: currentUserId,
      displayName: displayName,
      joinedAt: DateTime.now(),
      audioMuted: audioMuted,
      videoMuted: videoMuted,
      isTrainer: currentUserId == trainerId,
    );

    final document = _roomsCollection.doc(roomId);
    final snapshot = await document.get();
    final data = snapshot.data();
    if (data == null) {
      final room = CallRoomState(
        id: roomId,
        trainerId: trainerId,
        memberId: memberId,
        createdBy: currentUserId,
        createdAt: DateTime.now(),
        participants: <String, CallParticipantState>{
          currentUserId: participant,
        },
      );
      await document.set(room.toJson());
      return;
    }

    final room = CallRoomState.fromJson(data);
    final participants = Map<String, CallParticipantState>.of(room.participants)
      ..[currentUserId] = participant;
    await document.set(<String, dynamic>{
      'id': room.id,
      'trainerId': room.trainerId,
      'memberId': room.memberId,
      'createdBy': room.createdBy,
      'createdAt': Timestamp.fromDate(room.createdAt),
      'participants': participants.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    });
  }

  Future<void> _startSessionLogForActiveRoom() async {
    final session = _activeSession;
    if (session == null || session.sessionLogId != null) {
      return;
    }

    final roomState = await _ensureRoomSessionMetadata(session.roomId);
    if (roomState == null ||
        roomState.activeSessionLogId == null ||
        roomState.activeSessionStartedAt == null) {
      return;
    }

    await _sessionLogService.startSession(
      sessionId: roomState.activeSessionLogId!,
      roomId: session.roomId,
      trainerId: session.trainerId,
      trainerName: session.trainerName,
      memberId: session.memberId,
      memberName: session.memberName,
      focus: session.focus,
      startedAt: roomState.activeSessionStartedAt!,
      createdByUserId: session.currentUserId,
    );

    _updateSession(
      (current) => current?.copyWith(
        roomState: roomState,
        sessionLogId: roomState.activeSessionLogId,
        sessionStartedAt: roomState.activeSessionStartedAt,
      ),
    );
  }

  Future<CallRoomState?> _ensureRoomSessionMetadata(String roomId) async {
    final snapshot = await _roomsCollection.doc(roomId).get();
    final data = snapshot.data();
    if (data == null) {
      return null;
    }

    final room = CallRoomState.fromJson(data);
    if (room.activeSessionLogId != null && room.activeSessionStartedAt != null) {
      return room;
    }

    final startedAt = DateTime.now();
    final sessionLogId = 'session_${roomId}_${startedAt.millisecondsSinceEpoch}';
    await _roomsCollection.doc(roomId).update(<String, dynamic>{
      'activeSessionLogId': sessionLogId,
      'activeSessionStartedAt': Timestamp.fromDate(startedAt),
    });

    return room.copyWith(
      activeSessionLogId: sessionLogId,
      activeSessionStartedAt: startedAt,
    );
  }

  Future<void> _updateParticipantPresence({
    required String userId,
    required CallParticipantState Function(CallParticipantState participant)
    transform,
  }) async {
    final session = _activeSession;
    if (session == null) {
      return;
    }
    final room = session.roomState;
    if (room == null) {
      return;
    }
    final currentParticipant = room.participants[userId];
    if (currentParticipant == null) {
      return;
    }
    final participants = Map<String, CallParticipantState>.of(room.participants)
      ..[userId] = transform(currentParticipant);
    await _roomsCollection.doc(session.roomId).update(<String, dynamic>{
      'participants': participants.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    });
  }

  Future<void> _leaveRoomPresence(CallSessionState session) async {
    final document = _roomsCollection.doc(session.roomId);
    final snapshot = await document.get();
    final data = snapshot.data();
    if (data == null) {
      return;
    }

    final room = CallRoomState.fromJson(data);
    final participants = Map<String, CallParticipantState>.of(room.participants)
      ..remove(session.currentUserId);
    if (participants.isEmpty) {
      await document.delete();
      return;
    }

    await document.update(<String, dynamic>{
      'participants': participants.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    });
  }

  Future<void> _handleMeetingClosed(String? errorMessage) async {
    final session = _activeSession;
    if (session == null || _isLeaving) {
      return;
    }
    _isLeaving = true;
    try {
      await _leaveRoomPresence(session);
      if (errorMessage != null && errorMessage.isNotEmpty) {
        _emitSession(
          session.copyWith(
            isJoining: false,
            isInMeeting: false,
            errorMessage: errorMessage,
            clearRoomState: true,
          ),
        );
      } else {
        _clearSession();
      }
    } finally {
      _isLeaving = false;
    }
  }

  void _emitSession(CallSessionState? session) {
    _activeSession = session;
    if (!_sessionController.isClosed) {
      _sessionController.add(session);
    }
  }

  void _updateSession(
    CallSessionState? Function(CallSessionState? current) transform,
  ) {
    _emitSession(transform(_activeSession));
  }

  void _clearSession() {
    unawaited(_roomSubscription?.cancel());
    _roomSubscription = null;
    _emitSession(null);
  }

  void _assertConfigured() {
    if (!_isConfigured) {
      throw StateError('Firebase is not configured.');
    }
  }
}

String _normalizeIdSegment(String value) {
  final normalized = value.trim().toLowerCase().replaceAll(
    RegExp(r'[^a-z0-9]+'),
    '_',
  );
  return normalized.replaceAll(RegExp(r'^_+|_+$'), '');
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
    return DateTime.parse(value);
  }
  return null;
}

final callServiceProvider = Provider<CallService>((ref) {
  final sessionLogService = ref.watch(sessionLogServiceProvider);
  final service = Firebase.apps.isEmpty
      ? CallService.disabled()
      : CallService(sessionLogService: sessionLogService);
  ref.onDispose(service.dispose);
  return service;
});

final callRoomProvider = StreamProvider.family<CallRoomState?, String>((
  ref,
  roomId,
) {
  final service = ref.watch(callServiceProvider);
  return service.watchRoom(roomId);
});

final callSessionProvider = StreamProvider<CallSessionState?>((ref) {
  final service = ref.watch(callServiceProvider);
  return service.watchSession();
});

final callPrejoinProvider =
    NotifierProvider.family<CallPrejoinController, CallPrejoinState, String>(
      CallPrejoinController.new,
    );
