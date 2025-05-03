import 'package:e_commerce_app/state_provider/AuthStateProvider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  /// Toggle save or unsave a post with Snackbar
  Future<void> toggleSave(String postId, BuildContext context) async {
    final user = ref.read(authStateProvider);
    final userEmail = user?.email ?? "";

    if (userEmail.isEmpty) return;

    final docId = "${userEmail}_$postId";
    final savedArticleRef =
        FirebaseFirestore.instance.collection('saved_articles').doc(docId);

    if (state.contains(postId)) {
      await savedArticleRef.delete();
      state = {...state}..remove(postId.toString());
      _showSnackbar(context, "Post removed from saved items.");
    } else {
      await savedArticleRef.set({'email': userEmail, 'postId': postId});
      state = {...state}..add(postId);
      _showSnackbar(context, "Post saved successfully!");
    }
  }

  /// Show Snackbar Notification
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}

/// **Update Provider**
final savedPostsProvider =
    StateNotifierProvider<SavedPostsNotifier, Set<String>>((ref) {
  return SavedPostsNotifier(ref);
});
