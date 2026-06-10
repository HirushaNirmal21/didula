import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didula_api/services/userservices.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
// ⚠️ ඔයාගේ import paths නිවැරදි කරගන්න
import 'package:didula_api/models/usermodel.dart';

void main() {
  group('UserService Tests with Fake Firestore', () {
    late FakeFirebaseFirestore fakeFirestore;
    late UserService userService;

    // හැම ටෙස්ට් එකක්ම රන් වෙන්න කලින් අලුත්ම Fake Firestore එකක් සාදා ගනී
    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      // ⚡ මෙන්න මෙතනදී අපේ සර්විස් එකට බොරු ඩේටාබේස් එක පාස් කරනවා!
      userService = UserService(firestore: fakeFirestore);
    });

    // 1 වන ටෙස්ට් එක: getUserById එකෙන් හරියටම ඩේටා එනවද බැලීම
    test('should retrieve a user by ID from Firestore', () async {
      // මුලින්ම Fake ඩේටාබේස් එක ඇතුලට යූසර් කෙනෙක්ව අතින් දානවා
      await fakeFirestore.collection('users').doc('USER_001').set({
        'userId': 'USER_001',
        'name': 'Malith',
        'email': 'malith@gmail.com',
        'imageUrl': 'https://example.com/malith.png',
        'password': 'password123', // Usermodel එකට අවශ්‍ය නම් මේවාත් දාන්න
        'level': 1,
        'createdAt': Timestamp.now(), // 👈 මෙන්න මේක අනිවාර්යයෙන්ම ඕනේ!
        'updatedAt': Timestamp.now(),
      });

      // දැන් අපේ සර්විස් එකේ function එක රන් කරලා බලනවා
      final user = await userService.getUserById('USER_001');

      expect(user, isNotNull);
      expect(user!.name, 'Malith');
      expect(user.email, 'malith@gmail.com');
    });

    // 2 වන ටෙස්ට් එක: නැති ID එකක් සර්ච් කරොත් null එනවද බැලීම
    test('should return null if user does not exist', () async {
      final user = await userService.getUserById('NON_EXISTENT_ID');
      expect(user, isNull);
    });

    // 3 වන ටෙස්ට් එක: getAllUsers එකෙන් ඔක්කොම ලිස්ට් එක එනවද බැලීම
    test('should retrieve all users from collection', () async {
      // Fake ඩේටාබේස් එකට යූසර්ලා දෙන්නෙක් දානවා
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

    // 4 වන ටෙස්ට් එක: saveUser එකෙන් Firestore එකට ඩේටා සේව් වෙනවාද බැලීම
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
          level: 1, // හිස්ව දෙනවා default image එක වැටෙනවද බලන්න
        );

        // අපි හදපු mockedUserId එකක් පාස් කරනවා Auth Register එක bypass කරන්න
        await userService.saveUser(dummyUser, mockedUserId: 'MOCK_ID_123');

        // දැන් Fake Firestore එකේ ඇත්තටම සේව් වෙලාද කියලා check කරනවා
        final doc = await fakeFirestore
            .collection('users')
            .doc('MOCK_ID_123')
            .get();

        expect(doc.exists, true);
        expect(doc.data()!['name'], 'Amara');
        // Default Profile Image URL එක වැටිලාද කියා බැලීම
        expect(
          doc.data()!['imageUrl'],
          "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
        );
      },
    );
  });
}
