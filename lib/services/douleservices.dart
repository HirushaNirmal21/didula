import 'package:cloud_firestore/cloud_firestore.dart';

class DoualService {
  final FirebaseFirestore firestore;

  DoualService({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> createDoual({
    required String player1Ids,
    required String player2Ids,
    required String player1Name,
    required String player2Name,
    required String player1Image,
    required String player2Image,
  }) async {
    final doc = firestore.collection('douals').doc();

    await doc.set({
      'doualId': doc.id,
      'player1Name': player1Name,
      'player2Name': player2Name,
      'player1Image': player1Image,
      'player2Image': player2Image,
      'player1Ids': player1Ids,
      'player2Ids': player2Ids,
      'createdAt':
          FieldValue.serverTimestamp(), // fake_cloud_firestore එක මේක handle කරයි
    });
  }

  Future<void> deleteDoual(String doualId) async {
    try {
      await firestore.collection('douals').doc(doualId).delete();
    } catch (e) {
      print("Error deleting doual: $e");
    }
  }

  Stream<QuerySnapshot> getDouals() {
    return firestore
        .collection('douals')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
