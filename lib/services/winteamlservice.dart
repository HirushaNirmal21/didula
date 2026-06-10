import 'package:cloud_firestore/cloud_firestore.dart';

class WinTeamservise {
  final FirebaseFirestore _firestore;

  WinTeamservise({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> createWinTeam({
    required String winteamName,
    required List<String> membersId,
  }) async {
    final doc = _firestore.collection('winteam').doc();

    await doc.set({
      'winteamid': doc.id,
      'winteamName': winteamName,
      'memberId': membersId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteWinTeam(String winteamId) async {
    await _firestore.collection('winteam').doc(winteamId).delete();
  }

  Stream<QuerySnapshot> getWinTeam() {
    return _firestore
        .collection('winteam')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
