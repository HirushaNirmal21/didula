import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didula_api/models/usermodel.dart';

class UserService {
  final FirebaseFirestore _firestore;

  UserService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _usersCollection => _firestore.collection('users');

  int _calculateInitialPoints(int? level) {
    if (level == null) return 50;

    switch (level) {
      case 1:
        return 100;
      case 2:
        return 70;
      case 3:
        return 50;
      default:
        return 50;
    }
  }

  Future<void> saveUser(Usermodel user, {String? mockedUserId}) async {
    try {
      String userId = mockedUserId ?? user.userId;

      if (userId.trim().isEmpty) {
        print('Error: Cannot save user because User ID is empty!');
        return;
      }

      final userRef = _usersCollection.doc(userId);
      final userMap = user.toJson();
      userMap['userId'] = userId;

      const String defaultProfileUrl =
          "https://cdn-icons-png.flaticon.com/512/3135/3135715.png";

      if (userMap['imageUrl'] == null ||
          userMap['imageUrl'].toString().trim().isEmpty) {
        userMap['imageUrl'] = defaultProfileUrl;
      }

      // ⚡ [FIXED] ඩේටාබේස් එකට දාන්න කලින් Map එකෙන් level එක කෙළින්ම int එකක් විදිහට ගන්නවා
      // dynamic object එකක් ආරක්ෂිතව int එකකට cast කරගන්න int.tryParse පාවිච්චි කරනවා
      int? userLevel;
      if (userMap['level'] != null) {
        userLevel = int.tryParse(userMap['level'].toString());
      }

      // ලකුණු ටික නිවැරදිව ගණනය කරලා Map එකට එකතු කරනවා
      userMap['points'] = _calculateInitialPoints(userLevel);
      userMap['matchesPlayed'] = 0;
      userMap['matchesWon'] = 0;
      userMap['matchesLost'] = 0;

      // 🟢 3. දැන් Firestore එකට සිරාවටම ඩේටා ටික සේව් වෙනවා
      await userRef.set(userMap);
      print(
        'User saved successfully with ID: $userId and Initial Points: ${userMap['points']}',
      );
    } catch (error) {
      print('Error saving user to Firestore: $error');
      rethrow; // UI එකට Error එක බලාගන්න උඩට පාස් කරනවා
    }
  }

  // get user details by id
  Future<Usermodel?> getUserById(String userId) async {
    try {
      final DocumentSnapshot doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return Usermodel.fromJson(doc.data() as Map<String, dynamic>);
      }
    } catch (error) {
      print('Error getting user: $error');
    }
    return null;
  }

  // get all users
  Future<List<Usermodel>> getAllUsers() async {
    try {
      final snapshot = await _usersCollection.get();
      return snapshot.docs
          .map((doc) => Usermodel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (error) {
      print('Error getting users: $error');
      return [];
    }
  }
}
