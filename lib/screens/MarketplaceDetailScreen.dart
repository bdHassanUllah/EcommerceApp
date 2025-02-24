import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/state_provider/AuthStateProvider.dart';
import 'package:e_commerce/state_provider/BottomStateNavigator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce/Api_files/MarketplaceApi.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MarketplaceDetailScreen extends ConsumerStatefulWidget {
  final String title;
  final String imageUrl;
  final String content;

  const MarketplaceDetailScreen({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.content,
  });

  @override
  _MarketplaceDetailScreenState createState() => _MarketplaceDetailScreenState();
}

class _MarketplaceDetailScreenState extends ConsumerState<MarketplaceDetailScreen> {
  String removeHtmlTags(String htmlString) {
    String withoutShortcodes = htmlString.replaceAll(RegExp(r'\[.*?\]'), '');
    dom.Document document = html_parser.parse(withoutShortcodes);
    String plainText = document.body?.text ?? '';
    return plainText.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  late Future<List<Map<String, dynamic>>> marketplaceItems;
  Set<String> savedPosts = {};

  /*@override
  void initState() {
    super.initState();
    marketplaceItems = MarketplaceUrl.fetchMktPosts();
    _loadSavedPosts();
  }*/

  /*Future<void> _loadSavedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPostsList = prefs.getStringList('saved_posts') ?? [];
    setState(() {
      savedPosts = savedPostsList.toSet();
    });
  }*/

  /*Future<void> _toggleSavePost() async {
    final prefs = await SharedPreferences.getInstance();
    if (savedPosts.contains(widget.title)) {
      savedPosts.remove(widget.title);
    } else {
      savedPosts.add(widget.title);
    }
    await prefs.setStringList('saved_posts', savedPosts.toList());
    setState(() {});
  }*/
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
    final String postUrl = "https://ecommerce.com.pk/wp-json/api/v1/marketplaces"; // Replace with your post URL

    // Use share_plus to open the share dialog
    Share.share(postUrl, subject: 'Check out this post!');
  }


  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomNavProvider);
    final navigationNotifier = ref.read(bottomNavProvider.notifier);
    final user = ref.watch(authStateProvider);
    final isSaved = savedPosts.contains(widget.title);

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
        body: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Image.network(
              widget.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => 
                Icon(Icons.error, size: 200),
            ),
            SizedBox(height: 16),
            Text(
              removeHtmlTags(widget.title),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              removeHtmlTags(widget.content),
              style: const TextStyle(fontSize: 16),
            ),
          ],
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
