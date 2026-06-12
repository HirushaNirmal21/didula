import 'package:didula_api/services/seniorindividualservices.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SeniorIndividualService Tests with Fake Firestore', () {
    late FakeFirebaseFirestore fakeFirestore;
    late SeniorIndividualService seniorIndividualService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      seniorIndividualService = SeniorIndividualService(
        firestore: fakeFirestore,
      );
    });

    test(
      'should set senior 1st, 2nd, and 3rd place winners successfully',
      () async {
        await seniorIndividualService.setFirstPlace('SENIOR_1ST');
        await seniorIndividualService.setSecondPlace('SENIOR_2ND');
        await seniorIndividualService.setThirdPlace('SENIOR_3RD');

        final firstDoc = await fakeFirestore
            .collection('senior_individual_winners')
            .doc('first')
            .get();
        final secondDoc = await fakeFirestore
            .collection('senior_individual_winners')
            .doc('second')
            .get();
        final thirdDoc = await fakeFirestore
            .collection('senior_individual_winners')
            .doc('third')
            .get();

        expect(firstDoc.exists, true);
        expect(firstDoc.data()?['userId'], 'SENIOR_1ST');

        expect(secondDoc.exists, true);
        expect(secondDoc.data()?['userId'], 'SENIOR_2ND');

        expect(thirdDoc.exists, true);
        expect(thirdDoc.data()?['userId'], 'SENIOR_3RD');
      },
    );

    test(
      'should remove senior 1st, 2nd, and 3rd place winners successfully',
      () async {
        final collection = fakeFirestore.collection(
          'senior_individual_winners',
        );
        await collection.doc('first').set({'userId': 'OLD_SENIOR_1ST'});
        await collection.doc('second').set({'userId': 'OLD_SENIOR_2ND'});
        await collection.doc('third').set({'userId': 'OLD_SENIOR_3RD'});

        await seniorIndividualService.removeFirstPlace();
        await seniorIndividualService.removeSecondPlace();
        await seniorIndividualService.removeThirdPlace();

        final firstDoc = await collection.doc('first').get();
        final secondDoc = await collection.doc('second').get();
        final thirdDoc = await collection.doc('third').get();

        expect(firstDoc.exists, false);
        expect(secondDoc.exists, false);
        expect(thirdDoc.exists, false);
      },
    );

    test(
      'should stream senior first place winner document snapshot correctly',
      () async {
        await fakeFirestore
            .collection('senior_individual_winners')
            .doc('first')
            .set({'userId': 'STREAM_SENIOR_1ST'});

        final snapshot = await seniorIndividualService.getFirstPlace().first;

        expect(snapshot.exists, true);
        expect(snapshot.get('userId'), 'STREAM_SENIOR_1ST');
      },
    );
  });
}
