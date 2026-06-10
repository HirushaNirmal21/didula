import 'package:cloud_firestore/cloud_firestore.dart';

class SpecialPlayerService {
  final FirebaseFirestore firestore;

  // ⚡ Constructor එක හරහා පිටින් Firestore එකක් දෙන්න පුළුවන් කලා.
  SpecialPlayerService({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> setSeniorPlayer(String userId) async {
    await firestore.collection('special_players').doc('senior').set({
      'userId': userId,
    });
  }

  Future<void> setJuniorPlayer(String userId) async {
    await firestore.collection('special_players').doc('junior').set({
      'userId': userId,
    });
  }

  Future<void> removeSeniorPlayer() async {
    await firestore.collection('special_players').doc('senior').delete();
  }

  Future<void> removeJuniorPlayer() async {
    await firestore.collection('special_players').doc('junior').delete();
  }

  Stream<DocumentSnapshot> getSeniorPlayer() {
    return firestore.collection('special_players').doc('senior').snapshots();
  }

  Stream<DocumentSnapshot> getJuniorPlayer() {
    return firestore.collection('special_players').doc('junior').snapshots();
  }
}
