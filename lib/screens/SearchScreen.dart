import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'PostDetailScreen.dart';
import '../widgets/BottomNavigationWidget.dart';
import '../model/HiveModel.dart';
import '../main.dart'; // Import where `hiveBoxProvider` is defined

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<HiveModel> _allPosts = [];
  List<HiveModel> _filteredPosts = [];

  @override
  void initState() {
    super.initState();
    _loadAllDataFromHive();
  }

  void _loadAllDataFromHive() {
    final box = ref.read(hiveBoxProvider);

    if (box.isNotEmpty) {
      _allPosts = box.values.toList();
      print("✅ Hive Data Loaded: \${_allPosts.length} posts/blogs");
    } else {
      print("⚠️ No data found in Hive");
    }

    setState(() {});
  }

  void _searchPosts(String query) {
    if (query.length < 2) {
      setState(() => _filteredPosts = []);
      return;
    }

    String lowerQuery = query.toLowerCase();
    List<HiveModel> results = _allPosts.where((post) {
      String title = post.title.toLowerCase();
      return title.startsWith(lowerQuery) || title.contains(lowerQuery);
    }).toList();

    print("🔍 Search Query: '\$query' - Found: \${results.length} results");

    setState(() {
      _filteredPosts = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
        backgroundColor: const Color(0xFF2F4568),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search News & Blogs...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchPosts('');
                        },
                      )
                    : null,
              ),
              onChanged: _searchPosts,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _filteredPosts.isEmpty
                  ? (_allPosts.isEmpty
                          ? const Center(
                              child: Text(
                                "No posts/blogs available",
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          : _buildTrendingNews() // Show trending news when no search is active
                      )
                  : ListView.separated(
                      itemCount: _filteredPosts.take(6).length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final post = _filteredPosts[index];
                        return _buildNewsCard(
                          imageUrl: post.imageUrl,
                          title: post.title,
                          post: post,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationWidget(),
    );
  }

  Widget _buildNewsCard({
    required String imageUrl,
    required String title,
    required dynamic post,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(
              hiveModels: HiveModel(
                id: post.id.toString(), // Use post.id instead of post['id']
                title: post.title ?? "None",
                imageUrl: post.imageUrl ?? "featured_image",
                content: post.content ?? "No content available",
                date: post.date ?? "created_date",
                permalink: post.permalink ?? "https://ecommerce.com.pk",
              ),
            ),
          ),
        );
      },
      child: ListTile(
        leading: SizedBox(
          width: 80,
          height: 80,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Image.asset(
                'lib/assets/image/placeholder.png',
                fit: BoxFit.cover,
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(title),
      ),
    );
  }

  Widget _buildTrendingNews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Trending News",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: _allPosts.isNotEmpty
              ? ListView.separated(
                  itemCount: _allPosts.take(6).length,
                  separatorBuilder: (context, index) => const Divider(), // ✅ Divider added here
                  itemBuilder: (context, index) {
                    final post = _allPosts[index];
                    return _buildNewsCard(
                      imageUrl: post.imageUrl,
                      title: post.title,
                      post: post,
                    );
                  },
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ), // Show loader if no data yet
        ),

      ],
    );
  }
}
