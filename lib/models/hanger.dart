import 'package:cloud_firestore/cloud_firestore.dart';

import '../db.dart';

class HangerRef extends Document {
  HangerRef(DocumentReference ref) : super(ref);

  static const fieldId = 'id';
  static const fieldState = 'state';
  static const fieldStateUpdated = 'stateUpdated';
}

enum HangerState {
  AVAILABLE,
  UNAVAILABLE,
}
