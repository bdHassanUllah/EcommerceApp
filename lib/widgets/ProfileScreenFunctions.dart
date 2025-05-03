import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/HiveModel.dart';
import 'package:hive/hive.dart';
import '../screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state_provider/AuthStateProvider.dart';

class Profilescreenfunctions {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  String? userEmail;
  List<Map<String, dynamic>> savedPosts = [];
  final WidgetRef ref;
  final BuildContext context;

  Profilescreenfunctions({required this.ref, required this.context});

  void init() {
    _getUserData();
  }

  void _getUserData() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      user = currentUser;
      userEmail = currentUser.email?.toLowerCase();
      _fetchSavedPosts();
    }
  }

  Future<void> _fetchSavedPosts() async {
    if (userEmail == null) return;

    List<Map<String, dynamic>> fetchedPosts = [];
    var box = Hive.box<HiveModel>('postsBox');

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
          }
        }
      }
    } catch (e) {
      print("🚨 Error fetching saved posts: $e");
    }

    savedPosts = fetchedPosts;
  }

  void logout() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> changeAccount() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;

      if (user != null) {
        ref.read(userProvider.notifier).state = user;
      }
    } catch (e) {
      print("Error changing account: $e");
    }
  }

  static void showLogoutDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text(
            "Are you sure you want to logout?",
            style: TextStyle(fontSize: 20),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel", style: TextStyle(fontSize: 20)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onConfirm(); // Call the logout function
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.red, fontSize: 20),
              ),
            ),
          ],
        );
      },
    );
  }
}
