import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:garderobel_api/models/reservation.dart';

import 'models/device.dart';
import 'models/user.dart';
import 'models/venue.dart';

class Db {
  Db(this.db);

  static const pathVenues = 'venues';
  static const pathUsers = 'users';
  static const pathDevices = 'devices';
  static const pathReservations = 'reservations';

  final Firestore db;

  CollectionReference get venues => db.collection(pathVenues);

  CollectionReference get reservations => db.collection(pathReservations);

  CollectionReference get users => db.collection(pathUsers);

  CollectionReference get devices => db.collection(pathDevices);

  DeviceRef device(String id) => DeviceRef(devices.document(id));

  VenueRef venue(String id) => VenueRef(venues.document(id));

  UserRef user(String userId) => UserRef(users.document(userId));

  ReservationRef reservation(String id) => ReservationRef(reservations.document(id));
}

class Collection {
  const Collection(this.ref);

  final CollectionReference ref;
}

class Document {
  const Document(this.ref);

  final DocumentReference ref;
}
