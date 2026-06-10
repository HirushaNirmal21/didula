import 'package:cloud_firestore/cloud_firestore.dart';

class SeniorIndividualService {
  final FirebaseFirestore firestore;

  SeniorIndividualService({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> setFirstPlace(String userId) async {
    await firestore.collection('senior_individual_winners').doc('first').set({
      'userId': userId,
    });
  }

  Future<void> setSecondPlace(String userId) async {
    await firestore.collection('senior_individual_winners').doc('second').set({
      'userId': userId,
    });
  }

  Future<void> setThirdPlace(String userId) async {
    await firestore.collection('senior_individual_winners').doc('third').set({
      'userId': userId,
    });
  }

  Future<void> removeFirstPlace() async {
    await firestore
        .collection('senior_individual_winners')
        .doc('first')
        .delete();
  }

  Future<void> removeSecondPlace() async {
    await firestore
        .collection('senior_individual_winners')
        .doc('second')
        .delete();
  }

  Future<void> removeThirdPlace() async {
    await firestore
        .collection('senior_individual_winners')
        .doc('third')
        .delete();
  }

  Stream<DocumentSnapshot> getFirstPlace() {
    return firestore
        .collection('senior_individual_winners')
        .doc('first')
        .snapshots();
  }

  Stream<DocumentSnapshot> getSecondPlace() {
    return firestore
        .collection('senior_individual_winners')
        .doc('second')
        .snapshots();
  }

  Stream<DocumentSnapshot> getThirdPlace() {
    return firestore
        .collection('senior_individual_winners')
        .doc('third')
        .snapshots();
  }
}
