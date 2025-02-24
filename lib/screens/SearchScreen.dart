import 'package:e_commerce/screens/PostDetailScreen.dart';
import 'package:e_commerce/state_provider/AuthStateProvider.dart';
import 'package:e_commerce/widgets/BottomNavigationWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
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
  bool _isLoading = false;
  bool _isSearchBarFocused = false;
  List<String> previousSearches = [];

  Future<void> fetchPosts() async {
  try {
    final response = await http.get(
      Uri.parse("https://ecommerce.com.pk/wp-json/api/v1/happenings/"),
      headers: {'passkey': 'kW044]50^(ty'},
    );

    print("API Response Status Code: ${response.statusCode}");
    print("API Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as List;
      final validPosts = jsonData.where((item) {
        final imageUrl = item["featured_image"]?.toString() ?? "";
        return Uri.tryParse(imageUrl)?.isAbsolute ?? false;
      }).toList();

      print("Valid Posts Count: ${validPosts.length}");

      setState(() {
        _searchResults = validPosts.map((item) {
          return {
            "title": (item["title"] ?? "No Title").split(":").first.trim(),
            "featured_image": item["featured_image"],
            "content": item["content"] ?? "",
          };
        }).toList();
      });

      print("Processed Posts: $_searchResults");
    }
  } catch (e) {
    print("Error fetching posts: $e");
  }
}

  Future<void> _loadPreviousSearches() async {
    var box = await Hive.openBox('searchHistoryBox');
    setState(() {
      previousSearches = List<String>.from(box.get('previousSearches', defaultValue: []));
    });
  }

  Future<void> _savePreviousSearches() async {
    var box = await Hive.openBox('searchHistoryBox');
    await box.put('previousSearches', previousSearches);
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
    });

    var box = await Hive.openBox('cacheBox');
    var data = box.get('articles', defaultValue: []);

    _searchResults = data
        .where((post) =>
            post["title"] != null && post["title"].toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      _isLoading = false;
    });
  }

  void _onSubmitSearch(String query) {
    if (query.isNotEmpty && !previousSearches.contains(query)) {
      setState(() {
        if (previousSearches.length >= 5) {
          previousSearches.removeAt(0);
        }
        previousSearches.add(query);
      });
      _savePreviousSearches();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPreviousSearches();
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
            // 🔹 Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search News",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                          setState(() {
                            _isSearchBarFocused = false;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (query) {
                _performSearch(query);
                setState(() {
                  _isSearchBarFocused = query.isNotEmpty;
                });
              },
              onTap: () {
                setState(() {
                  _isSearchBarFocused = true;
                });
              },
              onSubmitted: (query) {
                _performSearch(query);
                _onSubmitSearch(query);
                setState(() {
                  _isSearchBarFocused = false;
                });
              },
            ),
            const SizedBox(height: 15),

            // 🔹 Show suggestions as user types
            if (_isSearchBarFocused)
              Container(
                padding: const EdgeInsets.only(top: 8),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: previousSearches
                      .where((keyword) =>
                          keyword.toLowerCase().contains(_searchController.text.toLowerCase()))
                      .length,
                  itemBuilder: (context, index) {
                    String suggestion = previousSearches
                        .where((keyword) =>
                            keyword.toLowerCase().contains(_searchController.text.toLowerCase()))
                        .toList()[index];

                    return GestureDetector(
                      onTap: () {
                        _searchController.text = suggestion;
                        _performSearch(suggestion);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Row(
                          children: [
                            const Icon(Icons.history, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(suggestion, style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            // 🔹 Show trending topics and news when not focused
            if (!_isSearchBarFocused) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: previousSearches.map((keyword) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          _searchController.text = keyword;
                          _performSearch(keyword);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            keyword,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Trending News",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

        
              // Trending News List
              /*Expanded(
                child: ListView(
                  children: [
                    _buildNewsCard(
                      imageUrl: "https://via.placeholder.com/150",
                      title: "Deepseek VS OpenAI: Is Deepseek AI the New Challenger?",
                    ),
                    _buildNewsCard(
                      imageUrl: "https://via.placeholder.com/150",
                      title: "Which Chinese AI App Has Surpassed ChatGPT?",
                    ),
                    _buildNewsCard(
                      imageUrl: "https://via.placeholder.com/150",
                      title: "How Is Generative AI Transforming Cybersecurity?",
                    ),
                  ],
                ),
              ),*/
            ] else if (_isLoading) ...[
              const Center(child: CircularProgressIndicator()),
            ] else if (_searchResults.isNotEmpty) ...[
              Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final post = _searchResults[index];
                  return ListTile(
                    leading: SizedBox(
                      width: 80,
                      height: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: post["featured_image"],
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            'lib/assets/image/placeholder.png',
                            fit: BoxFit.cover,
                          ),
                          fit: BoxFit.cover,
                        )
                      ),
                    ),
                    title: Text(post['title'] ?? "No title"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailScreen(
                            post: post,
                            postContent: post['content'],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationWidget(),
    );
  }

  Widget _buildTrendingChip(String label) {
    return Chip(label: Text(label), backgroundColor: Colors.grey[200]);
  }

  Widget _buildNewsCard({required String imageUrl, required String title}) {
    return ListTile(
      leading: SizedBox(
        width: 80,
        height: 80,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => 
              Image.asset(
                'lib/assets/image/placeholder.jpg',
                fit: BoxFit.cover,
              ),
          ),
        ),
      ),
      title: Text(title),
    );
  }

}
