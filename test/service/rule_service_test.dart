import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:didula_api/services/ruleservice.dart';
import 'package:didula_api/models/rulesmodel.dart';

void main() {
  group('Ruleservice Tests with Fake Firestore', () {
    late FakeFirebaseFirestore fakeFirestore;
    late Ruleservice ruleservice;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      ruleservice = Ruleservice(firestore: fakeFirestore);
    });

    test(
      'should create a rule and update it with the generated doc ID',
      () async {
        final newRule = Rulesmodel(
          ruleId: '',
          description: 'Wear clean sports uniforms',
          userId: 'ADMIN_001',
        );

        await ruleservice.createRule(newRule);

        final snapshot = await fakeFirestore.collection('rules').get();
        expect(snapshot.docs.length, 1);

        final docData = snapshot.docs.first.data();
        final generatedId = snapshot.docs.first.id;

        expect(docData['description'], 'Wear clean sports uniforms');

        expect(docData['ruleId'], generatedId);
      },
    );

    test('should delete a rule successfully', () async {
      await fakeFirestore.collection('rules').doc('RULE_TO_DELETE').set({
        'ruleId': 'RULE_TO_DELETE',
        'description': 'Temporary Rule',
        'userId': 'ADMIN_001',
      });

      await ruleservice.deleteRule(ruleId: 'RULE_TO_DELETE');

      final doc = await fakeFirestore
          .collection('rules')
          .doc('RULE_TO_DELETE')
          .get();
      expect(doc.exists, false);
    });

    test('should fetch all rules as a List successfully', () async {
      await fakeFirestore.collection('rules').doc('R1').set({
        'description': 'Rule 1',
        'userId': 'A1',
      });
      await fakeFirestore.collection('rules').doc('R2').set({
        'description': 'Rule 2',
        'userId': 'A2',
      });

      final rulesList = await ruleservice.getRules();

      expect(rulesList.length, 2);
      expect(rulesList[0].ruleId, 'R1');
      expect(rulesList[0].description, 'Rule 1');
      expect(rulesList[1].ruleId, 'R2');
    });

    test('should stream all rules correctly when data changes', () async {
      await fakeFirestore.collection('rules').doc('RS1').set({
        'description': 'Stream Rule',
        'userId': 'A1',
      });

      final streamList = await ruleservice.rules.first;

      expect(streamList.length, 1);
      expect(streamList.first.ruleId, 'RS1');
      expect(streamList.first.description, 'Stream Rule');
    });
  });
}
