import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseModel {
  final String email;
  final String postId;
  final String title;
  final String imageUrl;
  final String content;

  FirebaseModel({
    required this.email,
    required this.postId,
    required this.title,
    required this.imageUrl,
    required this.content,
  });

  // Convert model to JSON for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'postId': postId,
      'title': title,
      'imageUrl': imageUrl,
      'content': content,
    };
  }

  // Convert Firestore document to model
  factory FirebaseModel.fromMap(Map<String, dynamic> map) {
    return FirebaseModel(
      email: map['email'] ?? '',
      postId: map['postId'] ?? '',
      title: map['title'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      content: map['content'] ?? '',
    );
  }

  // Convert Firestore document snapshot to model
  factory FirebaseModel.fromFirestore(DocumentSnapshot doc) {
    return FirebaseModel.fromMap(doc.data() as Map<String, dynamic>);
  }
}
