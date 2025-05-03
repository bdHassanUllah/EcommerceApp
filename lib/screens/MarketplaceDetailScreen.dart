import 'package:e_commerce_app/state_provider/BottomStateNavigator.dart';
import 'package:e_commerce_app/widgets/BottomNavigationWidget.dart';
import 'package:e_commerce_app/widgets/Functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarketplaceDetailScreen extends ConsumerStatefulWidget {
  final String id;
  final String title;
  final String imageUrl;
  final String content;

  const MarketplaceDetailScreen({
    super.key,
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.content,
  });

  @override
  _MarketplaceDetailScreenState createState() =>
      _MarketplaceDetailScreenState();
}

class _MarketplaceDetailScreenState
    extends ConsumerState<MarketplaceDetailScreen> {
  late Future<List<Map<String, dynamic>>> marketplaceItems;
  Set<String> savedPosts = {};
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
  }

  @override
  Widget build(BuildContext context) {
    //final selectedIndex = ref.watch(bottomNavProvider);
    final navigationNotifier = ref.read(bottomNavProvider.notifier);
    //final user = ref.watch(authStateProvider);

    return PopScope(
      canPop: true, // Allows back navigation
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          navigationNotifier; // Keeping your original logic
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF2F4568),
          foregroundColor: Colors.white,
          title: Text(widget.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                ShareUtil.sharePost(
                  context,
                  widget.title,
                  pageRoute:
                      'marketplace', // Custom route for marketplace posts
                );
              },
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
              ShareUtil.removeHtmlTags(widget.title),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              ShareUtil.removeHtmlTags(widget.content),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationWidget(),
      ),
    );
  }
}
