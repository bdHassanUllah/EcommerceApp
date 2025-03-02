import 'package:e_commerce/screens/PostDetailScreen.dart';
import 'package:e_commerce/state_provider/AuthStateProvider.dart';
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
    final user = ref.watch(authStateProvider);

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
      bottomNavigationBar: const BottomNavigationWidget(),
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
  }

  Widget _buildNewsCard({required String imageUrl, required String title, required dynamic post}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(
              post: post,
              postContent: post['content'],
              id: post['postId'].toString(),
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
}
