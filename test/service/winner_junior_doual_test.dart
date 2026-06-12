import 'package:didula_api/services/winner_junior_doual_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JuniorDualWinnerService Tests with Fake Firestore', () {
    late FakeFirebaseFirestore fakeFirestore;
    late JuniorDualWinnerService juniorDualWinnerService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      juniorDualWinnerService = JuniorDualWinnerService(
        firestore: fakeFirestore,
      );
    });

    test(
      'should set junior dual 1st, 2nd, and 3rd place winners successfully',
      () async {
        await juniorDualWinnerService.seJuniortFirstPlace('JUNIOR_DUAL_1ST');
        await juniorDualWinnerService.setJuniorSecondPlace('JUNIOR_DUAL_2ND');
        await juniorDualWinnerService.setJuniorThirdPlace('JUNIOR_DUAL_3RD');

        final firstDoc = await fakeFirestore
            .collection('junior_dual_winners')
            .doc('first')
            .get();
        final secondDoc = await fakeFirestore
            .collection('junior_dual_winners')
            .doc('second')
            .get();
        final thirdDoc = await fakeFirestore
            .collection('junior_dual_winners')
            .doc('third')
            .get();

        expect(firstDoc.exists, true);
        expect(firstDoc.data()?['doualId'], 'JUNIOR_DUAL_1ST');

        expect(secondDoc.exists, true);
        expect(secondDoc.data()?['doualId'], 'JUNIOR_DUAL_2ND');

        expect(thirdDoc.exists, true);
        expect(thirdDoc.data()?['doualId'], 'JUNIOR_DUAL_3RD');
      },
    );

    test('should remove junior dual winners successfully', () async {
      final collection = fakeFirestore.collection('junior_dual_winners');
      await collection.doc('first').set({'doualId': 'OLD_JUNIOR_1ST'});
      await collection.doc('second').set({'doualId': 'OLD_JUNIOR_2ND'});
      await collection.doc('third').set({'doualId': 'OLD_JUNIOR_3RD'});

      await juniorDualWinnerService.removeJuniorFirstPlace();
      await juniorDualWinnerService.removeJuniorSecondPlace();
      await juniorDualWinnerService.removeJuniorThirdPlace();

      final firstDoc = await collection.doc('first').get();
      final secondDoc = await collection.doc('second').get();
      final thirdDoc = await collection.doc('third').get();

      expect(firstDoc.exists, false);
      expect(secondDoc.exists, false);
      expect(thirdDoc.exists, false);
    });

    test(
      'should stream junior dual first place document snapshot correctly',
      () async {
        await fakeFirestore.collection('junior_dual_winners').doc('first').set({
          'doualId': 'STREAM_JUNIOR_1ST',
        });

        final snapshot = await juniorDualWinnerService
            .getJuniorFirstPlace()
            .first;

        expect(snapshot.exists, true);
        expect(snapshot.get('doualId'), 'STREAM_JUNIOR_1ST');
      },
    );
  });
}
