import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:garderobel_api/models/reservation.dart';
import 'package:garderobel_api/models/wardrobe.dart';

import '../db.dart';

class VenueRef extends Document {
  VenueRef(DocumentReference ref) : super(ref);

  static const pathWardrobes = 'wardrobes';
  static const pathReservations = 'reservations';
  static const fieldName = 'name';

  CollectionReference get wardrobes => ref.collection(pathWardrobes);

  WardrobeRef wardrobe(String id) => WardrobeRef(wardrobes.document(id));

  CollectionReference get reservations => ref.collection(pathReservations);

  ReservationRef reservation(String id) => ReservationRef(reservations.document(id));
}
