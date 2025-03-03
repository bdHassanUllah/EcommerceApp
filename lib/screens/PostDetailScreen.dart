import 'package:e_commerce/state_provider/AuthStateProvider.dart';
import 'package:e_commerce/state_provider/BottomStateNavigator.dart';
import 'package:e_commerce/widgets/BottomNavigationWidget.dart';
import 'package:e_commerce/widgets/Functions.dart';
import 'package:e_commerce/widgets/SavedFunction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> post;
  final String postContent;
  final String id;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.postContent,
    required this.id,
  });

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  void _toggleSavePost() async {
  final user = ref.watch(authStateProvider);
  if (user == null) {
    _showLoginMessage();
    return;
  }

  await ref.read(savedPostsProvider.notifier).toggleSave(widget.post['id'].toString());

  setState(() {}); 
  // Read the updated state after the async operation
  final isPostSaved = ref.watch(savedPostsProvider).contains(widget.post['id'].toString());

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(isPostSaved ? "Save the article" : "Removed the article"),
    ),
  );
}


  void _showLoginMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please log in to use this feature")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomNavProvider);
    final navigationNotifier = ref.read(bottomNavProvider.notifier);
    final user = ref.watch(authStateProvider);
    final isSaved = ref.watch(savedPostsProvider).contains(widget.post['id'].toString());

    return WillPopScope(
      onWillPop: () async {
        navigationNotifier.state = 0;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF2F4568),
          foregroundColor: Colors.white,
          title: Text(widget.post['title'] ?? "No Title"),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "save") {
                  _toggleSavePost(
                    
                  );
                } else if (value == "share") {
                  ShareUtil.sharePost(
                    context, 
                    widget.id, 
                    pageRoute: "postdetailscreen" // Custom route for marketplace posts
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: "save",
                  enabled: user != null,
                  child: Row(
                    children: [
                      Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: user != null ? Colors.black : Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isSaved ? "Unsave Post" : "Save Post",
                        style: TextStyle(color: user != null ? Colors.black : Colors.grey),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: "share",
                  enabled: user != null,
                  child: Row(
                    children: [
                      Image.asset('lib/assets/image/share_logo.png',
                      height: 30,
                      width: 30,
                      ), 
                      const SizedBox(width: 10),
                      Text(
                        "Share Post",
                        style: TextStyle(color: user != null ? Colors.black : Colors.grey),
                      ),
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
                Image.network(
                  widget.post['featured_image'] ?? "https://via.placeholder.com/150",
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 10),
                Text(
                  widget.post['title'] ?? "No Title",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                //Html (data: widget.postContent),
                Text(
                  ShareUtil.removeHtmlTags(widget.postContent),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        /*bottomNavigationBar: BottomNavigationBar(
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
        ),*/
        bottomNavigationBar: const BottomNavigationWidget(),
      ),
    );
  }
}
