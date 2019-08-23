library garderobel_api;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'db.dart';
import 'models/hanger.dart';
import 'models/reservation.dart';
import 'models/user.dart';
import 'models/venue.dart';
import 'models/wardrobe.dart';

class GarderobelClient {
  GarderobelClient(this._fireStore) : db = Db(_fireStore);

  // ignore: unused_field
  final Firestore _fireStore;
  final Db db;
  final CloudFunctions cf = CloudFunctions(region: "europe-west2");

  findReservationsForCode(String qrCode, String userId) async {
    final code = _tokenizeCode(qrCode);
    return db
        .venue(code.venueId)
        .wardrobe(code.wardrobeId)
        .section(code.sectionId)
        .findCurrentReservations(userId);
  }

  QrCode _tokenizeCode(String code) {
    return QrCode(
        "aaXt3hxtb5tf8aTz1BNp", "E8blVz5KBFZoLOTLJGf1", "vnEpTisjoygX3UJFaMy2");
  }

  Stream<Iterable<Reservation>> findReservationsForUser(String userId,
      {bool onlyActive: true}) {
    return db.user(userId).reservations(onlyActive: onlyActive).snapshots().map(
        (qs) => qs.documents.map((ds) => ReservationRef.fromFirestore(ds)));
  }

  Future requestCheckOut(DocumentReference reservation) {
//    final HttpsCallable callable = cf.getHttpsCallable(
//      functionName: 'requestCheckOut',
//    );
//    return callable.call(<String, dynamic>{'reservation': reservation.documentID});

    return reservation.updateData({
      ReservationRef.jsonState: ReservationState.CHECKING_OUT.index,
      ReservationRef.jsonStateUpdated: FieldValue.serverTimestamp()
    });
  }

  Stream<Map<String, dynamic>> getCurrentUser() {
    return Stream.fromIterable([
      {'stripeId': 'cus_FXX6ahUoQ3Eqb7'}
    ]);
  }

  Future confirmCheckIn(DocumentReference reservation) {
    final HttpsCallable callable = cf.getHttpsCallable(
      functionName: 'confirmCheckIn',
    );
    return callable
        .call(<String, dynamic>{'reservation': reservation.documentID});
  }

  Future confirmCheckOut(DocumentReference reservation) {
    final HttpsCallable callable = cf.getHttpsCallable(
      functionName: 'confirmCheckOut',
    );
    return callable
        .call(<String, dynamic>{'reservation': reservation.documentID});
  }

  Future<void> confirmCheckInLocal(Reservation reservation) async {
    return reservation.ref.updateData({
      ReservationRef.jsonCheckIn: FieldValue.serverTimestamp(),
      ReservationRef.jsonStateUpdated: FieldValue.serverTimestamp(),
      ReservationRef.jsonState: ReservationState.CHECKED_IN.index,
    });
  }

  Future<void> confirmCheckOutLocal(Reservation reservation) async {
    await reservation.ref.updateData({
      ReservationRef.jsonCheckOut: FieldValue.serverTimestamp(),
      ReservationRef.jsonStateUpdated: FieldValue.serverTimestamp(),
      ReservationRef.jsonState: ReservationState.CHECKED_OUT.index,
    });

    return reservation.hanger.updateData({
      HangerRef.fieldStateUpdated: FieldValue.serverTimestamp(),
      HangerRef.fieldState: HangerState.AVAILABLE.index,
    }).then((value) => true, onError: (error) {
      print(error);
      return false;
    });
  }
}

class QrCode {
  QrCode(this.venueId, this.wardrobeId, this.sectionId);

  final String venueId;
  final String wardrobeId;
  final String sectionId;
}
