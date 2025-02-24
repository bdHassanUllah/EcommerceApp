/*import 'package:e_commerce/state_provider/AuthStateProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_commerce/state_provider/BottomStateNavigator.dart';

class BottomNavigationWidget extends ConsumerWidget {
  const BottomNavigationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavProvider);
    final user = ref.watch(authStateProvider); // Get user authentication state

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      // Bottom Navigation Widget
      onTap: (index) {
        ref.read(bottomNavProvider.notifier).setIndex(index, context);
      },
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
                  backgroundImage: NetworkImage(user.photoURL!), // Google Image
                  radius: 12, // Adjust size
                )
              : const Icon(Icons.account_circle), // Default Account Icon
              label: user != null ? user.displayName ?? 'Profile' : 'Login',
        ),
      ],
    );
  }
}*/

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

    // If user is logged out and currently on Profile screen, navigate to Login
    /*if (user == null && selectedIndex == 2) {
      Future.microtask(() {
        Navigator.pushNamedAndRemoveUntil(context, '/loginscreen', (route) => false);
      });
    }*/

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) {
        ref.read(bottomNavProvider.notifier).setIndex(index, context);
      },
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