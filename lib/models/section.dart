import 'package:cloud_firestore/cloud_firestore.dart';

import '../db.dart';
import 'hanger.dart';

class SectionRef extends Document {
  static const String pathHangers = 'hangers';

  SectionRef(DocumentReference ref) : super(ref);

  CollectionReference get hangers => ref.collection(pathHangers);

  Future<DocumentSnapshot> findAvailableHanger() async {
    final documents = await hangers
        .where('state', isEqualTo: HangerState.AVAILABLE.index)
        .limit(1)
        .getDocuments();
    if (documents.documents.isEmpty)
      return null;
    else
      return documents.documents.first;
  }

  Future<List<DocumentSnapshot>> findCurrentReservations(String userId) async {
    // TODO
    return Future.value([]);
  }
}
