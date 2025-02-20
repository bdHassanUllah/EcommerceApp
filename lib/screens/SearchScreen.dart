import 'package:e_commerce/screens/PostDetailScreen.dart';
import 'package:e_commerce/widgets/BottomNavigationWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

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

    _searchResults = data.where((post) =>
      post["title"] != null && post["title"].toLowerCase().contains(query.toLowerCase())
    ).toList();

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Explore", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search News",
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
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
            SizedBox(height: 15),

            // 🔹 Show suggestions as user types
            if (_isSearchBarFocused) ...[
              Container(
                padding: EdgeInsets.only(top: 8),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: previousSearches.where((keyword) =>
                          keyword.toLowerCase().contains(_searchController.text.toLowerCase()))
                      .toList().length,
                  itemBuilder: (context, index) {
                    String suggestion = previousSearches.where((keyword) =>
                          keyword.toLowerCase().contains(_searchController.text.toLowerCase()))
                        .toList()[index];

                    return GestureDetector(
                      onTap: () {
                        _searchController.text = suggestion;
                        _performSearch(suggestion);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 5.0),
                        child: Row(
                          children: [
                            Icon(Icons.history, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(suggestion, style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            // 🔹 Show trending news and previous search keywords when not focused
            if (!_isSearchBarFocused) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: previousSearches.map((keyword) {
                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          _searchController.text = keyword;
                          _performSearch(keyword);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            keyword,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20),
              Text("Trending News", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _searchResults[index]["featured_image"] ?? 
                                  "https://via.placeholder.com/150",
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.network(
                                  "https://via.placeholder.com/150",
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                          title: Text(_searchResults[index]['title'] ?? "No title"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostDetailScreen(
                                  post: _searchResults[index],
                                  postContent: _searchResults[index]['content'] ?? "Content not available",
                                ),
                              ),
                            );
                          },
                        ),
                        Divider(),
                      ],
                    );
                  },
                ),
              ),
            ] else if (_isLoading) ...[
              Center(child: CircularProgressIndicator()),
            ] else ...[
              Center(child: Text("No results found")),
            ]
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationWidget(),
    );
  }
}
