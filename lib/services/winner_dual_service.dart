import 'package:cloud_firestore/cloud_firestore.dart';

class SeniorDualWinnerService {
  final FirebaseFirestore firestore;

  SeniorDualWinnerService({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> setFirstPlace(String dualId) async {
    await firestore.collection('senior_dual_winners').doc('first').set({
      'doualId': dualId,
    });
  }

  Future<void> setSecondPlace(String dualId) async {
    await firestore.collection('senior_dual_winners').doc('second').set({
      'doualId': dualId,
    });
  }

  Future<void> setThirdPlace(String dualId) async {
    await firestore.collection('senior_dual_winners').doc('third').set({
      'doualId': dualId,
    });
  }

  Future<void> removeFirstPlace() async {
    await firestore.collection('senior_dual_winners').doc('first').delete();
  }

  Future<void> removeSecondPlace() async {
    await firestore.collection('senior_dual_winners').doc('second').delete();
  }

  Future<void> removeThirdPlace() async {
    await firestore.collection('senior_dual_winners').doc('third').delete();
  }

  Stream<DocumentSnapshot> getFirstPlace() {
    return firestore.collection('senior_dual_winners').doc('first').snapshots();
  }

  Stream<DocumentSnapshot> getSecondPlace() {
    return firestore
        .collection('senior_dual_winners')
        .doc('second')
        .snapshots();
  }

  Stream<DocumentSnapshot> getThirdPlace() {
    return firestore.collection('senior_dual_winners').doc('third').snapshots();
  }
}
