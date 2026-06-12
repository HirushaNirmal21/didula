import 'package:didula_api/services/auth_services.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthService Tests with Mock FirebaseAuth', () {
    late MockFirebaseAuth mockAuth;
    late AuthService authService;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      authService = AuthService(auth: mockAuth);
    });

    test('should register a new user successfully', () async {
      final credential = await authService.registerUser(
        email: 'testuser@gmail.com',
        password: 'password123',
      );

      expect(credential, isNotNull);
      expect(credential.user, isNotNull);
      expect(credential.user!.email, 'testuser@gmail.com');
    });

    test('should sign in an existing user successfully', () async {
      await mockAuth.createUserWithEmailAndPassword(
        email: 'loginuser@gmail.com',
        password: 'password123',
      );

      await authService.signInUser(
        email: 'loginuser@gmail.com',
        password: 'password123',
      );

      final currentUser = authService.getCurrentUser();
      expect(currentUser, isNotNull);
      expect(currentUser!.email, 'loginuser@gmail.com');
    });

    test('should sign out the current user successfully', () async {
      await mockAuth.createUserWithEmailAndPassword(
        email: 'logoutuser@gmail.com',
        password: 'password123',
      );

      expect(authService.getCurrentUser(), isNotNull);

      await authService.signOut();

      expect(authService.getCurrentUser(), isNull);
    });
  });
}
