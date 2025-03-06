import 'dart:convert';

import 'package:e_commerce/state_provider/AuthStateProvider.dart';
import 'package:e_commerce/state_provider/BottomStateNavigator.dart';
import 'package:e_commerce/state_provider/SavedPost.dart';
import 'package:e_commerce/widgets/BottomNavigationWidget.dart';
import 'package:e_commerce/widgets/Functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final String post;
  final String postContent;
  final String id;
  final String title;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.postContent,
    required this.id,
    required this.title
  });

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  //Corrected function
  void _toggleSavePost() async {
    await ref.read(savedPostsProvider.notifier).toggleSave(widget.id, context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        ref.read(bottomNavProvider.notifier).state = 0;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2F4568),
          foregroundColor: Colors.white,
          title: Text(widget.title),
          actions: [
            //Corrected Save Function Call
            ShareUtil.buildPopupMenu(
              context: context,
              ref: ref,
              postId: widget.id.toString(), // Corrected ID reference
              post: widget.post,
              toggleSavePost: _toggleSavePost, //Works correctly now
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  widget.post,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.5,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    "lib/assets/image/placeholder.jpg",
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width * 0.5,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.title ?? "No Title",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  ShareUtil.removeHtmlTags(widget.postContent),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationWidget(),
      ),
    );
  }
}
