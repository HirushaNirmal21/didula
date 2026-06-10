import 'package:didula_api/services/imaginplayer.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
// ⚠️ ඔයාගේ project එකේ හැටියට මේ import path එක නිවැරදි කරගන්න

void main() {
  group('SpecialPlayerService Tests with Fake Firestore', () {
    late FakeFirebaseFirestore fakeFirestore;
    late SpecialPlayerService specialPlayerService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      specialPlayerService = SpecialPlayerService(firestore: fakeFirestore);
    });

    // 1 වන ටෙස්ට් එක: Senior සහ Junior ක්‍රීඩකයින්ව සාර්ථකව සෙට් කිරීම ටෙස්ට් කිරීම
    test('should set senior and junior players successfully', () async {
      await specialPlayerService.setSeniorPlayer('USER_SENIOR_123');
      await specialPlayerService.setJuniorPlayer('USER_JUNIOR_456');

      // Fake Firestore එක ඇතුලෙන් ඩේටා ඇත්තටම වැටිලද බලනවා
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

    // 2 වන ටෙස්ට් එක: ක්‍රීඩකයින්ව අයින් කිරීම (Delete) ටෙස්ට් කිරීම
    test('should remove senior and junior players successfully', () async {
      // මුලින්ම Fake Firestore එක ඇතුළට ඩේටා දාගෙන ඉන්නවා
      await fakeFirestore.collection('special_players').doc('senior').set({
        'userId': 'OLD_SENIOR',
      });
      await fakeFirestore.collection('special_players').doc('junior').set({
        'userId': 'OLD_JUNIOR',
      });

      // අයින් කරන functions රන් කරනවා
      await specialPlayerService.removeSeniorPlayer();
      await specialPlayerService.removeJuniorPlayer();

      // දැන් ඩොකියුමන්ට්ස් මැකිලද බලනවා
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

    // 3 වන ටෙස්ට් එක: Document Snapshot Streams (getSeniorPlayer / getJuniorPlayer) වැඩදැයි බැලීම
    test('should stream special player document snapshots correctly', () async {
      // මුලින්ම ඩේටා එකක් දානවා
      await fakeFirestore.collection('special_players').doc('senior').set({
        'userId': 'STREAM_USER',
      });

      // Stream එක ලබාගෙන එහි පළමු snapshot එක කියවනවා
      final seniorSnapshot = await specialPlayerService.getSeniorPlayer().first;

      expect(seniorSnapshot.exists, true);
      expect(seniorSnapshot.get('userId'), 'STREAM_USER');
    });
  });
}
