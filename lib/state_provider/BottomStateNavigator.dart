import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';

final bottomNavProvider = StateNotifierProvider<BottomNavNotifier, int>(
  (ref) => BottomNavNotifier(),
);

class BottomNavNotifier extends StateNotifier<int> {
  BottomNavNotifier() : super(0);

  void setIndex(int index, BuildContext context) {
    if (state == index) return; // Prevent duplicate navigation

    state = index; // Update the selected tab

    // Check if user is logged in
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    // Navigate based on the index
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        break;
      case 1:
        Navigator.pushNamedAndRemoveUntil(context, '/search', (route) => false);
        break;
      case 2:
        if (isLoggedIn) {
          Navigator.pushNamedAndRemoveUntil(context, '/profile', (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/loginscreen', (route) => false);
        }
      break;
    }
  }
}