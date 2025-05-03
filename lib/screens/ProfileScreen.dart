import '../model/HiveModel.dart';
import 'PostDetailScreen.dart';
import '../widgets/BottomNavigationWidget.dart';
import '../widgets/CustomButton.dart';
import '../widgets/ProfileScreenFunctions.dart';
import '../widgets/SavedArticle.dart';
import '../widgets/UserProfileWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String userName;
  final String userImage;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.userImage,
  });

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late Profilescreenfunctions _profileFunctions;
  List<Map<String, dynamic>> savedPosts = [];
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    // Initialize Profile Functions
    _profileFunctions = Profilescreenfunctions(ref: ref, context: context);
    _profileFunctions.init();

    // Fetch Saved Articles
    _fetchSavedPosts();
  }

  @override
  void dispose() {
    _isDisposed = true; // ✅ Mark widget as disposed
    super.dispose();
  }

  Future<void> _fetchSavedPosts() async {
    if (_profileFunctions.userEmail == null) return;

    SavedArticlesFetcher fetcher = SavedArticlesFetcher(
      userEmail: _profileFunctions.userEmail!,
    );
    List<Map<String, dynamic>> posts = await fetcher.fetchSavedPosts();
    if (_isDisposed) return;

    setState(() {
      savedPosts = posts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PROFILE', style: TextStyle(fontSize: 25)),
        backgroundColor: const Color(0xFF2F4568),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 28),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 30, 8, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserProfileWidget(
              userName: widget.userName,
              userImage: widget.userImage,
            ),
            const SizedBox(height: 25),
            CustomButton(
              text: "Change Account",
              onPressed: () async {
                final profileFunctions = Profilescreenfunctions(
                  ref: ref,
                  context: context,
                );
                await profileFunctions
                    .changeAccount(); // ✅ Correct Instance Method Call
                _fetchSavedPosts(); // Refresh saved posts after account change
              },
              backgroundColor: const Color.fromARGB(255, 2, 41, 74),
              textColor: Colors.white,
            ),
            const SizedBox(height: 40),
            const Text(
              'Saved Articles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: savedPosts.isEmpty
                  ? const Center(child: Text("No saved articles found."))
                  : ListView.builder(
                      itemCount: savedPosts.length,
                      itemBuilder: (context, index) {
                        final article = savedPosts[index];
                        return ListTile(
                          title: Text(article['title'] ?? "Untitled"),
                          leading: (article['imageUrl'] != null &&
                                  article['imageUrl'].isNotEmpty)
                              ? Image.network(
                                  article['imageUrl'],
                                  width: 150,
                                  height: 150,
                                )
                              : Image.asset(
                                  "lib/assets/image/placeholder.jpg",
                                  width: 150,
                                  height: 150,
                                ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostDetailScreen(
                                  hiveModels: HiveModel(
                                    id: article['id'].toString(),
                                    title: article['title'] ?? "None",
                                    imageUrl:
                                        article['imageUrl'] ?? "featured_image",
                                    content: article['content'] ??
                                        "No content available",
                                    date: article['created_date'] != null
                                        ? DateTime.tryParse(
                                              article['created_date']
                                                  .toString(),
                                            ) ??
                                            DateTime
                                                .now() // ✅ Converts to DateTime safely
                                        : DateTime.now(),
                                    permalink: article['permalink'] ??
                                        "https://ecommerce.com.pk", // ✅ Uses current date as fallback
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            Center(
              child: CustomButton(
                text: "Logout",
                onPressed: () async {
                  Profilescreenfunctions.showLogoutDialog(context, () {
                    final profileFunctions = Profilescreenfunctions(
                      ref: ref,
                      context: context,
                    );
                    profileFunctions
                        .logout(); // Logout the user after confirmation
                  });
                },
                backgroundColor: Colors.white,
                textColor: Colors.black,
                borderColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationWidget(),
    );
  }
}
