import 'package:curved_navigation_bar/curved_navigation_bar.dart';
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
          color: selectedIndex == 0
              ? Colors.black
              : Colors.white, // Active: Black, Inactive: White
        ),
        Icon(
          Icons.search,
          size: 30,
          color: selectedIndex == 1
              ? Colors.black
              : Colors.white, // Active: Black, Inactive: White
        ),
        user != null && user.photoURL != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(user.photoURL!),
                radius: 15, // Adjusted for better visibility
              )
            : Icon(
                Icons.account_circle,
                size: 30,
                color: selectedIndex == 2
                    ? Colors.black
                    : Colors.white, // Active: Black, Inactive: White
              ),
      ],
    );
  }
}
