import '../model/HiveModel.dart';
import '../state_provider/SavedPost.dart';
import '../widgets/BottomNavigationWidget.dart';
import '../widgets/Functions.dart';
import '../widgets/ScrollFunctions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final HiveModel hiveModels;

  const PostDetailScreen({super.key, required this.hiveModels});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  //Corrected function
  void _toggleSavePost() async {
    await ref
        .read(savedPostsProvider.notifier)
        .toggleSave(widget.hiveModels.id, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F4568),
        foregroundColor: Colors.white,
        title: Text(widget.hiveModels.title),
        actions: [
          //Corrected Save Function Call
          ShareUtil.buildPopupMenu(
            context: context,
            ref: ref,
            postId: widget.hiveModels.id.toString(), // Corrected ID reference
            post: widget.hiveModels.imageUrl,
            toggleSavePost: _toggleSavePost, //Works correctly now
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ScrollableContentWidget(
          imageUrl: widget.hiveModels.imageUrl,
          title: widget.hiveModels.title,
          content: widget.hiveModels.content,
          date: widget.hiveModels.date!,
        ),
      ),
      bottomNavigationBar: BottomNavigationWidget(),
    );
  }
}
