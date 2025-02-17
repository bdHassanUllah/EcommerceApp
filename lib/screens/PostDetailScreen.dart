import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:share_plus/share_plus.dart';

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;
  final String postContent; // Post content
  final String datePosted; // Post date

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.postContent,
    required this.datePosted,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
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
    final docId = "${userEmail!}_${widget.post['title']}";
    final doc = await FirebaseFirestore.instance.collection('saved_articles').doc(docId).get();
    setState(() {
      isSaved = doc.exists;
    });
  }

  void toggleSaveArticle() async {
    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to save articles.")),
      );
      return;
    }

    final docId = "${userEmail!}_${widget.post['title']}";
    final savedArticlesRef = FirebaseFirestore.instance.collection('saved_articles');

    if (isSaved) {
      await savedArticlesRef.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Article removed from saved.")),
      );
    } else {
      await savedArticlesRef.doc(docId).set({
        'email': userEmail!,
        'title': widget.post['title'] ?? "No Title",
        'content': widget.post['content'] ?? "No Content",
        'imageUrl': widget.post['featured_image'] ?? "https://via.placeholder.com/150",
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Article saved successfully!")),
      );
    }

    setState(() {
      isSaved = !isSaved;
    });
  }

  void sharePost() {
    final title = widget.post['title'] ?? "No Title";
    final content = widget.post['content'] ?? "No Content";
    final shareText = "$title\n\n$content\n\nRead more in our app!";
    Share.share(shareText);
  }

  // Function to remove HTML tags
  String removeHtmlTags(String htmlText) {
    var document = parse(htmlText);
    return document.body?.text ?? "";
  }

  @override
  Widget build(BuildContext context) {
    String title = removeHtmlTags(widget.post['title'] ?? "No Title");
    String content = removeHtmlTags(widget.postContent); // Use cleaned content
    String imageUrl = widget.post['featured_image'] ?? "https://via.placeholder.com/150";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Details"),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String value) {
              if (value == 'save') {
                toggleSaveArticle();
              } else if (value == 'share') {
                sharePost();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'save',
                child: Row(
                  children: [
                    Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? Colors.black : Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    Text(isSaved ? "Unsave" : "Save"), // Dynamic label
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share, color: Colors.black),
                    SizedBox(width: 10),
                    Text("Share"),
                  ],
                ),
              ),
            ],
          ),
        ],

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image at the top
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      "https://via.placeholder.com/150", // Fallback image
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "Posted on: ${widget.datePosted}", // Display the date
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Text(
                content,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
