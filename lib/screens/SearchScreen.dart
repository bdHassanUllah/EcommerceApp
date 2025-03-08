/*import 'package:e_commerce/screens/PostDetailScreen.dart';
import 'package:e_commerce/widgets/BottomNavigationWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  List<dynamic> _trendingNews = [];
  bool _isLoading = false;
  bool _isSearchBarFocused = false;
  List<String> previousSearches = [];

  Future<void> fetchPosts() async {
    try {
      final response = await http.get(
        Uri.parse("https://ecommerce.com.pk/wp-json/api/v1/happenings/"),
        headers: {'passkey': 'kW044]50^(ty'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List;
        final validPosts = jsonData.where((item) {
          final imageUrl = item["featured_image"]?.toString() ?? "";
          return Uri.tryParse(imageUrl)?.isAbsolute ?? false;
        }).toList();

        setState(() {
          _searchResults = validPosts.map((item) {
            return {
              "title": (item["title"] ?? "No Title").split(":").first.trim(),
              "featured_image": item["featured_image"],
              "content": item["content"] ?? "",
              "postId": item["id"] ?? 0,
            };
          }).toList();

          validPosts.shuffle();
          _trendingNews = validPosts.take(4).toList();
        });
      }
    } catch (e) {
      print("Error fetching posts: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    //final user = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search News",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onTap: () {
                setState(() {
                  _isSearchBarFocused = true;
                });
              },
              onChanged: (query) {
                setState(() {
                  _isSearchBarFocused = query.isNotEmpty;
                });
              },
            ),
            const SizedBox(height: 15),
            Expanded(
              child: _isSearchBarFocused
                  ? _buildSearchResults()
                  : _buildTrendingNews(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationWidget(),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return const Center(child: Text("No results found"));
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final post = _searchResults[index];
        return _buildNewsCard(
          imageUrl: post["featured_image"],
          title: post["title"],
          post: post,
        );
      },
    );
  }

  Widget _buildTrendingNews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Trending News", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (_trendingNews.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: _trendingNews.length,
              itemBuilder: (context, index) {
                final post = _trendingNews[index];
                return _buildNewsCard(
                  imageUrl: post["featured_image"],
                  title: post["title"],
                  post: post,
                );
              },
            ),
          )
        else
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }}*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce/screens/PostDetailScreen.dart';
import 'package:e_commerce/widgets/BottomNavigationWidget.dart';
import 'package:e_commerce/model/HiveModel.dart';
import 'package:e_commerce/main.dart'; // Import where `hiveBoxProvider` is defined

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
          ? const Center(child: Text("No posts/blogs available", style: TextStyle(fontSize: 16)))
          : _buildTrendingNews() // Show trending news when no search is active
        )
      : ListView.builder(
          itemCount: _filteredPosts.take(6).length,
          itemBuilder: (context, index) {
            final post = _filteredPosts[index];
            return _buildNewsCard(
              imageUrl: post.imageUrl, 
              title: post.title, 
              post: post
            );
          },
        ),
)


          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationWidget(),
    );
  }

  Widget _buildNewsCard({required String imageUrl, required String title, required dynamic post}) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostDetailScreen(
              images: post.imageUrl,
              postContent: post.content,
              id: post.id.toString(), 
              title: post.title,
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
      const Text("Trending News", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      Expanded(
        child: _allPosts.isNotEmpty
            ? ListView.builder(
                itemCount: _allPosts.take(6).length, // ✅ Show only 6 trending posts
                itemBuilder: (context, index) {
                  final post = _allPosts[index];
                  return _buildNewsCard(
                    imageUrl: post.imageUrl, 
                    title: post.title, 
                    post: post
                  );
                },
              )
            : const Center(child: CircularProgressIndicator()), // Show loader if no data yet
      ),
    ],
  );
}


  

}
