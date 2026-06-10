import 'package:cloud_firestore/cloud_firestore.dart';

class JuniorDualWinnerService {
  final FirebaseFirestore firestore;

  JuniorDualWinnerService({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> seJuniortFirstPlace(String dualId) async {
    await firestore.collection('junior_dual_winners').doc('first').set({
      'doualId': dualId,
    });
  }

  Future<void> setJuniorSecondPlace(String dualId) async {
    await firestore.collection('junior_dual_winners').doc('second').set({
      'doualId': dualId,
    });
  }

  Future<void> setJuniorThirdPlace(String dualId) async {
    await firestore.collection('junior_dual_winners').doc('third').set({
      'doualId': dualId,
    });
  }

  Future<void> removeJuniorFirstPlace() async {
    await firestore.collection('junior_dual_winners').doc('first').delete();
  }

  Future<void> removeJuniorSecondPlace() async {
    await firestore.collection('junior_dual_winners').doc('second').delete();
  }

  Future<void> removeJuniorThirdPlace() async {
    await firestore.collection('junior_dual_winners').doc('third').delete();
  }

  Stream<DocumentSnapshot> getJuniorFirstPlace() {
    return firestore.collection('junior_dual_winners').doc('first').snapshots();
  }

  Stream<DocumentSnapshot> getJuniorSecondPlace() {
    return firestore
        .collection('junior_dual_winners')
        .doc('second')
        .snapshots();
  }

  Stream<DocumentSnapshot> getJuniorThirdPlace() {
    return firestore.collection('junior_dual_winners').doc('third').snapshots();
  }
}
