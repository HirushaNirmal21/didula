import 'package:cloud_firestore/cloud_firestore.dart';

class SponsorService {
  final FirebaseFirestore firestore;

  SponsorService({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  // make sponsor
  Future<void> makeSponsor(String uid) async {
    await firestore.collection('users').doc(uid).update({'isSponsor': true});
  }

  // remove sponsor
  Future<void> removeSponsor(String uid) async {
    await firestore.collection('users').doc(uid).update({'isSponsor': false});
  }

  // sponsor stream
  Stream<QuerySnapshot> getSponsors() {
    return firestore
        .collection('users')
        .where('isSponsor', isEqualTo: true)
        .snapshots();
  }

  // search users
  Stream<QuerySnapshot> searchUsers(String text) {
    return firestore
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: text)
        .where('name', isLessThanOrEqualTo: '$text\uf8ff')
        .snapshots();
  }
}
