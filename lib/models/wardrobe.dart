import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:garderobel_api/models/section.dart';

import '../db.dart';

class WardrobeRef extends Document {
  static const fieldName = 'name';

  WardrobeRef(DocumentReference ref) : super(ref);

  final pathSections = 'sections';

  CollectionReference get sections => ref.collection(pathSections);

  SectionRef section(String sectionId) => SectionRef(sections.document(sectionId));
}
