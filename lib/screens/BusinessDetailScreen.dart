import 'package:e_commerce/state_provider/AuthStateProvider.dart';
import 'package:e_commerce/state_provider/BottomStateNavigator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

class BusinessDetailScreen extends ConsumerStatefulWidget {
  final String title;
  final String imageUrl;
  final String content;
  final Map<String, dynamic> post;

  const BusinessDetailScreen({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.content,
    required this.post,
  });

  @override
  _BusinessDetailScreenState createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends ConsumerState<BusinessDetailScreen> {
  String removeHtmlTags(String htmlString) {
    String withoutShortcodes = htmlString.replaceAll(RegExp(r'\[.*?\]'), '');
    dom.Document document = html_parser.parse(withoutShortcodes);
    String plainText = document.body?.text ?? '';
    return plainText.replaceAll(RegExp(r'\s+'), ' ').trim();
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
    final String postUrl = "https://ecommerce.com.pk/wp-json/api/v1/businesses/"; // Replace with your post URL

    // Use share_plus to open the share dialog
    Share.share(postUrl, subject: 'Check out this post!');
  }


  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomNavProvider);
    final navigationNotifier = ref.read(bottomNavProvider.notifier);
    final user = ref.watch(authStateProvider);

    return WillPopScope(
      onWillPop: () async {
        navigationNotifier.state = 0;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "save") {
                  toggleSaveArticle();
                } else if (value == "share") {
                  sharePost(context);
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'save',
                  child: ListTile(
                    leading: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? Colors.black : null,
                    ),
                    title: Text(isSaved?'Unsave':'Save'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: ListTile(
                    leading: Icon(Icons.share),
                    title: Text('Share'),
                  ),
                ),
              ],
            ),
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
                      removeHtmlTags(widget.title),
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
              ref.refresh(authStateProvider);
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
