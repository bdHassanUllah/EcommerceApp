import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/FirebaseModel.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save article to Firestore
  static Future<void> saveArticle(FirebaseModel article) async {
    final docId = "${article.email}_${article.postId}";
    await _firestore.collection('saved_articles').doc(docId).set(article.toMap());
  }

  // Remove saved article
  static Future<void> removeSavedArticle(String email, String postId) async {
    final docId = "${email}_$postId";
    await _firestore.collection('saved_articles').doc(docId).delete();
  }

  // Check if an article is saved
  static Future<bool> isArticleSaved(String email, String postId) async {
    final docId = "${email}_$postId";
    final doc = await _firestore.collection('saved_articles').doc(docId).get();
    return doc.exists;
  }

  // Fetch all saved articles for a user
  static Future<List<FirebaseModel>> getSavedArticles(String email) async {
    final querySnapshot = await _firestore
        .collection('saved_articles')
        .where('email', isEqualTo: email)
        .get();

    return querySnapshot.docs
        .map((doc) => FirebaseModel.fromFirestore(doc))
        .toList();
  }
}