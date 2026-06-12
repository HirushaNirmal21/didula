import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didula_api/services/douleservices.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DoualService Tests with Fake Firestore', () {
    late FakeFirebaseFirestore fakeFirestore;
    late DoualService doualService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      doualService = DoualService(firestore: fakeFirestore);
    });

    test('should create a doual match successfully', () async {
      await doualService.createDoual(
        player1Ids: 'P1',
        player2Ids: 'P2',
        player1Name: 'Hirusha',
        player2Name: 'Nirmal',
        player1Image: 'img1.png',
        player2Image: 'img2.png',
      );

      final snapshot = await fakeFirestore.collection('douals').get();

      expect(snapshot.docs.length, 1);
      final docData = snapshot.docs.first.data();

      expect(docData['player1Name'], 'Hirusha');
      expect(docData['player2Name'], 'Nirmal');
      expect(docData['doualId'], snapshot.docs.first.id);
      expect(docData['createdAt'], isNotNull);
    });

    test('should delete a doual match successfully', () async {
      await fakeFirestore.collection('douals').doc('MATCH_999').set({
        'doualId': 'MATCH_999',
        'player1Name': 'Test1',
        'player2Name': 'Test2',
      });

      await doualService.deleteDoual('MATCH_999');

      final doc = await fakeFirestore
          .collection('douals')
          .doc('MATCH_999')
          .get();
      expect(doc.exists, false);
    });

    test(
      'should stream doual matches ordered by createdAt descending',
      () async {
        await fakeFirestore.collection('douals').doc('M1').set({
          'player1Name': 'Old Match',
          'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
        });

        await fakeFirestore.collection('douals').doc('M2').set({
          'player1Name': 'New Match',
          'createdAt': Timestamp.fromDate(DateTime(2026, 6, 1)),
        });

        final snapshot = await doualService.getDouals().first;

        expect(snapshot.docs.length, 2);

        expect(snapshot.docs.first.get('player1Name'), 'New Match');
        expect(snapshot.docs.last.get('player1Name'), 'Old Match');
      },
    );
  });
}
