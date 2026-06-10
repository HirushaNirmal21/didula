import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class Feedstorageservice {
  //Firebase Storage instance
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  //upload an image
  Future<String> uploadImage({
    required File postImage,
    required String userId,
  }) async {
    final ref = _firebaseStorage
        .ref()
        .child("feed-images")
        .child("$userId/${DateTime.now()}");

    try {
      //store the image under the reference
      final UploadTask task = ref.putFile(
        postImage,
        SettableMetadata(contentType: "image/jpeg"),
      );

      TaskSnapshot snapshot = await task;
      final String url = await snapshot.ref.getDownloadURL();

      return url;
    } catch (e) {
      print(e.toString());
      return "";
    }
  }

  //delete image from storage
  Future<void> deleteImage({required String imageUrl}) async {
    try {
      await _firebaseStorage.refFromURL(imageUrl).delete();
    } catch (e) {
      print("error delete :$e");
    }
  }
}
