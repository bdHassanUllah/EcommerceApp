import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavedPostNotifier extends StateNotifier<Set<String>> {
  SavedPostNotifier() : super({});

  Future<void> toggleSave(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docId = "${user.email!.toLowerCase()}_$postId";
    final savedArticlesRef = FirebaseFirestore.instance.collection('saved_articles').doc(docId);

    final doc = await savedArticlesRef.get();

    if (doc.exists) {
      await savedArticlesRef.delete();
      state = {...state}..remove(postId);
    } else {
      await savedArticlesRef.set({
        'email': user.email!,
        'postId': postId,
      });
      state = {...state, postId};
    }
  }

  Future<void> loadSavedPosts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('saved_articles')
        .where('email', isEqualTo: user.email!.toLowerCase())
        .get();

    state = querySnapshot.docs.map((doc) => doc['postId'].toString()).toSet();
  }
}

// Riverpod Provider
final savedPostsProvider = StateNotifierProvider<SavedPostNotifier, Set<String>>((ref) {
  final notifier = SavedPostNotifier();
  notifier.loadSavedPosts(); // Load saved posts initially
  return notifier;
});
