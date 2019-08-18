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
        state: ReservationState.values[data[ReservationRef.jsonState] ?? 1],
        reservationTime: data[ReservationRef.jsonReservationTime],
        hanger: data[ReservationRef.jsonHanger],
        venueName: data[ReservationRef.jsonVenueName],
        wardrobeName: data[ReservationRef.jsonWardrobeName],
        section: data[ReservationRef.jsonSection],
        user: data[ReservationRef.jsonUser],
        userName: data[ReservationRef.jsonUserName],
        hangerName: data[ReservationRef.jsonHangerName],
        color: data[ReservationRef.jsonColor],
        paymentState: PaymentState.values[data[ReservationRef.jsonPaymentState] + 2]);
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
  final PaymentState paymentState;
  final DocumentReference hanger;
  final DocumentReference section;
  final DocumentReference user;

  Reservation({
    @required this.ref,
    @required this.color,
    @required this.paymentState,
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

enum ReservationState { CHECK_IN_REJECTED, CHECKED_OUT, CHECKED_IN, CHECKING_OUT, CHECKING_IN }
enum PaymentState { REFUNDED, CANCELED, INITIAL, RESERVED, CAPTURED }
