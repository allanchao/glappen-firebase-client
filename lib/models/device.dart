import 'package:cloud_firestore/cloud_firestore.dart';

import '../db.dart';

class DeviceRef extends Document {
  DeviceRef(DocumentReference ref) : super(ref);
}
