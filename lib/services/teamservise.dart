import 'package:cloud_firestore/cloud_firestore.dart';

class Teamservise {
  final FirebaseFirestore firestore;

  Teamservise({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> createTeam({
    required String teamName,
    required List<String> memberIds,
  }) async {
    final doc = firestore.collection('teams').doc();

    await doc.set({
      'teamid': doc.id,
      'teamName': teamName,
      'members': memberIds,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTeam(String teamId) async {
    await firestore.collection('teams').doc(teamId).delete();
  }

  Stream<QuerySnapshot> getTeams() {
    return firestore
        .collection('teams')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
