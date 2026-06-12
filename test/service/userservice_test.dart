import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didula_api/services/userservices.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:didula_api/models/usermodel.dart';

void main() {
  group('UserService Tests with Fake Firestore', () {
    late FakeFirebaseFirestore fakeFirestore;
    late UserService userService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();

      userService = UserService(firestore: fakeFirestore);
    });

    test('should retrieve a user by ID from Firestore', () async {
      await fakeFirestore.collection('users').doc('USER_001').set({
        'userId': 'USER_001',
        'name': 'Malith',
        'email': 'malith@gmail.com',
        'imageUrl': 'https://example.com/malith.png',
        'password': 'password123',
        'level': 1,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      final user = await userService.getUserById('USER_001');

      expect(user, isNotNull);
      expect(user!.name, 'Malith');
      expect(user.email, 'malith@gmail.com');
    });

    test('should return null if user does not exist', () async {
      final user = await userService.getUserById('NON_EXISTENT_ID');
      expect(user, isNull);
    });

    test('should retrieve all users from collection', () async {
      await fakeFirestore.collection('users').doc('U1').set({
        'name': 'Kasun',
        'email': 'kasun@test.com',
      });
      await fakeFirestore.collection('users').doc('U2').set({
        'name': 'Nimal',
        'email': 'nimal@test.com',
      });

      final usersList = await userService.getAllUsers();

      expect(usersList.length, 2);
      expect(usersList[0].name, 'Kasun');
      expect(usersList[1].name, 'Nimal');
    });

    test(
      'should save user to firestore and apply default image if image is empty',
      () async {
        final dummyUser = Usermodel(
          name: 'Amara',
          email: 'amara@gmail.com',
          password: 'password123',
          imageUrl: '',
          userId: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          level: 1,
        );

        await userService.saveUser(dummyUser, mockedUserId: 'MOCK_ID_123');

        final doc = await fakeFirestore
            .collection('users')
            .doc('MOCK_ID_123')
            .get();

        expect(doc.exists, true);
        expect(doc.data()!['name'], 'Amara');

        expect(
          doc.data()!['imageUrl'],
          "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
        );
      },
    );
  });
}
