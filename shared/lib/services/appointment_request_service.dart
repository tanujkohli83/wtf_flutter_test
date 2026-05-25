import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/appointment_request_model.dart';

class AppointmentRequestService {
  AppointmentRequestService.disabled()
    : _firestore = null,
      _isConfigured = false;

  AppointmentRequestService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _isConfigured = true;

  final FirebaseFirestore? _firestore;
  final bool _isConfigured;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore!.collection('appointment_requests');

  Stream<List<AppointmentRequestModel>> watchMemberRequests(String memberId) {
    if (!_isConfigured) {
      return Stream<List<AppointmentRequestModel>>.value(const []);
    }

    return _collection.where('memberId', isEqualTo: memberId).snapshots().map((
      snapshot,
    ) {
      final requests = snapshot.docs
          .map((doc) => AppointmentRequestModel.fromJson(doc.data()))
          .toList();
      requests.sort((first, second) {
        return first.scheduledAt.compareTo(second.scheduledAt);
      });
      return requests;
    });
  }

  Stream<List<AppointmentRequestModel>> watchTrainerRequests(String trainerId) {
    if (!_isConfigured) {
      return Stream<List<AppointmentRequestModel>>.value(const []);
    }

    return _collection.where('trainerId', isEqualTo: trainerId).snapshots().map(
      (snapshot) {
        final requests = snapshot.docs
            .map((doc) => AppointmentRequestModel.fromJson(doc.data()))
            .toList();
        requests.sort((first, second) {
          return first.scheduledAt.compareTo(second.scheduledAt);
        });
        return requests;
      },
    );
  }

  Future<void> createRequest(AppointmentRequestModel request) async {
    _assertConfigured();
    await _collection.doc(request.id).set(request.toJson());
  }

  Future<void> setStatus({
    required String requestId,
    required AppointmentRequestStatus status,
  }) async {
    _assertConfigured();
    await _collection.doc(requestId).update(<String, dynamic>{
      'status': status.name,
      'respondedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  void _assertConfigured() {
    if (!_isConfigured) {
      throw StateError('Firebase is not configured.');
    }
  }
}

final appointmentRequestServiceProvider = Provider<AppointmentRequestService>((
  ref,
) {
  return Firebase.apps.isEmpty
      ? AppointmentRequestService.disabled()
      : AppointmentRequestService();
});

final memberAppointmentRequestsProvider =
    StreamProvider.family<List<AppointmentRequestModel>, String>((
      ref,
      memberId,
    ) {
      final service = ref.watch(appointmentRequestServiceProvider);
      return service.watchMemberRequests(memberId);
    });

final trainerAppointmentRequestsProvider =
    StreamProvider.family<List<AppointmentRequestModel>, String>((
      ref,
      trainerId,
    ) {
      final service = ref.watch(appointmentRequestServiceProvider);
      return service.watchTrainerRequests(trainerId);
    });
