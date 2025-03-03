import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SavedPostsNotifier extends StateNotifier<Set<String>> {
  SavedPostsNotifier() : super({}) {
    _loadSavedPosts(); // Load saved posts initially
  }

  /// Load saved posts from Firestore
  Future<void> _loadSavedPosts() async {
    final userEmail = "user@example.com"; // Replace with actual logged-in user email
    final snapshot = await FirebaseFirestore.instance
        .collection('saved_articles')
        .where('email', isEqualTo: userEmail)
        .get();

    final savedPosts = snapshot.docs.map((doc) => doc['postId'].toString()).toSet();
    state = savedPosts;
  }

  /// Toggle save or unsave a post
  Future<void> toggleSave(String postId) async {
    final userEmail = "user@example.com"; // Replace with actual logged-in user email
    final docId = "${userEmail}_$postId";
    final savedArticleRef = FirebaseFirestore.instance.collection('saved_articles').doc(docId);

    if (state.contains(postId)) {
      await savedArticleRef.delete();
      state = {...state}..remove(postId); // Remove from saved list
    } else {
      await savedArticleRef.set({
        'email': userEmail,
        'postId': postId,
      });
      state = {...state}..add(postId); // Add to saved list
    }
  }
}

// **Create a Riverpod Provider for saved posts**
final savedPostsProvider = StateNotifierProvider<SavedPostsNotifier, Set<String>>((ref) {
  return SavedPostsNotifier();
});
