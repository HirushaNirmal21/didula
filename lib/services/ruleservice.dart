// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didula_api/models/rulesmodel.dart';

class Ruleservice {
  final FirebaseFirestore _firestore;

  Ruleservice({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _rulesCollection => _firestore.collection("rules");

  Future<void> createRule(Rulesmodel rule) async {
    try {
      final Map<String, dynamic> data = rule.toJson();
      final docRef = await _rulesCollection.add(data);
      await docRef.update({'ruleId': docRef.id});
    } catch (error) {
      print('Error creating rule: $error');
    }
  }

  // get all rules as a stream List of Rulesmodel
  Stream<List<Rulesmodel>> get rules {
    try {
      return _rulesCollection.snapshots().map((snapshot) {
        return snapshot.docs
            .map(
              (doc) => Rulesmodel.fromJson(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ),
            )
            .toList();
      });
    } catch (error) {
      print(error);
      return Stream.empty();
    }
  }

  // delete a rule
  Future<void> deleteRule({required String ruleId}) async {
    try {
      await _rulesCollection.doc(ruleId).delete();
      print('Rule deleted successfully $ruleId');
    } catch (error) {
      print(error);
    }
  }

  // get rules as list
  Future<List<Rulesmodel>> getRules() async {
    try {
      final QuerySnapshot snapshot = await _rulesCollection.get();
      return snapshot.docs.map((doc) {
        return Rulesmodel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (error) {
      print('Error fetching rule: $error');
      return [];
    }
  }
}
