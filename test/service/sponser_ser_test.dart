import 'package:didula_api/services/sponser_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SponsorService Tests with Fake Firestore', () {
    late FakeFirebaseFirestore fakeFirestore;
    late SponsorService sponsorService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      sponsorService = SponsorService(firestore: fakeFirestore);
    });

    test('should make a user a sponsor successfully', () async {
      await fakeFirestore.collection('users').doc('USER_S1').set({
        'name': 'Kamal',
        'isSponsor': false,
      });

      await sponsorService.makeSponsor('USER_S1');

      final doc = await fakeFirestore.collection('users').doc('USER_S1').get();
      expect(doc.data()?['isSponsor'], true);
    });

    test('should remove sponsor status from a user successfully', () async {
      await fakeFirestore.collection('users').doc('USER_S2').set({
        'name': 'Sunil',
        'isSponsor': true,
      });

      await sponsorService.removeSponsor('USER_S2');

      final doc = await fakeFirestore.collection('users').doc('USER_S2').get();
      expect(doc.data()?['isSponsor'], false);
    });

    test('should stream only users who are sponsors', () async {
      await fakeFirestore.collection('users').doc('U1').set({
        'name': 'Sponsor 1',
        'isSponsor': true,
      });
      await fakeFirestore.collection('users').doc('U2').set({
        'name': 'Normal User',
        'isSponsor': false,
      });

      final snapshot = await sponsorService.getSponsors().first;

      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.get('name'), 'Sponsor 1');
    });

    test(
      'should search and return users whose names start with the given text',
      () async {
        await fakeFirestore.collection('users').doc('US1').set({
          'name': 'Amal Perera',
        });
        await fakeFirestore.collection('users').doc('US2').set({
          'name': 'Anura Kumara',
        });
        await fakeFirestore.collection('users').doc('US3').set({
          'name': 'Bimal Alwis',
        });

        final snapshot = await sponsorService.searchUsers('Am').first;

        expect(snapshot.docs.length, 1);
        expect(snapshot.docs.first.get('name'), 'Amal Perera');
      },
    );
  });
}
