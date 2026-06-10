import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didula_api/services/winteamlservice.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WinTeamservise Tests with Fake Firestore', () {
    late FakeFirebaseFirestore fakeFirestore;
    late WinTeamservise winTeamService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      winTeamService = WinTeamservise(firestore: fakeFirestore);
    });

    // 1 වන ටෙස්ට් එක: Win Team එකක් සාර්ථකව සෑදීම ටෙස්ට් කිරීම
    test('should create a win team with member IDs successfully', () async {
      await winTeamService.createWinTeam(
        winteamName: 'Invincibles XI',
        membersId: ['WIN_01', 'WIN_02'],
      );

      final snapshot = await fakeFirestore.collection('winteam').get();
      expect(snapshot.docs.length, 1);

      final docData = snapshot.docs.first.data();
      expect(docData['winteamName'], 'Invincibles XI');
      expect(docData['winteamid'], snapshot.docs.first.id);
      expect(docData['memberId'], ['WIN_01', 'WIN_02']);
      expect(docData['createdAt'], isNotNull);
    });

    // 2 වන ටෙස්ට් එක: Win Team එකක් සාර්ථකව ඩිලීට් කිරීම
    test('should delete a win team successfully', () async {
      await fakeFirestore.collection('winteam').doc('WIN_T_999').set({
        'winteamid': 'WIN_T_999',
        'winteamName': 'To Be Deleted',
      });

      await winTeamService.deleteWinTeam('WIN_T_999');

      final doc = await fakeFirestore
          .collection('winteam')
          .doc('WIN_T_999')
          .get();
      expect(doc.exists, false);
    });

    // 3 වන ටෙස්ට් එක: getWinTeam Stream එකෙන් අලුත්ම එක මුලට එන විදිහට දත්ත ලැබෙනවාද බැලීම
    test('should stream win teams ordered by createdAt descending', () async {
      await fakeFirestore.collection('winteam').doc('WT1').set({
        'winteamName': 'First Champion',
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });

      await fakeFirestore.collection('winteam').doc('WT2').set({
        'winteamName': 'Latest Champion',
        'createdAt': Timestamp.fromDate(DateTime(2026, 5, 1)),
      });

      final snapshot = await winTeamService.getWinTeam().first;

      expect(snapshot.docs.length, 2);
      // Descending නිසා අලුත්ම එක ('Latest Champion') මුලින්ම තිබිය යුතුය
      expect(snapshot.docs.first.get('winteamName'), 'Latest Champion');
    });
  });
}
