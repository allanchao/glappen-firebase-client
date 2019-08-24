import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../db.dart';

class ReservationRef extends Document {
  ReservationRef(DocumentReference ref) : super(ref);

  static const jsonReservationTime = 'reservationTime';
  static const jsonStateUpdated = 'stateUpdated';
  static const jsonCheckIn = 'checkedIn';
  static const jsonCheckOut = 'checkedOut';
  static const jsonHanger = 'hanger';
  static const jsonVenueName = 'venueName';
  static const jsonVenue = 'venue';
  static const jsonWardrobeName = 'wardrobeName';
  static const jsonHangerName = 'hangerName';
  static const jsonSection = 'section';
  static const jsonUser = 'user';
  static const jsonUserName = 'userName';
  static const jsonState = 'state';
  static const jsonVisibleInApp = 'visibleInApp';
  static const jsonColor = 'color';
  static const jsonPaymentState = 'paymentStatus';

  static Reservation fromFirestore(DocumentSnapshot ds) {
    final data = ds.data;
    return Reservation(
      ref: ds.reference,
      docId: ds.documentID,
      checkIn: data[ReservationRef.jsonCheckIn],
      checkOut: data[ReservationRef.jsonCheckOut],
      stateUpdated: data[ReservationRef.jsonStateUpdated],
      state: ReservationState.values[data[ReservationRef.jsonState]],
      reservationTime: data[ReservationRef.jsonReservationTime],
      hanger: data[ReservationRef.jsonHanger],
      venueName: data[ReservationRef.jsonVenueName],
      wardrobeName: data[ReservationRef.jsonWardrobeName],
      section: data[ReservationRef.jsonSection],
      user: data[ReservationRef.jsonUser],
      userName: data[ReservationRef.jsonUserName],
      hangerName: data[ReservationRef.jsonHangerName],
      color: data[ReservationRef.jsonColor],
    );
  }
}

class Reservation {
  final DocumentReference ref;
  final String docId;
  final String hangerName;
  final String userName;
  final String venueName;
  final String wardrobeName;
  final String color;
  final Timestamp checkIn;
  final Timestamp checkOut;
  final Timestamp reservationTime;
  final Timestamp stateUpdated;
  final ReservationState state;
  final DocumentReference hanger;
  final DocumentReference section;
  final DocumentReference user;

  Reservation({
    @required this.ref,
    @required this.color,
    @required this.docId,
    @required this.checkIn,
    @required this.checkOut,
    @required this.reservationTime,
    @required this.hanger,
    @required this.hangerName,
    @required this.section,
    @required this.userName,
    @required this.user,
    @required this.state,
    @required this.venueName,
    @required this.wardrobeName,
    @required this.stateUpdated,
  });
}

enum ReservationState {
  NONE,
  PAYMENT_METHOD_REQUIRED,
  PAYMENT_AUTH_REQUIRED,
  PAYMENT_RESERVED,
  CHECKED_IN,
  LOST,
  CHECKING_OUT,
  CHECKED_OUT
}
