

import 'package:cloud_firestore/cloud_firestore.dart';


class FirebaseIdGenerator {
  static String generateId(String collectionName) {
    final docRef = FirebaseFirestore.instance.collection(collectionName).doc();
    return docRef.id;
  }
}