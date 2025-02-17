import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/screens/LoginScreen.dart';
import 'package:e_commerce/screens/PostDetailScreen.dart';
import 'package:e_commerce/state_provider/AuthStateProvider.dart';
import 'package:e_commerce/widgets/BottomNavigationWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String userName;
  final String userImage;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.userImage,
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  String? userEmail;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  void _getUserData() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      setState(() {
        user = currentUser;
        userEmail = currentUser.email?.toLowerCase();
      });
    }
  }

  // Method to save the article
  void _saveArticle(String postId, String title, String content, String imageUrl) async {
    if (userEmail == null) return;

    final savedArticlesRef = FirebaseFirestore.instance.collection('saved_articles');
    
    // Check if the article has already been saved by its postId
    final querySnapshot = await savedArticlesRef
        .where('email', isEqualTo: userEmail)
        .where('postId', isEqualTo: postId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      // Save the article if it's not already saved
      await savedArticlesRef.add({
        'email': userEmail,
        'postId': postId,
        'title': title,
        'content': content,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } else {
      // Optionally show a message that the post is already saved
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This article is already saved.")),
      );
    }
  }

  void _logout() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: _logout,
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeAccount() async {
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

      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        ref.read(userProvider.notifier).state = user;
      }
    } catch (e) {
      print("Error changing account: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: widget.userImage.isNotEmpty
                      ? NetworkImage(widget.userImage)
                      : const AssetImage('lib/assets/image/default_avatar.png') 
                          as ImageProvider,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _changeAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 2, 41, 74),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Change Account'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Saved Articles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: userEmail == null
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('saved_articles')
                          .where('email', isEqualTo: userEmail)
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == 
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text("Error: ${snapshot.error}"));
                        }
                        if (!snapshot.hasData || 
                            snapshot.data!.docs.isEmpty) {
                          return const Center(
                              child: Text("No saved articles found."));
                        }

                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final article = snapshot.data!.docs[index].data() 
                                as Map<String, dynamic>;
                            return ListTile(
                              title: Text(article['title'] ?? "Untitled"),
                              leading: article['imageUrl'] != null
                                  ? Image.network(article['imageUrl'], 
                                      width: 150, height: 150)
                                  : const Icon(Icons.image, size: 50),
                              onTap: () {
                                // Save the post when tapped
                                _saveArticle(
                                  article['postId'] ?? '', 
                                  article['title'] ?? "No title", 
                                  article['content'] ?? "No content", 
                                  article['imageUrl'] ?? ''
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PostDetailScreen(
                                      post: article,
                                      postContent: article['content'] ?? "No content available",
                                      datePosted: article['timestamp'] != null
                                          ? (article['timestamp'] as Timestamp).toDate().toString()
                                          : "Unknown date",
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(),
    );
  }
}
