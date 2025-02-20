import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavedPostNotifier extends StateNotifier<Set<String>> {
  SavedPostNotifier() : super({});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetch saved posts from Firestore on app start
  Future<void> fetchSavedPosts() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.email)
          .collection('savedPosts')
          .get();

      final savedPosts = snapshot.docs.map((doc) => doc.id).toSet();
      state = savedPosts;
    } catch (e) {
      print("Error fetching saved posts: $e");
    }
  }

  /// Toggle Save Post (Add/Remove from Firestore)
  Future<void> toggleSave(String postId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final postRef = _firestore
        .collection('users')
        .doc(user.email)
        .collection('savedPosts')
        .doc(postId);

    try {
      if (state.contains(postId)) {
        await postRef.delete(); // Remove from Firestore
        state = {...state}..remove(postId);
      } else {
        await postRef.set({'savedAt': FieldValue.serverTimestamp()}); // Save to Firestore
        state = {...state}..add(postId);
      }
    } catch (e) {
      print("Error saving post: $e");
    }
  }
}

final savedPostsProvider = StateNotifierProvider<SavedPostNotifier, Set<String>>((ref) {
  final notifier = SavedPostNotifier();
  notifier.fetchSavedPosts(); // Load saved posts on app start
  return notifier;
});
