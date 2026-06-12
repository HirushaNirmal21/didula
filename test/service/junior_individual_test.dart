import 'package:didula_api/services/junior_individualservice.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JuniorIndividualService Tests with Fake Firestore', () {
    late FakeFirebaseFirestore fakeFirestore;
    late JuniorIndividualService juniorIndividualService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      juniorIndividualService = JuniorIndividualService(
        firestore: fakeFirestore,
      );
    });

    test('should set 1st, 2nd, and 3rd place winners successfully', () async {
      await juniorIndividualService.setJuniorFirstPlace('USER_1ST');
      await juniorIndividualService.setJuniorSecondPlace('USER_2ND');
      await juniorIndividualService.setJuniorThirdPlace('USER_3RD');

      final firstDoc = await fakeFirestore
          .collection('junior_individual_winners')
          .doc('firstplace')
          .get();
      final secondDoc = await fakeFirestore
          .collection('junior_individual_winners')
          .doc('secondplace')
          .get();
      final thirdDoc = await fakeFirestore
          .collection('junior_individual_winners')
          .doc('thirdplace')
          .get();

      expect(firstDoc.exists, true);
      expect(firstDoc.data()?['userId'], 'USER_1ST');

      expect(secondDoc.exists, true);
      expect(secondDoc.data()?['userId'], 'USER_2ND');

      expect(thirdDoc.exists, true);
      expect(thirdDoc.data()?['userId'], 'USER_3RD');
    });

    test(
      'should remove 1st, 2nd, and 3rd place winners successfully',
      () async {
        final collection = fakeFirestore.collection(
          'junior_individual_winners',
        );
        await collection.doc('firstplace').set({'userId': 'OLD_1ST'});
        await collection.doc('secondplace').set({'userId': 'OLD_2ND'});
        await collection.doc('thirdplace').set({'userId': 'OLD_3RD'});

        await juniorIndividualService.removeJuniorFirstPlace();
        await juniorIndividualService.removeJuniorSecondPlace();
        await juniorIndividualService.removeJuniorThirdPlace();

        final firstDoc = await collection.doc('firstplace').get();
        final secondDoc = await collection.doc('secondplace').get();
        final thirdDoc = await collection.doc('thirdplace').get();

        expect(firstDoc.exists, false);
        expect(secondDoc.exists, false);
        expect(thirdDoc.exists, false);
      },
    );

    test(
      'should stream first place winner document snapshot correctly',
      () async {
        await fakeFirestore
            .collection('junior_individual_winners')
            .doc('firstplace')
            .set({'userId': 'STREAM_1ST'});

        final snapshot = await juniorIndividualService
            .getJuniorFirstPlace()
            .first;

        expect(snapshot.exists, true);
        expect(snapshot.get('userId'), 'STREAM_1ST');
      },
    );
  });
}
