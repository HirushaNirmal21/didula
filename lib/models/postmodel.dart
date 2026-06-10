import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:didula_api/utils/moods.dart';

class PostModel {
  final String postId;
  final Moods mood;
  final String postCaption;
  final String userId;
  final String userName;
  final String profileImage;
  final int like;
  final DateTime datePublished;
  final String postUrl;

  PostModel({
    required this.postId,
    required this.mood,
    required this.postCaption,
    required this.userId,
    required this.userName,
    required this.profileImage,
    required this.like,
    required this.datePublished,
    required this.postUrl,
  });

  //convert a post instance to a map(for saving to firestore)
  Map<String, dynamic> toJson() {
    return {
      "postId": postId,
      "mood": mood.name,
      "postCaption": postCaption,
      "userId": userId,
      "userName": userName,
      "profileImage": profileImage,
      "like": like,
      "datePublished": Timestamp.fromDate(datePublished),
      "postUrl": postUrl,
    };
  }

  //create a post instance from a map (for retriving from firestore)
  factory PostModel.fromJson(Map<String, dynamic> data) {
    return PostModel(
      postId: data["postId"] ?? "",
      mood: MoodExtention.fromString(data["mood"] ?? "Happy"),
      postCaption: data["postCaption"] ?? "",
      userId: data["userId"] ?? "",
      userName: data["userName"] ?? "",
      profileImage: data["profileImage"] ?? "",
      like: data["like"] ?? 0,
      datePublished: (data["datePublished"] as Timestamp).toDate(),
      postUrl: data["postUrl"] ?? "",
    );
  }
}
