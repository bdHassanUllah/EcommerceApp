import '../state_provider/AuthStateProvider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SavedPostsNotifier extends StateNotifier<Set<String>> {
  final Ref ref;

  SavedPostsNotifier(this.ref) : super({}) {
    _initialize();
  }

  /// Initialize listener to update when user changes
  void _initialize() {
    ref.listen(authStateProvider, (previous, next) {
      if (next?.email != previous?.email) {
        _loadSavedPosts();
      }
    });
    _loadSavedPosts();
  }

  /// Load saved posts from Firestore dynamically
  Future<void> _loadSavedPosts() async {
    final user = ref.read(authStateProvider);
    final userEmail = user?.email ?? "";

    if (userEmail.isEmpty) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('saved_articles')
        .where('email', isEqualTo: userEmail)
        .get();

    final savedPosts =
        snapshot.docs.map((doc) => doc['postId'].toString()).toSet();

    state = savedPosts;
  }

  /// Toggle save or unsave a post
  Future<void> toggleSave(String postId) async {
    final user = ref.read(authStateProvider);
    final userEmail = user?.email ?? "";

    if (userEmail.isEmpty) return;

    final docId = "${userEmail}_$postId";
    final savedArticleRef =
        FirebaseFirestore.instance.collection('saved_articles').doc(docId);

    if (state.contains(postId)) {
      await savedArticleRef.delete();
      state = {...state}..remove(postId);
    } else {
      await savedArticleRef.set({'email': userEmail, 'postId': postId});
      state = {...state}..add(postId);
    }

    /// Notify all listening widgets
    state = {...state};
  }
}

// **Update Provider**
final savedPostsProvider =
    StateNotifierProvider<SavedPostsNotifier, Set<String>>((ref) {
  return SavedPostsNotifier(ref);
});
