import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_commerce/screens/PostDetailScreen.dart';
import 'package:share_plus/share_plus.dart'; // Import share_plus

class PostWidget extends StatefulWidget {
  final Map<String, dynamic> post;
  final String imageUrl;

  const PostWidget({super.key, required this.post, required this.imageUrl});

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
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
    final docId = "${userEmail!}_" + widget.post['title'];
    final doc = await FirebaseFirestore.instance.collection('saved_articles').doc(docId).get();
    setState(() {
      isSaved = doc.exists;
    });
  }

  void toggleSaveArticle() async {
    if (!isLoggedIn) return;

    final docId = "${userEmail!}_" + widget.post['title'];
    final savedArticlesRef = FirebaseFirestore.instance.collection('saved_articles');

    try {
      if (isSaved) {
        await savedArticlesRef.doc(docId).delete();
        showDialogBox("Removed", "Article removed from saved list.");
      } else {
        await savedArticlesRef.doc(docId).set({
          'email': userEmail!,
          'title': widget.post['title'] ?? "No Title",
          'content': widget.post['content'] ?? "No Content",
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
    final String postUrl = "https://ecommerce.com.pk/wp-json/api/v1/happenings/"; // Replace with your post URL

    // Use share_plus to open the share dialog
    Share.share(postUrl, subject: 'Check out this post!');
  }

  @override
  Widget build(BuildContext context) {
    double imageSize = 20.0;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(
              post: widget.post,
              postContent: widget.post['content'] ?? "No Content Available",
            ),
          ),
        );
      },
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post['title'] ?? "No Title",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      /*Text(
                        widget.post['excerpt'] ?? "No Description",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),*/
                      SizedBox(height: 70),
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.black, size: 16),
                          SizedBox(width: 5),
                          Text(
                            DateFormat('MMMM dd, yyyy').format(
                              DateTime.tryParse(widget.post['created_at'].toString()) ?? DateTime.now(),
                            ),
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.imageUrl,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset("assets/images/placeholder.jpg", height: 80, width: 80, fit: BoxFit.cover),
                      ),
                    ),
                    SizedBox(height: 50),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: isLoggedIn ? toggleSaveArticle : null,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSaved ? Icons.bookmark : Icons.bookmark_border,
                                color: isSaved ? Colors.black : Colors.grey,
                              ),
                              SizedBox(width: 3),
                              Text(
                                "Save",
                                style: TextStyle(
                                  color: isLoggedIn ? Colors.black : Colors.grey,
                                  fontSize: 12,
                                  fontWeight: isLoggedIn ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            sharePost(context); // Open the mobile share dialog
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'lib/assets/image/share_logo.png',
                                height: 30,
                                width: 30,
                              ),
                              SizedBox(width: 3),
                              Text(
                                "Share",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey),
        ],
      ),
    );
  }
}
