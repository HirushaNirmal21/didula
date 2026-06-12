import 'package:didula_api/services/imaginplayer.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpecialPlayerService Tests with Fake Firestore', () {
    late FakeFirebaseFirestore fakeFirestore;
    late SpecialPlayerService specialPlayerService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      specialPlayerService = SpecialPlayerService(firestore: fakeFirestore);
    });

    test('should set senior and junior players successfully', () async {
      await specialPlayerService.setSeniorPlayer('USER_SENIOR_123');
      await specialPlayerService.setJuniorPlayer('USER_JUNIOR_456');

      final seniorDoc = await fakeFirestore
          .collection('special_players')
          .doc('senior')
          .get();
      final juniorDoc = await fakeFirestore
          .collection('special_players')
          .doc('junior')
          .get();

      expect(seniorDoc.exists, true);
      expect(seniorDoc.data()?['userId'], 'USER_SENIOR_123');

      expect(juniorDoc.exists, true);
      expect(juniorDoc.data()?['userId'], 'USER_JUNIOR_456');
    });

    test('should remove senior and junior players successfully', () async {
      await fakeFirestore.collection('special_players').doc('senior').set({
        'userId': 'OLD_SENIOR',
      });
      await fakeFirestore.collection('special_players').doc('junior').set({
        'userId': 'OLD_JUNIOR',
      });

      await specialPlayerService.removeSeniorPlayer();
      await specialPlayerService.removeJuniorPlayer();

      final seniorDoc = await fakeFirestore
          .collection('special_players')
          .doc('senior')
          .get();
      final juniorDoc = await fakeFirestore
          .collection('special_players')
          .doc('junior')
          .get();

      expect(seniorDoc.exists, false);
      expect(juniorDoc.exists, false);
    });

    test('should stream special player document snapshots correctly', () async {
      await fakeFirestore.collection('special_players').doc('senior').set({
        'userId': 'STREAM_USER',
      });

      final seniorSnapshot = await specialPlayerService.getSeniorPlayer().first;

      expect(seniorSnapshot.exists, true);
      expect(seniorSnapshot.get('userId'), 'STREAM_USER');
    });
  });
}
