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

  requestCheckIn(String qrCode, String userId) async {
//    final HttpsCallable callable = cf.getHttpsCallable(
//      functionName: 'requestCheckIn',
//    );
//    try {
//      dynamic resp = await callable.call(<String, dynamic>{'code': qrCode});
//      return resp.reservation;
//    } on CloudFunctionsException catch (e) {
//      return null;
//    }

    final code = _tokenizeCode(qrCode);
    final venue = db.venue(code.venueId);
    final wardrobe = venue.wardrobe(code.wardrobeId);
    final section = wardrobe.section(code.sectionId);
    final hangersRef = section.hangers;

    final currentReservations = await section.findCurrentReservations(userId);
    if (currentReservations.isNotEmpty) return Future.value(null);

    final hangerSnapshot = await section.findAvailableHanger();
    if (hangerSnapshot == null) {
      return Future.value(null);
    }
    final hangerRef = hangerSnapshot.reference;
    hangerRef.setData({
      'state': HangerState.UNAVAILABLE.index,
      'stateUpdated': FieldValue.serverTimestamp(),
    }, merge: true);

    final userRef = db.user(userId);

    final hangerName =
        await hangerRef.get().then((item) => item.data[HangerRef.fieldId]);
    final userName =
        await userRef.ref.get().then((item) => item.data[UserRef.fieldName]);

    final venueData = await venue.ref.get();
    final wardrobeData = await wardrobe.ref.get();

    final reservationData = {
      ReservationRef.jsonSection: hangersRef.parent(),
      ReservationRef.jsonHanger: hangerRef,
      ReservationRef.jsonHangerName: hangerName,
      ReservationRef.jsonUser: userRef.ref,
      ReservationRef.jsonVenueName: venueData.data[VenueRef.fieldName],
      ReservationRef.jsonWardrobeName: wardrobeData.data[WardrobeRef.fieldName],
      ReservationRef.jsonUserName: userName,
      ReservationRef.jsonState: ReservationState.CHECKING_IN.index,
      ReservationRef.jsonReservationTime: FieldValue.serverTimestamp(),
    };

    return db.reservations.add(reservationData);
  }

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
