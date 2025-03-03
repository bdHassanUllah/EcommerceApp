import 'package:e_commerce/model/FirebaseModel.dart';
import 'package:e_commerce/state_provider/AuthStateProvider.dart';
import 'package:e_commerce/state_provider/BottomStateNavigator.dart';
import 'package:e_commerce/widgets/BottomNavigationWidget.dart';
import 'package:e_commerce/widgets/FirebaseService.dart';
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
  bool isLoggedIn = false;
  String? userEmail;
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      isLoggedIn = user != null;
      userEmail = user?.email?.toLowerCase();
    });
    if (isLoggedIn) {
      checkIfSaved();
    }
  }

  Future<void> checkIfSaved() async {
    if (userEmail == null) return;
    isSaved = await FirebaseService.isArticleSaved(userEmail!, widget.id);
    setState(() {});
  }

  void toggleSaveArticle() async {
    if (!isLoggedIn) return;

    final article = FirebaseModel(
      email: userEmail!,
      postId: widget.id,
      title: widget.title,
      imageUrl: widget.imageUrl,
      content: widget.content,
    );

    try {
      if (isSaved) {
        await FirebaseService.removeSavedArticle(userEmail!, widget.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Article removed from saved list.')),
        );
      } else {
        await FirebaseService.saveArticle(article);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Article saved successfully.')),
        );
      }

      setState(() {
        isSaved = !isSaved;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving article. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigationNotifier = ref.read(bottomNavProvider.notifier);
    final user = ref.watch(authStateProvider);
    bool isPopupOpen = false;

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
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () async {
                final RenderBox renderBox = context.findRenderObject() as RenderBox;
                final Offset offset = renderBox.localToGlobal(Offset.zero);

                if (isPopupOpen) {
                  Navigator.of(context).pop();
                } else {
                  isPopupOpen = true;
                  await showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(offset.dx + 900, offset.dy + 80, offset.dx + 22, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(color: Colors.grey, width: 1),
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
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: const [
                            Icon(Icons.share, color: Colors.black),
                            SizedBox(width: 10),
                            Text(
                              'Share',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).then((value) {
                    isPopupOpen = false;

                    if (value == 'save' && user != null) {
                      toggleSaveArticle();
                    } else if (value == 'share') {
                      ShareUtil.sharePost(
                        context,
                        widget.id,
                        pageRoute: 'blogdetailscreen',
                      );
                    }
                  });
                }
              },
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
                      widget.content.isNotEmpty ? ShareUtil.removeHtmlTags(widget.content) : 'Content not available',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavigationWidget(),
      ),
    );
  }
}
