import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didula_api/models/postmodel.dart';
import 'package:didula_api/services/feed/feedstorageservice.dart';
import 'package:didula_api/utils/moods.dart';

class Feedservices {
  final FirebaseFirestore _firestore;
  final Feedstorageservice _storageService;

  // ⚡ Constructor එක හරහා පිටින් Firestore සහ Storage Service එකක් inject කරන්න පුළුවන් කලා
  Feedservices({
    FirebaseFirestore? firestore,
    Feedstorageservice? storageService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storageService = storageService ?? Feedstorageservice();

  CollectionReference get _feedsCollection => _firestore.collection("feeds");

  // Save the post in the Firestore database
  Future<void> savePost(Map<String, dynamic> postDetails) async {
    try {
      String? postUrl;

      // check if the post has an image
      if (postDetails["postImage"] != null &&
          postDetails["postImage"] is File) {
        // ⚡ මෙතන දැන් constructor එකෙන් ආපු _storageService එක පාවිච්චි කරනවා
        postUrl = await _storageService.uploadImage(
          postImage: postDetails["postImage"] as File,
          userId: postDetails["userId"] as String,
        );
      }

      // create a new post
      final PostModel newPost = PostModel(
        postId: "",
        mood: MoodExtention.fromString(postDetails["mood"] ?? "happy"),
        postCaption: postDetails["postCaption"] as String? ?? "",
        userId: postDetails["userId"] as String? ?? "",
        userName: postDetails["userName"] as String? ?? "",
        profileImage: postDetails["profileImage"] as String? ?? "",
        like: 0,
        datePublished: DateTime.now(),
        postUrl: postUrl ?? "",
      );

      // add the post to the collection
      final DocumentReference docref = await _feedsCollection.add(
        newPost.toJson(),
      );

      await docref.update({"postId": docref.id});
      print("post saved");
    } catch (e) {
      print("error saving post :$e");
    }
  }

  // Fetch the post as a stream
  Stream<List<PostModel>> getPostStream() {
    return _feedsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return PostModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // create method like post
  Future<void> likePost({
    required String postId,
    required String userId,
  }) async {
    try {
      final DocumentReference postLikeRef = _feedsCollection
          .doc(postId)
          .collection("likes")
          .doc(userId);

      // add a document to the likes subcollection
      await postLikeRef.set({"LikedAt": Timestamp.now()});

      // update the likes count in the post document
      final DocumentSnapshot postDoc = await _feedsCollection.doc(postId).get();

      final PostModel post = PostModel.fromJson(
        postDoc.data() as Map<String, dynamic>,
      );
      final int newLikes = post.like + 1;

      // update
      await _feedsCollection.doc(postId).update({"like": newLikes});
    } catch (e) {
      print("error get like post:$e");
    }
  }

  // create method dislike post
  Future<void> disLikePost({
    required String postId,
    required String userId,
  }) async {
    try {
      final DocumentReference postLikeRef = _feedsCollection
          .doc(postId)
          .collection("likes")
          .doc(userId);

      // Delete a document to the likes subcollection
      await postLikeRef.delete();

      // update the likes count in the post document
      final DocumentSnapshot postDoc = await _feedsCollection.doc(postId).get();

      final PostModel post = PostModel.fromJson(
        postDoc.data() as Map<String, dynamic>,
      );
      final int newLike = post.like - 1;

      // update
      await _feedsCollection.doc(postId).update({"like": newLike});
    } catch (e) {
      print("error get like post:$e");
    }
  }

  // check if a uservhas liked a post
  Future<bool> hasUserLikedPost({
    required String postId,
    required String userId,
  }) async {
    try {
      final DocumentReference postLikeRef = _feedsCollection
          .doc(postId)
          .collection("likes")
          .doc(userId);

      final DocumentSnapshot doc = await postLikeRef.get();

      return doc.exists;
    } catch (e) {
      print("error get user like : $e");
      return false;
    }
  }

  // delete a post from the Firestore database
  Future<void> deletePost({
    required String postId,
    required String postUrl,
  }) async {
    try {
      // ⚡ මෙතනත් _storageService එක පාවිච්චි කරනවා
      await _storageService.deleteImage(imageUrl: postUrl);
      // delete the firebase doc
      await _feedsCollection.doc(postId).delete();
    } catch (e) {
      print("error deleting post: $e");
    }
  }
}
