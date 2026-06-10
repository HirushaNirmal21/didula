import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didula_api/services/douleservices.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
// ⚠️ ඔයාගේ project එකේ හැටියට මේ import path එක නිවැරදි කරගන්න

void main() {
  group('DoualService Tests with Fake Firestore', () {
    late FakeFirebaseFirestore fakeFirestore;
    late DoualService doualService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      doualService = DoualService(firestore: fakeFirestore);
    });

    // 1 වන ටෙස්ට් එක: Match එකක් සාර්ථකව සෑදීම සහ FieldValue.serverTimestamp() වැඩදැයි බැලීම
    test('should create a doual match successfully', () async {
      await doualService.createDoual(
        player1Ids: 'P1',
        player2Ids: 'P2',
        player1Name: 'Hirusha',
        player2Name: 'Nirmal',
        player1Image: 'img1.png',
        player2Image: 'img2.png',
      );

      // Fake Firestore එකේ 'douals' කලෙක්ෂන් එක චෙක් කරනවා
      final snapshot = await fakeFirestore.collection('douals').get();

      expect(snapshot.docs.length, 1);
      final docData = snapshot.docs.first.data();

      expect(docData['player1Name'], 'Hirusha');
      expect(docData['player2Name'], 'Nirmal');
      expect(docData['doualId'], snapshot.docs.first.id); // ID එක සමානද බලයි
      expect(
        docData['createdAt'],
        isNotNull,
      ); // Server Timestamp එක වැටිලාද බලයි
    });

    // 2 වන ටෙස්ට් එක: Match එකක් ඩිලීට් කිරීම ටෙස්ට් කිරීම
    test('should delete a doual match successfully', () async {
      // මුලින්ම Fake Firestore එකට මැච් එකක් දාගන්නවා
      await fakeFirestore.collection('douals').doc('MATCH_999').set({
        'doualId': 'MATCH_999',
        'player1Name': 'Test1',
        'player2Name': 'Test2',
      });

      // මැච් එක ඩිලීට් කරන සර්විස් ෆන්ක්ෂන් එක රන් කරනවා
      await doualService.deleteDoual('MATCH_999');

      // දැන් ඒ ID එකෙන් ඩොකියුමන්ට් එකක් තියෙනවද බලනවා
      final doc = await fakeFirestore
          .collection('douals')
          .doc('MATCH_999')
          .get();
      expect(doc.exists, false); // ඩිලීට් වුනු නිසා false විය යුතුය
    });

    // 3 වන ටෙස්ට් එක: Stream (getDouals) එක හරහා ඩේටා පිළිවෙලට එනවාද බැලීම
    test('should stream doual matches ordered by createdAt descending', () async {
      // කාල වකවානු දෙකක මැච් දෙකක් දානවා (createdAt වෙනස් කරලා)
      await fakeFirestore.collection('douals').doc('M1').set({
        'player1Name': 'Old Match',
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });

      await fakeFirestore.collection('douals').doc('M2').set({
        'player1Name': 'New Match',
        'createdAt': Timestamp.fromDate(DateTime(2026, 6, 1)),
      });

      // Stream එක ලබාගෙන ඒකෙන් එන පළමු දත්ත ටික (First Event) කියවනවා
      final snapshot = await doualService.getDouals().first;

      expect(snapshot.docs.length, 2);
      // Descending (අලුත්ම ඒවා උඩට) දාලා තියෙන නිසා පළමු එක 'New Match' විය යුතුය
      expect(snapshot.docs.first.get('player1Name'), 'New Match');
      expect(snapshot.docs.last.get('player1Name'), 'Old Match');
    });
  });
}
