import 'package:didula_api/services/auth_services.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
// ⚠️ ඔයාගේ import path එක නිවැරදි කරගන්න

void main() {
  group('AuthService Tests with Mock FirebaseAuth', () {
    late MockFirebaseAuth mockAuth;
    late AuthService authService;

    setUp(() {
      // ⚡ හැම ටෙස්ට් එකකටම කලින් බොරු Auth එකක් හදනවා
      mockAuth = MockFirebaseAuth();
      authService = AuthService(auth: mockAuth);
    });

    // 1 වන ටෙස්ට් එක: සාර්ථකව Register වීම ටෙස්ට් කිරීම
    test('should register a new user successfully', () async {
      final credential = await authService.registerUser(
        email: 'testuser@gmail.com',
        password: 'password123',
      );

      expect(credential, isNotNull);
      expect(credential.user, isNotNull);
      expect(credential.user!.email, 'testuser@gmail.com');
    });

    // 2 වන ටෙස්ට් එක: සාර්ථකව Sign In වීම ටෙස්ට් කිරීම
    test('should sign in an existing user successfully', () async {
      // මුලින්ම බොරු Auth එක ඇතුළට යූසර් කෙනෙක්ව ක්‍රියේට් කරලා ඉන්න ඕනේ
      await mockAuth.createUserWithEmailAndPassword(
        email: 'loginuser@gmail.com',
        password: 'password123',
      );

      // දැන් සර්විස් එකෙන් Sign In වෙන්න හදනවා
      await authService.signInUser(
        email: 'loginuser@gmail.com',
        password: 'password123',
      );

      // දැනට ලොග් වෙලා ඉන්න යූසර්ව අරන් බලනවා හරියටම ලොග් වුනාද කියලා
      final currentUser = authService.getCurrentUser();
      expect(currentUser, isNotNull);
      expect(currentUser!.email, 'loginuser@gmail.com');
    });

    // 3 වන ටෙස්ට් එක: Sign Out වීම ටෙස්ට් කිරීම
    test('should sign out the current user successfully', () async {
      // ලොග් කරලා ඉන්නවා
      await mockAuth.createUserWithEmailAndPassword(
        email: 'logoutuser@gmail.com',
        password: 'password123',
      );

      expect(authService.getCurrentUser(), isNotNull);

      // සර්විස් එකෙන් සයින් අවුට් කරනවා
      await authService.signOut();

      // දැන් යූසර් null වෙන්න ඕනේ
      expect(authService.getCurrentUser(), isNull);
    });
  });
}
