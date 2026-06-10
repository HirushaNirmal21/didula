import 'package:firebase_storage/firebase_storage.dart';

import 'dart:io';

class UserProfileStorageService {
  final FirebaseStorage _storage;

  UserProfileStorageService({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  Future<String> uploadImage({
    required File profileImage,
    required String userEmail,
  }) async {
    Reference ref = _storage
        .ref()
        .child("user-images")
        .child("$userEmail/${DateTime.now()}");

    try {
      UploadTask task = ref.putFile(
        profileImage,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      TaskSnapshot snapshot = await task;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print(e);
      return "";
    }
  }
}
