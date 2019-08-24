import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:garderobel_api/models/reservation.dart';

import '../db.dart';

class UserRef extends Document {
  UserRef(DocumentReference ref) : super(ref);
  static const fieldName = 'name';

  Query reservations({@required bool onlyActive}) {
    final query = ref.firestore
        .collection(Db.pathReservations)
        .where(ReservationRef.jsonUser, isEqualTo: ref);

    return onlyActive
        ? query
            .where(ReservationRef.jsonVisibleInApp, isEqualTo: true)
            .orderBy(ReservationRef.jsonReservationTime, descending: true)
        : query.orderBy(ReservationRef.jsonCheckOut, descending: true);
  }
}
