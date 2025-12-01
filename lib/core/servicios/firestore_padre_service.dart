import 'package:cloud_firestore/cloud_firestore.dart';

class FirestorePadreService {
  final _db = FirebaseFirestore.instance;

  Future<void> guardarPadre(String uid, Map<String, dynamic> data) async {
    await _db.collection("padres").doc(uid).set(data, SetOptions(merge: true));
  }
}
