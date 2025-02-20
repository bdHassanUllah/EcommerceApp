import 'package:e_commerce/state_provider/AuthStateProvider.dart';
import 'package:e_commerce/state_provider/BottomStateNavigator.dart';
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

  @override
  void initState() {
    super.initState();
    marketplaceItems = MarketplaceUrl.fetchMktPosts();
    _loadSavedPosts();
  }

  Future<void> _loadSavedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPostsList = prefs.getStringList('saved_posts') ?? [];
    setState(() {
      savedPosts = savedPostsList.toSet();
    });
  }

  Future<void> _toggleSavePost() async {
    final prefs = await SharedPreferences.getInstance();
    if (savedPosts.contains(widget.title)) {
      savedPosts.remove(widget.title);
    } else {
      savedPosts.add(widget.title);
    }
    await prefs.setStringList('saved_posts', savedPosts.toList());
    setState(() {});
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
                if (value == 'save' && user != null) {
                  _toggleSavePost();
                } else if (value == 'share') {
                  Share.share("${widget.title}\n\n${removeHtmlTags(widget.content)}");
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
                    title: Text('Save'),
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
