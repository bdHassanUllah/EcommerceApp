import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/model/HiveModel.dart';
import 'package:hive/hive.dart';

class SavedArticlesFetcher {
  final String userEmail;

  SavedArticlesFetcher({required this.userEmail});

  Future<List<Map<String, dynamic>>> fetchSavedPosts() async {
    List<Map<String, dynamic>> fetchedPosts = [];
    var box = Hive.box<HiveModel>('postsBox');

    print("🐝 Hive Box Keys (Post IDs): ${box.keys.toList()}");

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('saved_articles')
          .where('email', isEqualTo: userEmail)
          .get();

      for (var doc in querySnapshot.docs) {
        String savedPostId = doc['postId'].toString();
        if (box.containsKey(savedPostId)) {
          final savedPost = box.get(savedPostId);
          if (savedPost != null) {
            fetchedPosts.add({
              "id": savedPost.id,
              "title": savedPost.title,
              "imageUrl": savedPost.imageUrl,
              "content": savedPost.content,
            });
            print("✅ MATCH! Found in Hive: $savedPostId");
          }
        }
      }
    } catch (e) {
      print("🚨 Error fetching saved posts: $e");
    }
    return fetchedPosts;
  }
}
