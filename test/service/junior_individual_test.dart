import 'package:didula_api/services/junior_individualservice.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
// ⚠️ ඔයාගේ project එකේ හැටියට මේ import path එක නිවැරදි කරගන්න

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

    // 1 වන ටෙස්ට් එක: ස්ථාන 3ම සාර්ථකව සෙට් වෙනවාද බැලීම
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

    // 2 වන ටෙස්ට් එක: ජයග්‍රාහකයින්ව සාර්ථකව අයින් (Delete) කරන්න පුළුවන්ද බැලීම
    test(
      'should remove 1st, 2nd, and 3rd place winners successfully',
      () async {
        // මුලින්ම Fake Firestore එකට ඩේටා දානවා
        final collection = fakeFirestore.collection(
          'junior_individual_winners',
        );
        await collection.doc('firstplace').set({'userId': 'OLD_1ST'});
        await collection.doc('secondplace').set({'userId': 'OLD_2ND'});
        await collection.doc('thirdplace').set({'userId': 'OLD_3RD'});

        // අයින් කරන functions රන් කරනවා
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

    // 3 වන ටෙස්ට් එක: Streams (getJuniorFirstPlace වගේ ඒවා) හරහා නිවැරදිව දත්ත ලැබෙනවාද බැලීම
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
