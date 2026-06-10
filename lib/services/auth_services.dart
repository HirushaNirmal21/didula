import 'package:didula_api/exceptions/exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ⚠️ ඔයාගේ mapFirebaseExceptionCodes තියෙන නිවැරදි path එක මෙතනට දාන්න
// import 'package:didula_api/utils/exception_mapper.dart';

class AuthService {
  final FirebaseAuth _auth;

  // ⚡ Constructor එකෙන් පිටින් FirebaseAuth එකක් දෙන්න පුළුවන් කලා.
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  // signOut
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (error) {
      print(
        "Error signOut :${mapFirebaseExceptionCodes(errorCode: error.code)}",
      );
    } catch (e) {
      print("Error sign Out : $e");
    }
  }

  // register users
  Future<UserCredential> registerUser({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print(
        'Error creating user: ${mapFirebaseExceptionCodes(errorCode: e.code)}',
      );
      throw Exception(mapFirebaseExceptionCodes(errorCode: e.code));
    } catch (e) {
      print('Error creating user: $e');
      throw Exception(e.toString());
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print(
        'Error signing in: ${mapFirebaseExceptionCodes(errorCode: e.code)}',
      );
      throw Exception(mapFirebaseExceptionCodes(errorCode: e.code));
    } catch (e) {
      print('Error signing in: $e');
    }
  }
}
