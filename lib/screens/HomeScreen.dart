import 'package:e_commerce/Api_files/MarketplaceApi.dart';
import 'package:e_commerce/Api_files/BusinessApi.dart';
import 'package:e_commerce/state_provider/AuthStateProvider.dart';
import 'package:flutter/material.dart';
import 'package:e_commerce/Api_files/PostApi.dart';
import 'package:e_commerce/Api_files/ImageApi.dart';
import 'package:e_commerce/screens/BusinessScreen.dart';
import 'package:e_commerce/screens/LoginScreen.dart';
import 'package:e_commerce/screens/MarketplaceScreen.dart';
import 'package:e_commerce/screens/SearchScreen.dart';
import 'package:e_commerce/screens/ProfileScreen.dart'; 
import 'package:e_commerce/state_provider/BottomStateNavigator.dart';
import 'package:e_commerce/state_provider/TabStateNavigation.dart';
import 'package:e_commerce/widgets/BottomNavigationWidget.dart';
import 'package:e_commerce/widgets/PostWidget.dart';
import 'package:e_commerce/widgets/TabWidget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<List<dynamic>>? posts;
  Future<List<dynamic>>? images;
  Future<List<dynamic>>? mrktplace;
  Future<List<Map<String, String>>>? businesspage; // Updated type

  @override
  void initState() {
    super.initState();
    posts = ApiService.fetchPosts('');
    images = ImgApiURL().fetchImage();
    mrktplace = MarketplaceUrl.fetchMktPosts('');
    businesspage = Businessurl.fetchBusinessPosts('') as Future<List<Map<String, String>>>?;// Correct API call
  }

  // Method to get the tab content
  Widget getSelectedTabPage(int selectedTabIndex) {
    switch (selectedTabIndex) {
      case 0:
        return FutureBuilder<List<dynamic>>(
          future: posts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No posts found"));
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                String imageUrl = snapshot.data![index]["featured_image"] ?? "https://via.placeholder.com/150";
                return PostWidget(
                  post: snapshot.data![index],
                  imageUrl: imageUrl,
                );
              },
            );
          },
        );
      case 1:
        return const MarketplaceScreen();
      case 2:
        return const BusinessScreen(); 
        /*return FutureBuilder<List<Map<String, String>>>(
          future: businesspage,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No business data found"));
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                String title = snapshot.data![index]["title"]!;
                String imageUrl = snapshot.data![index]["image"]!;

                return ListTile(
                  leading: Image.network(
                    imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset("lib/assets/image/placeholder.png", width: 50, height: 50);
                    },
                  ),
                  title: Text(title),
                );
              },
            );
          },
        );*/
      case 3:
        return const Center(child: Text("Blog Content"));
      default:
        return const Center(child: Text("Publications Content"));
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedTabIndex = ref.watch(tabIndexProvider);
    final selectedIndex = ref.watch(bottomNavProvider);
    final user = ref.watch(authStateProvider); 

    // Titles for each tab
    final List<String> tabTitles = ["Latest Posts", "New Launches", "Business Insights", "Blog"];

    // Define pages for each bottom navigation tab
    final List<Widget> pages = [
      Scaffold(
        appBar: AppBar(
          title: Text(
            tabTitles[selectedTabIndex], 
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            TabsWidget(
              onselectedIndex: selectedTabIndex,
              onTabSelected: (index) {
                ref.read(tabIndexProvider.notifier).changeTab(index);
              },
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
            userName: user.displayName ?? 'Guest', 
            userImage: user.photoURL ?? 'https://via.placeholder.com/150',
          ) 
        : LoginScreen(),
    ];

    return pages[selectedIndex];
  }
}
