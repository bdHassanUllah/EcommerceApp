import 'package:e_commerce/state_provider/AuthStateProvider.dart';
import 'package:e_commerce/state_provider/BottomStateNavigator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:html/parser.dart';

class BlogDetailScreen extends ConsumerStatefulWidget {
  final String title;
  final String imageUrl;
  final String content;

  const BlogDetailScreen({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.content,
  });

  @override
  _BlogDetailScreenState createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends ConsumerState<BlogDetailScreen> {
  String removeHtmlTags(String htmlString) {
    return parse(htmlString).body?.text ?? '';
  }

  bool isLoggedIn = false;
  String? userEmail;
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    checkIfSaved();
  }

  void checkLoginStatus() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      isLoggedIn = user != null;
      userEmail = user?.email?.toLowerCase();
    });
  }

  Future<void> checkIfSaved() async {
    if (userEmail == null) return;
    final docId = "${userEmail!}_" + widget.title;
    final doc = await FirebaseFirestore.instance.collection('saved_articles').doc(docId).get();
    setState(() {
      isSaved = doc.exists;
    });
  }


    void toggleSaveArticle() async {
    if (!isLoggedIn) return;

    final docId = "${userEmail!}_" + widget.title;
    final savedArticlesRef = FirebaseFirestore.instance.collection('saved_articles');

    try {
      if (isSaved) {
        await savedArticlesRef.doc(docId).delete();
        showDialogBox("Removed", "Article removed from saved list.");
      } else {
        await savedArticlesRef.doc(docId).set({
          'email': userEmail!,
          'title': widget.title?? "No Title",
          'content': widget.content ?? "No Content",
          'imageUrl': widget.imageUrl,
          'timestamp': FieldValue.serverTimestamp(),
        });
        showDialogBox("Success", "Article saved successfully!");
      }
      setState(() {
        isSaved = !isSaved;
      });
    } catch (error) {
      showDialogBox("Error", "Failed to save the article. Please try again.");
    }
  }

  void showDialogBox(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Method to handle sharing the post
  void sharePost(BuildContext context) {
    final String postUrl = "https://ecommerce.com.pk/wp-json/api/v1/blogs"; // Replace with your post URL

    // Use share_plus to open the share dialog
    Share.share(postUrl, subject: 'Check out this post!');
  }


  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomNavProvider);
    final navigationNotifier = ref.read(bottomNavProvider.notifier);
    final user = ref.watch(authStateProvider);
    bool isPopupOpen = false; // Add this to manage the menu state

    return WillPopScope(
      onWillPop: () async {
        navigationNotifier;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Blog Details"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            

IconButton(
  icon: const Icon(Icons.more_vert),
  onPressed: () async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    if (isPopupOpen) {
      Navigator.of(context).pop(); // Close menu if already open
    } else {
      isPopupOpen = true;
      await showMenu(
        context: context,
        position: RelativeRect.fromLTRB(offset.dx + 900, offset.dy + 80, offset.dx + 22, 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: Colors.grey, width: 1), // Add border
        ),
        color: Colors.white,
        elevation: 10,
        items: [
          PopupMenuItem(
            value: 'save',
            child: Row(
              children: [
                Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? Colors.black : Colors.grey,
                ),
                const SizedBox(width: 10),
                Text(
                  isSaved ? 'Unsave' : 'Save',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          
          PopupMenuItem(
            value: 'share',
            child: Row(
              children: [
                const Icon(Icons.share, color: Colors.black),
                const SizedBox(width: 10),
                const Text(
                  'Share',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ).then((value) {
        isPopupOpen = false; // Reset menu state after closing

        if (value == 'save' && user != null) {
          toggleSaveArticle();
          } else if (value == "share") {
              sharePost(context);
            }
    });
  }}),
    
  


          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                widget.imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    "lib/assets/image/placeholder.jpg",
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      removeHtmlTags(widget.content),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            ref.read(bottomNavProvider.notifier).setIndex(index, context);
            if (index == 2) {
              ref.watch(authStateProvider);
            }
          },
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
              icon: user != null && user.photoURL != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(user.photoURL!),
                      radius: 14,
                    )
                  : const Icon(Icons.account_circle, size: 28),
              label: user != null ? user.displayName ?? "Profile" : "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
