import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/screens/LoginScreen.dart';
import 'package:e_commerce/screens/PostDetailScreen.dart';
import 'package:e_commerce/state_provider/AuthStateProvider.dart';
import 'package:e_commerce/widgets/BottomNavigationWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

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
  List<Map<String, dynamic>> savedPosts = [];

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
      _fetchSavedPosts(); // ✅ Fetch posts after setting userEmail
    }
  }

  Future<void> _fetchSavedPosts() async {
  if (userEmail == null) return;

  final box = await Hive.openBox('cacheBox');
  print("🐝 Hive Box Keys (Post IDs): ${box.keys.toList()}");

  List<Map<String, dynamic>> fetchedPosts = [];

  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('saved_articles')
        .where('email', isEqualTo: userEmail)
        .get();

    print("🔥 Firestore Docs Count: ${querySnapshot.docs.length}");

    for (var doc in querySnapshot.docs) {
      String savedPostId = doc['postId'].toString(); // Ensure correct key
      print("📝 Firestore Saved Post ID: $savedPostId");

      if (box.containsKey(savedPostId)) {
        final savedPost = box.get(savedPostId);
        print("✅ MATCH! Found in Hive: $savedPostId");
        fetchedPosts.add(savedPost);
      }
    }

    if (mounted) {
      setState(() {
        savedPosts = fetchedPosts;
        print("✅ Updated savedPosts: ${savedPosts.length} articles");
      });
    }
  } catch (e) {
    print("🚨 Error fetching saved posts: $e");
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

  Future<void> _changeAccount() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        ref.read(userProvider.notifier).state = user;
        _fetchSavedPosts(); // ✅ Fetch saved posts after account switch
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
                      : const AssetImage('lib/assets/image/default_avatar.png') as ImageProvider,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              child: savedPosts.isEmpty
                  ? const Center(child: Text("No saved articles found."))
                  : ListView.builder(
                      itemCount: savedPosts.length,
                      itemBuilder: (context, index) {
                        final article = savedPosts[index];
                        return ListTile(
                          title: Text(article['title'] ?? "Untitled"),
                          leading: article['featured_image'] != null
                              ? Image.network(article['featured_image'], width: 150, height: 150)
                              : Image.network(article['image'], width: 150, height: 150),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostDetailScreen(
                                  post: article,
                                  postContent: article['content'] ?? "No content available",
                                  id: article['postId'],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                height: 50,
                width: 250,
                child: ElevatedButton(
                  onPressed: _logout, // ✅ Logout button works now
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    side: const BorderSide(
                      color: Colors.black,
                      width: 0.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(),
    );
  }
}
