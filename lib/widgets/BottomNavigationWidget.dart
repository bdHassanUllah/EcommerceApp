import 'package:e_commerce/state_provider/AuthStateProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
}