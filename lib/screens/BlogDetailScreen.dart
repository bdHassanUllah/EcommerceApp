import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/model/FirebaseModel.dart';
import 'package:e_commerce/state_provider/AuthStateProvider.dart';
import 'package:e_commerce/state_provider/BottomStateNavigator.dart';
import 'package:e_commerce/state_provider/SavedPost.dart';
import 'package:e_commerce/widgets/BottomNavigationWidget.dart';
import 'package:e_commerce/widgets/Functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BlogDetailScreen extends ConsumerStatefulWidget {
  final String title;
  final String imageUrl;
  final String content;
  final String id;

  const BlogDetailScreen({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.content,
    required this.id,
  });

  @override
  _BlogDetailScreenState createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends ConsumerState<BlogDetailScreen> {
  // ✅ Corrected function
  void _toggleSavePost() async {
    await ref.read(savedPostsProvider.notifier).toggleSave(widget.id, context);
  }

  @override
  Widget build(BuildContext context) {
    final navigationNotifier = ref.read(bottomNavProvider.notifier);
    final savedPosts = ref.watch(savedPostsProvider);
    final isSaved = savedPosts.contains(widget.id);

    /// ✅ Converts `widget.content` to a Map for Firestore storage
    Map<String, dynamic> postContent = {
      "text": widget.content,
    };

    return WillPopScope(
      onWillPop: () async {
        navigationNotifier;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2F4568),
          foregroundColor: Colors.white,
          title: Text(widget.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            ShareUtil.buildPopupMenu(
              context: context,
              ref: ref,
              postId: widget.id.toString(),
              toggleSavePost: _toggleSavePost, // ✅ Now works without error
              post: postContent,
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
                    'lib/assets/image/placeholder.jpg',
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
                      ShareUtil.removeHtmlTags(widget.title),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.content.isNotEmpty
                          ? ShareUtil.removeHtmlTags(widget.content.toString())
                          : 'Content not available',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationWidget(),
      ),
    );
  }
}
