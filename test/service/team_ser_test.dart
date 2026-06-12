import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:didula_api/services/teamservise.dart';

void main() {
  group('Teamservise Tests with Fake Firestore', () {
    late FakeFirebaseFirestore fakeFirestore;
    late Teamservise teamService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      teamService = Teamservise(firestore: fakeFirestore);
    });

    test('should create a team with members list successfully', () async {
      await teamService.createTeam(
        teamName: 'Alliance FC',
        memberIds: ['USER_X', 'USER_Y', 'USER_Z'],
      );

      final snapshot = await fakeFirestore.collection('teams').get();
      expect(snapshot.docs.length, 1);

      final docData = snapshot.docs.first.data();
      expect(docData['teamName'], 'Alliance FC');
      expect(docData['teamid'], snapshot.docs.first.id);

      expect(docData['members'], isA<List>());
      expect(docData['members'], ['USER_X', 'USER_Y', 'USER_Z']);
      expect(docData['createdAt'], isNotNull);
    });

    test('should delete a team successfully', () async {
      await fakeFirestore.collection('teams').doc('TEAM_111').set({
        'teamid': 'TEAM_111',
        'teamName': 'Temporary Team',
      });

      await teamService.deleteTeam('TEAM_111');

      final doc = await fakeFirestore.collection('teams').doc('TEAM_111').get();
      expect(doc.exists, false);
    });

    test('should stream teams ordered by createdAt descending', () async {
      await fakeFirestore.collection('teams').doc('T1').set({
        'teamName': 'Old Team',
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      });

      await fakeFirestore.collection('teams').doc('T2').set({
        'teamName': 'New Team',
        'createdAt': Timestamp.fromDate(DateTime(2026, 6, 1)),
      });

      final snapshot = await teamService.getTeams().first;

      expect(snapshot.docs.length, 2);

      expect(snapshot.docs.first.get('teamName'), 'New Team');
      expect(snapshot.docs.last.get('teamName'), 'Old Team');
    });
  });
}
