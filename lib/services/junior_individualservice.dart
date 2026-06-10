import 'package:cloud_firestore/cloud_firestore.dart';

class JuniorIndividualService {
  final FirebaseFirestore firestore;

  JuniorIndividualService({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> setJuniorFirstPlace(String userId) async {
    await firestore
        .collection('junior_individual_winners')
        .doc('firstplace')
        .set({'userId': userId});
  }

  Future<void> setJuniorSecondPlace(String userId) async {
    await firestore
        .collection('junior_individual_winners')
        .doc('secondplace')
        .set({'userId': userId});
  }

  Future<void> setJuniorThirdPlace(String userId) async {
    await firestore
        .collection('junior_individual_winners')
        .doc('thirdplace')
        .set({'userId': userId});
  }

  Future<void> removeJuniorFirstPlace() async {
    await firestore
        .collection('junior_individual_winners')
        .doc('firstplace')
        .delete();
  }

  Future<void> removeJuniorSecondPlace() async {
    await firestore
        .collection('junior_individual_winners')
        .doc('secondplace')
        .delete();
  }

  Future<void> removeJuniorThirdPlace() async {
    await firestore
        .collection('junior_individual_winners')
        .doc('thirdplace')
        .delete();
  }

  Stream<DocumentSnapshot> getJuniorFirstPlace() {
    return firestore
        .collection('junior_individual_winners')
        .doc('firstplace')
        .snapshots();
  }

  Stream<DocumentSnapshot> getJuniorSecondPlace() {
    return firestore
        .collection('junior_individual_winners')
        .doc('secondplace')
        .snapshots();
  }

  Stream<DocumentSnapshot> getJuniorThirdPlace() {
    return firestore
        .collection('junior_individual_winners')
        .doc('thirdplace')
        .snapshots();
  }
}
