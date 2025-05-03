import '../model/HiveModel.dart';
import '../state_provider/BottomStateNavigator.dart';
import '../state_provider/SavedPost.dart';
import '../widgets/BottomNavigationWidget.dart';
import '../widgets/Functions.dart';
import '../widgets/ScrollFunctions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BlogDetailScreen extends ConsumerStatefulWidget {
  final HiveModel hiveModel;

  const BlogDetailScreen({super.key, required this.hiveModel});

  @override
  _BlogDetailScreenState createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends ConsumerState<BlogDetailScreen> {
  //  Corrected function
  void _toggleSavePost() async {
    await ref
        .read(savedPostsProvider.notifier)
        .toggleSave(widget.hiveModel.id, context);
  }

  @override
  Widget build(BuildContext context) {
    final navigationNotifier = ref.read(bottomNavProvider.notifier);

    ///  Converts `widget.content` to a Map for Firestore storage
    Map<String, dynamic> postContent = {"text": widget.hiveModel.content};

    return PopScope(
      canPop: true, // Allows back navigation
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          navigationNotifier; // Keeping your original logic
        }
      },

      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2F4568),
          foregroundColor: Colors.white,
          title: Text(widget.hiveModel.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            ShareUtil.buildPopupMenu(
              context: context,
              ref: ref,
              postId: widget.hiveModel.id.toString(),
              toggleSavePost: _toggleSavePost, //  Now works without error
              post: postContent,
            ),
          ],
        ),
        body: ScrollableContentWidget(
          imageUrl: widget.hiveModel.imageUrl,
          title: widget.hiveModel.title,
          content: widget.hiveModel.content,
          date: widget.hiveModel.date!,
        ),
        bottomNavigationBar: BottomNavigationWidget(),
      ),
    );
  }
}
