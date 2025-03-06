import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:e_commerce/state_provider/AuthStateProvider.dart';
import 'package:flutter/material.dart';
/*import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_commerce/state_provider/BottomStateNavigator.dart';

class BottomNavigationWidget extends ConsumerWidget {
  const BottomNavigationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavProvider);
    final user = ref.watch(authStateProvider); // Listen to auth state changes

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) {
        ref.read(bottomNavProvider.notifier).setIndex(index, context);
      },
      backgroundColor: Color(0xFF2F4568), // Set nav bar background color to blue
      selectedItemColor: Colors.white, // Active tab color
      unselectedItemColor: Colors.white70, // Inactive tab color (light gray)
      type: BottomNavigationBarType.fixed, // Keeps the text labels visible
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: user != null && user.photoURL != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(user.photoURL!),
                  radius: 12,
                )
              : const Icon(Icons.account_circle),
          label: user != null ? user.displayName ?? 'Profile' : 'Login',
        ),
      ],
    );
  }
}*/

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_commerce/state_provider/BottomStateNavigator.dart';

class BottomNavigationWidget extends ConsumerWidget {
  const BottomNavigationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavProvider);
    final user = ref.watch(authStateProvider); // Listen to auth state changes

    return CurvedNavigationBar(
      backgroundColor: Colors.white, // Background behind the bar
      color: const Color(0xFF2F4568), // Nav bar color
      buttonBackgroundColor: Colors.white, // Active icon background
      animationDuration: const Duration(minutes: 5), // Smooth animation
      index: selectedIndex, // Set selected tab
      onTap: (index) {
        ref.read(bottomNavProvider.notifier).setIndex(index, context);
      },
      items: [
        Icon(
          Icons.home,
          size: 30,
          color: selectedIndex == 0 ? Colors.black : Colors.white, // Active: Black, Inactive: White
        ),
        Icon(
          Icons.search,
          size: 30,
          color: selectedIndex == 1 ? Colors.black : Colors.white, // Active: Black, Inactive: White
        ),
        user != null && user.photoURL != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(user.photoURL!),
                radius: 15, // Adjusted for better visibility
              )
            : Icon(
                Icons.account_circle,
                size: 30,
                color: selectedIndex == 2 ? Colors.black : Colors.white, // Active: Black, Inactive: White
              ),
      ],
    );
  }
}



/*import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';


class BottomNavigationWidget extends StatefulWidget {
  @override
  _BottomNavigationWidgetState createState() => _BottomNavigationWidgetState();
}

class _BottomNavigationWidgetState extends State<BottomNavigationWidget> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          _buildPage("Home", Colors.blueAccent),
          _buildPage("Search", Colors.orangeAccent),
          _buildPage("Profile", Colors.greenAccent),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: Colors.white,
        animationDuration: Duration(milliseconds: 400),
        items: const [
          Icon(Icons.home, size: 30, color: Colors.black),
          Icon(Icons.search, size: 30, color: Colors.black),
          Icon(Icons.person, size: 30, color: Colors.black),
        ],
        index: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(index,
              duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
        },
      ),
    );
  }

  Widget _buildPage(String title, Color color) {
    return Container(
      color: color,
      child: Center(
        child: Text(
          title,
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}*/
