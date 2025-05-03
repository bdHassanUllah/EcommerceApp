import 'NotificationScreen.dart';
import '../state_provider/NotificationNotifier.dart';
import 'package:flutter/material.dart';
import '../state_provider/StateProvider.dart';
import '../state_provider/AuthStateProvider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state_provider/BottomStateNavigator.dart';
import '../state_provider/TabStateNavigation.dart';
import 'SearchScreen.dart';
import 'LoginScreen.dart';
import 'ProfileScreen.dart';
import 'MarketplaceScreen.dart';
import 'BusinessScreen.dart';
import 'BlogPost.dart';
import '../widgets/BottomNavigationWidget.dart';
import '../widgets/TabWidget.dart';
import '../widgets/PostWidget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTabIndex = ref.watch(tabIndexProvider);
    final selectedIndex = ref.watch(bottomNavProvider);
    final user = ref.watch(authStateProvider);

    final List<String> tabTitles = [
      "Latest Posts",
      "New Launches",
      "Business Insights",
      "Blog",
    ];

    final posts = ref.watch(postProvider);
    final marketplacePost = ref.watch(marketplaceProviders);
    final blogPosts = ref.watch(blogProvider);
    final businessPosts = ref.watch(businessProvider);

    Widget getSelectedTabPage(int index) {
      switch (index) {
        case 0:
          return _buildPostList(posts);
        case 1:
          return _buildMarketplaceList(marketplacePost);
        case 2:
          return _buildBusinessPost(businessPosts);
        case 3:
          return _buildBlogPost(blogPosts);
        default:
          return const Center(child: Text("No Content"));
      }
    }

    final List<Widget> pages = [
      Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF2F4568),
          foregroundColor: Colors.white,
          title: Text(
            tabTitles[selectedTabIndex],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () {
                    // Clear notification indicator when tapped
                    ref.read(hasNotificationProvider.notifier).state = false;

                    // Navigate to the Notification Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationScreen(),
                      ),
                    );
                  },
                ),
                if (ref.watch(hasNotificationProvider)) // ✅ Ensure it's always a boolean
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            TabsWidget(
              onselectedIndex: selectedTabIndex,
              onTabSelected: (index) =>
                  ref.read(tabIndexProvider.notifier).changeTab(index),
              tabs: const ["Publications", "Marketplace", "Business", "Blog"],
            ),
            Expanded(child: getSelectedTabPage(selectedTabIndex)),
          ],
        ),
        bottomNavigationBar: BottomNavigationWidget(),
      ),
      const SearchScreen(),
      user != null
          ? ProfileScreen(
              userName: user.displayName ?? '',
              userImage: user.photoURL ?? 'https://via.placeholder.com/150',
            )
          : LoginScreen(),
    ];

    return pages[selectedIndex];
  }

  Widget _buildPostList(AsyncValue<List<dynamic>> posts) {
    return posts.when(
      data: (data) {
        if (data.isEmpty) {
          return const Center(child: Text("No posts available"));
        }
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) => PostWidget(post: data[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text("Error: $error")),
    );
  }

  Widget _buildMarketplaceList(AsyncValue<List<dynamic>> marketplacePosts) {
    return marketplacePosts.when(
      data: (data) => MarketplaceScreen(),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text("Error: $error")),
    );
  }

  Widget _buildBlogPost(AsyncValue<List<dynamic>> blogPosts) {
    return blogPosts.when(
      data: (data) => BlogScreen(),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text("Error: $error")),
    );
  }

  Widget _buildBusinessPost(AsyncValue<List<dynamic>> businessPosts) {
    return businessPosts.when(
      data: (data) => BusinessPage(),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text("Error: $error")),
    );
  }
}
