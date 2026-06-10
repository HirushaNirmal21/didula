import 'package:didula_api/services/winner_dual_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SeniorDualWinnerService Tests with Fake Firestore', () {
    late FakeFirebaseFirestore fakeFirestore;
    late SeniorDualWinnerService seniorDualWinnerService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      seniorDualWinnerService = SeniorDualWinnerService(
        firestore: fakeFirestore,
      );
    });

    // 1 වන ටෙස්ට් එක: 1st, 2nd, 3rd ස්ථාන වලට dualId එක සාර්ථකව සෙට් වෙනවාද බැලීම
    test(
      'should set senior dual 1st, 2nd, and 3rd place winners successfully',
      () async {
        await seniorDualWinnerService.setFirstPlace('DUAL_TEAM_1ST');
        await seniorDualWinnerService.setSecondPlace('DUAL_TEAM_2ND');
        await seniorDualWinnerService.setThirdPlace('DUAL_TEAM_3RD');

        final firstDoc = await fakeFirestore
            .collection('senior_dual_winners')
            .doc('first')
            .get();
        final secondDoc = await fakeFirestore
            .collection('senior_dual_winners')
            .doc('second')
            .get();
        final thirdDoc = await fakeFirestore
            .collection('senior_dual_winners')
            .doc('third')
            .get();

        expect(firstDoc.exists, true);
        expect(firstDoc.data()?['doualId'], 'DUAL_TEAM_1ST');

        expect(secondDoc.exists, true);
        expect(secondDoc.data()?['doualId'], 'DUAL_TEAM_2ND');

        expect(thirdDoc.exists, true);
        expect(thirdDoc.data()?['doualId'], 'DUAL_TEAM_3RD');
      },
    );

    // 2 වන ටෙස්ට් එක: ස්ථාන වල තියෙන ඩේටා සාර්ථකව අයින් (Delete) කරන්න පුළුවන්ද බැලීම
    test('should remove senior dual winners successfully', () async {
      final collection = fakeFirestore.collection('senior_dual_winners');
      await collection.doc('first').set({'doualId': 'OLD_1ST'});
      await collection.doc('second').set({'doualId': 'OLD_2ND'});
      await collection.doc('third').set({'doualId': 'OLD_3RD'});

      await seniorDualWinnerService.removeFirstPlace();
      await seniorDualWinnerService.removeSecondPlace();
      await seniorDualWinnerService.removeThirdPlace();

      final firstDoc = await collection.doc('first').get();
      final secondDoc = await collection.doc('second').get();
      final thirdDoc = await collection.doc('third').get();

      expect(firstDoc.exists, false);
      expect(secondDoc.exists, false);
      expect(thirdDoc.exists, false);
    });

    // 3 වන ටෙස්ට් එක: Streams (getFirstPlace) හරහා නිවැරදිව රියල්-ටයිම් ඩේටා ලැබෙනවාද බැලීම
    test(
      'should stream senior dual first place document snapshot correctly',
      () async {
        await fakeFirestore.collection('senior_dual_winners').doc('first').set({
          'doualId': 'STREAM_DUAL_1ST',
        });

        final snapshot = await seniorDualWinnerService.getFirstPlace().first;

        expect(snapshot.exists, true);
        expect(snapshot.get('doualId'), 'STREAM_DUAL_1ST');
      },
    );
  });
}
